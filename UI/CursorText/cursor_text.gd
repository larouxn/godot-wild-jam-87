@tool

class_name CursorText extends MarginContainer

const CURSOR_TEXT := "[pulse freq=5.0 color=#ffffff40 ease=-5.0][b]|[/b][/pulse]"

@export_group("CursorText")

## The raw text of the label. If you've linked a TextState to this CursorText, you
## probably don't want to set this directly. Instead, use set_text_lines or
## set_text_words.
@export_multiline var text := "":
	set(new_text):
		text = new_text
		if text_label != null:
			text_label.text = new_text

## The position of the cursor respresented as xy-coordinates. x is the column the
## cursor is on, and y is the row.
@export var cursor_position := Vector2i(0, 0):
	set(new_cursor_position):
		cursor_position = new_cursor_position
		update_cursor()

## The font size. This will get propagated to all variants of the font (regular,
## bold, italic, etc.). The cursor's bold font variant will bigger, with a size
## of font_size + 10. The bold font is what the cursor is intended to be drawn
## with.
##
## If you change the font size, you may also need to adjust the cursor offset to
## look right.
@export var font_size := 45:
	set(new_font_size):
		font_size = new_font_size
		update_font_size()

## The offset of the cursor from the text represented as xy-coordinates. x is the
## cursor's offset from the left of the text and y is the offset from the top.
##
## This is set to a reasonable default but may need to be adjusted when changing
## the font size.
@export var cursor_offset := Vector2i(-14, -7):
	set(new_cursor_offset):
		cursor_offset = new_cursor_offset
		update_cursor_offset()

@export_group("InputManager Link")

## The InputManager used in this scene. This must be set if you are using the
## link_text_state functions.
@export var input_manager: InputManager

## The text state linked to this UI element.
var linked_text_state: TextState

## The text of the linked_text_state represented as an array of lines.
var linked_text_state_lines: PackedStringArray

## The text of the linked_text_state represented as an array of words.
var linked_text_state_words: PackedStringArray

@onready var cursor := $Cursor as RichTextLabel
@onready var text_label := $MarginContainer/Text as RichTextLabel
@onready var text_margin := $MarginContainer as MarginContainer


func _ready() -> void:
	update_cursor()
	update_font_size()
	update_cursor_offset()


func update_cursor() -> void:
	if cursor == null:
		return

	cursor.text = "\n".repeat(cursor_position.y)
	cursor.text += " ".repeat(cursor_position.x) + CURSOR_TEXT


func update_font_size() -> void:
	if cursor == null or text_label == null:
		return

	var size_keys: PackedStringArray = ["normal", "bold", "bold_italics", "italics", "mono"]

	for key in size_keys:
		text_label.set("theme_override_font_sizes/" + key + "_font_size", font_size)

	cursor.set("theme_override_font_sizes/normal_font_size", font_size)
	cursor.set("theme_override_font_sizes/bold_font_size", font_size + 10)

	# Leave some room at the end of the text for the cursor to hang over.
	text_margin.set("theme_override_constants/margin_right", get_cursor_size().x * 1.5)


func update_cursor_offset() -> void:
	if text_margin == null:
		return

	# We invert the offset parameters because this is really offsetting the text,
	# not the cursor.
	text_margin.set("theme_override_constants/margin_left", -1 * cursor_offset.x)
	text_margin.set("theme_override_constants/margin_top", -1 * cursor_offset.y)


## Calculate the number of characters that will fit on a single line of this
## CursorText. This takes the size of this CursorText as well as the font size
## into account.
func get_characters_per_line() -> int:
	var font: Font = text_label.get("theme_override_fonts/normal_font")
	var fsize: int = text_label.get("theme_override_font_sizes/normal_font_size")
	var char_width := font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x

	var margin_left: int = text_margin.get("theme_override_constants/margin_left")
	var margin_right: int = text_margin.get("theme_override_constants/margin_right")
	var container_width := text_margin.size.x - margin_left - margin_right

	return floor(container_width / char_width)


## Get the size of the cursor. This is different from the size of other characters
## since the cursor is using a bigger font.
func get_cursor_size() -> Vector2:
	var font: Font = cursor.get("theme_override_fonts/bold_font")
	var fsize: int = cursor.get("theme_override_font_sizes/bold_font_size")
	return font.get_string_size("|", HORIZONTAL_ALIGNMENT_LEFT, -1, fsize)


