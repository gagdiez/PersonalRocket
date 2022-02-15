extends Interactive2D
class_name Floor2D

func _ready():
	main_action = ACTIONS.walk_to
	secondary_action = ACTIONS.none
	oname = ""
	description = ""
	self.z_index = -1

func _input(event):
	if Input.is_action_just_released("ui_main_click"):
		interaction_position = get_viewport().get_mouse_position()

func use_item(_a, _b):
	pass
