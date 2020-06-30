extends Interactive

func _ready():
	main_action = ACTIONS.use

func use(_who):
	$OmniLight.visible = not $OmniLight.visible
	$light_glow.visible = not $light_glow.visible
