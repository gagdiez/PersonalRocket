extends "res://scenes/Point_and_Click/scripts/Interactive.gd"

var to
var level

func _ready():
	actions = [ACTIONS.go_to] # We have only one action in the interactions

func go_to(who):
	level.transition(who, to)
