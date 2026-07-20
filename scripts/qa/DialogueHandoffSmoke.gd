extends SceneTree

const DIALOGUE_BOX_SCENE_PATH := "res://scenes/ui/DialogueBox.tscn"
const MR_BYTE_PORTRAIT := "res://assets/art/portraits/mr_byte/mr_byte_neutral.png"

var failures: Array[String] = []
var dialogue_box: CanvasLayer = null

func _initialize() -> void:
	var packed_scene := load(DIALOGUE_BOX_SCENE_PATH) as PackedScene
	if packed_scene == null:
		print("FAIL: DialogueBox scene did not load.")
		quit(1)
		return
	dialogue_box = packed_scene.instantiate()
	root.add_child(dialogue_box)
	call_deferred("_run_check")

func _run_check() -> void:
	dialogue_box.call("start_dialogue", [
		{"speaker": "Mr. Byte", "text": "Ambient noise.", "portrait": MR_BYTE_PORTRAIT},
	])
	var portrait := dialogue_box.get_node("Panel/Portrait") as TextureRect
	_expect(portrait.visible and portrait.texture != null, "Mr. Byte portrait did not appear for his line.")
	dialogue_box.call("_accept_current_line")
	_expect(not portrait.visible, "Outgoing Mr. Byte portrait remained visible after dialogue ended.")
	_expect(portrait.texture == null, "Outgoing Mr. Byte portrait texture was retained after dialogue ended.")

	print("\n=== DIALOGUE HANDOFF SMOKE ===")
	if failures.is_empty():
		print("Outgoing speaker portrait clears before the next dialogue handoff.")
	else:
		for failure in failures:
			print("FAIL: " + failure)
	print("=== END DIALOGUE HANDOFF SMOKE ===")
	dialogue_box.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
