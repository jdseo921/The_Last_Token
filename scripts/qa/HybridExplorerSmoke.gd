extends SceneTree
## Focused regression coverage for the reusable CharacterBody2D movement FSM.

const EXPLORER_SCENE := preload("res://scenes/minigames/adventure/HybridExplorerCharacter.tscn")
const ADVENTURE_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")
const UPDATED_TAG_TEXTURE := "res://assets/art/minigames/hybrid_exploration/prize_echo_tag_v2.png"
const UPDATED_KEY_TEXTURE := "res://assets/art/minigames/night_ledger/ledger_key.png"
const UPDATED_GATE_TEXTURE := "res://assets/art/minigames/hybrid_exploration/prize_depth_gate_v2.png"
const UPDATED_EXIT_TEXTURE := "res://assets/art/minigames/hybrid_exploration/prize_exit_beacon_v2.png"
const MIN_KEY_GATE_TRAVEL := 344.0
const PROTECTED_MARKER_CLEARANCE := 72.0
const STAMP_HAZARD_CLEARANCE := 180.0
const MARKER_CLEARANCE := 12.0

var failures := 0
var captured_bridge_packet: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var floor_body := StaticBody2D.new()
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(240, 20)
	floor_shape.shape = rectangle
	floor_body.position = Vector2(0, 32)
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)

	var player := EXPLORER_SCENE.instantiate() as HybridExplorerController
	root.add_child(player)
	player.position = Vector2.ZERO
	await physics_frame
	await physics_frame

	_expect(HybridExplorerController.MovementState.keys() == ["IDLE", "RUN", "JUMP", "WALL_CLING", "CROUCH"], "FSM exposes the five requested states")
	_expect(player is CharacterBody2D, "controller extends CharacterBody2D")
	_expect(player.max_midair_jumps == 3, "controller permits three mid-air jumps")

	var collision := player.get_node("CollisionShape2D") as CollisionShape2D
	var normal_height := (collision.shape as RectangleShape2D).size.y
	player._set_crouched(true)
	_expect((collision.shape as RectangleShape2D).size.y < normal_height, "crouch reduces collision height")
	_expect(player.get_node("VisualRoot").scale.y < 1.0, "crouch scales the visible body")
	player._set_crouched(false)
	_expect(is_equal_approx((collision.shape as RectangleShape2D).size.y, normal_height), "standing restores collision height")

	var low_ceiling := StaticBody2D.new()
	var low_ceiling_collision := CollisionShape2D.new()
	var low_ceiling_shape := RectangleShape2D.new()
	low_ceiling_shape.size = Vector2(80, 8)
	low_ceiling_collision.shape = low_ceiling_shape
	low_ceiling.position = Vector2(0, 1.5)
	low_ceiling.add_child(low_ceiling_collision)
	player._set_crouched(true)
	root.add_child(low_ceiling)
	await physics_frame
	player._set_crouched(false)
	_expect((collision.shape as RectangleShape2D).size.y < normal_height, "crouch cannot expand into a low ceiling")
	low_ceiling.queue_free()
	await physics_frame
	player._set_crouched(false)
	_expect(is_equal_approx((collision.shape as RectangleShape2D).size.y, normal_height), "crouch safely restores after headroom clears")

	player.jump_energy = 75.0
	Input.action_release("move_up")
	player._perform_wall_jump()
	_expect(is_equal_approx(player.jump_energy, 75.0), "diagonal wall kick does not spend JumpEnergy")
	_expect(not is_zero_approx(player.velocity.x) and player.velocity.y < 0.0, "wall kick launches diagonally away")
	Input.action_press("move_up")
	player._perform_wall_jump()
	Input.action_release("move_up")
	_expect(is_equal_approx(player.jump_energy, 50.0), "upward wall jump spends exactly 25 JumpEnergy")
	_expect(is_zero_approx(player.velocity.x) and player.velocity.y < 0.0, "upward wall jump launches vertically")

	player.position = Vector2(400, -200)
	player.midair_jumps_used = 0
	for _index in range(4):
		player._try_jump()
	_expect(player.midair_jumps_used == 3, "air jump budget stops after three jumps")
	player.velocity.y = -300.0
	player._jump_cut_applied = false
	player._apply_vertical_motion(0.0, false)
	_expect(absf(player.velocity.y) < 300.0, "releasing Jump cuts ascent for variable height")

	player.jump_energy = 0.0
	player.position = Vector2(400, -200)
	await physics_frame
	_expect(is_zero_approx(player.jump_energy), "JumpEnergy does not recharge in the air")
	player.position = Vector2(0, 0)
	player.velocity = Vector2.ZERO
	for _frame in range(10):
		await physics_frame
	_expect(player.is_on_floor() and player.jump_energy > 0.0, "JumpEnergy recharges only after landing")

	player.master_scene_event.connect(func(payload: Dictionary) -> void: captured_bridge_packet = payload)
	player.report_to_master_3d(&"threshold_crossed", {"depth": 2})
	_expect(str(captured_bridge_packet.get("event", "")) == "threshold_crossed", "2D controller emits plain bridge data for a master 3D scene")
	_expect((captured_bridge_packet.get("data", {}) as Dictionary).get("depth", 0) == 2, "bridge payload preserves stage data")
	_check_adventure_presentation_profiles()

	player.queue_free()
	floor_body.queue_free()
	await process_frame
	print("HybridExplorerSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_adventure_presentation_profiles() -> void:
	for stage_id in ADVENTURE_CATALOG.get_all_stage_ids():
		var profile: Dictionary = ADVENTURE_CATALOG.get_profile(stage_id)
		_expect(not profile.is_empty(), "%s has an adventure profile" % stage_id)
		_expect(str(profile.get("collectible_texture", "")) == UPDATED_TAG_TEXTURE, "%s uses the readable tag marker" % stage_id)
		_expect(str(profile.get("key_texture", "")) == UPDATED_KEY_TEXTURE, "%s uses the readable key marker" % stage_id)
		_expect(str(profile.get("portal_texture", "")) == UPDATED_GATE_TEXTURE, "%s uses the readable gate marker" % stage_id)
		_expect(str(profile.get("goal_texture", "")) == UPDATED_EXIT_TEXTURE, "%s uses the readable exit marker" % stage_id)
		var key_size: Vector2 = profile.get("key_size", Vector2.ZERO)
		_expect(key_size.x >= 74.0 and key_size.y >= 74.0, "%s keeps its keys consistently large" % stage_id)
		_expect(str(profile.get("controls", "")).contains("ESC: PAUSE"), "%s advertises Esc pause" % stage_id)
		_expect(int(profile.get("target_duration_seconds", 0)) >= 180, "%s targets a substantial exploration run" % stage_id)
		for key_value in profile.get("keys", []):
			var key_position: Vector2 = key_value
			var nearest_trigger_distance := INF
			for portal_value in profile.get("portals", []):
				var portal: Dictionary = portal_value
				var trigger: Rect2 = portal.get("rect", Rect2())
				nearest_trigger_distance = minf(nearest_trigger_distance, _distance_to_rect(key_position, trigger))
			_expect(nearest_trigger_distance >= MIN_KEY_GATE_TRAVEL, "%s key at %s is at least two seconds from a gate trigger" % [stage_id, key_position])
		_check_protected_marker_clearance(stage_id, profile)
		_check_marker_separation(stage_id, profile)
		_check_portal_connections(stage_id, profile)
		_check_floor_marker_support(stage_id, profile)
		if stage_id == "static_service_run":
			_check_static_service_profile(profile)


func _check_static_service_profile(profile: Dictionary) -> void:
	var start: Vector2 = profile.get("start_position", Vector2.ZERO)
	var goal: Rect2 = profile.get("goal", Rect2())
	_expect(str(profile.get("course", "")) == "static_descent", "Static Service uses its own descending course")
	_expect(start.y < goal.get_center().y, "Static Service descends from the upper intake toward the lower exit")
	_expect(int(profile.get("required_collectibles", 0)) == 6, "Static Service uses six route-critical cores instead of another long sweep")
	_expect(int(profile.get("required_keys", 0)) == 0, "Static Service descends without phase relays")
	_expect((profile.get("checkpoints", []) as Array).is_empty(), "Static Service carries no mid-shaft saves")
	var interior_shelves := (profile.get("platforms", []) as Array).size() - 2
	var portals: Array = profile.get("portals", [])
	_expect(portals.size() == interior_shelves, "Static Service puts one climb gate on every interior shelf")
	_expect(start.distance_to((profile.get("collectibles", []) as Array)[0]) >= 140.0, "Static Service does not place a breaker core directly on spawn")
	var every_gate_climbs := true
	for portal_value in portals:
		var climb_portal: Dictionary = portal_value
		var pad_rect: Rect2 = climb_portal.get("rect", Rect2())
		var climb_target: Vector2 = climb_portal.get("target", Vector2.ZERO)
		if str(climb_portal.get("action", "")) != "up" or climb_target.y >= pad_rect.position.y:
			every_gate_climbs = false
	_expect(every_gate_climbs, "Static Service gates all climb toward the shelf above")
	for portal_value in profile.get("portals", []):
		var portal: Dictionary = portal_value
		var target: Vector2 = portal.get("target", Vector2.ZERO)
		_expect(_has_platform_support(target, profile.get("platforms", [])), "Static Service portal target %s has supporting floor" % target)
	_expect(_has_platform_support(Vector2(goal.get_center().x, goal.end.y - 32.0), profile.get("platforms", [])), "Static Service exit stands on the final lower platform")


func _has_platform_support(position: Vector2, platforms: Array) -> bool:
	var foot := position + Vector2(0, 32)
	for platform_value in platforms:
		if platform_value is Rect2 and (platform_value as Rect2).has_point(foot):
			return true
	return false


func _has_floor_surface(point: Vector2, platforms: Array) -> bool:
	for platform_value in platforms:
		if not platform_value is Rect2:
			continue
		var platform := platform_value as Rect2
		if point.x >= platform.position.x + 2.0 and point.x <= platform.end.x - 2.0 and absf(point.y - platform.position.y) <= 2.0:
			return true
	return false


func _check_floor_marker_support(stage_id: String, profile: Dictionary) -> void:
	var platforms: Array = profile.get("platforms", [])
	# Check visual marker bases, not merely the player collision area. This catches
	# the exact failure mode where a save or exit looks suspended in mid-air.
	for checkpoint_value in profile.get("checkpoints", []):
		if not checkpoint_value is Dictionary:
			continue
		var checkpoint: Dictionary = checkpoint_value
		var marker_position: Vector2 = checkpoint.get("position", Vector2(float(checkpoint.get("x", 0.0)), 856.0))
		_expect(
			_has_floor_surface(marker_position + Vector2(0.0, 44.0), platforms),
			"%s save %s is grounded on a floor surface" % [stage_id, str(checkpoint.get("name", "marker"))]
		)
	var goal: Rect2 = profile.get("goal", Rect2())
	_expect(
		_has_floor_surface(Vector2(goal.get_center().x, goal.end.y), platforms),
		"%s exit is grounded on a floor surface" % stage_id
	)
	for portal_value in profile.get("portals", []):
		if not portal_value is Dictionary:
			continue
		var portal: Dictionary = portal_value
		var trigger: Rect2 = portal.get("rect", Rect2())
		_expect(
			_has_floor_surface(Vector2(trigger.get_center().x, trigger.end.y), platforms),
			"%s portal %s is grounded on a floor surface" % [stage_id, str(portal.get("label", "gate"))]
		)


func _distance_to_rect(point: Vector2, rect: Rect2) -> float:
	var closest := Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)
	return point.distance_to(closest)


