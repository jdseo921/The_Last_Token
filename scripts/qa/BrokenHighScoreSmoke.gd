extends SceneTree

const SCENE_PATH := "res://scenes/minigames/BrokenHighScore.tscn"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load(SCENE_PATH) as PackedScene
	_expect(packed_scene != null, "Broken High Score scene loads")
	if packed_scene == null:
		quit(1)
		return
	var game := packed_scene.instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var constants: Dictionary = game.get_script().get_script_constant_map()
	_expect(int(constants.get("TARGET_MATCHES", 0)) == 4, "challenge requires four matches")
	_expect(int(constants.get("DIGIT_COUNT", 0)) == 6, "challenge uses six score digits")
	_expect(is_equal_approx(float(constants.get("MATCH_TIMING_MULTIPLIER", 0.0)), 1.10), "match timing is ten percent more generous")
	_expect(
		is_equal_approx(float(game.get("stable_window")), float(constants.get("STABLE_WINDOW_BASE", 0.0)) * 1.10),
		"opening match window uses the timing increase"
	)
	var instruction_panel := game.get_node("MainPanel/InstructionPanel") as Control
	var instruction_label := game.get_node("MainPanel/InstructionPanel/InstructionLabel") as Control
	var status_panel := game.get_node("MainPanel/StatusPanel") as Control
	var status_label := game.get_node("MainPanel/StatusPanel/StatusLabel") as Control
	var display_panel := game.get_node("MainPanel/DisplayPanel") as Control
	var match_lights := game.get_node("MainPanel/DisplayPanel/MatchLights") as Control
	_expect(_is_contained(instruction_label, instruction_panel), "instructions stay padded inside their box")
	_expect(_is_contained(status_label, status_panel), "status copy stays padded inside its box")
	_expect(
		is_equal_approx(match_lights.position.x + match_lights.size.x * 0.5, display_panel.size.x * 0.5),
		"four match lights are centered as one group"
	)
	_expect(
		instruction_label.get_theme_font("font").resource_path.ends_with("m6x11.ttf"),
		"body copy uses the clearer pixel font"
	)
	var initial_digits: String = game.get_node("MainPanel/DisplayPanel/CorruptedDigitLabel").text
	_expect(initial_digits.split(" ", false).size() == 6, "display presents six digit slots")
	for match_index in 4:
		game.set("stable", true)
		game.call("_on_score_pressed")
		if match_index < 3:
			_expect(not bool(game.get("completed")), "match %d does not finish early" % (match_index + 1))
	_expect(bool(game.get("completed")), "fourth clean match completes the game")
	_expect(int(game.get("matches")) == 4, "all four match lights are earned")
	_expect(
		game.get_node("MainPanel/DisplayPanel/CorruptedDigitLabel").text == "0 0 0 0 9 9",
		"completion restores the six-digit record"
	)
	game.queue_free()
	await process_frame
	print("BrokenHighScoreSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)


func _is_contained(child: Control, parent: Control) -> bool:
	return child.position.x >= 0.0 \
		and child.position.y >= 0.0 \
		and child.position.x + child.size.x <= parent.size.x \
		and child.position.y + child.size.y <= parent.size.y
