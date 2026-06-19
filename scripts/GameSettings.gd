extends Node

signal settings_changed

const CONFIG_PATH := "user://settings.cfg"

var master_volume := 1.0
var sfx_volume := 1.0
var music_volume := 0.75
var dialogue_opacity := 0.92
var text_speed := 1.0

func _ready() -> void:
	load_settings()
	_apply_audio_buses()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_audio_buses()
	_save_settings()
	settings_changed.emit()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_audio_buses()
	_save_settings()
	settings_changed.emit()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_audio_buses()
	_save_settings()
	settings_changed.emit()

func set_dialogue_opacity(value: float) -> void:
	dialogue_opacity = clampf(value, 0.45, 1.0)
	_save_settings()
	settings_changed.emit()

func set_text_speed(value: float) -> void:
	text_speed = clampf(value, 0.5, 2.0)
	_save_settings()
	settings_changed.emit()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	master_volume = clampf(float(config.get_value("audio", "master_volume", master_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", sfx_volume)), 0.0, 1.0)
	music_volume = clampf(float(config.get_value("audio", "music_volume", music_volume)), 0.0, 1.0)
	dialogue_opacity = clampf(float(config.get_value("dialogue", "opacity", dialogue_opacity)), 0.45, 1.0)
	text_speed = clampf(float(config.get_value("dialogue", "text_speed", text_speed)), 0.5, 2.0)

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("dialogue", "opacity", dialogue_opacity)
	config.set_value("dialogue", "text_speed", text_speed)
	config.save(CONFIG_PATH)

func _apply_audio_buses() -> void:
	_set_bus_volume("Master", master_volume)

func _set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	if linear_volume <= 0.001:
		AudioServer.set_bus_mute(bus_index, true)
		return
	AudioServer.set_bus_mute(bus_index, false)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))
