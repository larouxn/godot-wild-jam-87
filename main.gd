extends Node3D

signal damage_dealt(damage: int)

@export var input_manager: InputManager

var cursor_text: CursorText
var main_text := TextState.new()
var looking_at_book := false
var health: float

@onready var main_text_container := $"MainText" as ControlView3D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var player_ui := $PlayerUI as Control
@onready var health_bar := $PlayerUI/ProgressBar as ProgressBar


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


func init_nodes() -> void:
	cursor_text = main_text_container.get_control_node("CenterContainer/CursorText")

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