func _check_protected_marker_clearance(stage_id: String, profile: Dictionary) -> void:
	var danger_rects := _get_hazard_sweeps(profile)
	for portal_value in profile.get("portals", []):
		var portal: Dictionary = portal_value
		_expect(_is_clear_of_hazards(portal.get("rect", Rect2()), danger_rects, PROTECTED_MARKER_CLEARANCE), "%s gates stay clear of static contact" % stage_id)
	for checkpoint_value in profile.get("checkpoints", []):
		var checkpoint: Dictionary = checkpoint_value
		var protected_rect: Rect2 = checkpoint.get("rect", Rect2())
		if protected_rect.size == Vector2.ZERO:
			var threshold_x := float(checkpoint.get("x", 0.0))
			protected_rect = Rect2(threshold_x - 36.0, 812.0, 72.0, 88.0)
		_expect(_is_clear_of_hazards(protected_rect, danger_rects, PROTECTED_MARKER_CLEARANCE), "%s saves stay clear of static contact" % stage_id)
	if stage_id == "night_ledger_run":
		var stamps: Array = profile.get("collectibles", [])
		if stamps.size() >= 12:
			for stamp_index in range(9, 12):
				var final_stamp: Vector2 = stamps[stamp_index]
				var nearest_static := INF
				for danger in danger_rects:
					nearest_static = minf(nearest_static, _distance_to_rect(final_stamp, danger))
				_expect(nearest_static >= STAMP_HAZARD_CLEARANCE, "Night Ledger stamp %d has a safe approach away from static" % (stamp_index + 1))


