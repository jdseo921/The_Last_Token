class_name HybridAdventureCatalog
extends RefCounted

## Fixed authored course data for the five reachable scrolling adventure stages.
## Geometry is shared in three deliberate course families; objectives, routes,
## ordered pickups, palettes, portals and story copy remain stage-specific.

const WORLD_SIZE := Vector2(6400.0, 1080.0)
const START_POSITION := Vector2(82.0, 852.0)


static func get_profile(stage_id: String) -> Dictionary:
	var profile := _base_profile()
	match stage_id:
		"snack_service_dash":
			profile.merge(_snack_service_profile(), true)
		"prize_shelf_run":
			profile.merge(_prize_echo_profile(), true)
		"static_service_run":
			profile.merge(_static_service_profile(), true)
		"night_ledger_run":
			profile.merge(_night_ledger_profile(), true)
		_:
			push_warning("HybridAdventureCatalog: unknown stage id %s" % stage_id)
			return {}
	_apply_course(profile)
	return profile


static func get_all_stage_ids() -> Array[String]:
	return [
		"snack_service_dash",
		"prize_shelf_run",
		"static_service_run",
		"night_ledger_run",
	]


static func _base_profile() -> Dictionary:
	return {
		"type": "hybrid_scrolling_platform_adventure",
		"world_size": WORLD_SIZE,
		"start_position": START_POSITION,
		"target_duration_seconds": 210,
		"max_midair_jumps": 3,
		"variable_jump": true,
		"wall_cling": true,
		"wall_kick": true,
		"jump_energy": true,
		"camera_zoom": 0.6,
		"show_reset_button": false,
		"required_keys": 3,
		"environment_index": 0,
		"collectible_cell": 0,
		# Every adventure uses the same high-contrast marker family. Earlier
		# stages used atlas cells with inconsistent transparent padding, which
		# made keys and portals look smaller than their Prize Echo counterparts.
		"collectible_texture": "res://assets/art/minigames/hybrid_exploration/prize_echo_tag_v2.png",
		"key_texture": "res://assets/art/minigames/night_ledger/ledger_key.png",
		"portal_texture": "res://assets/art/minigames/hybrid_exploration/prize_depth_gate_v2.png",
		"goal_texture": "res://assets/art/minigames/hybrid_exploration/prize_exit_beacon_v2.png",
		"key_size": Vector2(74, 74),
		"course": "a",
		"ordered_collectibles": false,
		"objective": "Explore every depth, recover the route signals, and reach the exit beacon.",
		"controls": "A/D OR ARROWS: MOVE   S/DOWN: CROUCH\nW/S OR UP/DOWN: PORTAL\nSPACE/E: JUMP   W/UP+JUMP: WALL RISE\nR: RESET   ESC: PAUSE",
		"collectible_name": "Signals",
		"key_name": "Anchors",
		"status_intro": "Explore above and below the main rail. Portals connect distant layers.",
		"completion_text": "ROUTE STABILIZED. Return to the arcade.",
		"accent": Color(0.18, 0.82, 0.9),
		"secondary": Color(0.92, 0.24, 0.72),
		"platform_color": Color(0.08, 0.16, 0.22),
	}


static func _snack_service_profile() -> Dictionary:
	return {
		"title": "CARBONATION UNDERPASS",
		"music": "snack_alcove",
		"course": "c",
		"environment_index": 2,
		"collectible_cell": 2,
		"collectible_name": "Soda Labels",
		"key_name": "Pressure Valves",
		"objective": "Route the stockroom underpass. Recover 18 labels and stabilize three pressure valves.",
		"status_intro": "Fizz pockets guard the lower shelves. Crouch under pipes and climb the wall shafts.",
		"completion_text": "STOCK ROUTE BALANCED. Every label reaches the correct shelf without bursting.",
		"accent": Color(0.18, 0.9, 0.72),
		"secondary": Color(0.96, 0.32, 0.48),
	}


static func _prize_echo_profile() -> Dictionary:
	return {
		"title": "PRIZE ECHO ASCENT",
		"music": "prize_corner",
		"course": "b",
		"environment_index": 3,
		"collectible_cell": 3,
		"collectible_texture": "res://assets/art/minigames/hybrid_exploration/prize_echo_tag_v2.png",
		"portal_texture": "res://assets/art/minigames/hybrid_exploration/prize_depth_gate_v2.png",
		"goal_texture": "res://assets/art/minigames/hybrid_exploration/prize_exit_beacon_v2.png",
		"collectible_name": "Echo Tags",
		"key_name": "Rail Keys",
		"key_size": Vector2(74, 74),
		"ordered_collectibles": true,
		"objective": "Cross both prize rails. Recover 18 memory tags in order and open three rail locks.",
		"status_intro": "Hooks patrol the obvious route. The old tags hide on the upper and sub-rails.",
		"completion_text": "PRIZE ECHO RESTORED. Wanting and working belonged to one owner.",
		"accent": Color(0.96, 0.48, 0.76),
		"secondary": Color(0.96, 0.72, 0.22),
	}


