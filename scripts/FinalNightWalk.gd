extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

var ambush_done := false

func _ready() -> void:
	AudioManager.play_music_for_context("final_night_walk")
	GameState.start_final_night_walk()
	configure_stage(get_stage_config())
	_refresh_status("The tape rolls. Walk the route\nin the order the night happened.\n\nSomething else is walking it too.")

static func get_stage_config() -> Dictionary:
	return {
		"title": "FINAL NIGHT WALK",
		"objective": "Walk the final route as the tape remembers it. Collect the 16 Memory Frames in order. A second signal walks these halls - do not let it cross you.",
		"collectible_label": "Frames",
		"required_collectibles": 16,
		"ordered_collectibles": true,
		"reset_order_on_conflict": false,
		"hazards_blink": true,
		"hazard_blink_interval": 1.2,
		"move_step_interval": 0.15,
		"tile_size": 20,
		"grid_origin": Vector2(32, 126),
		"side_panel_x": 430,
		"controls_hint": "Move: WASD / Arrows. R: restart.",
		"goal_hint": "Frames 1-16 in order, then EXIT.",
		"collectible_marker": "M",
		"hazard_marker": "RW",
		"goal_marker": "EXIT",
		"player_adventure_sprite_path": "res://assets/art/minigames/adventure/player_8bit.png",
		"hazard_sprite_path": "res://assets/art/minigames/adventure/rewind_static_gen.png",
		"collectible_sprite_path": "res://assets/art/minigames/adventure/memory_frame_gen.png",
		"goal_sprite_path": "res://assets/art/minigames/adventure/staff_door_gen.png",
		"moving_hazard_sprite_path": "res://assets/art/minigames/adventure/second_signal_gen.png",
		"background_screen_path": "res://assets/art/minigames/adventure/backgrounds/final_night_walk_bg_640x440.png",
		"floor_color": Color(0.115, 0.105, 0.16, 0.26),
		"wall_color": Color(0.04, 0.034, 0.06, 0.88),
		"hazard_color": Color(0.72, 0.22, 0.78, 1.0),
		"collectible_color": Color(0.42, 0.62, 1.0, 1.0),
		"goal_color": Color(0.86, 0.58, 0.24, 1.0),
		"player_color": Color(0.92, 0.9, 1.0, 1.0),
		"collectible_texts": [
			"Counter lights shut off.",
			"Mira counted tokens twice.",
			"The ticket strip curled under the counter.",
			"Someone locked the front door from inside.",
			"Cabinet 07 stayed awake.",
			"A blank high score pulsed once.",
			"Someone walked past without a reflection.",
			"The cabinet row hummed a closing song.",
			"Vendo's display flickered without coins.",
			"The prize shelf tags turned backward.",
			"A plush faced the staff hallway.",
			"The schedule changed after closing.",
			"A staff member entered the back hall.",
			"The security tape skipped.",
			"The Staff Door recorded two signals.",
			"One signal kept walking.",
		],
		"wrong_order_lines": [
			"TIMESTAMP CONFLICT.",
			"That is not the next thing that happened.",
			"The route pulls you back to remember.",
		],
		"hazard_lines": [
			"REWIND STATIC.",
			"The route pulls you back.",
		],
		"conscience_hazard_lines": [
			"The second signal crosses your path.",
			"For one frame you see the route the way it walked it.",
			"A counter, dark. A door, patient. A turn not taken.",
			"The tape rewinds you to where you were.",
		],
		"completion_lines": [
			"FINAL NIGHT ROUTE STABILIZED.",
			"The second signal stops moving.",
			"It stands at the Staff Door, waiting for you to catch up.",
			"MEMORY ECHO AVAILABLE.",
			"THE STAFF DOOR DID NOT RECORD A CUSTOMER.",
		],
		"secret_lines": [
			"PRIVATE FRAME FOUND.",
			"A moment the tape never showed anyone:",
			"someone kneeling to fix the plush's bow tie",
			"before turning off the prize corner lights.",
		],
		"secret_flag": "fnw_secret_echo_found",
		"moving_hazard_color": Color(0.9, 0.42, 0.98, 1.0),
		"moving_hazards": [
			{"area": "counter", "axis": "h", "line": 12, "from": 12, "to": 15, "interval": 0.55, "marker": "RW"},
			{"area": "cabinet", "axis": "h", "line": 12, "from": 3, "to": 6, "interval": 0.5, "marker": "RW"},
			{"area": "snack_prize", "axis": "h", "line": 12, "from": 11, "to": 15, "interval": 0.46, "marker": "RW"},
			{"area": "back_hall", "axis": "h", "line": 12, "from": 1, "to": 4, "interval": 0.4, "marker": "RW"},
			{"area": "staff_door", "axis": "h", "line": 12, "from": 10, "to": 13, "interval": 0.36, "marker": "RW"},
		],
		"start_area": "counter",
		"areas": [
			{
				"id": "counter",
				"name": "Counter After Close",
				"layout": [
					"###################",
					"#P..C..#.....#...1#",
					"#.###..#.###.#.##.#",
					"#...##.#.#...#..#.#",
					"##.C#..#.#.#####..#",
					"#..##.##.#.....##.#",
					"#.....#..#####..#.#",
					"#.#####.C#....#.#.#",
					"#.#...#.##.##.#.#.#",
					"#.#.#.#..#..#.#.#.#",
					"#...#.##.##.#.#.#.#",
					"#.#.#..#..#.#...#.#",
					"#.#..C.#..H.....2.#",
					"###################",
				],
			},
			{
				"id": "cabinet",
				"name": "Cabinet Aisle",
				"layout": [
					"###################",
					"#1.....#..C#.....##",
					"#.###.##.#.#.###..#",
					"#..C#.#..#.#...##.#",
					"###.#.#.##.###..#.#",
					"#...#.#.#....##.#.#",
					"#.###.#.#.##..#.#.#",
					"#.#...#.#..##C#.#.#",
					"#.#.###.##.#..#.#.#",
					"#.#...#..#.#.##.#.#",
					"#.###.##.#.#.#..#.#",
					"#...#..#...#..C.#3#",
					"#.#....#.H.#..##..#",
					"###################",
				],
			},
			{
				"id": "snack_prize",
				"name": "Snack And Prize Path",
				"layout": [
					"###################",
					"#2...#....C#.....##",
					"#.##.#.###.#.###..#",
					"#..#.#.#...#...##.#",
					"##.#.#.#.#####C.#.#",
					"#..#...#....#.###.#",
					"#.##.####.#.#...#.#",
					"#..#.#..#.#.###.#.#",
					"##.#.#..#.#...#.#.#",
					"#..#.##.#.###.#.#.#",
					"#.##..#.#.#.C.#.#.#",
					"#.#..S#.#.#.###.#4#",
					"#....##.#.H.....#.#",
					"###################",
				],
			},
			{
				"id": "back_hall",
				"name": "Back Hall Footsteps",
				"layout": [
					"###################",
					"#3.....#...C#....4#",
					"#.###.##.##.#.##.##",
					"#...#.#...#.#..#..#",
					"###.#.#.#.#.##.##.#",
					"#...#.#.#.#..#..#.#",
					"#.###.#.#.##C##.#.#",
					"#.#...#.#..#..#.#.#",
					"#.#.###.##.##.#.#.#",
					"#.#.#...##..#.#.#.#",
					"#.#.#.##.##.#...#.#",
					"#5..#..#..#.##.##.#",
					"#....#.H..#.....C.#",
					"###################",
				],
			},
			{
				"id": "staff_door",
				"name": "Staff Door Memory",
				"layout": [
					"###################",
					"#5...#.......#....#",
					"#.##.#.#####.#.##.#",
					"#..#.#.#...#.#..#.#",
					"##.#.#.#.#.#.##.#.#",
					"#..#...#.#.#..#.#.#",
					"#.##.#.#.#.##C#.#.#",
					"#..#.#...#..#.#.#.#",
					"##.#.#.#####.#..#.#",
					"#..#.#.....#.##.#.#",
					"#.##.#####.#..#.#.#",
					"#..C.#...#.##.#.#.#",
					"#....#.H.#......E.#",
					"###################",
				],
			},
		],
		"area_links": [
			{"from_area": "counter", "marker": "1", "label": "CAB", "target_area": "cabinet", "target_spawn": Vector2i(1, 1)},
			{"from_area": "cabinet", "marker": "1", "label": "CTR", "target_area": "counter", "target_spawn": Vector2i(16, 1)},
			{"from_area": "counter", "marker": "2", "label": "PRZ", "target_area": "snack_prize", "target_spawn": Vector2i(1, 1)},
			{"from_area": "snack_prize", "marker": "2", "label": "CTR", "target_area": "counter", "target_spawn": Vector2i(16, 12)},
			{"from_area": "cabinet", "marker": "3", "label": "BACK", "target_area": "back_hall", "target_spawn": Vector2i(1, 1)},
			{"from_area": "back_hall", "marker": "3", "label": "CAB", "target_area": "cabinet", "target_spawn": Vector2i(17, 11)},
			{"from_area": "snack_prize", "marker": "4", "label": "BACK", "target_area": "back_hall", "target_spawn": Vector2i(16, 1)},
			{"from_area": "back_hall", "marker": "4", "label": "PRZ", "target_area": "snack_prize", "target_spawn": Vector2i(17, 11)},
			{"from_area": "back_hall", "marker": "5", "label": "DOOR", "target_area": "staff_door", "target_spawn": Vector2i(1, 1)},
			{"from_area": "staff_door", "marker": "5", "label": "BACK", "target_area": "back_hall", "target_spawn": Vector2i(1, 11)},
		],
	}

func _on_area_entered(area_id: String) -> void:
	if area_id == "staff_door" and not ambush_done and not completed:
		ambush_done = true
		moving_hazard_defs.append({
			"area": "staff_door", "axis": "h", "line": 1, "from": 6, "to": 12,
			"interval": 0.26, "marker": "RW",
		})
		_build_moving_hazards()
		_refresh_status("The second signal knew\nwhere you were going.\n\nIt got here first.\n\nIt walks the top hall now,\nfaster than the tape.")

func _on_stage_reset() -> void:
	ambush_done = false

func _on_stage_completed() -> void:
	GameState.complete_final_night_walk()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromFinalNightWalk")
	SceneChanger.go_to_staff_corridor()
