extends 'Interactive.gd'

func _ready():
	actions = [ACTIONS.walk_to]
	oname = ""

func walk_to(who):
	return

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if Input.is_action_just_released("ui_click"):
		position = click_position
