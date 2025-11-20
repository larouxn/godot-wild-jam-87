class_name TextState

## Emitted when the text progress is updated.
signal updated(id: int)

## Emitted when a newline is matched.
signal newline(id: int)

## Emitted when the text has been completed without error.
signal finished(id: int)

## Emitted when a wrong character is entered.
signal mistyped(id: int)

## Emitted when the locked state changes.
signal lock_changed(id: int, is_locked: bool)

static var instance_counter := 0

var id := 0
var text := ""
var input_index := 0
var mistake_index := -1
var typed_since_mistake := ""
var locked := false:
	set(new_locked):
		var prev_locked := locked
		locked = new_locked
		if prev_locked != locked:
			lock_changed.emit(id, locked)


func _init(in_text: String = "") -> void:
	id = instance_counter
	instance_counter += 1

	text = in_text


## Returns whether or not the text begins with the given prefix.
func begins_with(prefix: String) -> bool:
	return text.begins_with(prefix)


## Sets the text progress to match the given prefix. This behaves as if the text
## was reset and the user typed in the prefix.
func set_prefix(prefix: String) -> void:
	if locked:
		return

	reset()
	for chr in prefix:
		append_character(chr)


## Appends a character to the current text progress.
func append_character(chr: String) -> void:
	if input_index >= len(text):
		return

	if locked:
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


## Removes the last character from the current text progress.
func backspace() -> void:
	if input_index < 1:
		return

	if locked:
		return

	input_index -= 1

	if input_index <= mistake_index:
		mistake_index = -1

	if !typed_since_mistake.is_empty():
		typed_since_mistake = typed_since_mistake.left(-1)

	updated.emit(id)


## Get the string that was typed into this TextState, including characters that
## were mistyped and not part of the original text.
func get_typed_string() -> String:
	if mistake_index == -1:
		return text.substr(0, input_index)

	return text.substr(0, mistake_index) + typed_since_mistake


## Rest the TextState and lock it.
func reset_and_lock() -> void:
	reset()
	lock()


## Lock the TextState, preventing modification.
func lock() -> void:
	locked = true


## Unlock the TextState.
func unlock() -> void:
	locked = false


## Returns whether or not the TextState is currently locked.
func is_locked() -> bool:
	return locked


## Reset all progress on the TextState. Note that the TextState cannot be reset
## if it is locked.
func reset() -> void:
	if locked:
		return

	input_index = 0
	mistake_index = -1
	typed_since_mistake = ""
	updated.emit(id)


## Returns whether or not the TextState is currently reset.
func is_reset() -> bool:
	return input_index == 0 and mistake_index == -1 and typed_since_mistake == ""


## Returns whether or not the TextState has any input mistakes.
func is_mistyped() -> bool:
	return mistake_index != -1


## Splits the text of the TextState into a three-element array:
##
##   - 0: properly type characters
##   - 1: mistyped characters
##   - 2: untyped characters
##
## These substrings will always occur in order and add up to the entirety of the
## text. In other words: text == parts()[0] + parts()[1] + parts()[2].
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
