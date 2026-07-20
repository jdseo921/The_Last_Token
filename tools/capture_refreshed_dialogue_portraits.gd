extends SceneTree

var dialogue_box: CanvasLayer = null
var elapsed := 0.0
var stage := 0
var mira_started := false


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://tmp/captures")
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("151025")
	root.add_child(backdrop)
	dialogue_box = load("res://scenes/ui/DialogueBox.tscn").instantiate()
	root.add_child(dialogue_box)


func _process(delta: float) -> bool:
	if not mira_started:
		dialogue_box.call("start_dialogue", [{
			"speaker": "Mira",
			"text": "The room has to remember you before I am allowed to.",
			"portrait": "res://assets/art/portraits/mira/mira_worried.png",
		}])
		dialogue_box.call("_complete_current_line")
		mira_started = true
		elapsed = 0.0
		return false
	elapsed += delta
	if stage == 0 and elapsed >= 0.25:
		if not _save_capture("res://tmp/captures/dialogue_mira_refreshed.png"):
			return true
		dialogue_box.call("start_dialogue", [{
			"speaker": "Gus",
			"text": "Power's back. Door's listening. I still hate that sentence.",
			"portrait": "res://assets/art/portraits/gus/gus_alarmed.png",
		}])
		dialogue_box.call("_complete_current_line")
		stage = 1
		elapsed = 0.0
		return false
	if stage == 1 and elapsed >= 0.25:
		_save_capture("res://tmp/captures/dialogue_gus_refreshed.png")
		return true
	return false


func _save_capture(path: String) -> bool:
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Dialogue portrait capture requires a rendering display.")
		return false
	viewport_texture.get_image().save_png(path)
	print("saved %s" % path)
	return true
