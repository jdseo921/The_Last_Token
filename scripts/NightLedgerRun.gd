# Copyright (c) 2026 jdseo921. All rights reserved.
# This software and associated documentation files are proprietary and confidential.
# Unauthorized copying, modification, or distribution of this file is strictly prohibited.
# Written by jdseo921, jdseo0921@gmail.com

extends "res://scripts/minigames/adventure/HybridAdventureStage.gd"

const HYBRID_CATALOG := preload("res://scripts/minigames/adventure/HybridAdventureCatalog.gd")


func _ready() -> void:
	start_hybrid_stage("night_ledger_run", get_stage_profile())


static func get_stage_config() -> Dictionary:
	return get_stage_profile()


static func get_stage_profile() -> Dictionary:
	return HYBRID_CATALOG.get_profile("night_ledger_run")
