extends Interactive

onready var tween = $Tween

func _ready():
	main_action = ACTIONS.open

	description = "My wardrobe, maybe I can find something useful there"

	interaction_position = self.transform.origin + Vector3(0, 0, 2)


func open(who):
	who.approach(self)
	who.face_object(self)
	who.animate_until_finished("raise_hand")
	who.call_function_from(self, "slide_door")
	who.animate_until_finished("lower_hand")


func slide_door():
	var end = Vector3(transform.origin.x, transform.origin.y, transform.origin.z-2.69)

	tween.interpolate_property(self, "translation", self.transform.origin, end,
							   1, tween.TRANS_CUBIC, tween.EASE_IN_OUT)
	tween.start()
	
	$CollisionShape.disabled = true
