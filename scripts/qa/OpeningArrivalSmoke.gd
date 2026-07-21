extends SceneTree

const QUEST_NOTICE_PATH := "res://scenes/ui/QuestNotice.tscn"
const ROUTE_CUE_PATH := "res://scripts/RouteCue.gd"
const ARCADE_HUB_SCRIPT_PATH := "res://scripts/ArcadeHub.gd"
const DIALOGUE_POOL_PATH := "res://scripts/DialoguePool.gd"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node("GameState")
	game_state.call("reset_for_new_game")
	var host := Control.new()
	host.name = "OpeningArrivalHost"
	root.add_child(host)
	current_scene = host

	var notice := (load(QUEST_NOTICE_PATH) as PackedScene).instantiate()
	host.add_child(notice)
	await process_frame
	await process_frame
	var objective_hud := host.get_node("ObjectiveHudLayer/ObjectiveHud") as Control
	_expect(not objective_hud.visible, "opening objective stays hidden during the protagonist monologue")

	game_state.call("mark_opening_intro_seen")
	notice.call("refresh_objective_hud", true)
	_expect(objective_hud.visible, "opening objective can be shown immediately at the monologue handoff")
	var notice_title: Label = notice.get("hud_title")
	var notice_action: Label = notice.get("hud_action")
	_expect(notice_title.text == "GET YOUR BEARINGS", "opening HUD names the first quest")
	_expect(notice_action.text.replace("\n", " ") == "Look around. Talk to whoever is still here.", "opening HUD shows the requested local instruction")

	var route_cue: Node = (load(ROUTE_CUE_PATH) as Script).new()
	host.add_child(route_cue)
	route_cue.setup("arcade_hub", Vector2(24, 86), 430.0)
	await process_frame
	route_cue.call("refresh")
	_expect(route_cue.visible, "opening local navigation is visible after the monologue")
	_expect((route_cue.get_node("RouteCueLabel") as Label).text.replace("\n", " ") == "LOCAL: Look around. Talk to whoever is still here.", "route cue uses the opening local instruction")

	var hub: Node = (load(ARCADE_HUB_SCRIPT_PATH) as Script).new()
	var opening_lines: Array = hub.call("_get_opening_intro_lines")
	var opening_text := _flatten_dialogue(opening_lines)
	_expect(opening_text.contains("Curiosity") and opening_text.contains("closed arcade"), "opening establishes a curious walk-in")
	_expect(opening_text.contains("do not recognize"), "opening establishes that the player does not recognize the arcade")
	_expect(not opening_text.contains("familiar") and not opening_text.contains("came back"), "opening does not imply prior knowledge")
	var dialogue_pool := load(DIALOGUE_POOL_PATH) as Script
	var first_meeting := _flatten_dialogue(dialogue_pool.call("get_lines", "mira", "opening_first_meeting"))
	_expect(first_meeting.contains("I do not recognize this place"), "Mira meeting preserves the protagonist's uncertainty")
	_expect(not first_meeting.contains("I know this place"), "Mira meeting no longer contradicts the opening")
	var quest_details := str(game_state.call("get_current_quest_data").get("details", "")).to_lower()
	_expect(not quest_details.contains("owner") and not quest_details.contains("owned"), "opening quest does not reveal ownership")
	hub.free()
	host.queue_free()
	await process_frame
	print("OpeningArrivalSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _flatten_dialogue(lines: Array) -> String:
	var text := ""
	for line_value in lines:
		if line_value is Dictionary:
			text += " " + str((line_value as Dictionary).get("text", ""))
	return text


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		failures += 1
		push_error("FAIL: %s" % label)