static func _static_service_profile() -> Dictionary:
	return {
		"title": "STATIC SERVICE DEPTHS",
		"music": "maintenance_hall",
		"course": "static_descent",
		"world_size": Vector2(1920.0, 3800.0),
		"start_position": Vector2(1540.0, 188.0),
		"required_collectibles": 6,
		"required_keys": 2,
		"ordered_collectibles": true,
		"camera_zoom": 0.64,
		"environment_index": 4,
		"collectible_cell": 4,
		"collectible_name": "Breaker Cores",
		"key_name": "Phase Relays",
		"objective": "Descend the service shaft. Recover 6 breaker cores in order and bridge two phase relays.",
		"status_intro": "GUS (radio): Take the drop shafts downward. Only sealed cross-shafts need a phase gate.",
		"completion_text": "SERVICE POWER RESTORED. One repair opens the next route; it does not erase the strain.",
		"descent_cues": [
			{"position": Vector2(1018, 194), "direction": "left"},
			{"position": Vector2(742, 444), "direction": "left"},
			{"position": Vector2(874, 704), "direction": "right"},
			{"position": Vector2(974, 974), "direction": "right"},
			{"position": Vector2(1124, 1234), "direction": "left"},
			{"position": Vector2(754, 1504), "direction": "left"},
			{"position": Vector2(604, 1754), "direction": "left"},
			{"position": Vector2(1324, 2154), "direction": "left"},
			{"position": Vector2(724, 2434), "direction": "left"},
			{"position": Vector2(674, 2694), "direction": "right"},
			{"position": Vector2(1344, 3074), "direction": "left"},
			{"position": Vector2(724, 3314), "direction": "left"},
		],
		"accent": Color(0.18, 0.9, 0.62),
		"secondary": Color(0.26, 0.74, 1.0),
	}


static func _night_ledger_profile() -> Dictionary:
	return {
		"title": "NIGHT LEDGER ASCENT",
		"music": "after_hours_archive",
		"course": "ledger_vertical",
		"world_size": Vector2(1400.0, 3600.0),
		"start_position": Vector2(150.0, 3450.0),
		"camera_zoom": 0.65,
		"environment_index": 6,
		"collectible_cell": 6,
		"collectible_texture": "res://assets/art/minigames/hybrid_exploration/prize_echo_tag_v2.png",
		"portal_texture": "res://assets/art/minigames/hybrid_exploration/prize_depth_gate_v2.png",
		"goal_texture": "res://assets/art/minigames/hybrid_exploration/prize_exit_beacon_v2.png",
		"collectible_name": "Audit Stamps",
		"key_name": "Ledger Keys",
		"key_size": Vector2(74, 74),
		"required_collectibles": 12,
		"ordered_collectibles": true,
		# The vertical course uses 52 px rises. Give the base jump enough headroom
		# to clear those shelves without forcing a perfectly-timed multi-jump.
		"jump_speed": 390.0,
		"objective": "Climb the vertical archive. Recover 12 audit stamps in order and all three ledger keys.",
		"status_intro": "Climb the switchback shelves. Gates jump between distant ledger floors.",
		"completion_text": "DUPLEX TOKEN MINTED. One owner signature carries two reading traces.",
		"accent": Color(0.28, 0.72, 1.0),
		"secondary": Color(0.94, 0.7, 0.24),
	}


