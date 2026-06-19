extends Control

signal new_memory_requested
signal restore_memory_requested

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")

@onready var background_texture: TextureRect = $BackgroundLayer/BackgroundTexture
@onready var background_fallback: ColorRect = $BackgroundLayer/BackgroundFallback
@onready var scanline_overlay: TextureRect = $EffectsLayer/ScanlineOverlay
@onready var flicker_overlay: ColorRect = $EffectsLayer/FlickerOverlay
@onready var startup_static_overlay: ColorRect = $EffectsLayer/StartupStaticOverlay
@onready var crackle_root: Control = $EffectsLayer/CrackleRoot
@onready var logo_texture: TextureRect = $UILayer/LogoTexture
@onready var logo_fallback_label: Label = $UILayer/LogoFallbackLabel
@onready var menu_frame: TextureRect = $UILayer/Panel/MenuFrame
@onready var new_memory_button: Button = $UILayer/Panel/VBox/NewMemoryButton
@onready var restore_memory_button: Button = $UILayer/Panel/VBox/RestoreMemoryButton
@onready var settings_button: Button = $UILayer/Panel/VBox/SettingsButton
@onready var quit_button: Button = $UILayer/Panel/VBox/QuitButton
@onready var background_layer: CanvasLayer = $BackgroundLayer
@onready var effects_layer: CanvasLayer = $EffectsLayer
@onready var ui_layer: CanvasLayer = $UILayer
@onready var settings_menu: CanvasLayer = $SettingsMenu

var flicker_tween: Tween = null
var logo_tween: Tween = null
var background_tween: Tween = null
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_apply_optional_art()
	_apply_button_styles()
	_start_flicker_pulse()
	_start_logo_glow_pulse()
	_start_background_glow_pulse()
	_start_startup_static()
	new_memory_button.pressed.connect(request_new_memory)
	restore_memory_button.pressed.connect(request_restore_memory)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	if settings_menu.has_signal("settings_closed"):
		settings_menu.settings_closed.connect(_on_settings_closed)
	focus_default()

func focus_default() -> void:
	new_memory_button.grab_focus()

func _apply_button_styles() -> void:
	for button in [new_memory_button, restore_memory_button, settings_button, quit_button]:
		_style_menu_button(button)

func _style_menu_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(0.88, 0.93, 0.96, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.98, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.98, 1.0, 1.0, 1.0))
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.015, 0.022, 0.032, 0.78), Color(0.18, 0.8, 0.92, 0.42), 1))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.035, 0.052, 0.07, 0.9), Color(0.25, 0.95, 1.0, 0.72), 1))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.02, 0.015, 0.028, 0.94), Color(0.95, 0.18, 0.9, 0.85), 1))
	button.add_theme_stylebox_override("focus", _make_button_style(Color(0.035, 0.052, 0.07, 0.88), Color(0.98, 0.98, 1.0, 0.95), 2))

func _make_button_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(4)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style

func request_new_memory() -> void:
	_play_audio("play_ui_confirm")
	hide_for_memory_menu()
	new_memory_requested.emit()

func request_restore_memory() -> void:
	_play_audio("play_ui_confirm")
	hide_for_memory_menu()
	restore_memory_requested.emit()

func hide_for_memory_menu() -> void:
	_set_layers_visible(false)

func show_after_memory_menu() -> void:
	_set_layers_visible(true)
	focus_default()

func _set_layers_visible(is_visible: bool) -> void:
	visible = is_visible
	background_layer.visible = is_visible
	effects_layer.visible = is_visible
	ui_layer.visible = is_visible

func _on_settings_pressed() -> void:
	_set_layers_visible(false)
	if settings_menu.has_method("open_menu"):
		settings_menu.open_menu()

func _on_settings_closed() -> void:
	_set_layers_visible(true)
	settings_button.grab_focus()

func _on_quit_pressed() -> void:
	_play_audio("play_ui_cancel")
	get_tree().quit()

