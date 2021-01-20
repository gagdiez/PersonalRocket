extends Panel

const ITEM_SIZE = Vector2(48, 48)
onready var SLOT_SIZE = $Slots.get_constant("hseparation") + ITEM_SIZE.x

var inventory_to_follow

func follow(inventory:Inventory):
	if inventory_to_follow:
		inventory_to_follow.disconnect("item_added", self, "item_added")
		inventory_to_follow.disconnect("item_removed", self, "item_removed")
	
	inventory_to_follow = inventory
	inventory_to_follow.connect("item_added", self, "item_added")
	inventory_to_follow.connect("item_removed", self, "item_removed")
	
	for item in inventory.items:
		item_added(item)

func position_contained(position: Vector2):
	var top = position.y > $Slots.margin_top
	var bottom = position.y < $Slots.margin_bottom - $Slots.margin_top
	return top and bottom

func get_object_in_position(position: Vector2):
	var item_idx = int(floor(position.x / SLOT_SIZE))
	var modulus = fmod(position.x, SLOT_SIZE)

	if modulus > $Slots.margin_left and item_idx < inventory_to_follow.size():
		return inventory_to_follow.get(item_idx)
	else:
		return null

func item_added(item):
	var texturerect = TextureRect.new()
	texturerect.texture = load(item.thumbnail)
	texturerect.rect_size = ITEM_SIZE
	$Slots.add_child(texturerect)

func item_removed(item):
	for child in $Slots.get_children():
		$Slots.remove_child(child)
	follow(inventory_to_follow)
