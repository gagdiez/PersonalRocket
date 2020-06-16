extends 'Interactive.gd'

onready var tween = $Tween

func _ready():
	actions = [ACTIONS.open, ACTIONS.examine]

	description = "My wardrobe, maybe I can find something useful there"

	position = self.transform.origin + Vector3(0, 0, 2)


func open(who):
	var end = Vector3(transform.origin.x, transform.origin.y, -23.824)

	tween.interpolate_property(self, "translation", self.transform.origin, end,
							   1, tween.TRANS_CUBIC, tween.EASE_IN_OUT)
	tween.start()
	
	$CollisionShape.disabled = true
