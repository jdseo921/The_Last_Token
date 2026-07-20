class_name MinigameUILayoutGuard
extends Node

## Runtime safety net for minigame text. It preserves authored rectangles, then
## shrinks text only when copy changes would otherwise overflow those rectangles.

const MINIGAME_UI := preload("res://scripts/ui/MinigameUI.gd")
const EXCLUDED_BRANCHES := {
	"PauseMenu": true,
	"QuestNotice": true,
	"SettingsMenu": true,
	"DialogueBox": true,
	"ChoiceBox": true,
	"TileGrid": true,
	"ScrollingViewport": true,
}

var _signatures: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Run after ordinary gameplay scripts so a text change is fitted before the
	# same frame is drawn. Signature caching keeps unchanged frames inexpensive.
	process_priority = 1000
	call_deferred("refresh_now")


func _process(_delta: float) -> void:
	refresh_now()


func refresh_now() -> void:
	var host := get_parent()
	if host == null:
		return
	var seen: Dictionary = {}
	_scan_branch(host, seen)
	for instance_id in _signatures.keys():
		if not seen.has(instance_id):
			_signatures.erase(instance_id)


func _scan_branch(node: Node, seen: Dictionary) -> void:
	if node != get_parent() and _branch_is_excluded(node):
		return
	if node is Label:
		_refresh_label(node as Label, seen)
	elif node is Button:
		_refresh_button(node as Button, seen)
	for child in node.get_children():
		_scan_branch(child, seen)


func _refresh_label(label: Label, seen: Dictionary) -> void:
	if bool(label.get_meta(MINIGAME_UI.META_IGNORE, false)):
		return
	var key := label.get_instance_id()
	seen[key] = true
	var signature := "%s|%.1f|%.1f|%s" % [label.text, label.size.x, label.size.y, label.visible]
	if _signatures.get(key, "") == signature:
		return
	_signatures[key] = signature
	MINIGAME_UI.adopt_label(label)


func _refresh_button(button: Button, seen: Dictionary) -> void:
	if bool(button.get_meta(MINIGAME_UI.META_IGNORE, false)):
		return
	var key := button.get_instance_id()
	seen[key] = true
	var signature := "%s|%.1f|%.1f|%s" % [button.text, button.size.x, button.size.y, button.visible]
	if _signatures.get(key, "") == signature:
		return
	_signatures[key] = signature
	if not bool(button.get_meta(MINIGAME_UI.META_MANAGED, false)):
		MINIGAME_UI.configure_button(button)
	else:
		MINIGAME_UI.fit_button(button)


func _branch_is_excluded(node: Node) -> bool:
	if node is Node2D:
		return true
	if EXCLUDED_BRANCHES.has(str(node.name)):
		return true
	return bool(node.get_meta(MINIGAME_UI.META_IGNORE, false))
