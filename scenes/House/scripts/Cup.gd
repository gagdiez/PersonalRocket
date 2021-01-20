extends Interactive

func _ready():
	main_action = ACTIONS.take
	thumbnail = 'thumbnails/cup.png'

func use_item(who, what):
	if what == get_node("../Pan"):
		who.say("Gonna combine them")
		who.remove_from_inventory(self)
	else:
		who.say("I don't know how to combine " + self.oname + " with " + what.oname)
