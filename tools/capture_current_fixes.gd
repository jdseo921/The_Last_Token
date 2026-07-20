extends SceneTree

const TARGETS := [
	["cabinet_logs_fix", "res://scenes/maps/CabinetRow.tscn"],
	["prize_echo_sprite_fix", "res://scenes/minigames/PrizeShelfRun.tscn"],
]
const SETTLE_FRAMES := 50

var target_index := 0
var instance: Node = null
var frame_count := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")


func _process(_delta: float) -> bool:
	if instance == null:
		if target_index >= TARGETS.size():
			print("capture_current_fixes: done")
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
	if frame_count == 2 and str(TARGETS[target_index][0]) == "prize_echo_sprite_fix":
		var explorer := instance.get_node_or_null("AdventureView/WorldViewport/HybridWorld/Explorer") as Node2D
		if explorer != null:
			explorer.position = Vector2(1510, 852)
	if frame_count < SETTLE_FRAMES:
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
	game_state.story_started = true
	if target_name == "cabinet_logs_fix":
		game_state.lost_token_collected = true
		game_state.rockbyte_duel_completed = true
		game_state.lost_token_quest_completed = true
