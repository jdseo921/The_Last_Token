# Build & Ship — The Last Token

Engine: **Godot 4.7.stable**. Target: **Windows Desktop** (x86_64). The export preset lives in `export_presets.cfg` at the repo root and is already configured; it excludes `tools/`, `tmp/`, `docs/`, and `*.md` from the shipped build.

**Status: a verified release build exists** — `build/windows/TheLastToken.exe` + `TheLastToken.pck` (ship both together; `build/` is gitignored). The exported exe was smoke-tested headless: boots to the title menu, exit 0.

## One-time setup: export templates (already installed)

Templates live in `%APPDATA%\Godot\export_templates\4.7.stable\`; `windows_release_x86_64.exe` is installed. If they ever go missing: Godot editor → **Editor → Manage Export Templates → Download and Install**, or install `Godot_v4.7-stable_export_templates.tpz` from file.

## Validate before building

From the repo root (console build recommended for CLI output):

```
$godot = "C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe"
& $godot --headless --import --path .                                   # import assets
& $godot --headless --script res://tools/validate_project.gd --path .   # parse/load/JSON + unit test
& $godot --headless --path . --quit-after 150                           # boot smoke (Main -> TitleMenu)
```

`validate_project.gd` should print `RESULT: NO ERRORS`. Optional runtime checks: `tools/smoke_minigames.gd`, `tools/smoke_adventure.gd`.

## Build

```
& $godot --headless --path . --export-release "Windows Desktop" build/windows/TheLastToken.exe
```

Output: `build/windows/TheLastToken.exe` plus `TheLastToken.pck` (the preset keeps the pack separate; ship both together). For a debug build with a console window, use `--export-debug` instead.

## Notes

- `run/main_scene` = `res://scenes/main/Main.tscn`; app name = "The Last Token".
- Fixed 640×440 viewport, no Camera2D — each room is one screen.
- The `build/` directory is generated output and is safe to delete/regenerate.
