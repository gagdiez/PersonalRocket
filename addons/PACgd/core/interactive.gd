class_name PACInteractive
extends Node
## Something the player can interact with.
##
## Attach it (or a script extending it) to a physics object (StaticBody,
## Area, CharacterBody...), in 2D or 3D: the mouse finds objects through their
## collision shapes. Configure it from the Inspector, and extend it to give
## the object its own behaviour by overriding the verbs (examine, take, ...):
##
##     extends PACInteractive
##     func use_item(who, item):
##         who.say("That does not fit here")
##
## It extends Node so the same script works in 2D and 3D: to reach the
## properties of the object it is attached to, write self (self.visible).
##
## Verbs describe what happens, in order: every say(), approach(), run()...
## is added to PAC's queue, and played one after the other:
##
##     func use_item(who, box):
##         who.approach(self)
##         who.animate_until_finished(who.anim_raise_hand)
##         self.run(place_box.bind(box))   # once who has raised the hand
##         who.animate_until_finished(who.anim_lower_hand)
##
## To have several characters act at the same time, use PAC.together().

const PACSpace = preload("space.gd")
const STATES = preload("states.gd")

## Name shown to the player (defaults to the parent's name)
@export var display_name := ""
## What the player says when examining it (defaults to "A good old <name>")
@export_multiline var description := ""
## How cutscenes and scripts refer to it (PAC.get_object("red_box"),
## item.id == "red_box"). Required, and unique
@export var id := ""
## Whether the mouse sees this object
@export var interactive := true
## Left click
@export var main_action: PACAction = preload("res://addons/PACgd/actions/walk_to.tres")
## Right click
@export var secondary_action: PACAction = preload("res://addons/PACgd/actions/examine.tres")
## Image shown in the inventory once the player takes it
@export var thumbnail: Texture2D = preload("res://addons/PACgd/default_thumbnail.png")
## Where characters stand to interact with it (a Marker2D/Marker3D), defaults
## to the object's position
@export var interaction_point: Node

## 2D/3D adapter
var space


# The framework uses notifications instead of _ready/_enter_tree, so the
# scripts extending it can define those freely (without calling super). They
# run after the script's own _ready, so values set there are already in place
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			space = PACSpace.for_node(self)
			if is_node_ready():
				PAC.register(self)  # back in the tree (i.e. moved to the inventory)
		NOTIFICATION_READY:
			_fill_defaults()
			PAC.register(self)
		NOTIFICATION_EXIT_TREE:
			PAC.unregister(self)


func _fill_defaults() -> void:
	if display_name == "":
		display_name = String(name)
	if description == "":
		description = "A good old " + display_name


# Queue
## Calls the function when its turn comes, i.e. run(place_box.bind(box))
func run(function: Callable) -> void:
	PAC.add_step(STATES.Run.new(self, function))


func world_position():
	return self.global_position


func interaction_position():
	return interaction_point.global_position if interaction_point else self.global_position


# Default interactions, override them to customise the object
func examine(who) -> void:
	who.say(description)


func use_item(who, with_item) -> void:
	who.say("I don't know how to use %s with %s" % [display_name, with_item.display_name])


func walk_to(who) -> void:
	who.approach(self)


func take(who) -> void:
	who.approach(self)
	who.animate_until_finished(who.anim_raise_hand)
	run(grab)
	who.add_to_inventory(self)
	who.animate_until_finished(who.anim_lower_hand)


func grab() -> void:
	self.visible = false
	interactive = false
