extends PACInteractive

func _ready():
	id = "room"

	main_action = PAC.actions.go_to


func go_to(who):
	who.approach(self)
	self.run(get_tree().current_scene.transition.bind(who, $"../../../Room Left"))
