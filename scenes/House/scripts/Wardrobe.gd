extends Interactive

onready var tween = $Tween

func _ready():
	main_action = ACTIONS.open

	description = "My wardrobe, maybe I can find something useful there"

	position = self.transform.origin + Vector3(0, 0, 2)


func open(who):
	who.walk_to(self)
	who.face_object(self)
	who.animate_until_finished("raise_hand")
	who.interact(self, "slide_door")
	who.animate_until_finished("lower_hand")


func slide_door(who):
	var end = Vector3(transform.origin.x, transform.origin.y, -23.824)

	tween.interpolate_property(self, "translation", self.transform.origin, end,
							   1, tween.TRANS_CUBIC, tween.EASE_IN_OUT)
	tween.start()
	
	$CollisionShape.disabled = true
