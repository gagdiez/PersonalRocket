extends PACCharacter

func _ready():
	id = "cole"
	display_name = "Cole"

	# Cole is the character the player controls
	is_player = true

	# How he moves
	speed = 5.0
	minimum_walkable_distance = 0.5

	# His speech is shown above his head
	speech_offset = Vector3(0, 9.7, 0)

	# Clicking on Cole does nothing
	main_action = null
	secondary_action = null
