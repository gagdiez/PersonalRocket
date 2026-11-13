extends Node3D

# The house has two rooms, each with its own camera. Only the objects of the
# room we are in are interactive

func _ready():
	$Cole.face_direction(Vector3(-1, 0, 0))
	transition($Cole, $House/Living)

	# PAC.play_scene("res://scenes/House/cut_scenes/Intro.txt")


func transition(who, to):
	for room in [$House/Living, $"House/Room Left"]:
		for object in room.get_node("Interactive").get_children():
			object.interactive = room == to

	var camera = to.get_node("Camera")
	camera.current = true
	who.rotation_degrees.y = camera.rotation_degrees.y