func _apply_optional_art() -> void:
	_apply_texture_with_fallback(ASSET_PATHS.TITLE_BACKGROUND, background_texture, background_fallback)
	_apply_logo_texture()
	_apply_optional_texture(ASSET_PATHS.TITLE_MENU_FRAME, menu_frame)
	_apply_optional_texture(ASSET_PATHS.TITLE_SCANLINE_OVERLAY, scanline_overlay)

func _apply_logo_texture() -> void:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(ASSET_PATHS.TITLE_LOGO)
	logo_texture.texture = texture
	logo_texture.visible = texture != null
	logo_fallback_label.visible = texture == null
	logo_texture.modulate = Color.WHITE
	logo_fallback_label.modulate = Color.WHITE

func _apply_texture_with_fallback(path: String, texture_rect: TextureRect, fallback: CanvasItem) -> void:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	texture_rect.texture = texture
	texture_rect.visible = texture != null
	fallback.visible = texture == null
	texture_rect.modulate = Color.WHITE

func _apply_optional_texture(path: String, texture_rect: TextureRect) -> void:
	var texture: Texture2D = ASSET_PATHS.load_texture_or_null(path)
	texture_rect.texture = texture
	texture_rect.visible = texture != null

func _start_flicker_pulse() -> void:
	if flicker_tween and flicker_tween.is_valid():
		flicker_tween.kill()
	flicker_overlay.modulate.a = 0.025
	flicker_tween = create_tween()
	flicker_tween.set_loops()
	flicker_tween.tween_property(flicker_overlay, "modulate:a", 0.045, 1.8)
	flicker_tween.tween_property(flicker_overlay, "modulate:a", 0.014, 1.2)

func _start_logo_glow_pulse() -> void:
	if logo_tween and logo_tween.is_valid():
		logo_tween.kill()
	if not logo_texture.visible:
		return
	logo_tween = create_tween()
	logo_tween.set_loops()
	logo_tween.tween_property(logo_texture, "modulate", Color(1.0, 1.0, 1.0, 0.92), 1.4)
	logo_tween.tween_property(logo_texture, "modulate", Color(0.82, 0.95, 1.0, 1.0), 1.6)

func _start_background_glow_pulse() -> void:
	if background_tween and background_tween.is_valid():
		background_tween.kill()
	if not background_texture.visible:
		return
	background_tween = create_tween()
	background_tween.set_loops()
	background_tween.tween_property(background_texture, "modulate", Color(0.92, 0.96, 1.0, 1.0), 2.4)
	background_tween.tween_property(background_texture, "modulate", Color.WHITE, 2.8)

func _start_startup_static() -> void:
	startup_static_overlay.visible = true
	crackle_root.visible = true
	_play_audio("play_glitch")
	_run_startup_static()

func _run_startup_static() -> void:
	await _show_static_burst(0.12, 9, 0.16)
	await get_tree().create_timer(rng.randf_range(0.08, 0.18)).timeout
	await _show_static_burst(0.08, 6, 0.11)
	await get_tree().create_timer(rng.randf_range(0.18, 0.36)).timeout
	if rng.randf() < 0.65:
		await _show_static_burst(0.06, 4, 0.08)
	_clear_crackle_lines()
	startup_static_overlay.visible = false
	crackle_root.visible = false

func _show_static_burst(duration: float, line_count: int, alpha: float) -> void:
	_clear_crackle_lines()
	startup_static_overlay.modulate.a = alpha
	for index in range(line_count):
		crackle_root.add_child(_make_crackle_line())
	var burst_tween := create_tween()
	burst_tween.tween_property(startup_static_overlay, "modulate:a", 0.0, duration)
	await burst_tween.finished

func _make_crackle_line() -> ColorRect:
	var line := ColorRect.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line_width := rng.randf_range(80.0, 640.0)
	var line_height := rng.randf_range(1.0, 3.0)
	line.position = Vector2(rng.randf_range(-40.0, 520.0), rng.randf_range(0.0, 438.0))
	line.size = Vector2(line_width, line_height)
	line.color = Color(
		rng.randf_range(0.72, 1.0),
		rng.randf_range(0.88, 1.0),
		1.0,
		rng.randf_range(0.1, 0.32)
	)
	return line

func _clear_crackle_lines() -> void:
	for child in crackle_root.get_children():
		child.queue_free()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
