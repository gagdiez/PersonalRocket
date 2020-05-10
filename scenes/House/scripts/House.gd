extends Spatial

var point_and_click

func _ready():
	var viewport = get_viewport()
	var world = get_world()
	point_and_click = $"Point and Click"

	$Cole.navigation = $"House/Navigation"

	var avoid = [$Cole]
	
	point_and_click.init(world, viewport, avoid, [$Cole])

	for transitions in $Transitions.get_children():
		transitions.level = self
		

func transition_to(place):
	var camera
	match place:
		"Living":
			camera = get_node("House/Living/Camera")
			point_and_click.current_player.rotation_degrees.y = 0
			$"Transitions/Living Room/CollisionShape".disabled = true
			$"Transitions/Room/CollisionShape".disabled = false
		"Room Left":
			camera = get_node("House/Room Left/Camera")
			point_and_click.current_player.rotation_degrees.y = -90
			$"Transitions/Living Room/CollisionShape".disabled = false
			$"Transitions/Room/CollisionShape".disabled = true
	point_and_click.change_to_camera(camera)
