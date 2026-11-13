extends Node
## The PACgd point and click system, available everywhere as the PAC autoload
## (registered by the plugin).
##
## It keeps track of every PACInteractive in the scene, the player and its
## inventory, translates mouse clicks into actions, owns the HUD (inventory
## bar, dialog choices, speech, cursor label), and plays cutscenes. It lives
## outside the levels, so the player's inventory survives level changes.

const DEFAULT_HUD := "res://addons/PACgd/ui/hud.tscn"
const CutScene = preload("res://addons/PACgd/cutscenes/cutscene.gd")
const STATES = preload("states.gd")

## Emitted when the queue runs out of actions
signal queue_finished

## Verbs usable in cutscenes ("cole take: box"), by keyword
var actions := {
	"add_to_inventory": preload("res://addons/PACgd/actions/add_to_inventory.tres"),
	"call": preload("res://addons/PACgd/actions/call.tres"),
	"examine": preload("res://addons/PACgd/actions/examine.tres"),
	"give": preload("res://addons/PACgd/actions/give.tres"),
	"go_to": preload("res://addons/PACgd/actions/go_to.tres"),
	"open": preload("res://addons/PACgd/actions/open.tres"),
	"read": preload("res://addons/PACgd/actions/read.tres"),
	"remove_from_inventory": preload("res://addons/PACgd/actions/remove_from_inventory.tres"),
	"say": preload("res://addons/PACgd/actions/say.tres"),
	"search": preload("res://addons/PACgd/actions/search.tres"),
	"set": preload("res://addons/PACgd/actions/set.tres"),
	"take": preload("res://addons/PACgd/actions/take.tres"),
	"talk_to": preload("res://addons/PACgd/actions/talk_to.tres"),
	"use": preload("res://addons/PACgd/actions/use.tres"),
	"use_item": preload("res://addons/PACgd/actions/use_item.tres"),
	"walk_to": preload("res://addons/PACgd/actions/walk_to.tres"),
}

## The character controlled by the player
var player: PACCharacter
## The player's inventory, handed to whichever character is the player
var player_inventory := PACInventory.new()
## Every PACInteractive in the scene, by id
var objects := {}
## Disabled while cutscenes play
var active := true
## How far (in 3D) the mouse can reach
var ray_length := 1000.0
## Inventory bar, dialogs, speech and cursor label
var hud: CanvasLayer

## What is under the mouse (in the level or in the inventory), or null
var target = null
## Where the player would walk to: set when the mouse is on the navmesh
var walk_point = null
## The inventory item under the mouse (reported by the HUD)
var hovered_item: PACInteractive = null

## Actions such as "Use <item> with ..." wait for a second click
var combining: PACAction = null
var combining_item = null

## What characters and objects are going to do, one after the other
var queue = preload("queue.gd").Queue.new()
var _together := []

## Cutscenes being played (we hold them until they finish, otherwise they
## would be freed as soon as play_scene returns)
var running_cutscenes := []


func _ready() -> void:
	hud = load(ProjectSettings.get_setting("pac/hud_scene", DEFAULT_HUD)).instantiate()
	add_child(hud)
	hud.item_hovered.connect(func(item): hovered_item = item)
	hud.item_clicked.connect(_on_item_clicked)
	hud.show_inventory(player_inventory)
	hud.visible = false  # until there is a player (i.e. not in a main menu)


## Starts over: empties the player's inventory and stops all cutscenes (i.e.
## when going back to a main menu; changing levels keeps everything)
func reset() -> void:
	for item in player_inventory.items:
		item.queue_free()
	player_inventory = PACInventory.new()
	if player:
		player.inventory = player_inventory
	hud.show_inventory(player_inventory)
	_stop_everything()


## Drops the queue and the cutscenes (i.e. the level they were happening in
## is gone)
func _stop_everything() -> void:
	running_cutscenes.clear()
	queue.clear()
	active = true
	_stop_combining()


# Queue
## Adds an action at the end of the queue (characters and objects call it
## from say(), approach(), run()...)
func add_step(state) -> void:
	if _together:
		_together[-1].add(state)
	else:
		queue.append(state)


## The actions added inside the function happen at the same time: each
## character does theirs in order, and the queue goes on when all are done
##
##     PAC.together(func():
##         who.say("Is that... me?")
##         self.approach(who)
##     )
func together(actions: Callable) -> void:
	var group = STATES.Together.new()
	_together.append(group)
	actions.call()
	_together.pop_back()
	add_step(group)


