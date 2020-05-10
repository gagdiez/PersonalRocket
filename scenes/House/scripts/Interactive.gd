# Base class for interactive objects
extends Spatial

# All actions
onready var ACTION = load("res://scenes/Point_and_Click/scripts/actions.gd").new()

# Main action that can be performed on the object
var main_action
onready var secondary_action = ACTION.examine

# Position in space where the player will stand to interact
onready var position = self.transform.origin

# Thumbnail for takeable items
onready var thumbnail = 'thumbnails/default.png'

onready var collision = $CollisionShape

# The take function will always make the things desapear, so lets leave it here
func take():
	visible = false
	collision.disabled = true

func examine():
	return "A good old " + name
