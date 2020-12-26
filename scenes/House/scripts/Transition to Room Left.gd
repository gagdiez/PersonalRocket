extends Transition

func _ready():
	position = Vector3(-7, 0 , -13.89)
	
	level = get_node("../../../..")
	to = get_node("../../../Room Left")

func go_to(who):
	who.approach(self)
	who.interact(self, "transition", [who])
