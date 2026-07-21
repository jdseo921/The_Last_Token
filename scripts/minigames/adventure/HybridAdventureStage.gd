class_name HybridAdventureStage
extends Control

signal hybrid_transition_requested(payload: Dictionary)

const EXPLORER_SCENE := preload("res://scenes/minigames/adventure/HybridExplorerCharacter.tscn")
const PAUSE_MENU_SCENE := preload("res://scenes/ui/PauseMenu.tscn")
const MINIGAME_UI := preload("res://scripts/ui/MinigameUI.gd")
const BALANCED_TEXT := preload("res://scripts/BalancedText.gd")
const ENVIRONMENT_ATLAS := preload("res://assets/art/minigames/hybrid_exploration/exploration_environment_atlas.png")
const PROP_ATLAS := preload("res://assets/art/minigames/hybrid_exploration/exploration_prop_atlas.png")
const CHECKPOINT_FLAG := preload("res://assets/art/minigames/hybrid_exploration/adventure_checkpoint_flag_v2.png")
const READABLE_HUD_FONT := preload("res://assets/fonts/VT323-Regular.ttf")

const PROP_COLUMNS := 4
const PROP_ROWS := 3
const ENVIRONMENT_COLUMNS := 7
const PLAYER_HITBOX := Vector2(18, 28)
const TOP_HUD_RECT := Rect2(8, 6, 624, 78)
const ADVENTURE_VIEW_RECT := Rect2(10, 88, 620, 264)
const STATUS_HUD_RECT := Rect2(8, 356, 306, 78)
const CONTROLS_HUD_RECT := Rect2(318, 356, 314, 78)

@export var stage_id := "hybrid_adventure"
var stage_profile: Dictionary = {}
var world_size := Vector2(6400, 1080)
var completed := false
var return_in_progress := false

var player: HybridExplorerController
var world_root: Node2D
var adventure_view_container: SubViewportContainer
var adventure_viewport: SubViewport
var world_camera: Camera2D
var hud_layer: CanvasLayer
var counter_label: Label
var status_label: Label
var energy_label: Label
var zone_label: Label
var energy_bar: ProgressBar
var return_button: Button
var reset_button: Button
var completion_panel: Panel

var respawn_position := Vector2.ZERO
var checkpoint_index := -1
var collected_count := 0
var keys_collected := 0
var next_collectible_index := 0
var portal_cooldown := 0.0
var hazard_immunity := 0.0
var status_timer := 0.0
var order_lock_cooldown := 0.0
var reset_pending := false

var collectibles: Array[Dictionary] = []
var keys: Array[Dictionary] = []
var hazards: Array[Rect2] = []
var moving_hazards: Array[Dictionary] = []
var portals: Array[Dictionary] = []
var checkpoints: Array[Dictionary] = []
var marker_screen_labels: Array[Dictionary] = []
var goal_rect := Rect2()


func start_hybrid_stage(id: String, profile: Dictionary) -> void:
	stage_id = id
	stage_profile = profile.duplicate(true)
	world_size = stage_profile.get("world_size", Vector2(6400, 1080))
	AudioManager.play_music_for_context(str(stage_profile.get("music", "arcade_hub")))
	_build_stage()


func _build_stage() -> void:
	reset_pending = false
	completed = false
	return_in_progress = false
	collected_count = 0
	keys_collected = 0
	next_collectible_index = 0
	checkpoint_index = -1
	portal_cooldown = 0.0
	hazard_immunity = 0.0
	status_timer = 0.0
	order_lock_cooldown = 0.0
	collectibles.clear()
	keys.clear()
	hazards.clear()
	moving_hazards.clear()
	portals.clear()
	checkpoints.clear()
	marker_screen_labels.clear()
	_clear_previous_stage()
	_build_world()
	_build_hud()
	_build_pause_menu()
	_refresh_hud()
	_set_status(str(stage_profile.get("status_intro", "Explore the route.")), 4.0)
	# The scrolling artwork already carries enough texture. Keep the CRT bezel,
	# but omit the tiled scanline layer that obscured small stage markers.
	ArcadeScreen.apply(self, "", false)


func _clear_previous_stage() -> void:
	for child in get_children():
		if child.name in ["PauseMenu", "ArcadeScanlines", "ArcadeCRTOverlay"]:
			continue
		remove_child(child)
		child.queue_free()
	for overlay_name in ["ArcadeScanlines", "ArcadeCRTOverlay"]:
		var overlay := get_node_or_null(overlay_name)
		if overlay != null:
			remove_child(overlay)
			overlay.queue_free()


