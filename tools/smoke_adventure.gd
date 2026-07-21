extends SceneTree
## Headless contract test for every authored hybrid exploration stage.

const CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")
const PLAYER_SIZE := Vector2(18, 28)
const MOVING_HAZARD_SIZE := Vector2(42, 42)
const MAX_SAFE_DROP := 220.0
const EXPLORER_PATH := NodePath("AdventureView/WorldViewport/HybridWorld/Explorer")

var targets: Array[Dictionary] = [
	{"id": "snack_service_dash", "scene": "res://scenes/minigames/SnackServiceDash.tscn"},
	{"id": "prize_shelf_run", "scene": "res://scenes/minigames/PrizeShelfRun.tscn"},
	{"id": "static_service_run", "scene": "res://scenes/minigames/StaticServiceRun.tscn"},
	{"id": "night_ledger_run", "scene": "res://scenes/minigames/NightLedgerRun.tscn"},
]

var errors: Array[String] = []
var target_index := 0
var frame_count := 0
var stage: Node
var movement_start_x := 0.0


func _initialize() -> void:
	_check_catalog()


func _process(_delta: float) -> bool:
	if stage == null:
		if target_index >= targets.size():
			_finish()
			return true
		var packed := load(str(targets[target_index]["scene"])) as PackedScene
		_expect(packed != null, "%s scene loads" % targets[target_index]["id"])
		if packed == null:
			target_index += 1
			return false
		stage = packed.instantiate()
		root.add_child(stage)
		frame_count = 0
		return false
	frame_count += 1
	if frame_count == 2:
		_check_live_stage()
		var explorer := stage.get_node(EXPLORER_PATH) as CharacterBody2D
		movement_start_x = explorer.position.x
		Input.action_press("move_right")
	elif frame_count == 10:
		Input.action_release("move_right")
		_check_live_playability()
		stage.call("_reset_stage")
	elif frame_count == 13:
		_expect(stage.has_node(EXPLORER_PATH), "%s reset rebuilds the explorer" % _current_id())
		_expect(stage.has_node("HybridHUD/TopPanel/TitleLabel"), "%s reset rebuilds its centered HUD" % _current_id())
		_expect(stage.has_node("PauseMenu"), "%s keeps ESC pause coverage" % _current_id())
	elif frame_count >= 16:
		stage.free()
		stage = null
		target_index += 1
	return false


func _check_catalog() -> void:
	_expect(CATALOG.get_all_stage_ids().size() == 4, "catalog exposes all four adventure stages")
	var course_signatures: Dictionary = {}
	for id in CATALOG.get_all_stage_ids():
		var profile := CATALOG.get_profile(id)
		_expect(str(profile.get("type")) == "hybrid_scrolling_platform_adventure", "%s uses the hybrid stage contract" % id)
		_expect(int(profile.get("target_duration_seconds", 0)) >= 180, "%s targets at least three minutes" % id)
		_expect(int(profile.get("target_duration_seconds", 999)) <= 240, "%s stays within the four-minute target" % id)
		_expect(int(profile.get("max_midair_jumps", 0)) == 3, "%s grants three mid-air jumps" % id)
		_expect(bool(profile.get("variable_jump", false)), "%s enables variable jump height" % id)
		_expect(bool(profile.get("wall_cling", false)) and bool(profile.get("wall_kick", false)), "%s enables wall traversal" % id)
		_expect((profile.get("portals", []) as Array).size() >= 4, "%s has layered portal exploration" % id)
		_expect((profile.get("checkpoints", []) as Array).size() >= 4, "%s has four progression thresholds" % id)
		_expect((profile.get("keys", []) as Array).size() == int(profile.get("required_keys", 0)), "%s authors every required key" % id)
		_expect((profile.get("collectibles", []) as Array).size() == int(profile.get("required_collectibles", 0)), "%s authors every required collectible" % id)
		_check_route_safety(id, profile)
		course_signatures[str(profile.get("course"))] = true
	_expect(course_signatures.size() >= 3, "catalog uses at least three authored course families")


