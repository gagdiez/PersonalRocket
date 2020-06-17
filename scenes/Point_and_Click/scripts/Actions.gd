# Base class for actions

# Each action will have:
#  - a "function" called when executing
#  - a "text" which can be shown in screen
#  - a "type" which should be either "immediate" or "combined"
#    - immediate actions shuold be executed immediatly (i.e. examine <object>)
#    - combined actions need two objects to be done (i.e. use <this> <on that>)
#  - a "object" if the action is "combined", this is the object to combine"
#  - a "nexus" for the text in "combined" actions (i.e. use <this> "with" <that>)

const IMMEDIATE = 'immediate'
const TO_COMBINE = 'to_combine'
const COMBINED = 'combined'

class Action:
	var function
	var text
	var orig_text
	var type
	var orig_type
	var object
	var nexus = ""
	
	
	func _init(_func: String, _text:String, _type: String,
			   _nexus: String = ""):
		function = _func
		text = _text
		orig_text = _text
		orig_type = _type
		type = _type
		nexus = _nexus
	
	func combine(obj):
		object = obj
		text = orig_text + " " + obj.oname + " " + nexus
		type = COMBINED
	
	func uncombine():
		object = null
		text = orig_text
		type = orig_type


var walk_to = Action.new("walk_to", " ", IMMEDIATE)
var take = Action.new("take", "Take", IMMEDIATE)
var go_to = Action.new("go_to", "Go to", IMMEDIATE)
var read = Action.new("read", "Read", IMMEDIATE)
var examine = Action.new("examine", "Examine", IMMEDIATE)
var search = Action.new("search", "Search", IMMEDIATE)
var use = Action.new("use", "Use", IMMEDIATE)
var open = Action.new("open", "Open", IMMEDIATE)
var talk = Action.new("talk_to", "Talk to", IMMEDIATE)
var use_item = Action.new("use_item", "Use", TO_COMBINE, 'with')

# The empty action
var none = Action.new("", "", IMMEDIATE)
