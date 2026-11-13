extends PACInteractive

func _ready():
	id = "pan"

	main_action = PAC.actions.take
	thumbnail = preload("res://thumbnails/pan.png")
