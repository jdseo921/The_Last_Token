extends "res://scripts/minigames/adventure/HybridAdventureStage.gd"

const HYBRID_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")


func _ready() -> void:
	start_hybrid_stage(stage_id, _get_stage_config(stage_id))


static func _get_stage_config(id: String) -> Dictionary:
	return HYBRID_CATALOG.get_profile(id)