func _build_world() -> void:
	var screen_backdrop := ColorRect.new()
	screen_backdrop.name = "StageBackdrop"
	screen_backdrop.position = Vector2.ZERO
	screen_backdrop.size = Vector2(640, 440)
	screen_backdrop.color = Color(0.002, 0.004, 0.009, 1.0)
	screen_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_backdrop)

	adventure_view_container = SubViewportContainer.new()
	adventure_view_container.name = "AdventureView"
	adventure_view_container.position = ADVENTURE_VIEW_RECT.position
	adventure_view_container.size = ADVENTURE_VIEW_RECT.size
	adventure_view_container.stretch = true
	adventure_view_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(adventure_view_container)

	adventure_viewport = SubViewport.new()
	adventure_viewport.name = "WorldViewport"
	adventure_viewport.size = Vector2i(int(ADVENTURE_VIEW_RECT.size.x), int(ADVENTURE_VIEW_RECT.size.y))
	adventure_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	adventure_viewport.transparent_bg = false
	adventure_view_container.add_child(adventure_viewport)

	world_root = Node2D.new()
	world_root.name = "HybridWorld"
	world_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	adventure_viewport.add_child(world_root)
	_build_environment_backdrop()
	for platform_value in stage_profile.get("platforms", []):
		if platform_value is Rect2:
			_make_platform(platform_value)
	_build_descent_cues()
	_build_static_hazards()
	_build_moving_hazards()
	_build_collectibles()
	_build_keys()
	_build_portals()
	checkpoints.assign(stage_profile.get("checkpoints", []))
	_build_checkpoints()
	_build_goal()

	player = EXPLORER_SCENE.instantiate() as HybridExplorerController
	player.name = "Explorer"
	player.position = stage_profile.get("start_position", Vector2(82, 852))
	player.max_midair_jumps = int(stage_profile.get("max_midair_jumps", 3))
	player.jump_speed = float(stage_profile.get("jump_speed", player.jump_speed))
	player.jump_energy_changed.connect(_on_jump_energy_changed)
	player.state_changed.connect(_on_player_state_changed)
	player.master_scene_event.connect(_on_master_scene_event)
	world_root.add_child(player)
	respawn_position = player.position
	world_camera = player.get_node("Camera2D") as Camera2D
	var camera_zoom := maxf(float(stage_profile.get("camera_zoom", 1.0)), 0.25)
	world_camera.zoom = Vector2(camera_zoom, camera_zoom)
	world_camera.limit_left = 0
	world_camera.limit_right = int(world_size.x)
	world_camera.limit_top = 0
	world_camera.limit_bottom = int(world_size.y)
	world_camera.enabled = true


func _build_environment_backdrop() -> void:
	var environment_index := clampi(int(stage_profile.get("environment_index", 0)), 0, ENVIRONMENT_COLUMNS - 1)
	var environment_texture := _atlas_region(ENVIRONMENT_ATLAS, environment_index, ENVIRONMENT_COLUMNS, 1)
	var tint: Color = stage_profile.get("accent", Color.CYAN)
	# Stretch one continuous backdrop through the full vertical course. Repeating
	# it every 440 pixels produced a visible horizontal seam during depth shifts.
	for x in range(0, int(world_size.x), 640):
		var backdrop := TextureRect.new()
		backdrop.name = "DepthBackdrop%02d" % (x / 640)
		backdrop.position = Vector2(x, 0)
		backdrop.size = Vector2(640, world_size.y)
		backdrop.texture = environment_texture
		backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		backdrop.modulate = Color(tint.r * 0.48 + 0.24, tint.g * 0.38 + 0.25, tint.b * 0.34 + 0.34, 0.46)
		backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		backdrop.z_index = -100
		world_root.add_child(backdrop)
	var darkness := Polygon2D.new()
	darkness.polygon = PackedVector2Array([Vector2.ZERO, Vector2(world_size.x, 0), world_size, Vector2(0, world_size.y)])
	darkness.color = Color(0.005, 0.008, 0.016, 0.42)
	darkness.z_index = -90
	world_root.add_child(darkness)