## Stops what is going on, unless it cannot be interrupted (i.e. talking)
func interrupt() -> bool:
	if queue.empty() or queue.busy():
		return false
	var current = queue.current()
	if current:
		current.stop()
	queue.clear()
	return true


func _physics_process(_delta: float) -> void:
	if queue.empty():
		return
	if not queue.run():
		queue_finished.emit()


# Registry
func register(object: PACInteractive) -> void:
	if object.id == "":
		push_error("%s has no id: set one in its script (id = \"...\") or in the Inspector" % object.get_path())
		return
	var other = objects.get(object.id)
	if other and other != object:
		push_warning("Two objects have the id '%s' (%s, %s)"
				% [object.id, other.get_path(), object.get_path()])
	objects[object.id] = object


func unregister(object: PACInteractive) -> void:
	if objects.get(object.id) == object:
		objects.erase(object.id)
	if object == player:
		# The player left the level: what was going on there is over
		player = null
		hud.visible = false
		_stop_everything()


func set_player(character: PACCharacter) -> void:
	player = character
	player.inventory = player_inventory
	hud.visible = true


## The PACInteractive with the given id
func get_object(id: String) -> PACInteractive:
	return objects.get(id)


## Makes a custom PACAction available in cutscenes under the given keyword
func register_action(keyword: String, action: PACAction) -> void:
	actions[keyword] = action


# Mouse
func _process(_delta) -> void:
	if not active or player == null:
		hud.set_cursor_label("", Vector2.ZERO)
		return

	var mouse = get_viewport().get_mouse_position()
	_update_target(mouse)
	hud.set_cursor_label(_label(), mouse)


func _unhandled_input(event: InputEvent) -> void:
	# Clicks on the HUD (or on any other UI of the game) never reach this
	if not active or player == null or queue.busy():
		return
	if event is InputEventMouseButton and not event.pressed:
		_update_target(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			_main_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_secondary_click()


func _on_item_clicked(item: PACInteractive, button_index: int) -> void:
	if not active or player == null or queue.busy():
		return
	target = item
	walk_point = null
	if button_index == MOUSE_BUTTON_LEFT:
		_main_click()
	elif button_index == MOUSE_BUTTON_RIGHT:
		_secondary_click()


func _update_target(mouse: Vector2) -> void:
	target = null
	walk_point = null
	if hovered_item:
		target = hovered_item
	elif not get_viewport().gui_get_hovered_control():  # not over some UI
		var under = player.space.pick(get_viewport(), player.navigation_agent, mouse, ray_length)
		target = under.get("object")
		walk_point = under.get("point")


func _label() -> String:
	if combining:
		var text = "%s %s %s" % [combining.label, combining_item.display_name, combining.nexus]
		if target and target != combining_item:
			text += " " + target.display_name
		return text
	if target:
		var verb = target.main_action.label if target.main_action else ""
		return (verb + " " + target.display_name).strip_edges()
	return ""


func _main_click() -> void:
	if target == null:
		# Clicking the floor walks there, clicking anything else stops
		interrupt()
		if walk_point != null and not combining:
			player.walk_to_point(walk_point)
		_stop_combining()
		return

	if combining:
		interrupt()
		combining.execute(player, target, combining_item)
		_stop_combining()
		return

	var action: PACAction = target.main_action
	if action == null:
		return
	if action.type == PACAction.Type.TO_COMBINE:
		# Wait for the second object: "Use <item> with ..."
		combining = action
		combining_item = target
	else:
		interrupt()
		action.execute(player, target)


func _secondary_click() -> void:
	if target:
		if target.secondary_action:
			interrupt()
			target.secondary_action.execute(player, target)
	_stop_combining()


func _stop_combining() -> void:
	combining = null
	combining_item = null


# Cutscenes
func play_scene(scene_file: String, extra := {}) -> void:
	# Cutscenes can refer to every object by its id (including the
	# ones in the inventory), and to anything passed in extra
	var names := objects.duplicate()
	names.merge(extra, true)

	_stop_combining()
	var cutscene = CutScene.new(scene_file, names, self)
	running_cutscenes.append(cutscene)
	cutscene.finished.connect(_on_cutscene_finished)
	cutscene.play()


func _on_cutscene_finished(cutscene) -> void:
	# Dropping our reference frees the cutscene (and everything it parsed)
	running_cutscenes.erase(cutscene)
