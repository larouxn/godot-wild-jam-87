@tool

class_name MainTextContainer extends Sprite3D

@export_multiline var text := "":
	set(new_text):
		text = new_text
		if cursor_text != null:
			cursor_text.text = text

@export var minimum_width := 1300.0:
	set(new_width):
		minimum_width = new_width
		if cursor_text != null:
			cursor_text.custom_minimum_size.x = minimum_width

		if bg_panel != null:
			bg_panel.custom_minimum_size.x = minimum_width + bg_side_padding

@export var bg_side_padding := 100:
	set(new_padding):
		bg_side_padding = new_padding
		if bg_panel != null:
			bg_panel.custom_minimum_size.x = minimum_width + bg_side_padding

@export var input_manager: InputManager:
	set(new_input_manager):
		input_manager = new_input_manager
		if cursor_text != null:
			cursor_text.input_manager = input_manager

var old_cursor_position: Vector2i

@onready var bg_panel := %Background as Panel
@onready var text_offset := %TextOffset as MarginContainer
@onready var cursor_text := %CursorText as CursorText


func _ready() -> void:
	# Run the setters to propagate values on ready. Skip text because the cursor_text
	# will manage that itself.
	minimum_width = minimum_width
	bg_side_padding = bg_side_padding
	input_manager = input_manager

	# Update our scroll position when the cursor position changes.
	cursor_text.cursor_position_changed.connect(
		func(cursor_position: Vector2i) -> void:
			if cursor_position.y == old_cursor_position.y:
				old_cursor_position = cursor_position
				return
			old_cursor_position = cursor_position

			var line_height := cursor_text.get_line_height()
			var tween := get_tree().create_tween()
			(
				tween
				. tween_property(
					text_offset,
					"theme_override_constants/margin_top",
					-1 * cursor_position.y * line_height,
					0.25
				)
				. from_current()
				. set_trans(Tween.TRANS_ELASTIC)
			)
	)
