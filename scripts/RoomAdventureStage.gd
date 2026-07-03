extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

@export var stage_id := "hub_ticket_sweep"

func _ready() -> void:
	AudioManager.play_music_for_context(_get_music_context())
	configure_stage(_get_stage_config(stage_id))

static func _get_stage_config(id: String) -> Dictionary:
	match id:
		"cabinet_trace_run":
			return _get_cabinet_trace_config()
		"snack_service_dash":
			return _get_snack_service_config()
		"prize_shelf_run":
			return _get_prize_shelf_config()
		_:
			return _get_hub_ticket_config()

func _get_music_context() -> String:
	match stage_id:
		"cabinet_trace_run":
			return "cabinet_row"
		"snack_service_dash":
			return "snack_alcove"
		"prize_shelf_run":
			return "arcade_hub"
		_:
			return "arcade_hub"

static func _get_hub_ticket_config() -> Dictionary:
	return {
		"title": "TICKET SWEEP",
		"objective": "Sweep the arcade floor. Collect 8 loose Tickets, avoid spill tiles, then return to CTR.",
		"collectible_label": "Tickets",
		"required_collectibles": 8,
		"fog_enabled": true,
		"fog_radius": 5,
		"hazards_blink": true,
		"hazard_blink_interval": 1.5,
		"tile_size": 22,
		"grid_origin": Vector2(36, 122),
		"side_panel_x": 430,
		"goal_hint": "8 Tickets, watch the spill, then CTR.",
		"collectible_marker": "T",
		"hazard_marker": "SPL",
		"goal_marker": "CTR",
		"floor_color": Color(0.12, 0.12, 0.18, 1.0),
		"wall_color": Color(0.05, 0.055, 0.08, 1.0),
		"collectible_color": Color(0.95, 0.78, 0.24, 1.0),
		"hazard_color": Color(0.18, 0.52, 0.68, 1.0),
		"goal_color": Color(0.42, 0.74, 0.46, 1.0),
		"hazard_lines": ["STICKY CARPET.", "Back to the counter."],
		"completion_lines": ["TICKET SWEEP COMPLETE.", "The floor remembers less noise now."],
		"start_area": "floor",
		"areas": [
			{
				"id": "floor",
				"name": "Arcade Floor",
				"layout": [
					"##################",
					"#P.C.....#....C..#",
					"#.####.#.#.####..#",
					"#..C.#.#...#.....#",
					"###..#.#####.###.#",
					"#....#...H...#...#",
					"#.######.#####.#.#",
					"#..C.........#.#.#",
					"#.##########.#.#.#",
					"#C.....C....C..CE#",
					"##################",
				],
			},
		],
	}

static func _get_cabinet_trace_config() -> Dictionary:
	return {
		"title": "CABINET TRACE RUN",
		"objective": "Follow the cabinet trace in order. Collect 10 Trace Sparks, avoid static, then reach LOG.",
		"collectible_label": "Sparks",
		"required_collectibles": 10,
		"ordered_collectibles": true,
		"reset_order_on_conflict": true,
		"tile_size": 20,
		"grid_origin": Vector2(32, 126),
		"side_panel_x": 430,
		"goal_hint": "Collect Sparks 1-10 in order, then reach LOG.",
		"collectible_marker": "S",
		"hazard_marker": "ERR",
		"goal_marker": "LOG",
		"floor_color": Color(0.09, 0.11, 0.18, 1.0),
		"wall_color": Color(0.045, 0.04, 0.07, 1.0),
		"collectible_color": Color(0.42, 0.66, 1.0, 1.0),
		"hazard_color": Color(0.7, 0.18, 0.4, 1.0),
		"goal_color": Color(0.42, 0.82, 0.66, 1.0),
		"collectible_texts": [
			"Cabinet boot spark recovered.",
			"Truth cabinet ping accepted.",
			"Blank score trace accepted.",
			"Roxy's cabinet flickers once.",
			"Mr. Byte logs the order.",
			"Old profile trace recovered.",
			"False record trace discarded.",
			"Screen static narrows.",
			"Cabinet row signal lines up.",
			"Trace route complete.",
		],
		"wrong_order_lines": ["TRACE ORDER CONFLICT.", "The cabinet row rewinds."],
		"hazard_lines": ["CABINET STATIC.", "Trace reset."],
		"completion_lines": ["CABINET TRACE COMPLETE.", "The row remembers in order."],
		"start_area": "row",
		"areas": [
			{
				"id": "row",
				"name": "Cabinet Trace",
				"layout": [
					"##################",
					"#P.C....#....C..1#",
					"#.####..#.####...#",
					"#..C.#..#....#...#",
					"###..#.####..###.#",
					"#C...#....H......#",
					"#.######.#######.#",
					"#..............2.#",
					"#.##############.#",
					"#C...........C...#",
					"##################",
				],
			},
			{
				"id": "back",
				"name": "Back Cabinets",
				"layout": [
					"##################",
					"#1....C....#.....#",
					"#.######.#.#.###.#",
					"#......#.#.#...#.#",
					"####.#.#.#.###.#.#",
					"#....#...#...C.#.#",
					"#.###########.#..#",
					"#....H........#2.#",
					"#.#############..#",
					"#C............CE.#",
					"##################",
				],
			},
		],
		"area_links": [
			{"from_area": "row", "marker": "1", "label": "BACK", "target_area": "back", "target_spawn": Vector2i(2, 1)},
			{"from_area": "back", "marker": "1", "label": "ROW", "target_area": "row", "target_spawn": Vector2i(15, 1)},
			{"from_area": "row", "marker": "2", "label": "BACK", "target_area": "back", "target_spawn": Vector2i(15, 7)},
			{"from_area": "back", "marker": "2", "label": "ROW", "target_area": "row", "target_spawn": Vector2i(15, 7)},
		],
	}

