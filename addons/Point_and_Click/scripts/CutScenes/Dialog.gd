extends VBoxContainer
signal choice_made

func show_choice(scene, choice):
	$"..".visible = true
	var idx = 0
	for option in choice.options:
		var lb = LinkButton.new()
		lb.text = option.text
		lb.underline = LinkButton.UNDERLINE_MODE_NEVER
		lb.connect("pressed", self, "option_chosed", [scene, choice, idx])
		self.add_child(lb)
		idx += 1

func option_chosed(scene, choice, idx):
	$"..".visible = false
	
	for child in self.get_children():
		self.remove_child(child)
	
	var option = choice.options[idx]
	
	var new_actions = option.scene_actions.duplicate(true)

	if not option.end_conversation:
		new_actions.push_back(choice)
	
	scene.scene_actions =  new_actions + scene.scene_actions
	emit_signal("choice_made")
	
