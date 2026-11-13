extends PACCharacter

# Shadow Cole is Cole's scene (inherited) with another spritesheet and this
# script. Clicking on him makes Cole talk to him (the default talk_to: Cole
# approaches, and Shadow Cole says hi)

func _ready():
	id = "shadow_cole"
	display_name = "Shadow Cole"

	# His speech is shown above his head
	speech_offset = Vector3(0, 9.7, 0)
