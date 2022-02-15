extends Character

func _ready():
	animation_player = $Animations
	talk_bubble_offset = Vector3(0, 9.7, 0)
	interaction_position = self.transform.origin + Vector3(5, 0, 0)

func talk_to(who):
	who.approach(self)
	who.emit_message("arrived")
	
	wait_on_character(who, "arrived")
	say("Hi " + who.name)
