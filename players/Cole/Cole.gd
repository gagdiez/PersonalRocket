extends Spatial

# The player knows where the camera is, and where they can walk
var navigation
var camera

# Get nodes from the scene
onready var FSM = load("res://scenes/Point_and_Click/scripts/FSM.gd").new()
onready var ACTIONS = load("res://scenes/Point_and_Click/scripts/actions.gd").new()
onready var animation_player = $Animations

# Lets model our character as a set of queue of actions
onready var queue = FSM.Queue.new()

# Player variables
const SPEED = 5
const MINIMUM_DISTANCE = 0.5
var inventory
var talking = false
var talk_bubble
var talk_bubble_timer

func _ready():
	talk_bubble = $"Talk Bubble"
	talk_bubble_timer = get_node("Talk Bubble/Timer")
	talk_bubble_timer.connect("timeout", self, "quiet")
	talk_bubble.visible = true


func animate(animation):
	$Animations.play(animation)


func walk_to(object):
	var end = navigation.get_closest_point(object.position)

	if (end - transform.origin).length() > MINIMUM_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		
		var path = navigation.get_simple_path(begin, end, true)

		queue.clear()
		queue.append(FSM.Animate.new(self, "walk"))
		queue.append(FSM.WalkPath.new(self, path))
		queue.append(FSM.Animate.new(self, "idle"))


func go_to(object):
	# Transition between areas, walk to the point we need, and inform the obj
	walk_to(object)
	queue.append(FSM.PerformActionOnObject.new(self, ACTIONS.go_to, object))


func get_close_and_perform_action(action, object):
	# First of all, walk to the object
	walk_to(object)
	queue.append(FSM.FaceObject.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(FSM.PerformActionOnObject.new(self, action, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_down'))


func open(object):
	get_close_and_perform_action(ACTIONS.open, object)


func use(object):
	get_close_and_perform_action(ACTIONS.use, object)


func take(object):
	walk_to(object)
	queue.append(FSM.FaceObject.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(FSM.PerformActionOnObject.new(self, ACTIONS.take, object))
	queue.append(FSM.AddToInventory.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_down'))


func face_direction(direction):
	var my_pos = camera.unproject_position(transform.origin)
	var dir = camera.unproject_position(transform.origin + direction)
	
	if dir.x < my_pos.x:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1


func face_object_and_do(action, object):
	if object.get("position"):
		var direction = object.position - self.transform.origin
		face_direction(direction)
	say(object.call(action.function, self))


func examine(object):
	face_object_and_do(ACTIONS.examine, object)
	
func read(object):
	face_object_and_do(ACTIONS.read, object)

func quiet():
	talk_bubble.visible = false


func say(text):
	talk_bubble_timer.stop()
	talk_bubble.text = text
	talk_bubble.visible = true
	talk_bubble_timer.start()
	

func use_item(what, where):
	say("I don't know how to use the " + what.oname +
		" with the " + where.oname)


func _physics_process(delta):
	# Move Cole's bubble to above his head
	talk_bubble.rect_position = camera.unproject_position(
			transform.origin + Vector3(-.6, 9.5, 0)
	)
	
	var current_action = queue.current()

	if current_action:
		current_action.run()
