extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add(obj):
	var new_item = TextureRect.new()
	new_item.texture = load(obj.thumbnail)
	$Slots.add_child(new_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
