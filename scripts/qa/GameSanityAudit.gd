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
	"res://scenes/maps/PartyRoom.tscn", "res://scenes/maps/Workshop.tscn",
	"res://scenes/maps/MemoryCore.tscn", "res://scenes/maps/Restrooms.tscn",
	"res://scenes/maps/hallways/CabinetHallway.tscn", "res://scenes/maps/hallways/SnackHallway.tscn",
	"res://scenes/maps/hallways/PrizeHallway.tscn", "res://scenes/maps/hallways/MaintenanceHallway.tscn",
	"res://scenes/maps/hallways/BackHallway.tscn", "res://scenes/maps/hallways/CabinetSnackHallway.tscn",
	"res://scenes/maps/hallways/SnackPrizeHallway.tscn", "res://scenes/maps/hallways/MaintenanceStaffHallway.tscn",
]
const MUSIC_CONTEXTS := [
	"title", "arcade_hub", "cabinet_row", "snack_alcove", "prize_corner",
	"maintenance_hall", "staff_corridor", "staff_room", "rockbyte_duel",
	"truth_filter", "circuit_soda", "static_service_run", "maintenance_sync",
	"security_tape_assembly", "final_night_walk", "memory_echo", "ending", "post_reveal",
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
	machine_font = load("res://assets/fonts/VT323-Regular.ttf")
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
	# also audit hardcoded StaffRoom climax lines (the longest required sequence)
	var staff_room_script = load("res://scripts/StaffRoom.gd")
	if staff_room_script != null:
		var sr: Node = staff_room_script.new()
		if sr.has_method("_get_final_self_conflict_lines"):
			for line in sr.call("_get_final_self_conflict_lines"):
				measured += 1
				_measure_line(line, "StaffRoom.gd climax", font)
		sr.free()
	print("  C dialogue overflow: %d lines measured against DialogueBox rect" % measured)

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

func _measure_line(line: Dictionary, source: String, font: Font) -> void:
	if machine_font != null and DIALOGUE_BOX_SCRIPT.MACHINE_SPEAKERS.has(str(line.get("speaker", ""))):
		font = machine_font
	var text := str(line.get("text", ""))
	var width := DIALOGUE_TEXT_WIDTH_PORTRAIT if line.has("portrait") else DIALOGUE_TEXT_WIDTH_PLAIN
	var size := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width, DIALOGUE_FONT_SIZE)
	if size.y > DIALOGUE_TEXT_HEIGHT:
		_fail("dialogue overflow (%s): %.0fpx tall > %.0f: \"%s...\"" % [source, size.y, DIALOGUE_TEXT_HEIGHT, text.substr(0, 48)])

func _check_save_safety() -> void:
	var gs := root.get_node_or_null("GameState")
	var sm := root.get_node_or_null("SaveManager")
	if gs == null or sm == null:
		_fail("save: GameState/SaveManager autoloads missing")
		return
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
	var slot_path := "user://saves/save_slot_%d.json" % TEST_SLOT
	if not FileAccess.file_exists(slot_path):
		# path scheme may differ; find it
		var save_dir := DirAccess.open("user://saves")
		if save_dir != null:
			for f in save_dir.get_files():
				if str(TEST_SLOT) in f:
					slot_path = "user://saves/" + f
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
