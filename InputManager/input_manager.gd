extends Node3D

var main_text := TextState.new()
var active_text := main_text
var texts: Array[TextState] = []
var text_candidates: Array[TextState] = []

@onready var label := $Label as RichTextLabel


func _ready() -> void:
	main_text.text = (
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

	var candle_text := TextState.new()
	candle_text.text = "<light candle"
	var spell1_text := TextState.new()
	spell1_text.text = ":Bhippopotomonstrosesquippedaliophobia"
	var spell2_text := TextState.new()
	spell2_text.text = (
		':B\'hold, thus denoted! Word stops--variety, yes!--and yet "meaning" lacks. '
		+ "Cease; punctuate (as you will); stop? & yet more!"
	)
	texts.append_array([candle_text, spell1_text, spell2_text])
	render_ui()


func handle_key(key: String) -> void:
	if key == "backspace":
		# TODO: It might be nice to be able to backspace out of a side text and back
		#       into choosing a text candidate.
		if text_candidates.is_empty():
			active_text.backspace()
			if active_text.input_index == 0:
				active_text = main_text
		else:
			for text in text_candidates:
				text.backspace()
				if text.input_index == 0:
					text_candidates.erase(text)
	elif key == "tab" or key == "escape":
		active_text = main_text
		text_candidates = []
		for text in texts:
			text.reset()
	else:
		route_input(key)

	render_ui()


# Takes a character and routes it to the correct text, possible switching the
# active text.
func route_input(key: String) -> void:
	# Only consider side-texts while typing the main text. Once a side-text is
	# locked in, we can't start another one without returning to the main text
	# first.
	if main_text == active_text:
		# If we haven't started narrowing down possible side-texts, choose from all
		# of them. Otherwise, choose from the remaining candidates.
		var side_text_pool := texts
		if !text_candidates.is_empty():
			side_text_pool = text_candidates
			# Clear the current candidates since we'll append the new candidates to
			# this list.
			text_candidates = []
		# For each possible candidate text, check if its next character matches the
		# input. If it does, we add it to the list of candidates and append the input
		# to the text (so we keep the typing progress as we narrow it down).
		#
		# If it doesn't match, reset the typing progress.
		for text in side_text_pool:
			if text.check_character(key):
				text_candidates.append(text)
				text.append_character(key)
			else:
				text.reset()
		# If we only have one candidate left, set it as the active text. We've
		# successfully switched over to a side-text.
		if len(text_candidates) == 1:
			active_text = text_candidates[0]
			text_candidates = []
			# Remove the last added character as it will get re-added by the call to
			# append_character on the active text right after this.
			active_text.backspace()

	# Only append text to the active text when there are no side-text candidates.
	# This stops us from typing wrong characters into the main text while trying
	# to match a side-text (before the side-text is fully matched and becomes the
	# active text).
	if text_candidates.is_empty():
		active_text.append_character(key)


func render_ui() -> void:
	label.text = (
		render_text_state(main_text)
		+ "\n\n"
		+ render_text_state(texts[0])
		+ "\n\n"
		+ render_text_state(texts[1])
		+ "\n\n"
		+ render_text_state(texts[2])
		+ "\n\n"
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
