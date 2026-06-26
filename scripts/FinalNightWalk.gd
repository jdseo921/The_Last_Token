extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

func _ready() -> void:
	AudioManager.play_music_for_context("final_night_walk")
	GameState.start_final_night_walk()
	configure_stage(get_stage_config())

static func get_stage_config() -> Dictionary:
	return {
		"title": "FINAL NIGHT WALK",
		"objective": "Walk the final route as the tape remembers it. Collect 16 Memory Frames in order, avoid rewind static, then exit.",
		"collectible_label": "Frames",
		"required_collectibles": 16,
		"ordered_collectibles": true,
		"reset_order_on_conflict": true,
		"target_minutes": 5,
		"tile_size": 20,
		"grid_origin": Vector2(32, 126),
		"side_panel_x": 430,
		"controls_hint": "Move: WASD / Arrow Keys",
		"goal_hint": "Collect Frames 1-16 in order, then exit.",
		"collectible_marker": "M",
		"hazard_marker": "RW",
		"goal_marker": "EXIT",
		"floor_color": Color(0.115, 0.105, 0.16, 1.0),
		"wall_color": Color(0.052, 0.045, 0.075, 1.0),
		"hazard_color": Color(0.72, 0.22, 0.78, 1.0),
		"collectible_color": Color(0.42, 0.62, 1.0, 1.0),
		"goal_color": Color(0.86, 0.58, 0.24, 1.0),
		"player_color": Color(0.92, 0.9, 1.0, 1.0),
		"collectible_texts": [
			"Counter lights shut off.",
			"Mira counted tokens twice.",
			"The ticket strip curled under the counter.",
			"Cabinet 07 stayed awake.",
			"Gus checked the service panel.",
			"A blank high score pulsed once.",
			"Someone walked past without a reflection.",
			"Vendo's display flickered without coins.",
			"The prize shelf tags turned backward.",
			"A plush faced the staff hallway.",
			"The snack light buzzed like a warning.",
			"The schedule changed after closing.",
			"A staff member entered the back hall.",
			"The security tape skipped.",
			"The Staff Door recorded two signals.",
			"One signal kept walking.",
		],
		"wrong_order_lines": [
			"TIMESTAMP CONFLICT.",
			"The memory rewinds.",
		],
		"hazard_lines": [
			"REWIND STATIC.",
			"The route pulls you back.",
		],
		"completion_lines": [
			"FINAL NIGHT ROUTE STABILIZED.",
			"MEMORY ECHO AVAILABLE.",
			"THE STAFF DOOR DID NOT RECORD A CUSTOMER.",
		],
		"start_area": "counter",
		"areas": [
			{
				"id": "counter",
				"name": "Counter After Close",
				"layout": [
					"##################",
					"#P.C....#.....1..#",
					"#.####..#.####...#",
					"#....#..#....#...#",
					"###..#.####..###.#",
					"#C...#....H......#",
					"#.######.#######.#",
					"#..............2.#",
					"#.##############.#",
					"#C...............#",
					"##################",
				],
			},
			{
				"id": "cabinet",
				"name": "Cabinet Aisle",
				"layout": [
					"##################",
					"#1....C....#.....#",
					"#.######.#.#.###.#",
					"#......#.#.#...#.#",
					"####.#.#.#.###.#.#",
					"#....#...#...C.#.#",
					"#.###########.#..#",
					"#....H........#3.#",
					"#.#############..#",
					"#C............C..#",
					"##################",
				],
			},
			{
				"id": "snack_prize",
				"name": "Snack And Prize Path",
				"layout": [
					"##################",
					"#2....C....#.....#",
					"#.######.#.#.###.#",
					"#......#.#.#...#.#",
					"####.#.#.#.###.#.#",
					"#....#...#...C.#.#",
					"#.###########.#..#",
					"#....H........#4.#",
					"#.#############..#",
					"#C............C..#",
					"##################",
				],
			},
			{
				"id": "back_hall",
				"name": "Back Hall Footsteps",
				"layout": [
					"##################",
					"#3....#....C....4#",
					"#.###.#.######.#.#",
					"#...#.#....H...#.#",
					"###.#.#######.##.#",
					"#...#.....C.#....#",
					"#.#######.#.####.#",
					"#.....H...#......#",
					"#.##############.#",
					"#...............5#",
					"##################",
				],
			},
			{
				"id": "staff_door",
				"name": "Staff Door Memory",
				"layout": [
					"##################",
					"#4..C....#.......#",
					"#.####.#.#.####..#",
					"#....#.#...#..H..#",
					"###..#.#####.###.#",
					"#....#.C.....#...#",
					"#.######.#####.#.#",
					"#....H.......#.#.#",
					"#.##########.#.#.#",
					"#......C.....E...#",
					"##################",
				],
			},
		],
		"area_links": [
			{"from_area": "counter", "marker": "1", "label": "CAB", "target_area": "cabinet", "target_spawn": Vector2i(2, 1)},
			{"from_area": "cabinet", "marker": "1", "label": "CTR", "target_area": "counter", "target_spawn": Vector2i(14, 1)},
			{"from_area": "counter", "marker": "2", "label": "PRZ", "target_area": "snack_prize", "target_spawn": Vector2i(2, 1)},
			{"from_area": "snack_prize", "marker": "2", "label": "CTR", "target_area": "counter", "target_spawn": Vector2i(15, 7)},
			{"from_area": "cabinet", "marker": "3", "label": "BACK", "target_area": "back_hall", "target_spawn": Vector2i(2, 1)},
			{"from_area": "back_hall", "marker": "3", "label": "CAB", "target_area": "cabinet", "target_spawn": Vector2i(15, 7)},
			{"from_area": "snack_prize", "marker": "4", "label": "BACK", "target_area": "back_hall", "target_spawn": Vector2i(15, 1)},
			{"from_area": "back_hall", "marker": "4", "label": "PRZ", "target_area": "snack_prize", "target_spawn": Vector2i(15, 7)},
			{"from_area": "back_hall", "marker": "5", "label": "DOOR", "target_area": "staff_door", "target_spawn": Vector2i(2, 1)},
			{"from_area": "staff_door", "marker": "4", "label": "BACK", "target_area": "back_hall", "target_spawn": Vector2i(15, 1)},
		],
	}

func _on_stage_completed() -> void:
	GameState.complete_final_night_walk()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromFinalNightWalk")
	SceneChanger.go_to_staff_corridor()
