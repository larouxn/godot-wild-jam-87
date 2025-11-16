class_name TextState

var text := ""
var input_index := 0
var mistake_index := -1


func check_character(chr: String) -> bool:
	if input_index >= len(text):
		return false

	return chr == text[input_index]


func append_character(chr: String) -> void:
	if input_index >= len(text):
		return

	if chr != text[input_index] && mistake_index == -1:
		mistake_index = input_index

	input_index += 1


func backspace() -> void:
	if input_index < 1:
		return

	input_index -= 1
	if input_index <= mistake_index:
		mistake_index = -1


func reset() -> void:
	input_index = 0
	mistake_index = -1


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
