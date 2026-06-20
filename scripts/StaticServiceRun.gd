extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

func _ready() -> void:
	GameState.start_static_service_run()
	configure_stage({
		"title": "STATIC SERVICE RUN",
		"objective": "Gus needs the Staff Door systems powered. Collect 3 Signal Fuses, avoid static leaks, and reach the breaker panel.",
		"collectible_label": "Fuses",
		"required_collectibles": 3,
		"controls_hint": "Move: WASD / Arrow Keys",
		"goal_hint": "Collect 3 Signal Fuses, then reach BRK.",
		"collectible_marker": "F",
		"hazard_marker": "ZAP",
		"goal_marker": "BRK",
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
		"goal_sprite_path": "res://assets/art/minigames/adventure/breaker_panel.png",
	})

func _on_stage_completed() -> void:
	GameState.complete_static_service_run()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_hall()
