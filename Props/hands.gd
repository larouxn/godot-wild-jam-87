extends Node3D

const COLOR_HEALTHY = Color.WHITE
const COLOR_SICKLY = Color("#afb515")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hand_mesh_l: Node3D = $hand_left/Cube
@onready var hand_mesh_r: Node3D = $hand_right/Cube
@onready var player_health_bar: ProgressBar = $"../PlayerUI/ProgressBar"


func _ready() -> void:
	hand_mesh_l.set_surface_override_material(0, hand_mesh_l.get_active_material(0).duplicate())
	hand_mesh_r.set_surface_override_material(0, hand_mesh_r.get_active_material(0).duplicate())
	_update_decay()


func _process(_delta: float) -> void:
	_update_decay()


func type() -> void:
	animation_player.play("type")


func cast() -> void:
	animation_player.play("cast")


func idle() -> void:
	# TODO: try keep_state: true for resumable animations
	animation_player.stop()


func _update_decay() -> void:
	var ratio: float = player_health_bar.value / player_health_bar.max_value
	var weighted_ratio: float = ease(ratio, 0.4)  # Transition colors slower
	var new_color: Color = COLOR_SICKLY.lerp(COLOR_HEALTHY, weighted_ratio)

	hand_mesh_l.get_surface_override_material(0).albedo_color = new_color
	hand_mesh_r.get_surface_override_material(0).albedo_color = new_color
