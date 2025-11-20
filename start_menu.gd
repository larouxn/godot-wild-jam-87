extends Node3D

var open_menu_text := TextState.new("Type to begin")
var start_game_text := TextState.new("Sign the Contract")
var options_text := TextState.new("Negotiate Terms")
var credits_text := TextState.new("Meet the Authors")
var quit_text := TextState.new("Run Away")

@onready var input_manager := $InputManager as InputManager
@onready var open_label := $OpenMenuText as RichTextLabel
@onready var start_label := $StartGameText as RichTextLabel
@onready var options_label := $OptionsText as RichTextLabel
@onready var credits_label := $CreditsText as RichTextLabel
@onready var quit_label := $QuitText as RichTextLabel
@onready var match_sound_player := $OpenMenuText/MatchSoundPlayer as AudioStreamPlayer
@onready var bg_music := $BackgroundMusicPlayer as AudioStreamPlayer
@onready var typewriter_sound_player := $TypewriterSoundPlayer as AudioStreamPlayer

@onready var typing_a_sound := load("res://Sound/TypeSoundA.mp3")
@onready var typing_b_sound := load("res://Sound/TypeSoundB.mp3")
@onready var typing_c_sound := load("res://Sound/TypeSoundC.mp3")
@onready var typing_d_sound := load("res://Sound/TypeSoundD.mp3")
@onready var typing_e_sound := load("res://Sound/TypeSoundE.mp3")


func _ready() -> void:
	input_manager.set_main_text(open_menu_text)
	input_manager.register_side_text(start_game_text)
	input_manager.register_side_text(options_text)
	input_manager.register_side_text(credits_text)
	input_manager.register_side_text(quit_text)

	input_manager.connect("key_pressed", render_ui)
	input_manager.connect("key_pressed", play_type_sound)
	open_menu_text.finished.connect(_on_open_menu)
	start_game_text.finished.connect(_on_start_game)
	options_text.finished.connect(_on_options)
	credits_text.finished.connect(_on_credits)
	quit_text.finished.connect(_on_quit)
	match_sound_player.finished.connect(_start_bg_music)

	render_ui()


func render_ui() -> void:
	open_label.text = render_text_state(open_menu_text)
	start_label.text = render_text_state(start_game_text)
	options_label.text = render_text_state(options_text)
	credits_label.text = render_text_state(credits_text)
	quit_label.text = render_text_state(quit_text)


func play_type_sound() -> void:
	typewriter_sound_player.stream = (
		[typing_a_sound, typing_b_sound, typing_c_sound, typing_d_sound, typing_e_sound]
		. pick_random()
	)
	typewriter_sound_player.play()


func render_text_state(ts: TextState) -> String:
	var split := ts.parts()
	return (
		"[color=green]" + split[0] + "[/color][color=red][u]" + split[1] + "[/u][/color]" + split[2]
	)


func _on_open_menu(id: int) -> void:
	print(id)
	match_sound_player.play()
	open_label.hide()
	start_label.show()
	options_label.show()
	credits_label.show()
	quit_label.show()


func _start_bg_music() -> void:
	bg_music.play()


func _on_start_game(id: int) -> void:
	print(id)
	get_tree().change_scene_to_file("res://main.tscn")


func _on_options(id: int) -> void:
	print(id)


func _on_credits(id: int) -> void:
	print(id)


func _on_quit(id: int) -> void:
	print(id)
	get_tree().quit()
