extends Node

# This is a point and click game, sounds fair to have all the time
# in mind where is mouse, which object is under it, which action is currently
# selected, and  who's inventory is on screen (for multiplayer)
var actions
var current_main_action
var current_secondary_action
var current_inventory
var current_player
var label
var mouse_position
var obj_under_mouse

# What we want to avoid when pointing, it is loaded in the ready function
var avoid

# Other variables related to the point and click
var world
var camera
var players
var viewport
var ACTIONS

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)


func init(_world, _viewport, _avoid, _players):
	avoid = _avoid
	viewport = _viewport
	camera = viewport.get_camera()
	current_player = _players[0]
	world = _world
	
	var base_dir = self.get_script().get_path().get_base_dir()
	ACTIONS = load(base_dir + "/actions.gd").new()
	label = get_node("GUI/Cursor Label")
	
	current_player.inventory = $GUI/Inventory
	current_player.camera = camera
	
	current_inventory = current_player.inventory


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
	label.set("custom_colors/default_color", Color(1, 1, 1, 1))
	label.text = " "
	
	if obj_under_mouse:
		# Set the label visible in the right position
		label.rect_position = mouse_position + mouse_offset
		label.set("custom_colors/default_color", Color(1, 1, 1, 1))
		
		var has_main = obj_under_mouse.get("main_action")
		var has_scnd = obj_under_mouse.get("secondary_action")
		
		# Make the text for both actions
		if has_main:
			current_main_action = obj_under_mouse.main_action
			label.text += obj_under_mouse.main_action.text
			label.text += " " + obj_under_mouse.name.to_lower()

		label.text += " or " if has_main and has_scnd else " "
			
		if has_scnd:
			current_secondary_action = obj_under_mouse.secondary_action
			label.text += obj_under_mouse.secondary_action.text
			label.text += " " + obj_under_mouse.name.to_lower()


func main_click():
	# Function called when the main action is called
	if not obj_under_mouse:
		current_main_action.uncombine()
		return
	
	# If there is an object
	match current_main_action.type:
		ACTIONS.IMMEDIATE:
			# Immediate action in an object that has the needed properties
			current_player.call(current_main_action.function, obj_under_mouse)
		ACTIONS.TO_COMBINE:
			# Combine action with this object
			current_main_action.combine(obj_under_mouse)
		ACTIONS.COMBINED:
			# Action that carries an object
			current_player.call(current_main_action.function,
								current_main_action.object,
								obj_under_mouse)
			current_main_action.uncombine()


func secondary_click():
	current_main_action.uncombine()
	current_player.call(current_secondary_action.function, obj_under_mouse)


func change_to_camera(_camera):
	_camera.current = true
	camera = viewport.get_camera()
	current_player.camera = camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	mouse_position = viewport.get_mouse_position()
	
	if current_inventory.position_contained(mouse_position):
		obj_under_mouse = current_inventory.get_object_in_position(mouse_position)
	else:
		obj_under_mouse = get_object_under_mouse(mouse_position)

	point()

	if Input.is_action_just_released("ui_main_click"):
		main_click()

	if Input.is_action_just_released("ui_scnd_click"):
		secondary_click()

	
