extends CanvasLayer

signal encounter_finished(encounter_id: String)

const ADVANCE_COOLDOWN_MSEC := 220
const DEFAULT_LINE_LOCKOUT_MSEC := 120
const ANTAGONIST_LETTERS_PER_SECOND := 34.0

@onready var overlay_root: Control = $OverlayRoot
@onready var dialogue_panel: Panel = $OverlayRoot/DialoguePanel
@onready var speaker_label: Label = $OverlayRoot/DialoguePanel/SpeakerLabel
@onready var dialogue_label: Label = $OverlayRoot/DialoguePanel/DialogueLabel
@onready var continue_label: Label = $OverlayRoot/DialoguePanel/ContinueLabel
@onready var silhouette: TextureRect = $OverlayRoot/Silhouette
@onready var silhouette_fallback: ColorRect = $OverlayRoot/SilhouetteFallback
@onready var glitch_bar_a: ColorRect = $OverlayRoot/GlitchBarA
@onready var glitch_bar_b: ColorRect = $OverlayRoot/GlitchBarB
@onready var glitch_bar_c: ColorRect = $OverlayRoot/GlitchBarC

var encounter_id := ""
var dialogue_lines: Array = []
var current_index := 0
var active := false
var last_advance_msec := 0
var line_locked_until_msec := 0
var controlled_player: Node = null
var had_controlled_player := false
var controlled_player_was_enabled := true
var flicker_tween: Tween = null
var shake_tween: Tween = null
var fade_tween: Tween = null
var panel_home_position := Vector2.ZERO
var speaker_home_position := Vector2.ZERO
var dialogue_home_position := Vector2.ZERO
var current_full_text := ""
var current_effect := "normal"
var reveal_progress := 0.0
var line_complete := true
var antagonist_elapsed := 0.0

func _ready() -> void:
	visible = false
	panel_home_position = dialogue_panel.position
	speaker_home_position = speaker_label.position
	dialogue_home_position = dialogue_label.position
	_apply_identity_reveal()

func _process(delta: float) -> void:
	if not active:
		return
	_animate_antagonist_text(delta)
	if line_complete:
		return
	reveal_progress += ANTAGONIST_LETTERS_PER_SECOND * _get_text_speed() * delta
	var visible_count := mini(int(reveal_progress), current_full_text.length())
	dialogue_label.visible_characters = visible_count
	line_complete = visible_count >= current_full_text.length()

func set_controlled_player(player_node: Node) -> void:
	controlled_player = player_node

func start_encounter(new_encounter_id: String, lines: Array) -> void:
	encounter_id = new_encounter_id
	dialogue_lines = lines.duplicate(true)
	current_index = 0
	active = not dialogue_lines.is_empty()
	visible = active
	if active:
		if encounter_id != "staff_corridor_warning":
			_set_unknown_voice_music_dim(true)
		# Fade the dimmed overlay in rather than popping so it lands as a mood shift.
		overlay_root.modulate.a = 0.0
		_fade_overlay(1.0, 0.45)
	last_advance_msec = Time.get_ticks_msec()
	line_locked_until_msec = last_advance_msec + DEFAULT_LINE_LOCKOUT_MSEC
	_set_player_control(false)
	_start_flicker()
	if not active:
		_finish_encounter()
		return
	_refresh_line()

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("interact"):
		if event is InputEventKey and event.echo:
			get_viewport().set_input_as_handled()
			return
		var now := Time.get_ticks_msec()
		if now - last_advance_msec < ADVANCE_COOLDOWN_MSEC or now < line_locked_until_msec:
			get_viewport().set_input_as_handled()
			return
		last_advance_msec = now
		get_viewport().set_input_as_handled()
		if not line_complete:
			_complete_current_line()
			return
		_accept_current_line()

func _accept_current_line() -> void:
	_play_audio("play_dialogue_advance")
	current_index += 1
	if current_index >= dialogue_lines.size():
		_finish_encounter()
		return
	_refresh_line()

