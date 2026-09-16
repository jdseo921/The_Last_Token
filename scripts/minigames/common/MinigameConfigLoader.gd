# Copyright (c) 2026 jdseo921. All rights reserved.
# This software and associated documentation files are proprietary and confidential.
# Unauthorized copying, modification, or distribution of this file is strictly prohibited.
# Written by jdseo921, jdseo0921@gmail.com

extends RefCounted

static func load_config(path: String) -> Dictionary:
	if path.is_empty():
		return {}
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return {}
	return parsed
