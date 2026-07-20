extends SceneTree

const SCENE_PATH := "res://scenes/minigames/TruthFilter.tscn"
const BACKGROUND_PATH := "res://assets/art/minigames/truth_filter/backgrounds/truth_filter_verdict_chamber.png"
const CABINET_SHEET_PATH := "res://assets/art/minigames/truth_filter/truth_filter_deluxe_cabinet_states.png"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load(SCENE_PATH) as PackedScene
	_expect(packed_scene != null, "Truth Filter scene loads")
	if packed_scene == null:
		quit(1)
		return

	var game := packed_scene.instantiate()
	root.add_child(game)
	await process_frame
	await create_timer(1.0).timeout
	game.set_process(false)

	var constants: Dictionary = game.get_script().get_script_constant_map()
	var rounds: Array = constants.get("ROUND_DATA", [])
	_expect(rounds.size() == 5, "five authored records remain playable")
	_expect(ResourceLoader.exists(BACKGROUND_PATH), "verdict chamber background is registered")
	_expect(ResourceLoader.exists(CABINET_SHEET_PATH), "deluxe cabinet state sheet is registered")

	var sheet := load(CABINET_SHEET_PATH) as Texture2D
	_expect(sheet != null, "cabinet state sheet loads as a texture")
	if sheet != null:
		_expect(sheet.get_width() == 416, "cabinet sheet has four 104-pixel frames")
		_expect(sheet.get_height() == 144, "cabinet frames keep their authored height")

	var lights := game.get_node("RulePanel/RoundLights").get_children()
	_expect(lights.size() == 5, "round progress presents five state lights")
	var source_label := game.get_node("SignalPanel/SignalVBox/MemorySignalLabel") as Label
	var instruction_label := game.get_node("SignalPanel/SignalVBox/SignalIntegrityLabel") as Label
	_expect(source_label.text == "SOURCE: STAFF SHIFT LOG", "source pod keeps one concise centered label")
	_expect(instruction_label.text == "FIND THE LUCID RECORD", "instruction pod keeps one concise centered instruction")
	_expect(is_equal_approx(source_label.position.x + source_label.size.x * 0.5, 98.0), "source text is centered in its pod")
	_expect(is_equal_approx(instruction_label.position.x + instruction_label.size.x * 0.5, 411.0), "instruction text is centered in its pod")
	_expect((game.get_node("TitleLabel") as Label).position.y >= 32.0, "title sits lower in the top display")
	_expect((game.get_node("RulePanel/RoundLights") as HBoxContainer).position.y >= 9.0, "round lights sit below the panel edge")
	_expect((game.get_node("StageArea/CabinetA/NameLabel") as Label).position.y >= 10.0, "witness labels sit below their cabinet edge")
	game.set("current_round", 3)
	game.set("completed", false)
	game.call("_update_round_lights")
	var verified_color: Color = constants.get("ROUND_VERIFIED_COLOR", Color.TRANSPARENT)
	var active_color: Color = constants.get("ROUND_ACTIVE_COLOR", Color.TRANSPARENT)
	var empty_color: Color = constants.get("ROUND_EMPTY_COLOR", Color.TRANSPARENT)
	_expect((lights[0] as ColorRect).color.is_equal_approx(verified_color), "cleared rounds glow verified")
	_expect((lights[3] as ColorRect).color.is_equal_approx(active_color), "current round glows active")
	_expect((lights[4] as ColorRect).color.is_equal_approx(empty_color), "future rounds remain unlit")

	game.set("lie_density", 75.0)
	game.call("_update_density")
	var density_bar := game.get_node("SignalPanel/SignalVBox/DensityBar") as ProgressBar
	_expect(is_equal_approx(density_bar.value, 75.0), "lie-density meter mirrors gameplay pressure")

	game.call("_set_cabinet_art_state", 0, "wrong")
	var cabinet_art := game.get_node("StageArea/CabinetA/CabinetArt") as TextureRect
	var wrong_atlas := cabinet_art.texture as AtlasTexture
	_expect(wrong_atlas != null, "wrong-answer cabinet uses an atlas frame")
	if wrong_atlas != null:
		_expect(is_equal_approx(wrong_atlas.region.position.x, 312.0), "false-record state selects frame four")

	game.call("_complete_puzzle")
	var completion_text := (game.get_node("StatusPanel/StatusLabel") as Label).text
	_expect(completion_text == "SECOND TOKEN RECOVERED. RECORD TRUE; IDENTITY UNSETTLED.", "completion copy is concise and story-current")
	_expect(not completion_text.contains("MEMORY FRAGMENT"), "retired memory-fragment wording stays removed")

	game.queue_free()
	await process_frame
	print("TruthFilterSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
