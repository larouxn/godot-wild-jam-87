@tool

class_name SpellText extends VBoxContainer

@export_multiline var text := "":
	set(new_text):
		text = new_text
		if cursor_text != null:
			cursor_text.text = text

@export var description := "":
	set(new_desc):
		description = new_desc
		if description_label != null:
			if description.is_empty():
				description_label.text = ""
			else:
				description_label.text = "[i](" + description + ")[/i]"

@export var on_finish := ""

@export var on_typo := ""

@export var input_manager: InputManager:
	set(new_input_manager):
		input_manager = new_input_manager
		if cursor_text != null:
			cursor_text.input_manager = input_manager

@onready var cursor_text := $CursorText as CursorText
@onready var description_label := $MarginContainer/SpellDesc as RichTextLabel


func _ready() -> void:
	# Force the setters to run so the child nodes get updated.
	text = text
	description = description
	input_manager = input_manager