## Convert an array of words into an array of lines based on the measured number
## of characters that will fit on a line inside this CursorText.
##
## This is just a wrapper around words_to_lines_of_words that joins the nested
## arrays into strings.
func words_to_lines(words: PackedStringArray) -> PackedStringArray:
	return words_to_lines_of_words(words).map(
		func(word_line: PackedStringArray) -> String: return "".join(word_line)
	)


## Convert an array of words into an array of arrays of words, where each nested
## array corresponds to a visual line in the UI. The lines are based on the
## measured number of characters that will fit on a line inside this CursorText.
##
## Note that character counting around spaces is a little sloppy. A line will
## never be longer than what would fit, but may wrap earlier than necessary if
## spaces were counted towards the text length but trimmed from the final line.
func words_to_lines_of_words(words: PackedStringArray) -> Array[PackedStringArray]:
	var line_length := get_characters_per_line()

	var result: Array[PackedStringArray] = []
	var current: PackedStringArray = []
	for word in words:
		var current_str := "".join(current)
		if len(word) >= line_length:
			if !current_str.is_empty():
				result.append(current)
			result.append([word])
			current = []
		elif len(word) + len(current_str) > line_length:
			result.append(current)
			current = [word]
		else:
			current.append(word)

	if !current.is_empty():
		result.append(current)

	return result


## Given an index into the text and the lines of the text as an array, return the
## position of the cursor as xy-coordinates suitable for cursor_position.
func cursor_position_from_lines(index: int, lines: PackedStringArray) -> Vector2i:
	var current_line := 0
	var cumulative_length := 0
	var last_line := ""
	for line in lines:
		var line_len := len(line)
		if index <= line_len + cumulative_length:
			last_line = line
			break
		else:
			cumulative_length += line_len + 1
			current_line += 1

	var space_prefix_offset := len(last_line) - len(last_line.strip_edges(true, false))
	return Vector2i(max(0, index - cumulative_length - space_prefix_offset), 0)


## The same as cursor_position_from_lines, but sets the cursor_position instead of
## returning the coordinates.
func set_cursor_position_from_lines(index: int, lines: PackedStringArray) -> void:
	cursor_position = cursor_position_from_lines(index, lines)


## Set the text of this CursorText to the given array of lines joined with a
## newline character.
##
## If linked to a TextState, also update the TextState's text.
##
## Note that, unless keep_words is true, this clears linked_text_state_words
## since there is no easy way to deduce the inteded words (as the text
## generator output them) from entire lines.
func set_text_lines(new_text_lines: PackedStringArray, keep_words: bool = false) -> void:
	if linked_text_state != null:
		linked_text_state.text = "\n".join(new_text_lines)
		linked_text_state_lines = new_text_lines
		if !keep_words:
			linked_text_state_words = []
		render_linked_text(linked_text_state.id)
	else:
		text_label.text = "\n".join(new_text_lines)


## Set the text of this CursorText to the given array of words. Unlike set_text_lines,
## this will also properly set linked_text_state_words.
##
## If linked to a TextState, also update the TextState's text.
func set_text_words(words: PackedStringArray) -> void:
	if linked_text_state != null:
		linked_text_state_words = []
		for line in words_to_lines_of_words(words):
			linked_text_state_words.append_array(line)
			linked_text_state_words.append("\n")
		if !linked_text_state_words.is_empty():
			# Remove trialing newline
			linked_text_state_words.remove_at(linked_text_state_words.size() - 1)

	set_text_lines(words_to_lines(words), true)


## Show the cursor.
func show_cursor() -> void:
	cursor.show()


## Hide the cursor.
func hide_cursor() -> void:
	cursor.hide()


## Toggle the visibility of the cursor.
func toggle_cursor() -> void:
	cursor.visible = !cursor.visible


## Return the position of the current word in linked_text_state_words as a two-element array.
##
##   - 0: The index of the current word in linked_text_state_words
##   - 1: The index within the current word
func get_word_indices(index: int = -1) -> Array[int]:
	assert(
		!linked_text_state_words.is_empty(), "Cannot call get_word_indices where there are no words"
	)
	assert(
		index != -1 or linked_text_state != null,
		"You must either pass an index or have a linked TextState"
	)

	if index == -1:
		index = linked_text_state.input_index

	var ix := 0
	var cumulative_length := 0
	for word in linked_text_state_words:
		if len(word) + cumulative_length > index:
			return [ix, index - cumulative_length]
		cumulative_length += len(word)
		ix += 1

	return [-1, -1]


