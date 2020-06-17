extends "Transition.gd"

func _ready():
	position = Vector3(-4.157, 0 , -14.09)
	
	level = get_node("../../../..")
	to = get_node("../../../Living")
