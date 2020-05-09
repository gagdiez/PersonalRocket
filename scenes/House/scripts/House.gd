extends Spatial

func _ready():
	var viewport = get_viewport()
	var world = get_world()
	var point_and_click = $"Point and Click"

	$Cole.navigation = $"House/Navigation"

	var avoid = [$Cole]
	
	point_and_click.init(world, viewport, avoid, [$Cole])
