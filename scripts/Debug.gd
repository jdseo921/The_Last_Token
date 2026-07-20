class_name GameDebug
extends RefCounted

## Compile-safe bridge to the optional DebugLog autoload. Runtime scripts use
## this helper so isolated `--script` QA runs do not depend on autoload symbols
## being registered as global identifiers during compilation.


static func info(owner: Node, category: String, message: String, data: Dictionary = {}) -> void:
	_call_logger(owner, "info", category, message, data)


static func warning(owner: Node, category: String, message: String, data: Dictionary = {}) -> void:
	_call_logger(owner, "warning", category, message, data)


static func failure(owner: Node, category: String, message: String, data: Dictionary = {}) -> void:
	_call_logger(owner, "failure", category, message, data)


static func _call_logger(owner: Node, method_name: String, category: String, message: String, data: Dictionary) -> void:
	if owner == null or not owner.is_inside_tree():
		return
	var logger := owner.get_node_or_null("/root/DebugLog")
	if logger != null and logger.has_method(method_name):
		logger.call(method_name, category, message, data)
