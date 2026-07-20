extends "res://scripts/minigames/adventure/HybridAdventureStage.gd"

const HYBRID_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")


func _ready() -> void:
	GameState.start_final_night_walk()
	start_hybrid_stage("final_night_walk", get_stage_config())


static func get_stage_config() -> Dictionary:
	return HYBRID_CATALOG.get_profile("final_night_walk")
