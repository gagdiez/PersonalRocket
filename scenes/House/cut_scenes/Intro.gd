extends "res://scenes/Point_and_Click/scripts/CutScene.gd"

func init():
	var cole = get_node("../../Cole")
	var shadow_cole = get_node("../../Shadow Cole")
	var cup = get_node("../../House/Living/Interactive/Cup")

	str2obj = {"cole": cole, "shadow_cole": shadow_cole, "cup": cup}
	scene_file = "res://scenes/House/cut_scenes/Intro.txt"
	
	.init()
