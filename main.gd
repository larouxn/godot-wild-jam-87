extends Node3D

signal damage_dealt(damage: int)

@export var input_manager: InputManager

var cursor_text: CursorText
var main_text := TextState.new()
var looking_at_book := false
var health: float

@onready var main_text_container := $MainTextContainer as MainTextContainer
@onready var animation_player := $Head/AnimationPlayer as AnimationPlayer
@onready var player_ui := $PlayerUI as Control
@onready var health_bar := $PlayerUI/ProgressBar as ProgressBar
@onready var pause_menu := %PauseMenu as Control

@onready var typewriter_sound_player := $Head/Camera3D/TypewriterSoundPlayer as AudioStreamPlayer
@onready var typing_a_sound := load("res://Sound/Effects/TypeSoundA.mp3")
@onready var typing_b_sound := load("res://Sound/Effects/TypeSoundB.mp3")
@onready var typing_c_sound := load("res://Sound/Effects/TypeSoundC.mp3")
@onready var typing_d_sound := load("res://Sound/Effects/TypeSoundD.mp3")
@onready var typing_e_sound := load("res://Sound/Effects/TypeSoundE.mp3")


func _ready() -> void:
	init_nodes.call_deferred()
	input_manager.set_main_text(main_text)
	input_manager.input_state_changed.connect(
		func(input_state: InputManager.InputState) -> void:
			if input_state == InputManager.InputState.MAIN_TEXT:
				looking_at_book = false
				animation_player.play("look_typewriter")
			elif !looking_at_book:
				looking_at_book = true
				animation_player.play("look_book")
	)
	input_manager.selection_mistyped.connect(
		func(_candidates: Array[TextState]) -> void: input_manager.set_active_text(main_text)
	)
	main_text.mistyped.connect(_on_main_text_failed)
	health = health_bar.value
	input_manager.key_pressed.connect(play_type_sound)


func init_nodes() -> void:
	cursor_text = main_text_container.cursor_text

	var paragraph: PackedStringArray = []
	for sentence: Array in WordGenerator.new().get_paragraph_array(10):
		paragraph.append_array(sentence)

	cursor_text.link_text_state(main_text, paragraph)
	main_text.mistyped.connect(
		func(_id: int) -> void:
			main_text.lock()
			await get_tree().create_timer(3.0).timeout
			main_text.unlock()
	)


func _process(_delta: float) -> void:
	if health <= 0:
		print("Game Over!")


func _on_spellbook_spell_failed() -> void:
	print("spell failed")
	damage_dealt.emit(5)


func _on_main_text_failed(_id: int) -> void:
	damage_dealt.emit(3)


func play_type_sound() -> void:
	# Check if the node is inside the tree before trying to play
	if not is_inside_tree():
		return

	typewriter_sound_player.stream = (
		[typing_a_sound, typing_b_sound, typing_c_sound, typing_d_sound, typing_e_sound]
		. pick_random()
	)
	typewriter_sound_player.play()
