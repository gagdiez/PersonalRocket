extends Interactive
class_name BasePlayer

# A player is basically a queue of actions that is constantly running
const STATES = preload("States.gd")
onready var queue = preload("Queue.gd").Queue.new()

# The player knows where the camera is, where they can walk, and their inventory
var camera
var inventory
var navigation
var current_action

signal player_finished

func _ready():
	main_action = ACTIONS.talk_to

func do_action_in_object(action, object):
	# Function called by the point and click system when we click on an object
	if not action.function:
		return

	match action.type:
		ACTIONS.IMMEDIATE:
			self.call(action.function, object)
		ACTIONS.COMBINED:
			self.call(action.function, action.object, object)

func action_finished():
	emit_signal("player_finished")

func process_queue():
	# Process the queue
	current_action = queue.current()

	if current_action:
		current_action.run()
