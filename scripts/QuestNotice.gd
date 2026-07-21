extends CanvasLayer

signal quest_closed

const ASSET_PATHS := preload("res://scripts/AssetPaths.gd")
const ROUTE_CUE_SCRIPT := preload("res://scripts/RouteCue.gd")
const BALANCED_TEXT := preload("res://scripts/BalancedText.gd")
const NOTIFICATION_FADE_IN_SECONDS := 0.7
const NOTIFICATION_HOLD_SECONDS := 2.0
const NOTIFICATION_FADE_OUT_SECONDS := 1.0
const ANNOUNCE_POLL_SECONDS := 0.5
const OPENING_QUEST_IDS := ["opening_look_around", "opening_talk_to_mira"]
const PANEL_SCREEN_RATIO := Vector2(0.8, 0.8)
const DEFAULT_VIEWPORT_SIZE := Vector2(640.0, 440.0)
const NOTIFICATION_TIP_TEXT := "Tip: Press Esc, then choose Quest to read these details again."

@onready var panel: Panel = $Panel
@onready var frame_texture: TextureRect = $Panel/FrameTexture
@onready var eyebrow_label: Label = $Panel/EyebrowLabel
@onready var title_label: Label = $Panel/TitleLabel
@onready var body_label: Label = $Panel/BodyLabel
@onready var tip_label: Label = $Panel/TipLabel
@onready var close_button: Button = $Panel/CloseButton

var hide_tween: Tween = null
var notification_token := 0
var announce_accum := 0.0
var hud_root: Control = null
var hud_backing: ColorRect = null
var hud_edge: ColorRect = null
var hud_title: Label = null
var hud_action: Label = null
var hud_tween: Tween = null
var last_announced_signature := ""
var location_context_id := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	_apply_frame_art()
	call_deferred("_maybe_build_objective_hud")

func _maybe_build_objective_hud() -> void:
	# One persistent top-right objective HUD per map (only the map-level
	# QuestNotice builds it, not the copies living inside pause menus).
	if get_parent() != get_tree().current_scene:
		return
	# Own CanvasLayer: this QuestNotice layer is hidden except during popups,
	# but the objective HUD must ALWAYS be visible.
	var hud_layer := CanvasLayer.new()
	hud_layer.name = "ObjectiveHudLayer"
	hud_layer.layer = 55
	get_parent().add_child(hud_layer)
	hud_root = Control.new()
	hud_root.name = "ObjectiveHud"
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(hud_root)
	hud_backing = ColorRect.new()
	hud_backing.name = "ObjectiveBacking"
	hud_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_backing.position = Vector2(340, 0)
	hud_backing.size = Vector2(294, 44)
	hud_backing.color = Color(0.012, 0.016, 0.026, 0.78)
	hud_root.add_child(hud_backing)
	hud_edge = ColorRect.new()
	hud_edge.name = "ObjectiveEdge"
	hud_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_edge.position = Vector2(340, 0)
	hud_edge.size = Vector2(2, 44)
	hud_edge.color = Color(0.3, 0.9, 1.0, 0.85)
	hud_root.add_child(hud_edge)
	hud_title = Label.new()
	hud_title.name = "ObjectiveTitle"
	hud_title.position = Vector2(348, 2)
	hud_title.size = Vector2(282, 18)
	hud_title.add_theme_font_override("font", preload("res://assets/fonts/m5x7.ttf"))
	hud_title.add_theme_font_size_override("font_size", 16)
	hud_title.add_theme_color_override("font_color", Color(0.5, 0.95, 1.0, 1.0))
	hud_root.add_child(hud_title)
	hud_action = Label.new()
	hud_action.name = "ObjectiveAction"
	hud_action.position = Vector2(348, 20)
	hud_action.size = Vector2(282, 34)
	hud_action.add_theme_font_override("font", preload("res://assets/fonts/m5x7.ttf"))
	hud_action.add_theme_font_size_override("font_size", 16)
	hud_action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_root.add_child(hud_action)
	_update_objective_hud(false)

func _update_objective_hud(pulse: bool) -> void:
	if hud_root == null:
		return
	# Freeze the tip while a conversation is on screen: story flags flip at the
	# start of the initiating dialogue, and the new objective should only
	# surface once that conversation is over.
	if hud_root.visible and _any_dialogue_active():
		return
	var quest_id: String = GameState.get_current_quest_id()
	if quest_id.is_empty():
		hud_root.visible = false
		return
	# The opening tip waits until the protagonist's first monologue has finished.
	if OPENING_QUEST_IDS.has(quest_id) and not GameState.opening_intro_seen:
		hud_root.visible = false
		return
	var data: Dictionary = GameState.get_current_quest_data()
	hud_root.visible = true
	hud_title.text = str(data.get("title", "")).to_upper()
	var action := _get_contextual_action(data)
	if action.is_empty():
		action = str(data.get("location", ""))
	hud_action.text = action
	_fit_hud_to_content()
	if pulse:
		if hud_tween and hud_tween.is_valid():
			hud_tween.kill()
		hud_root.modulate = Color(1.7, 1.7, 1.7, 1.0)
		hud_tween = create_tween()
		hud_tween.tween_property(hud_root, "modulate", Color.WHITE, 0.9)


