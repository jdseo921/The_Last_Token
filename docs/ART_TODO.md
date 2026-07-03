# Art To Generate — Handoff Checklist

How to use each entry: in ChatGPT Pro, attach the **style ref** (existing art shown) + the **blueprint** (structure ref, if listed), paste the **prompt**, then **save the result to the "save to" path**. I downscale to 640×440, wire it, and re-import. All backgrounds are top-down, 640×440 target; generate large (≈1500×1030) and I'll downscale.

Global style note to include in every map prompt: *"8/16-bit pixel-art, match the existing art of this arcade (dark, neon-lit, cozy-but-decaying). Keep the floor dark and low-contrast so bright gameplay markers read on top. No characters, no text, no UI."*

---

## PRIORITY 1 — Required-route rooms that are still flat placeholders

### 1. Staff Corridor  ← most important (Security Tape, Final Night Walk, Memory Echo, and the Staff Room door all live here)
- **Current:** flat dark polygon + colored blocks (no real art).
- **Style ref:** use the new `assets/art/minigames/adventure/backgrounds/static_service_run_generated.png` (same "back-of-house, overloaded" mood).
- **Blueprint (structure ref):** `assets/art/maps/staff_corridor/staff_corridor_blueprint.png`
- **Save to:** `assets/art/maps/staff_corridor/staff_corridor_generated.png`
- **Prompt:**
  > Top-down 2D pixel-art background, 640×440, for a narrow STAFF-ONLY back corridor of a closed retro arcade in an "overloaded, too much signal" state. A vertical corridor runs down the center with heavy walls left and right. Palette: near-black with harsh RED warning accents and a sickly cyan-white overload glow. Strong anchor at TOP-CENTER: a heavy sealed STAFF ROOM door, red-lit, clearly the destination. Along the lower walls, two dead terminal/kiosk alcoves (one cyan-lit, one violet-lit). Exposed cabling and warning stripes bleed light. Tense, oppressive, the truth is close.

### 2. Staff Room  ← the climax reveal room (lower urgency: a slideshow covers most of the screen during the key beat, but you roam it after)
- **Current:** flat placeholder.
- **Style ref:** the warm/human end of the palette — reference `assets/art/maps/prize_corner/prize_corner_background_640x440.png` for coziness.
- **Blueprint:** none yet — say the word and I'll make one. Keep the **center floor open** (reveal plays there); a desk/terminal upper area, a wall photo.
- **Save to:** `assets/art/maps/staff_room/staff_room_generated.png`
- **Prompt:**
  > Top-down 2D pixel-art background, 640×440, for the arcade owner's small back office / STAFF ROOM — the emotional heart of the game, after a long final night. Quiet, still, dim. A worn desk with an old CRT terminal (faint glow) toward the top, a chair, a framed employee photo on the wall, shelves of spare parts and half-built cabinet boards along the edges. Palette: warm dim amber lamplight against deep shadow — softer and more human than the rest of the arcade. Keep the CENTER FLOOR OPEN and uncluttered.

---

## PRIORITY 1 — New character portraits (Reel & Coily)

These two new cast members speak inside their stages but have no face yet. Match the framing/scale of the existing machine-character portraits in `assets/art/portraits/vendo/` and `assets/art/portraits/mr_byte/`. Give 2–3 mood variants each. (After you provide these, I add the portrait paths into `data/dialogue/reel.json` + `coily.json` and place them physically in Snack Alcove / Staff Corridor.)

- **Reel** (jukebox / house sound system) — **save to:** `assets/art/portraits/reel/reel_warm.png`, `reel_wistful.png`, `reel_sincere.png`
  > Pixel-art character portrait bust of REEL, a wall-mounted arcade JUKEBOX given a face: a glowing speaker-grille "mouth", a warm amber VU-meter as an "eye", chrome trim, vinyl/cassette motifs, soft neon. Personality: warm, wistful, nostalgic. Variants: warm, wistful, sincere. Simple dark background.
- **Coily** (mascot animatronic) — **save to:** `assets/art/portraits/coily/coily_cheerful.png`, `coily_grieving.png`, `coily_eerie.png`
  > Pixel-art character portrait bust of COILY, a retro arcade MASCOT ANIMATRONIC — a friendly worn spring/coil-shaped robot host. A forced cheerful smile that reads a little sad and cracked, one flickering eye, faded paint and dust. Variants: cheerful (forced), grieving/cracked, eerie. Simple dark background.

