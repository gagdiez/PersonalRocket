extends "Interactive.gd"

var level

func _ready():
	position = Vector3(-7, 0 , -13.89)

func arrived():
	level.transition_to("Room Left")