func _fit_hud_to_content() -> void:
	# The backing and edge end exactly where the tip text ends, so the box
	# never extends below its own content.
	if hud_backing == null or hud_edge == null or hud_action == null:
		return
	var font: Font = hud_action.get_theme_font("font")
	if font == null:
		return
	var text_height: float = font.get_multiline_string_size(
		hud_action.text, HORIZONTAL_ALIGNMENT_LEFT, hud_action.size.x, 16).y
	hud_action.size.y = maxf(text_height + 2.0, 18.0)
	var box_height: float = hud_action.position.y + hud_action.size.y + 4.0
	hud_backing.size.y = box_height
	hud_edge.size.y = box_height

func _any_dialogue_active() -> bool:
	for dialogue_box in get_tree().get_nodes_in_group("dialogue_boxes"):
		if is_instance_valid(dialogue_box) and dialogue_box.get("active") == true:
			return true
	return false

func refresh_objective_hud(pulse := false) -> void:
	# Map scripts call this at exact story handoffs instead of waiting for the
	# half-second polling fallback.
	_update_objective_hud(pulse)

func set_location_context(new_location_id: String) -> void:
	location_context_id = new_location_id
	if hud_root != null:
		_update_objective_hud(false)

func _get_contextual_action(quest_data: Dictionary) -> String:
	if not location_context_id.is_empty():
		var hint: String = ROUTE_CUE_SCRIPT.get_current_hint(location_context_id)
		if hint.begins_with("LOCAL: "):
			return hint.trim_prefix("LOCAL: ")
		if hint.begins_with("ROUTE: "):
			return hint.trim_prefix("ROUTE: ")
	return str(quest_data.get("summary", ""))

func _process(delta: float) -> void:
	# Announce whenever the active quest changes so the player always sees the
	# next objective, no matter which room the change happened in.
	announce_accum += delta
	if announce_accum < ANNOUNCE_POLL_SECONDS:
		return
	announce_accum = 0.0
	# Only the map-level notice that owns the objective HUD may announce quest
	# changes - the copies embedded in pause menus have no HUD and would consume
	# the change marker without ever updating the visible tip.
	if hud_root == null:
		return
	if visible or get_tree().paused:
		return
	if hud_root != null and not hud_root.visible:
		# Re-check gates each poll so the tip appears the moment its gate opens
		# (right after the opening monologue) - pulse only for the opening tip.
		_update_objective_hud(OPENING_QUEST_IDS.has(GameState.get_current_quest_id()))
	var quest_id: String = GameState.get_current_quest_id()
	if quest_id.is_empty():
		return
	# Track the summary too: a beat can advance WITHIN one quest (talk to Roxy
	# -> beat her cabinet), and only the summary changes. Watching the id alone
	# left the tip stuck on the first phase forever.
	var signature: String = "%s|%s" % [quest_id, str(GameState.get_current_quest_data().get("summary", ""))]
	if signature == last_announced_signature:
		return
	if OPENING_QUEST_IDS.has(quest_id):
		return
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("_dialogue_is_active") and bool(scene.call("_dialogue_is_active")):
		return
	if ConscienceEncounterDirector.is_encounter_active():
		return
	last_announced_signature = signature
	_update_objective_hud(true)

func _input(event: InputEvent) -> void:
	# Let the player dismiss an auto notification early. Details mode (close_button
	# visible) keeps its own button and is left alone here.
	if not visible or close_button.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_dismiss_notification()

func _dismiss_notification() -> void:
	if hide_tween and hide_tween.is_valid():
		hide_tween.kill()
	hide_tween = create_tween()
	hide_tween.tween_property(panel, "modulate:a", 0.0, 0.18)
	hide_tween.tween_callback(_finish_notification)

func _finish_notification() -> void:
	hide()
	GameState.ui_notice_blocking = false

func show_notification(quest_data: Dictionary) -> void:
	# Quest changes belong in the persistent corner HUD. The large window is
	# reserved for explicit Esc > Quest details and must never interrupt play.
	GameState.ui_notice_blocking = false
	visible = false
	refresh_objective_hud(true)

