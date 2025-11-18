class_name InputManager extends Node3D

# The current state of the input manager.
enum InputState {
	# Routing keyboard input into the main text
	MAIN_TEXT,
	# Routing keyboard input into multiple side-texts while narrowing down a match
	SELECTION,
	# Routing keyboard input into the side-text that is the current active text
	SIDE_TEXT
}

# The main text required to win the game.
var main_text: TextState

# Side texts that can be typed to complete optional objectives (e.g. lighting a
# candle or casting a spell from the spellbook).
var side_texts: Array[TextState] = []

# The text that is focused and currently receiving input (assuming we are not in
# the process of narrowing down side-texts, in which case, multiple side-texts
# may receive input at once until one is chosen as the active text).
#
# It is represented as an array to allow for "no active text" (e.g. during side-text
# selection), but it should only ever have 0 or 1 element.
#
# This always starts with the main text.
var active_text: Array[TextState] = []:
	set(new_active_text):
		assert(len(new_active_text) <= 1, "active_text should only ever have 0 or 1 element")
		active_text = new_active_text

# When we begin matching a side-text, we store the characters typed here until only
# one side-text matches this prefix, at which point it becomes the active text and
# the prefix is cleared.
var selection_prefix := ""

@onready var label := $Label as RichTextLabel


func _ready() -> void:
	main_text = TextState.new(
		(
			"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent aliquet volutpat"
			+ "\nscelerisque. Curabitur sodales nibh ipsum, dapibus aliquet enim tincidunt non."
			+ "\nPraesent et placerat nisi. Donec volutpat ut mauris a semper. Cras lorem erat,"
			+ "\nfermentum nec porttitor a, maximus sit amet mauris. Suspendisse potenti. Nunc"
			+ "\nac faucibus erat. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
			+ "\nAenean ex ex, eleifend a ligula vel, suscipit tempus libero. Proin tristique"
			+ "\nmagna cursus, porttitor ipsum tempus, lacinia leo. Cras eu lacus volutpat,"
			+ "\ngravida tellus sed, pretium tellus. Sed ipsum arcu, sollicitudin in tortor in,"
			+ "\nporta pellentesque dui. Vestibulum ante ipsum primis in faucibus orci luctus"
			+ "\net ultrices posuere cubilia curae;"
		)
	)

	set_active_text(main_text)

	var candle_text := TextState.new("<light candle")
	var spell1_text := TextState.new("@Bhippopotomonstrosesquippedaliophobia")
	var spell2_text := TextState.new(
		(
			'@B\'hold, thus denoted! Word stops--variety, yes!--and yet "meaning" lacks. '
			+ "Cease; punctuate (as you will); stop? & yet more!"
		)
	)
	var spell3_text := TextState.new("@To ALSO Capitalize the Words Or Else")
	var spell4_text := TextState.new("@B'held")

	side_texts.append_array([candle_text, spell1_text, spell2_text, spell3_text, spell4_text])
	for text in side_texts:
		text.mistyped.connect(func(id: int) -> void: print("mistake on: " + str(id)))
		text.finished.connect(func(id: int) -> void: print("finished: " + str(id)))

	render_ui()


func handle_key(key: String) -> void:
	if key == "backspace":
		backspace()
	elif key == "tab" or key == "escape":
		set_active_text(main_text)
	else:
		route_char(key)

	render_ui()


func set_active_text(new_active_text: TextState) -> void:
	active_text = [new_active_text]
	selection_prefix = ""
	for text in side_texts:
		if text.id != new_active_text.id:
			text.reset()


func unset_active_text() -> void:
	active_text = []


func get_text_candidates_matching_prefix(prefix: String) -> Array[TextState]:
	return side_texts.filter(
		func(candidate: TextState) -> bool: return candidate.begins_with(prefix)
	)


# Return whether the input manager is in the SELECTION state
func is_input_state_selection() -> bool:
	return active_text.is_empty() and !selection_prefix.is_empty()


# Return whether the input manager is in the MAIN_TEXT state
func is_input_state_main_text() -> bool:
	var active_is_main := !active_text.is_empty() and active_text[0].id == main_text.id
	var prefix_is_empty := selection_prefix.is_empty()
	var side_texts_are_reset := true
	for text in side_texts:
		side_texts_are_reset = side_texts_are_reset and text.is_reset()

	return active_is_main and prefix_is_empty and side_texts_are_reset


# Return whether the input manager is in the SIDE_TEXT state
func is_input_state_side_text() -> bool:
	if active_text.is_empty():
		return false

	var active_isnt_main := active_text[0].id != main_text.id
	var prefix_is_empty := selection_prefix.is_empty()
	var other_side_texts_are_reset := true
	for text in side_texts:
		if text.id != active_text[0].id:
			other_side_texts_are_reset = other_side_texts_are_reset and text.is_reset()

	return active_isnt_main and prefix_is_empty and other_side_texts_are_reset


