class State:
	onready var blocked = false
	onready var finished = false
	var who

	func run():
		pass


# PREMADE STATES
class AddToInventory extends State:
	var object_to_take
	
	func _init(_who, _object_to_take):
		object_to_take = _object_to_take
		who = _who
		
	func run():
		blocked = true
		who.inventory.add(object_to_take)
		finished = true


class Animate extends State:
	var animation
	var player
	
	func _init(_who, _animation):
		who = _who
		animation = _animation
	
	func run():
		who.play_animation(animation)
		finished = true


class AnimateUntilFinished extends State:
	var animation
	var player
	
	func _init(_who, _animation):
		who = _who
		animation = _animation
		player = who.animation_player
	
	func run():
		blocked = true
		who.play_animation(animation)
		if not player.is_connected("animation_finished", self, "animation_finished"):
			player.connect("animation_finished", self, "animation_finished")
	
	func animation_finished(_arg):
		finished = true
		player.disconnect("animation_finished", self, "finished")


class FaceObject extends State:
	var object
	
	func _init(_who, _object):
		who = _who
		object = _object
	
	func run():
		var direction = object.transform.origin - who.transform.origin
		who.face_direction(direction)
		finished = true


class Finished extends State:
	func _init(_who):
		who = _who
	
	func run():
		who.action_finished()
		finished = true


class InteractWithObject extends State:
	var object
	var function
	
	func _init(_who, fn, obj):
		who = _who
		object = obj
		function = fn
		
	func run():
		blocked = true
		# Perform action on object
		object.call(function, who)
		finished = true


class PerformActionOnObject extends State:
	var object
	var action
	
	func _init(_who, act, obj):
		who = _who
		object = obj
		action = act
		
	func run():
		blocked = true
		# Perform action on object
		object.call(action.function, who)
		finished = true


class Say extends State:
	var what
	var label
	var timer
	var said = false
	
	func _init(_who, _what, _label, _timer):
		who = _who
		what = _what
		label = _label
		timer = _timer
	
	func run():
		blocked = true
		if said:
			return
		timer.stop()
		label.text = what
		label.visible = true
		timer.start()
		timer.connect("timeout", self, "quiet")
		said = true
		
	func quiet():
		timer.disconnect("timeout", self, "quiet")
		label.visible = false
		finished = true


class TalkTo extends State:
	var whom
	
	func _init(_who, _whom):
		who = _who
		whom = _whom
		
	func run():
		blocked = true
		whom.talking(who)
		finished = true


class WalkPath extends State:
	# Function to walk
	var path = []
	var path_idx = 0
	 
	func _init(_who, _path):
		who = _who
		path = _path

	func run():
		if path_idx < path.size():
			# There is a path to walk
			var move_vec = (path[path_idx] - who.transform.origin)

			if move_vec.length() < who.MINIMUM_WALKABLE_DISTANCE:
				# too short to walk, move to next segment
				path_idx += 1
				run()
			else:
				# Move the character
				who.move_and_slide(move_vec.normalized() * who.SPEED)
				who.face_direction(move_vec)
		else:
			# There is no more path to walk
			finished = true
