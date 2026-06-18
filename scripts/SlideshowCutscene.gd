extends CanvasLayer

signal cutscene_finished

const ADVANCE_COOLDOWN_MSEC := 250
const MIN_SLIDE_DELAY_SEC := 0.25
const FINAL_MEMORY_DELAY_SEC := 1.0

@onready var panel_texture: TextureRect = $PanelTexture
@onready var missing_panel: Panel = $MissingPanel
@onready var missing_panel_label: Label = $MissingPanel/MissingPanelLabel
@onready var caption_label: Label = $CaptionLabel
@onready var slide_counter_label: Label = $SlideCounterLabel
@onready var prompt_label: Label = $PromptLabel

var slides: Array = []
var current_index := 0
var active_tween: Tween = null
var can_advance := false
var finished := false
var waiting_for_final_input := false
var last_advance_msec := 0
var advance_generation := 0

func start_cutscene(slide_list: Array) -> void:
	slides = slide_list.duplicate()
	current_index = 0
	finished = false
	can_advance = false
	waiting_for_final_input = false
	last_advance_msec = 0
	advance_generation = 0
	visible = true
	prompt_label.text = "Press E / Space to continue"
	if slides.is_empty():
		call_deferred("_finish_cutscene")
		return
	_show_current_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or finished or not can_advance:
		return
	if event.is_action_pressed("interact"):
		if event is InputEventKey and event.echo:
			return
		var now := Time.get_ticks_msec()
		if now - last_advance_msec < ADVANCE_COOLDOWN_MSEC:
			get_viewport().set_input_as_handled()
			return
		last_advance_msec = now
		get_viewport().set_input_as_handled()
		_next_slide()

func _next_slide() -> void:
	if finished:
		return
	if waiting_for_final_input:
		_finish_cutscene()
		return
	current_index += 1
	if current_index >= slides.size():
		_show_final_memory_prompt()
		return
	_show_current_slide()

func _show_current_slide() -> void:
	if finished or current_index < 0 or current_index >= slides.size():
		return
	can_advance = false
	advance_generation += 1
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	panel_texture.scale = Vector2.ONE
	panel_texture.modulate = Color(1, 1, 1, 1)
	missing_panel.modulate = Color(1, 1, 1, 1)
	var slide := _get_slide_data(current_index)
	var image_path := str(slide.get("image_path", ""))
	caption_label.text = str(slide.get("caption", ""))
	slide_counter_label.text = "Memory %d / %d" % [current_index + 1, slides.size()]
	prompt_label.text = "Press E / Space to continue"
	var effect := str(slide.get("effect", "fade"))
	var duration := float(slide.get("duration", 0.5))
	_apply_image(image_path)
	_apply_effect(effect, duration)
	_enable_advance_after_delay(MIN_SLIDE_DELAY_SEC, advance_generation)

func _get_slide_data(index: int) -> Dictionary:
	if index < 0 or index >= slides.size():
		return {}
	if typeof(slides[index]) == TYPE_DICTIONARY:
		return slides[index]
	return {"caption": str(slides[index]), "effect": "fade", "image_path": ""}

func _apply_image(image_path: String) -> void:
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		panel_texture.texture = null
		missing_panel.visible = true
		missing_panel_label.text = "MEMORY PANEL\nPlaceholder image pending"
		return
	var texture := load(image_path)
	if texture is Texture2D:
		panel_texture.texture = texture
		missing_panel.visible = false
	else:
		panel_texture.texture = null
		missing_panel.visible = true
		missing_panel_label.text = "MEMORY PANEL\nPlaceholder image pending"

func _apply_effect(effect: String, duration: float) -> void:
	active_tween = create_tween()
	match effect:
		"slow_zoom":
			panel_texture.scale = Vector2(1.0, 1.0)
			active_tween.tween_property(panel_texture, "scale", Vector2(1.08, 1.08), max(duration, 0.1))
		"glitch_flash":
			_play_audio("play_glitch")
			panel_texture.modulate = Color(1, 1, 1, 0.25)
			active_tween.tween_property(panel_texture, "modulate", Color(1, 1, 1, 1), max(duration * 0.5, 0.05))
			active_tween.tween_property(panel_texture, "modulate", Color(0.85, 0.95, 1.0, 1), max(duration * 0.25, 0.05))
			active_tween.tween_property(panel_texture, "modulate", Color(1, 1, 1, 1), max(duration * 0.25, 0.05))
		_:
			panel_texture.modulate = Color(1, 1, 1, 0)
			active_tween.tween_property(panel_texture, "modulate", Color(1, 1, 1, 1), max(duration, 0.1))

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

func _show_final_memory_prompt() -> void:
	waiting_for_final_input = true
	can_advance = false
	advance_generation += 1
	caption_label.text = "The memory settles."
	prompt_label.text = "Press E / Space to finish memory"
	_enable_advance_after_delay(FINAL_MEMORY_DELAY_SEC, advance_generation)

func _enable_advance_after_delay(delay: float, generation: int) -> void:
	await get_tree().create_timer(delay).timeout
	if visible and not finished and generation == advance_generation:
		can_advance = true

func _finish_cutscene() -> void:
	if finished:
		return
	finished = true
	can_advance = false
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	visible = false
	cutscene_finished.emit()
