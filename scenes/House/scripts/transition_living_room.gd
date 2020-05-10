extends "Interactive.gd"

var level

func _ready():
	position = Vector3(-4.157, 0 , -14.09)
	actions = [ACTIONS.go_to]

func go_to():
	level.transition_to("Living")
