extends Node

var choice_gui

onready var ACTIONS = load("res://scenes/Point_and_Click/scripts/Actions.gd").new()


class PlayerAction:
	var who
	var action
	var what
	signal scene_finished
	
	func _init(_who, _action, _what):
		who = _who
		action = _action
		what = _what
	
	func play():
		who.connect("player_finished", self, "finished")
		who.call(action.function, what)
	
	func finished():
		emit_signal("scene_finished")


class SetVariable:
	signal scene_finished
	var whom
	var what
	var value
	
	func _init(_whom, _what, _value):
		whom = _whom
		what = _what
		value = _value
	
	func play():
		if what in whom:
			whom.set(what, value)
			emit_signal("scene_finished")
		else:
			printerr("Variable non existent: ", whom.name, " ", what)
			push_error("Variable non existent: " + whom.name + " " + what)


class Option:
	var text
	var scene_actions = []
	var condition
	var end_conversation
	
	func _init(_text, actions, cond=null, _end_conversation=false):
		text = _text
		scene_actions = actions
		condition = cond
		end_conversation = _end_conversation
	

class Choice:
	var options = []
	var choice_handler
	var scene
	signal scene_finished
	
	func _init(opts, _scene, GUI):
		options = opts
		choice_handler = GUI
		scene = _scene
	
	func play():
		choice_handler.show_choice(scene, self)
		choice_handler.connect("choice_made", self, "finished")
	
	func finished():
		choice_handler.disconnect("choice_made", self, "finished")
		emit_signal("scene_finished")


var scene_actions = []
var current_action

func play():
	if current_action:
		current_action.disconnect("scene_finished", self, "play")
		
	if not scene_actions.empty():
		current_action = scene_actions.pop_front()
		current_action.connect("scene_finished", self, "play")
		current_action.play()
