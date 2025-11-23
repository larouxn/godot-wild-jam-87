extends Control

var value_change: int = 0
var pixel_shift_per_tick: float

@onready var health_bar := $ProgressBar as ProgressBar
@onready var falling_health := $FallingHealth/CPUParticles2D as CPUParticles2D
@onready var full_health_position := falling_health.position.x


func _ready() -> void:
	pixel_shift_per_tick = health_bar.get_global_rect().size.x / 100
	falling_health.move_local_x(-pixel_shift_per_tick * (100 - health_bar.value))


func _process(_delta: float) -> void:
	if health_bar.value == 100:
		falling_health.emitting = false
	else:
		falling_health.emitting = true
	if value_change != 0:
		health_bar.value += value_change
		var position_shift := pixel_shift_per_tick * value_change
		if (falling_health.position.x + position_shift) > full_health_position:
			falling_health.position.x = full_health_position
		else:
			falling_health.move_local_x(position_shift)
	value_change = 0


func _on_timer_timeout() -> void:
	value_change = -1