static func _apply_course(profile: Dictionary) -> void:
	var course := str(profile.get("course", "a"))
	match course:
		"b":
			profile["platforms"] = _course_b_platforms()
			profile["collectibles"] = _course_b_collectibles()
			profile["keys"] = _course_b_keys()
			profile["hazards"] = _course_b_hazards()
			profile["moving_hazards"] = _course_b_moving_hazards()
			profile["portals"] = _course_b_portals()
		"c":
			profile["platforms"] = _course_c_platforms()
			profile["collectibles"] = _course_c_collectibles()
			profile["keys"] = _course_c_keys()
			profile["hazards"] = _course_c_hazards()
			profile["moving_hazards"] = _course_c_moving_hazards()
			profile["portals"] = _course_c_portals()
		"static_descent":
			profile["platforms"] = _static_service_platforms()
			profile["collectibles"] = _static_service_collectibles()
			profile["keys"] = _static_service_keys()
			profile["hazards"] = _static_service_hazards()
			profile["moving_hazards"] = _static_service_moving_hazards()
			profile["portals"] = _static_service_portals()
		"ledger_vertical":
			profile["platforms"] = _ledger_vertical_platforms()
			profile["collectibles"] = _ledger_vertical_collectibles()
			profile["keys"] = _ledger_vertical_keys()
			profile["hazards"] = _ledger_vertical_hazards()
			profile["moving_hazards"] = _ledger_vertical_moving_hazards()
			profile["portals"] = _ledger_vertical_portals()
		_:
			profile["platforms"] = _course_a_platforms()
			profile["collectibles"] = _course_a_collectibles()
			profile["keys"] = _course_a_keys()
			profile["hazards"] = _course_a_hazards()
			profile["moving_hazards"] = _course_a_moving_hazards()
			profile["portals"] = _course_a_portals()
	var available: Array = profile["collectibles"]
	var required := int(profile.get("required_collectibles", available.size()))
	profile["required_collectibles"] = mini(required, available.size())
	var collectible_limit := int(profile["required_collectibles"])
	# Array.slice() excludes its end index in Godot 4, so the requested count is
	# also the correct exclusive bound.
	profile["collectibles"] = available.slice(0, collectible_limit) if collectible_limit > 0 else []
	# Respawn points sit beyond each threshold on uninterrupted main-rail floor.
	# Keep them outside the complete sweep of every moving hazard, not merely
	# outside each hazard's starting position.
	if course == "ledger_vertical":
		profile["checkpoints"] = _ledger_vertical_checkpoints()
		profile["goal"] = Rect2(300, 40, 70, 100)
	elif course == "static_descent":
		profile["checkpoints"] = _static_service_checkpoints()
		profile["goal"] = Rect2(430, 3500, 70, 100)
	else:
		profile["checkpoints"] = [
			{"x": 1050.0, "spawn": Vector2(1220, 852), "name": "ENTRY DEPTH"},
			{"x": 2450.0, "spawn": Vector2(2320, 852), "name": "INNER RAIL"},
			{"x": 3920.0, "spawn": Vector2(4070, 852), "name": "SUB-LAYER"},
			# This save deliberately sits before the final depth gate instead of
			# sharing the gate's platform. Recovery and traversal remain readable.
			{"x": 5100.0, "spawn": Vector2(5040, 852), "name": "EXIT DEPTH"},
		]
		profile["goal"] = Rect2(6170, 800, 70, 100)
	# A save or depth gate is a recovery/transition space, never an obstacle
	# gauntlet. Remove authored static whose entire visible or moving sweep would
	# crowd one of those markers before the stage builds its sprites and damage.
	_filter_hazards_from_safe_markers(profile)
	profile["portal_count"] = (profile["portals"] as Array).size()
	profile["threshold_count"] = (profile["checkpoints"] as Array).size()


static func _filter_hazards_from_safe_markers(profile: Dictionary) -> void:
	const CLEARANCE := 72.0
	var safe_markers := _get_safe_marker_rects(profile)
	var filtered_static: Array[Rect2] = []
	for value in profile.get("hazards", []):
		if value is Rect2 and _rect_clears_markers(value, safe_markers, CLEARANCE):
			filtered_static.append(value)
	profile["hazards"] = filtered_static

	var filtered_moving: Array[Dictionary] = []
	for value in profile.get("moving_hazards", []):
		if not value is Dictionary:
			continue
		var definition: Dictionary = value
		var origin: Vector2 = definition.get("position", Vector2.ZERO)
		var travel_range := float(definition.get("range", 0.0))
		var marker_size: Vector2 = definition.get("size", Vector2(42, 42))
		# Test the full rendered sweep, not merely the marker's start frame.
		var sweep := Rect2(origin - marker_size * 0.5, Vector2(travel_range + marker_size.x, marker_size.y))
		if _rect_clears_markers(sweep, safe_markers, CLEARANCE):
			filtered_moving.append(definition)
	profile["moving_hazards"] = filtered_moving


static func _get_safe_marker_rects(profile: Dictionary) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for value in profile.get("portals", []):
		if value is Dictionary:
			result.append((value as Dictionary).get("rect", Rect2()))
	for value in profile.get("checkpoints", []):
		if not value is Dictionary:
			continue
		var checkpoint: Dictionary = value
		var marker_rect: Rect2 = checkpoint.get("rect", Rect2())
		if marker_rect.size == Vector2.ZERO:
			var threshold_x := float(checkpoint.get("x", 0.0))
			marker_rect = Rect2(threshold_x - 36.0, 812.0, 72.0, 88.0)
		result.append(marker_rect)
	# Completion objects are recovery spaces too. A hazard can challenge the
	# route between them, but never sit on top of a required pickup or exit.
	for value in profile.get("collectibles", []):
		if value is Vector2:
			result.append(Rect2(value - Vector2(32, 32), Vector2(64, 64)))
	var key_size: Vector2 = profile.get("key_size", Vector2(74, 74))
	for value in profile.get("keys", []):
		if value is Vector2:
			result.append(Rect2(value - key_size * 0.5, key_size))
	var goal: Rect2 = profile.get("goal", Rect2())
	if goal.size != Vector2.ZERO:
		result.append(goal)
	return result


static func _rect_clears_markers(candidate: Rect2, markers: Array[Rect2], clearance: float) -> bool:
	for marker in markers:
		if _rect_distance(candidate, marker) < clearance:
			return false
	return true


