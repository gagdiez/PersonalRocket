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
	._ready()
	animation_player = $Animations

	talk_bubble = $"Talk Bubble"
	talk_bubble_timer = get_node("Talk Bubble/Timer")
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


func walk_to(object, emit_signal=true):
	var end = navigation.get_closest_point(object.position)

	if (end - transform.origin).length() > MINIMUM_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		
		var path = navigation.get_simple_path(begin, end, true)

		queue.clear()
		queue.append(STATES.Animate.new(self, "walk"))
		queue.append(STATES.WalkPath.new(self, path))
		queue.append(STATES.Animate.new(self, "idle"))
		
		if emit_signal:
			queue.append(STATES.Finished.new(self))


func go_to(object):
	# Transition between areas, walk to the point we need, and inform the obj
	walk_to(object, false)
	queue.append(STATES.PerformActionOnObject.new(self, ACTIONS.go_to, object))
	queue.append(STATES.Finished.new(self))


func get_close_and_perform_action(action, object):
	# First of all, walk to the object
	walk_to(object, false)
	queue.append(STATES.FaceObject.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(STATES.PerformActionOnObject.new(self, action, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_down'))
	queue.append(STATES.Finished.new(self))


func open(object):
	get_close_and_perform_action(ACTIONS.open, object)


func use(object):
	get_close_and_perform_action(ACTIONS.use, object)


func take(object):
	walk_to(object, false)
	queue.append(STATES.FaceObject.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(STATES.PerformActionOnObject.new(self, ACTIONS.take, object))
	queue.append(STATES.AddToInventory.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_down'))
	queue.append(STATES.Finished.new(self))


func face_direction(direction):
	var my_pos = camera.unproject_position(transform.origin)
	var dir = camera.unproject_position(transform.origin + direction)
	
	if dir.x < my_pos.x:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1


func face_object(object):
	if object.get("position"):
		var direction = object.position - self.transform.origin
		face_direction(direction)
	.action_finished()


func examine(object):
	face_object(object)
	say(object.call(ACTIONS.examine.function, self))
	.action_finished()


func read(object):
	face_object(object)
	say(object.call(ACTIONS.read.function, self))
	.action_finished()


func quiet():
	talk_bubble.visible = false
	.action_finished()


func say(text):
	talk_bubble_timer.stop()
	talk_bubble.text = text
	talk_bubble.visible = true
	talk_bubble_timer.start()
	talk_bubble_timer.connect("timeout", self, "quiet")
	
	
func use_item(what, where):
	say("I don't know how to use the " + what.oname +
		" with the " + where.oname)
	.action_finished()

func talk_to(who):
	walk_to(who, false)
	.action_finished()
