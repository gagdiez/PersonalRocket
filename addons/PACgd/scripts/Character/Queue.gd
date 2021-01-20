# A smart queue to transition between states
class Queue:
	var queue = []

	func append(state):
		if queue and queue[0].blocked and not queue[0].finished:
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
			return true
		return false
