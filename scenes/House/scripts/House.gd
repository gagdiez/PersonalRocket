extends Spatial

var point_and_click
var all_interactive_objects
var cutscenes

func _ready():
	$Cole.navigation = $House/Navigation
	$Cole.camera = $House/Living/Camera
	$Cole.face_direction(Vector3(-1, 0, 0))

	$"Shadow Cole".camera = $House/Living/Camera
	$"Shadow Cole".navigation = $House/Navigation

	all_interactive_objects = $"House/Room Left/Interactive".get_children()
	all_interactive_objects += $"House/Living/Interactive".get_children()

	cutscenes = [$CutScenes/Intro]

	point_and_click = $"Point and Click"
	point_and_click.init($Cole, cutscenes)
	
	transition($Cole, $House/Living)

	$CutScenes/Intro.play()


func transition(who, to):
	# the objects from where we come are not interactive anymore
	var to_objects = to.get_node("Interactive").get_children()
	
	for obj in all_interactive_objects:
		if not obj in to_objects:
			obj.interactive = false
		else:
			obj.interactive = true
	
	var to_camera = to.get_node("Camera")
	to_camera.current = true
	
	who.camera = to_camera
	who.rotation_degrees.y = to_camera.rotation_degrees.y
	
	if to_camera.rotation_degrees.y != 0:
		who.talk_bubble_offset = Vector3(0, 9.5, -.9)
	else:
		who.talk_bubble_offset = Vector3(-.7, 9.5, 0)
