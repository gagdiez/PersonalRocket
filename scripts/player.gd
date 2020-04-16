extends KinematicBody

# For debugging
var DEBUG = false

# Get nodes from the scene
onready var fsm_animation = $AnimationTree.get("parameters/playback")
onready var sprite = $cole_sprite
onready var navigation = $Navigation
onready var talk_bubble = $"Talk Bubble"

# Properties of our player
var current_velocity = Vector3(0, 0, 0) # so we know its current speed
var speed = 5

# Variables for pathfinding -> The path our player has to follow
var path_idx = 0
var path = []


func key_input_velocity():
	# Function to control Cole using the keyboard
	var direction = Vector3(0, 0, 0)
	var keyboard_input = false
	
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
		keyboard_input = true
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
		keyboard_input = true
	if Input.is_action_pressed("ui_down"):
		direction.z = 1
		keyboard_input = true
	if Input.is_action_pressed("ui_up"):
		direction.z = -1
		keyboard_input = true
	
	if keyboard_input:
		path = []
	
	# Modify current velocity
	current_velocity = direction.normalized() * speed


func animate_player():
	# If the player has velocity, then it should be walking
	if current_velocity.x > 0:
		sprite.scale.x = 1
	elif current_velocity.x < 0:
		sprite.scale.x = -1

	var movement = current_velocity.x != 0 or current_velocity.z != 0
	
	if movement:
		fsm_animation.travel("walk")
	else:
		fsm_animation.travel("idle")


func walk_to(object):
	# Walk to an object
	var destination = object.position

	var begin = navigation.get_closest_point(self.transform.origin)
	var end = navigation.get_closest_point(destination)
	
	path = navigation.get_simple_path(begin, end, true)
	path_idx = 0
	
	if DEBUG:
		$Draw.draw_path(path)


func look(object):
	talk_bubble.rect_position = Vector2(40, 40)
	talk_bubble.text = object.description


func path_input_velocity():
	# If you point and clicked, a path was created to be walked
	if path_idx < path.size():
		# There is still path to walk		
		var move_vec = (path[path_idx] - transform.origin)
		
		if move_vec.length() < 1:
			# too short to walk
			path_idx += 1

			if path_idx < path.size():
				move_vec = (path[path_idx] - transform.origin)

		current_velocity = move_vec.normalized() * speed


func _physics_process(delta):
	# Check if it's being controled with the keyboard
	key_input_velocity()
	
	# Check if a point and click created a path
	path_input_velocity()

	# Animate the player
	animate_player()
	
	# Move it
	move_and_slide(current_velocity)
