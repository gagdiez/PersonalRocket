extends Spatial
class_name Interactive

# All actions
var ACTIONS = preload("Actions.gd").new()

# Actions that can be performed on the object
var main_action = ACTIONS.walk_to
var secondary_action = ACTIONS.examine

# Position in space where the player will stand to interact
onready var position = self.transform.origin

# Thumbnail for takeable items
onready var thumbnail = 'thumbnails/default.png'

# Name to output
onready var oname = str(name)

# Description of the object
onready var description = "A good old " + oname

onready var collision = $CollisionShape

func walk_to(who):
	who.walk_to(self)

func examine(who):
	print("called")
	return who.say(description)

func use_item(who:Interactive, item):
	who.say("I don't know how to combine " + self.oname + " with " + item.oname)
