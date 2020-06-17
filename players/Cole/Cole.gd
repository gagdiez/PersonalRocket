extends "res://scenes/Point_and_Click/scripts/Player.gd"

# Player variables
const SPEED = 5
const MINIMUM_DISTANCE = 0.5
var talking = false
var talk_bubble
var talk_bubble_timer
var talk_bubble_offset = Vector3(-.6, 9.5, 0)

var animation_player

func _ready():
	animation_player = $Animations

	talk_bubble = $"Talk Bubble"
	talk_bubble_timer = get_node("Talk Bubble/Timer")
	talk_bubble_timer.connect("timeout", self, "quiet")
	talk_bubble.visible = false

func _physics_process(_delta):
	# Move Cole's bubble to above his head
	talk_bubble.rect_position = camera.unproject_position(
			transform.origin + talk_bubble_offset
	)
	
	# Process the queue
	self.process_queue()


# Functions to create elements of the QUEUE
func animate(animation):
	$Animations.play(animation)


func walk_to(object):
	var end = navigation.get_closest_point(object.position)

	if (end - transform.origin).length() > MINIMUM_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		
		var path = navigation.get_simple_path(begin, end, true)

		queue.clear()
		queue.append(STATES.Animate.new(self, "walk"))
		queue.append(STATES.WalkPath.new(self, path))
		queue.append(STATES.Animate.new(self, "idle"))


func go_to(object):
	# Transition between areas, walk to the point we need, and inform the obj
	walk_to(object)
	queue.append(STATES.PerformActionOnObject.new(self, ACTIONS.go_to, object))


func get_close_and_perform_action(action, object):
	# First of all, walk to the object
	walk_to(object)
	queue.append(STATES.FaceObject.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(STATES.PerformActionOnObject.new(self, action, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_down'))


func open(object):
	get_close_and_perform_action(ACTIONS.open, object)


func use(object):
	get_close_and_perform_action(ACTIONS.use, object)


func take(object):
	walk_to(object)
	queue.append(STATES.FaceObject.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(STATES.PerformActionOnObject.new(self, ACTIONS.take, object))
	queue.append(STATES.AddToInventory.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_down'))


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
