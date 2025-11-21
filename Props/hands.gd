extends Node3D

@export var healthy_color: Color = Color.WHITE
@export var decay_color: Color = Color(0.2, 0.8, 0.2)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hand_mesh_l: Node3D = $hand_left/Cube
@onready var hand_mesh_r: Node3D = $hand_right/Cube


func _ready() -> void:
	type()
	hand_mesh_l.set_surface_override_material(0, hand_mesh_l.get_active_material(0).duplicate())
	hand_mesh_r.set_surface_override_material(0, hand_mesh_r.get_active_material(0).duplicate())

	update_decay_state(0.2)


func type() -> void:
	animation_player.play("type")


func cast() -> void:
	animation_player.play("cast")


func set_decay() -> void:
	pass


func update_decay_state(health_percentage: float) -> void:
	var decay_amount: float = 1.0 - health_percentage
	var new_color: Color = healthy_color.lerp(decay_color, decay_amount)

	hand_mesh_l.get_surface_override_material(0).albedo_color = new_color
	hand_mesh_r.get_surface_override_material(0).albedo_color = new_color