func _refresh_line() -> void:
	if not active or current_index >= dialogue_lines.size():
		return
	var line: Dictionary = dialogue_lines[current_index]
	var speaker := str(line.get("speaker", "???"))
	var text := str(line.get("text", ""))
	var effect := str(line.get("effect", "normal"))
	var pause_seconds := float(line.get("pause", 0.0))
	speaker_label.text = speaker
	current_full_text = text
	current_effect = effect
	reveal_progress = 0.0
	antagonist_elapsed = 0.0
	line_complete = current_full_text.is_empty()
	dialogue_label.text = current_full_text
	dialogue_label.visible_characters = -1 if line_complete else 0
	continue_label.visible = effect != "silent"
	line_locked_until_msec = Time.get_ticks_msec() + DEFAULT_LINE_LOCKOUT_MSEC + int(maxf(pause_seconds, 0.0) * 1000.0)
	_apply_line_effect(effect)
	_apply_staff_warning_portrait_blur()

func _apply_line_effect(effect: String) -> void:
	dialogue_panel.position = panel_home_position
	speaker_label.position = speaker_home_position
	dialogue_label.position = dialogue_home_position
	speaker_label.modulate = Color.WHITE
	dialogue_label.modulate = Color.WHITE
	match effect:
		"glitch":
			_play_audio("play_glitch")
			dialogue_label.modulate = Color(0.7, 1.0, 1.0, 1.0)
			_pulse_glitch_bars(0.42)
		"shake":
			_play_audio("play_glitch")
			_start_line_shake()
			_pulse_glitch_bars(0.32)
		"silent":
			dialogue_label.modulate = Color(0.74, 0.76, 0.82, 1.0)
			_pulse_glitch_bars(0.18)
		_:
			_pulse_glitch_bars(0.22)

func _complete_current_line() -> void:
	dialogue_label.text = current_full_text
	dialogue_label.visible_characters = -1
	line_complete = true

func _finish_encounter() -> void:
	active = false
	dialogue_label.visible_characters = -1
	_stop_tweens()
	if not visible:
		_cleanup_and_free()
		return
	# Fade the overlay back out, then hand control back and let the world resume.
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(overlay_root, "modulate:a", 0.0, 0.4)
	fade_tween.tween_callback(_cleanup_and_free)

func _cleanup_and_free() -> void:
	if encounter_id != "staff_corridor_warning":
		_set_unknown_voice_music_dim(false)
	visible = false
	_set_player_control(true)
	encounter_finished.emit(encounter_id)
	queue_free()

func _fade_overlay(target_a: float, duration: float) -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(overlay_root, "modulate:a", target_a, duration)

func _set_player_control(enabled: bool) -> void:
	if controlled_player == null or not is_instance_valid(controlled_player):
		return
	if not controlled_player.has_method("set_control_enabled"):
		return
	if not enabled:
		had_controlled_player = true
		var current_control_value: Variant = controlled_player.get("can_control")
		if typeof(current_control_value) == TYPE_BOOL:
			controlled_player_was_enabled = bool(current_control_value)
		controlled_player.call("set_control_enabled", false)
		return
	if had_controlled_player and controlled_player_was_enabled:
		controlled_player.call("set_control_enabled", true)

func _apply_identity_reveal() -> void:
	# ??? emerges over the run: a pure black figure at first, a little more
	# visible after every encounter, fully recognizable only in the Staff Room.
	var k: float = GameState.get_conscience_reveal_factor()
	var tex := load("res://assets/art/portraits/player/player_conscience_revealed.png")
	if tex is Texture2D:
		silhouette.texture = tex
		silhouette.visible = true
		silhouette.modulate = Color(k, k, k, 1.0)
		silhouette_fallback.visible = false
	else:
		silhouette.visible = false
		silhouette_fallback.visible = true
		silhouette_fallback.modulate = Color(1.0 + k, 1.0 + k, 1.0 + k, 1.0)

func _apply_staff_warning_portrait_blur() -> void:
	if encounter_id != "staff_corridor_warning" or silhouette == null:
		return
	var shader := load("res://assets/shaders/portrait_blur.gdshader") as Shader
	if shader == null:
		return
	var material := ShaderMaterial.new()
	material.shader = shader
	var denominator := maxf(float(dialogue_lines.size() - 1), 1.0)
	var progress := float(current_index) / denominator
	material.set_shader_parameter("blur_strength", lerpf(0.9, 0.3, progress))
	silhouette.material = material
	silhouette.modulate = Color(0.72, 0.8, 0.92, 1.0)