func _make_platform(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.name = "Platform"
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	var fill := Polygon2D.new()
	fill.polygon = PackedVector2Array([
		-rect.size * 0.5,
		Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
		rect.size * 0.5,
		Vector2(-rect.size.x * 0.5, rect.size.y * 0.5),
	])
	var is_climb_rail := rect.size.x <= 40.0 and rect.size.y >= 120.0
	fill.color = Color(0, 0, 0, 0) if is_climb_rail else stage_profile.get("platform_color", Color(0.08, 0.16, 0.22))
	body.add_child(fill)
	if is_climb_rail:
		# Keep the wall-cling collision but replace the screen-blocking vertical
		# stripe with a light two-edge climb rail.
		var rail_outline := Line2D.new()
		rail_outline.points = PackedVector2Array([
			Vector2(-rect.size.x * 0.5, rect.size.y * 0.5),
			Vector2(-rect.size.x * 0.5, -rect.size.y * 0.5),
			Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
			Vector2(rect.size.x * 0.5, rect.size.y * 0.5),
		])
		rail_outline.width = 2.0
		rail_outline.default_color = Color(stage_profile.get("accent", Color.CYAN), 0.58)
		rail_outline.antialiased = false
		body.add_child(rail_outline)
	var rim := Polygon2D.new()
	rim.polygon = PackedVector2Array([
		Vector2(-rect.size.x * 0.5, -rect.size.y * 0.5),
		Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
		Vector2(rect.size.x * 0.5, -rect.size.y * 0.5 + 4),
		Vector2(-rect.size.x * 0.5, -rect.size.y * 0.5 + 4),
	])
	rim.color = Color.TRANSPARENT if is_climb_rail else stage_profile.get("accent", Color.CYAN)
	body.add_child(rim)
	world_root.add_child(body)


func _build_descent_cues() -> void:
	# These small floor arrows only appear on authored descent routes. They are
	# visual nudges, not interactables, so they cannot interfere with pickups,
	# saves, gates, or collision.
	for cue_value in stage_profile.get("descent_cues", []):
		if not cue_value is Dictionary:
			continue
		var cue: Dictionary = cue_value
		var position: Vector2 = cue.get("position", Vector2.ZERO)
		var direction := str(cue.get("direction", "down"))
		var arrow := Polygon2D.new()
		arrow.name = "DescentCue"
		arrow.position = position
		arrow.polygon = _descent_cue_points(direction)
		arrow.color = Color(stage_profile.get("accent", Color.CYAN), 0.82)
		arrow.z_index = 3
		world_root.add_child(arrow)


func _descent_cue_points(direction: String) -> PackedVector2Array:
	match direction:
		"left":
			return PackedVector2Array([Vector2(8, -6), Vector2(8, 6), Vector2(-8, 0)])
		"right":
			return PackedVector2Array([Vector2(-8, -6), Vector2(-8, 6), Vector2(8, 0)])
		_:
			return PackedVector2Array([Vector2(-6, -8), Vector2(6, -8), Vector2(0, 8)])


func _build_static_hazards() -> void:
	for value in stage_profile.get("hazards", []):
		if not value is Rect2:
			continue
		var authored_rect: Rect2 = value
		# Trim static fields without turning them into a different obstacle. Their
		# lower edge stays nailed to the floor, while both the glow and damage area
		# lose twenty percent of their height.
		var reduced_height := authored_rect.size.y * 0.8
		var rect := Rect2(
			authored_rect.position + Vector2(0.0, authored_rect.size.y - reduced_height),
			Vector2(authored_rect.size.x, reduced_height)
		)
		hazards.append(rect)
		var hazard := Polygon2D.new()
		hazard.name = "StaticHazard"
		hazard.position = rect.get_center()
		hazard.polygon = PackedVector2Array([
			-rect.size * 0.5,
			Vector2(rect.size.x * 0.5, -rect.size.y * 0.5),
			rect.size * 0.5,
			Vector2(-rect.size.x * 0.5, rect.size.y * 0.5),
		])
		hazard.color = Color(stage_profile.get("secondary", Color.MAGENTA), 0.82)
		world_root.add_child(hazard)


func _build_moving_hazards() -> void:
	for value in stage_profile.get("moving_hazards", []):
		if not value is Dictionary:
			continue
		var definition: Dictionary = value.duplicate(true)
		var marker_size: Vector2 = definition.get("size", Vector2(42, 42))
		var marker := _make_prop_sprite(9, definition.get("position", Vector2.ZERO), marker_size, "MovingStatic")
		definition["size"] = marker_size
		definition["node"] = marker
		definition["origin_x"] = marker.position.x
		definition["direction"] = 1.0
		moving_hazards.append(definition)


func _build_collectibles() -> void:
	var cell := int(stage_profile.get("collectible_cell", 0))
	var positions: Array = stage_profile.get("collectibles", [])
	for index in range(positions.size()):
		var position: Vector2 = positions[index]
		var marker := _make_profile_prop_sprite("collectible_texture", cell, position, Vector2(56, 56), "Collectible%02d" % (index + 1))
		# Number labels live above the icon in the same high-contrast HUD face as
		# gates and saves. This stays readable at the zoomed-out adventure scale.
		var number := _make_world_label(marker, "%02d" % (index + 1), Rect2(-12, -38, 80, 30), 14)
		number.add_theme_font_override("font", READABLE_HUD_FONT)
		number.add_theme_color_override("font_color", Color.WHITE)
		number.add_theme_constant_override("outline_size", 1)
		collectibles.append({"position": position, "node": marker, "collected": false, "index": index})


func _build_keys() -> void:
	var positions: Array = stage_profile.get("keys", [])
	# Use one authored display size for every key. This keeps keys on upper and
	# sub-rails equally legible even when their source art has transparent padding.
	var key_size_value: Variant = stage_profile.get("key_size", Vector2(64, 64))
	var key_size := Vector2(64, 64)
	if key_size_value is Vector2:
		key_size = key_size_value
	for index in range(positions.size()):
		var position: Vector2 = positions[index]
		var marker := _make_profile_prop_sprite("key_texture", 7, position, key_size, "Key%02d" % (index + 1))
		keys.append({"position": position, "node": marker, "collected": false, "index": index})


func _build_portals() -> void:
	for value in stage_profile.get("portals", []):
		if not value is Dictionary:
			continue
		var portal: Dictionary = value.duplicate(true)
		var rect: Rect2 = portal.get("rect", Rect2())
		var marker_size := Vector2(66, 88)
		var marker_position := Vector2(rect.get_center().x, rect.end.y - marker_size.y * 0.5)
		var marker := _make_profile_prop_sprite("portal_texture", 8, marker_position, marker_size, "DepthPortal")
		var action := str(portal.get("action", "up"))
		_make_world_label(marker, "W / UP" if action == "up" else "S / DOWN", Rect2(-18, -36, 102, 30), 14, 220.0)
		portal["node"] = marker
		portals.append(portal)


func _build_checkpoints() -> void:
	for index in range(checkpoints.size()):
		var checkpoint: Dictionary = checkpoints[index]
		var threshold_x := float(checkpoint.get("x", 0.0))
		var marker_size := Vector2(72, 88)
		var marker_position: Vector2 = checkpoint.get("position", Vector2(threshold_x, 900.0 - marker_size.y * 0.5))
		var marker := _make_texture_sprite(CHECKPOINT_FLAG, marker_position, marker_size, "Threshold%02d" % (index + 1))
		_make_world_label(marker, "SAVE", Rect2(-16, -36, 104, 30), 14, 220.0)
		marker.modulate = Color(0.78, 0.84, 0.92, 1.0)
		checkpoint["node"] = marker


func _build_goal() -> void:
	goal_rect = stage_profile.get("goal", Rect2(6170, 800, 70, 100))
	var marker_size := Vector2(78, 96)
	var marker_position := Vector2(goal_rect.get_center().x, goal_rect.end.y - marker_size.y * 0.5)
	var marker := _make_profile_prop_sprite("goal_texture", 11, marker_position, marker_size, "ExitBeacon")
	_make_world_label(marker, "EXIT", Rect2(-16, -38, 104, 30), 14)


func _build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "HybridHUD"
	hud_layer.layer = 20
	add_child(hud_layer)
	var top_panel := _make_panel(hud_layer, "TopPanel", TOP_HUD_RECT, stage_profile.get("accent", Color.CYAN))
	var title := _make_label(top_panel, "TitleLabel", Rect2(10, 7, 412, 23), str(stage_profile.get("title", "DEPTH TRAVERSE")), 14, true)
	MINIGAME_UI.configure_label(title, MinigameUI.TextRole.TITLE, false, true, 11, 14, Vector2(3, 1))
	var objective_text := BALANCED_TEXT.split_balanced(str(stage_profile.get("objective", "Explore the route.")), 54)
	var objective := _make_label(top_panel, "ObjectiveLabel", Rect2(12, 32, 408, 41), objective_text, 11, true)
	MINIGAME_UI.configure_label(objective, MinigameUI.TextRole.BODY, true, true, 9, 11, Vector2(3, 1))
	counter_label = _make_label(top_panel, "CounterLabel", Rect2(430, 3, 184, 30), "", 10, true)
	MINIGAME_UI.configure_label(counter_label, MinigameUI.TextRole.HUD, true, true, 8, 10, Vector2(2, 1))
	energy_label = _make_label(top_panel, "EnergyLabel", Rect2(430, 34, 184, 13), "WALL ENERGY 100", 9, true)
	MINIGAME_UI.configure_label(energy_label, MinigameUI.TextRole.COMPACT, false, true, 8, 9, Vector2(2, 0))
	energy_bar = ProgressBar.new()
	energy_bar.name = "JumpEnergyBar"
	energy_bar.position = Vector2(444, 49)
	energy_bar.size = Vector2(156, 8)
	energy_bar.max_value = 100.0
	energy_bar.value = 100.0
	energy_bar.show_percentage = false
	var energy_bg := StyleBoxFlat.new()
	energy_bg.bg_color = Color(0.02, 0.03, 0.05, 0.94)
	var energy_fill := StyleBoxFlat.new()
	energy_fill.bg_color = stage_profile.get("secondary", Color.MAGENTA)
	energy_bar.add_theme_stylebox_override("background", energy_bg)
	energy_bar.add_theme_stylebox_override("fill", energy_fill)
	top_panel.add_child(energy_bar)
	zone_label = _make_label(top_panel, "ZoneLabel", Rect2(430, 59, 184, 12), "ENTRY DEPTH", 9, true)
	MINIGAME_UI.configure_label(zone_label, MinigameUI.TextRole.COMPACT, false, true, 8, 9, Vector2(2, 0))

	_make_world_frame(ADVENTURE_VIEW_RECT, stage_profile.get("accent", Color.CYAN))
	var status_panel := _make_panel(hud_layer, "StatusPanel", STATUS_HUD_RECT, stage_profile.get("secondary", Color.MAGENTA))
	status_label = _make_label(status_panel, "StatusLabel", Rect2(7, 5, 292, 68), "", 16, true)
	MINIGAME_UI.configure_label(status_label, MinigameUI.TextRole.HUD, true, true, 14, 16, Vector2(4, 2))
	status_label.add_theme_font_override("font", READABLE_HUD_FONT)
	MINIGAME_UI.fit_label(status_label)
	var controls_panel := _make_panel(hud_layer, "ControlsPanel", CONTROLS_HUD_RECT, stage_profile.get("accent", Color.CYAN))
	var controls := _make_label(controls_panel, "ControlsLabel", Rect2(7, 5, 300, 68), str(stage_profile.get("controls", "A/D MOVE   SPACE JUMP")), 13, true)
	MINIGAME_UI.configure_label(controls, MinigameUI.TextRole.COMPACT, false, true, 11, 13, Vector2(3, 2))
	controls.add_theme_font_override("font", READABLE_HUD_FONT)
	MINIGAME_UI.fit_label(controls)

	reset_button = Button.new()
	reset_button.name = "ResetButton"
	reset_button.position = Vector2(548, 90)
	reset_button.size = Vector2(80, 28)
	reset_button.text = "Reset (R)"
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_reset_stage)
	hud_layer.add_child(reset_button)
	MINIGAME_UI.configure_button(reset_button, 10, 12, 5)
	reset_button.visible = bool(stage_profile.get("show_reset_button", false))

	completion_panel = _make_panel(hud_layer, "CompletionPanel", Rect2(96, 142, 448, 166), Color(0.96, 0.72, 0.22))
	completion_panel.visible = false
	var complete_title := _make_label(completion_panel, "CompleteTitle", Rect2(16, 14, 416, 30), "DEPTH ROUTE COMPLETE", 16, true)
	MINIGAME_UI.configure_label(complete_title, MinigameUI.TextRole.TITLE, false, true, 11, 16, Vector2(3, 2))
	var complete_copy := _make_label(completion_panel, "CompleteCopy", Rect2(24, 50, 400, 60), str(stage_profile.get("completion_text", "Route complete.")), 14, true)
	MINIGAME_UI.configure_label(complete_copy, MinigameUI.TextRole.BODY, true, true, 10, 14, Vector2(5, 3))
	return_button = Button.new()
	return_button.name = "ReturnButton"
	return_button.position = Vector2(104, 118)
	return_button.size = Vector2(240, 34)
	return_button.text = "Return to Arcade"
	return_button.pressed.connect(_on_return_pressed)
	completion_panel.add_child(return_button)


