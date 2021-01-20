extends Interactive

func _ready():
	main_action = ACTIONS.use

func use(who):
	who.approach(self)
	who.face_object(self)
	who.animate_until_finished("raise_hand")
	who.call_function_from(self, "switch")
	who.animate_until_finished("lower_hand")

func switch():
	$OmniLight.visible = not $OmniLight.visible
	$light_glow.visible = not $light_glow.visible
