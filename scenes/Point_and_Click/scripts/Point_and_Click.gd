extends Node

# This is a point and click game, sounds fair to have all the time
# in mind where is mouse, which object is under it, which action is currently
# selected, and  who's inventory is on screen (for multiplayer)
var mouse_position
var obj_under_mouse
var current_player
var current_inventory
var current_click_action
var label

# The actions available in the level
var ACTIONS
var actions_to_functions = {} # So far we translated actions to functions using
							  # action.name, but this could change in the future

# What we want to avoid when pointing, it is loaded in the ready function
var avoid

# Other variables related to the point and click
var world
var camera
var players
var viewport
var actions

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)

# For debugging
var DEBUG = false


func init(_world, _viewport, _avoid, _players):
	avoid = _avoid
	viewport = _viewport
	camera = viewport.get_camera()
	current_player = _players[0]
	world = _world
	
	var base_dir = self.get_script().get_path().get_base_dir()
	actions = load(base_dir + "/actions.gd").new()
	label = get_node("GUI/Cursor Label")

	ACTIONS = [actions.read, actions.walk, actions.examine,
			   actions.take, actions.use, actions.open]

	current_click_action = actions.walk
	
	current_player.inventory = $GUI/Inventory
	current_player.camera = camera
	
	current_inventory = current_player.inventory


func can_perform_current_action_on(obj):
	var obj_and_combined = obj and current_click_action.type == actions.COMBINED
	var obj_and_possible = obj and obj.get(current_click_action.property)
	return obj_and_combined or obj_and_possible


func get_object_under_mouse(mouse_pos):
	# Function to retrieve which object is under the mouse...
	var RAY_LENGTH = 50
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var selection = world.direct_space_state.intersect_ray(from, to, avoid)

	# If the ray hits something, the hitted object is at selection['collider']
	if not selection.empty():
		return selection['collider']
	else:
		return


func point():
	# On every single frame we check what's under the mouse
	label.rect_position = mouse_position + mouse_offset
	label.text = current_click_action.text + " "
	label.set("custom_colors/default_color", Color(.6, .6, .6, .9))
	
	if obj_under_mouse:
		label.text += str(obj_under_mouse.name).to_lower() + " "
	
		if can_perform_current_action_on(obj_under_mouse):
			label.set("custom_colors/default_color", Color(1, 1, 1, 1))


func click():
	# Function called when a click is made
	if can_perform_current_action_on(obj_under_mouse):
		match current_click_action.type:
			actions.IMMEDIATE:
				# Immediate action in an object that has the needed properties
				current_player.call(current_click_action.name, obj_under_mouse)
			actions.TO_COMBINE:
				# Combine action with this object
				current_click_action.combine(obj_under_mouse)
			actions.COMBINED:
				# Action that carries an object
				current_player.call(current_click_action.name,
									current_click_action.object,
									obj_under_mouse)
				current_click_action.uncombine()
	else:
		current_click_action.uncombine()


func change_action(dir):
	current_click_action.uncombine()
	var idx_current_action = ACTIONS.find(current_click_action)
	idx_current_action = (idx_current_action + dir) % ACTIONS.size()
	current_click_action = ACTIONS[idx_current_action]


func change_to_camera(_camera):
	_camera.current = true
	camera = viewport.get_camera()
	current_player.camera = camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move Cole's bubble to above his head
	current_player.talk_bubble.rect_position = camera.unproject_position(
		current_player.transform.origin + Vector3(-.6, 9.5, 0)
		)
	
	mouse_position = viewport.get_mouse_position()
	
	if current_inventory.position_contained(mouse_position):
		obj_under_mouse = current_inventory.get_object_in_position(mouse_position)
	else:
		obj_under_mouse = get_object_under_mouse(mouse_position)

	if Input.is_action_just_released("ui_weel_up"):
		change_action(1)

	if Input.is_action_just_released("ui_weel_down"):
		change_action(-1)

	point()

	if Input.is_action_just_released("ui_click"):
		click()