func _build_pause_menu() -> void:
	if get_node_or_null("PauseMenu") != null:
		return
	var pause_menu := PAUSE_MENU_SCENE.instantiate()
	pause_menu.name = "PauseMenu"
	pause_menu.set("is_minigame_context", true)
	add_child(pause_menu)


func _physics_process(delta: float) -> void:
	if player == null or completed or return_in_progress:
		return
	portal_cooldown = maxf(0.0, portal_cooldown - delta)
	hazard_immunity = maxf(0.0, hazard_immunity - delta)
	status_timer = maxf(0.0, status_timer - delta)
	order_lock_cooldown = maxf(0.0, order_lock_cooldown - delta)
	_update_moving_hazards(delta)
	_check_collectibles()
	_check_keys()
	_check_hazards()
	_check_portals()
	_check_checkpoints()
	_check_goal()
	if player.position.y > world_size.y + 40.0:
		_soft_respawn("VOID SIGNAL. Returned to the last threshold.")
	if status_timer <= 0.0:
		_set_status(_get_idle_status(), 0.0)


func _process(_delta: float) -> void:
	_update_marker_screen_labels()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_reset_stage()


func _check_collectibles() -> void:
	var player_rect := Rect2(player.position - PLAYER_HITBOX * 0.5, PLAYER_HITBOX)
	for value in collectibles:
		var item: Dictionary = value
		if bool(item["collected"]):
			continue
		var item_position: Vector2 = item["position"]
		if not player_rect.grow(14.0).has_point(item_position):
			continue
		var index := int(item["index"])
		if bool(stage_profile.get("ordered_collectibles", false)) and index != next_collectible_index:
			if order_lock_cooldown <= 0.0:
				_set_status("ORDER LOCK: %s %02d glows brighter and must be recovered next." % [str(stage_profile.get("collectible_name", "Signal")), next_collectible_index + 1], 1.3)
				_play_audio("play_error_buzz")
				order_lock_cooldown = 0.65
			continue
		item["collected"] = true
		var marker := item["node"] as CanvasItem
		marker.visible = false
		var marker_label := marker.get_meta(&"world_label", null) as CanvasItem
		if marker_label != null:
			marker_label.visible = false
		collected_count += 1
		next_collectible_index += 1
		_refresh_collectible_guidance()
		_set_status("%s %02d recovered. Follow the next glow." % [str(stage_profile.get("collectible_name", "Signal")), index + 1], 1.7)
		_play_audio("play_score_blip")
		_refresh_hud()


