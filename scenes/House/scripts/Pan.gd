extends Interactive

func _ready():
	main_action = ACTIONS.take
	position = self.transform.origin + Vector3(3, 0, 0)
	thumbnail = 'thumbnails/pan.png'

func take(who):
	who.walk_to(self)
	who.animate_until_finished("raise_hand")
	who.interact(self, 'grab')
	who.add_to_inventory(self)
	who.animate_until_finished("lower_hand")

func grab(who):
	visible = false
	interactive = false
