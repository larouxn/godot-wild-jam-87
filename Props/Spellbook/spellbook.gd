class_name Spellbook extends Node3D

@export var main_text_ui: CursorText
@export var input_manager: InputManager

var spells: Dictionary[String, TextState] = {}
var spells_ui: Dictionary[String, SpellText] = {}

var book_is_floating := false

var control_root: VBoxContainer

@onready var animation_player := $Book/AnimationPlayer as AnimationPlayer
@onready var ui := $ControlView3D as ControlView3D


func _ready() -> void:
	_init_nodes.call_deferred()


func _init_nodes() -> void:
	control_root = ui.get_control_node("VBoxContainer")

	input_manager.input_state_changed.connect(
		func(input_state: InputManager.InputState) -> void:
			if input_state == InputManager.InputState.MAIN_TEXT:
				fall()
			else:
				rise()
	)

	for child in control_root.get_children():
		if child is SpellText:
			child.input_manager = input_manager
			spells[child.name] = child.cursor_text.create_and_link_one_line_text_state(child.text)
			spells_ui[child.name] = child

			spells[child.name].finished.connect(
				func(_id: int) -> void: _on_spell_finished(child.on_finish)
			)

			spells[child.name].mistyped.connect(
				func(_id: int) -> void: _on_spell_mistyped(spells[child.name], child.on_typo)
			)


func rise() -> void:
	if !book_is_floating:
		book_is_floating = true
		animation_player.play("rise")
		animation_player.queue("hover")


func fall() -> void:
	if book_is_floating:
		book_is_floating = false
		animation_player.play("fall", 0.3)


func lock_spell(spell: TextState, seconds: float) -> void:
	spell.lock()
	await get_tree().create_timer(seconds).timeout
	spell.unlock()


func lock_main() -> void:
	input_manager.main_text.lock()
	await get_tree().create_timer(0.5).timeout
	input_manager.main_text.unlock()


func _on_spell_finished(callback_name: String) -> void:
	Callable(self, callback_name).call()
	input_manager.set_active_text(input_manager.main_text)


func _on_spell_mistyped(spell: TextState, callback_name: String) -> void:
	lock_spell(spell, 10)
	lock_main()
	Callable(self, callback_name).call()
	input_manager.set_active_text(input_manager.main_text)


func _on_shorten_words_finished() -> void:
	var words_to_change := 30
	modify_remaining_words(
		func(words: PackedStringArray) -> PackedStringArray:
			var text_pattern := RegEx.new()
			text_pattern.compile("[a-zA-Z]")

			var symbol_at_end_pattern := RegEx.new()
			symbol_at_end_pattern.compile("[^a-zA-Z]+$")

			var ix := 1  # skip end of current word
			var changes_left := words_to_change
			while ix < words.size() and changes_left > 0:
				var word := words[ix]
				if text_pattern.search(word) != null:
					var trailing_symbols := symbol_at_end_pattern.search(word)
					var new_len: int = max(2, floor(len(word) * 0.4))
					words[ix] = word.left(new_len)
					if trailing_symbols != null:
						words[ix] += trailing_symbols.get_string()

					changes_left -= 1

				ix += 1

			return words
	)


func _on_shorten_words_mistyped() -> void:
	pass


func _on_remove_punctuation_finished() -> void:
	# Assuming 10 characters per word, the next 30 words.
	var chars_to_change := 30 * 10
	modify_remaining_words(
		func(words: PackedStringArray) -> PackedStringArray:
			var pattern := RegEx.new()
			pattern.compile("[^a-zA-Z0-9 \\n]")

			var chars_left := chars_to_change
			var ix := 1  # skip end of current word
			while ix < words.size() and chars_left > 0:
				words[ix] = pattern.sub(words[ix], "", true)
				chars_left -= len(words[ix])
				ix += 1

			return words
	)


func _on_remove_punctuation_mistyped() -> void:
	pass


func _on_remove_capital_letters_finished() -> void:
	var chars_to_change := 30 * 10
	modify_remaining_words(
		func(words: PackedStringArray) -> PackedStringArray:
			var chars_left := chars_to_change
			var ix := 0
			while ix < words.size() and chars_left > 0:
				words[ix] = words[ix].to_lower()
				chars_left -= len(words[ix])
				ix += 1

			return words
	)


func _on_remove_capital_letters_mistyped() -> void:
	pass


## Apply a function to the remaining words in the main text after the cursor.
## The function should return the new set of remaining words.
func modify_remaining_words(f: Callable) -> void:
	# Get current text and position from main text.
	var words := main_text_ui.linked_text_state_words
	var pos := main_text_ui.get_word_indices()
	var word_ix := pos[0]
	var char_ix := pos[1]

	# Get the array starting the the word we are currently on.
	var rest := words.slice(word_ix)
	var rest_orig := rest.duplicate()

	# Only give the part of the current word that's under and after the cursor.
	rest[0] = rest[0].substr(char_ix)

	# Apply user provided function to transform the rest of the text.
	var new_rest: PackedStringArray = f.call(rest)

	# Patch the first word back together.
	new_rest[0] = rest_orig[0].substr(0, char_ix) + new_rest[0]

	# Remove newlines from the output since CursorText will put them back in.
	var result: PackedStringArray = []

	var ix := 0
	while ix < word_ix:
		if words[ix] != "\n":
			result.append(words[ix])
		ix += 1

	ix = 0
	while ix < new_rest.size():
		if new_rest[ix] != "\n":
			result.append(new_rest[ix])
		ix += 1

	# Update the main text with the modified version
	main_text_ui.set_text_words(result)
