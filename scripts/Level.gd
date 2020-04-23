extends Spatial

onready var viewport = get_viewport()
onready var camera = viewport.get_camera()
onready var world = get_world()
onready var label = get_node("GUI/Cursor Label")

# This is a point and click game, sounds fair to have all the time
# in mind where is mouse, and which object is under it
var mouse_position
var obj_under_mouse 

# What we want to avoid when pointing, it is loaded in the ready function
var avoid

# For showing the label of objects under mouse
var mouse_offset = Vector2(8, 8)

# There should be a couple of actions: walk_to, read, look_at, take
const READ = 'read'
const WALK = 'walk_to'
const LOOK = 'look'
const TAKE = 'take'

const ACTIONS = [READ, WALK, LOOK, TAKE]
const properties_needed = {READ: "written_text", WALK: "position",
						   LOOK: "description", TAKE: "takeable"}
const action_label = {READ: "Read", WALK: "Walk to",
					  LOOK: "Look at", TAKE: "Take"}

var current_click_action = WALK

# For debugging
var DEBUG = false

func _ready():
	avoid = get_node('House/Walls').get_children()
	avoid.append($Cole)
	
func can_perform_current_action_on(obj):
	return obj and obj.get(properties_needed[current_click_action])

func get_object_under_mouse(mouse_pos):
	# Function to retrieve which object is under the mouse...
	var RAY_LENGTH = 100
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var selection = world.direct_space_state.intersect_ray(from, to, avoid)

	# If the ray hits something, then selection has a dictionary, with a
	# bunch of properties refering to the same object:

	#{position: Vector2 # point in world space for collision
	# normal: Vector2 # normal in world space for collision
	# collider: Object # Object collided or null (if unassociated)
	# collider_id: ObjectID # Object it collided against
	# rid: RID # RID it collided against
	# shape: int # shape index of collider
	# metadata: Variant()} # metadata of collider
	
	if not selection.empty():
		return selection['collider']
	else:
		return


func point():
	# On every single frame we check what's under the mouse
	# Right now we only show the name of the object (if any)
	# in the future we could change the cursor (to denote interaction)
	# or maybe display a menu... or something
	label.rect_position = mouse_position + mouse_offset
	label.text = action_label[current_click_action] + " "
	label.set("custom_colors/default_color", Color(1, 1, 1, 0))
	
	if obj_under_mouse:
		label.text += str(obj_under_mouse.name).to_lower()
		
		if can_perform_current_action_on(obj_under_mouse):
			label.set("custom_colors/default_color", Color(1, 1, 1, 1))
		else:
			label.set("custom_colors/default_color", Color(.6, .6, .6, .9))


func click():
	# Function called when something was clicked
	if can_perform_current_action_on(obj_under_mouse):
		# If the object has the properties needed for the
		# current action, then Cole performs it
		$Cole.call(current_click_action, obj_under_mouse)


func change_action(dir):
	var idx_current_action = ACTIONS.find(current_click_action)
	idx_current_action = (idx_current_action + dir) % ACTIONS.size()
	current_click_action = ACTIONS[idx_current_action]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mouse_position = viewport.get_mouse_position()
	obj_under_mouse = get_object_under_mouse(mouse_position)

	# Move Cole's bubble to above his head
	$Cole.talk_bubble.rect_position = camera.unproject_position($Cole.transform.origin + Vector3(-.6, 9.5, 0))

	if Input.is_action_just_released("ui_weel_up"):
		change_action(1)

	if Input.is_action_just_released("ui_weel_down"):
		change_action(-1)

	point()

	if Input.is_action_just_released("ui_click"):
		click()
