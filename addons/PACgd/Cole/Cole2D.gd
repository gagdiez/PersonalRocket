extends Character2D

func _ready():
	oname = "Cole"
	SPEED = 200
	MINIMUM_WALKABLE_DISTANCE = 20
	
	# We want nothing to happen when we click on Cole
	main_action = ACTIONS.none
	secondary_action = ACTIONS.none
