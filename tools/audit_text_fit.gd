extends SceneTree
## Checks that on-screen text actually fits the box it is drawn in.
##
## Every scene is instantiated and given a few frames so labels populated in
## _ready() carry their real text, then each Label/Button is measured with the
## font the theme actually resolves for it. Four ways text can go wrong:
##   1. no autowrap and the string is wider than its own rect  -> clipped
##   2. autowrap on and the wrapped block is taller than its rect -> cut off
##   3. the control sticks out of the parent panel it sits in  -> outside the box
##   4. the control lies outside the 640x440 viewport          -> off screen
const VIEWPORT := Vector2(640.0, 440.0)
const EPSILON := 0.5
# Reusable props are instantiated into a parent at a runtime position and are
# authored centred on their own origin, so measuring them standalone at (0,0)
# says nothing about where they land on screen.
const PREFAB_DIRS := ["/common/"]
const PREFAB_SCENES := ["res://scenes/ui/ReadableNote.tscn"]
const RUNTIME_TEXT_PATH := "res://tmp/runtime_text.json"

var _frame := 0
var scenes: Array[String] = []
var index := 0
var current: Node = null
var settle := 0
var problems: Array = []
var checked := 0
var runtime_hosts := {}
var runtime_rows: Array = []
var runtime_settle := 0

func _process(_delta: float) -> bool:
	_frame += 1
	if _frame < 2:
		return false
	if scenes.is_empty():
		_collect("res://scenes")
		scenes.sort()
		print("=== TEXT FIT AUDIT (%d scenes) ===" % scenes.size())
	if current == null:
		if index >= scenes.size():
			# Containers only resolve their children's size after a layout pass,
			# so the runtime strings get their own instantiate-then-settle phase
			# instead of being measured on the frame the scene is created.
			if runtime_hosts.is_empty():
				_load_runtime_hosts()
				return false
			runtime_settle += 1
			if runtime_settle < 4:
				return false
			_check_runtime_text()
			_report()
			return true
		var packed := load(scenes[index]) as PackedScene
		if packed == null:
			index += 1
			return false
		current = packed.instantiate()
		root.add_child(current)
		settle = 0
		return false
	settle += 1
	if settle < 3:
		return false
	_inspect(current, scenes[index])
	current.free()
	current = null
	index += 1
	return false

func _collect(dir_path: String) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var entry := d.get_next()
	while entry != "":
		var full := dir_path + "/" + entry
		if d.current_is_dir():
			if not entry.begins_with("."):
				_collect(full)
		elif entry.ends_with(".tscn"):
			scenes.append(full)
		entry = d.get_next()
	d.list_dir_end()

func _inspect(node: Node, scene_path: String) -> void:
	for child in _all_controls(node):
		var control := child as Control
		var text := ""
		if control is Label:
			text = (control as Label).text
		elif control is Button:
			text = (control as Button).text
		else:
			continue
		text = text.strip_edges()
		if text.is_empty():
			continue
		checked += 1
		# Hidden labels are measured too: dialogue panels and prompts instantiate
		# hidden and are revealed in play at these same rects. A nowrap label
		# self-heals its width to fit the text, so the symptom of a too-small box
		# is the grown rect escaping its parent or the screen - which is exactly
		# what the containment check looks for.
		_check_text_fit(control, text, scene_path)
		_check_containment(control, text, scene_path)

func _all_controls(node: Node) -> Array:
	var out: Array = []
	if node is Control:
		out.append(node)
	for c in node.get_children():
		out.append_array(_all_controls(c))
	return out

