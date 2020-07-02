extends Transition

func _ready():
	position = Vector3(-4.157, 0 , -14.09)
	
	level = get_node("../../../..")
	to = get_node("../../../Living")

func go_to(who):
	who.approach(self)
	who.interact(self, "transition")
