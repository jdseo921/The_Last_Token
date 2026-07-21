extends SceneTree

const CABINET_DIALOGUE_PATH := "res://data/dialogue/cabinet_07.json"
const VENDO_DIALOGUE_PATH := "res://data/dialogue/vendo.json"

var failures := 0


func _initialize() -> void:
	var cabinet_sets := _load_sets(CABINET_DIALOGUE_PATH)
	var vendo_sets := _load_sets(VENDO_DIALOGUE_PATH)
	_expect(not cabinet_sets.is_empty(), "Cabinet 07 dialogue data loads")
	_expect(not vendo_sets.is_empty(), "Vendo dialogue data loads")

	_expect(
		_all_sets_use_speaker(cabinet_sets.get("rockbyte_completion", []), "Player"),
		"first Rockbyte completion handoff is voiced by the player"
	)
	_expect(
		not _sets_contain_text(cabinet_sets.get("rockbyte_completion", []), "RETURN TO MIRA"),
		"Cabinet 07 no longer orders the first-play return to Mira"
	)
	_expect(
		_sets_contain_speaker(vendo_sets.get("circuit_soda_completion_anecdote", []), "Vendo")
			and _sets_contain_speaker(vendo_sets.get("circuit_soda_completion_anecdote", []), "Player"),
		"first Circuit Soda debrief is a Vendo and player conversation"
	)
	_expect(
		_sets_contain_text(vendo_sets.get("unknown_voice_clue", []), "PASSAGE IN THE RIGHT WALL"),
		"Vendo gives the exact Prize Service Hall landmark after the unknown voice"
	)

	_expect(
		_all_sets_use_speaker(cabinet_sets.get("post_game_replay_return", []), "Cabinet 07"),
		"post-game Rockbyte replay dialogue remains Cabinet 07's"
	)
	_expect(
		_all_sets_use_speaker(vendo_sets.get("circuit_soda_replay_return", []), "Vendo"),
		"post-game Circuit Soda replay dialogue remains Vendo's"
	)

	print("PostMinigameDialogueSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _load_sets(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	var data := parsed as Dictionary
	var sets: Variant = data.get("sets", {})
	return sets as Dictionary if sets is Dictionary else {}


func _all_sets_use_speaker(dialogue_sets: Array, expected_speaker: String) -> bool:
	if dialogue_sets.is_empty():
		return false
	for dialogue_set in dialogue_sets:
		if not dialogue_set is Array or dialogue_set.is_empty():
			return false
		for line in dialogue_set:
			if not line is Dictionary or str(line.get("speaker", "")) != expected_speaker:
				return false
	return true


func _sets_contain_text(dialogue_sets: Array, needle: String) -> bool:
	for dialogue_set in dialogue_sets:
		if not dialogue_set is Array:
			continue
		for line in dialogue_set:
			if line is Dictionary and needle in str(line.get("text", "")).to_upper():
				return true
	return false


func _sets_contain_speaker(dialogue_sets: Array, expected_speaker: String) -> bool:
	for dialogue_set in dialogue_sets:
		if not dialogue_set is Array:
			continue
		for line in dialogue_set:
			if line is Dictionary and str(line.get("speaker", "")) == expected_speaker:
				return true
	return false


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
