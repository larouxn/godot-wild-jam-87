class_name EndMenu extends Node3D

var try_again_text := TextState.new("Try again")
var main_menu_text := TextState.new("Return to menu")
var quit_text := TextState.new("Run Away")

var master_bus_index := AudioServer.get_bus_index("Master")
var music_bus_index := AudioServer.get_bus_index("BackgroundMusic")
var sfx_bus_index := AudioServer.get_bus_index("SFX")

@onready var input_manager := $InputManager as InputManager
@onready var game_title := $GameTitleLabel as RichTextLabel
@onready var menu := $Menu as VBoxContainer
@onready var try_again_label := $Menu/TryAgainText as RichTextLabel
@onready var main_menu_label := $Menu/MainMenuText as RichTextLabel
@onready var quit_label := $Menu/QuitText as RichTextLabel
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


func _ready() -> void:
	# set up inputs
	input_manager.set_main_text(try_again_text)
	input_manager.register_side_text(main_menu_text)
	input_manager.register_side_text(quit_text)

	# set up signals
	input_manager.connect("key_pressed", render_ui)
	input_manager.connect("key_pressed", play_type_sound)
	try_again_text.finished.connect(_on_start_game)
	main_menu_text.finished.connect(_on_open_menu)
	quit_text.finished.connect(_on_quit)
	match_sound_player.finished.connect(_start_bg_music)

	game_title.show()
	render_ui()


func render_ui() -> void:
	try_again_label.text = render_text_state(try_again_text)
	main_menu_label.text = render_text_state(main_menu_text)
	quit_label.text = render_text_state(quit_text)


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
	StartMenu.jump_to_main_menu = true
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")


func _start_bg_music() -> void:
	bg_music.play()


func _on_start_game(id: int) -> void:
	print(id)
	get_tree().change_scene_to_file("res://main.tscn")


func _on_quit(id: int) -> void:
	print(id)
	get_tree().quit()
