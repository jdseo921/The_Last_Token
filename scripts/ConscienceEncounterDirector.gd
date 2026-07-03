extends Node

const CONSCIENCE_ENCOUNTER_SCENE := preload("res://scenes/cutscenes/ConscienceEncounter.tscn")

var active_encounter: Node = null

func is_encounter_active() -> bool:
	return active_encounter != null and is_instance_valid(active_encounter)

func maybe_start_encounter(parent: Node, encounter_id: String, after: Callable = Callable()) -> bool:
	if parent == null or not is_instance_valid(parent):
		return false
	if is_encounter_active():
		return false
	if not _should_trigger(encounter_id):
		return false
	var lines := get_encounter_lines(encounter_id)
	if lines.is_empty():
		return false
	var player := _find_player(parent)
	active_encounter = CONSCIENCE_ENCOUNTER_SCENE.instantiate()
	parent.add_child(active_encounter)
	if active_encounter.has_method("set_controlled_player"):
		active_encounter.call("set_controlled_player", player)
	if active_encounter.has_signal("encounter_finished"):
		active_encounter.connect("encounter_finished", _on_encounter_finished.bind(after, parent), CONNECT_ONE_SHOT)
	if active_encounter.has_method("start_encounter"):
		active_encounter.call("start_encounter", encounter_id, lines)
	return true

func get_encounter_lines(encounter_id: String) -> Array:
	match encounter_id:
		"after_truth_filter":
			return [
				{"speaker": "???", "text": "Truth Filter passed.", "effect": "glitch"},
				{"speaker": "???", "text": "The cabinets are not cheering. They are keeping score."},
				{"speaker": "???", "text": "Do you feel them watching the way you move?"},
				{"speaker": "???", "text": "The woman at the counter felt it first. She feels the distance in you and blames the late hour."},
				{"speaker": "???", "text": "She is closer than she knows.", "effect": "glitch"},
				{"speaker": "???", "text": "There are two of us inside that distance. She will never learn which of us answered her.", "effect": "shake"},
			]
		"after_circuit_soda":
			return [
				{"speaker": "???", "text": "Signal routed.", "effect": "glitch"},
				{"speaker": "???", "text": "Labels help machines behave. They do not decide what is inside the can."},
				{"speaker": "???", "text": "The vending machine caught the flicker in your label and logged it as a fault."},
				{"speaker": "???", "text": "It was not a fault. It was me, reading over your shoulder.", "effect": "glitch"},
				{"speaker": "???", "text": "They keep meeting one of us and answering the other, and never notice the swap."},
				{"speaker": "???", "text": "Telling the two apart was always going to be your job. Only yours.", "effect": "shake"},
			]
		"after_lost_shift_file":
			return [
				{"speaker": "???", "text": "The file found a number.", "effect": "silent", "pause": 0.25},
				{"speaker": "???", "text": "Numbers are useful in arcades. Scores. Tickets. Employee slots."},
				{"speaker": "???", "text": "A name is heavier. A name remembers what it did."},
				{"speaker": "???", "text": "That is why, on the last night, one of us set the name down at the door and did not pick it back up."},
				{"speaker": "???", "text": "You carry the number now. I carry the rest.", "effect": "glitch"},
				{"speaker": "???", "text": "The others feel the weight on you and decide you are only tired."},
				{"speaker": "???", "text": "Let them. It is kinder than the truth, for a little longer.", "effect": "silent", "pause": 0.2},
			]
		"after_final_night_walk":
			return [
				{"speaker": "???", "text": "You walked the route. Counter dark. Cabinet awake. Back hall open."},
				{"speaker": "???", "text": "Two signals in one door. One walked in. One stayed."},
				{"speaker": "???", "text": "You have spent this whole night asking which one you are."},
				{"speaker": "???", "text": "The staff never had to ask. To them you were always just you, only wrong somehow.", "effect": "glitch"},
				{"speaker": "???", "text": "They will keep it that way. Only you get to open the last door and see the rest."},
				{"speaker": "???", "text": "One of us has been taking your turn since the night this place closed."},
				{"speaker": "???", "text": "One more echo, and you will have to look at who.", "effect": "shake"},
				{"speaker": "???", "text": "I am not going to make it easy.", "effect": "silent", "pause": 0.2},
			]
		_:
			return []

func _should_trigger(encounter_id: String) -> bool:
	if GameState.is_conscience_encounter_seen(encounter_id):
		return false
	match encounter_id:
		"after_truth_filter":
			return GameState.lying_cabinets_completed and not GameState.twist_reveal_seen
		"after_circuit_soda":
			return GameState.circuit_soda_completed and not GameState.twist_reveal_seen
		"after_lost_shift_file":
			return GameState.lost_shift_file_completed and not GameState.twist_reveal_seen
		"after_final_night_walk":
			return GameState.final_night_walk_completed and not GameState.twist_reveal_seen
		_:
			return false

func _on_encounter_finished(finished_encounter_id: String, after: Callable, parent: Node) -> void:
	_mark_seen(finished_encounter_id)
	active_encounter = null
	_refresh_player_visual(parent)
	if after.is_valid():
		after.call_deferred()

func _mark_seen(encounter_id: String) -> void:
	GameState.mark_conscience_encounter_seen(encounter_id)

func _find_player(root: Node) -> Node:
	if root == null:
		return null
	if root is CharacterBody2D and root.has_method("set_control_enabled"):
		return root
	for child in root.get_children():
		var player := _find_player(child)
		if player != null:
			return player
	return null

func _refresh_player_visual(parent: Node) -> void:
	var player := _find_player(parent)
	if player != null and player.has_method("refresh_visual_state"):
		player.call("refresh_visual_state")