func _check_keys() -> void:
	var player_rect := Rect2(player.position - PLAYER_HITBOX * 0.5, PLAYER_HITBOX)
	for value in keys:
		var item: Dictionary = value
		if bool(item["collected"]):
			continue
		if not player_rect.grow(14.0).has_point(item["position"]):
			continue
		item["collected"] = true
		(item["node"] as CanvasItem).visible = false
		keys_collected += 1
		_set_status("%s %d / %d secured." % [str(stage_profile.get("key_name", "Anchor")), keys_collected, int(stage_profile.get("required_keys", 3))], 2.0)
		_play_audio("play_score_blip")
		_refresh_hud()


func _check_hazards() -> void:
	if hazard_immunity > 0.0:
		return
	var player_rect := Rect2(player.position - PLAYER_HITBOX * 0.5, PLAYER_HITBOX)
	for hazard in hazards:
		if player_rect.intersects(hazard):
			_soft_respawn("STATIC CONTACT. Progress held; position restored.")
			return
	for value in moving_hazards:
		var hazard: Dictionary = value
		var node := hazard["node"] as Control
		if player_rect.intersects(Rect2(node.position, node.size)):
			_soft_respawn("MOVING STATIC. Progress held; position restored.")
			return


func _check_portals() -> void:
	if portal_cooldown > 0.0:
		return
	var player_rect := Rect2(player.position - PLAYER_HITBOX * 0.5, PLAYER_HITBOX)
	for value in portals:
		var portal: Dictionary = value
		if not player_rect.intersects(portal.get("rect", Rect2())):
			continue
		var action := str(portal.get("action", "up"))
		var activated := Input.is_action_pressed("move_up") if action == "up" else Input.is_action_pressed("move_down")
		if not activated:
			continue
		player.respawn_at(portal.get("target", player.position))
		if world_camera != null:
			world_camera.reset_smoothing()
		portal_cooldown = 0.7
		hazard_immunity = 0.55
		_set_status("DEPTH SHIFT: %s." % str(portal.get("label", "connected layer")), 2.0)
		player.report_to_master_3d(&"depth_shift", {"stage_id": stage_id, "portal_label": portal.get("label", "")})
		_play_audio("play_interact")
		return


