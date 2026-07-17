extends SceneTree
# Walk the Roxy -> Truth Filter -> Mr. Byte -> Gus stretch and print exactly
# what the UI tells the player at each step (tip + in-room routing bar).

const ROUTE_CUE := preload("res://scripts/RouteCue.gd")

var started := false

func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	var gs := root.get_node("GameState")
	gs.reset_for_new_game()
	gs.start_lost_token_quest()
	gs.rockbyte_duel_completed = true
	gs.collect_lost_token()
	gs.complete_lost_token_quest()
	_show(gs, "token returned to Mira", "arcade_hub")
	gs.roxy_met = true
	_show(gs, "talked to Roxy", "cabinet_row")
	gs.complete_broken_high_score()
	_show(gs, "beat Roxy's cabinet", "cabinet_row")
	gs.increment_npc_dialogue_count("mr_byte_tf_explained")
	_show(gs, "Mr. Byte briefed you", "cabinet_row")
	gs.complete_truth_filter()
	_show(gs, "Truth Filter passed", "cabinet_row")
	gs.mr_byte_truth_filter_debriefed = true
	_show(gs, "Mr. Byte debrief heard", "cabinet_row")
	gs.gus_hub_checkin_truth_filter_done = true
	_show(gs, "Gus check-in heard", "arcade_hub")
	gs.increment_npc_dialogue_count("vendo_circuit_explained")
	_show(gs, "Vendo explained Circuit Soda", "snack_alcove")
	return true

func _show(gs: Node, label: String, room: String) -> void:
	var data: Dictionary = gs.get_current_quest_data()
	var cue: String = ROUTE_CUE.get_current_hint(room)
	print("%s\n   quest : %s\n   tip   : %s | %s\n   in %s : %s" % [
		label,
		gs.get_current_quest_id(),
		str(data.get("title", "")),
		str(data.get("summary", "")),
		room,
		cue,
	])
