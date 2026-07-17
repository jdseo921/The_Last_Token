extends SceneTree
# Verify the Arcade Hub's routing bar guides the player at each early beat.

var frame := 0
var scene: Node = null
var step := 0

const BEATS := [
	{"label": "after token returned (talk to Roxy)", "apply": "token"},
	{"label": "after Roxy met (beat her cabinet)", "apply": "roxy"},
	{"label": "after high score (see Mr. Byte)", "apply": "score"},
]

func _process(_delta: float) -> bool:
	frame += 1
	if frame == 1:
		var gs := root.get_node("GameState")
		gs.reset_for_new_game()
		gs.start_lost_token_quest()
		gs.rockbyte_duel_completed = true
		gs.collect_lost_token()
		gs.complete_lost_token_quest()
		return false
	if frame == 2:
		scene = (load("res://scenes/arcade/ArcadeHub.tscn") as PackedScene).instantiate()
		root.add_child(scene)
		return false
	if frame < 5:
		return false
	var gs := root.get_node("GameState")
	for beat in BEATS:
		match str(beat["apply"]):
			"roxy":
				gs.roxy_met = true
			"score":
				gs.complete_broken_high_score()
		if scene.has_method("_refresh_objective_hint"):
			scene.call("_refresh_objective_hint")
		var cue: Node = scene.get("route_cue")
		var quest: String = gs.get_current_quest_id()
		var tip: String = str(gs.get_current_quest_data().get("summary", ""))
		if cue == null or not is_instance_valid(cue):
			print("FAIL [%s] no route cue in hub" % beat["label"])
			continue
		var label: Node = cue.get("route_label")
		var text: String = str(label.get("text")) if label != null else "<none>"
		var vis: bool = bool(cue.get("visible"))
		print("[%s]\n   quest=%s\n   tip  = %s\n   cue  = %s (visible=%s)" % [beat["label"], quest, tip, text, vis])
	return true
