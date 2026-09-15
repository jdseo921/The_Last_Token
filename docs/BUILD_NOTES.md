# BUILD_NOTES.md

## Godot Version
- Target engine: Godot 4.x
- Godot 4.7.x is the current local target for testing/export.
- Project config currently lists feature tag: `4.7`

## Main Scene
- `res://scenes/main/Main.tscn`

## Autoloads
- `GameState` -> `res://scripts/GameState.gd`
- `SceneChanger` -> `res://scripts/SceneChanger.gd`
- `SaveManager` -> `res://scripts/SaveManager.gd`
- `AudioManager` -> `res://scripts/AudioManager.gd`

## Export Status
- `export_presets.cfg` does not currently exist.
- If a local `export_presets.cfg` is created manually, review it before sharing because it may contain machine-specific paths.
- No platform-specific export settings have been created in the repo.
- No generated binaries should be committed.
- Local build folders such as `build/`, `builds/`, `export/`, and `exports/` are ignored by `.gitignore`.

## Manual Windows Export Steps
1. Open the project in Godot 4.7.x.
2. Go to `Project -> Export`.
3. Choose `Add...`.
4. Select `Windows Desktop`.
5. Install export templates if Godot prompts for them.
6. Choose `Export Project`.
7. Save the exported build outside the repo or in an ignored local build folder such as `builds/` or `exports/`.

Do not commit generated `.exe`, `.pck`, `.zip`, log files, or large build output files.

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

## Automated QA Caveat
Use `QA_AUTOMATION.md` for Codex/headless check guidance. In this workspace, temporary Godot QA runners have crashed while opening `user://logs/...`, so automated checks should be limited to scene smoke tests unless that local runner issue is fixed.
