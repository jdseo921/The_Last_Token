extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

func _ready() -> void:
	GameState.start_final_night_walk()
	configure_stage({
		"title": "FINAL NIGHT WALK",
		"objective": "The tape is ordered. Walk the route it remembers. Collect the Memory Frames in order and avoid rewind static.",
		"collectible_label": "Frames",
		"required_collectibles": 4,
		"ordered_collectibles": true,
		"reset_order_on_conflict": true,
		"controls_hint": "Move: WASD / Arrow Keys",
		"goal_hint": "Collect Memory Frames 1-4 in order, then exit.",
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
			"Cabinet 07 stayed awake.",
			"A staff member entered the back hall.",
			"The Staff Door recorded two signals.",
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
		"layout": [
			"###############",
			"#P.C.........E#",
			"#.###.###.###.#",
			"#...#...C...#.#",
			"#.#.#.#####.#.#",
			"#.#.....H...#.#",
			"#.#####.###.#.#",
			"#.....C...#C..#",
			"###############",
		],
		"player_adventure_sprite_path": "res://assets/art/minigames/adventure/player_8bit.png",
		"tile_sheet_path": "res://assets/art/minigames/adventure/final_night_tiles.png",
		"hazard_sprite_path": "res://assets/art/minigames/adventure/rewind_static.png",
		"collectible_sprite_path": "res://assets/art/minigames/adventure/memory_frame.png",
		"goal_sprite_path": "res://assets/art/minigames/adventure/staff_door_marker.png",
	})

func _on_stage_completed() -> void:
	GameState.complete_final_night_walk()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromFinalNightWalk")
	SceneChanger.go_to_staff_corridor()
