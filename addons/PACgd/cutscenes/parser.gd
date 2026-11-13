extends RefCounted
## Translates a cutscene file into scenes (see scenes.gd)

const SCENES = preload("scenes.gd")

# The parser uses a dictionary (here called names) to know how to translate
# strings into objects. For example, the user will write "cole take: box",
# and we want this to be translated into interactions between our objects
# cole and box.
var names: Dictionary

# Lines to be parsed
var lines = []

func err(msg):
	# Nice erorr printing in the console
	printerr(msg); push_error(msg)
	
func identation(line):
	# Computes the level of identation of a line
	return len(line) - len(line.dedent())
	
# PARSER
func parse_file(_scene_file, _names):
	# Parses all the lines of a file
	var file = FileAccess.open(_scene_file, FileAccess.READ)
	if file == null:
		err("Cannot open " + _scene_file + ": " + error_string(FileAccess.get_open_error()))
		return []
	lines = Array(file.get_as_text().split('\n', false))
	file.close()

	names = _names
	lines = remove_white_lines(lines)
	
	return parse(lines)
	
func parse(to_parse):
	# Parses an array of lines and transform thems into scenes
	var scenes = []
	
	while not to_parse.is_empty():
		var scene

		var line = to_parse[0]
		var splitted = line.dedent().split(":", true, 1)
		var instruction = splitted[0]

		match instruction:
			'choice':
				scene = parse_choice(to_parse)
			'if':
				var params = splitted[1]  # get condition from "if: condition"
				scene = parse_if(params, to_parse)
			'finish':
				line = to_parse.pop_front()  # simply return a finish
				scene = SCENES.ChoiceFinish.new()
			_:
				line = to_parse.pop_front()
				scene = parse_action(line)

		scenes.append(scene)
	return scenes

func remove_white_lines(to_clean):
	# Remove empty from a String Array
	var not_white_lines = []
	
	while not to_clean.is_empty():
		var line = to_clean.pop_front()
		if line.dedent():
			not_white_lines.append(line)
	return not_white_lines

func parse_action(line):
	# Actions are of the form <whom> <action>: <what>
	# For example: Cole say: Hi; Cole take: object; Cole walk_to: object
	var two_point_split = line.dedent().split(":", true, 1)
	var subject_action = two_point_split[0].split(" ")
	
	if len(two_point_split) <= 1 or len(subject_action) <= 1:
		err("Error in line " + line + ". Invalid syntax")
		return []
	
	# Get the stings <whom> <action>: <what>
	var whom = subject_action[0].strip_edges()
	var action = subject_action[1].strip_edges()
	var what = two_point_split[1].strip_edges()

	if not whom in names:
		err(whom + " is not a valid actor (check its id)")
		return []

	# Translate whom into a godot-object
	whom = names[whom]

	if not action in PAC.actions:
		err(action + " is not a valid action (see PAC.actions)")
		return []

	var real_action: PACAction = PAC.actions[action]

	match real_action.type:
		PACAction.Type.INTERACTIVE:
			# i.e. cole take: <what> -> Translate what into an object
			if what in names:
				return SCENES.ExecAction.new(whom, real_action, names[what])
			err(what + " is not a valid object (check its id)")
			return []

		PACAction.Type.INTERNAL:
			# i.e. cole call: fc param1 param2 param3
			# We need to split <what> into an array
			var params = Array(what.split(" "))

			for i in range(params.size()):
				if '{' in params[i] and '}' in params[i]:
					params[i] = SCENES.Variable.new(params[i], names)

			return SCENES.ExecAction.new(whom, real_action, params)

		PACAction.Type.IMMEDIATE:
			# cole add_to_inventory: <item>
			if action in ["add_to_inventory", "remove_from_inventory"]:
				if what in names:
					return SCENES.ExecAction.new(whom, real_action, names[what])
				err(what + " is not a valid object (check its id)")
				return []

			# cole say: <what> -> what could contain variables
			if '{' in what and '}' in what:
				what = SCENES.Variable.new(what, names)
			return SCENES.ExecAction.new(whom, real_action, what)

		PACAction.Type.TO_COMBINE:
			# cole use_item: <item> <object> -> object.use_item(cole, item)
			var combined_split = what.split(" ")
			if combined_split.size() != 2:
				err("Error in line " + line + ". Expected: <item> <object>")
				return []
			var item_name = combined_split[0].strip_edges()
			var object_name = combined_split[1].strip_edges()

			if not item_name in names:
				err(item_name + " is not a valid object (check its id)")
				return []
			if not object_name in names:
				err(object_name + " is not a valid object (check its id)")
				return []

			return SCENES.ExecAction.new(whom, real_action, names[object_name], names[item_name])

	return []

func parse_choice(to_parse):
	# Parse a choice
	var line = to_parse.pop_front()
	var title = line.split(":", true, 1)[1]
	var choice_ident = identation(line)
	
	var options = []
	while not to_parse.is_empty() and identation(to_parse[0]) > choice_ident:
		options.append(parse_option(to_parse))

	return SCENES.Choice.new(title, options)


func parse_option(to_parse):
	# Parse an option
	var line = to_parse.pop_front()
	var option_ident = identation(line)
	
	var if_split = line.split("if:")
	
	var condition = 'true'
	if if_split.size() == 2:
		condition = if_split[1]
	
	var two_point_split = if_split[0].split(":", true, 1)

	if (two_point_split[0].dedent() != "option"):
		err("Error parsing option:" + line)
		return []

	var actions = []
	while not to_parse.is_empty() and identation(to_parse[0]) > option_ident:
		actions.append(to_parse.pop_front())
	
	var scenes = parse(actions)
	
	# Check if the last scene is finish, if not, make it a return
	var last_scene = scenes[-1]

	if not last_scene is SCENES.ChoiceFinish:
		scenes.append(SCENES.ChoiceReturn.new())

	var title = two_point_split[1]

	return SCENES.Option.new(title, scenes, condition, names)

func parse_if(condition, to_parse):
	# Parse an if
	var iftrue = []
	var iffalse = []
	
	# First line is the if
	var line = to_parse.pop_front()
	var if_indent = identation(line)
	
	while not to_parse.is_empty() and identation(to_parse[0]) > if_indent:
		line = to_parse.pop_front()
		iftrue.append(line)

	if not to_parse.is_empty() and to_parse[0].dedent().split(':')[0] == 'else':
		to_parse.pop_front()
		
		while not to_parse.is_empty() and identation(to_parse[0]) > if_indent:
			line = to_parse.pop_front()
			iffalse.append(line)

	iftrue = parse(iftrue)
	iffalse = parse(iffalse)
	return SCENES.If.new(names, condition, iftrue, iffalse)
