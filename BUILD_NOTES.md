# BUILD_NOTES.md

## Godot Version
- Target engine: Godot 4.x
- Project config currently lists feature tag: `4.4`

## Main Scene
- `res://scenes/main/Main.tscn`

## Autoloads
- `GameState` -> `res://scripts/GameState.gd`
- `SceneChanger` -> `res://scripts/SceneChanger.gd`
- `SaveManager` -> `res://scripts/SaveManager.gd`
- `AudioManager` -> `res://scripts/AudioManager.gd`

## Export Status
- `export_presets.cfg` does not currently exist.
- No platform-specific export settings have been created.
- No generated binaries should be committed.

## Manual Export Steps
1. Open the project in Godot 4.x.
2. Go to `Project -> Export`.
3. Choose `Add...`.
4. Select the target platform.
5. Configure the export template/settings for that platform.
6. Choose `Export Project`.
7. Keep exported builds outside the repo or in an ignored build folder.

## Manual Setup
- Open `project.godot` in Godot 4.x.
- Confirm the main scene is `res://scenes/main/Main.tscn`.
- Confirm the autoloads listed above are present.
- Optional audio files can be placed in:
  - `res://assets/audio/sfx/`
  - `res://assets/audio/music/`

## Save Files
Runtime saves are written under:
- `user://saves/slot_1.json`
- `user://saves/slot_2.json`
- `user://saves/slot_3.json`

The exact OS path for `user://` depends on the Godot editor/runtime environment.