---

## PRIORITY 2 — Optional consistency upgrades (these rooms ALREADY have decent art)

Only regenerate if you want them to match the new premium hub/adventure style. Blueprints already made (they overlay your current colliders, so a regen keeps the exact layout and I don't touch colliders). For each: **style ref = its own current background**, **structure ref = its blueprint**.

| Room | Current art (style ref) | Blueprint (structure ref) | Save regeneration to |
|---|---|---|---|
| Snack Alcove | `assets/art/maps/snack_alcove/snack_alcove_background_640x440.png` | `.../snack_alcove/snack_alcove_blueprint.png` | `.../snack_alcove/snack_alcove_generated.png` |
| Maintenance Hall | `.../maintenance_hall/maintenance_hall_background_640x440.png` | `.../maintenance_hall/maintenance_hall_blueprint.png` | `.../maintenance_hall/maintenance_hall_generated.png` |
| Prize Corner | `.../prize_corner/prize_corner_background_640x440.png` | `.../prize_corner/prize_corner_blueprint.png` | `.../prize_corner/prize_corner_generated.png` |

Prompt template (fill in the bracket): *"Redraw this top-down arcade room in richer 8/16-bit pixel art, KEEPING the exact same layout, wall positions, and exits shown in the blueprint. [Snack Alcove: a neon snack counter — popcorn machine, cold-drinks vending machine, menu board. / Maintenance Hall: a grimy utility room — pipes, breaker panels, a workbench, warning lights. / Prize Corner: a prize-redemption counter — glass case of plush toys and trinkets, ticket-shelf wall, warm fairy lights.] Dark low-contrast floor so markers read on top. No characters, no text."*

---

## PRIORITY 2 — Hallways (×8, all flat placeholders)

Short connecting corridors, traversed on every room transition. One shared look is fine; vary the accent color per wing if you like. No blueprint needed (they're simple pass-throughs).
- **Save to:** `assets/art/maps/hallways/<name>_generated.png` for each: `cabinet_hallway`, `snack_hallway`, `prize_hallway`, `maintenance_hallway`, `back_hallway`, `cabinet_snack_hallway`, `snack_prize_hallway`, `maintenance_staff_hallway`.
- **Prompt:**
  > Top-down 2D pixel-art background, 640×440, for a SHORT connecting hallway in a closed retro arcade — a simple passage with a door/opening at each end. Carpeted floor with faded arcade-pattern trim, one or two framed game posters, a flickering ceiling light. Dim, neutral, transitional, low-contrast floor. [Optional accent: tint toward CYAN for cabinet wing / GREEN for snack wing / GOLD for prize wing / RED for the staff/back wing.]

---

## PRIORITY 3 — Side rooms (not on the required route)

Lowest priority; generate only for completeness. All currently flat placeholders. Save each to `assets/art/maps/<room>/<room>_generated.png`.
- **Front Entrance** — cold blue night lobby: locked glass doors, dead neon OPEN sign, ticket booth, one warm light still on.
- **Party Room** — faded birthday party room: long table, sagging streamers, a dark stage where a mascot used to perform.
- **Workshop** — cluttered repair workshop: half-built cabinets, tools, solder station, spare boards (this is 04's space — make it feel lived-in).
- **Memory Core** — abstract server/memory room: racks of humming drives, cables of light, the arcade's "brain." Eerie, sacred.
- **Restrooms** — small tiled restroom: a cracked mirror (important — the mirror is a story object), a dripping sink.

---

## Already handled (no action needed from you)
- ✅ **Arcade Hub** — regenerated & wired.
- ✅ **Cabinet Row** — your generated art is in; **I still owe the collider wiring** (my task, tracked).
- ✅ **Static Service Run + Final Night Walk** backgrounds + all 8 adventure sprites — wired this build.

## Fastest path to a fully-arted required route
Do **P1** first (Staff Corridor, Staff Room, Reel, Coily), then the **8 hallways**, and you'll have every screen the critical path touches. The three P2 rooms already look good — skip unless you want perfect consistency.
