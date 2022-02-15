extends RichTextLabel

onready var cole = $".."

func set_text(text: String):
	self.rect_size.x = self.get_font("font").get_string_size(text).x
	self.rect_size.y = self.get_font("font").get_string_size(text).y

	if cole is KinematicBody2D:
		self.rect_position.x = -self.rect_size.x / 2
	else:
		self.rect_position = cole.camera.unproject_position(
			cole.transform.origin + cole.talk_bubble_offset
		) - Vector2(self.rect_size.x / 2, 0)

	self.text = text
