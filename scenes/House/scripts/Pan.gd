extends 'Interactive.gd'

func _ready():
	main_action = ACTION.take
	position = self.transform.origin + Vector3(3, 0, 0)
	thumbnail = 'thumbnails/pan.png'
