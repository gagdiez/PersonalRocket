extends "res://scenes/Point_and_Click/scripts/Interactive.gd"

func _ready():
	actions = [ACTIONS.use]

func use(_who):
	$OmniLight.visible = not $OmniLight.visible
	$light_glow.visible = not $light_glow.visible
