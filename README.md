# The Last Token

The Last Token is a 2D top-down retro arcade mystery about exploring Pixel Haven, talking to strange arcade regulars, recovering a lost token, unlocking the staff room, and uncovering who the player really is.

## Status
The project is currently a playable MVP with placeholder visuals, placeholder slideshow panels, and optional audio hooks. It is intended for local testing and feedback, not final release.

## Engine
- Godot 4.x
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

## Core Gameplay Loop
Explore the arcade, talk to Mira and the other core NPCs, play Rockbyte Duel, solve the Sync Door puzzle, enter the Staff Room, watch the reveal slideshow, and continue into post-reveal roam.

## Memory Slots
The Memory Terminal opens a small save/load menu with three Memory Slots. Saves are stored under `user://saves/slot_1.json`, `slot_2.json`, and `slot_3.json`.

## Post-Reveal Roam
After the ending prompt, the player returns to ArcadeHub with post-reveal state unlocked. NPC dialogue changes to reflect the reveal, and the state can be saved and loaded.
