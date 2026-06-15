extends Control

@onready var count_label: Label = $Panel/VBox/CountLabel
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

func _ready() -> void:
	take_left_button.pressed.connect(_on_take_left_pressed)
	take_right_button.pressed.connect(_on_take_right_pressed)
	take_both_button.pressed.connect(_on_take_both_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	_refresh_ui()

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
	match choice:
		"left":
			if left_pile <= 0:
				status_label.text = "That pile is empty."
				return
			left_pile -= 1
		"right":
			if right_pile <= 0:
				status_label.text = "That pile is empty."
				return
			right_pile -= 1
		"both":
			if left_pile <= 0 and right_pile <= 0:
				status_label.text = "Both piles are empty."
				return
			if left_pile > 0:
				left_pile -= 1
			if right_pile > 0:
				right_pile -= 1
	_refresh_ui()
	if left_pile == 0 and right_pile == 0:
		_finish_duel(true)
		return
	_cabinet_turn()

func _cabinet_turn() -> void:
	if duel_finished:
		return
	if left_pile == 0 and right_pile == 0:
		_finish_duel(false)
		return
	var winning_move := _get_winning_move()
	if winning_move == "":
		winning_move = _random_valid_move()
	_apply_cabinet_move(winning_move)
	_refresh_ui()
	if left_pile == 0 and right_pile == 0:
		_finish_duel(false)

func _get_winning_move() -> String:
	if left_pile > 0 and right_pile == 0:
		return "left"
	if right_pile > 0 and left_pile == 0:
		return "right"
	if left_pile == 1 and right_pile == 1:
		return "both"
	if left_pile == 1 and right_pile > 0:
		return "left"
	if right_pile == 1 and left_pile > 0:
		return "right"
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
	take_left_button.visible = false
	take_right_button.visible = false
	take_both_button.visible = false
	exit_button.visible = true
	if player_won:
		GameState.rockbyte_duel_completed = true
		GameState.collect_lost_token()
		exit_button.text = "Exit"
		status_label.text = "PATTERN BROKEN.\nMEMORY UNLOCKED.\nTWO REMAINED.\nONE WAS SAVED.\nONE WAS LOST."
		return
	status_label.text = "YOU LOST THIS GAME BEFORE.\nMANY TIMES.\nBEGIN AGAIN?"
	exit_button.text = "Retry"

func _on_exit_pressed() -> void:
	if player_won_last_round:
		SceneChanger.change_scene("res://scenes/arcade/ArcadeHub.tscn")
		return
	SceneChanger.change_scene("res://scenes/minigames/RockbyteDuel.tscn")

func _refresh_ui() -> void:
	count_label.text = "Left: %d | Right: %d" % [left_pile, right_pile]
	if not duel_finished:
		status_label.text = "Choose your move."
