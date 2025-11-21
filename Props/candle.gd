extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	ignite()


func ignite() -> void:
	animation_player.play("ignite")


func extinguish() -> void:
	animation_player.play("extinguish")


func flicker() -> void:
	var animation_length: float = animation_player.get_animation("flicker").length
	animation_player.play("flicker")
	animation_player.seek(randf_range(0.0, animation_length))


func _on_animation_player_animation_finished(animation_name: String) -> void:
	if animation_name == "ignite":
		flicker()
