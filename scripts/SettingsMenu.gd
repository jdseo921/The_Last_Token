extends CanvasLayer

signal settings_closed

const SETTINGS_FRAME_PATH := "res://assets/art/ui/menus/settings_menu_frame.png"

@onready var frame_texture: TextureRect = $Panel/FrameTexture
@onready var audio_label: Label = $Panel/ScrollContainer/VBox/AudioLabel
@onready var dialogue_label: Label = $Panel/ScrollContainer/VBox/DialogueLabel
@onready var display_label: Label = $Panel/ScrollContainer/VBox/DisplayLabel
@onready var master_slider: HSlider = $Panel/ScrollContainer/VBox/MasterVolumeRow/MasterVolumeSlider
@onready var master_value_label: Label = $Panel/ScrollContainer/VBox/MasterVolumeRow/MasterVolumeValue
@onready var sfx_slider: HSlider = $Panel/ScrollContainer/VBox/SfxVolumeRow/SfxVolumeSlider
@onready var sfx_value_label: Label = $Panel/ScrollContainer/VBox/SfxVolumeRow/SfxVolumeValue
@onready var music_slider: HSlider = $Panel/ScrollContainer/VBox/MusicVolumeRow/MusicVolumeSlider
@onready var music_value_label: Label = $Panel/ScrollContainer/VBox/MusicVolumeRow/MusicVolumeValue
@onready var opacity_slider: HSlider = $Panel/ScrollContainer/VBox/DialogueOpacityRow/DialogueOpacitySlider
@onready var opacity_value_label: Label = $Panel/ScrollContainer/VBox/DialogueOpacityRow/DialogueOpacityValue
@onready var speed_slider: HSlider = $Panel/ScrollContainer/VBox/TextSpeedRow/TextSpeedSlider
@onready var speed_value_label: Label = $Panel/ScrollContainer/VBox/TextSpeedRow/TextSpeedValue
@onready var window_size_option: OptionButton = $Panel/ScrollContainer/VBox/WindowSizeRow/WindowSizeOption
@onready var back_button: Button = $Panel/BackButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_apply_optional_frame()
	_apply_visual_style()
	back_button.pressed.connect(close_menu)
	master_slider.value_changed.connect(_on_master_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	opacity_slider.value_changed.connect(_on_dialogue_opacity_changed)
	speed_slider.value_changed.connect(_on_text_speed_changed)
	window_size_option.item_selected.connect(_on_window_size_selected)
	_sync_from_settings()

func open_menu() -> void:
	_sync_from_settings()
	visible = true
	master_slider.grab_focus()
	_play_audio("play_ui_confirm")

func close_menu() -> void:
	visible = false
	_play_audio("play_ui_cancel")
	settings_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		close_menu()

func _sync_from_settings() -> void:
	var settings := get_node_or_null("/root/GameSettings")
	if settings == null:
		return
	master_slider.value = float(settings.get("master_volume")) * 100.0
	sfx_slider.value = float(settings.get("sfx_volume")) * 100.0
	music_slider.value = float(settings.get("music_volume")) * 100.0
	opacity_slider.value = float(settings.get("dialogue_opacity")) * 100.0
	speed_slider.value = float(settings.get("text_speed")) * 100.0
	_sync_window_size_options()
	_refresh_value_labels()

func _on_master_volume_changed(value: float) -> void:
	GameSettings.set_master_volume(value / 100.0)
	_refresh_value_labels()

func _on_sfx_volume_changed(value: float) -> void:
	GameSettings.set_sfx_volume(value / 100.0)
	_refresh_value_labels()

func _on_music_volume_changed(value: float) -> void:
	GameSettings.set_music_volume(value / 100.0)
	_refresh_value_labels()

func _on_dialogue_opacity_changed(value: float) -> void:
	GameSettings.set_dialogue_opacity(value / 100.0)
	_refresh_value_labels()

func _on_text_speed_changed(value: float) -> void:
	GameSettings.set_text_speed(value / 100.0)
	_refresh_value_labels()

func _on_window_size_selected(index: int) -> void:
	DisplayOptions.set_window_size_index(index)

func _refresh_value_labels() -> void:
	master_value_label.text = "%d%%" % int(round(master_slider.value))
	sfx_value_label.text = "%d%%" % int(round(sfx_slider.value))
	music_value_label.text = "%d%%" % int(round(music_slider.value))
	opacity_value_label.text = "%d%%" % int(round(opacity_slider.value))
	speed_value_label.text = "%.1fx" % (speed_slider.value / 100.0)

func _sync_window_size_options() -> void:
	window_size_option.clear()
	for option in DisplayOptions.get_window_size_options():
		window_size_option.add_item(option)
	window_size_option.select(DisplayOptions.get_window_size_index())

func _apply_optional_frame() -> void:
	frame_texture.visible = false
	frame_texture.texture = null
	if not ResourceLoader.exists(SETTINGS_FRAME_PATH):
		return
	var resource := load(SETTINGS_FRAME_PATH)
	if resource is Texture2D:
		frame_texture.texture = resource
		frame_texture.visible = true

func _apply_visual_style() -> void:
	for section_label in [audio_label, dialogue_label, display_label]:
		section_label.text = section_label.text.to_upper()
		section_label.add_theme_constant_override("outline_size", 2)
		section_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.06, 1.0))
	for slider in [master_slider, sfx_slider, music_slider, opacity_slider, speed_slider]:
		_style_slider(slider)
	_style_back_button()

