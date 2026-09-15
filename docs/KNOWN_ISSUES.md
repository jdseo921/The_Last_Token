# KNOWN_ISSUES.md

## Live Runtime Test Status
- Final runtime click-through still needs to be completed in Godot on a machine with the editor installed.
- Publish-readiness polish pass was statically reviewed and passed a Godot 4.7 headless project/main-scene smoke check.
- The full `TEST_PLAN.md` path still needs a human interactive playthrough in the Godot viewport because NPC movement, collisions, focus navigation, and menu readability cannot be fully verified from the headless console.
- Codex-driven temporary Godot QA runners have repeatedly crashed while opening `user://logs/...`. Use `QA_AUTOMATION.md` and prefer headless scene smoke checks plus manual viewport QA.

## Known Bugs / Risks
- Rockbyte Duel uses simple cabinet AI, so outcomes may vary and winning may require retrying.
- Save/load restores GameState flags and safe scene paths, but exact player position/facing restoration is still placeholder-level. ArcadeHub uses simple state-based spawn positions instead of a full spawn marker system.
- Saves made from minigames, cutscenes, title flow, or post-reveal states restore safely to ArcadeHub instead of restoring the exact transient scene.
- Save/load menu interaction should be manually tested with existing and empty slots.
- Latest UI polish should be manually checked in the Godot viewport for text clipping at the project window size, especially Memory Slot summaries and longer dialogue lines.
- No `export_presets.cfg` is included yet; Windows export presets must be created manually in Godot.

## Placeholder Limitations
- Visuals are simple placeholder shapes and labels.
- Slideshow reveal panels may be missing and should display an intentional `MEMORY PANEL / Placeholder image pending` panel.
- Audio hooks exist, but final sound effects and music are not included. Missing audio files should not block play.
- Title, save slots, dialogue, puzzle, reveal, and ending screens have MVP readability polish, but still use simple placeholder UI.
- Hub interactables are labeled placeholder markers; final sprite art and richer environmental dressing are still out of scope for this MVP pass.

## Not Bugs
- Missing custom art and missing audio files are expected for the MVP.
- The project intentionally has one ending and a small post-reveal roam mode.
- The project intentionally does not include combat, inventory, extra NPCs, or additional minigames.
