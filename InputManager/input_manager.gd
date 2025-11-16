extends Node3D

var text := ""

@onready var label := $Label as Label


func handle_key(key: String) -> void:
	if key == "backspace":
		text = text.left(-1)
	else:
		text += key

	label.text = text


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		var e := event as InputEventKey
		var key := PackedByteArray([e.unicode]).get_string_from_ascii()
		print("key: " + key)

		if e.keycode == KEY_BACKSPACE:
			key = "backspace"

		if e.keycode == KEY_ENTER:
			key = "\n"

		if e.is_echo():
			if key == "backspace":
				handle_key(key)
		else:
			handle_key(key)
