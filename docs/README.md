# The Last Token — Design Docs (Canonical)

This folder is the **single source of truth** for story and gameplay direction. It reworks and consolidates the ~30 scattered root-level planning docs into two clear, non-contradictory documents.

## Read these

1. **[DESIGN_BIBLE.md](DESIGN_BIBLE.md)** — canon (premise, the twist, the dark-past tone rule), the theme & **motto distribution map**, characters & voice, the Memory Signal system, dialogue rules, and the **45–60 min story flow**.
2. **[STAGE_DESIGN.md](STAGE_DESIGN.md)** — every playable stage's redesign: distinct verb, entertainment, story connection, per-stage dialogue (lore + breather + motto), coded difficulty, and build order.
3. **[BUILD.md](BUILD.md)** — how to validate the project headless and export a Windows build.

## Canon rule

Where these docs and any older root-level doc disagree, **these win.** "Canon" = the shipped game data (`data/dialogue/*.json`, `data/quests.json`, `scripts/StaffRoom.gd`), reconciled here. The old planning docs are advisory only and slated for `docs/archive/` (see Bible §9) — nothing is deleted without approval.

## Status

- **Story & gameplay direction:** implemented in the shipped data.
- **Protagonist reveal:** distributed across the required route (early → mid → late), not back-loaded to the climax. The dark past stays implied/poetic. See the Bible's motto/reveal map.
- **Art direction — visual phase DONE:** every minigame, puzzle, and adventure stage renders on a bespoke neon "arcade-screen" SVG background inside a shared CRT frame — `scripts/ArcadeScreen.gd` + `assets/art/minigames/**/backgrounds/*.svg` + `assets/art/ui/crt/crt_overlay.svg`. Climax cutscene: `assets/art/cutscenes/memory_reveal/reveal_0X.svg`. (Full portrait/map/generator art remains an optional later pass.)
- **Build:** export-ready — see **[BUILD.md](BUILD.md)** (blocked only on installing the 4.7 export templates).
- **Validation:** headless harness in `tools/` — `validate_project.gd` (parse/load/JSON + overlay unit test), `smoke_minigames.gd`, `smoke_adventure.gd`. Latest run: **no errors**; real boot to TitleMenu clean.

## Implementation order (Bible + Stage §7)

1. Dialogue single-source cleanup (remove triplication; fix signal values).
2. Story pass — seed foreshadowing, motto fragments, breathers (data only).
3. Framework capabilities (moving hazards + fog in `ArcadeAdventureStage`).
4. Stage redesigns (route order, cheapest wins first).
5. Ending reprise (conditional fragment collection).
6. Art pass — **done** for stage screens: shared CRT frame (`ArcadeScreen`) + per-stage neon SVG backgrounds across all minigames, puzzles, and adventure stages. Portrait/map/generator art is an optional later pass.
