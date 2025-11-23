class_name Intro extends Node3D

var intro_text: PackedStringArray = [
	"Who...?",
	"No... no, it doesn't matter who...",
	"But, when did it happen?",
	"No, that doesn't matter either.",
	"The real thing that bothers me is...",
	"How.",
	"How did I let myself get...",
	"C U R S E D",
	"...",
	"My body is decaying beneath me.",
	"I need to weave a counter-curse, and quickly.",
	"Let's get to work."
]

var main_text_state := TextState.new()
var skip_text_state: TextState

@onready var input_manager := $InputManager as InputManager

@onready var bg_music := $Audio/BackgroundMusicPlayer as AudioStreamPlayer
@onready var typing_sfx := $Audio/TypewriterSoundPlayer as AudioStreamPlayer
@onready var newline_sfx := $Audio/TypewriterBellPlayer as AudioStreamPlayer

@onready var typing_a_sound := load("res://Sound/Effects/TypeSoundA.mp3")
@onready var typing_b_sound := load("res://Sound/Effects/TypeSoundB.mp3")
@onready var typing_c_sound := load("res://Sound/Effects/TypeSoundC.mp3")
@onready var typing_d_sound := load("res://Sound/Effects/TypeSoundD.mp3")
@onready var typing_e_sound := load("res://Sound/Effects/TypeSoundE.mp3")

@onready var story_text := (
	$CanvasLayer/PanelContainer/PanelContainer/CenterContainer/CursorText as CursorText
)
@onready
var skip_text := $CanvasLayer/PanelContainer/PanelContainer/MarginContainer/CursorText as CursorText


func _ready() -> void:
	main_text_state.newline.connect(play_newline_sound)
	input_manager.set_main_text(main_text_state)

	input_manager.key_pressed.connect(play_typing_sfx)

	skip_text_state = skip_text.create_and_link_one_line_text_state("@skip intro")
	skip_text_state.finished.connect(go_to_main_game)

	story_text.link_text_state(main_text_state, [])
	for line in intro_text:
		main_text_state.reset()
		story_text.set_text_lines([line, ""])
		await main_text_state.finished

	go_to_main_game(-1)


func play_typing_sfx() -> void:
	typing_sfx.stream = (
		[typing_a_sound, typing_b_sound, typing_c_sound, typing_d_sound, typing_e_sound]
		. pick_random()
	)
	typing_sfx.play()


func play_newline_sound(_id: int) -> void:
	newline_sfx.play()


func go_to_main_game(id: int) -> void:
	newline_sfx.stop()

	if id == main_text_state.id:
		main_text_state.backspace()
	else:
		skip_text_state.backspace()

	main_text_state.lock()
	skip_text_state.lock()

	newline_sfx.play()
	await newline_sfx.finished

	get_tree().change_scene_to_file("res://main.tscn")
