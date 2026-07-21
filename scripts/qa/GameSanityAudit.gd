extends SceneTree
# Content-agnostic sanity audit. Covers, with real engine execution:
#   A. title scene boots and is interactive
#   B. every MapTransition's target scene AND target spawn marker exist (both directions)
#   C. every dialogue line in the game fits the real DialogueBox text rect
#   D. save -> summary -> reload works; corrupted save files fail SAFELY
#   E. every music context resolves to a real, existing stream
# Run: godot --headless --script res://scripts/qa/GameSanityAudit.gd --path <project>

const MAPS := [
	"res://scenes/arcade/ArcadeHub.tscn", "res://scenes/arcade/StaffRoom.tscn",
	"res://scenes/maps/CabinetRow.tscn", "res://scenes/maps/SnackAlcove.tscn",
	"res://scenes/maps/MaintenanceHall.tscn", "res://scenes/maps/StaffCorridor.tscn",
	"res://scenes/maps/PrizeCorner.tscn", "res://scenes/maps/FrontEntrance.tscn",
	"res://scenes/maps/PartyRoom.tscn", "res://scenes/maps/Restrooms.tscn",
	"res://scenes/maps/hallways/CabinetHallway.tscn", "res://scenes/maps/hallways/SnackHallway.tscn",
	"res://scenes/maps/hallways/PrizeHallway.tscn", "res://scenes/maps/hallways/MaintenanceHallway.tscn",
	"res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"res://scenes/maps/hallways/SnackPrizeHallway.tscn", "res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
]
const MUSIC_CONTEXTS := [
	"title", "arcade_hub", "cabinet_row", "snack_alcove", "prize_corner",
	"maintenance_hall", "staff_corridor", "staff_room", "rockbyte_duel",
	"truth_filter", "circuit_soda", "static_service_run", "maintenance_sync",
	"security_tape_assembly", "memory_echo", "ending", "post_reveal",
]
const DIALOGUE_TEXT_WIDTH_PORTRAIT := 454.0
const DIALOGUE_TEXT_WIDTH_PLAIN := 558.0
const DIALOGUE_TEXT_HEIGHT := 84.0
const DIALOGUE_FONT_SIZE := 16
const TEST_SLOT := 3

var fails := 0
var started := false
var measured := 0

func _process(_d: float) -> bool:
	if started:
		return true
	started = true
	print("\n=== GAME SANITY AUDIT ===")
	_check_title()
	_check_transitions()
	_check_dialogue_overflow()
	_check_save_safety()
	_check_music_contexts()
	print("=== SANITY AUDIT: %s ===" % ("PASS" if fails == 0 else "FAIL (%d)" % fails))
	quit(1 if fails > 0 else 0)
	return true

func _check_title() -> void:
	var main_path: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	if not ResourceLoader.exists(main_path):
		_fail("title: main scene missing: " + main_path)
		return
	var inst: Node = (load(main_path) as PackedScene).instantiate()
	root.add_child(inst)
	var buttons: Array = []
	_collect(inst, buttons, func(n): return n is Button and (n as Button).is_visible_in_tree())
	if buttons.size() < 1:
		_fail("title: no interactive buttons found in main scene")
	inst.free()
	print("  A title: main scene loads, %d buttons" % buttons.size())

func _check_transitions() -> void:
	var target_cache := {}
	var checked := 0
	for map_path in MAPS:
		var inst: Node = (load(map_path) as PackedScene).instantiate()
		var transitions: Array = []
		_collect(inst, transitions, func(n): return n is Area2D and n.get("target_scene_path") != null)
		for t in transitions:
			checked += 1
			var target: String = str(t.get("target_scene_path"))
			var spawn_id: String = str(t.get("target_spawn_id"))
			if not ResourceLoader.exists(target):
				_fail("%s: exit '%s' -> missing scene %s" % [map_path.get_file(), t.name, target])
				continue
			if not target_cache.has(target):
				target_cache[target] = (load(target) as PackedScene).instantiate()
			var target_inst: Node = target_cache[target]
			if spawn_id.is_empty():
				spawn_id = "Spawn_Default"
			if target_inst.get_node_or_null(spawn_id) == null and target_inst.get_node_or_null("Spawn_Default") == null:
				_fail("%s: exit '%s' -> %s missing spawn '%s' (and no Spawn_Default fallback)" % [map_path.get_file(), t.name, target.get_file(), spawn_id])
		inst.free()
	for target_inst in target_cache.values():
		target_inst.free()
	print("  B transitions: %d exits checked across %d maps" % [checked, MAPS.size()])

