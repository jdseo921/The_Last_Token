extends SceneTree
# Measure circuit soda tile sheet: for each of the 6 frames, report which edge
# midpoints have pipe pixels (N/E/S/W openings) so logic can match the art.

func _process(_delta: float) -> bool:
	var tex := load("res://assets/art/minigames/circuit_soda/circuit_soda_tiles_sheet.png") as Texture2D
	if tex == null:
		print("NO SHEET")
		return true
	var img := tex.get_image()
	if img.is_compressed():
		img.decompress()
	var fw := int(img.get_width() / 6)
	var fh := img.get_height()
	print("frame size: %dx%d" % [fw, fh])
	for f in range(6):
		var ox := f * fw
		var sides := ""
		if _edge_has_pipe(img, ox, fw, fh, "N"):
			sides += "N"
		if _edge_has_pipe(img, ox, fw, fh, "E"):
			sides += "E"
		if _edge_has_pipe(img, ox, fw, fh, "S"):
			sides += "S"
		if _edge_has_pipe(img, ox, fw, fh, "W"):
			sides += "W"
		print("frame %d: edges=%s" % [f, sides])
	return true

func _edge_has_pipe(img: Image, ox: int, fw: int, fh: int, side: String) -> bool:
	# sample a band across the middle third of the given edge, 2px inset
	var hits := 0
	var samples := 0
	for t in range(-fw / 6, fw / 6):
		var p: Vector2i
		match side:
			"N":
				p = Vector2i(ox + fw / 2 + t, 1)
			"S":
				p = Vector2i(ox + fw / 2 + t, fh - 2)
			"E":
				p = Vector2i(ox + fw - 2, fh / 2 + t)
			_:
				p = Vector2i(ox + 1, fh / 2 + t)
		if p.x < ox or p.x >= ox + fw or p.y < 0 or p.y >= fh:
			continue
		samples += 1
		var c := img.get_pixelv(p)
		if c.a > 0.5 and (c.r + c.g + c.b) > 0.55:
			hits += 1
	return samples > 0 and float(hits) / float(samples) > 0.3
