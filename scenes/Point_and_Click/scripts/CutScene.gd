extends Node

onready var queue = load("res://scenes/Point_and_Click/scripts/Queue.gd").Queue.new()
onready var STATES = load("res://scenes/Point_and_Click/scripts/States.gd")
onready var ACTIONS = load("res://scenes/Point_and_Click/scripts/Actions.gd").new()

class PlayerAction:
	
	var first_run = true
	var finished
	var blocked
	var who
	var action
	var what
	
	func _init(_who, _action, _what):
		who = _who
		action = _action
		what = _what
		finished = false
		blocked = false
	
	func run():
		if first_run:
			who.call(action.function, what)
			first_run = false
		
		if who.queue.empty():
			finished = true


var events

func start():
	for e in events:
		queue.append(e)
	print(queue)
	
func _physics_process(_delta):
	# Process the queue
	var current_action = queue.current()

	if current_action:
		current_action.run()
