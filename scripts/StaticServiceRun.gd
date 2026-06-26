extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

func _ready() -> void:
	AudioManager.play_music_for_context("static_service_run")
	GameState.start_static_service_run()
	configure_stage(get_stage_config())

static func get_stage_config() -> Dictionary:
	return {
		"title": "STATIC SERVICE RUN",
		"objective": "Restore service power across the back halls. Collect 16 Signal Fuses, route through service doors, avoid static leaks, then reach BRK.",
		"collectible_label": "Fuses",
		"required_collectibles": 16,
		"target_minutes": 5,
		"tile_size": 20,
		"grid_origin": Vector2(32, 126),
		"side_panel_x": 430,
		"controls_hint": "Move: WASD / Arrow Keys",
		"goal_hint": "Collect all 16 fuses, then reach BRK.",
		"collectible_marker": "F",
		"hazard_marker": "ZAP",
		"goal_marker": "BRK",
		"player_adventure_sprite_path": "res://assets/art/minigames/adventure/player_8bit.png",
		"hazard_sprite_path": "res://assets/art/minigames/adventure/static_leak.png",
		"collectible_sprite_path": "res://assets/art/minigames/adventure/signal_fuse.png",
		"goal_sprite_path": "res://assets/art/minigames/adventure/breaker_panel.png",
		"floor_color": Color(0.10, 0.13, 0.16, 1.0),
		"wall_color": Color(0.045, 0.055, 0.065, 1.0),
		"hazard_color": Color(0.26, 0.72, 0.95, 1.0),
		"collectible_color": Color(0.95, 0.76, 0.22, 1.0),
		"goal_color": Color(0.22, 0.82, 0.52, 1.0),
		"player_color": Color(0.88, 0.95, 1.0, 1.0),
		"hazard_lines": [
			"STATIC DISCHARGE.",
			"Signal reset.",
		],
		"completion_lines": [
			"SERVICE POWER RESTORED.",
			"STAFF DOOR SYSTEMS ONLINE.",
			"MAINTENANCE SYNC AVAILABLE.",
		],
		"start_area": "entry",
		"areas": [
			{
				"id": "entry",
				"name": "Service Entry",
				"layout": [
					"##################",
					"#P..C....#....2..#",
					"#.####.#.#.####..#",
					"#....#.#...#.....#",
					"###..#.#####.###.#",
					"#1...#...H...#...#",
					"#.######.#####.#.#",
					"#....C.......#.#.#",
					"#.##########.#.#.#",
					"#C.............#.#",
					"##################",
				],
			},
			{
				"id": "crawl",
				"name": "Fuse Crawl",
				"layout": [
					"##################",
					"#1....#....C.....#",
					"#.###.#.######.#.#",
					"#...#.#....H...#.#",
					"###.#.#######.##.#",
					"#...#.....C.#....#",
					"#.#######.#.####.#",
					"#.....H...#....3.#",
					"#.##############.#",
					"#..............C.#",
					"##################",
				],
			},
			{
				"id": "relay",
				"name": "Relay Spine",
				"layout": [
					"##################",
					"#2....C.....#..5.#",
					"#.######.##.#.##.#",
					"#....H...#..#....#",
					"###.######.#####.#",
					"#3..#....C.....#.#",
					"#.###.########.#.#",
					"#.....#..H..#..4.#",
					"#.###.#.###.#.##.#",
					"#...C............#",
					"##################",
				],
			},
			{
				"id": "storage",
				"name": "Parts Storage",
				"layout": [
					"##################",
					"#4....#.....C....#",
					"#.###.#.########.#",
					"#...#.#....H.....#",
					"###.#.#######.##.#",
					"#...#.....C.#....#",
					"#.#######.#.####.#",
					"#.....H...#......#",
					"#.##############.#",
					"#..............C.#",
					"##################",
				],
			},
			{
				"id": "breaker",
				"name": "Breaker Room",
				"layout": [
					"##################",
					"#5..C....#....C..#",
					"#.####.#.#.####..#",
					"#....#.#...#..H..#",
					"###..#.#####.###.#",
					"#C...#.......#...#",
					"#.######.#####.#.#",
					"#....H.......#.#.#",
					"#.##########.#.#.#",
					"#......C.....E...#",
					"##################",
				],
			},
		],
		"area_links": [
			{"from_area": "entry", "marker": "1", "label": "DUCT", "target_area": "crawl", "target_spawn": Vector2i(2, 1)},
			{"from_area": "crawl", "marker": "1", "label": "ENT", "target_area": "entry", "target_spawn": Vector2i(2, 5)},
			{"from_area": "entry", "marker": "2", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(2, 1)},
			{"from_area": "relay", "marker": "2", "label": "ENT", "target_area": "entry", "target_spawn": Vector2i(14, 1)},
			{"from_area": "crawl", "marker": "3", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(2, 5)},
			{"from_area": "relay", "marker": "3", "label": "DUCT", "target_area": "crawl", "target_spawn": Vector2i(15, 7)},
			{"from_area": "relay", "marker": "4", "label": "STOR", "target_area": "storage", "target_spawn": Vector2i(2, 1)},
			{"from_area": "storage", "marker": "4", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(15, 7)},
			{"from_area": "relay", "marker": "5", "label": "BRK", "target_area": "breaker", "target_spawn": Vector2i(2, 1)},
			{"from_area": "breaker", "marker": "5", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(15, 1)},
		],
	}

func _on_stage_completed() -> void:
	GameState.complete_static_service_run()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_hall()
