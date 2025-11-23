extends Control

## Emitted when a health threshold is passed.
signal health_threshold_passed(threshold: float)

const COLOR_HEALTH_HIGH = Color("#911b1b")  # Healthy red
const COLOR_HEALTH_LOW = Color("#afb515")  # Sickly yellow
const HEALTH_THRESHOLDS = {
	MAX = 100.0,
	TWO_THIRDS = 66.0,
	ONE_THIRD = 33.0,
}

var value_change: int = 0
var pixel_shift_per_tick: float
var health_current_max_limit: float = HEALTH_THRESHOLDS.MAX

@onready var health_bar := $ProgressBar as ProgressBar
@onready var falling_health := $FallingHealth/CPUParticles2D as CPUParticles2D
@onready var full_health_position := falling_health.position.x
@onready var health_bar_style_box: StyleBox = health_bar.get_theme_stylebox("fill").duplicate()


func _ready() -> void:
	pixel_shift_per_tick = health_bar.get_global_rect().size.x / 100
	falling_health.move_local_x(-pixel_shift_per_tick * (100 - health_bar.value))
	_update_health_bar_color()


func _process(_delta: float) -> void:
	if health_bar.value <= 0:
		return

	if health_bar.value == 100:
		falling_health.emitting = false
	else:
		falling_health.emitting = true

	if value_change != 0:
		_update_health()
		_update_particle_postion()
		_update_health_bar_color()

	value_change = 0


func _on_timer_timeout() -> void:
	value_change = -1


func _on_main_damage_dealt(damage: Variant) -> void:
	value_change = -damage


func _update_health() -> void:
	var new_health: float = health_bar.value + value_change

	if (
		new_health <= HEALTH_THRESHOLDS.ONE_THIRD
		and health_current_max_limit > HEALTH_THRESHOLDS.ONE_THIRD
	):
		health_current_max_limit = HEALTH_THRESHOLDS.ONE_THIRD
		health_threshold_passed.emit(HEALTH_THRESHOLDS.ONE_THIRD)
	elif (
		new_health <= HEALTH_THRESHOLDS.TWO_THIRDS
		and health_current_max_limit > HEALTH_THRESHOLDS.TWO_THIRDS
	):
		health_current_max_limit = HEALTH_THRESHOLDS.TWO_THIRDS
		health_threshold_passed.emit(HEALTH_THRESHOLDS.TWO_THIRDS)

	health_bar.value = clamp(new_health, 0, health_current_max_limit)


func _update_particle_postion() -> void:
	var missing_health: float = health_bar.max_value - health_bar.value
	var target_x: float = full_health_position - (pixel_shift_per_tick * missing_health)
	falling_health.position.x = target_x


func _update_health_bar_color() -> void:
	var ratio: float = health_bar.value / health_bar.max_value
	var weighted_ratio: float = ease(ratio, 2.0)  # Transition colors quicker
	var new_color: Color = COLOR_HEALTH_LOW.lerp(COLOR_HEALTH_HIGH, weighted_ratio)

	health_bar_style_box.bg_color = new_color

	health_bar.add_theme_stylebox_override("fill", health_bar_style_box)

	falling_health.color = new_color
