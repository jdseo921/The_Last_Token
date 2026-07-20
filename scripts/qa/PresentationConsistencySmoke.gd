
extends SceneTree

const HUB_SCENE := "res://scenes/arcade/ArcadeHub.tscn"
const CABINET_SCENE := "res://scenes/maps/CabinetRow.tscn"
const MAINTENANCE_SCENE := "res://scenes/maps/MaintenanceHall.tscn"
const SNACK_SCENE := "res://scenes/maps/SnackAlcove.tscn"
const CHARACTER_SHEETS := {
	"mira idle": ["res://assets/art/characters/mira/mira_idle_sheet_v2.png", Vector2i(64, 32)],
	"mira facing": ["res://assets/art/characters/mira/mira_turn_diagonal_sheet_v2.png", Vector2i(128, 32)],
	"gus idle": ["res://assets/art/characters/gus/gus_idle_sheet_v2.png", Vector2i(64, 32)],
	"gus facing": ["res://assets/art/characters/gus/gus_turn_diagonal_sheet_v2.png", Vector2i(128, 32)],
	"roxy idle": ["res://assets/art/characters/roxy/roxy_idle_sheet_v2.png", Vector2i(64, 32)],
	"roxy facing": ["res://assets/art/characters/roxy/roxy_turn_diagonal_sheet_v2.png", Vector2i(128, 32)],
}

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var hub := (load(HUB_SCENE) as PackedScene).instantiate()
	var cabinet := (load(CABINET_SCENE) as PackedScene).instantiate()
	var maintenance := (load(MAINTENANCE_SCENE) as PackedScene).instantiate()
	var snack := (load(SNACK_SCENE) as PackedScene).instantiate()

	var vendo := hub.get_node("InteractableLayer/Vendo")
	_expect(str(vendo.get("label_text")) == "SIP-2", "main-hub soda machine is distinctly named SIP-2")
	var renamed_lines: Array = hub.call("_rename_hub_vending_speaker", [{"speaker": "Vendo", "text": "Test."}])
	_expect(not renamed_lines.is_empty() and str(renamed_lines[0].get("speaker", "")) == "SIP-2", "main-hub vending dialogue uses the SIP-2 speaker name")
	_expect(str(snack.get_node("InteractableLayer/Vendo").get("label_text")) == "VENDO", "Snack Alcove machine keeps the Vendo name")
	var audio_manager := root.get_node_or_null("AudioManager")
	_expect(audio_manager != null, "AudioManager autoload is available")
	if audio_manager != null:
		_expect(str(audio_manager.call("_get_track_id_for_context", "snack_alcove")) == "snack_alcove_vendo", "Snack Alcove uses the restored hallway music")
		_expect(str(audio_manager.call("_get_track_id_for_context", "circuit_soda")) == "snack_alcove_vendo", "Circuit Soda shares the restored hallway music")
		_expect(str(audio_manager.call("_get_track_id_for_context", "prize_corner")) == "circuit_soda_game", "Prize Corner uses the Circuit Soda music")

	_expect(cabinet.get_node_or_null("InteractableLayer/CabinetTraceRun") == null, "Cabinet Row no longer exposes Trace Run")
	var mr_byte := cabinet.get_node("InteractableLayer/MrByte") as Node2D
	var logs := cabinet.get_node("InteractableLayer/Logs") as Node2D
	_expect(logs.position.x >= 180.0 and logs.position.x <= 220.0 and logs.position.y < 180.0, "Logs sit in the marked kiosk-side position")
	_expect(not _interaction_rect(logs).intersects(_interaction_rect(mr_byte)), "Logs have their own non-overlapping interaction area")
	_expect((logs.get("interact_extents") as Vector2).length() > 0.0, "Logs expose a usable collision footprint")
	var logs_label_offset: Vector2 = logs.get("label_offset")
	_expect(absf(logs_label_offset.x) < 1.0 and logs_label_offset.y >= 0.0, "Logs label stays centered directly below the stack")
	var broken_score := cabinet.get_node("InteractableLayer/BrokenHighScore")
	_expect((broken_score.get("label_offset") as Vector2).x > 0.0, "Broken Score label is shifted toward its cabinet")

	var npc_nodes: Array[Node] = [
		hub.get_node("InteractableLayer/Mira"),
		hub.get_node("InteractableLayer/Gus"),
		cabinet.get_node("InteractableLayer/MrByte"),
		cabinet.get_node("InteractableLayer/Roxy"),
		maintenance.get_node("InteractableLayer/Gus"),
	]
	for npc in npc_nodes:
		_expect(int(npc.get("label_font_size")) <= 12, "%s nameplate uses the smaller NPC size" % npc.name)
		_expect((npc.get("label_offset") as Vector2).y < 0.0, "%s nameplate is pulled toward the sprite" % npc.name)

	_expect(str(cabinet.get_node("InteractableLayer/Roxy").get("facing_sheet_path")).ends_with("roxy_turn_diagonal_sheet_v2.png"), "Roxy uses the portrait-matched facing sheet")

	for sheet_name in CHARACTER_SHEETS:
		var definition: Array = CHARACTER_SHEETS[sheet_name]
		var path := str(definition[0])
		var expected_size: Vector2i = definition[1]
		_expect(FileAccess.file_exists(path), "%s sheet exists" % sheet_name)
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(path))
		_expect(error == OK, "%s sheet loads" % sheet_name)
		if error != OK:
			continue
		_expect(Vector2i(image.get_width(), image.get_height()) == expected_size, "%s sheet is %s" % [sheet_name, expected_size])
		_expect(image.get_pixel(0, 0).a < 0.01, "%s sheet keeps transparent corners" % sheet_name)
		var opaque_pixels := 0
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				if image.get_pixel(x, y).a > 0.5:
					opaque_pixels += 1
		_expect(opaque_pixels > 30, "%s sheet contains visible character art" % sheet_name)

	hub.free()
	cabinet.free()
	maintenance.free()
	snack.free()
	print("PresentationConsistencySmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)


func _interaction_rect(interactable: Node2D) -> Rect2:
	var extents: Vector2 = interactable.get("interact_extents")
	return Rect2(interactable.position - extents * 0.5, extents)