func _check_dialogue_overflow() -> void:
	var font: Font = load("res://assets/fonts/m6x11.ttf")
	machine_font = font
	if font == null:
		font = ThemeDB.fallback_font
	if machine_font == null:
		machine_font = font
	measured = 0
	var dir := DirAccess.open("res://data/dialogue")
	if dir == null:
		_fail("dialogue: cannot open data/dialogue")
		return
	for file_name in dir.get_files():
		if not file_name.ends_with(".json"):
			continue
		var file := FileAccess.open("res://data/dialogue/" + file_name, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if not parsed is Dictionary:
			_fail("dialogue: %s failed to parse" % file_name)
			continue
		_walk_dialogue(parsed, file_name, font)
	# Roughly 40% of the game's dialogue is authored as inline arrays inside the
	# map handlers rather than in the JSON pools. Those lines reach the same box
	# and must be measured too, or the audit only guards part of the script.
	_measure_inline_dialogue("res://scripts", font)
	print("  C dialogue overflow: %d lines measured against DialogueBox rect" % measured)

func _measure_inline_dialogue(root_path: String, font: Font) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full := root_path + "/" + entry
		if dir.current_is_dir():
			if not entry.begins_with(".") and entry != "qa":
				_measure_inline_dialogue(full, font)
		elif entry.ends_with(".gd"):
			var src := FileAccess.get_file_as_string(full)
			for line in _extract_inline_lines(src):
				measured += 1
				_measure_line(line, entry, font)
		entry = dir.get_next()
	dir.list_dir_end()

func _extract_inline_lines(src: String) -> Array:
	# Scans for {"speaker": "...", "text": "..."} literals. Hand-rolled instead
	# of a RegEx because the antagonist speaker is itself a quoted string
	# ("\"Player\"") and escape handling has to be exact.
	var out: Array = []
	var search_from := 0
	while true:
		var head := src.find("\"speaker\"", search_from)
		if head < 0:
			break
		search_from = head + 9
		var speaker_result := _read_quoted_after_colon(src, search_from)
		if speaker_result.is_empty():
			continue
		var text_key: int = src.find("\"text\"", int(speaker_result["end"]))
		if text_key < 0 or text_key - int(speaker_result["end"]) > 8:
			continue
		var text_result := _read_quoted_after_colon(src, text_key + 6)
		if text_result.is_empty():
			continue
		var entry := {"speaker": speaker_result["value"], "text": text_result["value"]}
		var tail_end: int = mini(src.length(), int(text_result["end"]) + 160)
		var tail := src.substr(int(text_result["end"]), tail_end - int(text_result["end"]))
		var brace := tail.find("}")
		if brace >= 0 and tail.substr(0, brace).contains("\"portrait\""):
			entry["portrait"] = true
		out.append(entry)
		search_from = int(text_result["end"])
	return out

func _read_quoted_after_colon(src: String, from_index: int) -> Dictionary:
	var i := from_index
	while i < src.length() and src[i] != "\"":
		var c := src[i]
		if c != ":" and c != " " and c != "\t":
			return {}
		i += 1
	if i >= src.length():
		return {}
	i += 1
	var value := ""
	while i < src.length():
		var c := src[i]
		if c == "\\":
			if i + 1 < src.length():
				var n := src[i + 1]
				value += "\n" if n == "n" else n
				i += 2
				continue
			return {}
		if c == "\"":
			return {"value": value, "end": i + 1}
		value += c
		i += 1
	return {}

func _walk_dialogue(node: Variant, source: String, font: Font) -> void:
	if node is Dictionary:
		if node.has("text") and node.has("speaker"):
			measured += 1
			_measure_line(node, source, font)
			return
		for v in (node as Dictionary).values():
			_walk_dialogue(v, source, font)
	elif node is Array:
		for v in node:
			_walk_dialogue(v, source, font)

var machine_font: Font = null
const DIALOGUE_BOX_SCRIPT := preload("res://scripts/DialogueBox.gd")
const PORTRAIT_REGISTRY := preload("res://scripts/DialoguePortraitRegistry.gd")
const BALANCED_TEXT := preload("res://scripts/BalancedText.gd")

func _measure_line(line: Dictionary, source: String, font: Font) -> void:
	if machine_font != null and DIALOGUE_BOX_SCRIPT.MACHINE_SPEAKERS.has(str(line.get("speaker", ""))):
		font = machine_font
	var text := str(line.get("text", "")).strip_edges()
	# DialogueBox indents the text whenever a portrait resolves, including the
	# default portrait a speaker gets without an explicit "portrait" key, which
	# narrows the label from 558 to 454. Measuring the wide rect for those lines
	# would let a real overflow pass.
	var shows_portrait: bool = line.has("portrait")
	if not shows_portrait:
		var portrait_path: String = PORTRAIT_REGISTRY.get_default_portrait_path(str(line.get("speaker", "")), false)
		shows_portrait = not portrait_path.is_empty() and ResourceLoader.exists(portrait_path)
	var width := DIALOGUE_TEXT_WIDTH_PORTRAIT if shows_portrait else DIALOGUE_TEXT_WIDTH_PLAIN
	var size := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width, DIALOGUE_FONT_SIZE)
	if size.y > DIALOGUE_TEXT_HEIGHT:
		_fail("dialogue overflow (%s): %.0fpx tall > %.0f: \"%s...\"" % [source, size.y, DIALOGUE_TEXT_HEIGHT, text.substr(0, 48)])

