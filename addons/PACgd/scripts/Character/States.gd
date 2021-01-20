class State:
	var blocked = false
	var finished = false
	var who

	func run():
		finished = true


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
		player.disconnect("animation_finished", self, "animation_finished")
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
			printerr(who.name + " does not implement the method " + fc)
			push_error(who.name + " does not implement the method " + fc)
		finished = true


class Emit extends State:
	
	var message
	
	func _init(_who, msg):
		who = _who
		message = msg
		
	func run():
		if who.get_signal_connection_list("message"):
			who.emit_signal("message", message)
			finished = true


class FaceObject extends State:
	var object
	
	func _init(_who, _object):
		who = _who
		object = _object
	
	func run():
		var direction = object.transform.origin - who.transform.origin
		who.face_direction(direction)
		finished = true


class InteractWithObject extends State:
	var object
	var function
	var params
	
	func _init(_who, obj, fn, _params=[]):
		who = _who
		object = obj
		function = fn
		params = _params
		
	func run():
		blocked = true
		# Perform action on object
		object.callv(function, params)
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


class SetVariable extends State:
	var whom
	var what
	var value
	
	func _init(_whom, _what, _value):
		whom = _whom
		what = _what
		value = _value
	
	func run():
		if what in whom:
			whom.set(what, value)
		else:
			printerr("Variable non existent: ", whom.name, ".", what)
			push_error("Variable non existent: " + whom.name + " " + what)
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


class WaitOnCharacter extends State:
	var whom
	var what
	var running = false
	
	func _init(_who, _whom, _what):
		who = _who
		whom = _whom
		what = _what
	
	func run():
		if running:
			return

		whom.connect("message", self, "received_message")
		running = true
	
	func received_message(message):
		if message == what:
			whom.disconnect("message", self, "received_message")
			finished = true
