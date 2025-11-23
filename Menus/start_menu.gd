class_name StartMenu extends Node3D

static var jump_to_main_menu: bool = false

var open_menu_text := TextState.new("Type to Begin")
var start_game_text := TextState.new("Sign the Contract")
var options_text := TextState.new("Negotiate Terms")
var credits_text := TextState.new("Meet the Authors")
var quit_text := TextState.new("Run Away")
var options_return_text := TextState.new("Confirm")
var credits_return_text := TextState.new("Back")

var master_bus_index := AudioServer.get_bus_index("Master")
var music_bus_index := AudioServer.get_bus_index("BackgroundMusic")
var sfx_bus_index := AudioServer.get_bus_index("SFX")

@onready var candle := $Table/CandleTall as StaticBody3D

@onready var input_manager := $InputManager as InputManager
@onready var game_title := $GameTitleLabel as RichTextLabel
@onready var main_menu := $MainMenu as VBoxContainer
@onready var open_label := $MainMenu/OpenMenuText as RichTextLabel
@onready var start_label := $MainMenu/StartGameText as RichTextLabel
@onready var options_label := $MainMenu/OptionsText as RichTextLabel
@onready var credits_label := $MainMenu/CreditsText as RichTextLabel
@onready var quit_label := $MainMenu/QuitText as RichTextLabel

@onready var options_menu := $OptionsMenu as VBoxContainer
@onready var options_return_label := $OptionsMenu/OptionsReturnLabel as RichTextLabel
@onready var credits_menu := $CreditsMenu as VBoxContainer
@onready var credits_return_label := $CreditsMenu/CreditsReturnLabel as RichTextLabel
@onready var bg_panel := $MenuPanel as Panel

@onready var match_sound_player := $MatchSoundPlayer as AudioStreamPlayer
@onready var bg_music := $BackgroundMusicPlayer as AudioStreamPlayer
@onready var bell_player := $TypewriterBellPlayer as AudioStreamPlayer
@onready var typewriter_sound_player := $TypewriterSoundPlayer as AudioStreamPlayer
@onready var typing_a_sound := load("res://Sound/Effects/TypeSoundA.mp3")
@onready var typing_b_sound := load("res://Sound/Effects/TypeSoundB.mp3")
@onready var typing_c_sound := load("res://Sound/Effects/TypeSoundC.mp3")
@onready var typing_d_sound := load("res://Sound/Effects/TypeSoundD.mp3")
@onready var typing_e_sound := load("res://Sound/Effects/TypeSoundE.mp3")
@onready var master_slider := $OptionsMenu/MasterVolumeCon/MasterVolumeSlider as HSlider
@onready var music_slider := $OptionsMenu/MusicVolumeCon/MusicVolumeSlider as HSlider
@onready var sfx_slider := $OptionsMenu/SFXVolumeCon/SFXVolumeSlider as HSlider


func _ready() -> void:
	# set up inputs
	input_manager.set_main_text(open_menu_text)
	input_manager.register_side_text(start_game_text)
	input_manager.register_side_text(options_text)
	input_manager.register_side_text(credits_text)
	input_manager.register_side_text(quit_text)

	# set up signals
	input_manager.connect("key_pressed", render_ui)
	input_manager.connect("key_pressed", play_type_sound)
	open_menu_text.finished.connect(_on_open_menu)
	start_game_text.finished.connect(_on_start_game)
	options_text.finished.connect(_on_options)
	credits_text.finished.connect(_on_credits)
	quit_text.finished.connect(_on_quit)
	options_return_text.finished.connect(_on_options_return)
	credits_return_text.finished.connect(_on_credits_return)
	match_sound_player.finished.connect(_start_bg_music)

	# set up audio
	master_slider.value = AudioServer.get_bus_volume_linear(master_bus_index)
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus_index)
	render_ui()

	if jump_to_main_menu:
		_on_open_menu(-1)
		jump_to_main_menu = false


func render_ui() -> void:
	open_label.text = render_text_state(open_menu_text)
	start_label.text = render_text_state(start_game_text)
	options_label.text = render_text_state(options_text)
	credits_label.text = render_text_state(credits_text)
	quit_label.text = render_text_state(quit_text)
	options_return_label.text = render_text_state(options_return_text)
	credits_return_label.text = render_text_state(credits_return_text)


func play_type_sound() -> void:
	# Check if the node is inside the tree before trying to play
	if not is_inside_tree():
		return

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
	bell_player.play()
	match_sound_player.play()
	candle.show()
	game_title.show()
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
	input_manager.unregister_side_text(id)
	input_manager.register_side_text(options_return_text)
	main_menu.hide()
	bg_panel.show()
	options_menu.show()
	master_slider.grab_focus()


func _on_credits(id: int) -> void:
	print(id)
	input_manager.unregister_side_text(id)
	input_manager.register_side_text(credits_return_text)
	main_menu.hide()
	bg_panel.show()
	credits_menu.show()


func _on_quit(id: int) -> void:
	print(id)
	get_tree().quit()


func _on_options_return(id: int) -> void:
	print(id)
	input_manager.unregister_side_text(id)
	input_manager.register_side_text(options_text)
	bg_panel.hide()
	options_menu.hide()
	main_menu.show()


func _on_credits_return(id: int) -> void:
	print(id)
	input_manager.unregister_side_text(id)
	input_manager.register_side_text(credits_text)
	bg_panel.hide()
	credits_menu.hide()
	main_menu.show()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(master_bus_index, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_bus_index, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_bus_index, value)
