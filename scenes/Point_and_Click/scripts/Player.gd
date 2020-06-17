extends "res://scenes/Point_and_Click/scripts/Interactive.gd"

# A player is basically a queue of actions that is constantly running
onready var STATES = load("res://scenes/Point_and_Click/scripts/States.gd")
onready var queue = load("res://scenes/Point_and_Click/scripts/Queue.gd").Queue.new()

# The player knows where the camera is, where they can walk, and their inventory
var camera
var inventory
var navigation
var current_action

func _ready():
	actions = [ACTIONS.talk]

func do_action_in_object(action, object):
	# Function called by the point and click system when we click on an object
	match action.type:
		ACTIONS.IMMEDIATE:
			self.call(action.function, object)
		ACTIONS.COMBINED:
			self.call(action.function, action.object, object)


func process_queue():
	# Process the queue
	current_action = queue.current()

	if current_action:
		current_action.run()
