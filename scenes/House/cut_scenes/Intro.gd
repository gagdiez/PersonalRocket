extends "res://scenes/Point_and_Click/scripts/CutScene.gd"

func init():
	var cole = get_node("../../Cole")
	var shadow_cole = get_node("../../Shadow Cole")
	var cup = get_node("../../House/Living/Interactive/Cup")

	var c2o1 = Option.new("What is life?",
						  [PlayerAction.new(cole, ACTIONS.say, "What is life?"),
						   PlayerAction.new(shadow_cole, ACTIONS.say, "I don't know")])
	var c2o2 = Option.new("What is love?",
					  [PlayerAction.new(cole, ACTIONS.say, "What is love?"),
					   PlayerAction.new(shadow_cole, ACTIONS.say, "Baby don't hurt me")])
	var c2o3 = Option.new("Nevermind",
					  [PlayerAction.new(cole, ACTIONS.say, "Nevermind"),
					   PlayerAction.new(shadow_cole, ACTIONS.say, "Dude, tell me how you are doing")],
					   null, true)
					
	var c1o1 = Option.new("Cool",
						  [PlayerAction.new(cole, ACTIONS.say, "Cool"),
						   PlayerAction.new(shadow_cole, ACTIONS.say, "Come on..")])
	var c1o2 = Option.new("Actually...",
						  [PlayerAction.new(cole, ACTIONS.say, "Actually..."),
						   Choice.new([c2o1, c2o2, c2o3], self, choice_gui)])
	var c1o3 = Option.new("Lets talk about something else",
						  [PlayerAction.new(cole, ACTIONS.say, "Move on")],
						  null, true)

	var choice1 = Choice.new([c1o1, c1o2, c1o3], self, choice_gui)

	scene_actions = [
		PlayerAction.new(cole, ACTIONS.walk_to, shadow_cole),
		PlayerAction.new(shadow_cole, ACTIONS.say, "How do you feel?"),
		choice1,
		PlayerAction.new(cole, ACTIONS.say, "You liking the intro so far?"),
		PlayerAction.new(shadow_cole, ACTIONS.say, "Best intro ever"),
		PlayerAction.new(cole, ACTIONS.say, "I know, right?"),
		PlayerAction.new(cole, ACTIONS.say, "Gotta go to take the cup"),
		PlayerAction.new(cole, ACTIONS.take, cup),
		PlayerAction.new(cole, ACTIONS.say, "Sweeeet"),
	]
