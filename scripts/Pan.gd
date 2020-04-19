extends 'Interactive.gd'

func _ready():
	takeable = true
	position = self.transform.origin + Vector3(3, 0, 0)
