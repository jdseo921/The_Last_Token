extends SceneTree
# Measure candidate quest summaries against the objective HUD tip budget
# (m5x7 @16 across 282px, single line).

const CANDIDATES := [
	"Look around. Talk to whoever is here.",
	"Talk to Mira at the ticket counter.",
	"Win your token back from Cabinet 07.",
	"Bring the Lost Token back to Mira.",
	"Talk to Roxy in Cabinet Row.",
	"Beat Roxy's score cabinet in Cabinet Row.",
	"Beat Roxy's cabinet in Cabinet Row.",
	"See Mr. Byte in Cabinet Row, then the Truth Filter.",
	"See Mr. Byte in Cabinet Row about the Truth Filter.",
	"Run the Truth Filter in Cabinet Row.",
	"Find Gus on the Arcade Hub floor.",
	"Talk to Gus in the Arcade Hub.",
	"See Vendo in Snack Alcove, then Circuit Soda.",
	"Route Circuit Soda in Snack Alcove.",
	"Help Pip sort the prizes in Prize Corner.",
	"Read the checklist, schedule, and note.",
	"Talk to Gus in Maintenance Hall.",
	"Restore service power in Maintenance Hall.",
	"Help Gus run Maintenance Sync.",
	"Follow the Staff Access Hall onward.",
	"Restore the Security Tape in Staff Corridor.",
	"Use Final Night Walk in Staff Corridor.",
	"Use Memory Echo in Staff Corridor.",
	"Enter the Staff Room from Staff Corridor.",
	"Let the memory settle.",
	"Speak with the remaining witnesses.",
]

func _process(_delta: float) -> bool:
	var font: Font = load("res://assets/fonts/m5x7.ttf")
	if font == null:
		print("NO FONT")
		return true
	print("budget: 282px | m5x7 @16")
	for text in CANDIDATES:
		var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		print("%s %5.0fpx  %s" % ["OK  " if w <= 282.0 else "OVER", w, text])
	return true
