extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var animation_length: float = animation_player.get_animation("flicker").length
	animation_player.play("flicker")
	animation_player.seek(randf_range(0.0, animation_length))