func show_custom_notification(eyebrow: String, title: String, body: String) -> void:
	# Compatibility entry point for older map callbacks. Automatic quest-card
	# popups were retired; keep the HUD current without blocking interaction.
	GameState.ui_notice_blocking = false
	visible = false
	refresh_objective_hud(true)

func show_custom_details(eyebrow: String, title: String, body: String) -> void:
	# Details-mode custom window (Close button, no auto-fade) - used for Controls.
	notification_token += 1
	if hide_tween and hide_tween.is_valid():
		hide_tween.kill()
	_configure_window(eyebrow, title, body, true)
	visible = true
	panel.modulate.a = 1.0
	close_button.grab_focus()
	_play_audio("play_ui_confirm")

func show_details(quest_data: Dictionary) -> void:
	notification_token += 1
	if hide_tween and hide_tween.is_valid():
		hide_tween.kill()
	_configure_window(
		"ACTIVE QUEST",
		str(quest_data.get("title", "No Active Quest")),
		_format_quest_body(quest_data, true),
		true
	)
	visible = true
	panel.modulate.a = 1.0
	close_button.grab_focus()
	_play_audio("play_ui_confirm")

func close_details() -> void:
	GameState.ui_notice_blocking = false
	hide()
	quest_closed.emit()

func _configure_window(eyebrow: String, title: String, body: String, details_mode: bool) -> void:
	eyebrow_label.text = eyebrow
	title_label.text = title
	body_label.text = body
	tip_label.visible = not details_mode
	tip_label.text = NOTIFICATION_TIP_TEXT if not details_mode else ""
	close_button.visible = details_mode
	var rect := _get_scaled_panel_rect()
	var content_left := rect.size.x * 0.14
	var content_width := rect.size.x * 0.72
	panel.offset_left = rect.position.x
	panel.offset_top = rect.position.y
	panel.offset_right = rect.position.x + rect.size.x
	panel.offset_bottom = rect.position.y + rect.size.y
	eyebrow_label.offset_left = content_left
	eyebrow_label.offset_top = rect.size.y * 0.16
	eyebrow_label.offset_right = content_left + content_width
	eyebrow_label.offset_bottom = eyebrow_label.offset_top + rect.size.y * 0.07
	title_label.offset_left = eyebrow_label.offset_left
	title_label.offset_top = rect.size.y * 0.27
	title_label.offset_right = content_left + content_width
	title_label.offset_bottom = title_label.offset_top + rect.size.y * 0.12
	body_label.offset_left = content_left
	body_label.offset_top = rect.size.y * 0.43
	body_label.offset_right = content_left + content_width
	body_label.offset_bottom = rect.size.y * 0.82 if details_mode else rect.size.y * 0.70
	tip_label.offset_left = content_left
	tip_label.offset_top = rect.size.y * 0.76
	tip_label.offset_right = content_left + content_width
	tip_label.offset_bottom = rect.size.y * 0.86
	close_button.offset_left = (rect.size.x - 124.0) * 0.5
	close_button.offset_top = rect.size.y * 0.88
	close_button.offset_right = close_button.offset_left + 124.0
	close_button.offset_bottom = close_button.offset_top + 28.0

func _format_quest_body(quest_data: Dictionary, details_mode: bool) -> String:
	var lines := PackedStringArray()
	var owner := str(quest_data.get("owner", ""))
	var location := str(quest_data.get("location", ""))
	var required_text := "Required" if bool(quest_data.get("required", true)) else "Optional"
	if not owner.is_empty():
		lines.append("Owner: %s" % owner)
	if not location.is_empty():
		lines.append("Location: %s" % location)
	lines.append("Type: %s" % required_text)
	lines.append("")
	var body_key := "details" if details_mode else "summary"
	var body_text := str(quest_data.get(body_key, ""))
	if body_text.is_empty():
		body_text = str(quest_data.get("summary", ""))
	if not body_text.is_empty():
		lines.append(body_text)
	return "\n".join(lines)

func _get_scaled_panel_rect() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DEFAULT_VIEWPORT_SIZE
	var panel_size := Vector2(
		viewport_size.x * PANEL_SCREEN_RATIO.x,
		viewport_size.y * PANEL_SCREEN_RATIO.y
	)
	var panel_position := (viewport_size - panel_size) * 0.5
	return Rect2(panel_position, panel_size)

func _apply_frame_art() -> void:
	var texture := ASSET_PATHS.load_texture_or_null(ASSET_PATHS.QUEST_WINDOW_FRAME)
	frame_texture.visible = texture != null
	frame_texture.texture = texture
	panel.self_modulate.a = 0.0 if texture != null else 0.92

func _on_close_pressed() -> void:
	_play_audio("play_ui_cancel")
	close_details()

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
