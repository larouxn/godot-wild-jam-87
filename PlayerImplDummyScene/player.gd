class_name Player extends Node3D

@export var input_manager: InputManager

var cursor_text: CursorText
var main_text := TextState.new()
var looking_at_book := false

@onready var main_text_container := $"../MainTextContainer" as MainTextContainer
@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	init_nodes.call_deferred()
	input_manager.set_main_text(main_text)
	input_manager.input_state_changed.connect(
		func(input_state: InputManager.InputState) -> void:
			if input_state == InputManager.InputState.MAIN_TEXT:
				looking_at_book = false
				animation_player.play("look_typewriter")
				# book.fall()
			elif !looking_at_book:
				looking_at_book = true
				animation_player.play("look_book")
				# book.rise()
	)
	input_manager.selection_mistyped.connect(
		func(_candidates: Array[TextState]) -> void: input_manager.set_active_text(main_text)
	)


func init_nodes() -> void:
	cursor_text = main_text_container.cursor_text
	# var spell1 := spells.get_control_node("VBoxContainer/CursorText") as CursorText
	# var spell2 := spells.get_control_node("VBoxContainer/CursorText2") as CursorText
	# var spell3 := spells.get_control_node("VBoxContainer/CursorText3") as CursorText

	var paragraph: PackedStringArray = []
	for sentence: Array in WordGenerator.new().get_paragraph_array(100):
		paragraph.append_array(sentence)

	main_text.input_index = 1500
	cursor_text.link_text_state(main_text, paragraph)
	print(main_text.text)
	main_text.mistyped.connect(
		func(_id: int) -> void:
			main_text.lock()
			await get_tree().create_timer(3.0).timeout
			main_text.unlock()
	)

	# var s1t := spell1.create_and_link_one_line_text_state("@hippopotomonstrosesquipedaliophobia")
	# var s2t := spell2.create_and_link_one_line_text_state(
	# 	"@state { text = filter (not . symbol) $ state ^. #text) }"
	# )
	# var s3t := spell3.create_and_link_one_line_text_state(
	# 	"@gO AwAy cApItAL LEttErs nO OnE LIkEs yOU"
	# )
	#
	# for spell_text: TextState in [s1t, s2t, s3t]:
	# 	spell_text.finished.connect(
	# 		func(_id: int) -> void: input_manager.set_active_text(main_text)
	# 	)
	# 	spell_text.mistyped.connect(
	# 		func(_id: int) -> void:
	# 			spell_text.lock()
	# 			main_text.lock()
	# 			input_manager.set_active_text(main_text)
	# 			await get_tree().create_timer(0.5).timeout
	# 			main_text.unlock()
	# 			await get_tree().create_timer(10.0).timeout
	# 			spell_text.unlock()
	# 	)
