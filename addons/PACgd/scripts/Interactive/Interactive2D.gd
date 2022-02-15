extends Node2D
class_name Interactive2D

var ACTIONS = preload("../Actions/Actions.gd").new()
var DEFAULT = preload("Default.gd").new()

# Position in space where the player will stand to interact
onready var interaction_position = DEFAULT.interaction_position(self)

# Name to output
onready var oname = DEFAULT.oname(self)

# If interactive, the point and click see's it
onready var interactive = DEFAULT.interactive(self)

# All actions
var main_action = DEFAULT.main_action
var secondary_action = DEFAULT.secondary_action

# Thumbnail for takeable items
onready var thumbnail = DEFAULT.thumbnail

# Description of the object
onready var description = DEFAULT.description(self)

# Default Interactions
func examine(who): return DEFAULT.examine(who, self)
func use_item(who, item): DEFAULT.use_item(who, item, self)
func walk_to(who): DEFAULT.walk_to(who, self)
func take(who): DEFAULT.take(who, self)
func grab(): DEFAULT.grab(self)
