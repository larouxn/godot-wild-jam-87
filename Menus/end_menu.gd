extends Node3D

var try_again_text: TextState
var main_menu_text: TextState
var quit_text: TextState

var master_bus_index := AudioServer.get_bus_index("Master")
var music_bus_index := AudioServer.get_bus_index("BackgroundMusic")
var sfx_bus_index := AudioServer.get_bus_index("SFX")

@onready var input_manager := $InputManager as InputManager
@onready var game_title := $GameTitleLabel as RichTextLabel
@onready var try_again_cursor := $Menu/TryAgainCursor as CursorText
@onready var main_menu_cursor := $Menu/MainMenuCursor as CursorText
@onready var quit_cursor := $Menu/QuitCursor as CursorText

@onready var bg_music := $BackgroundMusicPlayer as AudioStreamPlayer
@onready var bell_player := $TypewriterBellPlayer as AudioStreamPlayer
@onready var typewriter_sound_player := $TypewriterSoundPlayer as AudioStreamPlayer
@onready var typing_a_sound := load("res://Sound/Effects/TypeSoundA.mp3")
@onready var typing_b_sound := load("res://Sound/Effects/TypeSoundB.mp3")
@onready var typing_c_sound := load("res://Sound/Effects/TypeSoundC.mp3")
@onready var typing_d_sound := load("res://Sound/Effects/TypeSoundD.mp3")
@onready var typing_e_sound := load("res://Sound/Effects/TypeSoundE.mp3")


func _ready() -> void:
	_setup_text_states()
	input_manager.connect("key_pressed", play_type_sound)
	_start_bg_music()

	game_title.show()


func _setup_text_states() -> void:
	try_again_text = try_again_cursor.create_and_link_one_line_text_state("Try Again", true)
	main_menu_text = main_menu_cursor.create_and_link_one_line_text_state("Return to Start")
	quit_text = quit_cursor.create_and_link_one_line_text_state("Run Away")

	try_again_text.finished.connect(_on_start_game)
	main_menu_text.finished.connect(_on_open_menu)
	quit_text.finished.connect(_on_quit)


func play_type_sound() -> void:
	# Check if the node is inside the tree before trying to play
	if not is_inside_tree():
		return

	typewriter_sound_player.stream = (
		[typing_a_sound, typing_b_sound, typing_c_sound, typing_d_sound, typing_e_sound]
		. pick_random()
	)
	typewriter_sound_player.play()


func _on_open_menu(id: int) -> void:
	print(id)
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")


func _start_bg_music() -> void:
	bg_music.play()


func _on_start_game(id: int) -> void:
	print(id)
	get_tree().change_scene_to_file("res://main.tscn")


func _on_quit(id: int) -> void:
	print(id)
	get_tree().quit()
