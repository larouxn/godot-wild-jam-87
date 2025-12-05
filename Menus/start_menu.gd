extends Node3D

var open_menu_text: TextState = TextState.new()
var start_game_text: TextState
var options_text: TextState
var credits_text: TextState
var quit_text: TextState
var options_return_text: TextState
var credits_return_text: TextState

var master_bus_index := AudioServer.get_bus_index("Master")
var music_bus_index := AudioServer.get_bus_index("BackgroundMusic")
var sfx_bus_index := AudioServer.get_bus_index("SFX")

@onready var candle := $Table/CandleTall as StaticBody3D

@onready var input_manager := $InputManager as InputManager
@onready var game_title := $GameTitleLabel as RichTextLabel
@onready var main_menu := $MainMenu as VBoxContainer
@onready var options_menu := $OptionsMenu as VBoxContainer
@onready var credits_menu := $CreditsMenu as VBoxContainer
@onready var bg_panel := $MenuPanel as Panel

@onready var open_label := $OpenCursor as RichTextLabel
@onready var start_label := $MainMenu/StartCursor as RichTextLabel
@onready var options_label := $MainMenu/OptionsCursor as RichTextLabel
@onready var credits_label := $MainMenu/CreditsCursor as RichTextLabel
@onready var quit_label := $MainMenu/QuitCursor as RichTextLabel
@onready
var options_return_label := $OptionsMenu/CenterContainer/OptionsReturnCursor as RichTextLabel
@onready
var credits_return_label := $CreditsMenu/CenterContainer/CreditsReturnCursor as RichTextLabel

@onready var open_cursor := $OpenCursor as CursorText
@onready var start_cursor := $MainMenu/StartCursor as CursorText
@onready var options_cursor := $MainMenu/OptionsCursor as CursorText
@onready var credits_cursor := $MainMenu/CreditsCursor as CursorText
@onready var quit_cursor := $MainMenu/QuitCursor as CursorText
@onready var options_return_cursor := $OptionsMenu/CenterContainer/OptionsReturnCursor as CursorText
@onready var credits_return_cursor := $CreditsMenu/CenterContainer/CreditsReturnCursor as CursorText

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
	ResourceLoader.load_threaded_request("res://main.tscn")
	ResourceLoader.load_threaded_request("res://intro.tscn")

	# set up inputs
	input_manager.set_main_text(open_menu_text)
	init_nodes.call_deferred()

	# set up signals
	input_manager.connect("key_pressed", play_type_sound)

	# set up audio
	master_slider.value = AudioServer.get_bus_volume_linear(master_bus_index)
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus_index)


func init_nodes() -> void:
	open_menu_text = open_cursor.create_and_link_one_line_text_state(open_cursor.text)
	start_game_text = start_cursor.create_and_link_one_line_text_state("Start")
	options_text = options_cursor.create_and_link_one_line_text_state("Options")
	credits_text = credits_cursor.create_and_link_one_line_text_state("Credits")
	quit_text = quit_cursor.create_and_link_one_line_text_state("Run Away")
	options_return_text = options_return_cursor.create_and_link_one_line_text_state("Confirm")
	credits_return_text = credits_return_cursor.create_and_link_one_line_text_state("Back")

	open_menu_text.finished.connect(_on_open_menu)
	start_game_text.finished.connect(_on_start_game)
	options_text.finished.connect(_on_options)
	credits_text.finished.connect(_on_credits)
	quit_text.finished.connect(_on_quit)
	options_return_text.finished.connect(_on_options_return)
	credits_return_text.finished.connect(_on_credits_return)

	_lock_all_menu_cursors()
	options_return_text.lock()
	credits_return_text.lock()


func play_type_sound() -> void:
	# Check if the node is inside the tree before trying to play
	if not is_inside_tree():
		return

	typewriter_sound_player.stream = (
		[typing_a_sound, typing_b_sound, typing_c_sound, typing_d_sound, typing_e_sound]
		. pick_random()
	)
	typewriter_sound_player.play()


func _lock_all_menu_cursors() -> void:
	start_game_text.lock()
	options_text.lock()
	credits_text.lock()
	quit_text.lock()


func _unlock_all_menu_cursors() -> void:
	start_game_text.unlock()
	options_text.unlock()
	credits_text.unlock()
	quit_text.unlock()


func _on_open_menu(_id: int) -> void:
	input_manager.handle_key("escape")  # clears input
	bell_player.play()
	_start_bg_music()
	candle.show()
	open_cursor.hide()
	open_menu_text.lock()
	_unlock_all_menu_cursors()
	game_title.show()
	main_menu.show()


func _start_bg_music() -> void:
	print("starting background music")
	bg_music.play()


func _on_start_game(_id: int) -> void:
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://intro.tscn"))


func _on_options(_id: int) -> void:
	input_manager.handle_key("escape")  # clears input
	_lock_all_menu_cursors()
	options_return_text.unlock()
	main_menu.hide()
	bg_panel.show()
	options_menu.show()
	master_slider.grab_focus()


func _on_credits(_id: int) -> void:
	input_manager.handle_key("escape")  # clears input
	_lock_all_menu_cursors()
	credits_return_text.unlock()
	main_menu.hide()
	bg_panel.show()
	credits_menu.show()


func _on_quit(_id: int) -> void:
	get_tree().quit()


func _on_options_return(_id: int) -> void:
	input_manager.handle_key("escape")  # clears input
	_unlock_all_menu_cursors()
	options_return_text.lock()
	bg_panel.hide()
	options_menu.hide()
	main_menu.show()


func _on_credits_return(_id: int) -> void:
	input_manager.handle_key("escape")  # clears input
	_unlock_all_menu_cursors()
	credits_return_text.lock()
	bg_panel.hide()
	credits_menu.hide()
	main_menu.show()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(master_bus_index, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_bus_index, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_bus_index, value)
