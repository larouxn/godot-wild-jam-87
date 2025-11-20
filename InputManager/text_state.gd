class_name TextState

signal updated(id: int)
signal newline(id: int)
signal finished(id: int)
signal mistyped(id: int)

static var instance_counter := 0

var id := 0
var text := ""
var input_index := 0
var mistake_index := -1
var typed_since_mistake := ""


func _init(in_text: String = "") -> void:
	id = instance_counter
	instance_counter += 1

	text = in_text


func begins_with(prefix: String) -> bool:
	return text.begins_with(prefix)


func set_prefix(prefix: String) -> void:
	reset()
	for chr in prefix:
		append_character(chr)


func append_character(chr: String) -> void:
	if input_index >= len(text):
		return

	var chr_matches := chr == text[input_index]
	if chr == " " and text[input_index] == "\n":
		chr_matches = true

	if !chr_matches && mistake_index == -1:
		mistake_index = input_index

	input_index += 1

	if mistake_index != -1:
		typed_since_mistake += chr

	updated.emit(id)

	if chr_matches and text[input_index - 1] == "\n":
		newline.emit(id)

	if mistake_index != -1:
		mistyped.emit(id)

	if mistake_index == -1 && input_index >= len(text):
		finished.emit(id)


func backspace() -> void:
	if input_index < 1:
		return

	input_index -= 1

	if input_index <= mistake_index:
		mistake_index = -1

	if !typed_since_mistake.is_empty():
		typed_since_mistake = typed_since_mistake.left(-1)

	updated.emit(id)


func get_typed_string() -> String:
	if mistake_index == -1:
		return text.substr(0, input_index)

	return text.substr(0, mistake_index) + typed_since_mistake


func reset() -> void:
	input_index = 0
	mistake_index = -1
	typed_since_mistake = ""
	updated.emit(id)


func is_reset() -> bool:
	return input_index == 0 and mistake_index == -1 and typed_since_mistake == ""


func is_mistyped() -> bool:
	return mistake_index != -1


func parts() -> PackedStringArray:
	var good := ""
	var mistake := ""
	var untyped := text.substr(input_index, -1)

	if mistake_index == -1:
		good = text.substr(0, input_index)
	else:
		good = text.substr(0, mistake_index)
		mistake = text.substr(mistake_index, input_index - mistake_index)

	return PackedStringArray([good, mistake, untyped])
