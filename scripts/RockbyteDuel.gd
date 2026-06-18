extends Control

@onready var count_label: Label = $Panel/VBox/CountLabel
@onready var turn_label: Label = $Panel/VBox/TurnLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var take_left_button: Button = $Panel/VBox/ButtonsHBox/TakeLeftButton
@onready var take_right_button: Button = $Panel/VBox/ButtonsHBox/TakeRightButton
@onready var take_both_button: Button = $Panel/VBox/ButtonsHBox/TakeBothButton
@onready var exit_button: Button = $Panel/VBox/ExitButton

var left_pile := 5
var right_pile := 5
var duel_finished := false
var last_message := ""
var player_won_last_round := false
var loss_retry_count := 0

func _ready() -> void:
	take_left_button.pressed.connect(_on_take_left_pressed)
	take_right_button.pressed.connect(_on_take_right_pressed)
	take_both_button.pressed.connect(_on_take_both_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	_reset_duel()

func _unhandled_input(event: InputEvent) -> void:
	if duel_finished and event.is_action_pressed("interact"):
		_on_exit_pressed()

func _on_take_left_pressed() -> void:
	_take_player_turn("left")

func _on_take_right_pressed() -> void:
	_take_player_turn("right")

func _on_take_both_pressed() -> void:
	_take_player_turn("both")

func _take_player_turn(choice: String) -> void:
	if duel_finished:
		return
	var player_message := ""
	match choice:
		"left":
			if left_pile <= 0:
				status_label.text = "That pile is empty."
				return
			left_pile -= 1
			player_message = "You took 1 from the left pile."
		"right":
			if right_pile <= 0:
				status_label.text = "That pile is empty."
				return
			right_pile -= 1
			player_message = "You took 1 from the right pile."
		"both":
			if left_pile <= 0 and right_pile <= 0:
				status_label.text = "Both piles are empty."
				return
			if left_pile > 0:
				left_pile -= 1
			if right_pile > 0:
				right_pile -= 1
			player_message = "You took 1 from both piles."
	last_message = player_message
	_refresh_counts()
	status_label.text = player_message
	_set_move_buttons_enabled(false)
	if left_pile == 0 and right_pile == 0:
		_finish_duel(true)
		return
	_cabinet_turn(player_message)

func _cabinet_turn(player_message: String) -> void:
	if duel_finished:
		return
	turn_label.text = "Cabinet turn"
	await get_tree().create_timer(0.35).timeout
	if duel_finished:
		return
	if left_pile == 0 and right_pile == 0:
		_finish_duel(false)
		return
	var winning_move := _get_winning_move()
	if winning_move == "" or randi() % 100 < 35:
		winning_move = _random_valid_move()
	_apply_cabinet_move(winning_move)
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
	turn_label.text = "Game over"
	take_left_button.visible = false
	take_right_button.visible = false
	take_both_button.visible = false
	exit_button.visible = true
	if player_won:
		GameState.rockbyte_duel_completed = true
		GameState.collect_lost_token()
		_play_audio("play_token_get")
		exit_button.text = "Exit"
		status_label.text = "PATTERN BROKEN.\nMEMORY UNLOCKED.\nTWO VERSIONS REMAINED.\nONE WAS SAVED.\nONE WAS LOST.\n\nLost Token recovered.\nReturn it to Mira."
		return
	_play_audio("play_error")
	loss_retry_count += 1
	status_label.text = _get_loss_text()
	exit_button.text = "Retry"

func _on_exit_pressed() -> void:
	if player_won_last_round:
		SceneChanger.go_to_arcade_hub()
		return
	_reset_duel()

func _reset_duel() -> void:
	left_pile = 5
	right_pile = 5
	duel_finished = false
	player_won_last_round = false
	last_message = "Choose one button. Take the final rock to win."
	turn_label.text = "Your turn"
	take_left_button.visible = true
	take_right_button.visible = true
	take_both_button.visible = true
	_set_move_buttons_enabled(true)
	exit_button.visible = false
	exit_button.text = "Exit"
	_refresh_counts()
	status_label.text = last_message

func _refresh_counts() -> void:
	count_label.text = "LEFT PILE: %d        RIGHT PILE: %d" % [left_pile, right_pile]

func _get_loss_text() -> String:
	match loss_retry_count:
		1:
			return "YOU LOST THIS GAME BEFORE.\nMANY TIMES.\nBEGIN AGAIN?"
		2:
			return "Hint: Two piles do not mean two choices.\nSometimes both must change together."
		_:
			return "Cabinet 07: HELP UNLOCKED.\nTry leaving both piles with the same count."

func _set_move_buttons_enabled(enabled: bool) -> void:
	take_left_button.disabled = not enabled
	take_right_button.disabled = not enabled
	take_both_button.disabled = not enabled

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)
