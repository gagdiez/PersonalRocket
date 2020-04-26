# The actions have grown enough in quantity and complexity such that
# they need their own class

# Each action will have:
#  - a "name" which identifies it
#  - a "text" which can be shown in screen
#  - a "property" which the object should have in order to execute the action
#  - a "type" which should be either "immediate" or "combined"
#    - immediate actions shuold be executed immediatly (i.e. examine <object>)
#    - combined actions need two objects to be done (i.e. use <this> <on that>)
#  - a "nexus" if the action is "combined", so we write "Use <obj> with <obj>"

const IMMEDIATE = 'immediate'
const COMBINED = 'combined'

class Action:
	var name
	var text
	var type
	var property
	var nexus
	
	func _init(_name: String, _text:String, _type: String,
			   _property: String, _nexus: String = ""):
		name = _name
		text = _text
		type = _type
		property = _property
		nexus = _nexus


var take = Action.new("take", "Take", IMMEDIATE, 'takeable')
var walk = Action.new("walk_to", "Walk to", IMMEDIATE, 'position')
var read = Action.new("read", "Read", IMMEDIATE, 'readable')
var examine = Action.new("examine", "Examine", IMMEDIATE, 'description')
var use = Action.new("use", "Use", COMBINED, 'useble', 'with')
