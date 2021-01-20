extends Character

func _ready():
	._ready()
	animation_player = $Animations
	
	talk_bubble = $"Talk Bubble"
	talk_bubble.visible = false
	
	talk_bubble_timer = $"Talk Bubble/Timer"

	talk_bubble_offset = Vector3(-.6, 9.5, 0)

	interaction_position = self.transform.origin + Vector3(5, 0, 0)

func talk_to(who):
	who.approach(self)
	who.emit_message("arrived")
	
	wait_on_character(who, "arrived")
	say("Hi " + who.name)
