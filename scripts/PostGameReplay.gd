extends RefCounted
class_name PostGameReplay
# Post-game replay offers: after a machine's comment dialogue, open a yes/no
# ChoiceBox that relaunches the (already completed) stage. GameState tracks the
# run so the room can auto-play a fresh anecdote when the player returns a winner.

static func open_offer(ui_parent: Node, player: Node, question: String, stage_id: String, launch: Callable) -> void:
	if GameState.ui_notice_blocking or ui_parent == null:
		return
	var choice_box: Node = load("res://scenes/ui/ChoiceBox.tscn").instantiate()
	ui_parent.add_child(choice_box)
	if player and player.has_method("set_control_enabled"):
		player.call_deferred("set_control_enabled", false)
	var close := func(replay: bool) -> void:
		if is_instance_valid(choice_box):
			choice_box.queue_free()
		if replay:
			GameState.begin_postgame_replay(stage_id)
			launch.call()
		elif player != null and is_instance_valid(player) and player.has_method("set_control_enabled"):
			player.set_control_enabled(true)
	if choice_box.has_signal("choice_selected"):
		choice_box.connect("choice_selected", func(index: int) -> void: close.call(index == 0), CONNECT_ONE_SHOT)
	if choice_box.has_signal("choice_cancelled"):
		choice_box.connect("choice_cancelled", func() -> void: close.call(false), CONNECT_ONE_SHOT)
	if choice_box.has_method("open_choice"):
		choice_box.open_choice(question, ["Yes. One more run.", "Not right now."])
