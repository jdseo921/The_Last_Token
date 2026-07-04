extends CanvasLayer

signal dialogue_finished

const ADVANCE_COOLDOWN_MSEC := 180
const LETTERS_PER_SECOND := 42.0
const WORDS_PER_SECOND := 7.0
const ANTAGONIST_LETTERS_PER_SECOND := 22.0
const TEXT_LEFT_WITHOUT_PORTRAIT := 16.0
const TEXT_LEFT_WITH_PORTRAIT := 120.0
const PORTRAIT_REGISTRY := preload("res://scripts/DialoguePortraitRegistry.gd")
const ANTAGONIST_SPEAKERS := ["???", "\"Player\""]
const MACHINE_SPEAKERS := [
	"Cabinet 07",
	"Staff Door",
	"Vendo",
	"Mr. Byte",
	"Broken Cabinet",
	"Truth Filter",
	"Terminal",
	"Memory Terminal",
]

@onready var panel: Panel = $Panel
@onready var portrait_texture_rect: TextureRect = $Panel/Portrait
@onready var speaker_name_label: Label = $Panel/SpeakerName
@onready var dialogue_text_label: Label = $Panel/DialogueText
@onready var continue_prompt_label: Label = $Panel/ContinuePrompt

var dialogue_lines: Array = []
var current_index := 0
var active := false
var last_advance_msec := 0
var current_reveal_mode := "instant"
var current_full_text := ""
var current_words: Array[String] = []
var reveal_progress := 0.0
var line_complete := true
var current_line_is_antagonist := false
var current_antagonist_effect := "normal"
var antagonist_elapsed := 0.0
var speaker_home_position := Vector2.ZERO
var dialogue_text_home_position := Vector2.ZERO
var continue_prompt_home_position := Vector2.ZERO

func _ready() -> void:
	visible = false
	continue_prompt_label.text = "PRESS E / SPACE"
	speaker_home_position = speaker_name_label.position
	dialogue_text_home_position = dialogue_text_label.position
	continue_prompt_home_position = continue_prompt_label.position
	_apply_settings()
	var settings := get_node_or_null("/root/GameSettings")
	if settings and settings.has_signal("settings_changed"):
		settings.settings_changed.connect(_apply_settings)

func _process(delta: float) -> void:
	if active and current_line_is_antagonist:
		_animate_antagonist_text(delta)
	if not active or line_complete:
		return
	if current_reveal_mode == "letters":
		reveal_progress += LETTERS_PER_SECOND * _get_text_speed() * delta
		var visible_count := mini(int(reveal_progress), current_full_text.length())
		dialogue_text_label.visible_characters = visible_count
		line_complete = visible_count >= current_full_text.length()
		return
	if current_reveal_mode == "antagonist":
		reveal_progress += ANTAGONIST_LETTERS_PER_SECOND * _get_text_speed() * delta
		var visible_count := mini(int(reveal_progress), current_full_text.length())
		dialogue_text_label.visible_characters = visible_count
		line_complete = visible_count >= current_full_text.length()
		return
	if current_reveal_mode == "words":
		reveal_progress += WORDS_PER_SECOND * _get_text_speed() * delta
		var visible_words := mini(int(reveal_progress), current_words.size())
		dialogue_text_label.text = _join_visible_words(visible_words)
		line_complete = visible_words >= current_words.size()

func start_dialogue(lines: Array) -> void:
	dialogue_lines = lines
	current_index = 0
	active = not dialogue_lines.is_empty()
	visible = active
	last_advance_msec = Time.get_ticks_msec()
	_refresh_line()

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("interact"):
		if event is InputEventKey and event.echo:
			get_viewport().set_input_as_handled()
			return
		var now := Time.get_ticks_msec()
		if now - last_advance_msec < ADVANCE_COOLDOWN_MSEC:
			get_viewport().set_input_as_handled()
			return
		last_advance_msec = now
		get_viewport().set_input_as_handled()
		if not line_complete:
			_complete_current_line()
			return
		_accept_current_line()

func _accept_current_line() -> void:
	_play_audio("play_dialogue_advance")
	current_index += 1
	if current_index >= dialogue_lines.size():
		active = false
		visible = false
		dialogue_finished.emit()
		return
	_refresh_line()

func _refresh_line() -> void:
	if not active or current_index >= dialogue_lines.size():
		speaker_name_label.text = ""
		dialogue_text_label.text = ""
		_show_portrait("")
		return
	var line: Dictionary = dialogue_lines[current_index]
	var speaker := str(line.get("speaker", ""))
	var text := str(line.get("text", ""))
	speaker_name_label.text = speaker
	current_line_is_antagonist = _is_antagonist_speaker(speaker)
	current_antagonist_effect = str(line.get("effect", "normal"))
	antagonist_elapsed = 0.0
	_show_portrait(_get_portrait_path(line, speaker))
	_apply_portrait_veil()
	_reset_line_visuals()
	current_reveal_mode = "antagonist" if current_line_is_antagonist else _get_reveal_mode(speaker)
	if current_reveal_mode == "words":
		current_full_text = text.to_upper()
	else:
		current_full_text = text
	reveal_progress = 0.0
	line_complete = current_reveal_mode == "instant" or current_full_text.is_empty()
	dialogue_text_label.visible_characters = -1
	if current_reveal_mode == "instant":
		dialogue_text_label.text = current_full_text
		return
	if current_reveal_mode == "antagonist":
		current_words.clear()
		dialogue_text_label.text = current_full_text
		dialogue_text_label.visible_characters = 0
		return
	if current_reveal_mode == "words":
		current_words = _split_words(current_full_text)
		dialogue_text_label.text = ""
		return
	current_words.clear()
	dialogue_text_label.text = current_full_text
	dialogue_text_label.visible_characters = 0

