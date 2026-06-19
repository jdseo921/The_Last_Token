extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

func _ready() -> void:
	GameState.start_static_service_run()
	configure_stage({
		"title": "STATIC SERVICE RUN",
		"objective": "Gus needs the Staff Door systems powered. Collect 3 Signal Fuses, avoid static leaks, and reach the breaker panel.",
		"collectible_label": "Fuses",
		"required_collectibles": 3,
		"hazard_lines": [
			"STATIC DISCHARGE.",
			"Signal reset.",
		],
		"completion_lines": [
			"SERVICE POWER RESTORED.",
			"STAFF DOOR SYSTEMS ONLINE.",
			"MAINTENANCE SYNC AVAILABLE.",
		],
		"layout": [
			"############",
			"#P..C......#",
			"#.####.##..#",
			"#....#..H..#",
			"#.##.#.###.#",
			"#..H...C...#",
			"#.######.#.#",
			"#..C.....G.#",
			"############",
		],
		"player_adventure_sprite_path": "res://assets/art/minigames/adventure/player_8bit.png",
		"tile_sheet_path": "res://assets/art/minigames/adventure/maintenance_tiles.png",
		"hazard_sprite_path": "res://assets/art/minigames/adventure/static_leak.png",
		"collectible_sprite_path": "res://assets/art/minigames/adventure/signal_fuse.png",
	})

func _on_stage_completed() -> void:
	GameState.complete_static_service_run()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_hall()
