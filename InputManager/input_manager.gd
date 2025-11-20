class_name InputManager extends Node3D

signal key_pressed

# Emitted with the new InputState whenever the InputState changes.
signal input_state_changed(input_state: InputState)

# Fires when the active text(s) change. This could occur when transitioning to
# a single active text (MAIN_TEXT, SIDE_TEXT) or when updating the prefix during
# side-text selection.
#
# The argument is a list of TextStates which are currently receiving input.
#
# NOTE: This fires every time the prefix changes during side-text selection,
#       regardless of whether or not the set of TextStates currently receiving
#       input has changed.
signal active_texts_changed(text: Array[TextState])

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
var main_text: TextState:
	set = set_main_text

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


# Set the main text. If it was previously unset, also set it as the active text.
func set_main_text(new_main_text: TextState) -> void:
	var prev_main_text := main_text
	main_text = new_main_text
	main_text.lock_changed.connect(handle_text_lock)
	if prev_main_text == null:
		set_active_text(new_main_text)
	else:
		prev_main_text.lock_changed.disconnect(handle_text_lock)


# Callback for the lock_changed signal to sync up text that was locked and has
# just been unlocked.
func handle_text_lock(id: int, locked: bool) -> void:
	if !locked:
		for text in side_texts:
			if text.id == id:
				text.reset()
		recalculate_input_state()


# Add a side-text to the array of side-texts. The input state will be recalculated
# to accommodate the new side-text.
func register_side_text(side_text: TextState) -> void:
	for text in side_texts:
		assert(text.id != side_text.id, "Cannot register side-text with non-unique id")

	side_text.reset()
	side_text.lock_changed.connect(handle_text_lock)
	side_texts.append(side_text)

	if get_input_state() != InputState.MAIN_TEXT:
		recalculate_input_state()


# Remove a side text from the array of side-texts. The input state will be
# recalculated to accommodate the removed side-text.
func unregister_side_text(id: int) -> void:
	for text in side_texts:
		if text.id == id:
			text.lock_changed.disconnect(handle_text_lock)
	side_texts = side_texts.filter(func(text: TextState) -> bool: return text.id != id)

	var input_state := get_input_state()
	if input_state == InputState.SIDE_TEXT and active_text[0].id == id:
		# If we're removing the active side-text, switch to MAIN_TEXT state.
		set_active_text(main_text)
	elif input_state == InputState.SELECTION:
		# If we're in the selection process, recalculate the side-text state.
		recalculate_input_state()


# Update the input state after a side-text has been added, removed, or unlocked.
func recalculate_input_state() -> void:
	var input_state := get_input_state()

	var prefix := selection_prefix
	if input_state == InputState.MAIN_TEXT:
		# If we are in MAIN_TEXT state, it doesn't matter if we added or removed side-
		# texts. We don't need to fix anything.
		return

	if input_state == InputState.SIDE_TEXT:
		prefix = active_text[0].get_typed_string()
		# If the side-text is mistyped, it can't be considered a candidate for its own
		# prefix. This means that if a newly-added side-text did match, it would be the
		# only match and snatch focus from the current side-text. This behavior seems
		# like it would be unexpected, so we skip matching on new entries if the current
		# side-text is mistyped.
		if active_text[0].is_mistyped():
			return

	# Sync all candidates up with the current prefix. This catches up newly-added
	# side-texts.
	var candidates := get_text_candidates_matching_prefix(prefix)
	for candidate in candidates:
		candidate.set_prefix(prefix)

	var num_candidates := len(candidates)
	if num_candidates > 1:
		selection_prefix = prefix
		unset_active_text()
		if input_state != InputState.SELECTION:
			input_state_changed.emit(InputState.SELECTION)
		active_texts_changed.emit(candidates)
	elif num_candidates == 1:
		set_active_text(candidates[0])
	elif num_candidates == 0:
		set_active_text(main_text)


# Return whether or not the given TextState is currently receiving input.
func is_text_active(text: TextState) -> bool:
	var input_state := get_input_state()

	if input_state == InputState.SELECTION:
		return text in get_text_candidates_matching_prefix(selection_prefix)

	return text == active_text[0]


func handle_key(key: String) -> void:
	if key == "backspace":
		backspace()
	elif key == "tab" or key == "escape":
		set_active_text(main_text)
	else:
		route_char(key)

	key_pressed.emit()


func set_active_text(new_active_text: TextState) -> void:
	var prev_active_text := active_text

	active_text = [new_active_text]
	selection_prefix = ""
	for text in side_texts:
		if text.id != new_active_text.id:
			text.reset()

	if active_text != prev_active_text:
		if new_active_text == main_text:
			input_state_changed.emit(InputState.MAIN_TEXT)
		else:
			input_state_changed.emit(InputState.SIDE_TEXT)

	active_texts_changed.emit(active_text)


func unset_active_text() -> void:
	# NOTE: This implies that the input state has changed to SELECTION, but we are
	#       emitting that event where the other selection logic is happening, not
	#       here.
	active_text = []
	active_texts_changed.emit(active_text)


func get_text_candidates_matching_prefix(prefix: String) -> Array[TextState]:
	return side_texts.filter(
		func(candidate: TextState) -> bool:
			return candidate.begins_with(prefix) and !candidate.is_locked()
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
		side_texts_are_reset = side_texts_are_reset and (text.is_reset() or text.is_locked())

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
			other_side_texts_are_reset = (
				other_side_texts_are_reset and (text.is_reset() or text.is_locked())
			)

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
			var candidates := get_text_candidates_matching_prefix(selection_prefix)
			for candidate in candidates:
				candidate.set_prefix(selection_prefix)
			active_texts_changed.emit(candidates)
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
			# Only go into SELECTION mode if the active text is not mistyped.
			if len(candidates) > 1 and !active_text[0].is_mistyped():
				unset_active_text()
				selection_prefix = typed
				for candidate in candidates:
					candidate.set_prefix(typed)
				input_state_changed.emit(InputState.SELECTION)
				active_texts_changed.emit(candidates)
	else:
		# If we are not in SELECTION or SIDE_TEXT, then we have to be in the MAIN_TEXT
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
			if input_state != InputState.SELECTION:
				input_state_changed.emit(InputState.SELECTION)
			active_texts_changed.emit(text_candidates)
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