func _complete_current_line() -> void:
	if current_reveal_mode == "words":
		dialogue_text_label.text = current_full_text
	elif current_reveal_mode == "antagonist":
		dialogue_text_label.text = current_full_text
		dialogue_text_label.visible_characters = -1
	else:
		dialogue_text_label.text = current_full_text
		dialogue_text_label.visible_characters = -1
	line_complete = true

func _apply_portrait_veil() -> void:
	# The antagonist's portrait darkens to near-black early and clears as the
	# story approaches the reveal.
	if not portrait_texture_rect.visible:
		return
	if current_line_is_antagonist and not _should_show_revealed_player_portrait():
		var game_state := get_node_or_null("/root/GameState")
		var k := 0.0
		if game_state != null and game_state.has_method("get_conscience_reveal_factor"):
			k = float(game_state.call("get_conscience_reveal_factor"))
		portrait_texture_rect.modulate = Color(k, k, k, 1.0)
	else:
		portrait_texture_rect.modulate = Color.WHITE

func _show_portrait(path: String) -> void:
	portrait_texture_rect.visible = false
	portrait_texture_rect.texture = null
	_set_text_left(TEXT_LEFT_WITHOUT_PORTRAIT)
	if path.is_empty():
		return
	if not ResourceLoader.exists(path):
		return
	var resource := load(path)
	if resource is Texture2D:
		portrait_texture_rect.texture = resource
		portrait_texture_rect.visible = true
		_set_text_left(TEXT_LEFT_WITH_PORTRAIT)

func _get_portrait_path(line: Dictionary, speaker: String) -> String:
	if line.has("portrait"):
		return str(line.get("portrait", ""))
	return PORTRAIT_REGISTRY.get_default_portrait_path(speaker, _should_show_revealed_player_portrait())

func _should_show_revealed_player_portrait() -> bool:
	var game_state := get_node_or_null("/root/GameState")
	if game_state == null:
		return false
	return bool(game_state.get("twist_reveal_seen")) or bool(game_state.get("conscience_final_room_seen")) or bool(game_state.get("post_reveal_roam_unlocked"))

func _set_text_left(left: float) -> void:
	speaker_name_label.offset_left = left
	dialogue_text_label.offset_left = left
	speaker_home_position = speaker_name_label.position
	dialogue_text_home_position = dialogue_text_label.position

func _get_reveal_mode(speaker: String) -> String:
	if speaker == "Player":
		return "instant"
	if speaker in MACHINE_SPEAKERS:
		return "words"
	return "letters"

func _is_antagonist_speaker(speaker: String) -> bool:
	return speaker in ANTAGONIST_SPEAKERS

func _reset_line_visuals() -> void:
	speaker_name_label.position = speaker_home_position
	dialogue_text_label.position = dialogue_text_home_position
	continue_prompt_label.position = continue_prompt_home_position
	speaker_name_label.modulate = Color.WHITE
	dialogue_text_label.modulate = Color.WHITE
	continue_prompt_label.modulate = Color(0.82, 0.92, 0.96, 1.0)

func _animate_antagonist_text(delta: float) -> void:
	antagonist_elapsed += delta
	var twitch_step := int(antagonist_elapsed * 22.0)
	var should_twitch := twitch_step % 9 == 0
	var direction := -1.0 if twitch_step % 2 == 0 else 1.0
	var effect_scale := 2.0 if current_antagonist_effect == "shake" else 1.0
	var offset_x := direction * effect_scale if should_twitch else 0.0
	dialogue_text_label.position = dialogue_text_home_position + Vector2(offset_x, 0.0)
	speaker_name_label.position = speaker_home_position + Vector2(-offset_x, 0.0)
	var pulse := (sin(antagonist_elapsed * 9.0) + 1.0) * 0.5
	var hot_frame := int(antagonist_elapsed * 13.0) % 11 == 0
	if hot_frame:
		dialogue_text_label.modulate = Color(1.0, 0.78, 1.0, 1.0)
		speaker_name_label.modulate = Color(1.0, 0.62, 0.92, 1.0)
		return
	dialogue_text_label.modulate = Color(0.82 + pulse * 0.16, 0.94 + pulse * 0.06, 1.0, 1.0)
	speaker_name_label.modulate = Color(0.9 + pulse * 0.1, 0.82 + pulse * 0.16, 1.0, 1.0)

func _split_words(text: String) -> Array[String]:
	var words: Array[String] = []
	for word in text.split(" ", false):
		words.append(word)
	return words

func _join_visible_words(visible_words: int) -> String:
	var visible_text := ""
	for index in range(visible_words):
		if index > 0:
			visible_text += " "
		visible_text += current_words[index]
	return visible_text

func _play_audio(method_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(method_name):
		audio_manager.call(method_name)

func _apply_settings() -> void:
	var settings := get_node_or_null("/root/GameSettings")
	if settings == null:
		panel.self_modulate.a = 0.92
		return
	panel.self_modulate.a = float(settings.get("dialogue_opacity"))

func _get_text_speed() -> float:
	var settings := get_node_or_null("/root/GameSettings")
	if settings == null:
		return 1.0
	return maxf(float(settings.get("text_speed")), 0.5)
