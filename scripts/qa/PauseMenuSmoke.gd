extends SceneTree

const PAUSE_MENU_PATH := "res://scenes/ui/PauseMenu.tscn"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var pause_menu_scene := load(PAUSE_MENU_PATH) as PackedScene
	_expect(pause_menu_scene != null, "PauseMenu scene loads")
	if pause_menu_scene == null:
		quit(1)
		return
	var room_menu := pause_menu_scene.instantiate()
	root.add_child(room_menu)
	await process_frame
	_expect(room_menu.get_node_or_null("Panel/VBox/StatusLabel") == null, "redundant pause status row is removed")
	_expect(_is_centered(room_menu.get_node("Panel"), 330.0), "room pause panel is compact and vertically centered")
	_expect(is_equal_approx((room_menu.get_node("Panel/VBox") as Control).offset_bottom, 312.0), "room controls keep equal vertical padding")
	room_menu.call("open_menu")
	_expect(paused, "opening the pause menu pauses gameplay")
	room_menu.call("_on_save_slot_menu_closed")
	_expect(room_menu.get_node("Panel").visible, "closing Save/Load returns directly to the pause controls")
	room_menu.call("close_menu")
	_expect(not paused, "closing the pause menu resumes gameplay")
	room_menu.queue_free()
	await process_frame

	var minigame_menu := pause_menu_scene.instantiate()
	minigame_menu.set("is_minigame_context", true)
	root.add_child(minigame_menu)
	await process_frame
	_expect((minigame_menu.get_node("Panel/VBox/ExitMinigameButton") as Button).visible, "minigame pause keeps its exit control")
	_expect(_is_centered(minigame_menu.get_node("Panel"), 368.0), "minigame pause panel is compact and vertically centered")
	_expect(is_equal_approx((minigame_menu.get_node("Panel/VBox") as Control).offset_bottom, 350.0), "minigame controls keep equal vertical padding")
	minigame_menu.queue_free()
	await process_frame

	var audio_manager := root.get_node_or_null("AudioManager")
	_expect(audio_manager != null, "AudioManager autoload is available")
	if audio_manager != null:
		var player_a := audio_manager.get("music_player_a") as AudioStreamPlayer
		var player_b := audio_manager.get("music_player_b") as AudioStreamPlayer
		_expect(player_a != null and player_a.process_mode == Node.PROCESS_MODE_ALWAYS, "primary music player ignores gameplay pause")
		_expect(player_b != null and player_b.process_mode == Node.PROCESS_MODE_ALWAYS, "crossfade music player ignores gameplay pause")

	print("PauseMenuSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(1 if failures > 0 else 0)


func _is_centered(control: Control, expected_height: float) -> bool:
	return (
		is_equal_approx(control.offset_top, -expected_height * 0.5)
		and is_equal_approx(control.offset_bottom, expected_height * 0.5)
	)


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
		return
	failures += 1
	print("FAIL: " + message)
