extends CanvasLayer

signal cutscene_finished

@onready var panel_texture: TextureRect = $PanelTexture
@onready var missing_panel: Panel = $MissingPanel
@onready var missing_panel_label: Label = $MissingPanel/MissingPanelLabel
@onready var caption_label: Label = $CaptionLabel

var slides: Array = []
var current_index := 0
var active_tween: Tween = null

func start_cutscene(slide_list: Array) -> void:
	slides = slide_list
	current_index = 0
	visible = true
	_show_current_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		_next_slide()

func _next_slide() -> void:
	current_index += 1
	if current_index >= slides.size():
		visible = false
		cutscene_finished.emit()
		return
	_show_current_slide()

func _show_current_slide() -> void:
	if current_index < 0 or current_index >= slides.size():
		return
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	panel_texture.scale = Vector2.ONE
	panel_texture.modulate = Color(1, 1, 1, 1)
	missing_panel.modulate = Color(1, 1, 1, 1)
	var slide: Dictionary = slides[current_index]
	var image_path := str(slide.get("image_path", ""))
	caption_label.text = str(slide.get("caption", ""))
	var effect := str(slide.get("effect", "fade"))
	var duration := float(slide.get("duration", 0.5))
	_apply_image(image_path)
	_apply_effect(effect, duration)

func _apply_image(image_path: String) -> void:
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		panel_texture.texture = null
		missing_panel.visible = true
		missing_panel_label.text = "Missing panel:\n%s" % image_path
		return
	var texture := load(image_path)
	if texture is Texture2D:
		panel_texture.texture = texture
		missing_panel.visible = false
	else:
		panel_texture.texture = null
		missing_panel.visible = true
		missing_panel_label.text = "Invalid panel:\n%s" % image_path

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
