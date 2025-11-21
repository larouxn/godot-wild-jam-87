extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass


func rise() -> void:
	animation_player.play("rise")


func fall() -> void:
	animation_player.play("fall", 0.5)


func hover() -> void:
	animation_player.play("hover")


func _on_animation_player_animation_finished(animation_name: StringName) -> void:
	if animation_name == "rise":
		animation_player.play("hover", 0.3)
