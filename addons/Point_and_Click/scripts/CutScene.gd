extends Node
class_name CutScene

# To be set before running init
var choice_gui

onready var SCENES = preload("Scenes.gd")
onready var PARSER = preload("Parser.gd").new()
onready var ACTIONS = preload("Actions.gd").new()

# A Cutscene is a list of actions to be played one by one
var scene_actions = []
var current_action
var str2obj
var scene_file

func init():
	var parser = PARSER.Parser.new(self, choice_gui, str2obj)
	scene_actions = parser.parse_file(scene_file)

func play():
	if current_action:
		current_action.disconnect("scene_finished", self, "play")
		
	if not scene_actions.empty():
		current_action = scene_actions.pop_front()
		current_action.connect("scene_finished", self, "play")
		current_action.play()
