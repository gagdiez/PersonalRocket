extends Interactive
class_name Player

# A player is basically a queue of actions that is constantly running
const STATES = preload("States.gd")
onready var queue = preload("Queue.gd").Queue.new()

# They know where the camera is, where they can walk, and their inventory
var camera
var inventory
var navigation

# Their NODE has an animation player, a sprite, and a talk bubble
var animation_player
var talk_bubble
var talk_bubble_timer
var talk_bubble_offset
var sprite

# They have a speed, and they don't move if the destination is close
var SPEED = 5
var MINIMUM_WALKABLE_DISTANCE = 0.5

# They can signal after finising actions
signal player_finished


# Godot functions
func _ready():
	main_action = ACTIONS.talk_to
	inventory = Inventory.new()

func _physics_process(_delta):
	# Move player's bubble above they head
	talk_bubble.rect_position = camera.unproject_position(
			transform.origin + talk_bubble_offset
	)

	# Process the queue
	var current_action = queue.current()

	if current_action:
		current_action.run()


# Function called by the point and click system when we click on an object
func do_action_on_object(action:Action, what):
	if not action.function:
		return

	self.interrupt()

	match action.type:
		Action.IMMEDIATE:
			self.call(action.function, what)
		Action.INTERACTIVE:
			what.call(action.function, self)
		Action.COMBINED:
			what.call(action.function, self, action.object)

# Functions to modify the graphics
func face_direction(direction):
	var my_pos = camera.unproject_position(transform.origin)
	var dir = camera.unproject_position(transform.origin + direction)
	
	if dir.x < my_pos.x:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1

func play_animation(animation):
	animation_player.play(animation)


# Functions to populate the queue in response to clicks in objects
func action_finished():
	emit_signal("player_finished")

func add_to_inventory(object):
	queue.append(STATES.AddToInventory.new(self, object))

func animate(animation):
	queue.append(STATES.Animate.new(self, animation))

func animate_until_finished(animation):
	queue.append(STATES.AnimateUntilFinished.new(self, animation))

func emit_finished_signal():
	queue.append(STATES.Finished.new(self))

func face_object(object):
	queue.append(STATES.FaceObject.new(self, object))

func interrupt():
	queue.clear()
	play_animation("idle")

func interact(object, function):
	queue.append(STATES.InteractWithObject.new(self, function, object))

func remove_from_inventory(object):
	queue.append(STATES.RemoveFromInventory.new(self, object))

func say(text):
	queue.append(STATES.Say.new(self, text, talk_bubble, talk_bubble_timer))

func talk_to(someone):
	return

func walk_to(object):
	var end = navigation.get_closest_point(object.position)

	if (end - transform.origin).length() > MINIMUM_WALKABLE_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		var path = navigation.get_simple_path(begin, end, true)

		queue.append(STATES.Animate.new(self, "walk"))
		queue.append(STATES.WalkPath.new(self, path))
		queue.append(STATES.Animate.new(self, "idle"))
