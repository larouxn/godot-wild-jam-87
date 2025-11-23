extends Control

@export var input_manager: InputManager
@export var main_node: Node3D
@export var spellbook: Spellbook

var resume_text: TextState
var main_menu_text: TextState
var options_text: TextState
var quit_text: TextState
var confirm_text: TextState

var master_bus_index := AudioServer.get_bus_index("Master")
var music_bus_index := AudioServer.get_bus_index("BackgroundMusic")
var sfx_bus_index := AudioServer.get_bus_index("SFX")

@onready var resume_cursor := %ResumeCursor as CursorText
@onready var main_menu_cursor := %MainMenuCursor as CursorText
@onready var options_cursor := %OptionsCursor as CursorText
@onready var quit_cursor := %QuitCursor as CursorText
@onready var confirm_cursor := %ConfirmCursor as CursorText

@onready var pause_menu := %PauseMenu
@onready var nav_menu := %NavigationMenu
@onready var option_menu := %OptionMenu
@onready var master_slider := %MasterVolumeSlider as HSlider
@onready var music_slider := %MusicVolumeSlider as HSlider
@onready var sfx_slider := %SFXVolumeSlider as HSlider


func _ready() -> void:
	init_nodes.call_deferred()

	# set up audio
	master_slider.value = AudioServer.get_bus_volume_linear(master_bus_index)
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus_index)


func init_nodes() -> void:
	resume_text = resume_cursor.create_and_link_one_line_text_state(resume_cursor.text)
	main_menu_text = main_menu_cursor.create_and_link_one_line_text_state(main_menu_cursor.text)
	options_text = options_cursor.create_and_link_one_line_text_state(options_cursor.text)
	quit_text = quit_cursor.create_and_link_one_line_text_state(quit_cursor.text)
	confirm_text = confirm_cursor.create_and_link_one_line_text_state(confirm_cursor.text)

	resume_text.finished.connect(_on_resume)
	main_menu_text.finished.connect(_on_main_menu)
	options_text.finished.connect(_on_options)
	quit_text.finished.connect(_on_quit)
	confirm_text.finished.connect(_on_confirm)

	lock_all_texts()
	confirm_text.lock()


func lock_all_texts() -> void:
	resume_text.lock()
	main_menu_text.lock()
	options_text.lock()
	quit_text.lock()


func unlock_all_texts() -> void:
	resume_text.unlock()
	main_menu_text.unlock()
	options_text.unlock()
	quit_text.unlock()


func _on_resume(_id: int) -> void:
	get_tree().paused = false
	lock_all_texts()
	input_manager.handle_key("escape")
	main_node.main_text.unlock()
	for ts: TextState in spellbook.spells.values():
		ts.unlock()
	pause_menu.hide()


func _on_main_menu(_id: int) -> void:
	input_manager.handle_key("escape")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")


func _on_options(_id: int) -> void:
	input_manager.handle_key("escape")
	lock_all_texts()
	confirm_text.unlock()
	nav_menu.hide()
	option_menu.show()
	master_slider.grab_focus()


func _on_quit(_id: int) -> void:
	input_manager.handle_key("escape")
	get_tree().paused = false
	get_tree().quit()


func _on_confirm(_id: int) -> void:
	input_manager.handle_key("escape")
	confirm_text.lock()
	unlock_all_texts()
	option_menu.hide()
	nav_menu.show()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(master_bus_index, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_bus_index, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_bus_index, value)