func _check_text_fit(control: Control, text: String, scene_path: String) -> void:
	var font: Font = control.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var font_size: int = control.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = 16
	var box := control.size
	# Buttons draw inside the stylebox padding.
	if control is Button:
		var sb: StyleBox = control.get_theme_stylebox("normal")
		if sb != null:
			box.x -= sb.get_margin(SIDE_LEFT) + sb.get_margin(SIDE_RIGHT)
			box.y -= sb.get_margin(SIDE_TOP) + sb.get_margin(SIDE_BOTTOM)
	var wraps := false
	if control is Label:
		wraps = (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF
	if wraps:
		var block := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, box.x, font_size)
		if block.y > box.y + EPSILON:
			_flag(scene_path, control, "wrapped text %.0fpx tall in a %.0fpx box" % [block.y, box.y], text)
		# A single unbreakable word still escapes sideways.
		for word in text.replace("\n", " ").split(" ", false):
			var word_w: float = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			if word_w > box.x + EPSILON:
				_flag(scene_path, control, "word '%s' is %.0fpx wide in a %.0fpx box" % [word, word_w, box.x], text)
				break
	else:
		var longest := 0.0
		for part in text.split("\n"):
			longest = maxf(longest, font.get_string_size(part, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		if longest > box.x + EPSILON:
			_flag(scene_path, control, "text %.0fpx wide in a %.0fpx box (no autowrap)" % [longest, box.x], text)
		var line_count := text.split("\n").size()
		var needed: float = font.get_height(font_size) * line_count
		if needed > box.y + EPSILON:
			_flag(scene_path, control, "%d line(s) need %.0fpx in a %.0fpx box" % [line_count, needed, box.y], text)

func _check_containment(control: Control, text: String, scene_path: String) -> void:
	var rect := control.get_global_rect()
	# Inside the parent panel, when the parent is a bounded box of its own.
	var parent := control.get_parent()
	if parent is Panel or parent is ColorRect:
		var pr := (parent as Control).get_global_rect()
		if pr.size.x > 1.0 and pr.size.y > 1.0:
			if rect.position.x < pr.position.x - EPSILON or rect.position.y < pr.position.y - EPSILON \
					or rect.end.x > pr.end.x + EPSILON or rect.end.y > pr.end.y + EPSILON:
				_flag(scene_path, control, "sticks out of its parent %s %s vs %s" % [parent.name, rect, pr], text)
	if _is_prefab(scene_path):
		return
	if rect.position.x < -EPSILON or rect.position.y < -EPSILON \
			or rect.end.x > VIEWPORT.x + EPSILON or rect.end.y > VIEWPORT.y + EPSILON:
		_flag(scene_path, control, "outside the 640x440 viewport %s" % rect, text)

func _collect_runtime_assignments() -> Array:
	# Status lines, verdicts and phase banners are assigned in code and never
	# exist at load time. Pair each `<label>.text = "literal"` with the node the
	# label is bound to via its @onready declaration, then measure the literal
	# against that node's real rect.
	var script_to_scene := {}
	for scene_path in scenes:
		var src := FileAccess.get_file_as_string(scene_path)
		var marker_text := "[ext_resource type=\"Script\" path=\""
		var from := 0
		while true:
			var marker := src.find(marker_text, from)
			if marker < 0:
				break
			var start: int = marker + marker_text.length()
			var stop := src.find("\"", start)
			if stop < 0:
				break
			var script_path := src.substr(start, stop - start)
			if not script_to_scene.has(script_path):
				script_to_scene[script_path] = scene_path
			from = stop
	var rows: Array = []
	for script_path in script_to_scene:
		if not FileAccess.file_exists(script_path):
			continue
		var src := FileAccess.get_file_as_string(script_path)
		var bindings := {}
		for line in src.split("\n"):
			var trimmed := line.strip_edges()
			if not trimmed.begins_with("@onready var "):
				continue
			var eq := trimmed.find("= $")
			if eq < 0:
				continue
			var var_name := trimmed.substr(13, trimmed.find(":", 13) - 13).strip_edges()
			if var_name.is_empty() or var_name.contains(" "):
				continue
			bindings[var_name] = trimmed.substr(eq + 3).strip_edges()
		if bindings.is_empty():
			continue
		for var_name in bindings:
			var needle: String = str(var_name) + ".text = \""
			var from := 0
			while true:
				var hit := src.find(needle, from)
				if hit < 0:
					break
				var value_start: int = hit + needle.length()
				var value := ""
				var i: int = value_start
				while i < src.length():
					var ch := src[i]
					if ch == "\\":
						if i + 1 < src.length():
							value += "\n" if src[i + 1] == "n" else src[i + 1]
							i += 2
							continue
						break
					if ch == "\"":
						break
					value += ch
					i += 1
				from = maxi(i, value_start)
				# Format placeholders stand in for their widest plausible value.
				value = value.replace("%.0f", "888").replace("%.1f", "88.8")
				value = value.replace("%d", "88").replace("%s", "PLACEHOLDER")
				value = value.strip_edges()
				if value.is_empty():
					continue
				rows.append({"scene": script_to_scene[script_path], "node": bindings[var_name], "text": value})
	return rows

func _is_prefab(scene_path: String) -> bool:
	if PREFAB_SCENES.has(scene_path):
		return true
	for fragment in PREFAB_DIRS:
		if scene_path.contains(fragment):
			return true
	return false

func _flag(scene_path: String, control: Control, message: String, text: String) -> void:
	problems.append("%s :: %s :: %s | \"%s\"" % [
		scene_path.get_file(), control.name, message, text.replace("\n", " / ").substr(0, 58)])

func _check_runtime_text() -> void:
	# Status lines, verdicts and prompts that only appear part-way through a
	# minigame never exist at load time, so they are measured here against the
	# label they are actually assigned to.
	var measured := 0
	for row in runtime_rows:
		var scene_path := str(row.get("scene", ""))
		if not runtime_hosts.has(scene_path):
			continue
		var host: Node = runtime_hosts[scene_path]
		var target := host.get_node_or_null(NodePath(str(row.get("node", ""))))
		if target == null or not (target is Label or target is Button):
			continue
		var control := target as Control
		# A control that never received a layout pass reports a placeholder size;
		# measuring against it would invent failures rather than find them.
		if control.size.x < 8.0 or control.size.y < 8.0:
			continue
		measured += 1
		_check_text_fit(control, str(row.get("text", "")), scene_path.get_file() + " (runtime)")
	for scene_path in runtime_hosts:
		(runtime_hosts[scene_path] as Node).free()
	print("runtime strings measured: %d" % measured)

func _load_runtime_hosts() -> void:
	runtime_rows = _collect_runtime_assignments()
	if runtime_rows.is_empty():
		runtime_hosts["__none__"] = Node.new()
		return
	for row in runtime_rows:
		var scene_path := str(row.get("scene", ""))
		if runtime_hosts.has(scene_path) or not ResourceLoader.exists(scene_path):
			continue
		var packed := load(scene_path) as PackedScene
		if packed == null:
			continue
		var inst := packed.instantiate()
		root.add_child(inst)
		runtime_hosts[scene_path] = inst

func _report() -> void:
	print("labels/buttons measured: %d" % checked)
	print("problems: %d" % problems.size())
	for p in problems:
		print("  " + p)
	print("=== TEXT FIT AUDIT: %s ===" % ("PASS" if problems.is_empty() else "FAIL"))
	quit(1 if problems.size() > 0 else 0)
