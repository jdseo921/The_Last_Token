# QA_AUTOMATION.md

## Purpose
This project can use Godot headless checks for quick launch and scene smoke tests, but full gameplay QA still needs a human Godot viewport pass. Codex should not treat headless checks as proof that movement, focus, dialogue timing, collision, save menu interaction, or minigame feel has passed.

## Current Automation Boundary
Use automated checks for:

- Project import/open sanity.
- Main scene launch sanity.
- Direct scene parse/load sanity.
- Missing script/resource errors.
- Obvious GDScript parser errors.

Do not use automated checks as the only proof for:

- Dialogue input timing.
- Player movement and collision.
- Interaction range and prompts.
- Save/load menu focus and slot selection.
- Rockbyte Duel lose/retry/win feel.
- Quest notice readability.
- Full first-quest acceptance.

## Known Codex/Godot Issue
In this workspace, Godot 4.7 console can launch normal project scenes headlessly, but temporary QA scenes or direct `--script` state runners have repeatedly crashed while trying to open `user://logs/...`.

Observed symptom:

```text
ERROR: Failed to open 'user://logs/godot...log'.
CrashHandlerException: Program crashed with signal 11
```

Because of this, Codex should avoid temporary Godot state-runner scenes/scripts that drive save/load or scene changes. Those checks may crash the local console runner even when the actual game scenes still launch.

## Recommended Codex Smoke Commands
Run these only as smoke checks:

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --path "." --quit
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --path "." "res://scenes/main/Main.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --path "." "res://scenes/arcade/ArcadeHub.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --path "." "res://scenes/minigames/RockbyteDuel.tscn" --quit-after 2
```

If these pass, report them as `headless smoke passed`, not as `live playthrough passed`.

## Commands To Avoid In This Workspace
Avoid these until the `user://logs` crash is solved:

```powershell
godot --headless --path "." --script "res://tmp/SomeRunner.gd"
godot --headless --path "." "res://tmp/TemporaryQAScene.tscn"
```

Also avoid temporarily wiring QA nodes into `Main.tscn`; if a crash happens mid-run, it increases cleanup risk.

## Manual Gate For First Quest
The first quest should only be marked passed after a human viewport run confirms:

1. New Memory works.
2. Opening intro plays once.
3. Mira starts Lost Token quest.
4. Quest objective points to Cabinet 07.
5. Cabinet 07 launches Rockbyte Duel.
6. Rockbyte Duel can be lost, retried, and won.
7. Lost Token recovery persists through save/load.
8. Mira completes the quest.
9. Completion persists through save/load.
10. Objective points to Staff Door.

## Maintainability Rules
- Keep save/load state checks in `GameState` and `SaveManager` easy to inspect.
- Keep transient scenes such as minigames restoring to ArcadeHub unless a specific safe restore path exists.
- Keep QA documentation honest: static review, headless smoke, and live playthrough are different results.
- Keep temporary generated files in `tmp/`, and do not rely on them for committed project behavior.
