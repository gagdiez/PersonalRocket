extends "Interactive.gd"

var level

func _ready():
	position = Vector3(-7, 0 , -13.89)
	actions = [ACTIONS.go_to]

func go_to():
	level.transition_to("Room Left")