func _style_slider(slider: HSlider) -> void:
	var rail := StyleBoxFlat.new()
	rail.bg_color = Color(0.18, 0.2, 0.22, 0.95)
	rail.set_corner_radius_all(0)
	rail.content_margin_top = 3.0
	rail.content_margin_bottom = 3.0
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.52, 0.86, 0.94, 0.95)
	fill.set_corner_radius_all(0)
	fill.content_margin_top = 3.0
	fill.content_margin_bottom = 3.0
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.9, 0.95, 0.98, 1.0)
	grabber.border_color = Color(0.16, 0.25, 0.3, 1.0)
	grabber.set_border_width_all(1)
	grabber.set_corner_radius_all(0)
	grabber.content_margin_left = 6.0
	grabber.content_margin_right = 6.0
	grabber.content_margin_top = 6.0
	grabber.content_margin_bottom = 6.0
	var fill_hi := StyleBoxFlat.new()
	fill_hi.bg_color = Color(0.72, 0.98, 1.0, 1.0)
	fill_hi.set_corner_radius_all(0)
	fill_hi.content_margin_top = 3.0
	fill_hi.content_margin_bottom = 3.0
	var grabber_hi := grabber.duplicate() as StyleBoxFlat
	grabber_hi.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	grabber_hi.border_color = Color(0.3, 0.95, 1.0, 1.0)
	slider.add_theme_stylebox_override("slider", rail)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill_hi)
	slider.add_theme_stylebox_override("grabber", grabber)
	slider.add_theme_stylebox_override("grabber_highlight", grabber_hi)

func _style_back_button() -> void:
	back_button.text = back_button.text.to_upper()
	back_button.add_theme_font_size_override("font_size", 14)
	back_button.add_theme_color_override("font_color", Color(0.9, 0.95, 0.98, 1.0))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.03, 0.04, 0.78)
	normal.border_color = Color(0.28, 0.9, 1.0, 0.55)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(0)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.05, 0.08, 0.1, 0.92)
	hover.border_color = Color(0.4, 0.98, 1.0, 0.95)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.09, 0.03, 0.07, 0.94)
	pressed.border_color = Color(1.0, 0.36, 0.72, 0.95)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.bg_color = Color(0.05, 0.07, 0.09, 0.5)
	focus.border_color = Color(1.0, 0.88, 0.32, 0.95)
	focus.set_border_width_all(2)
	back_button.add_theme_stylebox_override("normal", normal)
	back_button.add_theme_stylebox_override("hover", hover)
	back_button.add_theme_stylebox_override("pressed", pressed)
	back_button.add_theme_stylebox_override("focus", focus)

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
