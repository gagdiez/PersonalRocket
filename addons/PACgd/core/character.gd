class_name PACCharacter
extends PACInteractive
## A character that walks, talks, and carries an inventory.
##
## Attach it to a CharacterBody2D/3D that has an AnimationPlayer, a sprite
## and a NavigationAgent2D/3D as children (found automatically, or set below).
##
## Calling say(), approach(), etc. adds an action to PAC's queue, and they
## are played one after the other.

## The character controlled by the player (its inventory persists across levels)
@export var is_player := false

@export_group("Movement")
@export var speed := 5.0
## Destinations closer than this are not walked to
@export var minimum_walkable_distance := 0.5

@export_group("Animations")
@export var anim_idle := &"idle"
@export var anim_walk := &"walk"
@export var anim_raise_hand := &"raise_hand"
@export var anim_lower_hand := &"lower_hand"

@export_group("Speech")
## Where speech is shown, relative to the character's position
@export var speech_offset := Vector3.ZERO

@export_group("Nodes")
## Found automatically among the character's nodes when not set
@export var animation_player: AnimationPlayer
## Found automatically among the character's nodes when not set
@export var sprite: Node
## Found automatically among the character's nodes when not set
@export var navigation_agent: Node

var inventory := PACInventory.new()


func _init() -> void:
	# If you click on them you will talk to them
	main_action = preload("res://addons/PACgd/actions/talk_to.tres")


func _notification(what: int) -> void:
	# (see PACInteractive._notification)
	match what:
		NOTIFICATION_READY:
			if animation_player == null:
				animation_player = _find_node(["AnimationPlayer"])
			if sprite == null:
				sprite = _find_node(["Sprite3D", "Sprite2D", "AnimatedSprite3D", "AnimatedSprite2D"])
			if navigation_agent == null:
				navigation_agent = _find_node(["NavigationAgent3D", "NavigationAgent2D"])
			if is_player:
				PAC.set_player(self)


func _find_node(classes: Array) -> Node:
	for child in get_children():
		for c in classes:
			if child.is_class(c):
				return child
	return null


# Internal Functions
func face_direction(direction) -> void:
	if sprite:
		space.face(sprite, self, direction)


func speech_screen_position() -> Vector2:
	return space.screen_position(self, speech_offset)


func play_animation(animation) -> void:
	if animation_player:
		animation_player.play(animation)


func say_now(text) -> void:
	PAC.hud.say(self, text)


func quiet() -> void:
	PAC.hud.quiet(self)


# Functions to populate the queue
func add_to_inventory(new_item: PACInteractive) -> void:
	PAC.add_step(STATES.AddToInventory.new(self, new_item))


func animate(animation) -> void:
	PAC.add_step(STATES.Animate.new(self, animation))


func animate_until_finished(animation) -> void:
	PAC.add_step(STATES.AnimateUntilFinished.new(self, animation))


# (cutscenes: "cole call: function param1 param2")
func internal(fc, params) -> void:
	PAC.add_step(STATES.CallFunction.new(self, fc, params))


func face_object(object) -> void:
	PAC.add_step(STATES.FaceObject.new(self, object))


func remove_from_inventory(old_item: PACInteractive) -> void:
	PAC.add_step(STATES.RemoveFromInventory.new(self, old_item))


func say(text, how_long = 2.0) -> void:
	PAC.add_step(STATES.Say.new(self, text, how_long))



func approach(object) -> void:
	_walk(object.interaction_position(), object)


## Walks to a point of the level (i.e. where the player clicked the floor)
func walk_to_point(point) -> void:
	_walk(point, null)


func _walk(point, object_to_face) -> void:
	# Walking is driven by the NavigationAgent, which paths on the world's
	# navigation map (every NavigationRegion in the scene registers there)
	assert(navigation_agent != null, display_name + " needs a NavigationAgent to walk")
	PAC.add_step(STATES.WalkTo.new(self, point))
	if object_to_face:
		PAC.add_step(STATES.FaceObject.new(self, object_to_face))


# Default answers to actions
func receive_item(from, given_item) -> void:
	# The giver hands the item over
	from.animate_until_finished(from.anim_raise_hand)
	from.remove_from_inventory(given_item)
	from.animate_until_finished(from.anim_lower_hand)

	# And we take it
	animate_until_finished(anim_raise_hand)
	add_to_inventory(given_item)
	animate_until_finished(anim_lower_hand)


func talk_to(who) -> void:
	who.approach(self)
	face_object(who)
	say("Hi " + who.display_name)