func _check_marker_separation(stage_id: String, profile: Dictionary) -> void:
	var markers: Array[Dictionary] = []
	var tag_index := 0
	for value in profile.get("collectibles", []):
		if value is Vector2:
			tag_index += 1
			markers.append({"name": "tag %02d" % tag_index, "rect": Rect2(value - Vector2(28, 28), Vector2(56, 56))})
	var key_size: Vector2 = profile.get("key_size", Vector2(74, 74))
	var key_index := 0
	for value in profile.get("keys", []):
		if value is Vector2:
			key_index += 1
			markers.append({"name": "key %d" % key_index, "rect": Rect2(value - key_size * 0.5, key_size)})
	var gate_index := 0
	for value in profile.get("portals", []):
		if value is Dictionary:
			gate_index += 1
			var trigger: Rect2 = (value as Dictionary).get("rect", Rect2())
			var gate_rect := Rect2(trigger.get_center() - Vector2(33, 44), Vector2(66, 88))
			markers.append({"name": "gate %d" % gate_index, "rect": gate_rect})
	var save_index := 0
	for value in profile.get("checkpoints", []):
		if value is Dictionary:
			save_index += 1
			var checkpoint: Dictionary = value
			var save_position: Vector2 = checkpoint.get("position", Vector2(float(checkpoint.get("x", 0.0)), 856.0))
			markers.append({"name": "save %d" % save_index, "rect": Rect2(save_position - Vector2(36, 44), Vector2(72, 88))})
	var goal: Rect2 = profile.get("goal", Rect2())
	if goal.size != Vector2.ZERO:
		markers.append({"name": "exit", "rect": Rect2(goal.get_center() - Vector2(39, 48), Vector2(78, 96))})
	var conflicts: Array[String] = []
	for first_index in range(markers.size()):
		for second_index in range(first_index + 1, markers.size()):
			var first: Dictionary = markers[first_index]
			var second: Dictionary = markers[second_index]
			var first_rect: Rect2 = first.get("rect", Rect2())
			var second_rect: Rect2 = second.get("rect", Rect2())
			if _rect_distance(first_rect, second_rect) < MARKER_CLEARANCE:
				conflicts.append("%s / %s" % [first.get("name", "marker"), second.get("name", "marker")])
	_expect(conflicts.is_empty(), "%s keeps tags, keys, and gates separate%s" % [stage_id, "" if conflicts.is_empty() else ": " + ", ".join(conflicts)])


