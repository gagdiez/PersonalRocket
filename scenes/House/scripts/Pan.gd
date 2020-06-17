extends "res://scenes/Point_and_Click/scripts/Interactive.gd"

func _ready():
	actions = [ACTIONS.take, ACTIONS.examine]
	position = self.transform.origin + Vector3(3, 0, 0)
	thumbnail = 'thumbnails/pan.png'
