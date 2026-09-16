# Copyright (c) 2026 jdseo921. All rights reserved.
# This software and associated documentation files are proprietary and confidential.
# Unauthorized copying, modification, or distribution of this file is strictly prohibited.
# Written by jdseo921, jdseo0921@gmail.com

extends SceneTree

const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")
const EXPECTED_FONT := "res://assets/fonts/m6x11.ttf"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var box := DIALOGUE_BOX_SCENE.instantiate()
	root.add_child(box)
	await process_frame
	var speaker := box.get_node("Panel/SpeakerName") as Label
	var body := box.get_node("Panel/DialogueText") as Label
	_expect(is_equal_approx(speaker.offset_top, 8.0), "speaker names use the shared Y coordinate")
	_expect(is_equal_approx(body.offset_top, 38.0), "dialogue copy starts beneath every speaker name")
	box.call("start_dialogue", [{"speaker": "Gus", "text": "Human font check."}])
	_expect(speaker.get_theme_font("font").resource_path == EXPECTED_FONT, "human speaker name uses the shared font")
	_expect(body.get_theme_font("font").resource_path == EXPECTED_FONT, "human dialogue uses the shared font")
	box.call("start_dialogue", [{"speaker": "Night Ledger", "text": "MACHINE FONT CHECK."}])
	_expect(speaker.get_theme_font("font").resource_path == EXPECTED_FONT, "machine speaker name uses the same shared font")
	_expect(body.get_theme_font("font").resource_path == EXPECTED_FONT, "machine dialogue uses the same shared font")
	_expect(is_equal_approx(speaker.offset_top, 8.0) and is_equal_approx(body.offset_top, 38.0), "speaker switching does not move dialogue geometry")
	box.queue_free()
	await process_frame
	var snack_text := FileAccess.get_file_as_string("res://scripts/maps/SnackAlcove.gd")
	var cabinet_text := FileAccess.get_file_as_string("res://scripts/maps/CabinetRow.gd")
	var vendo_text := FileAccess.get_file_as_string("res://data/dialogue/vendo.json")
	_expect(not snack_text.contains("Vendo loves explaining"), "Circuit Soda no longer assumes the player knows Vendo")
	_expect(not vendo_text.contains("my signal needs a soda"), "Vendo introduction no longer gives the Player an unexplained soda-signal conclusion")
	# These two assertions are a pair, and they guard a property rather than a
	# script: meeting Vendo must leave the Player bewildered and still walking,
	# never handed a conclusion they have not earned. The beat currently doing
	# that job is "(A vending machine missed me. I am filing that under things to
	# panic about later.)" in circuit_soda_intro. Match the deferral, not the
	# whole sentence - pinning the full line is what broke this check when the
	# copy was reworded without the meaning changing.
	_expect(vendo_text.contains("things to panic about later"), "Vendo introduction keeps the Player confused but moving forward")
	_expect(not cabinet_text.contains("Roxy's turf"), "Broken Score no longer assumes the player knows Roxy")
	print("DialogueStyleSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
