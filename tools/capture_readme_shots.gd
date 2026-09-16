# Copyright (c) 2026 jdseo921. All rights reserved.
# This software and associated documentation files are proprietary and confidential.
# Unauthorized copying, modification, or distribution of this file is strictly prohibited.
# Written by jdseo921, jdseo0921@gmail.com

extends SceneTree
## Renders the README screenshots from the shipped game.
##
## Run WITH a real renderer (no --headless: the dummy renderer has no
## framebuffer) and at the window size you want the images to be:
##
##   godot --disable-crash-handler --path . --resolution 1280x880 \
##         --script "res://tools/capture_readme_shots.gd"
##
## The project stretches a 640x440 viewport with `canvas_items`, so the root
## texture comes out at the window size and the pixel art scales cleanly at
## integer-ish multiples. Output lands in tmp/captures/, which is gitignored;
## copy the ones you want into docs/media/.

const OUT_DIR := "res://tmp/captures"
const SETTLE_FRAMES := 150

var shots: Array[Dictionary] = [
	{
		"name": "hub",
		"scene": "res://scenes/arcade/ArcadeHub.tscn",
		"story": "mid",
	},
	{
		"name": "cabinet-row",
		"scene": "res://scenes/maps/CabinetRow.tscn",
		"story": "mid",
	},
	{
		"name": "staff-corridor",
		"scene": "res://scenes/maps/StaffCorridor.tscn",
		"story": "late",
	},
	{
		"name": "minigame-truth-filter",
		"scene": "res://scenes/minigames/TruthFilter.tscn",
		"story": "mid",
	},
	{
		"name": "minigame-circuit-soda",
		"scene": "res://scenes/minigames/CircuitSoda.tscn",
		"story": "mid",
	},
]

var index := 0
var frames := 0
var current: Node = null


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	# DisplayOptions applies its own saved window size on startup, which
	# overrides --resolution. Ask it for the largest supported size (1280x880)
	# so the captures are big enough to read at README width.
	var display := root.get_node_or_null("/root/DisplayOptions")
	if display != null and display.has_method("set_window_size_index"):
		var options: Array = display.call("get_window_size_options")
		display.call("set_window_size_index", maxi(options.size() - 1, 0))


func _process(_delta: float) -> bool:
	if index >= shots.size():
		print("capture_readme_shots: done, %d image(s) in %s" % [shots.size(), OUT_DIR])
		quit(0)
		return true

	var shot: Dictionary = shots[index]

	if current == null:
		_apply_story_state(str(shot.get("story", "mid")))
		var packed := load(str(shot["scene"])) as PackedScene
		if packed == null:
			push_error("capture: cannot load " + str(shot["scene"]))
			index += 1
			return false
		current = packed.instantiate()
		root.add_child(current)
		frames = 0
		return false

	frames += 1
	if frames < SETTLE_FRAMES:
		return false

	var texture := root.get_texture()
	if texture == null:
		push_error("capture: no framebuffer - run without --headless")
		quit(1)
		return true

	var path := "%s/%s.png" % [OUT_DIR, str(shot["name"])]
	var image := texture.get_image()
	image.save_png(path)
	print("saved %s  (%dx%d)" % [path, image.get_width(), image.get_height()])

	current.queue_free()
	current = null
	index += 1
	return false


func _apply_story_state(phase: String) -> void:
	# Put the world past the opening so rooms render wired rather than mid-fade,
	# and far enough in that props and route cues reflect real play.
	var state := root.get_node_or_null("/root/GameState")
	if state == null:
		return
	state.call("reset_for_new_game")
	state.set("opening_intro_seen", true)
	state.set("story_started", true)

	if phase == "mid" or phase == "late":
		state.call("start_lost_token_quest")
		state.set("rockbyte_duel_completed", true)
		state.call("collect_lost_token")
		state.call("complete_lost_token_quest")
		state.call("complete_broken_high_score")
		state.call("complete_truth_filter")

	if phase == "late":
		state.call("complete_circuit_soda")
		state.call("complete_pip_secret")
		state.call("complete_closing_shift_echoes")
		state.call("complete_static_service_run")
		state.call("complete_maintenance_sync")
