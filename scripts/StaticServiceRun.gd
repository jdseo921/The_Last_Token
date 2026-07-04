extends "res://scripts/minigames/adventure/ArcadeAdventureStage.gd"

var blackout_done := false

func _ready() -> void:
	AudioManager.play_music_for_context("static_service_run")
	GameState.start_static_service_run()
	configure_stage(get_stage_config())
	_refresh_status("GUS (radio): Grid's dead. Flip breakers as you go.\n\nSomething hums back when you move.")

static func get_stage_config() -> Dictionary:
	return {
		"title": "STATIC SERVICE RUN",
		"objective": "The halls are dark. Flip the 16 fuse-breakers to light the route, dodge the patrolling static, and reach the main breaker (BRK).",
		"collectible_label": "Fuses",
		"required_collectibles": 16,
		"fog_enabled": true,
		"fog_radius": 2,
		"breaker_reveal": true,
		"breaker_reveal_radius": 3,
		"hazards_blink": true,
		"hazard_blink_interval": 1.5,
		"tile_size": 20,
		"grid_origin": Vector2(32, 126),
		"side_panel_x": 430,
		"controls_hint": "Move: WASD / Arrows. R: restart.",
		"goal_hint": "All 16 fuses, then BRK.",
		"collectible_marker": "F",
		"hazard_marker": "ZAP",
		"goal_marker": "BRK",
		"player_adventure_sprite_path": "res://assets/art/minigames/adventure/player_8bit.png",
		"hazard_sprite_path": "res://assets/art/minigames/adventure/static_leak_gen.png",
		"collectible_sprite_path": "res://assets/art/minigames/adventure/signal_fuse_gen.png",
		"goal_sprite_path": "res://assets/art/minigames/adventure/breaker_panel_gen.png",
		"moving_hazard_sprite_path": "res://assets/art/minigames/adventure/static_surge_gen.png",
		"background_screen_path": "res://assets/art/minigames/adventure/backgrounds/static_service_run_bg_640x440.png",
		"floor_color": Color(0.10, 0.13, 0.16, 0.30),
		"wall_color": Color(0.03, 0.038, 0.048, 0.88),
		"hazard_color": Color(0.26, 0.72, 0.95, 1.0),
		"collectible_color": Color(0.95, 0.76, 0.22, 1.0),
		"goal_color": Color(0.22, 0.82, 0.52, 1.0),
		"player_color": Color(0.88, 0.95, 1.0, 1.0),
		"collectible_texts": [
			"Breaker up. A stretch of hall remembers its lights.",
			"The conduit hums awake under the floor.",
			"Somewhere a fan starts turning again.",
			"A work lamp flickers on over an old toolbox.",
			"The wiring crackles, then settles.",
			"Warmth crawls a little further down the wall.",
			"A junction box blinks from red to green.",
			"You hear the vending machine upstairs reboot.",
			"The dark gives back another few meters.",
			"Old cable trays rattle with fresh current.",
			"A section light buzzes, steadies, holds.",
			"The floor stripes glow faintly again.",
			"Another circuit remembers its job.",
			"The hum behind the walls drops half a tone.",
			"The service route sign lights up: THIS WAY.",
			"One breaker left in the chain. The main panel waits.",
		],
		"hazard_lines": [
			"STATIC DISCHARGE.",
			"Signal reset.",
		],
		"conscience_hazard_lines": [
			"The dark rushes back into the aisle you just lit.",
			"Something is pulling the current out behind you.",
			"You lit that hall. It did not stay lit.",
			"You are not the only thing moving in these halls.",
		],
		"completion_lines": [
			"SERVICE POWER RESTORED.",
			"The patrolling static thins, pulls back, and is gone.",
			"For a moment the hum sounds almost like breathing.",
			"STAFF DOOR SYSTEMS ONLINE.",
			"MAINTENANCE SYNC AVAILABLE.",
		],
		"secret_lines": [
			"HIDDEN CACHE FOUND.",
			"A shelf of spare fuses, labeled in careful handwriting.",
			"\"Spares for the night shift. Take what you need. - 04\"",
			"The whole storage bay lights up at once.",
		],
		"secret_flag": "ssr_secret_cache_found",
		"moving_hazard_color": Color(0.36, 0.9, 1.0, 1.0),
		"moving_hazards": [
			{"area": "entry", "axis": "h", "line": 12, "from": 2, "to": 9, "interval": 0.55, "marker": "ZAP"},
			{"area": "crawl", "axis": "h", "line": 12, "from": 4, "to": 6, "interval": 0.5, "marker": "ZAP"},
			{"area": "relay", "axis": "h", "line": 12, "from": 1, "to": 4, "interval": 0.45, "marker": "ZAP"},
			{"area": "storage", "axis": "h", "line": 12, "from": 11, "to": 17, "interval": 0.42, "marker": "ZAP"},
			{"area": "breaker", "axis": "h", "line": 12, "from": 6, "to": 12, "interval": 0.34, "marker": "ZAP"},
		],
		"start_area": "entry",
		"areas": [
			{
				"id": "entry",
				"name": "Service Entry",
				"layout": [
					"###################",
					"#P...#.....C#....2#",
					"#.##.#.###.#.##.#.#",
					"#..#.#.#...#..#.#.#",
					"##.#.#.#.#####.#..#",
					"#..#...#.C..#..##.#",
					"#.####.####.#.##..#",
					"#.#..C.#..#.#..#.##",
					"#.#.####.##.##.#..#",
					"#.#.#..H.#...#.##.#",
					"#.#.#.##.#.#.#..#.#",
					"#1..#....#.#.##.#.#",
					"#.........#....C..#",
					"###################",
				],
			},
			{
				"id": "crawl",
				"name": "Fuse Crawl",
				"layout": [
					"###################",
					"#1.....#..C#.....3#",
					"#.###.##.#.#.###.##",
					"#...#.#..#.#...#..#",
					"###.#.#.##.###.##.#",
					"#...#.#.#....#..#.#",
					"#.###.#.#.##.##.#.#",
					"#.#...#.#..#.#..#.#",
					"#.#.###.##.#.#.##.#",
					"#.#..C#..#.#.#.#..#",
					"#.##.#.#.#.#.#.#.##",
					"#..#.#.#...#...#..#",
					"#C.#...#.H.#...#..#",
					"###################",
				],
			},
			{
				"id": "relay",
				"name": "Relay Spine",
				"layout": [
					"###################",
					"#2....#...C#.....5#",
					"#.###.#.##.#.###.##",
					"#.#...#.#..#...#..#",
					"#.#.###.#.####.##.#",
					"#.#.#...#....#..#.#",
					"#.#.#.#####.###.#.#",
					"#...#.....#.#...#.#",
					"##.#####.##.#.###.#",
					"#..#...C.#..#.#..4#",
					"#.##.###.#.##.#.###",
					"#3...#...#.#..#...#",
					"#....#.H.#.#.....C#",
					"###################",
				],
			},
			{
				"id": "storage",
				"name": "Parts Storage",
				"layout": [
					"###################",
					"#4...#......#....S#",
					"#.##.#.####.#.#####",
					"#..#.#.#..#.#....##",
					"##.#.#.#.##.####.##",
					"#..#...#.#....#..##",
					"#.#####.#.###.#.###",
					"#.#...C.#...#.#...#",
					"#.#.#####.#.#.###.#",
					"#.#.#...#.#.#...#.#",
					"#.#.#.#.#.#.###.#.#",
					"#...#.#...#...#.C.#",
					"#.C.#.#..H#.......#",
					"###################",
				],
			},
			{
				"id": "breaker",
				"name": "Breaker Room",
				"layout": [
					"###################",
					"#5......#.....C...#",
					"#.#####.#.#######.#",
					"#.#...#.#.#.....#.#",
					"#.#.#.#.#.#.###.#.#",
					"#...#...#.#.#.#.#.#",
					"#.#######.#.#.#.#.#",
					"#.#.....C.#.#.#.#.#",
					"#.#.#######.#.#.#.#",
					"#.#.#..C....#...#.#",
					"#.#.#.#########.#.#",
					"#.#.#.....H..#..#.#",
					"#...#........#.E..#",
					"###################",
				],
			},
		],
		"area_links": [
			{"from_area": "entry", "marker": "1", "label": "DUCT", "target_area": "crawl", "target_spawn": Vector2i(1, 1)},
			{"from_area": "crawl", "marker": "1", "label": "ENT", "target_area": "entry", "target_spawn": Vector2i(1, 11)},
			{"from_area": "entry", "marker": "2", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(1, 1)},
			{"from_area": "relay", "marker": "2", "label": "ENT", "target_area": "entry", "target_spawn": Vector2i(16, 1)},
			{"from_area": "crawl", "marker": "3", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(1, 11)},
			{"from_area": "relay", "marker": "3", "label": "DUCT", "target_area": "crawl", "target_spawn": Vector2i(16, 1)},
			{"from_area": "relay", "marker": "4", "label": "STOR", "target_area": "storage", "target_spawn": Vector2i(1, 1)},
			{"from_area": "storage", "marker": "4", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(16, 9)},
			{"from_area": "relay", "marker": "5", "label": "BRK", "target_area": "breaker", "target_spawn": Vector2i(1, 1)},
			{"from_area": "breaker", "marker": "5", "label": "RLY", "target_area": "relay", "target_spawn": Vector2i(16, 1)},
		],
	}

func _on_area_entered(area_id: String) -> void:
	if area_id == "breaker" and not blackout_done and not completed:
		blackout_done = true
		trigger_blackout("EVERY LIGHT GOES OUT AT ONCE.\n\nThe hum sharpens:\n\"I buried it dark\nfor a reason.\"\n\nThe static is faster now.\nReach the main breaker.", 0.62)

func _on_stage_reset() -> void:
	blackout_done = false

func _on_stage_completed() -> void:
	GameState.complete_static_service_run()

func _on_return_pressed() -> void:
	GameState.set_pending_spawn_id("Spawn_FromMaintenanceSync")
	SceneChanger.go_to_maintenance_hall()
