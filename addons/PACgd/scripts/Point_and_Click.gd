extends Node2D

# THIS IS THE POINT AND CLICK SYSTEM
# DO NOT WORRY ABOUT THIS

# But if you are curious on how the whole thing works, then go ahead and check
# the code! It's quite cool actually - Signed: The person who wrote the code
onready var ACTIONS = preload("Actions/Actions.gd").new()
onready var gui = $Dialog/Choices

# This is a point and click game, sounds fair to have all the time
# in mind where the mouse is, which object is under it, who is the
# main player and the current action (for combining actions)
var current_action:Action
var player:Character
var label:RichTextLabel
var mouse_position:Vector2
var obj_under_mouse: Object

# During the game there will be objects you want the P&C to avoid. For example,
# if you are in one room, you want the system to ignore objects in another room
var avoid:Array = []

# For cutscenes we need to be able to translate text into objects in the game
var str2obj: Dictionary

# Flag to be active
var active:bool = true

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)

# Functions

func init(_player:Character, _str2obj={}):
	# This function needs to be called by the user to set the player
	player = _player
	$Inventory.follow(player.inventory)
	
	str2obj = _str2obj

func click():
	# Function called when a left click is made
	if obj_under_mouse:
		if current_action.type == Action.TO_COMBINE:
			# Combine action with this object
			current_action.combine(obj_under_mouse)
		else:
			label.text = ""
			current_action.execute(player, obj_under_mouse)
			current_action.uncombine()
	else:
		player.interrupt()
		current_action.uncombine()

func get_object_under_mouse(mouse_pos:Vector2, RAY_LENGTH=50):
	# Function to retrieve which object is under the mouse
	
	# Create a ray from the camera pointing towards the mouse
	var from = player.camera.project_ray_origin(mouse_pos)
	var to = from + player.camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var ray = player.get_world().direct_space_state.intersect_ray(from, to, avoid)

	# If the ray hits something then the hitted object is at ray['collider']
	if ray and ray['collider'] is Interactive:
		if ray['collider'].interactive:
			avoid = []
			return ray['collider']
		else:
			avoid.append(ray['collider'])
			return get_object_under_mouse(mouse_pos)
	avoid = []
	return

func play_scene(scene_file, addition={}):
	# Function to play a cutscene
	var new_str2obj = str2obj.duplicate()
	
	for key in addition:
		new_str2obj[key] = addition[key]
	
	var cut_scene_player = CutScene.new(scene_file, new_str2obj, self)
	cut_scene_player.play()

func point():
	# On every single frame we check what's under the mouse
	label.rect_position = mouse_position + mouse_offset
	label.text = current_action.text
	
	if obj_under_mouse:
		if current_action.type != Action.COMBINED:
			current_action = obj_under_mouse.main_action
			label.text = current_action.text
		elif obj_under_mouse == current_action.combine_object:
			return
			
		label.text += " " + obj_under_mouse.oname
	else:
		if current_action.type != Action.COMBINED:
			current_action = ACTIONS.none

func _process(_delta):
	# On every frame
	if not active: return

	# Get mouse position
	mouse_position = player.get_viewport().get_mouse_position()
	
	# Check if there is an object under the mouse
	if $Inventory.position_contained(mouse_position):
		obj_under_mouse = $Inventory.get_object_in_position(mouse_position)
	else:
		obj_under_mouse = get_object_under_mouse(mouse_position)

	# Change label depending on what is under the mouse
	point()
	
	# Manage the click
	if Input.is_action_just_released("ui_main_click"):
		click()

	if Input.is_action_just_released("ui_secondary_click"):
		secondary_click()

func _ready():
	# On ready set the current action to none, and clear the label
	label = $"Cursor Label"
	label.set("custom_colors/default_color", Color(1, 1, 1, 1))
	label.text = ""

	current_action = ACTIONS.none

func secondary_click():
	# Function called when a right click is made
	if obj_under_mouse:
		obj_under_mouse.secondary_action.execute(player, obj_under_mouse)
	current_action.uncombine()
