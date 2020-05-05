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

class Walk extends State:
	# Function to walk
	var path = []
	var path_idx = 0
	var who
	 
	func _init(_who, to_what, navigation):
		var begin = navigation.get_closest_point(_who.transform.origin)
		var end = navigation.get_closest_point(to_what.position)
		who = _who
		
		if (end - _who.transform.origin).length() > who.MINIMUM_DISTANCE:
			# We actually need to walk
			path = navigation.get_simple_path(begin, end, true)
			path_idx = 0

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
				who.animate("walk", move_vec)
				who.move_and_slide(move_vec.normalized() * who.SPEED)
		else:
			# There is no more path to walk, go to idle animation
			who.animate("idle", null)
			finished = true


class Take extends State:
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
		
		# Tell the object you took it
		object_to_take.take()
		
		finished = true


class PlayAnimation extends State:
	var who
	var animation
	var player
	
	func _init(_who, animation_player, _animation):
		who = _who
		animation = _animation
		player = animation_player
	
	func run():
		if not finished:
			blocked = true
			who.animate(animation, null)
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
		who.face_object(object)
		finished = true
