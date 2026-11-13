class_name PACInventory
extends RefCounted
## The objects a character carries.
##
## Taken objects leave the level and are kept (hidden and disabled) under the
## PAC autoload, so they survive level changes. Removing an object from the
## inventory puts it back in the current level, still hidden.

signal item_added(item: PACInteractive)
signal item_removed(item: PACInteractive)

const USE_ITEM = preload("res://addons/PACgd/actions/use_item.tres")
const EXAMINE = preload("res://addons/PACgd/actions/examine.tres")

var items: Array[PACInteractive] = []


func add(item: PACInteractive) -> void:
	# In the inventory: left click uses it with something, right click examines
	item.main_action = USE_ITEM
	item.secondary_action = EXAMINE

	# Take it out of the level, so it is not freed when the level changes, and
	# disable it, so it is not processed nor collides with anything
	item.reparent(PAC)
	item.process_mode = Node.PROCESS_MODE_DISABLED

	items.append(item)
	item_added.emit(item)


func remove(item: PACInteractive) -> void:
	items.erase(item)
	item.reparent(PAC.get_tree().current_scene)
	item.process_mode = Node.PROCESS_MODE_INHERIT
	item_removed.emit(item)


func has(item: PACInteractive) -> bool:
	return item in items


func size() -> int:
	return items.size()


func get_item(idx: int) -> PACInteractive:
	return items[idx]


func find(id: String) -> PACInteractive:
	for item in items:
		if item.id == id:
			return item
	return null
