extends Control

const ROUND_END_INPUT_DELAY_MSEC := 250
const ACTIVE_ROCK_COLOR := Color(0.68, 0.72, 0.78, 1)
const EMPTY_ROCK_COLOR := Color(0.13, 0.13, 0.16, 1)
const ACTION_QUEUE_SCRIPT := preload("res://scripts/minigames/common/MinigameActionQueue.gd")
const CONFIG_LOADER := preload("res://scripts/minigames/common/MinigameConfigLoader.gd")
const CONFIG_PATH := "res://data/minigames/rockbyte_duel_config.json"
const ROCK_PILE_PROP_SCENE := preload("res://scenes/minigames/common/RockPileProp.tscn")
const CABINET_TURN_DELAY_SECONDS := 0.23
const HARD_RANDOM_MOVE_CHANCE_PERCENT := 12
const LEEWAY_RANDOM_MOVE_CHANCE_PERCENT := 58
const LEEWAY_LOSS_THRESHOLD := 3
const RESULT_POPUP_HOLD_SECONDS := 2.0

@export var background_texture_path: String = ""
@export var frame_texture_path: String = ""

@onready var background_texture: TextureRect = $BackgroundLayer/BackgroundTexture
@onready var background_placeholder: ColorRect = $BackgroundLayer/BackgroundPlaceholder
@onready var frame_texture: TextureRect = $CabinetFrameLayer/FrameTexture
@onready var frame_placeholder: Panel = $CabinetFrameLayer/FramePlaceholder
@onready var stage: Control = $Stage
@onready var title_label: Label = $TitleLabel
@onready var count_label: Label = $GameArea/CountLabel
@onready var turn_label: Label = $StatusPanel/StatusVBox/TurnLabel
@onready var status_label: Label = $StatusPanel/StatusVBox/StatusLabel
@onready var take_left_button: Button = $ButtonArea/ButtonsHBox/TakeLeftButton
@onready var take_right_button: Button = $ButtonArea/ButtonsHBox/TakeRightButton
@onready var take_both_button: Button = $ButtonArea/ButtonsHBox/TakeBothButton
@onready var exit_button: Button = $ButtonArea/ExitButton
@onready var result_popup: Panel = $ResultPopup
@onready var result_popup_label: Label = $ResultPopup/ResultPopupLabel
@onready var left_rocks: Array[ColorRect] = [
	$GameArea/PilesHBox/LeftPilePanel/LeftRockGrid/Rock1,
	$GameArea/PilesHBox/LeftPilePanel/LeftRockGrid/Rock2,
	$GameArea/PilesHBox/LeftPilePanel/LeftRockGrid/Rock3,
	$GameArea/PilesHBox/LeftPilePanel/LeftRockGrid/Rock4,
	$GameArea/PilesHBox/LeftPilePanel/LeftRockGrid/Rock5,
]
@onready var right_rocks: Array[ColorRect] = [
	$GameArea/PilesHBox/RightPilePanel/RightRockGrid/Rock1,
	$GameArea/PilesHBox/RightPilePanel/RightRockGrid/Rock2,
	$GameArea/PilesHBox/RightPilePanel/RightRockGrid/Rock3,
	$GameArea/PilesHBox/RightPilePanel/RightRockGrid/Rock4,
	$GameArea/PilesHBox/RightPilePanel/RightRockGrid/Rock5,
]

var left_pile := 5
var right_pile := 5
var duel_finished := false
var last_message := ""
var player_won_last_round := false
var loss_retry_count := 0
var round_finished_msec := 0
var action_queue: Node = null
var left_pile_prop: Node = null
var right_pile_prop: Node = null
var visual_sequence_running := false
var minigame_config: Dictionary = {}
var result_popup_tween: Tween = null

