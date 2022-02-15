extends Character

func _ready():
	SPEED = 8
	MINIMUM_WALKABLE_DISTANCE = .8
	talk_bubble_offset = Vector3(0, 9.7, 0)
	
	main_action = ACTIONS.none
	secondary_action = ACTIONS.none
