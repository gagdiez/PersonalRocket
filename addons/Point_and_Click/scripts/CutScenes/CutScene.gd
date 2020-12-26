extends Node
class_name CutScene

var SCENES = preload("Scenes.gd").new()

# A Cutscene is a stack of scenes to be played one by one
# When a cutscene is played the point and click will be disabled
var scene_actions = []
var current_action
var point_and_click

# We need to stack choices, since we could have choices within choices
# and we don't want to forget to return to them
var choices = []

# Functions

func _init(scene_file, str2obj, _point_and_click):
	# On init we define the P&C and parse the file
	point_and_click = _point_and_click
	
	var parser = Parser.new()
	scene_actions = parser.parse_file(scene_file, str2obj)

func play():
	# Playing a scene within the cutscene
	point_and_click.active = false
	
	# Disconnect finished scenes
	if current_action:
		current_action.disconnect("scene_finished", self, "scene_finished")
	
	# Check if there are new scenes, otherwise activate the P&C and go back
	if scene_actions.empty():
		point_and_click.active = true
		return
	
	# There are more scenes, so take the next one
	current_action = scene_actions.pop_front()

	# Handle choices
	if current_action is SCENES.Choice:
		choices.append(current_action)
		current_action.choice_handler = point_and_click.gui # TODO: change this
	elif current_action is SCENES.ChoiceReturn:
		current_action = choices[-1]
	elif current_action is SCENES.ChoiceFinish:
		choices.pop_back()
		return play()
	
	# Connect the scene to this cutscene, and wait for it to finish
	current_action.connect("scene_finished", self, "scene_finished")
	current_action.play()

func scene_finished(resulting_scenes):
	# When a scene finish it will return a (maybe empty) array of new scenes
	# This could happen i.e. because a choice was made, or an if executed
	# Append them to the stack and go keep going with the cutscene
	scene_actions = resulting_scenes + scene_actions
	play()