static func _rect_distance(first: Rect2, second: Rect2) -> float:
	var horizontal := maxf(maxf(first.position.x - second.end.x, second.position.x - first.end.x), 0.0)
	var vertical := maxf(maxf(first.position.y - second.end.y, second.position.y - first.end.y), 0.0)
	return Vector2(horizontal, vertical).length()


static func _course_a_platforms() -> Array[Rect2]:
	return [
		Rect2(0, 900, 700, 40), Rect2(770, 900, 620, 40), Rect2(1460, 900, 560, 40),
		Rect2(2090, 900, 700, 40), Rect2(2870, 900, 560, 40), Rect2(3510, 900, 660, 40),
		Rect2(4250, 900, 590, 40), Rect2(4920, 900, 650, 40), Rect2(5640, 900, 760, 40),
		Rect2(180, 790, 150, 18), Rect2(420, 700, 160, 18), Rect2(610, 610, 34, 290),
		Rect2(820, 760, 180, 18), Rect2(1080, 650, 170, 18), Rect2(1320, 560, 34, 340),
		Rect2(1530, 760, 190, 18), Rect2(1790, 650, 160, 18), Rect2(1970, 540, 34, 360),
		Rect2(2180, 780, 160, 18), Rect2(2410, 690, 190, 18), Rect2(2660, 590, 34, 310),
		Rect2(2960, 760, 170, 18), Rect2(3190, 650, 160, 18), Rect2(3370, 540, 34, 360),
		Rect2(3600, 780, 190, 18), Rect2(3850, 680, 170, 18), Rect2(4090, 590, 34, 310),
		Rect2(4370, 770, 180, 18), Rect2(4610, 650, 170, 18), Rect2(4800, 540, 34, 360),
		Rect2(5030, 760, 180, 18), Rect2(5280, 650, 170, 18), Rect2(5500, 570, 34, 330),
		Rect2(5740, 760, 180, 18), Rect2(5980, 650, 160, 18),
		Rect2(1220, 1030, 1120, 30), Rect2(3550, 1030, 1040, 30),
	]


static func _course_b_platforms() -> Array[Rect2]:
	return [
		Rect2(0, 900, 560, 40), Rect2(640, 900, 730, 40), Rect2(1450, 900, 630, 40),
		# Join this central rail into the preceding shelf. The former 80 px slit
		# looked like missing scenery and served no traversal purpose.
		Rect2(2080, 900, 630, 40), Rect2(2790, 900, 710, 40), Rect2(3580, 900, 580, 40),
		Rect2(4240, 900, 690, 40), Rect2(5010, 900, 540, 40), Rect2(5630, 900, 770, 40),
		Rect2(120, 740, 180, 18), Rect2(360, 590, 34, 310), Rect2(470, 520, 180, 18),
		Rect2(760, 760, 170, 18), Rect2(1010, 650, 190, 18), Rect2(1280, 500, 34, 400),
		Rect2(1530, 710, 180, 18), Rect2(1790, 580, 180, 18), Rect2(2040, 470, 34, 430),
		Rect2(2260, 760, 170, 18), Rect2(2480, 620, 170, 18), Rect2(2670, 520, 34, 380),
		Rect2(2870, 700, 180, 18), Rect2(3130, 560, 180, 18), Rect2(3420, 470, 34, 430),
		Rect2(3670, 760, 180, 18), Rect2(3920, 620, 170, 18), Rect2(4130, 500, 34, 400),
		Rect2(4330, 700, 180, 18), Rect2(4580, 570, 190, 18), Rect2(4890, 470, 34, 430),
		Rect2(5090, 740, 180, 18), Rect2(5330, 610, 170, 18), Rect2(5520, 500, 34, 400),
		Rect2(5760, 720, 170, 18), Rect2(6000, 580, 180, 18),
		Rect2(1120, 1030, 1030, 30), Rect2(3340, 1030, 1160, 30),
	]


static func _course_c_platforms() -> Array[Rect2]:
	return [
		Rect2(0, 900, 650, 40), Rect2(730, 900, 560, 40), Rect2(1370, 900, 720, 40),
		Rect2(2170, 900, 620, 40), Rect2(2870, 900, 650, 40), Rect2(3600, 900, 620, 40),
		Rect2(4300, 900, 650, 40), Rect2(5030, 900, 620, 40), Rect2(5730, 900, 670, 40),
		Rect2(160, 780, 160, 18), Rect2(390, 680, 180, 18), Rect2(620, 560, 34, 340),
		Rect2(790, 740, 170, 18), Rect2(1030, 620, 160, 18), Rect2(1260, 520, 34, 380),
		Rect2(1450, 760, 190, 18), Rect2(1710, 640, 170, 18), Rect2(1990, 520, 34, 380),
		Rect2(2250, 730, 180, 18), Rect2(2490, 590, 180, 18), Rect2(2750, 470, 34, 430),
		Rect2(2940, 760, 170, 18), Rect2(3190, 640, 170, 18), Rect2(3480, 540, 34, 360),
		Rect2(3680, 720, 190, 18), Rect2(3940, 580, 170, 18), Rect2(4190, 460, 34, 440),
		Rect2(4380, 760, 180, 18), Rect2(4630, 640, 170, 18), Rect2(4920, 520, 34, 380),
		Rect2(5110, 720, 190, 18), Rect2(5370, 580, 170, 18), Rect2(5620, 470, 34, 430),
		Rect2(5800, 740, 180, 18), Rect2(6050, 610, 170, 18),
		Rect2(1180, 1030, 1180, 30), Rect2(3510, 1030, 1120, 30),
	]


