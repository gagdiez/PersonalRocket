extends Transition

func _ready():
	interaction_position = Vector3(-7, 0 , -13.89)
	
	level = get_node("../../../..")
	to = get_node("../../../Room Left")

func go_to(who):
	who.approach(self)
	who.call_function_from(self, "transition", [who])