func _check_checkpoints() -> void:
	var player_rect := Rect2(player.position - PLAYER_HITBOX * 0.5, PLAYER_HITBOX)
	for index in range(checkpoints.size()):
		if index <= checkpoint_index:
			continue
		var checkpoint: Dictionary = checkpoints[index]
		var reached := false
		var trigger_value: Variant = checkpoint.get("rect", null)
		if trigger_value is Rect2:
			reached = player_rect.intersects(trigger_value)
		else:
			reached = player.position.x >= float(checkpoint.get("x", INF))
		if not reached:
			continue
		checkpoint_index = index
		respawn_position = checkpoint.get("spawn", player.position)
		zone_label.text = str(checkpoint.get("name", "DEPTH %d" % (index + 1)))
		var marker := checkpoint.get("node") as CanvasItem
		if marker != null:
			marker.modulate = Color.WHITE
		_set_status("THRESHOLD ANCHORED: %s." % zone_label.text, 1.6)
		_play_audio("play_button_pulse")


func _check_goal() -> void:
	var player_rect := Rect2(player.position - PLAYER_HITBOX * 0.5, PLAYER_HITBOX)
	if not player_rect.intersects(goal_rect):
		return
	var required_collectibles := int(stage_profile.get("required_collectibles", collectibles.size()))
	var required_keys := int(stage_profile.get("required_keys", keys.size()))
	if collected_count < required_collectibles or keys_collected < required_keys:
		_set_status("EXIT LOCKED: %s %d/%d  //  %s %d/%d" % [
			str(stage_profile.get("collectible_name", "Signals")), collected_count, required_collectibles,
			str(stage_profile.get("key_name", "Anchors")), keys_collected, required_keys,
		], 1.5)
		return
	_complete_stage()


func _complete_stage() -> void:
	if completed:
		return
	completed = true
	player.set_movement_enabled(false)
	_on_stage_completed()
	player.report_to_master_3d(&"stage_complete", {"stage_id": stage_id, "collectibles": collected_count, "keys": keys_collected})
	_play_audio("play_success_jingle")
	completion_panel.visible = true
	reset_button.visible = false
	return_button.grab_focus()


func _complete_run() -> void:
	# Compatibility hook used by existing QA and replay tooling.
	collected_count = int(stage_profile.get("required_collectibles", collectibles.size()))
	keys_collected = int(stage_profile.get("required_keys", keys.size()))
	_complete_stage()


func _soft_respawn(message: String) -> void:
	player.respawn_at(respawn_position)
	if world_camera != null:
		world_camera.reset_smoothing()
	hazard_immunity = 1.0
	portal_cooldown = 0.5
	_set_status(message, 2.0)
	_play_audio("play_error_buzz")


func _update_moving_hazards(delta: float) -> void:
	for value in moving_hazards:
		var hazard: Dictionary = value
		var node := hazard["node"] as Control
		var origin_x := float(hazard["origin_x"])
		var travel_range := float(hazard.get("range", 180.0))
		node.position.x += float(hazard.get("speed", 70.0)) * float(hazard["direction"]) * delta
		if node.position.x >= origin_x + travel_range:
			node.position.x = origin_x + travel_range
			hazard["direction"] = -1.0
		elif node.position.x <= origin_x:
			node.position.x = origin_x
			hazard["direction"] = 1.0


