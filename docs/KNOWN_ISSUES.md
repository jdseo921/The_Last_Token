# KNOWN_ISSUES.md

Updated after the game was completed and playtested. Entries below were re-checked against the code; the earlier MVP-era list described a much less finished project.

## Status
- The game is complete and playable end to end, and has been played through by other people.
- `tools/RunRegressionSuite.ps1` is the maintained validation entry point: an editor-wide parse, a main-scene boot, then 32 checks from `scripts/qa/`.
- Headless automation still does not prove movement feel, input timing, or readability. `TEST_PLAN.md` remains the manual pass for those.

## Open work
- Exit placement between rooms needs another pass.
- Adventure-stage levels need adjustment.

## Known bugs / risks
- Rockbyte Duel uses simple cabinet AI, so outcomes vary and winning may require retrying.
- Saves made from minigames, cutscenes, title flow, or post-reveal states restore to the parent room that owns them rather than to the exact transient scene. This is deliberate; see `SaveManager._get_safe_resume_scene`.
- Exact player position and facing are not restored. Story state, safe scene paths, and named spawn markers are.

## Resolved since the MVP list
- **Spawn markers.** ArcadeHub no longer uses state-based spawn positions. It has eight named markers (`Spawn_Default`, `Spawn_FromCabinetRow`, and so on), and 21 markers exist across the scenes. `GameSanityAudit.gd` checks that every `MapTransition` target marker exists in both directions.
- **Export preset.** `export_presets.cfg` is committed and configured for Windows Desktop. See `BUILD.md`.
- **Audio.** Sixteen music tracks and sixteen SFX one-shots ship under `assets/audio/`, wired through `AudioManager` with context mapping and crossfades. Missing audio still does not block play.
- **Reveal panels.** Eight panels exist under `assets/art/cutscenes/memory_reveal/`. The `MEMORY PANEL / Placeholder image pending` card is now only a fallback for a removed image.
- **Text clipping.** Now covered automatically: `GameSanityAudit.gd` measures every shipped dialogue line against the real DialogueBox rect, `MinigameLayoutAudit.gd` measures minigame controls against their parents, and `tools/audit_text_fit.gd` sweeps every scene. `MinigameUI.gd` logs a `text_did_not_fit` warning through `DebugLog` at runtime.
- **Save/load menu.** Covered by `SaveSlotDisplaySmoke.gd` for slot text and by the save/reload and corrupt-file checks in `GameSanityAudit.gd`.
- **QA runner crashes.** The old `user://logs` crash advice predates the regression suite, which runs 32 `--script` checks sequentially, each with its own `--log-file` and `--disable-crash-handler`.

## Placeholder limitations
- Some map and character visuals are still simple shapes and labels, though 207 PNGs now ship under `assets/art/`, including map backgrounds for eight rooms and portraits for ten speakers.
- SFX are simple generated WAV one-shots rather than final sound design.
- Generated polish assets are deterministic and project-local; the generators live under `tools/`.

## Not bugs
- The project intentionally has one ending and a small post-reveal roam mode.
- The project intentionally does not include combat or an inventory.
- The MVP-era line "no additional minigames" no longer holds: the shipped game has eleven playable screens, catalogued in `scripts/qa/MinigameTestCatalog.gd`.
