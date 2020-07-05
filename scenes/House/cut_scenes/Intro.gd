extends CutScene

func init():
	var cole = get_node("../../Cole")
	var shadow_cole = get_node("../../Shadow Cole")
	var cup = get_node("../../House/Living/Interactive/Cup")
	var room = get_node("../../House/Living/Interactive/Room")
	var wardrobe = get_node("../../House/Room Left/Interactive/Wardrobe")
	var pan = get_node("../../House/Living/Interactive/Pan")
	str2obj = {"cole": cole, "shadow_cole": shadow_cole, "cup": cup,
			   "room": room, "wardrobe": wardrobe, "pan": pan}
	scene_file = "res://scenes/House/cut_scenes/Intro.txt"
	
	.init()