func _refresh_hud() -> void:
	if counter_label == null:
		return
	var required_collectibles := int(stage_profile.get("required_collectibles", collectibles.size()))
	var required_keys := int(stage_profile.get("required_keys", keys.size()))
	counter_label.text = "%s %d/%d\n%s %d/%d" % [
		str(stage_profile.get("collectible_name", "Signals")), collected_count, required_collectibles,
		str(stage_profile.get("key_name", "Anchors")), keys_collected, required_keys,
	]
	MINIGAME_UI.fit_label(counter_label)
	_refresh_collectible_guidance()


func _refresh_collectible_guidance() -> void:
	var ordered := bool(stage_profile.get("ordered_collectibles", false))
	for value in collectibles:
		var item: Dictionary = value
		var node := item.get("node") as CanvasItem
		if node == null or bool(item.get("collected", false)):
			continue
		if not ordered or int(item.get("index", -1)) == next_collectible_index:
			node.modulate = Color.WHITE
		else:
			node.modulate = Color(0.56, 0.62, 0.72, 0.54)
		var marker_label := node.get_meta(&"world_label", null) as CanvasItem
		if marker_label != null:
			marker_label.modulate = node.modulate


func _get_idle_status() -> String:
	if bool(stage_profile.get("ordered_collectibles", false)) and next_collectible_index < collectibles.size():
		return "NEXT: %s %02d glows brightly. Follow its signal." % [str(stage_profile.get("collectible_name", "Signal")), next_collectible_index + 1]
	return "Find the remaining markers. Portal controls appear when you are nearby."


func _set_status(message: String, duration := 1.8) -> void:
	if status_label == null:
		return
	status_label.text = BALANCED_TEXT.split_balanced(message, 42)
	status_timer = duration
	MINIGAME_UI.fit_label(status_label)


func _on_jump_energy_changed(current: float, maximum: float) -> void:
	if energy_bar == null:
		return
	energy_bar.max_value = maximum
	energy_bar.value = current
	energy_label.text = "WALL ENERGY %03d" % roundi(current)
	MINIGAME_UI.fit_label(energy_label)


func _on_player_state_changed(_previous: HybridExplorerController.MovementState, current: HybridExplorerController.MovementState) -> void:
	if current == HybridExplorerController.MovementState.WALL_CLING and status_timer <= 0.0:
		_set_status("WALL CLING: Jump kicks away. Hold W while jumping to spend 25 wall energy and rise.", 1.2)


func _on_master_scene_event(payload: Dictionary) -> void:
	# A host that embeds this 2D stage inside a 3D scene can connect here and use
	# the plain Dictionary payload to update its 3D world/camera state.
	hybrid_transition_requested.emit(payload)


func _reset_stage() -> void:
	if return_in_progress or player == null:
		return
	# Reset is a recovery action during exploration. Rebuilding the stage here
	# silently discarded the active checkpoint and made every save look broken.
	_soft_respawn("RESET: Returned to the last threshold.")
	_play_audio("play_button_pulse")


func is_hybrid_adventure() -> bool:
	return true


func _on_stage_completed() -> void:
	match stage_id:
		"prize_shelf_run":
			GameState.complete_pip_secret()
		"static_service_run":
			GameState.complete_static_service_run()
		"night_ledger_run":
			GameState.complete_night_ledger_run()


func _on_return_pressed() -> void:
	if return_in_progress:
		return
	return_in_progress = true
	get_tree().paused = false
	match stage_id:
		"snack_service_dash":
			GameState.set_pending_spawn_id("Spawn_FromSnackAdventure")
			SceneChanger.go_to_snack_alcove()
		"prize_shelf_run":
			GameState.set_pending_spawn_id("Spawn_FromPrizeAdventure")
			SceneChanger.go_to_prize_corner()
		"static_service_run":
			GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
			SceneChanger.go_to_maintenance_hall()
		"night_ledger_run":
			if not SceneChanger.go_to_return_point():
				SceneChanger.go_to_snack_hallway()
		_:
			GameState.set_pending_spawn_id("Spawn_FromHubAdventure")
			SceneChanger.go_to_arcade_hub()


func can_open_pause_menu() -> bool:
	return not return_in_progress


func _make_panel(parent: Node, node_name: String, rect: Rect2, border_color: Color) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", MINIGAME_UI.make_panel_style(border_color, Color(0.004, 0.008, 0.015, 0.94)))
	parent.add_child(panel)
	return panel


func _make_world_frame(rect: Rect2, border_color: Color) -> Panel:
	var frame := Panel.new()
	frame.name = "AdventureViewFrame"
	frame.position = rect.position
	frame.size = rect.size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = border_color
	style.set_border_width_all(2)
	frame.add_theme_stylebox_override("panel", style)
	hud_layer.add_child(frame)
	return frame