static func _get_snack_service_config() -> Dictionary:
	return {
		"title": "SNACK SERVICE DASH",
		"objective": "Stock the route without spilling the signal. Collect 9 Labels, dodge fizz, then reach OUT.",
		"collectible_label": "Labels",
		"required_collectibles": 9,
		"tile_size": 20,
		"grid_origin": Vector2(32, 126),
		"side_panel_x": 430,
		"goal_hint": "Collect all 9 Labels, then reach OUT.",
		"collectible_marker": "L",
		"hazard_marker": "FZ",
		"goal_marker": "OUT",
		"floor_color": Color(0.13, 0.08, 0.11, 1.0),
		"wall_color": Color(0.06, 0.04, 0.055, 1.0),
		"collectible_color": Color(0.22, 0.88, 0.76, 1.0),
		"hazard_color": Color(0.95, 0.34, 0.42, 1.0),
		"goal_color": Color(0.86, 0.72, 0.25, 1.0),
		"hazard_lines": ["CARBONATION BURST.", "Route pressure reset."],
		"completion_lines": ["SNACK SERVICE COMPLETE.", "Labels sorted. Signal still fizzy."],
		"start_area": "stock",
		"areas": [
			{
				"id": "stock",
				"name": "Stock Shelf",
				"layout": [
					"##################",
					"#P..C....#....1..#",
					"#.####.#.#.####..#",
					"#....#.#...#.....#",
					"###..#.#####.###.#",
					"#C...#...H...#...#",
					"#.######.#####.#.#",
					"#....C.......#.#.#",
					"#.##########.#.#.#",
					"#C...........C...#",
					"##################",
				],
			},
			{
				"id": "route",
				"name": "Fizz Route",
				"layout": [
					"##################",
					"#1....#....C.....#",
					"#.###.#.######.#.#",
					"#...#.#....H...#.#",
					"###.#.#######.##.#",
					"#...#.....C.#....#",
					"#.#######.#.####.#",
					"#.....H...#......#",
					"#.##############.#",
					"#C.............CE#",
					"##################",
				],
			},
		],
		"area_links": [
			{"from_area": "stock", "marker": "1", "label": "FIZZ", "target_area": "route", "target_spawn": Vector2i(2, 1)},
			{"from_area": "route", "marker": "1", "label": "STOCK", "target_area": "stock", "target_spawn": Vector2i(14, 1)},
		],
	}

static func _get_prize_shelf_config() -> Dictionary:
	return {
		"title": "PRIZE SHELF RUN",
		"objective": "Sort the shelf path by feeling, not value. Collect 7 Tags, avoid loose hooks, then reach TAG.",
		"collectible_label": "Tags",
		"required_collectibles": 7,
		"tile_size": 22,
		"grid_origin": Vector2(36, 122),
		"side_panel_x": 430,
		"goal_hint": "Collect all 7 Tags, then reach TAG.",
		"collectible_marker": "P",
		"hazard_marker": "HK",
		"goal_marker": "TAG",
		"floor_color": Color(0.13, 0.1, 0.15, 1.0),
		"wall_color": Color(0.055, 0.045, 0.065, 1.0),
		"collectible_color": Color(0.95, 0.62, 0.82, 1.0),
		"hazard_color": Color(0.62, 0.26, 0.7, 1.0),
		"goal_color": Color(0.82, 0.7, 0.28, 1.0),
		"hazard_lines": ["LOOSE PRIZE HOOK.", "Back to the shelf start."],
		"completion_lines": ["PRIZE SHELF RUN COMPLETE.", "Nothing valuable moved. Something familiar did."],
		"start_area": "shelf",
		"areas": [
			{
				"id": "shelf",
				"name": "Prize Shelf",
				"layout": [
					"##################",
					"#P.C....#....C...#",
					"#.####.#.#.####..#",
					"#....#.#...#.....#",
					"###..#.#####.###.#",
					"#C...#...H...#...#",
					"#.######.#####.#.#",
					"#....C.......#.#.#",
					"#.##########.#.#.#",
					"#C.........C...CE#",
					"##################",
				],
			},
		],
	}

func _on_return_pressed() -> void:
	if return_in_progress:
		return
	return_in_progress = true
	_play_audio("play_ui_cancel")
	if return_button:
		return_button.disabled = true
	match stage_id:
		"cabinet_trace_run":
			GameState.set_pending_spawn_id("Spawn_FromCabinetAdventure")
			SceneChanger.go_to_cabinet_row()
		"snack_service_dash":
			GameState.set_pending_spawn_id("Spawn_FromSnackAdventure")
			SceneChanger.go_to_snack_alcove()
		"prize_shelf_run":
			GameState.set_pending_spawn_id("Spawn_FromPrizeAdventure")
			SceneChanger.go_to_prize_corner()
		_:
			GameState.set_pending_spawn_id("Spawn_FromHubAdventure")
			SceneChanger.go_to_arcade_hub()
