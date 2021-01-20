extends Node
class_name Parser

var SCENES = preload("Scenes.gd").new()
var ACTIONS = preload("../Actions/Actions.gd").new()

# The parser uses a dictionary (here called str2obj) to know how to
# translate strings into objects. For example, the user will write
# "cole take: box", and we want this to be translated into interactions
# between our Godot-object Cole and the Godot-object box
var str2obj

# Lines to be parsed
var lines = []

func err(msg):
	# Nice erorr printing in the console
	printerr(msg); push_error(msg)
	
func identation(line):
	# Computes the level of identation of a line
	return len(line) - len(line.dedent())
	
# PARSER
func parse_file(_scene_file, _str2obj):
	for value in _str2obj.values():
		if not value is Object:
			err(value + " is not an object")
			return []
	
	# Parses all the lines of a file
	var file = File.new()
	file.open(_scene_file, File.READ)
	lines = Array(file.get_as_text().split('\n', false))
	file.close()

	str2obj = _str2obj
	lines = remove_white_lines(lines)
	
	return parse(lines)
	
func parse(lines):
	# Parses an array of lines and transform thems into scenes
	var scenes = []
	
	while not lines.empty():
		var scene

		var line = lines[0]
		var splitted = line.dedent().split(":")
		var instruction = splitted[0]

		match instruction:
			'choice':
				scene = parse_choice(lines)
			'if':
				var params = splitted[1]  # get condition from "if: condition"
				scene = parse_if(params, lines)
			'finish':
				line = lines.pop_front()  # simply return a finish
				scene = SCENES.ChoiceFinish.new()
			_:
				line = lines.pop_front()
				scene = parse_action(line)

		scenes.append(scene)
	return scenes

func remove_white_lines(lines):
	# Remove empty from a String Array
	var not_white_lines = []
	
	while not lines.empty():
		var line = lines.pop_front()
		if line.dedent():
			not_white_lines.append(line)
	return not_white_lines

func parse_action(line):
	# Actions are of the form <whom> <action>: <what>
	# For example: Cole say: Hi; Cole take: object; Cole walk_to: object
	var two_point_split = line.dedent().split(":")
	var subject_action = two_point_split[0].split(" ")
	
	if len(two_point_split) <= 1 or len(subject_action) <= 1:
		err("Error in line " + line + ". Invalid syntax")
		return []
	
	# Get the stings <whom> <action>: <what>
	var whom = subject_action[0].strip_edges()
	var action = subject_action[1].strip_edges()
	var what = two_point_split[1].strip_edges()

	if not whom in str2obj:
		err(whom + " is not a valid actor, check the dictionary")
		return []
	
	# Translate whom into a godot-object
	whom = str2obj[whom]

	if not action in ACTIONS:
		err(action + " is not a valid action, check the Actions class")
		return []
	
	# Translate the action into an PAC Action
	var real_action = ACTIONS.get(action)
	
	match real_action.type:
		Action.INTERACTIVE:
			# i.e. cole take: <what> -> Translate what into an object
			if what in str2obj:
				return SCENES.ExecAction.new(whom, real_action, str2obj[what])
			err(what + " is not a valid object, check the dictionary")
			return []

		Action.INTERNAL:
			# i.e. cole call: fc param1 param2 param3
			# We need to split <what> into an array
			var params = Array(what.split(" "))
			
			for i in range(params.size()):
				if '{' in params[i] and '}' in params[i]:
					params[i] = SCENES.Variable.new(params[i], str2obj)
			
			return SCENES.ExecAction.new(whom, real_action, params)

		Action.IMMEDIATE:
			# cole say: <what> -> what could contain variables
			if '{' in what and '}' in what:
				what = SCENES.Variable.new(what, str2obj)
			return SCENES.ExecAction.new(whom, real_action, what)

		Action.TO_COMBINE:
			# cole use: <this> <onthat> -> translate both objects
			var combined_split = what.split(" ")
			var obj1 = combined_split[0].strip_edges()
			var obj2 = combined_split[1].strip_edges()
			
			if not (obj1 in str2obj) or not (obj2 in str2obj):
				err("Check if "+obj1+" "+obj2+" are in the dictionary")
				return []
			
			var combine = Action.new(real_action.function, real_action.text,
									 real_action.type, real_action.nexus)
			combine.combine(str2obj[obj1])
	
			return SCENES.ExecAction.new(whom, combine, str2obj[obj2])

func parse_choice(lines):
	# Parse a choice
	var line = lines.pop_front()
	var title = line.split(":")[1]
	var choice_ident = identation(line)
	
	var options = []
	while not lines.empty() and identation(lines[0]) > choice_ident:
		options.append(parse_option(lines))

	return SCENES.Choice.new(title, options)


func parse_option(lines):
	# Parse an option
	var line = lines.pop_front()
	var option_ident = identation(line)
	
	var if_split = line.split("if:")
	
	var condition = 'true'
	if if_split.size() == 2:
		condition = if_split[1]
	
	var two_point_split = if_split[0].split(":")

	if (two_point_split[0].dedent() != "option"):
		err("Error parsing option:" + line)
		return []

	var actions = []
	while not lines.empty() and identation(lines[0]) > option_ident:
		actions.append(lines.pop_front())
	
	var scenes = parse(actions)
	
	# Check if the last scene is finish, if not, make it a return
	var last_scene = scenes[-1]

	if not last_scene is SCENES.ChoiceFinish:
		scenes.append(SCENES.ChoiceReturn.new())

	var title = two_point_split[1]

	return SCENES.Option.new(title, scenes, condition, str2obj)

func parse_if(condition, lines):
	# Parse an if
	var iftrue = []
	var iffalse = []
	
	# First line is the if
	var line = lines.pop_front()
	var if_indent = identation(line)
	
	while not lines.empty() and identation(lines[0]) > if_indent:
		line = lines.pop_front()
		iftrue.append(line)

	if lines[0].dedent().split(':')[0] == 'else':
		lines.pop_front()
		
		while not lines.empty() and identation(lines[0]) > if_indent:
			line = lines.pop_front()
			iffalse.append(line)

	iftrue = parse(iftrue)
	iffalse = parse(iffalse)
	return SCENES.If.new(str2obj, condition, iftrue, iffalse)
