extends SceneTree

const PRIZE_CORNER_PATH := "res://scenes/maps/PrizeCorner.tscn"
const PRIZE_ASCENT_PATH := "res://scenes/minigames/PrizeShelfRun.tscn"

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state := root.get_node("GameState")
	game_state.call("reset_for_new_game")
	game_state.set("story_started", true)
	game_state.set("circuit_soda_completed", true)
	game_state.set("vendo_unknown_clue_seen", true)
	var room := (load(PRIZE_CORNER_PATH) as PackedScene).instantiate()
	root.add_child(room)
	await process_frame

	var counter := room.get_node("InteractableLayer/PrizeCounter")
	var pip := room.get_node("InteractableLayer/Pip")
	var shelf := room.get_node("InteractableLayer/PrizeShelfRun")
	var counter_rect := _interaction_rect(counter)
	var pip_rect := _interaction_rect(pip)
	var shelf_rect := _interaction_rect(shelf)
	_expect(not counter_rect.intersects(pip_rect), "Prize Counter hitbox no longer overlaps Pip")
	_expect(not pip_rect.intersects(shelf_rect), "Pip hitbox no longer overlaps Prize Echo shelf")
	_expect(not counter_rect.intersects(shelf_rect), "Prize Counter hitbox no longer overlaps Prize Echo shelf")

	room.call("_handle_pip")
	_expect(bool(game_state.get("prize_echo_unlocked")), "talking to Pip unlocks Prize Echo Ascent directly")
	var initial_pip_lines: Array = room.get_node("UILayer/DialogueBox").get("dialogue_lines")
	_expect(initial_pip_lines.size() <= 10, "Pip's first quest introduction is authored as one continuous scene")
	_expect(not room.has_method("_start_prize_sort"), "obsolete three-label sorting route is removed")
	var pending: Callable = room.get("pending_after_dialogue")
	_expect(not pending.is_valid(), "Pip no longer launches Prize Echo automatically")
	room.call("_handle_pip")
	pending = room.get("pending_after_dialogue")
	_expect(not pending.is_valid(), "Pip directs the player without owning the run transition")
	room.call("_handle_prize_shelf_adventure")
	pending = room.get("pending_after_dialogue")
	_expect(pending.is_valid(), "the shelf interactable owns the Prize Echo transition")

	var save_data: Dictionary = game_state.call("to_save_data")
	_expect(bool(save_data.get("prize_echo_unlocked", false)), "Prize Echo handoff survives save data")
	game_state.call("reset_for_new_game")
	game_state.call("apply_save_data", save_data)
	_expect(bool(game_state.get("prize_echo_unlocked")), "Prize Echo handoff restores from save data")

	room.queue_free()
	await process_frame

	var stage := (load(PRIZE_ASCENT_PATH) as PackedScene).instantiate()
	root.add_child(stage)
	await process_frame
	await process_frame
	var frame := stage.get_node_or_null("HybridHUD/AdventureViewFrame") as Control
	var status_panel := stage.get_node_or_null("HybridHUD/StatusPanel") as Control
	var controls_panel := stage.get_node_or_null("HybridHUD/ControlsPanel") as Control
	var view := stage.get_node_or_null("AdventureView") as SubViewportContainer
	var world := stage.get_node_or_null("AdventureView/WorldViewport/HybridWorld") as Node2D
	var camera := stage.get_node_or_null("AdventureView/WorldViewport/HybridWorld/Explorer/Camera2D") as Camera2D
	var title_label := stage.get_node("HybridHUD/TopPanel/TitleLabel") as Label
	var objective_label := stage.get_node("HybridHUD/TopPanel/ObjectiveLabel") as Label
	var status_label := stage.get_node("HybridHUD/StatusPanel/StatusLabel") as Label
	var controls_label := stage.get_node("HybridHUD/ControlsPanel/ControlsLabel") as Label
	_expect(frame != null and frame.position.is_equal_approx(Vector2(10, 88)) and frame.size.is_equal_approx(Vector2(620, 264)), "Prize Echo keeps the adventure inside a framed center view")
	_expect(view != null and view.position.is_equal_approx(frame.position) and view.size.is_equal_approx(frame.size), "the world is clipped to the frame instead of hiding behind the HUD")
	_expect(status_panel != null and status_panel.position.x < controls_panel.position.x, "NEXT status sits left of the controls")
	_expect(title_label.position.y >= 7.0 and objective_label.position.y >= 32.0, "title and objective sit lower and remain vertically centered")
	_expect(status_label.get_theme_font("font").resource_path.ends_with("VT323-Regular.ttf") and status_label.get_theme_font_size("font_size") >= 14, "NEXT uses the larger readable HUD font")
	_expect(controls_label.get_theme_font("font").resource_path.ends_with("VT323-Regular.ttf") and controls_label.get_theme_font_size("font_size") >= 11, "controls use the larger readable HUD font")
	_expect(camera != null and camera.zoom.x < 0.61, "Prize Echo camera is zoomed out for the shorter center viewport")
	_expect(not stage.get_node("HybridHUD/ResetButton").visible, "redundant reset button is hidden")
	_expect(controls_label.text.contains("ARROWS"), "controls explicitly include arrow-key movement")
	_expect(stage.get_node_or_null("ArcadeScanlines") == null, "adventure stages omit the obscuring horizontal scanline overlay")
	var first_tag := world.get_node_or_null("Collectible01") as TextureRect if world != null else null
	var first_key := world.get_node_or_null("Key01") as TextureRect if world != null else null
	var second_key := world.get_node_or_null("Key02") as TextureRect if world != null else null
	var third_key := world.get_node_or_null("Key03") as TextureRect if world != null else null
	var first_portal := world.get_node_or_null("DepthPortal") as TextureRect if world != null else null
	var first_checkpoint := world.get_node_or_null("Threshold01") as TextureRect if world != null else null
	var exit_beacon := world.get_node_or_null("ExitBeacon") as TextureRect if world != null else null
	_expect(first_tag != null and first_tag.size.x >= 56.0, "collectible icons remain readable at the zoomed-out camera scale")
	_expect(first_key != null and second_key != null and third_key != null, "all three Prize Echo rail keys are present")
	_expect(first_key != null and first_key.size.is_equal_approx(Vector2(74, 74)) and second_key.size.is_equal_approx(first_key.size) and third_key.size.is_equal_approx(first_key.size), "all rail keys use one consistently large display size")
	if first_key != null and second_key != null and third_key != null:
		var key_centers := [first_key.position + first_key.size * 0.5, second_key.position + second_key.size * 0.5, third_key.position + third_key.size * 0.5]
		_expect((key_centers[0] as Vector2).is_equal_approx(Vector2(2050, 990)) and (key_centers[1] as Vector2).is_equal_approx(Vector2(3450, 426)) and (key_centers[2] as Vector2).is_equal_approx(Vector2(3250, 854)), "rail keys occupy their authored traversal positions")
		_expect(_keys_clear_portal_triggers(stage, key_centers), "every rail key requires a real traversal away from a portal")
	_expect(first_tag != null and first_tag.texture.resource_path.ends_with("prize_echo_tag_v2.png"), "Prize Echo uses the high-contrast generated tag sprite")
	_expect(first_portal != null and first_portal.size.y >= 88.0 and is_equal_approx(first_portal.position.y + first_portal.size.y, 900.0), "depth gates are enlarged and floor-aligned")
	_expect(first_portal != null and first_portal.texture.resource_path.ends_with("prize_depth_gate_v2.png"), "Prize Echo uses the generated depth-gate sprite")
	var portal_label := first_portal.get_meta(&"world_label", null) as Label if first_portal != null else null
	_expect(portal_label != null and portal_label.get_parent() == stage and portal_label.get_theme_font_size("font_size") >= 13, "compact depth-gate control label is projected above the gate in unscaled HUD space")
	_expect(first_checkpoint != null and first_checkpoint.texture.resource_path.ends_with("adventure_checkpoint_flag_v2.png"), "thresholds use the generated checkpoint flag")
	_expect(first_checkpoint != null and first_checkpoint.size.y >= 88.0 and is_equal_approx(first_checkpoint.position.y + first_checkpoint.size.y, 900.0), "checkpoint flag is enlarged and floor-aligned")
	var checkpoint_label := first_checkpoint.get_meta(&"world_label", null) as Label if first_checkpoint != null else null
	_expect(checkpoint_label != null and checkpoint_label.get_parent() == stage and checkpoint_label.get_theme_font_size("font_size") >= 13, "compact SAVE label is projected above the checkpoint flag in unscaled HUD space")
	_expect(exit_beacon != null and exit_beacon.size.y >= 96.0 and is_equal_approx(exit_beacon.position.y + exit_beacon.size.y, 900.0), "exit sprite is enlarged and floor-aligned")
	_expect(exit_beacon != null and exit_beacon.texture.resource_path.ends_with("prize_exit_beacon_v2.png"), "Prize Echo uses the generated exit-beacon sprite")
	var exit_label := exit_beacon.get_meta(&"world_label", null) as Label if exit_beacon != null else null
	_expect(exit_label != null and exit_label.get_parent() == stage and exit_label.get_theme_font_size("font_size") >= 13, "compact EXIT label is projected above the floor-aligned beacon in unscaled HUD space")
	_expect(_has_continuous_backdrops(world, stage.get("world_size")), "adventure backdrop has no repeated horizontal seam")
	_check_sprite_alpha("res://assets/art/minigames/hybrid_exploration/prize_echo_tag_v2.png")
	_check_sprite_alpha("res://assets/art/minigames/hybrid_exploration/prize_depth_gate_v2.png")
	_check_sprite_alpha("res://assets/art/minigames/hybrid_exploration/prize_exit_beacon_v2.png")
	_check_sprite_alpha("res://assets/art/minigames/hybrid_exploration/adventure_checkpoint_flag_v2.png")
	_expect(_has_outline_climb_rail(world), "vertical platform stripes are replaced by outlined climb rails")
	stage.queue_free()
	await process_frame
	print("PrizeEchoHandoffSmoke: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(0 if failures == 0 else 1)


func _interaction_rect(interactable: Node2D) -> Rect2:
	var extents: Vector2 = interactable.get("interact_extents")
	return Rect2(interactable.position - extents * 0.5, extents)


func _has_continuous_backdrops(world: Node2D, expected_world_size: Vector2) -> bool:
	if world == null:
		return false
	var backdrop_count := 0
	for child in world.get_children():
		if not str(child.name).begins_with("DepthBackdrop") or not child is TextureRect:
			continue
		backdrop_count += 1
		var backdrop := child as TextureRect
		if not is_zero_approx(backdrop.position.y) or not is_equal_approx(backdrop.size.y, expected_world_size.y):
			return false
	return backdrop_count == ceili(expected_world_size.x / 640.0)


func _check_sprite_alpha(path: String) -> void:
	var texture := load(path) as Texture2D
	var sprite_image := texture.get_image() if texture != null else null
	_expect(sprite_image != null and not sprite_image.is_empty(), "%s loads" % path.get_file())
	if sprite_image == null or sprite_image.is_empty():
		return
	_expect(sprite_image.get_pixel(0, 0).a < 0.05, "%s has transparent corners" % path.get_file())
	var visible_pixels := 0
	for y in range(sprite_image.get_height()):
		for x in range(sprite_image.get_width()):
			if sprite_image.get_pixel(x, y).a > 0.5:
				visible_pixels += 1
	_expect(visible_pixels > 120, "%s retains a readable opaque silhouette" % path.get_file())


func _has_outline_climb_rail(world: Node2D) -> bool:
	if world == null:
		return false
	for child in world.get_children():
		if not child is StaticBody2D:
			continue
		var collision: CollisionShape2D = null
		for part in child.get_children():
			if part is CollisionShape2D:
				collision = part
				break
		if collision == null or not collision.shape is RectangleShape2D:
			continue
		var size := (collision.shape as RectangleShape2D).size
		if size.x <= 40.0 and size.y >= 120.0:
			for visual in child.get_children():
				if visual is Line2D:
					return true
	return false


func _keys_clear_portal_triggers(stage: Node, key_centers: Array) -> bool:
	var profile: Dictionary = stage.get("stage_profile")
	for key_value in key_centers:
		var key_center: Vector2 = key_value
		for portal_value in profile.get("portals", []):
			var portal: Dictionary = portal_value
			var trigger: Rect2 = portal.get("rect", Rect2())
			if _distance_to_rect(key_center, trigger) < 344.0:
				return false
	return true


func _distance_to_rect(point: Vector2, rect: Rect2) -> float:
	var closest := Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)
	return point.distance_to(closest)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)
