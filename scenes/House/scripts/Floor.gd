extends Interactive

func _ready():
	main_action = ACTIONS.walk_to
	secondary_action = ACTIONS.none
	oname = ""
	description = ""

func walk_to(_who):
	return

func _input_event(_camera, _event, click_position, _click_normal, _shape_idx):
	if Input.is_action_just_released("ui_main_click"):
		position = click_position
