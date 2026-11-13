extends PACInteractive

func _ready():
	id = "wardrobe"

	main_action = PAC.actions.open
	description = "My wardrobe, maybe I can find something useful there"


func open(who):
	who.approach(self)
	who.animate_until_finished(who.anim_raise_hand)
	self.run(slide_door)
	who.animate_until_finished(who.anim_lower_hand)


func slide_door():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:z", self.position.z - 2.69, 1.0)

	$CollisionShape3D.disabled = true
