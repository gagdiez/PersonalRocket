extends "res://scenes/Point_and_Click/scripts/CutScene.gd"

func start():
	var cole = get_node("../../Cole")
	var shadow_cole = get_node("../../Shadow Cole")
	var cup = get_node("../../House/Living/Interactive/Cup")

	scene_actions = [
		PlayerAction.new(cole, ACTIONS.walk_to, shadow_cole),
		PlayerAction.new(cole, ACTIONS.say, "Hi Shadow Cole"),
		PlayerAction.new(shadow_cole, ACTIONS.say, "What's up?"),
		PlayerAction.new(cole, ACTIONS.say, "Not much, this is the intro"),
		PlayerAction.new(shadow_cole, ACTIONS.say, "Best intro ever"),
		PlayerAction.new(cole, ACTIONS.say, "I know, right?"),
		PlayerAction.new(cole, ACTIONS.say, "Gotta go to take the cup"),
		PlayerAction.new(cole, ACTIONS.take, cup),
		PlayerAction.new(cole, ACTIONS.say, "Sweeeet"),
	]

	.play()
