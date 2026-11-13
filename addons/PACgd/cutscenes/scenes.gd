class ExecAction:
	var who
	var action
	var what
	var with_item
	var name = 'ExecAction'
	signal scene_finished

	func _init(_who, _action, _what, _with_item = null):
		who = _who
		action = _action
		what = _what
		with_item = _with_item
	
	func play():

		if what is Array:
			for i in range(what.size()):
				if what[i] is Variable:
					what[i] = what[i].evaluate()
		
		if what is Variable:
			what = what.evaluate()
		
		action.execute(who, what, with_item)

		# Done once the queue has played what the action added to it
		if PAC.queue.empty():
			finished.call_deferred()
		else:
			PAC.queue_finished.connect(finished, CONNECT_ONE_SHOT)

	func finished():
		scene_finished.emit([])


class Option:
	var text
	var names
	var scenes = []
	var condition = []
	var eval = ExpressionEvaluator.new()
	
	func _init(_text, _scenes, _condition, _names):
		text = _text
		scenes = _scenes
		condition = _condition
		names = _names
	
	func evaluate():
		return eval.evaluate(condition, names.keys(), names.values())


class Choice:
	var name = 'Choice'
	var options = []
	var choice_handler
	var title
	var to_show = []
	signal scene_finished
	
	func _init(_title, opts):
		title = _title
		options = opts
	
	func play():
		to_show = []

		for opt in options:
			if opt.evaluate():
				to_show.append(opt)

		choice_handler.show_choice(title, to_show)
		choice_handler.choice_made.connect(finished)
	
	func finished(chosen_idx):
		choice_handler.choice_made.disconnect(finished)

		var option = to_show[chosen_idx]
	
		scene_finished.emit(option.scenes)

class ChoiceReturn:
	var name = 'Return'
	pass

class ChoiceFinish:
	var name = 'Finish'
	pass


class Condition:
	var cond
	var names
	
	func _init(condition, _names):
		cond = condition
		names = _names
	
	func eval():
		return true


class ExpressionEvaluator:
	func evaluate(command, variable_names = [], variable_values = []):
		var expression = Expression.new()
		
		var error = expression.parse(command, variable_names)
		if error != OK:
			push_error(expression.get_error_text())
			return false

		var result = expression.execute(variable_values, self)

		if not expression.has_execute_failed():
			return result
		return false 


class If:
	var condition
	var if_true_scenes
	var if_false_scenes
	var names
	var eval = ExpressionEvaluator.new()
	var name = 'If'
	
	signal scene_finished
	
	func _init(_names, cond, iftrue, iffalse):
		condition = cond
		if_true_scenes = iftrue
		if_false_scenes = iffalse
		names = _names

	func play():
		if eval.evaluate(condition, names.keys(), names.values()):
			scene_finished.emit(if_true_scenes)
		else:
			scene_finished.emit(if_false_scenes)


class Variable:
	var variable
	var to_evaluate = []
	var names
	var eval = ExpressionEvaluator.new()
	
	func _init(_variable, _names):
		variable = _variable
		names = _names
		
		var regex = RegEx.new()
		regex.compile("({.*?})")
		
		for mtch in regex.search_all(variable):
			to_evaluate.append(mtch.get_string())

	func evaluate():
		var changes:Array = []
		for e in to_evaluate:
			var expression = e.substr(1, len(e)-2)
			changes.append(eval.evaluate(expression, names.keys(), names.values()))
		
		if variable == to_evaluate[0]:
			return changes[0]

		for i in range(to_evaluate.size()):
			variable = variable.replace(to_evaluate[i], str(changes[i]))

		return variable