func _check_save_safety() -> void:
	var gs := root.get_node_or_null("GameState")
	var sm := root.get_node_or_null("SaveManager")
	if gs == null or sm == null:
		_fail("save: GameState/SaveManager autoloads missing")
		return
	# Keep the destructive corrupted-save check inside the workspace. Normal game
	# sessions leave this override empty and continue to use user://saves.
	sm.set("save_dir_override", "res://tmp/qa_saves")
	sm.call("delete_save", TEST_SLOT)
	gs.call("reset_for_new_game")
	gs.call("start_lost_token_quest")
	gs.set("rockbyte_duel_completed", true)
	gs.call("complete_lost_token_quest")
	var quest_before := str(gs.call("get_current_quest_id"))
	if not bool(sm.call("save_game", TEST_SLOT)):
		_fail("save: save_game(%d) returned false" % TEST_SLOT)
		return
	var summary: Dictionary = sm.call("get_slot_summary", TEST_SLOT)
	if not bool(summary.get("save_exists", false)):
		_fail("save: summary reports no save after saving")
	gs.call("reset_for_new_game")
	var slot_path := str(sm.call("_get_slot_path", TEST_SLOT))
	var file := FileAccess.open(slot_path, FileAccess.READ)
	if file == null:
		_fail("save: cannot locate written save file")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	gs.call("apply_save_data", parsed.get("game_state", parsed) if parsed is Dictionary else {})
	var quest_after := str(gs.call("get_current_quest_id"))
	if quest_after != quest_before:
		_fail("save: roundtrip quest drift '%s' -> '%s'" % [quest_before, quest_after])
	# corrupted save must fail safely (no crash, load returns false)
	var corrupt := FileAccess.open(slot_path, FileAccess.WRITE)
	corrupt.store_string("{{{ this is not json !!!")
	corrupt.close()
	var corrupt_summary: Dictionary = sm.call("get_slot_summary", TEST_SLOT)
	var loaded := bool(sm.call("load_game", TEST_SLOT))
	if loaded:
		_fail("save: corrupted save loaded as valid")
	sm.call("delete_save", TEST_SLOT)
	sm.set("save_dir_override", "")
	gs.call("reset_for_new_game")
	print("  D save: roundtrip ok, corrupted file rejected safely (summary keys: %d)" % corrupt_summary.size())

func _check_music_contexts() -> void:
	var am := root.get_node_or_null("AudioManager")
	if am == null:
		_fail("audio: AudioManager autoload missing")
		return
	var tracks: Dictionary = am.get("MUSIC_TRACKS") if am.get("MUSIC_TRACKS") != null else {}
	var ok := 0
	for context in MUSIC_CONTEXTS:
		var track_id := str(am.call("_get_track_id_for_context", context))
		if track_id.is_empty():
			_fail("audio: context '%s' resolves to no track" % context)
			continue
		if not tracks.has(track_id):
			_fail("audio: context '%s' -> unknown track '%s'" % [context, track_id])
			continue
		# MUSIC_TRACKS maps id -> base file name inside MUSIC_DIR, any known extension
		var base := str(tracks[track_id])
		var music_dir := str(am.get("MUSIC_DIR"))
		var found := false
		for ext in ["mp3", "ogg", "wav"]:
			if ResourceLoader.exists("%s%s.%s" % [music_dir, base, ext]):
				found = true
				break
		if not found:
			_fail("audio: track '%s' has no stream file under %s" % [track_id, music_dir])
			continue
		ok += 1
	print("  E audio: %d/%d music contexts resolve to real streams" % [ok, MUSIC_CONTEXTS.size()])

func _fail(msg: String) -> void:
	print("  FAIL " + msg)
	fails += 1

func _collect(node: Node, out: Array, pred: Callable) -> void:
	for child in node.get_children():
		if pred.call(child):
			out.append(child)
		_collect(child, out, pred)
