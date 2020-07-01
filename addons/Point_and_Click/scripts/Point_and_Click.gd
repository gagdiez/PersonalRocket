extends Node2D

onready var parent = get_parent()
onready var ACTIONS = preload("Actions.gd").new()

# This is a point and click game, sounds fair to have all the time
# in mind where the mouse is, which object is under it, and the
# current action (for combining actions)
var current_action
var player
var label
var mouse_position
var obj_under_mouse

# Other variables related to the point and click
var world
var viewport
var camera
var avoid

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)


func init(_player:BasePlayer, _avoid:Array=[], cutscenes:Array=[]):
	world = parent.get_world()
	viewport = parent.get_viewport()
	camera = viewport.get_camera()
	
	avoid = _avoid
	player = _player
	
	var base_dir = self.get_script().get_path().get_base_dir()
	
	label = $"Cursor Label"
	label.set("custom_colors/default_color", Color(1, 1, 1, 1))
	
	current_action = ACTIONS.none
	player.inventory = $Inventory
	
	for cs in cutscenes:
		cs.choice_gui = $Dialog/Choices
		cs.init()


func get_object_under_mouse(mouse_pos:Vector2):
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
	label.text =  current_action.text
	
	if obj_under_mouse:
		if current_action.type != ACTIONS.COMBINED:
			current_action = obj_under_mouse.main_action
			label.text =  current_action.text

		label.text += " " + obj_under_mouse.oname
	else:
		if current_action.type != ACTIONS.COMBINED:
			current_action = ACTIONS.none


func click():
	# Function called when a left click is made
	if obj_under_mouse:
		if current_action.type == ACTIONS.TO_COMBINE:
			# Combine action with this object
			current_action.combine(obj_under_mouse)
		else:
			player.do_action_in_object(current_action,
											   obj_under_mouse)
			current_action.uncombine()
	else:
		current_action.uncombine()


func secondary_click():
	# Function called when a right click is made
	if obj_under_mouse:
		player.do_action_in_object(obj_under_mouse.secondary_action,
										   obj_under_mouse)
	current_action.uncombine()


func _process(_delta):
	viewport = parent.get_viewport()
	camera = viewport.get_camera()
	
	# Get mouse position
	mouse_position = viewport.get_mouse_position()
	
	# Check if there is an object under the mouse
	if player.inventory.position_contained(mouse_position):
		obj_under_mouse = player.inventory.get_object_in_position(mouse_position)
	else:
		obj_under_mouse = get_object_under_mouse(mouse_position)

	# Change label depending on what is under the mouse
	point()
	
	# Manage the click
	if Input.is_action_just_released("ui_main_click"):
		click()

	if Input.is_action_just_released("ui_secondary_click"):
		secondary_click()
