# Build & Ship — The Last Token

Engine: **Godot 4.7.stable**. Target: **Windows Desktop** (x86_64). The export preset lives in `export_presets.cfg` at the repo root and is already configured; it excludes `tools/`, `tmp/`, `docs/`, and `*.md` from the shipped build.

**Status: a verified release build exists** — `build/windows/TheLastToken.exe` + `TheLastToken.pck` (ship both together; `build/` is gitignored). The exported exe was smoke-tested headless: boots to the title menu, exit 0.

## One-time setup: export templates (already installed)

Templates live in `%APPDATA%\Godot\export_templates\4.7.stable\`; `windows_release_x86_64.exe` is installed. If they ever go missing: Godot editor → **Editor → Manage Export Templates → Download and Install**, or install `Godot_v4.7-stable_export_templates.tpz` from file.

## Validate before building

From the repo root, run the maintained regression entry point:

```powershell
pwsh tools/RunRegressionSuite.ps1
```

The runner performs an editor-wide parse, boots the main scene, treats silent script compile failures as failures, and executes all focused QA scripts. Logs are written under `tmp/qa/<timestamp>/`. See [`DEBUGGING.md`](../DEBUGGING.md) for runtime tracing.

## Build

```
& $godot --headless --path . --export-release "Windows Desktop" build/windows/TheLastToken.exe
```

Output: `build/windows/TheLastToken.exe` plus `TheLastToken.pck` (the preset keeps the pack separate; ship both together). For a debug build with a console window, use `--export-debug` instead.

## Notes

- `run/main_scene` = `res://scenes/main/Main.tscn`; app name = "The Last Token".
- Fixed 640×440 viewport, no Camera2D — each room is one screen.
- The `build/` directory is generated output and is safe to delete/regenerate.
