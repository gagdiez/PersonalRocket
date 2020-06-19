extends "res://scenes/Point_and_Click/scripts/Interactive.gd"

func _ready():
	actions = [ACTIONS.walk_to]
	oname = ""

func walk_to(_who):
	return

func _input_event(_camera, _event, click_position, _click_normal, _shape_idx):
	if Input.is_action_just_released("ui_click"):
		position = click_position