# Return the current state the input manager is in.
#
# It is possible that it is not in any known state (due to stateful variables
# being set wrong or getting out of sync due to a bug). If this happens, this
# function will call `assert` to throw us into a debugger. In a production build,
# the game would just exit.
func get_input_state() -> InputState:
	if is_input_state_selection():
		return InputState.SELECTION

	if is_input_state_main_text():
		return InputState.MAIN_TEXT

	if is_input_state_side_text():
		return InputState.SIDE_TEXT

	assert(false, "Invalid state when determining InputState")
	get_tree().quit()
	# This is just here to typecheck; the program will exit without ever hitting
	# this line.
	return InputState.MAIN_TEXT


# Handle the backspace keypress.
#
# Aside from just removing the last typed character of a text, this can
# transition us from:
#
#   - SELECTION -> MAIN_TEXT
#   - SIDE_TEXT -> SELECTION
#   - SIDE_TEXT -> MAIN_TEXT
func backspace() -> void:
	var input_state := get_input_state()

	if input_state == InputState.SELECTION:
		selection_prefix = selection_prefix.left(-1)
		# If backspacing causes the selection prefix to be empty, abort selection and
		# set the active text back to the main text.
		if selection_prefix.is_empty():
			set_active_text(main_text)
		else:
			# Otherwise, it is possible backspacing the selection prefix caused other
			# side-texts to become viable options. Iterate through candidates and sync
			# them with the selection prefix.
			for candidate in get_text_candidates_matching_prefix(selection_prefix):
				candidate.set_prefix(selection_prefix)
	elif input_state == InputState.SIDE_TEXT:
		# If we are already in an active side-text, backspace that side text. Since
		# backspacing shortens the prefix, it is possible to go back into selection.
		active_text[0].backspace()

		# If backspacing causes side-text to have nothing typed, return to the main
		# text as the active text.
		if active_text[0].is_reset():
			set_active_text(main_text)
		else:
			# Otherwise, since backspacing shortens the prefix, it is possible to go back
			# into selection. So we get the typed text of the active side-text and see if
			# any other side-texts have that text as a prefix. If so, we go back into the
			# selection state.
			var typed := active_text[0].get_typed_string()
			var candidates := get_text_candidates_matching_prefix(typed)
			if len(candidates) > 1 and active_text[0] in candidates:
				unset_active_text()
				selection_prefix = typed
				for candidate in candidates:
					candidate.set_prefix(typed)
	else:
		# If we are not in SELECTION or SIDE_TEXT, then we have to be in the MAIN_STATE
		# state. Just backspace the active text.
		active_text[0].backspace()


# Takes a character and routes it to the correct text, possible switching the
# active text.
func route_char(key: String) -> void:
	var input_state := get_input_state()

	# Only consider side-texts while in the MAIN_TEXT or SELECTION state. Once a
	# side-text is locked in, we can't start another one without returning to the
	# main text or backspacing out of it.
	if input_state == InputState.MAIN_TEXT or input_state == InputState.SELECTION:
		var text_candidates := get_text_candidates_matching_prefix(selection_prefix + key)
		var candidate_count := len(text_candidates)
		# If we have more than one candidate matching selection_prefix, add the character
		# to the selection prefix and matching candidates. Reset any side-texts that don't
		# match as they are no longer being considered. Also unset the active text, since
		# we don't have one during selection.
		if candidate_count > 1:
			selection_prefix += key
			unset_active_text()
			for text in side_texts:
				if text in text_candidates:
					text.append_character(key)
				else:
					text.reset()
		# If we only have one candidate, we have a unique match. Set this side-text as active.
		elif candidate_count == 1:
			set_active_text(text_candidates[0])
		# Otherwise, we have no matches. Go back to focusing the main text.
		# TODO: Emit some sort of selection_typo signal instead, so it can be handled by the
		#       main game (e.g. locking the spellbook temporarily, dropping the matches, etc.)
		else:
			set_active_text(main_text)

	# Only append the character if there is an active text to append to. Otherwise, we are in
	# the SELECTION state, which is handled above.
	if !active_text.is_empty():
		active_text[0].append_character(key)


func render_ui() -> void:
	label.text = (
		selection_prefix
		+ "\n\n"
		+ render_text_state(main_text)
		+ "\n\n"
		+ render_text_state(side_texts[0])
		+ "\n"
		+ render_text_state(side_texts[1])
		+ "\n"
		+ render_text_state(side_texts[2])
		+ "\n"
		+ render_text_state(side_texts[3])
		+ "\n"
		+ render_text_state(side_texts[4])
	)


func render_text_state(ts: TextState) -> String:
	var split := ts.parts()

	return (
		"[color=green]" + split[0] + "[/color][color=red][u]" + split[1] + "[/u][/color]" + split[2]
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		var e := event as InputEventKey
		var key := PackedByteArray([e.unicode]).get_string_from_ascii()

		# Handle special keys like backspace, enter, and shift. Without doing this,
		# we end up sending some bogus character to handle_key.
		if e.unicode == 0:
			if e.keycode == KEY_BACKSPACE:
				key = "backspace"
			elif e.keycode == KEY_ENTER:
				key = "\n"
			elif e.keycode == KEY_TAB:
				key = "tab"
			elif e.keycode == KEY_ESCAPE:
				key = "escape"
			else:
				# Quit early if it's not one of the special keys we care about.
				return

		if e.is_echo():
			if key == "backspace":
				handle_key(key)
		else:
			handle_key(key)