func _check_route_safety(id: String, profile: Dictionary) -> void:
	var platforms: Array = profile.get("platforms", [])
	var static_hazards: Array = profile.get("hazards", [])
	var moving_hazards: Array = profile.get("moving_hazards", [])
	var start_position: Vector2 = profile.get("start_position", Vector2.ZERO)
	_expect(_is_safe_spawn(start_position, platforms, static_hazards, moving_hazards), "%s starts above a safe landing" % id)

	var checkpoints_safe := true
	for checkpoint_value in profile.get("checkpoints", []):
		var checkpoint: Dictionary = checkpoint_value
		if not _is_safe_spawn(checkpoint.get("spawn", Vector2.ZERO), platforms, static_hazards, moving_hazards):
			checkpoints_safe = false
			break
	_expect(checkpoints_safe, "%s keeps every checkpoint outside solids and hazard sweeps" % id)

	var portal_targets_safe := true
	for portal_value in profile.get("portals", []):
		var portal: Dictionary = portal_value
		if not _is_safe_spawn(portal.get("target", Vector2.ZERO), platforms, static_hazards, moving_hazards):
			portal_targets_safe = false
			break
	_expect(portal_targets_safe, "%s gives every portal a supported, hazard-free landing" % id)

	var collectibles_reachable := true
	for collectible_value in profile.get("collectibles", []):
		if not _is_pickup_near_route(collectible_value, platforms):
			collectibles_reachable = false
			break
	for key_value in profile.get("keys", []):
		if not _is_pickup_near_route(key_value, platforms):
			collectibles_reachable = false
			break
	_expect(collectibles_reachable, "%s places every required pickup beside reachable route geometry" % id)

	if bool(profile.get("ordered_collectibles", false)):
		_expect(_is_monotonic_route(profile.get("collectibles", [])), "%s ordered route never requires blind backtracking" % id)

	var controls := str(profile.get("controls", "")).to_upper()
	_expect(controls.contains("PORTAL") and controls.contains("RESET") and controls.contains("PAUSE"), "%s HUD explains portals, retry, and pause" % id)


func _is_monotonic_route(collectibles: Array) -> bool:
	# Ordered routes progress steadily along one axis in one direction; the
	# axis depends on the course (horizontal runs vs descent/climb shafts).
	if collectibles.size() < 2:
		return true
	var x_up := true
	var x_down := true
	var y_up := true
	var y_down := true
	var previous: Vector2 = collectibles[0]
	for index in range(1, collectibles.size()):
		var point: Vector2 = collectibles[index]
		if point.x <= previous.x:
			x_up = false
		if point.x >= previous.x:
			x_down = false
		if point.y <= previous.y:
			y_up = false
		if point.y >= previous.y:
			y_down = false
		previous = point
	return x_up or x_down or y_up or y_down


