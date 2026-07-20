extends SceneTree

const SAVE_SLOT_MENU_PATH := "res://scenes/ui/SaveSlotMenu.tscn"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var menu := (load(SAVE_SLOT_MENU_PATH) as PackedScene).instantiate()
	root.add_child(menu)
	await process_frame

	var occupied := str(menu.call("_format_slot_text", 2, {
		"save_exists": true,
		"story_phase": "Fractured",
		"last_saved_at": "2026-07-19T22:15:30",
		"required_progress_count": 99,
		"optional_games_completed_count": 99,
		"secrets_found_count": 99,
	}))
	var occupied_lines := occupied.split("\n", false)
	_expect(occupied_lines.size() == 3, "occupied slot displays exactly three lines")
	_expect(occupied_lines[0] == "MEMORY SLOT 2", "occupied slot displays its slot number")
	_expect(occupied_lines[1] == "STATUS: Fractured", "occupied slot displays status")
	_expect(occupied_lines[2] == "LAST SAVED: 2026-07-19T22:15:30", "occupied slot displays its save time")
	_expect(not occupied.contains("MAIN:") and not occupied.contains("OPTIONAL:") and not occupied.contains("SECRETS:"), "slot display omits changing quest counters")

	var empty := str(menu.call("_format_slot_text", 1, {"save_exists": false}))
	_expect(empty == "MEMORY SLOT 1\nSTATUS: EMPTY\nLAST SAVED: NEVER", "empty slot uses the same three-field layout")
	var slot_buttons: Array = menu.get("slot_buttons")
	_expect(slot_buttons.size() == 3 and is_equal_approx((slot_buttons[0] as Button).custom_minimum_size.y, 76.0), "compact three-line slots use consistent height")

	menu.queue_free()
	await process_frame
	print("SaveSlotDisplaySmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		failures += 1
		push_error("FAIL: %s" % label)
