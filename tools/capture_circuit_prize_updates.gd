extends SceneTree

const TARGETS := [
	["circuit_soda_raised", "res://scenes/minigames/CircuitSoda.tscn"],
	["prize_corner_restored", "res://scenes/maps/PrizeCorner.tscn"],
]

var target_index := 0
var instance: Node = null
var frame_count := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")


func _process(_delta: float) -> bool:
	if instance == null:
		if target_index >= TARGETS.size():
			print("capture_circuit_prize_updates: done")
			return true
		_prepare_state(str(TARGETS[target_index][0]))
		instance = (load(str(TARGETS[target_index][1])) as PackedScene).instantiate()
		root.add_child(instance)
		var quest_notice := instance.get_node_or_null("QuestNotice")
		if quest_notice != null:
			quest_notice.visible = false
		frame_count = 0
		return false
	frame_count += 1
	if frame_count < 24:
		return false
	var image := root.get_texture().get_image()
	var output_path := "res://tmp/captures/%s.png" % str(TARGETS[target_index][0])
	var error := image.save_png(output_path)
	print("%s: %s" % [output_path, "OK" if error == OK else "ERROR %d" % error])
	instance.free()
	instance = null
	target_index += 1
	return false


func _prepare_state(target_name: String) -> void:
	var game_state := root.get_node_or_null("GameState")
	if game_state == null:
		return
	game_state.reset_for_new_game()
	if target_name == "prize_corner_restored":
		game_state.story_started = true
		game_state.lost_token_quest_started = true
		game_state.rockbyte_duel_completed = true
		game_state.lost_token_quest_completed = true
		game_state.broken_high_score_completed = true
		game_state.lying_cabinets_completed = true
		game_state.circuit_soda_completed = true
		game_state.conscience_encounter_2_seen = true
		game_state.vendo_unknown_clue_seen = true
		game_state.last_announced_quest_id = "prize_sort"
