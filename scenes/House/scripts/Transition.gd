extends Interactive

class_name Transition

var to
var level

func _ready():
	main_action = ACTIONS.go_to # We have only one action in the interactions

func transition(who):
	level.transition(who, to)