func _ready() -> void:
	AudioManager.play_music_for_context("rockbyte_duel")
	minigame_config = CONFIG_LOADER.load_config(CONFIG_PATH)
	_apply_config_text()
	_apply_optional_texture(_get_config_background_path(), background_texture, background_placeholder)
	_apply_optional_texture(frame_texture_path, frame_texture, frame_placeholder)
	_setup_action_queue()
	_setup_staged_visuals()
	take_left_button.pressed.connect(_on_take_left_pressed)
	take_right_button.pressed.connect(_on_take_right_pressed)
	take_both_button.pressed.connect(_on_take_both_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	loss_retry_count = GameState.rockbyte_duel_loss_count
	_reset_duel()

func _unhandled_input(event: InputEvent) -> void:
	if duel_finished and event.is_action_pressed("interact"):
		if event is InputEventKey and event.echo:
			get_viewport().set_input_as_handled()
			return
		if Time.get_ticks_msec() - round_finished_msec < ROUND_END_INPUT_DELAY_MSEC:
			get_viewport().set_input_as_handled()
			return
		get_viewport().set_input_as_handled()
		_on_exit_pressed()

func _on_take_left_pressed() -> void:
	_take_player_turn("left")

func _on_take_right_pressed() -> void:
	_take_player_turn("right")

func _on_take_both_pressed() -> void:
	_take_player_turn("both")

func _take_player_turn(choice: String) -> void:
	if duel_finished or visual_sequence_running:
		return
	var player_message := ""
	var removed_left := 0
	var removed_right := 0
	match choice:
		"left":
			if left_pile <= 0:
				status_label.text = "That pile is empty."
				_play_audio("play_error")
				return
			left_pile -= 1
			removed_left = 1
			player_message = "You took 1 from the left pile."
		"right":
			if right_pile <= 0:
				status_label.text = "That pile is empty."
				_play_audio("play_error")
				return
			right_pile -= 1
			removed_right = 1
			player_message = "You took 1 from the right pile."
		"both":
			if left_pile <= 0 and right_pile <= 0:
				status_label.text = "Both piles are empty."
				_play_audio("play_error")
				return
			if left_pile > 0:
				left_pile -= 1
				removed_left = 1
			if right_pile > 0:
				right_pile -= 1
				removed_right = 1
			player_message = "You took 1 from both piles."
	_play_audio("play_ui_confirm")
	last_message = player_message
	status_label.text = player_message
	_set_move_buttons_enabled(false)
	await _play_player_move_visual(choice, removed_left, removed_right)
	_refresh_counts()
	if left_pile == 0 and right_pile == 0:
		_finish_duel(true)
		return
	await _cabinet_turn(player_message)

func _cabinet_turn(player_message: String) -> void:
	if duel_finished:
		return
	turn_label.text = "Cabinet turn"
	await get_tree().create_timer(CABINET_TURN_DELAY_SECONDS).timeout
	if duel_finished:
		return
	if left_pile == 0 and right_pile == 0:
		_finish_duel(false)
		return
	var cabinet_move := _get_cabinet_move()
	var removed := _get_removed_counts_for_move(cabinet_move)
	_apply_cabinet_move(cabinet_move)
	await _play_cabinet_move_visual(cabinet_move, int(removed.get("left", 0)), int(removed.get("right", 0)))
	_refresh_counts()
	status_label.text = "%s\n%s" % [player_message, last_message]
	if left_pile == 0 and right_pile == 0:
		_finish_duel(false)
		return
	turn_label.text = "Your turn"
	_set_move_buttons_enabled(true)

func _get_winning_move() -> String:
	if left_pile > 0 and right_pile == 0:
		return "left"
	if right_pile > 0 and left_pile == 0:
		return "right"
	if left_pile == 1 and right_pile == 1:
		return "both"
	return ""

func _random_valid_move() -> String:
	var options: Array[String] = []
	if left_pile > 0:
		options.append("left")
	if right_pile > 0:
		options.append("right")
	if left_pile > 0 or right_pile > 0:
		options.append("both")
	return options[randi() % options.size()]

func _get_cabinet_move() -> String:
	var strategic_move := _get_strategic_move()
	var random_chance := HARD_RANDOM_MOVE_CHANCE_PERCENT
	if GameState.rockbyte_duel_loss_count >= LEEWAY_LOSS_THRESHOLD:
		random_chance = LEEWAY_RANDOM_MOVE_CHANCE_PERCENT
	if strategic_move == "" or randi() % 100 < random_chance:
		return _random_valid_move()
	return strategic_move

func _get_strategic_move() -> String:
	var winning_move := _get_winning_move()
	if not winning_move.is_empty():
		return winning_move
	if left_pile > right_pile:
		return "left"
	if right_pile > left_pile:
		return "right"
	if left_pile > 0 and right_pile > 0:
		return "both"
	return _random_valid_move()

func _apply_cabinet_move(choice: String) -> void:
	match choice:
		"left":
			left_pile = maxi(left_pile - 1, 0)
			last_message = "Cabinet took 1 from the left pile."
		"right":
			right_pile = maxi(right_pile - 1, 0)
			last_message = "Cabinet took 1 from the right pile."
		"both":
			if left_pile > 0:
				left_pile -= 1
			if right_pile > 0:
				right_pile -= 1
			last_message = "Cabinet took 1 from both piles."
	status_label.text = last_message

func _finish_duel(player_won: bool) -> void:
	duel_finished = true
	player_won_last_round = player_won
	round_finished_msec = Time.get_ticks_msec()
	turn_label.text = "Game over"
	take_left_button.visible = false
	take_right_button.visible = false
	take_both_button.visible = false
	exit_button.visible = true
	_play_result_visual(player_won)
	if player_won:
		GameState.rockbyte_duel_completed = true
		GameState.collect_lost_token()
		_play_audio("play_token_get")
		exit_button.text = "Return to Arcade"
		status_label.text = "Lost Token recovered.\nReturn to Mira."
		_show_result_popup("TOKEN SIGNAL MATCHED.\nPREVIOUS SESSION FOUND.\nLost Token recovered.")
		exit_button.grab_focus()
		return
	_play_audio("play_error")
	GameState.rockbyte_duel_loss_count += 1
	loss_retry_count = GameState.rockbyte_duel_loss_count
	status_label.text = "Duel lost.\nPress Retry Duel."
	_show_result_popup(_get_loss_text())
	exit_button.text = "Retry Duel"
	exit_button.grab_focus()

func _on_exit_pressed() -> void:
	_play_audio("play_ui_confirm")
	if player_won_last_round:
		SceneChanger.go_to_arcade_hub()
		return
	_reset_duel()

func _reset_duel() -> void:
	visual_sequence_running = false
	left_pile = 5
	right_pile = 5
	duel_finished = false
	player_won_last_round = false
	round_finished_msec = 0
	last_message = "Choose one move each turn. Take the final rock to win."
	_hide_result_popup()
	turn_label.text = "Your turn"
	take_left_button.visible = true
	take_right_button.visible = true
	take_both_button.visible = true
	_set_move_buttons_enabled(true)
	exit_button.visible = false
	exit_button.text = "Exit"
	_setup_staged_visuals()
	_refresh_counts()
	_sync_stage_pile_counts()
	status_label.text = last_message
	take_left_button.grab_focus()

func _refresh_counts() -> void:
	count_label.text = "LEFT PILE: %d        RIGHT PILE: %d" % [left_pile, right_pile]
	_refresh_rock_visuals()

func _refresh_rock_visuals() -> void:
	_set_rock_group_count(left_rocks, left_pile)
	_set_rock_group_count(right_rocks, right_pile)

func _set_rock_group_count(rocks: Array[ColorRect], count: int) -> void:
	for index in range(rocks.size()):
		rocks[index].color = ACTIVE_ROCK_COLOR if index < count else EMPTY_ROCK_COLOR
		rocks[index].modulate.a = 1.0 if index < count else 0.45

func _get_loss_text() -> String:
	match loss_retry_count:
		1:
			return "Cabinet 07 remembers this loss.\nTry again."
		2:
			return "Hint: two piles can change together.\nPress Retry Duel."
		_:
			return "Cabinet 07: pattern aid unlocked.\nTry keeping both piles even."

func _set_move_buttons_enabled(enabled: bool) -> void:
	var can_use_buttons := enabled and not visual_sequence_running
	take_left_button.disabled = not can_use_buttons
	take_right_button.disabled = not can_use_buttons
	take_both_button.disabled = not can_use_buttons

func _setup_action_queue() -> void:
	action_queue = ACTION_QUEUE_SCRIPT.new()
	add_child(action_queue)
	if action_queue.has_method("set_stage"):
		action_queue.call("set_stage", stage)

func _setup_staged_visuals() -> void:
	if stage == null:
		return
	if stage.has_method("clear_stage"):
		stage.call("clear_stage")
	if stage.has_method("setup_stage"):
		stage.call("setup_stage", {
			"background_texture_path": _get_config_background_path(),
			"left_actor_position": Vector2(118, 238),
			"right_actor_position": Vector2(522, 238),
			"center_prop_position": Vector2(320, 228),
		})
	if stage.has_method("add_actor"):
		for participant_data in _get_participant_data():
			stage.call("add_actor", participant_data)
	if stage.has_method("add_prop"):
		left_pile_prop = stage.call("add_prop", ROCK_PILE_PROP_SCENE, {
			"prop_id": "left_pile",
			"pile_id": "left_pile",
			"max_rocks": 5,
			"current_rocks": left_pile,
			"position": Vector2(250, 230),
		}) as Node
		right_pile_prop = stage.call("add_prop", ROCK_PILE_PROP_SCENE, {
			"prop_id": "right_pile",
			"pile_id": "right_pile",
			"max_rocks": 5,
			"current_rocks": right_pile,
			"position": Vector2(390, 230),
		}) as Node
	if action_queue != null and action_queue.has_method("clear"):
		action_queue.call("clear")

func _sync_stage_pile_counts() -> void:
	if left_pile_prop != null and is_instance_valid(left_pile_prop) and left_pile_prop.has_method("set_count"):
		left_pile_prop.call("set_count", left_pile)
	if right_pile_prop != null and is_instance_valid(right_pile_prop) and right_pile_prop.has_method("set_count"):
		right_pile_prop.call("set_count", right_pile)

func _show_result_popup(text: String) -> void:
	if result_popup_tween and result_popup_tween.is_valid():
		result_popup_tween.kill()
	result_popup_label.text = text
	result_popup.visible = true
	result_popup.modulate.a = 0.0
	result_popup_tween = create_tween()
	result_popup_tween.tween_property(result_popup, "modulate:a", 1.0, 0.18)
	result_popup_tween.tween_interval(RESULT_POPUP_HOLD_SECONDS)
	result_popup_tween.tween_property(result_popup, "modulate:a", 0.0, 0.28)
	result_popup_tween.tween_callback(_hide_result_popup.bind(false))

func _hide_result_popup(kill_tween: bool = true) -> void:
	if kill_tween and result_popup_tween and result_popup_tween.is_valid():
		result_popup_tween.kill()
	result_popup_tween = null
	if result_popup != null:
		result_popup.visible = false

func _play_player_move_visual(choice: String, removed_left: int, removed_right: int) -> void:
	var actions: Array[Dictionary] = []
	var target_prop_id := _get_primary_target_prop_id(choice, removed_left, removed_right)
	actions.append({
		"type": "actor_action",
		"actor_id": "player",
		"action": "carry",
		"target_prop_id": target_prop_id,
	})
	_append_rock_removal_actions(actions, removed_left, removed_right, _get_actor_removal_style("player"))
	await _play_visual_sequence(actions)

func _play_cabinet_move_visual(choice: String, removed_left: int, removed_right: int) -> void:
	var actions: Array[Dictionary] = []
	var target_prop_id := _get_primary_target_prop_id(choice, removed_left, removed_right)
	actions.append({
		"type": "actor_action",
		"actor_id": "cabinet07",
		"action": "machine",
		"target_prop_id": target_prop_id,
	})
	_append_rock_removal_actions(actions, removed_left, removed_right, _get_actor_removal_style("cabinet07"))
	await _play_visual_sequence(actions)

func _play_result_visual(player_won: bool) -> void:
	if stage == null or not stage.has_method("play_actor_action"):
		return
	stage.call("play_actor_action", "player", "success" if player_won else "failure", Vector2(320, 230))
	stage.call("play_actor_action", "cabinet07", "machine", Vector2(320, 230))

func _play_visual_sequence(actions: Array[Dictionary]) -> void:
	if actions.is_empty() or action_queue == null:
		return
	if not action_queue.has_method("clear") or not action_queue.has_method("add_action") or not action_queue.has_method("play"):
		return
	visual_sequence_running = true
	_set_move_buttons_enabled(false)
	action_queue.call("clear")
	for action_data in actions:
		action_queue.call("add_action", action_data)
	action_queue.call("play")
	if action_queue.has_method("is_playing") and not bool(action_queue.call("is_playing")):
		visual_sequence_running = false
		return
	if action_queue.has_signal("sequence_finished"):
		var finished_signal: Signal = Signal(action_queue, "sequence_finished")
		await finished_signal
	visual_sequence_running = false

func _append_rock_removal_actions(actions: Array[Dictionary], removed_left: int, removed_right: int, style: String) -> void:
	if removed_left > 0:
		actions.append({
			"type": "prop_action",
			"prop_id": "left_pile",
			"action": "remove_amount",
			"amount": removed_left,
			"style": style,
		})
	if removed_right > 0:
		actions.append({
			"type": "prop_action",
			"prop_id": "right_pile",
			"action": "remove_amount",
			"amount": removed_right,
			"style": style,
		})

func _get_primary_target_prop_id(choice: String, removed_left: int, removed_right: int) -> String:
	match choice:
		"left":
			return "left_pile"
		"right":
			return "right_pile"
		_:
			if removed_left > 0:
				return "left_pile"
			if removed_right > 0:
				return "right_pile"
	return "left_pile"

func _get_removed_counts_for_move(choice: String) -> Dictionary:
	var removed := {
		"left": 0,
		"right": 0,
	}
	match choice:
		"left":
			removed["left"] = 1 if left_pile > 0 else 0
		"right":
			removed["right"] = 1 if right_pile > 0 else 0
		"both":
			removed["left"] = 1 if left_pile > 0 else 0
			removed["right"] = 1 if right_pile > 0 else 0
	return removed

func _get_actor_removal_style(actor_id: String) -> String:
	if stage != null and stage.has_method("get_removal_style_for_actor"):
		return str(stage.call("get_removal_style_for_actor", actor_id))
	return "vanish"

func _apply_config_text() -> void:
	title_label.text = str(minigame_config.get("title", "ROCKBYTE DUEL"))

func _get_config_background_path() -> String:
	return str(minigame_config.get("background", background_texture_path))

func _get_participant_data() -> Array[Dictionary]:
	var fallback_participants: Array[Dictionary] = [
		{
			"actor_id": "player",
			"display_name": "Player",
			"actor_type": "player",
			"side": "left",
		},
		{
			"actor_id": "cabinet07",
			"display_name": "Cabinet 07",
			"actor_type": "machine",
			"side": "right",
			"idle_flicker_enabled": true,
		},
	]
	var participants_value: Variant = minigame_config.get("participants", [])
	if not participants_value is Array:
		return fallback_participants
	var participants_array: Array = participants_value
	if participants_array.is_empty():
		return fallback_participants
	var participants: Array[Dictionary] = []
	for participant_value in participants_array:
		if participant_value is Dictionary:
			participants.append(participant_value)
	if participants.is_empty():
		return fallback_participants
	return participants

func _apply_optional_texture(path: String, texture_rect: TextureRect, placeholder: CanvasItem) -> void:
	texture_rect.visible = false
	texture_rect.texture = null
	placeholder.visible = true
	if path.is_empty():
		return
	if not ResourceLoader.exists(path):
		return
	var resource := load(path)
	if resource is Texture2D:
		texture_rect.texture = resource
		texture_rect.visible = true
		placeholder.visible = false

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