func _check_portal_connections(stage_id: String, profile: Dictionary) -> void:
	var portals: Array = profile.get("portals", [])
	for index in range(portals.size()):
		var portal: Dictionary = portals[index]
		var target: Vector2 = portal.get("target", Vector2.ZERO)
		var source_rect: Rect2 = portal.get("rect", Rect2())
		var source_center := source_rect.get_center()
		var partner_index := -1
		for candidate_index in range(portals.size()):
			if candidate_index == index:
				continue
			var candidate: Dictionary = portals[candidate_index]
			var candidate_rect: Rect2 = candidate.get("rect", Rect2())
			if target.is_equal_approx(candidate_rect.get_center()):
				partner_index = candidate_index
				break
		if partner_index < 0:
			# One-way climb gates are valid when they land on supported floor;
			# only gates that claim a partner must return to it.
			_expect(
				_has_platform_support(target, profile.get("platforms", [])),
				"%s portal %d is one-way onto supported floor" % [stage_id, index + 1]
			)
			continue
		var partner: Dictionary = portals[partner_index]
		var partner_target: Vector2 = partner.get("target", Vector2.ZERO)
		_expect(
			partner_target.is_equal_approx(source_center),
			"%s portal %d returns to portal %d" % [stage_id, index + 1, partner_index + 1]
		)


func _get_hazard_sweeps(profile: Dictionary) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for value in profile.get("hazards", []):
		if value is Rect2:
			result.append(value)
	for value in profile.get("moving_hazards", []):
		if not value is Dictionary:
			continue
		var definition: Dictionary = value
		var center: Vector2 = definition.get("position", Vector2.ZERO)
		var range_value := float(definition.get("range", 0.0))
		var marker_size: Vector2 = definition.get("size", Vector2(42, 42))
		# Audit the entire rendered sweep, not just its starting frame.
		result.append(Rect2(center - marker_size * 0.5, Vector2(range_value + marker_size.x, marker_size.y)))
	return result


func _is_clear_of_hazards(protected_rect: Rect2, danger_rects: Array[Rect2], clearance: float) -> bool:
	for danger in danger_rects:
		if _rect_distance(protected_rect, danger) < clearance:
			return false
	return true


func _rect_distance(first: Rect2, second: Rect2) -> float:
	var horizontal := maxf(maxf(first.position.x - second.end.x, second.position.x - first.end.x), 0.0)
	var vertical := maxf(maxf(first.position.y - second.end.y, second.position.y - first.end.y), 0.0)
	return Vector2(horizontal, vertical).length()


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		failures += 1
		push_error("FAIL: %s" % label)
