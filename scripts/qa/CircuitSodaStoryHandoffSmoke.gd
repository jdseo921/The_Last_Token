extends SceneTree

const SNACK_ALCOVE_SCENE_PATH := "res://scenes/maps/SnackAlcove.tscn"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node("GameState")
	game_state.reset_for_new_game()
	game_state.story_started = true
	game_state.lost_token_quest_started = true
	game_state.rockbyte_duel_completed = true
	game_state.lost_token_quest_completed = true
	game_state.broken_high_score_completed = true
	game_state.lying_cabinets_completed = true
	game_state.mr_byte_truth_filter_debriefed = true
	game_state.gus_hub_checkin_truth_filter_done = true
	game_state.complete_circuit_soda()

	var snack_alcove := (load(SNACK_ALCOVE_SCENE_PATH) as PackedScene).instantiate()
	root.add_child(snack_alcove)
	await process_frame
	var dialogue_box := snack_alcove.get_node("UILayer/DialogueBox")
	var conscience_director := root.get_node("ConscienceEncounterDirector")

	snack_alcove.call("_handle_vendo")
	var debrief_lines: Array = dialogue_box.get("dialogue_lines")
	_expect(not debrief_lines.is_empty() and str(debrief_lines[0].get("speaker", "")) == "Vendo", "first post-Circuit interaction starts Vendo's debrief")
	_finish_dialogue(dialogue_box)
	await process_frame
	await process_frame
	_expect(bool(conscience_director.call("is_encounter_active")), "the unknown encounter starts only after Vendo's debrief")

	var encounter: Node = conscience_director.get("active_encounter")
	if encounter != null and is_instance_valid(encounter):
		encounter.call("_finish_encounter")
		await create_timer(0.5).timeout
	_expect(game_state.conscience_encounter_2_seen, "the unknown encounter completes before the clue quest")
	_expect(game_state.get_current_quest_id() == "ask_vendo_about_unknown", "the next quest sends the player back to Vendo")

	snack_alcove.call("_handle_vendo")
	var clue_lines: Array = dialogue_box.get("dialogue_lines")
	_expect(_contains_text(clue_lines, "between Circuit Soda and me"), "Vendo identifies the right-side passage between the machines")
	_finish_dialogue(dialogue_box)
	_expect(game_state.vendo_unknown_clue_seen, "Vendo's clue is recorded after the conversation")
	_expect(game_state.get_current_quest_id() == "prize_sort", "Vendo's clue advances the quest to Prize Service Hall")

	snack_alcove.queue_free()
	await process_frame
	print("CircuitSodaStoryHandoffSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _finish_dialogue(dialogue_box: Node) -> void:
	while bool(dialogue_box.get("active")):
		dialogue_box.call("_accept_current_line")


func _contains_text(lines: Array, needle: String) -> bool:
	for line_value in lines:
		if line_value is Dictionary and needle in str(line_value.get("text", "")):
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
