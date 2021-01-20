class ExecAction:
	var who
	var action
	var what
	var name = 'ExecAction'
	signal scene_finished
	
	func _init(_who, _action, _what):
		who = _who
		action = _action
		what = _what
	
	func play():
		who.connect("player_finished", self, "finished")
		
		if what is Array:
			for i in range(what.size()):
				if what[i] is Variable:
					what[i] = what[i].evaluate()
		
		if what is Variable:
			what = what.evaluate()
		
		action.execute(who, what)
	
	func finished():
		who.disconnect("player_finished", self, "finished")
		emit_signal("scene_finished", [])


class Option:
	var text
	var str2obj
	var scenes = []
	var condition = []
	var eval = ExpressionEvaluator.new()
	
	func _init(_text, _scenes, _condition, _str2obj):
		text = _text
		scenes = _scenes
		condition = _condition
		str2obj = _str2obj
	
	func evaluate():
		return eval.evaluate(condition, str2obj.keys(), str2obj.values())


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
		choice_handler.connect("choice_made", self, "finished")
	
	func finished(chosen_idx):
		choice_handler.disconnect("choice_made", self, "finished")

		var option = to_show[chosen_idx]
	
		emit_signal("scene_finished", option.scenes)

class ChoiceReturn:
	var name = 'Return'
	pass

class ChoiceFinish:
	var name = 'Finish'
	pass


class Condition:
	var cond
	var str2obj
	
	func _init(condition, _str2obj):
		cond = condition
		str2obj = _str2obj
	
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
	var str2obj
	var eval = ExpressionEvaluator.new()
	var name = 'If'
	
	signal scene_finished
	
	func _init(_str2obj, cond, iftrue, iffalse):
		condition = cond
		if_true_scenes = iftrue
		if_false_scenes = iffalse
		str2obj = _str2obj

	func play():
		if eval.evaluate(condition, str2obj.keys(), str2obj.values()):
			emit_signal("scene_finished", if_true_scenes)
		elif not if_false_scenes.empty():
			emit_signal("scene_finished", if_false_scenes)
		emit_signal("scene_finished", [])


class Variable:
	var variable
	var to_evaluate = []
	var str2obj
	var eval = ExpressionEvaluator.new()
	
	func _init(_variable, _str2obj):
		variable = _variable
		str2obj = _str2obj
		
		var regex = RegEx.new()
		regex.compile("({.*?})")
		
		for mtch in regex.search_all(variable):
			to_evaluate.append(mtch.get_string())

	func evaluate():
		var changes:Array = []
		for e in to_evaluate:
			var expression = e.substr(1, len(e)-2)
			changes.append(eval.evaluate(expression, str2obj.keys(), str2obj.values()))
		
		if variable == to_evaluate[0]:
			return changes[0]

		for i in range(to_evaluate.size()):
			variable = variable.replace(to_evaluate[i], changes[i])

		return variable
