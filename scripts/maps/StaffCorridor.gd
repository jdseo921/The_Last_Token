extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: CanvasLayer = $UILayer/DialogueBox
@onready var prompt_label: Label = $UILayer/InteractionPrompt
@onready var prompt_background: ColorRect = $UILayer/InteractionPromptBackground

var pending_after_dialogue: Callable = Callable()

func _ready() -> void:
	player.interaction_prompt_changed.connect(_on_prompt_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_apply_spawn_position()
	_on_prompt_changed("")

func can_open_pause_menu() -> bool:
	return not _dialogue_is_active()

func _apply_spawn_position() -> void:
	var spawn_id := GameState.consume_pending_spawn_id()
	var marker := get_node_or_null(spawn_id)
	if marker is Marker2D:
		player.global_position = marker.global_position

func _on_prompt_changed(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()
	prompt_background.visible = prompt_label.visible

func start_dialogue(lines: Array, after_dialogue: Callable = Callable()) -> void:
	pending_after_dialogue = after_dialogue
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	dialogue_box.start_dialogue(lines)

func _on_dialogue_finished() -> void:
	if pending_after_dialogue.is_valid():
		pending_after_dialogue.call()
		pending_after_dialogue = Callable()
	if player and player.has_method("set_control_enabled"):
		player.set_control_enabled(true)

func _dialogue_is_active() -> bool:
	if dialogue_box == null:
		return false
	return dialogue_box.get("active") == true

func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"memory_echo":
			_handle_memory_echo()
		"staff_room_door":
			_handle_staff_room_door()
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])

func _handle_memory_echo() -> void:
	if not GameState.maintenance_sync_completed:
		start_dialogue([
			{"speaker": "Memory Echo", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Memory Echo", "text": "MAINTENANCE SYNC REQUIRED."},
		])
		return
	if not GameState.memory_echo_completed:
		GameState.start_memory_echo()
		GameState.set_pending_spawn_id("Spawn_FromMemoryEcho")
		SceneChanger.go_to_memory_echo()
		return
	if not GameState.memory_echo_anecdote_seen:
		GameState.memory_echo_anecdote_seen = true
		start_dialogue([
			{"speaker": "Memory Echo", "text": "Echo stabilized."},
			{"speaker": "Memory Echo", "text": "The arcade stops arguing with itself."},
			{"speaker": "Memory Echo", "text": "That might be worse."},
		])
		return
	start_dialogue([
		{"speaker": "Memory Echo", "text": "Echo stable."},
		{"speaker": "Memory Echo", "text": "Quiet is not always better."},
	])

func _handle_staff_room_door() -> void:
	if not GameState.memory_echo_completed:
		start_dialogue([
			{"speaker": "Staff Room Door", "text": "STAFF ROOM LOCKED."},
			{"speaker": "Staff Room Door", "text": "MEMORY ECHO REQUIRED."},
		])
		return
	if GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK COMPLETE."},
			{"speaker": "Staff Room Door", "text": "RETURN NOT REQUIRED."},
		])
		return
	start_dialogue([
		{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK AVAILABLE."},
		{"speaker": "Staff Room Door", "text": "ENTER STAFF ROOM?"},
	], Callable(SceneChanger, "go_to_staff_room"))
