class_name PACAction
extends Resource
## A verb the player can use on things: "Examine", "Take", "Use ... with ...".
##
## Built-in verbs live in addons/PACgd/actions/*.tres. To create your own,
## create a new PACAction resource, set its label and method, and implement
## that method in your PACInteractive scripts. Register it with
## PAC.register_action() to also use it in cutscenes.

enum Type {
	## Delegated to the target: "take box" -> box.take(player)
	INTERACTIVE,
	## Needs a second object: "use key with door" -> door.use_item(player, key)
	TO_COMBINE,
	## Executed by the character itself: "say hi" -> player.say("hi")
	IMMEDIATE,
	## Changes the character's variables or calls its functions (cutscenes)
	INTERNAL,
}

## Text shown next to the mouse, i.e. "Take"
@export var label := ""
## Method called when the action is executed
@export var method: StringName
@export var type := Type.INTERACTIVE
## For TO_COMBINE actions, the word joining both objects, i.e. "with", "to"
@export var nexus := ""


func execute(who, target, with_item = null) -> void:
	if method == &"":
		return

	match type:
		Type.INTERACTIVE:
			_call(target, [who])
		Type.TO_COMBINE:
			if with_item != null and with_item != target:
				_call(target, [who, with_item])
		Type.IMMEDIATE:
			_call(who, [target])
		Type.INTERNAL:
			if target is Array:
				who.internal(method, target)
			else:
				push_error("Action '%s' expects an array of parameters" % method)


func _call(object, args: Array) -> void:
	if object.has_method(method):
		object.callv(method, args)
	else:
		push_error("%s does not implement '%s'" % [object, method])
