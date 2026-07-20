extends SceneTree

const QUEST_REGISTRY := preload("res://scripts/QuestRegistry.gd")
const NIGHT_LEDGER_SCENE := "res://scenes/minigames/NightLedgerRun.tscn"
const NIGHT_LEDGER_SCRIPT := "res://scripts/NightLedgerRun.gd"
const HALLWAY_SCENE := "res://scenes/maps/hallways/SnackHallway.tscn"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node_or_null("GameState")
	var audio_manager := root.get_node_or_null("AudioManager")
	_expect(game_state != null, "GameState is available")
	_expect(audio_manager != null, "AudioManager is available")
	if game_state == null or audio_manager == null:
		quit(1)
		return

	var archive_quest := QUEST_REGISTRY.get_quest("after_hours_archive")
	_expect(not archive_quest.is_empty(), "optional Night Ledger quest is registered")
	_expect(not bool(archive_quest.get("required", true)), "Night Ledger remains optional")
	_expect(str(archive_quest.get("owner", "")) == "Night Ledger", "Night Ledger owns its optional quest")
	_expect(str(archive_quest.get("starts_after", "")) == "circuit_soda_completed", "archive unlocks after Circuit Soda")

	var hallway := (load(HALLWAY_SCENE) as PackedScene).instantiate()
	_expect(hallway.get_node_or_null("InteractableLayer/Tally") == null, "Tally remains removed")
	_expect(hallway.get_node_or_null("InteractableLayer/NightLedgerCabinet") != null, "Night Ledger remains the only archive NPC")
	var papers := hallway.get_node_or_null("InteractableLayer/CrumpledBills")
	var television := hallway.get_node_or_null("InteractableLayer/OldTelevision")
	_expect(papers != null, "archive adds the overdue-paper evidence hotspot")
	_expect(hallway.get_node_or_null("InteractableLayer/OldTelevision") != null, "archive adds the old-television evidence hotspot")
	_expect(str(papers.get("label_text")) == "CRUMPLED PAPERS" and (papers.get("label_offset") as Vector2).y < 0.0, "paper label is renamed and tucked beneath the table")
	_expect((television.get("label_offset") as Vector2).x < 0.0 and (television.get("label_offset") as Vector2).y < 0.0, "television label sits up and left beneath the set")
	_expect(hallway.get_node_or_null("NightLedgerBody/CollisionShape2D") != null, "Night Ledger keeps physical collision")
	_expect((hallway.get_node("NightLedgerBody") as Node2D).position.y >= 320.0, "Night Ledger sits below the north doorway choke point")
	var north_exit := hallway.get_node_or_null("ToSnackAlcove") as Area2D
	_expect(north_exit != null and north_exit.position.is_equal_approx(Vector2(320, 30)), "archive keeps the centered north exit")
	hallway.free()

	var stage_script: Script = load(NIGHT_LEDGER_SCRIPT)
	var profile: Dictionary = stage_script.call("get_stage_profile")
	_expect(str(profile.get("type", "")) == "hybrid_scrolling_platform_adventure", "Night Ledger uses the hybrid scrolling adventure")
	var archive_world_size: Vector2 = profile.get("world_size", Vector2.ZERO)
	_expect(archive_world_size.y >= 3000.0 and archive_world_size.y > archive_world_size.x, "archive is a substantial vertical course")
	_expect(int(profile.get("target_duration_seconds", 0)) >= 180, "archive targets a three-to-four-minute run")
	_expect(int(profile.get("required_collectibles", 0)) == 12, "twelve ordered stamps drive completion")
	_expect(bool(profile.get("ordered_collectibles", false)), "stamp sequence is ordered")
	_expect(int(profile.get("required_keys", 0)) == 3, "three ledger keys drive completion")
	_expect(bool(profile.get("variable_jump", false)), "variable-height jump is enabled")
	_expect(int(profile.get("max_midair_jumps", 0)) == 3, "three mid-air jumps are enabled")
	_expect(float(profile.get("jump_speed", 0.0)) >= 390.0, "archive base jump clears the authored switchback with headroom")
	_expect(bool(profile.get("wall_cling", false)) and bool(profile.get("wall_kick", false)), "archive enables wall cling and wall kick")
	_expect(int(profile.get("portal_count", 0)) >= 4, "paired vertical-floor portals are authored")
	_expect(int(profile.get("threshold_count", 0)) >= 4, "four scrolling thresholds are authored")
	_check_stage_authorship(profile)

	game_state.call("reset_for_new_game")
	var stage := (load(NIGHT_LEDGER_SCENE) as PackedScene).instantiate()
	root.add_child(stage)
	await process_frame
	await process_frame
	_expect(stage.get_node_or_null("PauseMenu") != null, "Night Ledger exposes Esc pause")
	_expect(bool(stage.get_node("PauseMenu").get("is_minigame_context")), "pause menu uses minigame controls")
	_expect(stage.get_node_or_null("AdventureView/WorldViewport/HybridWorld/Explorer") is CharacterBody2D, "archive uses the shared CharacterBody2D FSM")
	_expect(stage.get_node_or_null("AdventureView") is SubViewportContainer, "archive world is clipped to the shared middle viewport")
	_expect(stage.get_node_or_null("HybridHUD/TopPanel/TitleLabel") != null, "archive keeps the shared framed title UI")
	_expect(stage.get_node_or_null("HybridHUD/StatusPanel/StatusLabel") != null, "archive keeps a centered readable status box")
	_expect((stage.get("collectibles") as Array).size() == 12, "all twelve stamps spawn")
	_expect((stage.get("keys") as Array).size() == 3, "all three keys spawn")
	var first_stamp: Dictionary = (stage.get("collectibles") as Array)[0]
	var stamp_marker := first_stamp.get("node") as Control
	var stamp_label := stamp_marker.get_meta(&"world_label", null) as Label
	var label_backing := stamp_label.get_theme_stylebox("normal") as StyleBoxFlat if stamp_label != null else null
	_expect(stamp_label != null and stamp_label.get_parent() == stage and stamp_label.get_theme_font_size("font_size") >= 13 and stamp_label.get_theme_color("font_color").is_equal_approx(Color.WHITE) and label_backing != null and label_backing.bg_color.a >= 0.8, "all adventure stamps use a compact, unscaled HUD number with a tight black backing")
	var exit_marker := stage.get_node_or_null("AdventureView/WorldViewport/HybridWorld/ExitBeacon") as Control
	var goal_rect: Rect2 = profile.get("goal", Rect2())
	_expect(exit_marker != null and is_equal_approx(exit_marker.position.y + exit_marker.size.y, goal_rect.end.y) and _goal_has_supporting_platform(goal_rect, profile.get("platforms", [])), "exit beacon stands on its final platform")
	var explorer := stage.get_node("AdventureView/WorldViewport/HybridWorld/Explorer") as CharacterBody2D
	var audit_save: Dictionary = (stage.get("checkpoints") as Array)[1]
	explorer.position = (audit_save.get("rect", Rect2()) as Rect2).get_center()
	stage.call("_check_checkpoints")
	stage.call("_reset_stage")
	_expect(explorer.position.is_equal_approx(audit_save.get("spawn", Vector2.ZERO)), "Reset returns to the most recently activated save instead of the bottom")
	_expect(str(profile.get("collectible_texture", "")).ends_with("prize_echo_tag_v2.png"), "archive reuses the readable Prize Echo tag sprite")
	_expect(str(profile.get("portal_texture", "")).ends_with("prize_depth_gate_v2.png"), "archive reuses the readable Prize Echo gate sprite")
	_expect(str(profile.get("goal_texture", "")).ends_with("prize_exit_beacon_v2.png"), "archive reuses the readable Prize Echo exit sprite")
	_check_key_gate_spacing(profile)
	stage.call("_complete_run")
	_expect(bool(stage.get("completed")), "balanced record completes the archive")
	_expect(bool(game_state.get("night_ledger_token_collected")), "completion awards the Duplex Token")
	stage.queue_free()
	await process_frame

	var ledger_sets := _load_dialogue_sets("res://data/dialogue/night_ledger.json")
	var intro_text := _flatten_dialogue(ledger_sets.get("quest_intro", []))
	var debrief_text := _flatten_dialogue(ledger_sets.get("token_debrief", []))
	_expect(not intro_text.to_lower().contains("optional"), "Night Ledger leaves the route's optional nature implicit")
	_expect(intro_text.contains("EVERYTHING IN THIS ROOM IS OPERATIONAL"), "Night Ledger introduces the room nonchalantly")
	_expect(intro_text.contains("does not seem necessary") and intro_text.contains("entertaining"), "the player implies that the strange token is an entertaining detour")
	_expect(intro_text.contains("Three extra jumps"), "dialogue explains the three mid-air jumps")
	_expect(debrief_text.contains("One owner signature. Two authorization traces"), "debrief explains the Duplex Token without resolving it")
	_expect(debrief_text.contains("one person being pulled apart"), "debrief only hints at the later split")
	_expect(debrief_text.contains("POWER RESERVE CRITICAL") and debrief_text.contains("ARCHIVE... CLOSING"), "Night Ledger loses power after the hint")
	_expect(_flatten_dialogue(ledger_sets.get("offline_until_postgame", [])).contains("does not look like it will power on"), "Night Ledger remains offline before post-game")
	_expect(_flatten_dialogue(ledger_sets.get("post_reveal_reboot", [])).contains("OWNER SIGNATURE RECONCILED"), "Night Ledger returns only after the reveal")
	_expect(_flatten_dialogue(ledger_sets.get("archive_bills", [])).to_lower().contains("rent past due"), "left table records the financial strain")
	_expect(_flatten_dialogue(ledger_sets.get("archive_bills_post_reveal", [])).contains("papers were mine"), "left table gains a post-reveal personal memory")
	_expect(_flatten_dialogue(ledger_sets.get("archive_tv", [])).contains("replacement was denied"), "right table records the unaffordable replacement")
	_expect(_flatten_dialogue(ledger_sets.get("archive_tv_post_reveal", [])).contains("television was mine"), "right table gains a post-reveal personal memory")
	_expect(str(profile.get("music", "")) == "after_hours_archive", "Night Ledger adventure inherits the archive room music context")
	_expect(str(audio_manager.call("_get_track_id_for_context", "night_ledger")) == str(audio_manager.call("_get_track_id_for_context", "after_hours_archive")), "Night Ledger context resolves to the archive room track")

	print("ArchiveHistorySmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_stage_authorship(profile: Dictionary) -> void:
	var world_size: Vector2 = profile.get("world_size", Vector2.ZERO)
	for index in range((profile.get("collectibles", []) as Array).size()):
		var position: Vector2 = (profile.get("collectibles", []) as Array)[index]
		_expect(position.x >= 0.0 and position.x < world_size.x and position.y >= 0.0 and position.y < world_size.y, "Stamp %02d is inside the scrolling world" % (index + 1))
	_expect((profile.get("platforms", []) as Array).size() >= 30, "archive has a substantial authored platform route")
	_expect((profile.get("hazards", []) as Array).size() <= 3, "archive keeps fixed static fields sparse")
	_expect((profile.get("moving_hazards", []) as Array).size() >= 6, "archive uses moving static as its main timing challenge")
	var stamps: Array = profile.get("collectibles", [])
	_expect(stamps.size() >= 12 and (stamps[9] as Vector2).is_equal_approx(Vector2(470, 1702)), "stamp 10 begins the rebuilt audit switchback on its shelf")
	_expect(stamps.size() >= 12 and (stamps[10] as Vector2).is_equal_approx(Vector2(690, 1546)), "stamp 11 uses a distinct upper shelf")
	_expect(stamps.size() >= 12 and (stamps[11] as Vector2).is_equal_approx(Vector2(900, 1494)), "stamp 12 sits before the top-depth gate")
	_check_required_route(profile)


func _check_key_gate_spacing(profile: Dictionary) -> void:
	for key_value in profile.get("keys", []):
		var key_position: Vector2 = key_value
		var nearest_gate_distance := INF
		for portal_value in profile.get("portals", []):
			var portal: Dictionary = portal_value
			var gate_center := (portal.get("rect", Rect2()) as Rect2).get_center()
			nearest_gate_distance = minf(nearest_gate_distance, key_position.distance_to(gate_center))
		_expect(nearest_gate_distance >= 344.0, "each Ledger Key requires roughly two seconds of travel from a gate")


func _check_required_route(profile: Dictionary) -> void:
	var stamps: Array = profile.get("collectibles", [])
	var platforms: Array = profile.get("platforms", [])
	if stamps.size() < 12:
		_expect(false, "required audit route has all twelve stamps")
		return
	for index in range(stamps.size()):
		_expect(_find_support_platform_index(stamps[index] as Vector2, platforms) >= 0, "stamp %02d has a broad support shelf" % (index + 1))
	for key_value in profile.get("keys", []):
		_expect(_find_support_platform_index(key_value as Vector2, platforms) >= 0, "each Ledger Key has a broad support shelf")
	for checkpoint_value in profile.get("checkpoints", []):
		var checkpoint: Dictionary = checkpoint_value
		_expect(_find_support_platform_index(checkpoint.get("position", Vector2.ZERO), platforms) >= 0, "%s save has a supported landing" % str(checkpoint.get("name", "Ledger")))

	# Stamps 1-5 and 6-12 are each continuous, ordinary-jump runs. The two
	# depth gates are the intentional breaks between those authored sections.
	for index in range(0, 4):
		_expect(_has_ordinary_climb(stamps[index] as Vector2, stamps[index + 1] as Vector2, platforms), "stamps %02d-%02d have a continuous ordinary-jump route" % [index + 1, index + 2])
	for index in range(5, 11):
		_expect(_has_ordinary_climb(stamps[index] as Vector2, stamps[index + 1] as Vector2, platforms), "stamps %02d-%02d have a continuous ordinary-jump route" % [index + 1, index + 2])

	var portals: Array = profile.get("portals", [])
	if portals.size() >= 3:
		var first_gate: Rect2 = (portals[0] as Dictionary).get("rect", Rect2())
		var second_gate: Rect2 = (portals[2] as Dictionary).get("rect", Rect2())
		var first_gate_landing := Vector2(first_gate.get_center().x, first_gate.end.y - 50.0)
		var second_gate_landing := Vector2(second_gate.get_center().x, second_gate.end.y - 50.0)
		_expect(_has_ordinary_climb(stamps[4] as Vector2, first_gate_landing, platforms), "stamp 5 reaches the first depth gate without a precision leap")
		_expect(_has_ordinary_climb(stamps[11] as Vector2, second_gate_landing, platforms), "stamp 12 reaches the top-depth gate without a precision leap")
		_expect(_has_ordinary_climb((portals[2] as Dictionary).get("target", Vector2.ZERO), profile.get("keys", [])[2] as Vector2, platforms), "the top-depth gate has a continuous route to the final Ledger Key")
	_check_checkpoint_spacing(profile)
	_check_moving_hazards_cross_route(profile)


func _find_support_platform_index(anchor: Vector2, platforms: Array) -> int:
	var best_index := -1
	var best_height_delta := INF
	for index in range(platforms.size()):
		if not platforms[index] is Rect2:
			continue
		var platform: Rect2 = platforms[index]
		if platform.size.x < 100.0:
			continue
		var height_above_platform := platform.position.y - anchor.y
		if height_above_platform < 28.0 or height_above_platform > 70.0:
			continue
		if anchor.x < platform.position.x - 18.0 or anchor.x > platform.end.x + 18.0:
			continue
		if height_above_platform < best_height_delta:
			best_height_delta = height_above_platform
			best_index = index
	return best_index


func _has_ordinary_climb(from_anchor: Vector2, to_anchor: Vector2, platforms: Array) -> bool:
	var start := _find_support_platform_index(from_anchor, platforms)
	var destination := _find_support_platform_index(to_anchor, platforms)
	if start < 0 or destination < 0:
		return false
	var pending: Array[int] = [start]
	var visited := {start: true}
	while not pending.is_empty():
		var current: int = pending.pop_front()
		if current == destination:
			return true
		var current_platform: Rect2 = platforms[current]
		for next_index in range(platforms.size()):
			if visited.has(next_index) or not platforms[next_index] is Rect2:
				continue
			var next_platform: Rect2 = platforms[next_index]
			if next_platform.size.x < 100.0:
				continue
			var rise := current_platform.position.y - next_platform.position.y
			var horizontal_gap := maxf(maxf(current_platform.position.x - next_platform.end.x, next_platform.position.x - current_platform.end.x), 0.0)
			if rise >= 0.0 and rise <= 56.0 and horizontal_gap <= 24.0:
				visited[next_index] = true
				pending.append(next_index)
	return false


func _check_checkpoint_spacing(profile: Dictionary) -> void:
	for checkpoint_value in profile.get("checkpoints", []):
		var checkpoint: Dictionary = checkpoint_value
		var closest_stamp := INF
		for stamp_value in profile.get("collectibles", []):
			closest_stamp = minf(closest_stamp, (checkpoint.get("position", Vector2.ZERO) as Vector2).distance_to(stamp_value as Vector2))
		_expect(closest_stamp >= 240.0, "%s save is not crowded by a stamp" % str(checkpoint.get("name", "Ledger")))


func _check_moving_hazards_cross_route(profile: Dictionary) -> void:
	var platforms: Array = profile.get("platforms", [])
	for hazard_value in profile.get("moving_hazards", []):
		var hazard: Dictionary = hazard_value
		var center: Vector2 = hazard.get("position", Vector2.ZERO)
		var marker_size: Vector2 = hazard.get("size", Vector2(42, 42))
		var sweep := Rect2(center - marker_size * 0.5, Vector2(float(hazard.get("range", 0.0)) + marker_size.x, marker_size.y))
		var crosses_route := false
		for platform_value in platforms:
			if not platform_value is Rect2:
				continue
			var platform: Rect2 = platform_value
			if platform.size.x >= 100.0 and _rect_distance(sweep, platform) <= 1.0:
				crosses_route = true
				break
		_expect(crosses_route, "every moving static field patrols a traversable shelf")


func _goal_has_supporting_platform(goal_rect: Rect2, platforms: Array) -> bool:
	for platform_value in platforms:
		if not platform_value is Rect2:
			continue
		var platform: Rect2 = platform_value
		if is_equal_approx(platform.position.y, goal_rect.end.y) and platform.end.x >= goal_rect.position.x and platform.position.x <= goal_rect.end.x:
			return true
	return false


func _rect_distance(first: Rect2, second: Rect2) -> float:
	var horizontal := maxf(maxf(first.position.x - second.end.x, second.position.x - first.end.x), 0.0)
	var vertical := maxf(maxf(first.position.y - second.end.y, second.position.y - first.end.y), 0.0)
	return Vector2(horizontal, vertical).length()


func _load_dialogue_sets(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return (parsed as Dictionary).get("sets", {}) if parsed is Dictionary else {}


func _flatten_dialogue(value: Variant) -> String:
	var flattened := ""
	if value is Array:
		for item: Variant in value:
			flattened += " " + _flatten_dialogue(item)
	elif value is Dictionary:
		flattened += str((value as Dictionary).get("text", ""))
	return flattened


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		failures += 1
		push_error("FAIL: %s" % label)
