extends Interactive2D
class_name Character2D

# A player is basically a queue of actions that is constantly running
const STATES = preload("States.gd")
var queue = preload("Queue.gd").Queue.new()

# They know where the camera is, where they can walk
var camera
var navigation

# They have an inventory
var inventory = Inventory.new()

# Their NODE has an animation player, a sprite, and a talk bubble
onready var animation_player = $Animations
onready var talk_bubble = $TalkBubble
onready var sprite = $Sprite

# They have a speed, and they don't move if the destination is close
var SPEED = 5
var MINIMUM_WALKABLE_DISTANCE = .5

# They can signal after finising actions
signal player_finished
signal message(signal_name)

# If you click on them you will talk to them
func _ready():
	main_action = ACTIONS.talk_to
	secondary_action = ACTIONS.examine


# GODOT Function
# We constantly check if it has an action to run
var doing = false  # -> for emiting a signal after finishing an action
func _physics_process(_delta):
	# Process the queue
	var current_action = queue.current()

	if current_action:
		doing = true
		current_action.run()
	elif doing:
		doing = false
		emit_signal("player_finished")

func get_world():
	return get_world_2d()

# Internal Functions
func face_direction(direction):
	var my_pos = transform.origin
	var dir = transform.origin + direction
	
	if dir.x < my_pos.x:
		sprite.scale.x = -abs(sprite.scale.x)
	else:
		sprite.scale.x = abs(sprite.scale.x)

func interrupt():
	if queue.clear():
		play_animation("idle")

func play_animation(animation):
	animation_player.play(animation)

func say_now(text):
	talk_bubble.set_text(text)
	talk_bubble.visible = true

func quiet():
	talk_bubble.visible = false
	talk_bubble.set_text("")


# Functions to populate the queue in response to clicks in objects
func add_to_inventory(object):
	queue.append(STATES.AddToInventory.new(self, object))

func animate(animation):
	queue.append(STATES.Animate.new(self, animation))

func animate_until_finished(animation):
	queue.append(STATES.AnimateUntilFinished.new(self, animation))

func call_function_from(object, function, params=[]):
	if not params is Array:
		printerr("parameters should be an array")
		queue.append(STATES.State.new())
	else:
		queue.append(STATES.InteractWithObject.new(self, object, function, params))

func internal(fc, params):
	queue.append(STATES.CallFunction.new(self, fc, params))

func emit_message(signal_message):
	queue.append(STATES.Emit.new(self, signal_message))

func emit_finished_signal():
	queue.append(STATES.Finished.new(self))

func face_object(object):
	queue.append(STATES.FaceObject.new(self, object))

func remove_from_inventory(object):
	queue.append(STATES.RemoveFromInventory.new(self, object))

func say(text, how_long=2):
	queue.append(STATES.Say.new(self, text, how_long))

func wait_on_character(who:Character, message:String):
	queue.append(STATES.WaitOnCharacter.new(self, who, message))

func approach(object):
	assert(navigation != null, "You forgot to set the navigation of " + oname)
	
	if not object.interaction_position: return
	
	var end = navigation.get_closest_point(object.interaction_position)

	if (end - transform.origin).length() > MINIMUM_WALKABLE_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		var path = navigation.get_simple_path(begin, end, true)

		queue.append(STATES.Animate.new(self, "walk"))
		queue.append(STATES.WalkPath.new(self, path))
		queue.append(STATES.FaceObject.new(self, object))
		queue.append(STATES.Animate.new(self, "idle"))
	else:
		queue.append(STATES.State.new()) # queue nothing to keep signals working


# Default answers to actions
func receive_item(from, item):
	# Remove item
	from.animate_until_finished("raise_hand")
	from.remove_from_inventory(item)
	from.animate_until_finished("lower_hand")
	from.emit_message("gave_item")
	
	# Take item
	self.animate_until_finished("raise_hand")
	self.animate_until_finished("lower_hand")
	self.wait_on_character(from, "gave_item")
	self.add_to_inventory(from)

func talk_to(who):
	who.approach(self)
	who.emit_message("arrived")
	
	# Called when main_action is invoqued by the click
	self.wait_on_character(who, "arrived")
	self.face_object(who)
	self.say("Hi " + who.name)
