extends SceneTree

const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/DialogueBox.tscn")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var audio_manager := root.get_node("AudioManager")
	var game_state := root.get_node("GameState")
	game_state.call("reset_for_new_game")
	audio_manager.call("set_unknown_voice_music_dimmed", false, 0.05)
	var normal_db := float(audio_manager.call("_get_music_volume_db"))
	audio_manager.call("set_unknown_voice_music_dimmed", true, 0.05)
	var dimmed_db := float(audio_manager.call("_get_music_volume_db"))
	_expect(is_equal_approx(dimmed_db, normal_db - 20.0), "unknown voice keeps roughly ten percent of normal music volume")

	var dialogue := DIALOGUE_BOX_SCENE.instantiate()
	root.add_child(dialogue)
	dialogue.call("start_dialogue", [
		{"speaker": "???", "text": "The room goes quiet."},
		{"speaker": "Player", "text": "The music returns."},
	])
	_expect(bool(audio_manager.call("is_unknown_voice_music_dimmed")), "a hidden ??? line dims music")
	dialogue.call("_accept_current_line")
	_expect(not bool(audio_manager.call("is_unknown_voice_music_dimmed")), "leaving a ??? line restores music")
	dialogue.queue_free()
	await process_frame

	game_state.set("conscience_final_room_seen", true)
	var reveal_dialogue := DIALOGUE_BOX_SCENE.instantiate()
	root.add_child(reveal_dialogue)
	reveal_dialogue.call("start_dialogue", [{"speaker": "???", "text": "Identity visible."}])
	_expect(not bool(audio_manager.call("is_unknown_voice_music_dimmed")), "the identity-reveal room is exempt from music dimming")
	reveal_dialogue.queue_free()
	audio_manager.call("set_unknown_voice_music_dimmed", false, 0.05)
	await process_frame

	print("UnknownVoiceMusicDuckSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
