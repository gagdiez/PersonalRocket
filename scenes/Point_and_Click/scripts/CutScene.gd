extends Node

onready var queue = load("res://scenes/Point_and_Click/scripts/Queue.gd").Queue.new()
onready var STATES = load("res://scenes/Point_and_Click/scripts/States.gd")
onready var ACTIONS = load("res://scenes/Point_and_Click/scripts/Actions.gd").new()

class PlayerAction:
	var who
	var action
	var what
	
	func _init(_who, _action, _what):
		who = _who
		action = _action
		what = _what

var scene_actions = []
var current_scene

func play():
	if current_scene:
		current_scene.who.disconnect("action_finished", self, "play")

	if not scene_actions.empty():
		current_scene = scene_actions.pop_front()
		current_scene.who.connect("action_finished", self, "play")
		current_scene.who.call(current_scene.action.function, current_scene.what)
