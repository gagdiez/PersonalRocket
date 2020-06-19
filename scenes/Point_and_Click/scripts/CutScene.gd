extends Node

onready var SCENES = load("res://scenes/Point_and_Click/scripts/SCENES.gd")
onready var ACTIONS = load("res://scenes/Point_and_Click/scripts/Actions.gd").new()

class PlayerAction:
	var who
	var action
	var what
	signal action_finished
	
	func _init(_who, _action, _what):
		who = _who
		action = _action
		what = _what
	
	func play():
		who.connect("action_finished", self, "finished")
		who.call(action.function, what)
	
	func finished():
		emit_signal("action_finished")

var scene_actions = []

func play():
	if not scene_actions.empty():
		var current_action = scene_actions.pop_front()
		current_action.connect("action_finished", self, "play")
		current_action.play()
