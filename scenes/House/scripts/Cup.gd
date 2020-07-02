extends Interactive

func _ready():
	main_action = ACTIONS.take
	thumbnail = 'thumbnails/cup.png'

func take(who):
	who.walk_to(self)
	who.face_object(self)
	who.animate_until_finished("raise_hand")
	who.interact(self, 'grab')
	who.add_to_inventory(self)
	who.animate_until_finished("lower_hand")

func grab(who):
	visible = false
	interactive = false

func use_item(who, what):
	if what == get_node("../Pan"):
		who.say("Gonna combine them")
		who.remove_from_inventory(what)
