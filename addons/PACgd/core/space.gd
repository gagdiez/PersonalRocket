## Everything PACgd does differently in 2D and 3D lives here: the rest of the
## framework talks to one of these two adapters and never checks dimensions.

static func for_node(node: Node):
	if node is Node3D:
		return Space3D.new()
	return Space2D.new()


class Space3D:
	func navigation_ready(agent: NavigationAgent3D) -> bool:
		return NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) > 0

	func closest_navigation_point(agent: NavigationAgent3D, point: Vector3) -> Vector3:
		var closest = NavigationServer3D.map_get_closest_point(agent.get_navigation_map(), point)
		# The navmesh floats a bit above the real floor, path_height_offset tells
		# how much, so we take it out to keep the character's feet on the floor
		closest.y -= agent.path_height_offset
		return closest

	func face(sprite: Node3D, body: Node3D, direction: Vector3) -> void:
		# Face left/right depending on how the movement looks from the camera
		var camera = body.get_viewport().get_camera_3d()
		var here = camera.unproject_position(body.global_position)
		var there = camera.unproject_position(body.global_position + direction)
		sprite.scale.x = -abs(sprite.scale.x) if there.x < here.x else abs(sprite.scale.x)

	func screen_position(node: Node3D, offset: Vector3) -> Vector2:
		return node.get_viewport().get_camera_3d().unproject_position(node.global_position + offset)

	func pick(viewport: Viewport, agent: NavigationAgent3D, mouse: Vector2, ray_length: float) -> Dictionary:
		# Cast a ray from the camera through the mouse
		var camera = viewport.get_camera_3d()
		assert(camera != null, "There is no active Camera3D in the scene")
		var from = camera.project_ray_origin(mouse)
		var to = from + camera.project_ray_normal(mouse) * ray_length
		var space_state = viewport.find_world_3d().direct_space_state

		var exclude: Array[RID] = []
		while true:
			var query = PhysicsRayQueryParameters3D.create(from, to, 0xFFFFFFFF, exclude)
			query.collide_with_areas = true
			var hit = space_state.intersect_ray(query)
			if hit.is_empty():
				return {}  # nothing under the mouse (the sky)
			var object = hit.collider
			if object is PACInteractive and object.interactive:
				return {"object": object}
			if object is PACInteractive or object is Area3D:
				exclude.append(hit.rid)  # the mouse sees through them
				continue
			# Something solid stops the ray: if it is the floor, the navmesh is
			# right above the hit (baked navmeshes lie on, or slightly above, the
			# ground). Walls and furniture are kept out of the navmesh, so they
			# find nothing above them
			if agent == null or not navigation_ready(agent):
				return {}
			var above = hit.position + Vector3.UP * agent.height
			var point = NavigationServer3D.map_get_closest_point_to_segment(agent.get_navigation_map(), hit.position, above)
			if Geometry3D.get_closest_point_to_segment(point, hit.position, above).distance_to(point) < 0.01:
				return {"point": point}
			return {}
		return {}


class Space2D:
	func navigation_ready(agent: NavigationAgent2D) -> bool:
		return NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) > 0

	func closest_navigation_point(agent: NavigationAgent2D, point: Vector2) -> Vector2:
		return NavigationServer2D.map_get_closest_point(agent.get_navigation_map(), point)

	func face(sprite: Node2D, _body: Node2D, direction: Vector2) -> void:
		sprite.scale.x = -abs(sprite.scale.x) if direction.x < 0 else abs(sprite.scale.x)

	func screen_position(node: Node2D, offset: Vector3) -> Vector2:
		return node.get_global_transform_with_canvas() * Vector2(offset.x, offset.y)

	func pick(viewport: Viewport, agent: NavigationAgent2D, mouse: Vector2, _ray_length: float) -> Dictionary:
		# Translate the mouse into world coordinates (cameras move the canvas)
		var point = viewport.get_canvas_transform().affine_inverse() * mouse
		var query = PhysicsPointQueryParameters2D.new()
		query.position = point
		query.collide_with_areas = true

		# The interactive object drawn on top (highest z_index)
		var best = null
		for hit in viewport.find_world_2d().direct_space_state.intersect_point(query, 32):
			var object = hit.collider
			if object is PACInteractive and object.interactive:
				if best == null or object.z_index > best.z_index:
					best = object
		if best:
			return {"object": best}

		# Is the mouse on the navmesh?
		if agent == null or not navigation_ready(agent):
			return {}
		var closest = NavigationServer2D.map_get_closest_point(agent.get_navigation_map(), point)
		if closest.distance_to(point) < 0.5:
			return {"point": closest}
		return {}
