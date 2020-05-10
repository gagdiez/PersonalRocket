extends "Interactive.gd"

var level

func _ready():
	position = Vector3(-4.157, 0 , -14.09)

func arrived():
	level.transition_to("Living")
	$CollisionShape.disabled = true
