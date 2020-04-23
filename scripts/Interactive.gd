extends Spatial

# In the future, this should be the base class for all interactive objects
# Ideally, there would be a couple of 
onready var written_text
onready var position = self.transform.origin
onready var description = "It is just a " + name.to_lower()
onready var takeable = false

onready var collision = $CollisionShape

func take():
	visible = false
	collision.disabled = true
