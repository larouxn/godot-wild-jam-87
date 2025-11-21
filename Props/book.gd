extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass


func rise() -> void:
	animation_player.play("rise")
	animation_player.queue("hover")


func fall() -> void:
	animation_player.play("fall", 0.5)


func hover() -> void:
	animation_player.play("hover")
