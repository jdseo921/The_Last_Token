# The Last Token

The Last Token is a 2D top-down retro arcade mystery about exploring Pixel Haven, talking to strange arcade regulars, recovering a lost token, unlocking the staff room, and uncovering who the player really is.

## Status
The project is currently an MVP candidate pending final live playtest, with placeholder visuals, placeholder slideshow panels, Memory Slots, post-reveal roam, and optional audio hooks. It is ready to open in Godot and export as a local test build, but should not be called live-verified until the full acceptance route passes in the Godot runtime.

## Engine
- Godot 4.x
- Godot 4.4.x preferred, because `project.godot` currently lists the `4.4` feature tag.
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
Explore the arcade, talk to Mira and the other core NPCs, play Rockbyte Duel, solve the Sync Door puzzle, enter the Staff Room, watch the reveal slideshow, and continue into post-reveal roam.

## Memory Slots
The Memory Terminal opens a small save/load menu with three Memory Slots. Saves are stored under `user://saves/slot_1.json`, `slot_2.json`, and `slot_3.json`.

## Post-Reveal Roam
After the ending prompt, the player returns to ArcadeHub with post-reveal state unlocked. NPC dialogue changes to reflect the reveal, and the state can be saved and loaded.

## Current Placeholders
- Visuals are simple shapes and labels.
- Cutscene panels may be missing and display `MEMORY PANEL / Placeholder image pending`.
- Audio hooks are present, but final sound effects and music are not included.
- Exact player position restore is placeholder-level; story state and safe scene paths are restored.
- Rockbyte Duel uses simple AI for MVP testing.
