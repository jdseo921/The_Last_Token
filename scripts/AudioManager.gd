extends Node

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const AUDIO_EXTENSIONS := [".wav", ".ogg", ".mp3"]
const SFX_NAMES := {
	"ui_confirm": "ui_confirm",
	"ui_cancel": "ui_cancel",
	"interact": "interact",
	"dialogue_advance": "dialogue_advance",
	"token_get": "token_get",
	"glitch": "glitch",
	"save": "save",
	"error": "error",
}

var sfx_players: Array[AudioStreamPlayer] = []
var next_player_index := 0
var ambience_player: AudioStreamPlayer = null
var ambience_stream: AudioStream = null
var ambience_enabled := false

func _ready() -> void:
	for index in range(4):
		var player := AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	ambience_player = AudioStreamPlayer.new()
	add_child(ambience_player)
	ambience_player.finished.connect(_on_ambience_finished)

func play_ui_confirm() -> void:
	_play_sfx("ui_confirm")

func play_ui_cancel() -> void:
	_play_sfx("ui_cancel")

func play_interact() -> void:
	_play_sfx("interact")

func play_dialogue_advance() -> void:
	_play_sfx("dialogue_advance")

func play_token_get() -> void:
	_play_sfx("token_get")

func play_glitch() -> void:
	_play_sfx("glitch")

func play_save() -> void:
	_play_sfx("save")

func play_error() -> void:
	_play_sfx("error")

func play_arcade_ambience() -> void:
	ambience_stream = _load_audio(MUSIC_DIR, "arcade_ambience")
	if ambience_stream == null:
		return
	ambience_enabled = true
	ambience_player.stream = ambience_stream
	ambience_player.play()

func stop_arcade_ambience() -> void:
	ambience_enabled = false
	if ambience_player:
		ambience_player.stop()

func _play_sfx(key: String) -> void:
	if sfx_players.is_empty():
		return
	var base_name := str(SFX_NAMES.get(key, key))
	var stream := _load_audio(SFX_DIR, base_name)
	if stream == null:
		return
	var player := sfx_players[next_player_index]
	next_player_index = (next_player_index + 1) % sfx_players.size()
	player.stop()
	player.stream = stream
	player.play()

func _load_audio(folder_path: String, base_name: String) -> AudioStream:
	for extension in AUDIO_EXTENSIONS:
		var file_path := "%s%s%s" % [folder_path, base_name, extension]
		if ResourceLoader.exists(file_path):
			var stream := load(file_path)
			if stream is AudioStream:
				return stream
	return null

func _on_ambience_finished() -> void:
	if ambience_enabled and ambience_stream:
		ambience_player.play()
