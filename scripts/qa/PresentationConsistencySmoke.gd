
extends SceneTree

const HUB_SCENE := "res://scenes/arcade/ArcadeHub.tscn"
const CABINET_SCENE := "res://scenes/maps/CabinetRow.tscn"
const MAINTENANCE_SCENE := "res://scenes/maps/MaintenanceHall.tscn"
const SNACK_SCENE := "res://scenes/maps/SnackAlcove.tscn"
const STAFF_ROOM_SCENE := "res://scenes/arcade/StaffRoom.tscn"
const BALANCED_TEXT := preload("res://scripts/BalancedText.gd")
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
	var staff_room := (load(STAFF_ROOM_SCENE) as PackedScene).instantiate()
	root.add_child(staff_room)
	await process_frame
	await process_frame
	_expect(staff_room.get("active_dialogue_box") == null and staff_room.get("active_cutscene") == null, "Staff Room waits for terminal interaction instead of auto-starting the reveal")

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

	var furniture_rectangles: Array[Vector4] = staff_room.get_node("FurnitureCollision").get("rectangles")
	_expect(staff_room.get_node_or_null("FurnitureCollision/CollisionBox00/Shape") is CollisionPolygon2D, "Staff Room terminal collision shape is generated at runtime")
	_expect(staff_room.get_node_or_null("FurnitureCollision/CollisionBox01/Shape") is CollisionPolygon2D, "Staff Room archive desk collision shape is generated at runtime")
	_expect(furniture_rectangles.has(Vector4(225, 108, 172, 72)), "Staff Room terminal keeps its former interaction rectangle as solid collision")
	_expect(furniture_rectangles.has(Vector4(98, 199, 56, 100)), "Staff Room archive desk keeps its former interaction rectangle as solid collision")
	_expect((staff_room.get_node("RevealTerminal").get("interact_extents") as Vector2).is_equal_approx(Vector2(206.4, 86.4)), "Staff Room terminal interaction area is twenty percent larger")
	_expect((staff_room.get_node("SecurityTapeDesk").get("interact_extents") as Vector2).is_equal_approx(Vector2(67.2, 120)), "Staff Room archive desk interaction area is twenty percent larger")
	var staff_player := staff_room.get_node("Player") as CharacterBody2D
	staff_player.global_position = Vector2(162, 249)
	await physics_frame
	await physics_frame
	_expect(staff_player.get_node("InteractionArea").get_overlapping_areas().has(staff_room.get_node("SecurityTapeDesk")), "archive desk remains interactable from outside its solid collision")
	staff_player.global_position = Vector2(311, 190)
	await physics_frame
	_expect(staff_player.get_node("InteractionArea").get_overlapping_areas().has(staff_room.get_node("RevealTerminal")), "terminal remains interactable from outside its solid collision")

	var slideshow := (load("res://scenes/cutscenes/SlideshowCutscene.tscn") as PackedScene).instantiate()
	root.add_child(slideshow)
	await process_frame
	var panel_clip := slideshow.get_node("PanelClip") as Control
	_expect(panel_clip.clip_contents, "Memory Echo slideshow clips zoomed pictures to the image frame")
	_expect(slideshow.get_node_or_null("FadeOverlay") is ColorRect, "Memory Echo slideshow has a full-screen crossfade overlay")
	var balanced_caption: String = BALANCED_TEXT.split_balanced("You protected the dream by hiding its cost, until hope and responsibility stopped speaking.")
	var balanced_lines := balanced_caption.split("\n")
	_expect(balanced_lines.size() == 2 and absi(balanced_lines[0].length() - balanced_lines[1].length()) <= 12, "long Memory Echo captions split into balanced horizontal lines")
	slideshow.free()

	var ending_prompt := (load("res://scenes/cutscenes/EndingPrompt.tscn") as PackedScene).instantiate()
	root.add_child(ending_prompt)
	await process_frame
	var ending_panel := ending_prompt.get_node("Panel") as Panel
	var ending_vbox := ending_prompt.get_node("Panel/VBox") as VBoxContainer
	_expect(ending_panel.modulate.a < 1.0, "ending message window begins a long fade-in")
	_expect(ending_panel.size.y - (ending_vbox.position.y + ending_vbox.size.y) >= 40.0, "ending buttons keep a comfortable bottom margin")
	ending_prompt.free()

	var final_lines: Array = staff_room.call("_get_final_self_conflict_lines")
	_expect(str(final_lines[0].get("speaker", "")) == "???", "post-Echo conversation identifies the first voice as ???")
	_expect(str(final_lines[1].get("speaker", "")) == "Player", "post-Echo conversation restores the Player label on the next line")
	var game_state := root.get_node("GameState")
	game_state.set("maintenance_sync_completed", true)
	game_state.set("security_tape_assembly_completed", true)
	game_state.set("twist_reveal_seen", false)
	var staff_route_cue := staff_room.get("route_cue") as Control
	staff_route_cue.set("dismissed", false)
	staff_route_cue.visible = true
	staff_route_cue.get_node("RouteCueLabel").text = "LOCAL: Inspect the restore terminal."
	staff_room.call("_handle_terminal_interaction")
	_expect(bool(staff_route_cue.get("dismissed")) and not staff_route_cue.visible, "restored-tape terminal dialogue expires its navigation immediately")
	var final_dialogue: Node = staff_room.get("active_dialogue_box")
	if final_dialogue != null:
		final_dialogue.call("set_antagonist_ambience_enabled", false)
		final_dialogue.call("start_dialogue", [{"speaker": "???", "text": "Employee 04."}])
		_expect(not bool(final_dialogue.get("antagonist_ambience_enabled")), "final conversation disables antagonist background and music dimming")
		var dim_overlay := final_dialogue.get("dim_overlay") as ColorRect
		_expect(dim_overlay != null and not dim_overlay.visible, "final conversation keeps the Staff Room background visible")

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
	staff_room.free()
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
