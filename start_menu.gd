extends Node3D

var open_menu_text := TextState.new("Type to Open")
var start_game_text := TextState.new("Sign the Contract")
var options_text := TextState.new("Negotiate Conditions")
var credits_text := TextState.new("Meet the Authors")
var quit_text := TextState.new("Run Away")

@onready var input_manager := $InputManager as InputManager
@onready var open_label := $OpenMenuText as RichTextLabel
@onready var start_label := $StartGameText as RichTextLabel
@onready var options_label := $OptionsText as RichTextLabel
@onready var credits_label := $CreditsText as RichTextLabel
@onready var quit_label := $QuitText as RichTextLabel


func _ready() -> void:
	input_manager.set_main_text(open_menu_text)
	input_manager.register_side_text(start_game_text)
	input_manager.register_side_text(options_text)
	input_manager.register_side_text(credits_text)
	input_manager.register_side_text(quit_text)

	input_manager.connect("key_pressed", render_ui)
	open_menu_text.finished.connect(_on_open_menu)
	start_game_text.finished.connect(_on_start_game)
	options_text.finished.connect(_on_options)
	credits_text.finished.connect(_on_credits)
	quit_text.finished.connect(_on_quit)

	render_ui()


func render_ui() -> void:
	open_label.text = render_text_state(open_menu_text)
	start_label.text = render_text_state(start_game_text)
	options_label.text = render_text_state(options_text)
	credits_label.text = render_text_state(credits_text)
	quit_label.text = render_text_state(quit_text)


func render_text_state(ts: TextState) -> String:
	var split := ts.parts()
	return (
		"[color=green]" + split[0] + "[/color][color=red][u]" + split[1] + "[/u][/color]" + split[2]
	)


func _on_open_menu(id: int) -> void:
	print(id)
	open_label.visible = false
	start_label.visible = true
	options_label.visible = true
	credits_label.visible = true
	quit_label.visible = true


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
