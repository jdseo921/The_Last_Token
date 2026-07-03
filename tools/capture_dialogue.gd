extends SceneTree
# Renders the dialogue box with a long line + portrait to verify text fits.
#   godot --path <project> --script res://tools/capture_dialogue.gd
var _n: Node = null
var _frame := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("user://captures")
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 1.0)
	bg.size = Vector2(640, 440)
	root.add_child(bg)

func _process(_d: float) -> bool:
	if _n == null:
		var ps = load("res://scenes/ui/DialogueBox.tscn")
		_n = ps.instantiate()
		root.add_child(_n)
		_n.call("start_dialogue", [
			{"speaker": "Player", "text": "You used to tell the kids who lost that a game ending was just a turn ending, not the whole world. I never once turned that rule toward myself.", "portrait": "res://assets/art/portraits/mira/mira_sad.png"},
		])
		_frame = 0
		return false
	_frame += 1
	if _frame >= 12:
		# reveal completes over time; force-complete by advancing the label
		var img := root.get_texture().get_image()
		img.save_png("user://captures/dialogue_long.png")
		print("saved dialogue_long.png")
		return true
	return false