func _make_label(parent: Node, node_name: String, rect: Rect2, text_value: String, font_size: int, centered: bool) -> Label:
	var label := Label.new()
	label.name = node_name
	label.position = rect.position
	label.size = rect.size
	label.text = text_value
	label.add_theme_font_override("font", MINIGAME_UI.BODY_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _make_world_label(parent: Node, text_value: String, rect: Rect2, font_size: int, proximity_radius := 0.0) -> Label:
	# These captions must not live inside the SubViewport: Camera2D zoom turns a
	# crisp font into filtered pixel fragments. Render them in screen space, then
	# project their marker position through the camera each frame instead.
	var marker := parent as Control
	var compact_font_size := clampi(font_size, 13, 14)
	var text_size := READABLE_HUD_FONT.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, compact_font_size).ceil()
	var label_size := text_size + Vector2(8.0, 6.0)
	var label_name := "%sLabel" % marker.name if marker != null else "WorldLabel"
	var label := _make_label(self, label_name, Rect2(Vector2.ZERO, label_size), text_value, compact_font_size, true)
	label.set_meta(MINIGAME_UI.META_IGNORE, true)
	label.z_index = 8
	label.add_theme_font_override("font", READABLE_HUD_FONT)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0.002, 0.004, 0.012, 1.0))
	label.add_theme_constant_override("outline_size", 1)
	var label_backing := StyleBoxFlat.new()
	label_backing.bg_color = Color(0.0, 0.0, 0.0, 0.88)
	label_backing.corner_radius_top_left = 2
	label_backing.corner_radius_top_right = 2
	label_backing.corner_radius_bottom_left = 2
	label_backing.corner_radius_bottom_right = 2
	label_backing.content_margin_left = 2.0
	label_backing.content_margin_right = 2.0
	label_backing.content_margin_top = 1.0
	label_backing.content_margin_bottom = 1.0
	label.add_theme_stylebox_override("normal", label_backing)
	parent.set_meta(&"world_label", label)
	if marker != null:
		var marker_center := marker.position + marker.size * 0.5
		var caption_center := marker.position + rect.position + rect.size * 0.5
		marker_screen_labels.append({
			"label": label,
			"marker": marker,
			"world_offset": caption_center - marker_center,
			"proximity_radius": proximity_radius,
		})
	return label


func _update_marker_screen_labels() -> void:
	if world_camera == null or adventure_viewport == null:
		return
	var camera_center := world_camera.get_screen_center_position()
	var viewport_size := Vector2(adventure_viewport.size)
	var zoom := world_camera.zoom
	var view_bounds := ADVENTURE_VIEW_RECT
	for value in marker_screen_labels:
		var entry: Dictionary = value
		var label := entry.get("label") as Label
		var marker := entry.get("marker") as Control
		if label == null or marker == null or not is_instance_valid(label) or not is_instance_valid(marker):
			continue
		if not marker.visible:
			label.visible = false
			continue
		var marker_center := marker.position + marker.size * 0.5
		var proximity_radius := float(entry.get("proximity_radius", 0.0))
		if proximity_radius > 0.0 and player != null and player.position.distance_to(marker_center) > proximity_radius:
			label.visible = false
			continue
		var world_offset: Vector2 = entry.get("world_offset", Vector2.ZERO)
		var world_anchor := marker_center + world_offset
		var viewport_anchor := (world_anchor - camera_center) * zoom + viewport_size * 0.5
		var screen_anchor := ADVENTURE_VIEW_RECT.position + viewport_anchor
		var half_label := label.size * 0.5
		var label_rect := Rect2(screen_anchor - half_label, label.size)
		# Do not pin distant captions to the field edges. That made markers outside
		# the camera pile into an unreadable column at the side of the screen.
		if not view_bounds.encloses(label_rect):
			label.visible = false
			continue
		label.position = label_rect.position
		label.visible = true


func _make_prop_sprite(cell_index: int, position: Vector2, size: Vector2, node_name: String) -> TextureRect:
	return _make_texture_sprite(_atlas_region(PROP_ATLAS, cell_index, PROP_COLUMNS, PROP_ROWS), position, size, node_name)


func _make_profile_prop_sprite(profile_key: String, fallback_cell: int, position: Vector2, size: Vector2, node_name: String) -> TextureRect:
	var texture_path := str(stage_profile.get(profile_key, ""))
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		var resource := load(texture_path)
		if resource is Texture2D:
			return _make_texture_sprite(resource as Texture2D, position, size, node_name)
	return _make_prop_sprite(fallback_cell, position, size, node_name)


func _make_texture_sprite(texture: Texture2D, position: Vector2, size: Vector2, node_name: String) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.name = node_name
	sprite.position = position - size * 0.5
	sprite.size = size
	sprite.texture = texture
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world_root.add_child(sprite)
	return sprite


func _atlas_region(texture: Texture2D, index: int, columns: int, rows: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	var cell_size := Vector2(texture.get_width() / float(columns), texture.get_height() / float(rows))
	var column := index % columns
	var row := index / columns
	atlas.region = Rect2(Vector2(column, row) * cell_size, cell_size)
	return atlas


func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
