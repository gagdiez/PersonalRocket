extends PACInteractive

# There is one in each room: their ids are set in the Inspector

func _ready():
	main_action = PAC.actions.use


func use(who):
	who.approach(self)
	who.animate_until_finished(who.anim_raise_hand)
	self.run(switch)
	who.animate_until_finished(who.anim_lower_hand)


func switch():
	$OmniLight3D.visible = not $OmniLight3D.visible
	$light_glow.visible = not $light_glow.visible
