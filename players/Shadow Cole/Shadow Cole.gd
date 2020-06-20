extends "res://scenes/Point_and_Click/scripts/Player.gd"

# Player variables
const SPEED = 5
const MINIMUM_DISTANCE = 0.5
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
	talk_bubble_timer.connect("timeout", self, "quiet")

	position = self.transform.origin + Vector3(5, 0, 0)

func _physics_process(_delta):
	# Move Cole's bubble to above his head
	talk_bubble.rect_position = camera.unproject_position(
			transform.origin + talk_bubble_offset
	)
	self.position = self.transform.origin + Vector3(5, 0, 0)
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


func quiet():
	talk_bubble.visible = false
	.action_finished()


func say(text):
	talk_bubble_timer.stop()
	talk_bubble.text = text
	talk_bubble.visible = true
	talk_bubble_timer.start()


func talking(_whom):
	pass#cut_scene.start("shadow_conversation")
