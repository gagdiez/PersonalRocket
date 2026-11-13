@tool
extends EditorPlugin
## Registers the PAC autoload: the point and click system that every
## PACInteractive and PACCharacter talk to.

const AUTOLOAD_NAME = "PAC"
const AUTOLOAD_PATH = "res://addons/PACgd/core/pac.gd"
const HUD_SETTING = "pac/hud_scene"


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

	# Lets users swap the HUD for their own scene
	if not ProjectSettings.has_setting(HUD_SETTING):
		ProjectSettings.set_setting(HUD_SETTING, "res://addons/PACgd/ui/hud.tscn")
	ProjectSettings.set_initial_value(HUD_SETTING, "res://addons/PACgd/ui/hud.tscn")
	ProjectSettings.add_property_info({
		"name": HUD_SETTING, "type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE, "hint_string": "*.tscn",
	})
	ProjectSettings.save()


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
