extends KinematicBody

# For debugging
var DEBUG = false

# Get nodes from the scene
onready var FSM = load("res://scripts/FSM.gd")
onready var navigation = $Navigation
onready var talk_bubble = $"Talk Bubble"
onready var talk_bubble_timer = get_node("Talk Bubble/Timer")

# Lets model our character as a set of actions. This will simplify the logic
# a lot. In this way, if the character is 
onready var queue = FSM.Queue.new()

# Player variables
const SPEED = 5
const MINIMUM_DISTANCE = 0.5
var inventory


func _ready():
	talk_bubble_timer.connect("timeout", self, "quiet")


func animate(action, direction):
	if direction:
		if direction.x < 0:
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1

	$Animations.play(action)


func walk_to(object):
	# Add to the queue that we want to walk
	queue.clear()
	queue.append(FSM.Walk.new(self, object, navigation))


func take(object):
	# First of all, walk to the object
	queue.clear()
	queue.append(FSM.Walk.new(self, object, navigation))
	queue.append(FSM.FaceObject.new(self, object))
	queue.append(FSM.PlayAnimation.new(self, $Animations, 'take_raise'))
	queue.append(FSM.Take.new(self, object))
	queue.append(FSM.PlayAnimation.new(self, $Animations, 'take_down'))


func face_object(object):
	if object.transform.origin.x < transform.origin.x:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1


func look(object):
	say(object.description)


func quiet():
	talk_bubble.visible = false


func say(text):
	talk_bubble_timer.stop()
	talk_bubble.text = text
	talk_bubble.visible = true
	talk_bubble_timer.start()


func _physics_process(delta):
	var current_action = queue.current()

	if current_action:
		current_action.run()
