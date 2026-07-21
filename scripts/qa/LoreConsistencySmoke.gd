extends SceneTree

const DIALOGUE_POOL := preload("res://scripts/DialoguePool.gd")
const CONSCIENCE_DIRECTOR_PATH := "res://scripts/ConscienceEncounterDirector.gd"
const STAFF_ROOM_PATH := "res://scripts/StaffRoom.gd"

const DIALOGUE_FILES := [
	"res://data/dialogue/cabinet_07.json",
	"res://data/dialogue/gus.json",
	"res://data/dialogue/mira.json",
	"res://data/dialogue/mr_byte.json",
	"res://data/dialogue/night_ledger.json",
	"res://data/dialogue/pip.json",
	"res://data/dialogue/roxy.json",
	"res://data/dialogue/vendo.json",
]

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node("GameState")
	game_state.call("reset_for_new_game")
	_check_recognition_without_memory()
	_check_reveal_pacing()
	_check_completion_themes()
	_check_post_reveal_identity()
	_check_final_theme_resolution()
	_check_forbidden_copy_language()
	print("LoreConsistencySmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _check_recognition_without_memory() -> void:
	_expect(_contains("mira", "opening_first_meeting", "looking at me like we have never met"), "Mira recognizes the player and notices the missing relationship")
	_expect(_contains("gus", "pre_lost_token_flavor", "Are we not strangers"), "Gus is unsettled that the player treats him as a stranger")
	_expect(_contains("roxy", "first_meeting_locked", "person in half the staff photos"), "Roxy recognizes the player before her quest opens")
	_expect(_contains("pip", "first_meeting", "Do you know me too"), "Pip's recognition confuses the player")
	_expect(_contains("vendo", "early_flavor", "Scanner says returning staff"), "Vendo reports recognition against a first-visit expression")
	_expect(_contains("mr_byte", "pre_truth_filter_locked", "Employee geometry recognized"), "Mr. Byte distinguishes recognition from absent memory")


func _check_reveal_pacing() -> void:
	var mira_return := _lines_text(DIALOGUE_POOL.get_lines("mira", "lost_token_return_anecdote"))
	_expect(not mira_return.contains("bought Pixel Haven") and not mira_return.contains("Staff 04"), "Mira's token return stays personal instead of delivering the whole history")
	_expect(_contains("roxy", "broken_high_score_completion", "kids the same thing after a bad round"), "Roxy carries the player's encouraging-player memory")
	_expect(_contains("gus", "closing_shift_echoes_debrief", "hardest nights"), "Gus carries the player's closing-shift memory after the evidence route")
	var director_script := load(CONSCIENCE_DIRECTOR_PATH) as Script
	_expect(director_script != null, "conscience encounter director loads")
	if director_script == null:
		return
	var director: Node = director_script.new()
	var truth_text := _lines_text(director.call("get_encounter_lines", "after_truth_filter")).to_lower()
	var soda_text := _lines_text(director.call("get_encounter_lines", "after_circuit_soda")).to_lower()
	var final_walk_text := _lines_text(director.call("get_encounter_lines", "after_final_night_walk")).to_lower()
	_expect(not truth_text.contains("two of us") and not truth_text.contains("separation"), "Truth Filter foreshadows incompatible priorities without naming the split")
	_expect(not soda_text.contains("two of us") and soda_text.contains("remembers what the dream cost"), "Circuit Soda keeps the voice protective and ambiguous")
	_expect(final_walk_text.contains("two signals") and final_walk_text.contains("did not appear in one instant"), "Final Night makes the gradual separation explicit at the late reveal")
	director.free()


func _check_completion_themes() -> void:
	_expect(_contains("cabinet_07", "rockbyte_completion", "cabinet knew my timing"), "Rockbyte completion returns recognition without instant understanding")
	_expect(_contains("roxy", "broken_high_score_completion", "returned a clue, not a future"), "Broken Score treats a win as a clue rather than destiny")
	_expect(_contains("mr_byte", "truth_filter_completion_anecdote", "One correct answer cannot settle a life"), "Truth Filter separates a correct answer from a settled life")
	_expect(_contains("vendo", "circuit_soda_completion_anecdote", "fixed a route, not me"), "Circuit Soda repairs a route rather than the person")
	_expect(_contains("pip", "prize_sort_completion", "Neither remembers a whole owner alone"), "Prize Echo Ascent joins wanting, return, and responsibility")
	_expect(_contains("gus", "static_service_run_anecdote", "next step"), "Static Service presents repair as one next step")


func _check_post_reveal_identity() -> void:
	_expect(_contains("pip", "post_reveal", "Same person. Different seams"), "Pip confirms continuity instead of calling the player a copy")
	_expect(_contains("vendo", "post_reveal_witness", "same customer, complete signal"), "Vendo confirms the same person's integrated signal")
	_expect(_contains("mira", "post_reveal_witness", "Not as a file or an echo. As you"), "Mira remembers the living person rather than a reconstructed memory")
	_expect(_contains("mr_byte", "post_reveal_witness", "two survival strategies"), "Mr. Byte records integration instead of one half defeating the other")


func _check_final_theme_resolution() -> void:
	var staff_room_script := load(STAFF_ROOM_PATH) as Script
	_expect(staff_room_script != null, "Staff Room story script loads")
	if staff_room_script == null:
		return
	var staff_room: Node = staff_room_script.new()
	var final_text := _lines_text(staff_room.call("_get_final_self_conflict_lines"))
	_expect(final_text.contains("It was not one loss. It was years of them arriving together."), "final reveal respects accumulated financial and emotional pressure")
	_expect(final_text.contains("You kept the dream of Pixel Haven. I kept the bitter reality behind it."), "final reveal assigns the dream and material burden to the separated perspectives")
	_expect(final_text.contains("No minigame win erases that"), "final reveal rejects game victories as cures for real hardship")
	_expect(final_text.contains("One win cannot carry it forever. One loss cannot define everything that follows."), "final reveal distinguishes life from a binary game result")
	_expect(final_text.contains("A young heart is not ignorance"), "youth motto explicitly rejects denial and arrested growth")
	_expect(final_text.contains("The heart of youth is not gone unless I let it go."), "youth motto is retained in its mature form")
	_expect(final_text.contains("I do not become whole by defeating you."), "ending resolves through integration rather than defeating the burdened half")
	staff_room.free()


func _check_forbidden_copy_language() -> void:
	var forbidden := ["restored memory", "not the original", "stored file", "copy of you", "archived restore profile"]
	var combined := ""
	for path in DIALOGUE_FILES:
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			combined += file.get_as_text().to_lower()
	for phrase in forbidden:
		_expect(not combined.contains(phrase), "dialogue avoids copy/reconstruction phrase: %s" % phrase)


func _contains(character_id: String, set_id: String, needle: String) -> bool:
	return _lines_text(DIALOGUE_POOL.get_lines(character_id, set_id)).contains(needle)


func _lines_text(lines: Array) -> String:
	var pieces: Array[String] = []
	for line_value in lines:
		if line_value is Dictionary:
			pieces.append(str((line_value as Dictionary).get("text", "")))
	return "\n".join(pieces)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