static func _ledger_vertical_platforms() -> Array[Rect2]:
	# A deliberate switchback rather than a collection of isolated jumps.
	# Each required rise is 52 px, with overlapping shelf lips, so the whole
	# route can be completed with ordinary jumps. The longer macro-zigzag and
	# moving currents provide the challenge; precision recovery does not.
	return [
		Rect2(0, 3500, 1400, 60),
		# Intake ledger: start to the first depth gate.
		Rect2(140, 3448, 280, 22), Rect2(380, 3396, 220, 22), Rect2(580, 3344, 340, 22),
		Rect2(820, 3292, 200, 22), Rect2(1000, 3240, 300, 22), Rect2(780, 3188, 360, 22),
		Rect2(520, 3136, 340, 22), Rect2(280, 3084, 320, 22), Rect2(100, 3032, 340, 22),
		Rect2(320, 2980, 280, 22), Rect2(560, 2928, 360, 22), Rect2(780, 2876, 300, 22),
		Rect2(1020, 2824, 280, 22),
		# Audit ledger: a full zigzag after the first depth shift. The key and
		# every stamp sit on broad shelves, not on wall rails or fall gaps.
		Rect2(140, 2510, 320, 22), Rect2(380, 2458, 280, 22), Rect2(620, 2406, 340, 22),
		Rect2(900, 2354, 300, 22), Rect2(1000, 2302, 300, 22), Rect2(260, 2250, 780, 22),
		Rect2(100, 2198, 300, 22), Rect2(280, 2146, 300, 22), Rect2(100, 2094, 280, 22),
		Rect2(340, 2042, 320, 22), Rect2(560, 1990, 320, 22), Rect2(760, 1938, 540, 22),
		Rect2(1000, 1886, 300, 22), Rect2(760, 1834, 360, 22), Rect2(500, 1782, 360, 22),
		Rect2(300, 1730, 320, 22), Rect2(100, 1678, 500, 22), Rect2(340, 1626, 320, 22),
		Rect2(560, 1574, 320, 22), Rect2(780, 1522, 300, 22), Rect2(1020, 1470, 280, 22),
		# Top archive: a final short switchback after the second gate.
		Rect2(360, 690, 360, 22), Rect2(600, 638, 260, 22), Rect2(780, 586, 360, 22),
		Rect2(1000, 534, 300, 22), Rect2(760, 482, 320, 22), Rect2(480, 430, 420, 22),
		Rect2(280, 378, 340, 22), Rect2(100, 326, 320, 22), Rect2(320, 274, 340, 22),
		Rect2(560, 222, 360, 22), Rect2(780, 170, 320, 22), Rect2(540, 118, 340, 22),
		# The exit beacon rests on this final shelf; it is never suspended in the
		# goal trigger above the route.
		Rect2(300, 140, 300, 22),
		Rect2(0, 0, 30, 3600), Rect2(1370, 0, 30, 3600),
	]


static func _ledger_vertical_collectibles() -> Array[Vector2]:
	return [
		Vector2(250, 3420), Vector2(690, 3316), Vector2(1130, 3212), Vector2(690, 3108),
		Vector2(250, 3004), Vector2(520, 2430), Vector2(1130, 2274), Vector2(250, 2066),
		Vector2(1130, 1858), Vector2(470, 1702), Vector2(690, 1546), Vector2(900, 1494),
	]


static func _ledger_vertical_keys() -> Array[Vector2]:
	# Each key is at least ~400 px from the nearest gate: over two seconds of
	# normal running/climbing, so a depth shift never hands out a free key.
	return [Vector2(470, 2943), Vector2(470, 2005), Vector2(1130, 497)]


static func _ledger_vertical_hazards() -> Array[Rect2]:
	return [
		# Fixed fields stay sparse. The ascent now emphasizes reading and timing
		# moving currents rather than inching through permanent blocker stacks.
		Rect2(870, 3268, 54, 24), Rect2(730, 1760, 54, 22),
	]