func _hide_identity_art() -> void:
	silhouette.visible = false
	silhouette.texture = null
	silhouette_fallback.visible = false

func _start_flicker() -> void:
	if flicker_tween and flicker_tween.is_valid():
		flicker_tween.kill()
	flicker_tween = create_tween()
	flicker_tween.set_loops()
	flicker_tween.set_parallel(true)
	flicker_tween.tween_property(glitch_bar_a, "modulate:a", 0.36, 0.12)
	flicker_tween.tween_property(glitch_bar_b, "modulate:a", 0.18, 0.18)
	flicker_tween.tween_property(glitch_bar_c, "modulate:a", 0.28, 0.15)
	flicker_tween.chain().set_parallel(true)
	flicker_tween.tween_property(glitch_bar_a, "modulate:a", 0.06, 0.22)
	flicker_tween.tween_property(glitch_bar_b, "modulate:a", 0.04, 0.2)
	flicker_tween.tween_property(glitch_bar_c, "modulate:a", 0.08, 0.2)

func _pulse_glitch_bars(alpha: float) -> void:
	glitch_bar_a.modulate.a = alpha
	glitch_bar_b.modulate.a = alpha * 0.58
	glitch_bar_c.modulate.a = alpha * 0.76

func _start_line_shake() -> void:
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
	shake_tween = create_tween()
	shake_tween.tween_property(dialogue_panel, "position", panel_home_position + Vector2(-3, 0), 0.035)
	shake_tween.tween_property(dialogue_panel, "position", panel_home_position + Vector2(3, 0), 0.035)
	shake_tween.tween_property(dialogue_panel, "position", panel_home_position, 0.045)

func _stop_tweens() -> void:
	if flicker_tween and flicker_tween.is_valid():
		flicker_tween.kill()
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
	dialogue_panel.position = panel_home_position
	speaker_label.position = speaker_home_position
	dialogue_label.position = dialogue_home_position

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

func _set_unknown_voice_music_dim(enabled: bool) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("set_unknown_voice_music_dimmed"):
		audio_manager.call("set_unknown_voice_music_dimmed", enabled)

func _exit_tree() -> void:
	if encounter_id != "staff_corridor_warning":
		_set_unknown_voice_music_dim(false)

func _animate_antagonist_text(delta: float) -> void:
	antagonist_elapsed += delta
	var twitch_step := int(antagonist_elapsed * 24.0)
	var should_twitch := twitch_step % 8 == 0
	var direction := -1.0 if twitch_step % 2 == 0 else 1.0
	var effect_scale := 2.0 if current_effect == "shake" else 1.0
	var offset_x := direction * effect_scale if should_twitch else 0.0
	dialogue_label.position = dialogue_home_position + Vector2(offset_x, 0.0)
	speaker_label.position = speaker_home_position + Vector2(-offset_x, 0.0)
	var pulse := (sin(antagonist_elapsed * 10.0) + 1.0) * 0.5
	if current_effect == "silent":
		dialogue_label.modulate = Color(0.72 + pulse * 0.08, 0.78 + pulse * 0.08, 0.88 + pulse * 0.08, 1.0)
		speaker_label.modulate = Color(0.72, 0.86 + pulse * 0.1, 0.95, 1.0)
		return
	var hot_frame := int(antagonist_elapsed * 14.0) % 10 == 0
	if hot_frame:
		dialogue_label.modulate = Color(1.0, 0.72, 1.0, 1.0)
		speaker_label.modulate = Color(1.0, 0.56, 0.9, 1.0)
		return
	dialogue_label.modulate = Color(0.82 + pulse * 0.16, 0.94 + pulse * 0.06, 1.0, 1.0)
	speaker_label.modulate = Color(0.9 + pulse * 0.1, 0.82 + pulse * 0.16, 1.0, 1.0)

func _get_text_speed() -> float:
	var settings := get_node_or_null("/root/GameSettings")
	if settings == null:
		return 1.0
	return maxf(float(settings.get("text_speed")), 0.5)
