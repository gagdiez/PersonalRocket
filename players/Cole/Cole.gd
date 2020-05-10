extends KinematicBody

# For debugging
var DEBUG = false
var navigation
var camera

# Get nodes from the scene
onready var FSM = load("res://scenes/Point_and_Click/scripts/FSM.gd").new()
onready var actions = load("res://scenes/Point_and_Click/scripts/actions.gd").new()
onready var talk_bubble = $"Talk Bubble"
onready var talk_bubble_timer = get_node("Talk Bubble/Timer")
onready var animation_player = $Animations

# Lets model our character as a set of actions. This will simplify the logic
onready var queue = FSM.Queue.new()

# Player variables
const SPEED = 5
const MINIMUM_DISTANCE = 0.5
var inventory


func _ready():
	talk_bubble_timer.connect("timeout", self, "quiet")


func animate(action, direction):
	$Animations.play(action)


func walk_to(object):
	
	var end = navigation.get_closest_point(object.position)
	print("Gotta go to", end)
	
	if (end - transform.origin).length() > MINIMUM_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		
		var path = navigation.get_simple_path(begin, end, true)

		queue.clear()
		queue.append(FSM.Animate.new(self, "walk"))
		queue.append(FSM.WalkPath.new(self, path))
		queue.append(FSM.Animate.new(self, "idle"))


func take(object):
	# First of all, walk to the object
	queue.clear()
	walk_to(object)
	queue.append(FSM.FaceObject.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(FSM.Take.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_down'))


func open(object):
	# First of all, walk to the object
	queue.clear()
	walk_to(object)
	queue.append(FSM.FaceObject.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(FSM.Open.new(self, object))
	queue.append(FSM.AnimateUntilFinished.new(self, 'take_down'))


func face_direction(direction):
	var my_pos = camera.unproject_position(transform.origin)
	var dir = camera.unproject_position(transform.origin + direction)
	
	if dir.x < my_pos.x:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1


func read(object):
	say(object.get(actions.read.property))


func examine(object):
	var direction = object.position - self.transform.origin
	face_direction(direction)
	say(object.get(actions.examine.property))


func quiet():
	talk_bubble.visible = false


func say(text):
	talk_bubble_timer.stop()
	talk_bubble.text = text
	talk_bubble.visible = true
	talk_bubble_timer.start()


func use(what, where):
	say("I don't know how to use the " + what.name.to_lower() +
		" with the " + where.name.to_lower())


func _physics_process(delta):
	var current_action = queue.current()

	if current_action:
		current_action.run()