## Link a TextState to this CursorText. This will set the text of the TextState
## to the array of words passed in and wire up signals to update this UI component
## whenever the TextState text or the set of texts receiving input changes.
##
## To treat the array of words as an array of lines instead, pass words_is_lines = true.
func link_text_state(
	text_state: TextState, words: PackedStringArray, words_is_lines: bool = false
) -> void:
	assert(input_manager != null, "InputManager must be attached to link a text state")
	assert(
		input_manager.main_text == text_state or text_state in input_manager.side_texts,
		"TextState must be managed by the attached InputManager"
	)
	# I just don't want to implement it right now...
	assert(linked_text_state == null, "linked_text_state cannot be reassigned")

	linked_text_state = text_state
	if words_is_lines:
		set_text_lines(words)
	else:
		set_text_words(words)

	# Re-render the UI whenever the TextState text changes.
	linked_text_state.updated.connect(render_linked_text)

	linked_text_state.lock_changed.connect(
		func(id: int, _locked: bool) -> void: render_linked_text(id)
	)

	# When the set of texts receiving input changes, check if our linked TextState
	# is receiving input. If so, show the cursor; if not, hide it.
	input_manager.active_texts_changed.connect(
		func(active_texts: Array[TextState]) -> void:
			cursor.visible = linked_text_state in active_texts
	)

	# Check if the text we are linking is currently receiving input. If not, hide
	# the cursor.
	if !input_manager.is_text_active(linked_text_state):
		cursor.visible = false


## Like link_text_state but also creates the TextState and registers it with the
## InputManager automatically. The text of TextState is initialized with the array
## of words passed in.
##
## To treat the array of words as an array of lines instead, pass words_is_lines = true.
##
## By default, the TextState is registered as a side-text. To register it as the
## main text instead, set the is_main_text parameter to true.
##
## Returns the newly created TextState.
func create_and_link_text_state(
	words: PackedStringArray, is_main_text: bool = false, words_is_lines: bool = false
) -> TextState:
	assert(input_manager != null, "InputManager must be attached to link a text state")

	var text_state := TextState.new()

	if is_main_text:
		input_manager.set_main_text(text_state)
	else:
		input_manager.register_side_text(text_state)

	link_text_state(text_state, words, words_is_lines)

	return text_state


## Like create_and_link_text_state but expects a single line of text as input. It
## will create a TextState that expects the given line followed by a newline to
## trigger the finished signal.
##
## It is a shortcut for calling: create_and_link_text_state([line, ""], false, true)
##
## Can register as the main text by passing is_main_text = true.
func create_and_link_one_line_text_state(line: String, is_main_text: bool = false) -> TextState:
	return create_and_link_text_state([line, ""], is_main_text, true)


## Render the linked TextState to the screen by writing to the RichTextLabel and
## moving the cursor to the right position.
func render_linked_text(_id: int) -> void:
	var parts := linked_text_state.parts()

	# Replace series of spaces + newline with just a newline.
	var pattern := RegEx.new()
	pattern.compile(" *\n *")

	parts[0] = pattern.sub(parts[0], "\n", true)
	if parts[0].ends_with("\n"):
		parts[1] = parts[1].strip_edges(true, false)
		if parts[1].is_empty():
			parts[2] = parts[2].strip_edges(true, false)

	parts[1] = pattern.sub(parts[1], "\n", true)
	if parts[1].ends_with("\n"):
		parts[2].strip_edges(true, false)

	parts[2] = pattern.sub(parts[2], "\n", true)
	parts[2] = parts[2].strip_edges(false, true)

	var good := "[color=#00ff00]" + parts[0] + "[/color]"
	var mistake := "[color=#ff0000][u]" + parts[1] + "[/u][/color]"
	var untyped := "[color=#999999]" + parts[2] + "[/color]"
	text = good + mistake + untyped
	text_label.material.set_shader_parameter(
		"enabled", linked_text_state.is_locked() and linked_text_state.is_mistyped()
	)

	set_cursor_position_from_lines(linked_text_state.input_index, linked_text_state_lines)
