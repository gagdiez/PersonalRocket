extends PACInteractive

func _ready():
	id = "cup"

	main_action = PAC.actions.take
	thumbnail = preload("res://thumbnails/cup.png")


func use_item(who, item):
	if item.id == "pan":
		who.say("Gonna combine them")
		who.remove_from_inventory(self)
	else:
		who.say("I don't know how to combine " + display_name + " with " + item.display_name)