static func _ledger_vertical_moving_hazards() -> Array[Dictionary]:
	return [
		# Every moving field sweeps a shelf that the critical route crosses. Their
		# purpose is timing the traversal, never decorating unreachable void.
		{"position": Vector2(400, 3375), "range": 100.0, "speed": 72.0, "size": Vector2(64, 42)},
		{"position": Vector2(900, 3271), "range": 60.0, "speed": 76.0, "size": Vector2(64, 42)},
		{"position": Vector2(850, 3167), "range": 40.0, "speed": 78.0, "size": Vector2(64, 42)},
		{"position": Vector2(480, 2229), "range": 360.0, "speed": 80.0, "size": Vector2(84, 42)},
		{"position": Vector2(780, 2229), "range": 160.0, "speed": 82.0, "size": Vector2(64, 42)},
		{"position": Vector2(440, 2125), "range": 120.0, "speed": 84.0, "size": Vector2(64, 42)},
		{"position": Vector2(800, 1761), "range": 60.0, "speed": 88.0, "size": Vector2(64, 42)},
		{"position": Vector2(140, 1657), "range": 80.0, "speed": 92.0, "size": Vector2(64, 42)},
		{"position": Vector2(550, 409), "range": 300.0, "speed": 96.0, "size": Vector2(84, 42)},
		{"position": Vector2(320, 253), "range": 100.0, "speed": 100.0, "size": Vector2(64, 42)},
		{"position": Vector2(900, 149), "range": 60.0, "speed": 102.0, "size": Vector2(64, 42)},
	]


static func _ledger_vertical_portals() -> Array[Dictionary]:
	return [
		# Each target is the centre of its paired threshold. This keeps a depth
		# shift reversible instead of sending the player beside an unrelated gate.
		{"rect": Rect2(1110, 2760, 52, 64), "target": Vector2(206, 2478), "action": "up", "label": "UPPER LEDGER"},
		{"rect": Rect2(180, 2446, 52, 64), "target": Vector2(1136, 2792), "action": "down", "label": "LOWER LEDGER"},
		{"rect": Rect2(1110, 1406, 52, 64), "target": Vector2(426, 658), "action": "up", "label": "TOP ARCHIVE"},
		{"rect": Rect2(400, 626, 52, 64), "target": Vector2(1136, 1438), "action": "down", "label": "INNER ARCHIVE"},
	]


static func _ledger_vertical_checkpoints() -> Array[Dictionary]:
	return [
		{"rect": Rect2(1100, 3400, 120, 100), "position": Vector2(1160, 3456), "spawn": Vector2(1160, 3486), "name": "ENTRY FLOOR"},
		{"rect": Rect2(630, 1890, 120, 100), "position": Vector2(690, 1946), "spawn": Vector2(690, 1976), "name": "AUDIT FLOOR"},
		# Keep the save on the same top shelf, but clear of the paired depth gate.
		{"rect": Rect2(540, 590, 120, 100), "position": Vector2(600, 646), "spawn": Vector2(600, 676), "name": "TOP ARCHIVE"},
		{"rect": Rect2(640, 122, 120, 100), "position": Vector2(700, 178), "spawn": Vector2(700, 208), "name": "CLOSING LEDGER"},
	]


static func _course_a_collectibles() -> Array[Vector2]:
	return [Vector2(250, 752), Vector2(500, 662), Vector2(850, 722), Vector2(1150, 612), Vector2(1560, 722), Vector2(1850, 612), Vector2(2220, 742), Vector2(2490, 652), Vector2(3100, 732), Vector2(3250, 612), Vector2(3630, 742), Vector2(3920, 642), Vector2(4410, 732), Vector2(4680, 612), Vector2(5070, 722), Vector2(5450, 622), Vector2(5790, 722), Vector2(6040, 612)]


static func _course_b_collectibles() -> Array[Vector2]:
	return [Vector2(170, 702), Vector2(520, 482), Vector2(800, 722), Vector2(1090, 612), Vector2(1570, 672), Vector2(1840, 542), Vector2(2300, 722), Vector2(2520, 582), Vector2(3050, 672), Vector2(3180, 522), Vector2(3720, 722), Vector2(3970, 582), Vector2(4380, 662), Vector2(4630, 532), Vector2(5130, 702), Vector2(5480, 582), Vector2(5800, 682), Vector2(6050, 542)]


static func _course_c_collectibles() -> Array[Vector2]:
	return [Vector2(210, 742), Vector2(450, 642), Vector2(820, 702), Vector2(1080, 582), Vector2(1490, 722), Vector2(1760, 602), Vector2(2290, 692), Vector2(2540, 552), Vector2(3100, 712), Vector2(3240, 602), Vector2(3720, 682), Vector2(3980, 542), Vector2(4420, 722), Vector2(4690, 602), Vector2(5150, 682), Vector2(5300, 692), Vector2(5840, 702), Vector2(6100, 572)]


static func _course_a_keys() -> Array[Vector2]:
	# Keep every key at least two seconds of traversal away from a depth gate.
	# The old lower-rail positions sat on the return-gate trigger itself.
	return [Vector2(2050, 994), Vector2(3400, 500), Vector2(4680, 854)]


