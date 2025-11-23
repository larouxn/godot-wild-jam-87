class_name WinMenu extends Node3D

var restart_text := TextState.new("Type once more...")

@onready var input_manager := $InputManager as InputManager
@onready var restart_label := $WinText/RestartText as RichTextLabel

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
	input_manager.set_main_text(restart_text)

	# set up signals
	input_manager.connect("key_pressed", render_ui)
	input_manager.connect("key_pressed", play_type_sound)
	restart_text.finished.connect(_on_restart)

	render_ui()


func render_ui() -> void:
	restart_label.text = render_text_state(restart_text)


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


func _on_restart(_id: int) -> void:
	restart_label.hide()
	bell_player.play()


func _on_typewriter_bell_player_finished() -> void:
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
