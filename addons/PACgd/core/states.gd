const QUEUE = preload("queue.gd")


class State:
	var blocked = false
	var finished = false
	var who

	func run():
		finished = true

	## Called when the player interrupts it
	func stop():
		pass


# PREMADE STATES
class AddToInventory extends State:
	var item

	func _init(_who, _item):
		item = _item
		who = _who

	func run():
		blocked = true
		who.inventory.add(item)
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
		if not player.animation_finished.is_connected(animation_finished):
			player.animation_finished.connect(animation_finished)
	
	func animation_finished(_arg):
		player.animation_finished.disconnect(animation_finished)
		finished = true


class CallFunction extends State:
	var fc
	var params
	
	func _init(_who, _fc, _params):
		who = _who
		fc = _fc
		params = _params
	
	func run():
		if who.has_method(fc):
			who.callv(fc, params)
		else:
			push_error(who.display_name + " does not implement the method " + fc)
		finished = true



class FaceObject extends State:
	var object
	
	func _init(_who, _object):
		who = _who
		object = _object
	
	func run():
		var direction = object.world_position() - who.world_position()
		who.face_direction(direction)
		finished = true



class RemoveFromInventory extends State:
	var to_remove
	
	func _init(_who, object):
		to_remove = object
		who = _who
		
	func run():
		blocked = true
		who.inventory.remove(to_remove)
		finished = true


class Say extends State:
	var what
	var label
	var said = false
	var how_long

	func _init(_who, _what, _how_long):
		who = _who
		what = _what
		how_long = _how_long
	
	func run():
		blocked = true
		if said:
			return

		who.say_now(what)
		var timer = who.get_tree().create_timer(how_long)

		timer.timeout.connect(quiet)
		said = true

	func quiet():
		who.quiet()
		finished = true


class WalkTo extends State:
	# Walk to (the closest reachable point to) a destination, following the
	# path of the character's NavigationAgent
	var destination
	var started = false

	func _init(_who, _destination):
		who = _who
		destination = _destination

	func run():
		var agent = who.navigation_agent

		if not started:
			if not who.space.navigation_ready(agent):
				return  # the navigation map is not built yet (first frames)
			# Where to go is decided now, from where the character is now
			var end = who.space.closest_navigation_point(agent, destination)
			if (end - who.global_position).length() <= who.minimum_walkable_distance:
				finished = true
				return
			agent.target_desired_distance = who.minimum_walkable_distance
			agent.path_desired_distance = who.minimum_walkable_distance
			agent.target_position = end
			who.play_animation(who.anim_walk)
			started = true

		if agent.is_navigation_finished():
			# There is no more path to walk
			stop()
			finished = true
			return

		# Move the character towards the next point in the path
		var move_vec = agent.get_next_path_position() - who.global_position
		who.velocity = move_vec.normalized() * who.speed
		who.move_and_slide()
		who.face_direction(move_vec)

	func stop():
		who.velocity = who.velocity * 0
		who.play_animation(who.anim_idle)


class Run extends State:
	var function

	func _init(_who, _function):
		who = _who
		function = _function

	func run():
		function.call()
		finished = true


class Together extends State:
	# Each actor does their own states in order, all actors at the same time.
	# It finishes when all of them are done
	var queues = {}

	func add(state):
		var key = state.who if state.who != null else state
		if not queues.has(key):
			queues[key] = QUEUE.Queue.new()
		queues[key].append(state)

	func run():
		finished = true
		blocked = false
		for queue in queues.values():
			var running = queue.run()
			if running:
				finished = false
				blocked = blocked or running.blocked

	func stop():
		for queue in queues.values():
			var running = queue.current()
			if running:
				running.stop()