static func _course_b_keys() -> Array[Vector2]:
	# The rail keys are deliberately offset from portal triggers. Entering a
	# layer gives the player a route to solve, rather than a free pickup.
	return [Vector2(2050, 990), Vector2(3450, 426), Vector2(3250, 854)]


static func _course_c_keys() -> Array[Vector2]:
	return [Vector2(1920, 994), Vector2(4220, 420), Vector2(4800, 854)]


static func _course_a_hazards() -> Array[Rect2]:
	return [Rect2(700, 876, 70, 24), Rect2(1390, 876, 70, 24), Rect2(2020, 876, 70, 24), Rect2(2790, 876, 80, 24), Rect2(3430, 876, 80, 24), Rect2(4170, 876, 80, 24), Rect2(4840, 876, 80, 24), Rect2(5570, 876, 70, 24), Rect2(1780, 1006, 90, 24), Rect2(4020, 1006, 90, 24)]


static func _course_b_hazards() -> Array[Rect2]:
	return [Rect2(560, 876, 80, 24), Rect2(1370, 876, 80, 24), Rect2(2080, 876, 80, 24), Rect2(2710, 876, 80, 24), Rect2(3500, 876, 80, 24), Rect2(4160, 876, 80, 24), Rect2(4930, 876, 80, 24), Rect2(5550, 876, 80, 24), Rect2(1640, 1006, 90, 24), Rect2(3880, 1006, 90, 24)]


static func _course_c_hazards() -> Array[Rect2]:
	return [Rect2(650, 876, 80, 24), Rect2(1290, 876, 80, 24), Rect2(2090, 876, 80, 24), Rect2(2790, 876, 80, 24), Rect2(3520, 876, 80, 24), Rect2(4220, 876, 80, 24), Rect2(4950, 876, 80, 24), Rect2(5650, 876, 80, 24), Rect2(1720, 1006, 90, 24), Rect2(4050, 1006, 90, 24)]


static func _course_a_moving_hazards() -> Array[Dictionary]:
	return _moving_hazards_for([900.0, 2380.0, 3760.0, 5200.0])


static func _course_b_moving_hazards() -> Array[Dictionary]:
	return _moving_hazards_for([820.0, 2260.0, 3680.0, 5140.0])


static func _course_c_moving_hazards() -> Array[Dictionary]:
	return _moving_hazards_for([960.0, 2320.0, 3740.0, 5220.0])


