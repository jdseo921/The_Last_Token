# KNOWN_ISSUES.md

## Known Bugs / Risks
- Final runtime click-through still needs to be completed in Godot on a machine with the editor installed.
- Rockbyte Duel uses simple cabinet AI, so outcomes may vary and winning may require retrying.
- Save/load restores GameState flags and safe scene paths, but exact player position/facing restoration is still placeholder-level. ArcadeHub uses simple state-based spawn positions instead of a full spawn marker system.
- Save/load menu interaction should be manually tested with existing and empty slots.
- No `export_presets.cfg` is included yet; Windows export presets must be created manually in Godot.

## Placeholder Limitations
- Visuals are simple placeholder shapes and labels.
- Slideshow reveal panels may be missing and should display `MEMORY PANEL / Image pending`.
- Audio hooks exist, but final sound effects and music are not included. Missing audio files should not block play.
- Title/Menu flow is functional for MVP testing, not final polish.
- UI layout is functional placeholder UI, not final polish.

## Not Bugs
- Missing custom art and missing audio files are expected for the MVP.
- The project intentionally has one ending and a small post-reveal roam mode.
- The project intentionally does not include combat, inventory, extra NPCs, or additional minigames.
