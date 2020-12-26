extends VBoxContainer
signal choice_made(idx)

func clean():
	$"..".visible = false
	
	for child in self.get_children():
		self.remove_child(child)

func show_choice(title, options):
	clean()
	
	$"..".visible = true
	
	var ttl = Label.new()
	ttl.text = title
	ttl.add_color_override("font_color", Color(0, 1, 1))
	self.add_child(ttl)
	
	var idx = 0
	for option in options:
		var lb = LinkButton.new()
		lb.text = option.text
		lb.underline = LinkButton.UNDERLINE_MODE_NEVER
		lb.connect("pressed", self, "option_chosed", [idx])
		self.add_child(lb)
		idx += 1

func option_chosed(idx):
	clean()

	emit_signal("choice_made", idx)
