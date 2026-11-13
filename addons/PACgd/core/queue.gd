# A smart queue to transition between states
class Queue:
	var queue = []

	func append(state) -> void:
		queue.append(state)

	func empty() -> bool:
		return queue.is_empty()

	## Doing something that cannot be interrupted (i.e. talking)
	func busy() -> bool:
		return not queue.is_empty() and queue[0].blocked and not queue[0].finished

	func current():
		if queue:
			var current_state = queue[0]

			if current_state.finished:
				queue.pop_front()
				return current()
			return queue[0]

	func clear() -> void:
		queue = []

	## Runs states until one needs more time (walking, talking...), returns it
	func run():
		var state = current()
		while state:
			if state.who != null and not is_instance_valid(state.who):
				state.finished = true  # its actor is gone (i.e. the level changed)
			else:
				state.run()
			if not state.finished:
				return state
			state = current()
		return null
