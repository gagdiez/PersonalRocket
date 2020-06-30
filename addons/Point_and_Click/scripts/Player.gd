extends BasePlayer
class_name Player

var animation_player
var talk_bubble
var talk_bubble_timer
var talk_bubble_offset
var SPEED = 5
var MINIMUM_DISTANCE = 0.5

func _physics_process(_delta):
	# Move Cole's bubble to above his head
	talk_bubble.rect_position = camera.unproject_position(
			transform.origin + talk_bubble_offset
	)
	
	# Process the queue
	self.process_queue()

# Functions to modify the graphics
func animate(animation):
	$Animations.play(animation)

func face_direction(direction):
	var my_pos = camera.unproject_position(transform.origin)
	var dir = camera.unproject_position(transform.origin + direction)
	
	if dir.x < my_pos.x:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1

# Functions to populate the queue in response to clicks in objects
func examine(object):
	queue.clear()
	queue.append(STATES.Animate.new(self, "idle"))
	queue.append(STATES.FaceObject.new(self, object))
	say(object.call(ACTIONS.examine.function, self))

func get_close_and_perform_action(action, object):
	# First of all, walk to the object
	walk_to(object, false)
	queue.append(STATES.FaceObject.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(STATES.PerformActionOnObject.new(self, action, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_down'))
	queue.append(STATES.Finished.new(self))

func go_to(object):
	# Transition between areas, walk to the point we need, and inform the obj
	walk_to(object, false)
	queue.append(STATES.PerformActionOnObject.new(self, ACTIONS.go_to, object))
	queue.append(STATES.Finished.new(self))

func open(object):
	get_close_and_perform_action(ACTIONS.open, object)

func read(object):
	walk_to(object, false)
	queue.append(STATES.FaceObject.new(self, object))
	say(object.call(ACTIONS.read.function, self))

func say(text):
	queue.append(STATES.Say.new(self, text, talk_bubble, talk_bubble_timer))
	queue.append(STATES.Finished.new(self))

func take(object):
	walk_to(object, false)
	queue.append(STATES.FaceObject.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_raise'))
	queue.append(STATES.PerformActionOnObject.new(self, ACTIONS.take, object))
	queue.append(STATES.AddToInventory.new(self, object))
	queue.append(STATES.AnimateUntilFinished.new(self, 'take_down'))
	queue.append(STATES.Finished.new(self))

func talk_to(who):
	walk_to(who)

func use(object):
	get_close_and_perform_action(ACTIONS.use, object)

func use_item(what, where):
	what.use(where)

func walk_to(object, emit_signal=true):
	queue.clear()
	
	var end = navigation.get_closest_point(object.position)

	if (end - transform.origin).length() > MINIMUM_DISTANCE:
		# We actually need to walk
		var begin = navigation.get_closest_point(transform.origin)
		var path = navigation.get_simple_path(begin, end, true)

		queue.append(STATES.Animate.new(self, "walk"))
		queue.append(STATES.WalkPath.new(self, path))
		queue.append(STATES.Animate.new(self, "idle"))
		
		if emit_signal:
			queue.append(STATES.Finished.new(self))
