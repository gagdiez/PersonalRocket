class State:
	onready var blocked = false
	onready var finished = false

	func run():
		pass

class Queue:
	var queue = []

	func append(state):
		if queue and queue[0].blocked:
			return
		else:
			queue.append(state)
	
	func empty():
		return queue.empty()

	func current():
		if queue:
			var current_state = queue[0]
			
			if current_state.finished:
				queue.pop_front()
				return current()
			return queue[0]
	
	func clear():
		if queue and not queue[0].blocked:
			queue = []


# PREMADE STATES
class AddToInventory extends State:
	# Function to take
	var object_to_take
	var who
	
	func _init(_who, _object_to_take):
		object_to_take = _object_to_take
		who = _who
		
	func run():
		blocked = true
		who.inventory.add(object_to_take)
		
		who.say("I took the " + str(object_to_take.name).to_lower())

		finished = true


class Animate extends State:
	var who
	var animation
	var player
	
	func _init(_who, _animation):
		who = _who
		animation = _animation
	
	func run():
		who.animate(animation)
		finished = true


class AnimateUntilFinished extends State:
	var who
	var animation
	var player
	
	func _init(_who, _animation):
		who = _who
		animation = _animation
		player = who.animation_player
	
	func run():
		if not finished:
			blocked = true
			who.animate(animation)
			if not player.is_connected("animation_finished", self, "finished"):
				player.connect("animation_finished", self, "finished")
	
	func finished(arg):
		finished = true
		player.disconnect("animation_finished", self, "finished")


class FaceObject extends State:
	var who
	var object
	
	func _init(_who, _object):
		who = _who
		object = _object
	
	func run():
		var direction = object.transform.origin - who.transform.origin
		who.face_direction(direction)
		finished = true


class PerformActionOnObject extends State:
	# Function to take
	var who
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


class WalkPath extends State:
	# Function to walk
	var path = []
	var path_idx = 0
	var who
	 
	func _init(_who, _path):
		who = _who
		path = _path

	func run():
		if path_idx < path.size():
			# There is a path to walk
			var move_vec = (path[path_idx] - who.transform.origin)

			if move_vec.length() < who.MINIMUM_DISTANCE:
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
