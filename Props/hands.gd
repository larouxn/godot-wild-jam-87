extends Node3D

const COLOR_HEALTHY = Color.WHITE
const COLOR_SICKLY = Color("#afb515")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_timer: Timer = $AnimationTimer
@onready var hand_mesh_l: Node3D = $hand_left/Cube
@onready var hand_mesh_r: Node3D = $hand_right/Cube
@onready var player_health_bar: ProgressBar = $"../PlayerUI/ProgressBar"
@onready var main_text_input_manager: InputManager = %InputManager


func _ready() -> void:
	hand_mesh_l.set_surface_override_material(0, hand_mesh_l.get_active_material(0).duplicate())
	hand_mesh_r.set_surface_override_material(0, hand_mesh_r.get_active_material(0).duplicate())

	main_text_input_manager.key_pressed.connect(_type)
	animation_timer.timeout.connect(_idle)

	_update_decay()


func _process(_delta: float) -> void:
	_update_decay()


func _type() -> void:
	animation_player.play("type")
	animation_timer.start()


func _cast() -> void:
	animation_timer.stop()
	animation_player.play("cast")


func _idle() -> void:
	animation_timer.stop()
	animation_player.stop()


func _update_decay() -> void:
	var ratio: float = player_health_bar.value / player_health_bar.max_value
	var weighted_ratio: float = ease(ratio, 0.4)  # Transition colors slower
	var new_color: Color = COLOR_SICKLY.lerp(COLOR_HEALTHY, weighted_ratio)

	hand_mesh_l.get_surface_override_material(0).albedo_color = new_color
	hand_mesh_r.get_surface_override_material(0).albedo_color = new_color