func _is_safe_spawn(position: Vector2, platforms: Array, static_hazards: Array, moving_hazards: Array) -> bool:
	var initial_rect := Rect2(position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
	for hazard_value in static_hazards:
		if initial_rect.intersects(hazard_value):
			return false
	for hazard_value in moving_hazards:
		if initial_rect.intersects(_moving_hazard_sweep(hazard_value)):
			return false
	for platform_value in platforms:
		var platform: Rect2 = platform_value
		if not initial_rect.intersects(platform):
			continue
		# A spawn seated on a platform top is standing, not embedded: the
		# controller snaps shallow first-frame overlap out onto the surface.
		if position.y <= platform.position.y + 8.0:
			return true
		return false

	var landing_top := _find_landing_top(position, platforms)
	if is_inf(landing_top):
		return false
	if landing_top - (position.y + PLAYER_SIZE.y * 0.5) > MAX_SAFE_DROP:
		return false
	var landing_rect := Rect2(Vector2(position.x - PLAYER_SIZE.x * 0.5, landing_top - PLAYER_SIZE.y), PLAYER_SIZE)
	for hazard_value in static_hazards:
		if landing_rect.intersects(hazard_value):
			return false
	for hazard_value in moving_hazards:
		if landing_rect.intersects(_moving_hazard_sweep(hazard_value)):
			return false
	return true


func _find_landing_top(position: Vector2, platforms: Array) -> float:
	var player_bottom := position.y + PLAYER_SIZE.y * 0.5
	var nearest_top := INF
	for platform_value in platforms:
		var platform: Rect2 = platform_value
		if platform.size.x < 48.0:
			continue
		if position.x - PLAYER_SIZE.x * 0.5 < platform.position.x:
			continue
		if position.x + PLAYER_SIZE.x * 0.5 > platform.end.x:
			continue
		if platform.position.y + 0.01 < player_bottom:
			continue
		nearest_top = minf(nearest_top, platform.position.y)
	return nearest_top


func _is_pickup_near_route(value: Variant, platforms: Array) -> bool:
	if not value is Vector2:
		return false
	var position: Vector2 = value
	for platform_value in platforms:
		var platform: Rect2 = platform_value
		if platform.size.x >= 80.0:
			var above_surface := platform.position.y - position.y
			if position.x >= platform.position.x - 24.0 and position.x <= platform.end.x + 24.0 and above_surface >= 0.0 and above_surface <= 90.0:
				return true
		else:
			var beside_wall := minf(absf(position.x - platform.position.x), absf(position.x - platform.end.x))
			if beside_wall <= 42.0 and position.y >= platform.position.y - 70.0 and position.y <= platform.end.y:
				return true
	return false


func _moving_hazard_sweep(value: Variant) -> Rect2:
	if not value is Dictionary:
		return Rect2()
	var hazard: Dictionary = value
	var center: Vector2 = hazard.get("position", Vector2.ZERO)
	var travel_range := float(hazard.get("range", 0.0))
	return Rect2(center - MOVING_HAZARD_SIZE * 0.5, Vector2(travel_range + MOVING_HAZARD_SIZE.x, MOVING_HAZARD_SIZE.y))


func _check_live_stage() -> void:
	var id := _current_id()
	var profile: Dictionary = stage.get("stage_profile")
	_expect(str(stage.get("stage_id")) == id, "%s selects the correct authored profile" % id)
	_expect(stage.has_node(EXPLORER_PATH), "%s instantiates CharacterBody2D explorer" % id)
	_expect(stage.has_node("AdventureView/WorldViewport/HybridWorld/DepthBackdrop00"), "%s uses the generated pixel environment atlas" % id)
	_expect(stage.has_node("HybridHUD/TopPanel/TitleLabel"), "%s builds the shared title panel" % id)
	_expect(stage.has_node("HybridHUD/StatusPanel/StatusLabel"), "%s builds the shared centered status panel" % id)
	var view := stage.get_node_or_null("AdventureView") as Control
	var top_panel := stage.get_node_or_null("HybridHUD/TopPanel") as Control
	var status_panel := stage.get_node_or_null("HybridHUD/StatusPanel") as Control
	var controls_panel := stage.get_node_or_null("HybridHUD/ControlsPanel") as Control
	var camera := stage.get_node_or_null(NodePath(str(EXPLORER_PATH) + "/Camera2D")) as Camera2D
	_expect(view != null and view.position.y >= 88.0 and view.size.y >= 260.0, "%s reserves the middle screen for play" % id)
	_expect(top_panel != null and top_panel.size.y <= 80.0, "%s keeps its top HUD within twenty percent" % id)
	_expect(status_panel != null and controls_panel != null and status_panel.position.y >= view.position.y + view.size.y, "%s keeps NEXT and controls below the play view" % id)
	_expect(camera != null and camera.zoom.x <= 0.66, "%s zooms out to preserve vertical route visibility" % id)
	_expect(stage.has_node("PauseMenu"), "%s supports the shared pause menu" % id)
	_expect(stage.has_node("ArcadeCRTOverlay"), "%s keeps the arcade presentation overlay" % id)
	var explorer := stage.get_node_or_null(EXPLORER_PATH)
	_expect(explorer is CharacterBody2D, "%s explorer uses move-and-slide physics body" % id)
	_expect(explorer != null and int(explorer.get("max_midair_jumps")) == 3, "%s configures three mid-air jumps" % id)
	_expect((stage.get("collectibles") as Array).size() == int(profile.get("required_collectibles")), "%s spawns the full collection route" % id)
	_expect((stage.get("keys") as Array).size() == int(profile.get("required_keys", 0)), "%s spawns all exploration keys" % id)
	_expect((stage.get("moving_hazards") as Array).size() + (stage.get("hazards") as Array).size() >= 1, "%s includes traversal hazards" % id)


func _check_live_playability() -> void:
	var id := _current_id()
	var explorer := stage.get_node(EXPLORER_PATH) as CharacterBody2D
	_expect(explorer.position.x > movement_start_x + 0.5, "%s responds to held movement input" % id)

	var live_collectibles: Array = stage.get("collectibles")
	var first_collectible: Dictionary = live_collectibles[0]
	explorer.position = first_collectible["position"]
	stage.call("_check_collectibles")
	_expect(int(stage.get("collected_count")) == 1, "%s collects its first route pickup" % id)
	stage.call("_soft_respawn", "QA RESPAWN")
	_expect(int(stage.get("collected_count")) == 1, "%s preserves pickups through hazard recovery" % id)

	var live_portals: Array = stage.get("portals")
	var first_portal: Dictionary = live_portals[0]
	var portal_rect: Rect2 = first_portal["rect"]
	var portal_action := "move_up" if str(first_portal.get("action", "up")) == "up" else "move_down"
	explorer.position = portal_rect.get_center()
	stage.set("portal_cooldown", 0.0)
	Input.action_press(portal_action)
	stage.call("_check_portals")
	Input.action_release(portal_action)
	_expect(explorer.position.is_equal_approx(first_portal["target"]), "%s activates a marked depth portal" % id)


func _current_id() -> String:
	return str(targets[target_index]["id"])


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		errors.append(label)
		push_error("FAIL: %s" % label)


func _finish() -> void:
	if errors.is_empty():
		print("ADVENTURE SMOKE: PASS")
		quit(0)
	else:
		print("ADVENTURE SMOKE: FAIL (%d)" % errors.size())
		quit(1)
