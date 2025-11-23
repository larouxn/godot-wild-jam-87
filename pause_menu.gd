extends Control

var resume_text := TextState.new("Resume")
var main_menu_text := TextState.new("Main Menu")
var options_text := TextState.new("Options")
var quit_text := TextState.new("Quit")
var confirm_text := TextState.new("Confirm")

var master_bus_index := AudioServer.get_bus_index("Master")
var music_bus_index := AudioServer.get_bus_index("BackgroundMusic")
var sfx_bus_index := AudioServer.get_bus_index("SFX")

@onready var input_manager := %InputManager as InputManager

@onready var resume_label := %ResumeButton as RichTextLabel
@onready var main_menu_label := %MainMenuButton as RichTextLabel
@onready var options_label := %OptionsButton as RichTextLabel
@onready var quit_label := %QuitButton as RichTextLabel
@onready var confirm_label := %ConfirmButton as RichTextLabel

@onready var pause_menu := %PauseMenu
@onready var nav_menu := %NavigationMenu
@onready var option_menu := %OptionMenu
@onready var master_slider := %MasterVolumeSlider as HSlider
@onready var music_slider := %MusicVolumeSlider as HSlider
@onready var sfx_slider := %SFXVolumeSlider as HSlider


func _ready() -> void:
	#input_manager.set_main_text(resume_text)
	#input_manager.register_side_text(main_menu_text)
	#input_manager.register_side_text(options_text)
	#input_manager.register_side_text(quit_text)

	input_manager.connect("key_pressed", render_ui)
	resume_text.finished.connect(_on_resume)
	main_menu_text.finished.connect(_on_main_menu)
	options_text.finished.connect(_on_options)
	quit_text.finished.connect(_on_quit)
	confirm_text.finished.connect(_on_confirm)

	# set up audio
	master_slider.value = AudioServer.get_bus_volume_linear(master_bus_index)
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus_index)
	render_ui()


func render_text_state(ts: TextState) -> String:
	var split := ts.parts()
	return (
		"[color=green]" + split[0] + "[/color][color=red][u]" + split[1] + "[/u][/color]" + split[2]
	)


func render_ui() -> void:
	resume_label.text = render_text_state(resume_text)
	main_menu_label.text = render_text_state(main_menu_text)
	options_label.text = render_text_state(options_text)
	quit_label.text = render_text_state(quit_text)
	confirm_label.text = render_text_state(confirm_text)


func _on_resume(id: int) -> void:
	print(id)
	pause_menu.hide()


func _on_main_menu(id: int) -> void:
	print(id)
	get_tree().change_scene_to_file("res://StartMenu/start_menu.tscn")


func _on_options(id: int) -> void:
	input_manager.unregister_side_text(id)
	input_manager.register_side_text(confirm_text)
	nav_menu.hide()
	option_menu.show()
	master_slider.grab_focus()


func _on_quit(id: int) -> void:
	print(id)
	get_tree().quit()


func _on_confirm(id: int) -> void:
	input_manager.unregister_side_text(id)
	input_manager.register_side_text(options_text)
	option_menu.hide()
	nav_menu.show()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(master_bus_index, value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_bus_index, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_bus_index, value)
