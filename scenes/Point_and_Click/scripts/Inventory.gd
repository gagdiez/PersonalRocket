extends Panel

const ITEM_SIZE = 48
onready var SLOT_SIZE = $Slots.get_constant("hseparation") + ITEM_SIZE

class Item extends TextureRect:
	var object
	var usable = true
	var description
	var actions
	var oname
	
	var ACTIONS = load("res://scenes/Point_and_Click/scripts/Actions.gd").new()
	
	func _init(_object):
		object = _object
		description = _object.description
		actions = [ACTIONS.use_item, ACTIONS.examine]
		oname = _object.oname
		
		self.texture = load(_object.thumbnail)
		self.rect_size.x = ITEM_SIZE
		self.rect_size.y = ITEM_SIZE
	
	func examine():
		return description


var items = []


func position_contained(position: Vector2):
	var top = position.y > $Slots.margin_top
	var bottom = position.y < $Slots.margin_bottom - $Slots.margin_top
	return top and bottom


func get_object_in_position(position: Vector2):
	
	var item_idx = int(floor(position.x / SLOT_SIZE))
	var modulus = fmod(position.x, SLOT_SIZE)
	
	if modulus > $Slots.margin_left and item_idx < len(items):
		return items[item_idx]
	else:
		return null


func add(obj):
	var new_item = Item.new(obj)
	$Slots.add_child(new_item)
	items.append(new_item)
