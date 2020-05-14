# Base class for interactive objects
extends StaticBody

# All actions
onready var ACTIONS = load("res://scenes/Point_and_Click/scripts/actions.gd").new()

# Actions that can be performed on the object
onready var actions = [ACTIONS.examine]

# Position in space where the player will stand to interact
onready var position = self.transform.origin

# Thumbnail for takeable items
onready var thumbnail = 'thumbnails/default.png'

# Name to output
onready var oname = str(name).to_lower()

# Description of the object
onready var description = "A good old " + oname

onready var collision = $CollisionShape

# The take function will always make the things desapear, so lets leave it here
func take():
	visible = false
	collision.disabled = true

func examine():
	return description
