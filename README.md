# The Last Token

The Last Token is a 2D top-down retro arcade mystery about exploring Pixel Haven, talking to strange arcade regulars, recovering a lost token, unlocking the staff room, and uncovering who the player really is.

## Status
The project is currently an MVP candidate pending final live playtest, with Memory Slots, post-reveal roam, integrated background music, and a visual-polish pass for the reveal slideshow, hub state props, route cues, retro UI framing, and key minigame feedback. It is ready to open in Godot and export as a local test build, but should not be called live-verified until the full acceptance route passes in the Godot runtime.

## Engine
- Godot 4.x
- Godot 4.7.x is the current local target; `project.godot` lists the `4.7` feature tag.
- Main scene: `res://scenes/main/Main.tscn`

## Open The Project
1. Install Godot 4.x.
2. Open Godot's Project Manager.
3. Choose `Import`.
4. Select this folder's `project.godot`.
5. Open the project.

## Run The Game
1. Open the project in Godot.
2. Press Play.
3. If prompted for a main scene, choose `res://scenes/main/Main.tscn`.

## Manual Windows Export
No `export_presets.cfg` is currently included. Create the preset manually in Godot:

1. Open the project in Godot 4.4.x.
2. Go to `Project -> Export`.
3. Choose `Add...`.
4. Select `Windows Desktop`.
5. Install export templates if Godot prompts for them.
6. Choose `Export Project`.
7. Export builds outside this repo or into an ignored local build folder such as `builds/` or `exports/`.

Do not commit generated `.exe`, `.pck`, `.zip`, log files, or large build output files.

## Controls
- Move: `WASD` / Arrow Keys
- Interact / Continue: `E` / Space
- Cancel / Back: Esc / Backspace
- Menus: mouse click / keyboard focus where supported
- Title Menu: `Window Size` cycles same-ratio test windows: `640 x 440`, `960 x 660`, `1280 x 880`

## Core Gameplay Loop
Explore the arcade, talk to Mira and the other core NPCs, play required arcade stages, investigate the Lost Shift File, restore service power, assemble the Security Tape, walk the Final Night reconstruction, stabilize Memory Echo, enter the Staff Room, watch the reveal slideshow, and continue into post-reveal roam.

Current required route:
1. Rockbyte Duel
2. Truth Filter
3. Circuit Soda
4. Lost Shift File
5. Static Service Run
6. Maintenance Sync
7. Security Tape Assembly
8. Final Night Walk
9. Memory Echo
10. Staff Room Reveal

Save slots display required progress as `Main: x / 10`, plus optional games, secrets, and Memory Signal.

## Save Files
The Esc pause menu opens save/load options with three save slots. Saves are stored under `user://saves/slot_1.json`, `slot_2.json`, and `slot_3.json`.

## QA Automation
See `QA_AUTOMATION.md` before running automated Godot checks from Codex. Headless scene checks are useful for smoke testing, but the first quest is not considered passed until a live Godot viewport playthrough confirms it.

## Post-Reveal Roam
After the ending prompt, the player returns to ArcadeHub with post-reveal state unlocked. NPC dialogue changes to reflect the reveal, and the state can be saved and loaded.

## Current Placeholders
- Some map and character visuals are still simple shapes and labels, but map route cues now point to the next required room or local action, and small ambient sprite effects add readable cabinet/static/exit signals.
- The Staff Room reveal now uses eight mono-color 8-bit panels under `assets/art/cutscenes/memory_reveal/`; the slideshow fallback still displays `MEMORY PANEL / Placeholder image pending` if an image is removed.
- Background music is included and wired through `AudioManager`. Simple generated SFX now cover memory panels, Memory Echo accepts, Staff Door unlock, arcade button pulses, score blips, error buzzes, and success jingles.
- Exact player position restore is placeholder-level; story state and safe scene paths are restored.
- Rockbyte Duel uses simple AI for MVP testing.

## Asset Notes
Generated polish assets are deterministic and project-local. The generator lives at `tools/generate_visual_polish_assets.gd` and currently covers mono-color reveal panels, small hub/minigame sprites, ambient map effect sheets, Security Tape/Rockbyte backgrounds, and simple WAV one-shots for cutscenes, doors, and arcade feedback.

The shared UI theme uses a readable retro monospace stack with pixel-style fallbacks when available. Antagonist dialogue uses the same font as protagonist dialogue, with distinct scan-jitter and flicker animation instead of a separate typeface.
