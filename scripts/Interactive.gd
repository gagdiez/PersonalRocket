extends Spatial

# In the future, this should be the base class for all interactive objects
# Ideally, there would be a couple of 
onready var written_text
onready var position = self.transform.origin
onready var description = "It is just a " + name.to_lower()
onready var takeable = false

onready var collision = $CollisionShape

func take():
	print("I am " + self.name.to_lower() + " and somebody took me")
	visible = false
	collision.disabled = true
