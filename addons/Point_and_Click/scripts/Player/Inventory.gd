class_name Inventory

var ACTIONS = preload("../Actions/Actions.gd").new()
var items = []
signal item_added
signal item_removed

func add(obj):
	obj.main_action = ACTIONS.use_item
	obj.secondary_action = ACTIONS.examine

	items.append(obj)
	emit_signal("item_added", obj)
	
func remove(obj):
	items.erase(obj)
	emit_signal("item_removed", obj)

func size():
	return len(items)

func get(idx):
	return items[idx]
