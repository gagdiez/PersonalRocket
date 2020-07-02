extends Node

class Parser:
	var SCENES = preload("Scenes.gd").new()
	var ACTIONS = preload("../Actions/Actions.gd").new()
	
	var scene
	var gui
	var str2obj
	
	func _init(_scene, _gui, _str2obj):
		scene = _scene
		gui = _gui
		str2obj = _str2obj

	func remove_white_lines(lines):
		var not_white_lines = []
		
		while not lines.empty():
			var line = lines.pop_front()
			if line.dedent():
				not_white_lines.append(line)
		return not_white_lines

	func parse_file(file_name):
		# Parses the file "file_name", using the dictionary "str2obj" to know
		# what each string is referencing... for example, "cole" -> "$Cole"
		var file = File.new()
		file.open(file_name, File.READ)
		var lines = Array(file.get_as_text().split('\n', false))
		lines = remove_white_lines(lines)
		file.close()
		
		return parse(lines)
	
	func parse(lines):
		var actions = []
		
		while not lines.empty():
			var action
			var line = lines.pop_front()
	
			var splitted = line.dedent().split(":")
	
			if splitted[0] == 'choice':
				action = parse_choice(lines)
			else:
				action = parse_action(line)
			
			actions.append(action)

		return actions
	
	
	func parse_action(line):
		var two_point_split = line.dedent().split(":")
		var space_split = two_point_split[0].split(" ")
		
		if len(two_point_split) <= 1 or len(space_split) <= 1:
			printerr("Error in line ", line, ". Invalid syntax")
			return []
		
		var whom = space_split[0].strip_edges()
		var action = space_split[1].strip_edges()
		var what = two_point_split[1].strip_edges()
	
		if not whom in str2obj:
			printerr(whom, " is not a valid actor, check the dictionary")
			return []
		
		whom = str2obj[whom]

		if not action in ACTIONS:
			printerr(action, " is not a valid action, check the Actions class")
			return []
		
		var real_action = ACTIONS.get(action)
		
		if real_action.type == Action.IMMEDIATE:
			return SCENES.PlayerAction.new(whom, real_action, what)

		if real_action.type == Action.TO_COMBINE:
			var combined_split = what.split(" ")
			var obj1 = combined_split[0].strip_edges()
			var obj2 = combined_split[1].strip_edges()
			
			if not (obj1 in str2obj) or not (obj2 in str2obj):
				printerr("Check if ", obj1, " ", obj2, " are in the dictionary")
				return []
			
			var to_combine = Action.new(real_action.function, real_action.text,
										real_action.type, real_action.nexus)
			to_combine.combine(str2obj[obj1])

			return SCENES.PlayerAction.new(whom, to_combine, str2obj[obj2])
		
		if not what in str2obj:
			printerr(what, " is not a valid object, check the dictionary")
			return []
		else:
			return SCENES.PlayerAction.new(whom, real_action, str2obj[what])


	func identation(line):
		return len(line) - len(line.dedent())


	func parse_choice(lines):
		var line = lines[0]
		var choice_ident = identation(line)
		var options = []

		while not lines.empty() and identation(lines[0]) >= choice_ident:
			options.append(parse_option(lines))

		return SCENES.Choice.new(options, scene, gui)


	func parse_option(lines):
		var title
		var actions = []
		var condition = null
		var end = false

		var line = lines.pop_front()
		var option_ident = identation(line)
		var two_point_split = line.split(":")
		var type = two_point_split[0]

		match type.dedent():
			"option":
				end = false
			"return":
				end = true
			_:
				printerr("Error parsing option:", line)
				return []

		if "!{" in two_point_split[1]:
			var cond_split = two_point_split[1].split("!{")
			condition = parse_condition("!{"+cond_split[1])
			title = cond_split[0]
		else:
			title = two_point_split[1]

		while not lines.empty() and identation(lines[0]) > option_ident:
			actions.append(lines.pop_front())

		var parsed_actions = parse(actions)
		return SCENES.Option.new(title, parsed_actions, condition, end)

	func parse_condition(text):
		return true
