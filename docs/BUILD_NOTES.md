# BUILD_NOTES.md

## Godot Version
- Target engine: Godot 4.x
- Godot 4.7.x is the current local target for testing/export.
- Project config currently lists feature tag: `4.7`

## Main Scene
- `res://scenes/main/Main.tscn`

## Autoloads
- `DebugLog` -> `res://scripts/DebugLog.gd`
- `GameState` -> `res://scripts/GameState.gd`
- `SceneChanger` -> `res://scripts/SceneChanger.gd`
- `SaveManager` -> `res://scripts/SaveManager.gd`
- `AudioManager` -> `res://scripts/AudioManager.gd`
- `DisplayOptions` -> `res://scripts/DisplayOptions.gd`
- `GameSettings` -> `res://scripts/GameSettings.gd`
- `ConscienceEncounterDirector` -> `res://scripts/ConscienceEncounterDirector.gd`
- `DevRouteMenu` -> `res://scripts/DevRouteMenu.gd`

## Export Status
- `export_presets.cfg` exists at the repo root and is committed. It defines a `Windows Desktop` preset exporting to `build/windows/TheLastToken.exe`, with `tools/`, `tmp/`, `docs/`, `*.md`, `scripts/qa/`, and generated art excluded from the pack.
- No generated binaries should be committed.
- Local build folders such as `build/`, `builds/`, `export/`, and `exports/` are ignored by `.gitignore`.
- `BUILD.md` is the current build reference; the manual steps below are kept only for recreating the preset from scratch.

## Manual Windows Export Steps
The committed preset makes these unnecessary. Use them only if `export_presets.cfg` is lost.

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

## Automated QA
`tools/RunRegressionSuite.ps1` is the maintained validation entry point: an editor-wide parse, a main-scene boot, then 31 QA scripts from `scripts/qa/`. See `QA_AUTOMATION.md` for what it does and does not prove, and `DEBUGGING.md` for runtime tracing.

The earlier note here limited automation to scene smoke tests because `--script` QA runners crashed while opening `user://logs/...`. That advice predates the regression suite, which runs 31 `--script` checks sequentially, each with its own `--log-file` and `--disable-crash-handler`.
