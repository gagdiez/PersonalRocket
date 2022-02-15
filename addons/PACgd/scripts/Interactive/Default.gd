# Default parameters
func interaction_position(obj): return obj.transform.origin
func oname(obj): return str(obj.name)
func interactive(obj): return true

# Default actions
var ACTIONS = preload("../Actions/Actions.gd").new()

var main_action = ACTIONS.walk_to
var secondary_action = ACTIONS.examine

# Default thumbnail
var thumbnail = "res://addons/Point_and_Click/scripts/Interactive/default_thumbnail.png"

# Default description
func description(obj): return "A good old " + obj.oname

# Default Interactions
func examine(who, obj):
	return who.say(obj.description)

func use_item(who, item, obj):
	who.say("I don't know how to use " + obj.oname + " with " + item.oname)

func walk_to(who, obj):
	who.approach(obj)

func take(who, obj):
	who.approach(obj)
	who.animate_until_finished("raise_hand")
	who.call_function_from(obj, "grab")
	who.add_to_inventory(obj)
	who.animate_until_finished("lower_hand")

func grab(obj):
	obj.visible = false
	obj.interactive = false
