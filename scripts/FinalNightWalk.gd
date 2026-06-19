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
	})

func _on_stage_completed() -> void:
	GameState.complete_final_night_walk()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromFinalNightWalk")
	SceneChanger.go_to_staff_corridor()
