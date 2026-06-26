extends CanvasLayer

signal encounter_finished(encounter_id: String)

const ADVANCE_COOLDOWN_MSEC := 220
const DEFAULT_LINE_LOCKOUT_MSEC := 120

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
var panel_home_position := Vector2.ZERO

func _ready() -> void:
	visible = false
	panel_home_position = dialogue_panel.position
	_hide_identity_art()

func set_controlled_player(player_node: Node) -> void:
	controlled_player = player_node

func start_encounter(new_encounter_id: String, lines: Array) -> void:
	encounter_id = new_encounter_id
	dialogue_lines = lines.duplicate(true)
	current_index = 0
	active = not dialogue_lines.is_empty()
	visible = active
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
		_accept_current_line()

func _accept_current_line() -> void:
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
	dialogue_label.text = text
	continue_label.visible = effect != "silent"
	line_locked_until_msec = Time.get_ticks_msec() + DEFAULT_LINE_LOCKOUT_MSEC + int(maxf(pause_seconds, 0.0) * 1000.0)
	_apply_line_effect(effect)

func _apply_line_effect(effect: String) -> void:
	dialogue_panel.position = panel_home_position
	dialogue_label.modulate = Color.WHITE
	match effect:
		"glitch":
			dialogue_label.modulate = Color(0.7, 1.0, 1.0, 1.0)
			_pulse_glitch_bars(0.42)
		"shake":
			_start_line_shake()
			_pulse_glitch_bars(0.32)
		"silent":
			dialogue_label.modulate = Color(0.74, 0.76, 0.82, 1.0)
			_pulse_glitch_bars(0.18)
		_:
			_pulse_glitch_bars(0.22)

func _finish_encounter() -> void:
	active = false
	visible = false
	_stop_tweens()
	_set_player_control(true)
	encounter_finished.emit(encounter_id)
	queue_free()

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
