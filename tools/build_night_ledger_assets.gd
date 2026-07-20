extends SceneTree

const SOURCE := "res://assets/art/portraits/night_ledger/generated/night_ledger_expression_sheet.png"
const PORTRAIT_OUTPUTS := [
	"res://assets/art/portraits/night_ledger/night_ledger_neutral.png",
	"res://assets/art/portraits/night_ledger/night_ledger_dry.png",
	"res://assets/art/portraits/night_ledger/night_ledger_grave.png",
	"res://assets/art/portraits/night_ledger/night_ledger_delighted.png",
	"res://assets/art/portraits/night_ledger/night_ledger_panic.png",
	"res://assets/art/portraits/night_ledger/night_ledger_grin.png",
]
const CABINET_OUTPUT := "res://assets/art/minigames/night_ledger/night_ledger_cabinet.png"
const COLUMNS := 3
const ROWS := 2


func _initialize() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE))
	if source == null or source.is_empty():
		push_error("Could not load Night Ledger expression sheet")
		quit(1)
		return
	var cell_size := Vector2i(source.get_width() / COLUMNS, source.get_height() / ROWS)
	var neutral_subject: Image = null
	for index in range(PORTRAIT_OUTPUTS.size()):
		var cell_origin := Vector2i(index % COLUMNS, index / COLUMNS) * cell_size
		var cell := source.get_region(Rect2i(cell_origin, cell_size))
		var guard := Vector2i(32, 16)
		cell = cell.get_region(Rect2i(guard, cell_size - guard * 2))
		var used := cell.get_used_rect()
		if used.size == Vector2i.ZERO:
			push_error("Night Ledger cell %d is empty" % index)
			quit(1)
			return
		var subject := cell.get_region(used)
		if index == 0:
			neutral_subject = subject.duplicate()
		var portrait := _fit_subject(subject, Vector2i(128, 128), Vector2i(118, 118))
		var error := portrait.save_png(ProjectSettings.globalize_path(PORTRAIT_OUTPUTS[index]))
		if error != OK:
			push_error("Could not write %s" % PORTRAIT_OUTPUTS[index])
			quit(1)
			return
		print("Wrote %s" % PORTRAIT_OUTPUTS[index])
	var cabinet := _fit_subject(neutral_subject, Vector2i(96, 128), Vector2i(86, 120))
	var cabinet_error := cabinet.save_png(ProjectSettings.globalize_path(CABINET_OUTPUT))
	if cabinet_error != OK:
		push_error("Could not write Night Ledger cabinet")
		quit(1)
		return
	print("Wrote %s" % CABINET_OUTPUT)
	quit()


func _fit_subject(subject: Image, output_size: Vector2i, max_size: Vector2i) -> Image:
	var scale_factor := minf(
		float(max_size.x) / float(subject.get_width()),
		float(max_size.y) / float(subject.get_height())
	)
	var scaled_size := Vector2i(
		maxi(1, int(round(subject.get_width() * scale_factor))),
		maxi(1, int(round(subject.get_height() * scale_factor)))
	)
	subject.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_NEAREST)
	var output := Image.create(output_size.x, output_size.y, false, Image.FORMAT_RGBA8)
	output.fill(Color(0, 0, 0, 0))
	var destination := Vector2i(
		(output_size.x - scaled_size.x) / 2,
		(output_size.y - scaled_size.y) / 2
	)
	output.blit_rect(subject, Rect2i(Vector2i.ZERO, scaled_size), destination)
	return output