static func _moving_hazards_for(origins: Array[float]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index in range(origins.size()):
		result.append({"position": Vector2(origins[index], 842 - (index % 2) * 170), "range": 180.0 + index * 20.0, "speed": 62.0 + index * 8.0})
	return result


static func _course_a_portals() -> Array[Dictionary]:
	return _portal_pairs(
		[1580.0, 3770.0],
		[1370.0, 4200.0],
		[
			{"entry_x": 2720.0, "return_rect": Rect2(2974, 696, 52, 64), "label": "UPPER STACK"},
			{"entry_x": 5260.0, "return_rect": Rect2(5334, 586, 52, 64), "label": "HIGH MEMORY"},
		]
	)


static func _course_b_portals() -> Array[Dictionary]:
	return _portal_pairs(
		[1510.0, 3670.0],
		[1420.0, 4180.0],
		[
			{"entry_x": 2600.0, "return_rect": Rect2(2884, 636, 52, 64), "label": "UPPER STACK"},
			{"entry_x": 5200.0, "return_rect": Rect2(5354, 546, 52, 64), "label": "HIGH MEMORY"},
		]
	)


static func _course_c_portals() -> Array[Dictionary]:
	return _portal_pairs(
		[1480.0, 3740.0],
		[1410.0, 4300.0],
		[
			{"entry_x": 2650.0, "return_rect": Rect2(2954, 696, 52, 64), "label": "UPPER STACK"},
			{"entry_x": 5280.0, "return_rect": Rect2(5394, 516, 52, 64), "label": "HIGH MEMORY"},
		]
	)


static func _static_service_platforms() -> Array[Rect2]:
	# A descending service shaft: each shelf catches a deliberate drop and turns
	# the route through a different bay. Two sealed cross-shafts are deliberately
	# out of reach, so the only portals are useful rather than decorative.
	return [
		Rect2(980, 220, 860, 40), # Upper-right intake.
		Rect2(720, 470, 350, 30),
		Rect2(180, 730, 720, 40),
		Rect2(580, 1000, 420, 30),
		Rect2(1100, 1260, 740, 40), # First relay alcove.
		Rect2(730, 1530, 440, 30),
		Rect2(80, 1780, 550, 40), # Sealed lower-left shaft.
		Rect2(1300, 2180, 540, 40), # Reached through phase gate A.
		Rect2(700, 2460, 420, 30),
		Rect2(40, 2720, 660, 40), # Second sealed crossing starts here.
		Rect2(1320, 3100, 520, 40), # Reached through phase gate B.
		Rect2(700, 3340, 460, 30),
		Rect2(120, 3600, 580, 40), # Exit floor.
	]


static func _static_service_collectibles() -> Array[Vector2]:
	# The first core is deliberately a short walk from spawn rather than an
	# automatic pickup. The rest mark each committed descent through the shaft.
	return [
		Vector2(1300, 188), Vector2(420, 698), Vector2(1350, 1228),
		Vector2(1580, 2148), Vector2(420, 2688), Vector2(900, 3308),
	]


static func _static_service_keys() -> Array[Vector2]:
	# Both relays sit in full bays, well away from their corresponding gates.
	return [Vector2(1730, 1228), Vector2(1770, 3068)]


static func _static_service_hazards() -> Array[Rect2]:
	return []


static func _static_service_moving_hazards() -> Array[Dictionary]:
	# Each moving field patrols a shelf that the descending route must cross.
	# None sit on a save, a gate, or a required pickup.
	return [
		{"position": Vector2(780, 438), "range": 150.0, "speed": 88.0, "size": Vector2(42, 42)},
		{"position": Vector2(820, 1498), "range": 160.0, "speed": 94.0, "size": Vector2(42, 42)},
		{"position": Vector2(760, 2428), "range": 170.0, "speed": 90.0, "size": Vector2(42, 42)},
	]


static func _static_service_portals() -> Array[Dictionary]:
	# These are the two only cross-shafts that cannot be crossed by a normal
	# drop, wall kick, or multi-jump. Every portal has a reciprocal return.
	var lower_shaft_gate := Rect2(170, 1716, 52, 64)
	var relay_bay_gate := Rect2(1320, 2116, 52, 64)
	var lower_cross_gate := Rect2(240, 2656, 52, 64)
	var exit_bay_gate := Rect2(1350, 3036, 52, 64)
	return [
		{"rect": lower_shaft_gate, "target": relay_bay_gate.get_center(), "action": "down", "label": "RELAY BAY"},
		{"rect": relay_bay_gate, "target": lower_shaft_gate.get_center(), "action": "up", "label": "LOWER SHAFT"},
		{"rect": lower_cross_gate, "target": exit_bay_gate.get_center(), "action": "down", "label": "EXIT BAY"},
		{"rect": exit_bay_gate, "target": lower_cross_gate.get_center(), "action": "up", "label": "CROSS SHAFT"},
	]


static func _static_service_checkpoints() -> Array[Dictionary]:
	return [
		{"rect": Rect2(240, 630, 80, 100), "position": Vector2(280, 686), "spawn": Vector2(280, 698), "name": "LOWER INTAKE"},
		{"rect": Rect2(1080, 1160, 80, 100), "position": Vector2(1120, 1216), "spawn": Vector2(1120, 1228), "name": "RELAY ALCOVE"},
		{"rect": Rect2(1400, 2080, 80, 100), "position": Vector2(1440, 2136), "spawn": Vector2(1440, 2148), "name": "SEALED BAY"},
		{"rect": Rect2(560, 2620, 80, 100), "position": Vector2(600, 2676), "spawn": Vector2(600, 2688), "name": "CROSS SHAFT"},
		{"rect": Rect2(740, 3240, 80, 100), "position": Vector2(780, 3296), "spawn": Vector2(780, 3308), "name": "EXIT DEPTH"},
	]


static func _portal_pairs(down_x: Array[float], return_x: Array[float], upper_routes: Array[Dictionary]) -> Array[Dictionary]:
	var sub_layer := Rect2(down_x[0], 836, 52, 64)
	var sub_layer_return := Rect2(return_x[0] - 20, 966, 52, 64)
	var low_archive := Rect2(down_x[1], 836, 52, 64)
	var low_archive_return := Rect2(return_x[1] - 20, 966, 52, 64)
	var result: Array[Dictionary] = [
		{"rect": sub_layer, "target": sub_layer_return.get_center(), "action": "down", "label": "SUB-LAYER"},
		{"rect": sub_layer_return, "target": sub_layer.get_center(), "action": "up", "label": "MAIN RAIL"},
		{"rect": low_archive, "target": low_archive_return.get_center(), "action": "down", "label": "LOW ARCHIVE"},
		{"rect": low_archive_return, "target": low_archive.get_center(), "action": "up", "label": "SERVICE RAIL"},
	]
	for route in upper_routes:
		var entry_rect := Rect2(float(route["entry_x"]), 836, 52, 64)
		var return_rect: Rect2 = route["return_rect"]
		result.append({
			"rect": entry_rect,
			"target": return_rect.get_center(),
			"action": "up",
			"label": route["label"],
		})
		result.append({
			"rect": return_rect,
			"target": entry_rect.get_center(),
			"action": "down",
			"label": "MAIN RAIL" if result.size() == 5 else "EXIT RAIL",
		})
	return result
