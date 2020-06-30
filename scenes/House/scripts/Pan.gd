extends Interactive

func _ready():
	main_action = ACTIONS.take
	position = self.transform.origin + Vector3(3, 0, 0)
	thumbnail = 'thumbnails/pan.png'
