extends Node3D

var word_generator: WordGenerator = WordGenerator.new()

var main_text := TextState.new(
	word_generator.join_paragraph_to_string(word_generator.get_paragraph_array(50))
)

var prefixes: Array[String] = [
	"@abcde",
	"@12345",
	"@abc",
	"@123xy",
]

@onready var input_manager := $InputManager as InputManager
@onready var label := $Label as RichTextLabel
@onready var timer := $Timer as Timer


func _ready() -> void:
	input_manager.set_main_text(main_text)
	for pre in prefixes:
		input_manager.register_side_text(TextState.new(pre + generate_word(10)))

	input_manager.connect("key_pressed", render_ui)
	timer.connect(
		"timeout",
		func() -> void:
			var rem_ix := randi() % len(input_manager.side_texts)
			var pfx_ix := randi() % len(prefixes)
			input_manager.unregister_side_text(input_manager.side_texts[rem_ix].id)
			input_manager.register_side_text(TextState.new(prefixes[pfx_ix] + generate_word(10)))
			render_ui()
	)

	render_ui()


func generate_word(length: int) -> String:
	var chars := "abcdefghijklmnopqrstuvwxyz"
	var word: String = ""
	var n_char := len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word


func render_ui() -> void:
	var input_state_dict := {0: "MAIN_TEXT", 1: "SELECTION", 2: "SIDE_TEXT"}
	label.text = (
		input_state_dict[input_manager.get_input_state()]
		+ "\n\n"
		+ render_text_state(main_text)
		+ "\n\n"
	)
	for st in input_manager.side_texts:
		label.text += render_text_state(st) + "\n"


func render_text_state(ts: TextState) -> String:
	var split := ts.parts()

	return (
		"[color=green]" + split[0] + "[/color][color=red][u]" + split[1] + "[/u][/color]" + split[2]
	)
