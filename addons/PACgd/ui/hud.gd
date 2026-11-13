extends CanvasLayer
## The default PACgd HUD: inventory bar, dialog choices, speech, cursor label.
##
## To customise it, duplicate ui/hud.tscn (and this script if needed), change
## it, and set Project Settings > pac/hud_scene to your copy. A HUD must keep
## the signals and public functions of this script.

signal item_hovered(item: PACInteractive)  # null when the mouse leaves the item
signal item_clicked(item: PACInteractive, button_index: int)
signal choice_made(idx: int)

const ITEM_SIZE = Vector2(48, 48)

@onready var slots: GridContainer = $Inventory/Slots
@onready var dialog: Panel = $Dialog
@onready var choices: VBoxContainer = $Dialog/Choices
@onready var speech_layer: Control = $Speech
@onready var cursor_label: Label = $CursorLabel

var inventory: PACInventory
var speeches := {}  # character -> Label


func _process(_delta) -> void:
	# Speech follows the characters
	for character in speeches.keys():
		var label: Label = speeches[character]
		if not is_instance_valid(character) or not character.is_inside_tree():
			label.queue_free()
			speeches.erase(character)
			continue
		label.position = character.speech_screen_position() - Vector2(label.size.x / 2, 0)


# Inventory
func show_inventory(new_inventory: PACInventory) -> void:
	if inventory:
		inventory.item_added.disconnect(_rebuild_inventory)
		inventory.item_removed.disconnect(_rebuild_inventory)
	inventory = new_inventory
	inventory.item_added.connect(_rebuild_inventory)
	inventory.item_removed.connect(_rebuild_inventory)
	_rebuild_inventory()


func _rebuild_inventory(_item = null) -> void:
	for child in slots.get_children():
		slots.remove_child(child)
		child.queue_free()
	item_hovered.emit(null)

	for item in inventory.items:
		var slot = TextureRect.new()
		slot.texture = item.thumbnail
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.custom_minimum_size = ITEM_SIZE
		slot.mouse_entered.connect(item_hovered.emit.bind(item))
		slot.mouse_exited.connect(item_hovered.emit.bind(null))
		slot.gui_input.connect(_on_slot_input.bind(item))
		slots.add_child(slot)


func _on_slot_input(event: InputEvent, item: PACInteractive) -> void:
	if event is InputEventMouseButton and not event.pressed:
		item_clicked.emit(item, event.button_index)


# Cursor label
func set_cursor_label(text: String, mouse_position: Vector2) -> void:
	cursor_label.text = text
	cursor_label.position = mouse_position + Vector2(8, 8)


# Speech
func say(character, text: String) -> void:
	var label: Label = speeches.get(character)
	if label == null:
		label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		speech_layer.add_child(label)
		speeches[character] = label
	label.text = text
	label.reset_size()
	label.position = character.speech_screen_position() - Vector2(label.size.x / 2, 0)


func quiet(character) -> void:
	var label: Label = speeches.get(character)
	if label:
		label.queue_free()
		speeches.erase(character)


## What a character is currently saying ("" if nothing)
func get_speech(character) -> String:
	return speeches[character].text if speeches.has(character) else ""


# Choices
func show_choice(title: String, options: Array) -> void:
	_clear_choices()
	dialog.visible = true

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", Color(0, 1, 1))
	choices.add_child(title_label)

	for idx in range(options.size()):
		var option = LinkButton.new()
		option.text = options[idx].text
		option.underline = LinkButton.UNDERLINE_MODE_NEVER
		option.pressed.connect(choose_option.bind(idx))
		choices.add_child(option)


## Picks one of the options of the choice being shown
func choose_option(idx: int) -> void:
	_clear_choices()
	choice_made.emit(idx)


func _clear_choices() -> void:
	dialog.visible = false
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
