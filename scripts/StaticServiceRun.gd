extends "res://scripts/minigames/adventure/HybridAdventureStage.gd"

const HYBRID_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")


func _ready() -> void:
	GameState.start_static_service_run()
	start_hybrid_stage("static_service_run", get_stage_config())


static func get_stage_config() -> Dictionary:
	return HYBRID_CATALOG.get_profile("static_service_run")
