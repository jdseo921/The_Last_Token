extends Node2D

@export_enum("flicker", "glow_pulse", "bob", "jitter", "blink", "scanline_pulse", "random_screen_flash", "dust_mote_drift")
var effect_type := "flicker"
@export_range(0.0, 1.0, 0.01) var intensity := 0.12
@export_range(0.05, 8.0, 0.05) var speed := 1.0
@export var random_offset := true
@export var only_when_memory_signal_at_least := -1
@export var active_flag_optional := ""
@export var prop_size := Vector2(64, 32)
@export var prop_color := Color(0.45, 0.9, 1.0, 0.18)

@onready var visual: Polygon2D = $Visual

var base_position := Vector2.ZERO
var base_scale := Vector2.ONE
var base_color := Color.WHITE
var elapsed := 0.0
var rng := RandomNumberGenerator.new()
var next_flash_time := 0.0

func _ready() -> void:
	rng.randomize()
	base_position = position
	base_scale = scale
	visual.color = prop_color
	base_color = visual.color
	_update_visual_shape()
	if random_offset:
		elapsed = rng.randf_range(0.0, TAU)
		next_flash_time = rng.randf_range(0.4, 2.0)

func _process(delta: float) -> void:
	elapsed += delta * maxf(speed, 0.05)
	visible = _is_active()
	if not visible:
		return
	var readability_dim := _get_readability_dim()
	visual.color = base_color
	position = base_position
	scale = base_scale
	match effect_type:
		"glow_pulse":
			_apply_alpha(0.45 + _wave() * 0.55, readability_dim)
		"bob":
			position = base_position + Vector2(0.0, sin(elapsed) * intensity * 7.0)
			_apply_alpha(0.78, readability_dim)
		"jitter":
			if int(elapsed * 12.0) % 7 == 0:
				position = base_position + Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * intensity * 2.0
			_apply_alpha(0.62, readability_dim)
		"blink":
			_apply_alpha(0.25 if sin(elapsed * 2.2) > 0.92 else 0.72, readability_dim)
		"scanline_pulse":
			scale = Vector2(base_scale.x, maxf(base_scale.y * (0.42 + _wave() * 0.28), 0.08))
			_apply_alpha(0.28 + _wave() * 0.22, readability_dim)
		"random_screen_flash":
			_apply_random_flash(delta, readability_dim)
		"dust_mote_drift":
			position = base_position + Vector2(sin(elapsed * 0.4) * 18.0, -fmod(elapsed * 10.0, 34.0)) * intensity
			_apply_alpha(0.22 + _wave() * 0.12, readability_dim)
		_:
			_apply_alpha(0.38 + sin(elapsed * 7.0) * 0.18 + sin(elapsed * 13.0) * 0.08, readability_dim)

func _apply_random_flash(delta: float, readability_dim: float) -> void:
	next_flash_time -= delta
	if next_flash_time <= 0.0:
		next_flash_time = rng.randf_range(0.7, 2.8)
		_apply_alpha(0.85, readability_dim)
		return
	_apply_alpha(0.18 + _wave() * 0.1, readability_dim)

func _apply_alpha(multiplier: float, readability_dim: float) -> void:
	var next_color := base_color
	next_color.a = clampf(base_color.a * multiplier * (1.0 + intensity), 0.0, 0.42) * readability_dim
	visual.color = next_color

func _wave() -> float:
	return (sin(elapsed) + 1.0) * 0.5

func _is_active() -> bool:
	if only_when_memory_signal_at_least >= 0 and GameState.memory_signal_level < only_when_memory_signal_at_least:
		return false
	if not active_flag_optional.is_empty():
		return bool(GameState.get(active_flag_optional))
	return true

func _get_readability_dim() -> float:
	var host := _find_dialogue_host()
	if host != null and host.has_method("_dialogue_is_active") and bool(host.call("_dialogue_is_active")):
		return 0.38
	return 1.0

func _find_dialogue_host() -> Node:
	var cursor: Node = self
	while cursor != null:
		if cursor.has_method("_dialogue_is_active"):
			return cursor
		cursor = cursor.get_parent()
	return null

func _update_visual_shape() -> void:
	var half := prop_size * 0.5
	visual.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])
