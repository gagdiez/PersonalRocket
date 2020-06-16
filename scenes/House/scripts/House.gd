extends Spatial

var point_and_click
var all_interactive_objects

func _ready():
	point_and_click = $"Point and Click"

	$Cole.navigation = $House/Navigation
	$Cole.camera = $House/Living/Camera
	
	point_and_click.init(get_world(), get_viewport(), [$Cole], [$Cole])
	
	all_interactive_objects = $"House/Room Left/Interactive".get_children()
	all_interactive_objects += $"House/Living/Interactive".get_children()

	transition($Cole, $House/Living)


func transition(who, to):
	# the objects from where we come are not interactive anymore
	var avoid = []
	
	var to_objects = to.get_node("Interactive").get_children()
	
	for obj in all_interactive_objects:
		if not obj in to_objects:
			avoid.append(obj)
	
	print(avoid)
	
	var to_camera = to.get_node("Camera")
	to_camera.current = true
	
	point_and_click.camera = to_camera
	point_and_click.avoid = avoid
	
	who.camera = to_camera
	who.rotation_degrees.y = to_camera.rotation_degrees.y
	
	
	
