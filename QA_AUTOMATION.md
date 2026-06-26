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
- Required route scene path existence.
- Required route flag/progress smoke checks.

Do not use automated checks as the only proof for:

- Dialogue input timing.
- Player movement and collision.
- Interaction range and prompts.
- Save/load menu focus and slot selection.
- Rockbyte Duel lose/retry/win feel.
- Quest notice readability.
- Full first-quest acceptance.

## Known Codex/Godot Issue
In this workspace, Godot 4.7 console can launch normal project scenes headlessly, but temporary QA scenes, direct `--script` state runners, and parallel scene smoke launches have repeatedly crashed while trying to open `user://logs/...`.

Observed symptom:

```text
ERROR: Failed to open 'user://logs/godot...log'.
CrashHandlerException: Program crashed with signal 11
```

Because of this, Codex should avoid temporary Godot state-runner scenes/scripts that drive save/load or scene changes. Those checks may crash the local console runner even when the actual game scenes still launch.

Also avoid running multiple Godot headless commands at the same time in this workspace. Parallel launches can collide in the same `user://logs` location and produce a native Windows application error. Run Godot smokes sequentially, with a unique `--log-file` per launch when possible.

## Recommended Codex Smoke Commands
Preferred local smoke runner:

```powershell
.\tools\RunGodotSmoke.ps1
```

This runs project and scene smokes sequentially, uses unique temporary `--log-file` paths, and disables the crash handler to reduce Windows application error popups if the engine crashes.

If running individual commands manually, run these only as smoke checks and do not run them in parallel:

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_project.log" --quit
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_main.log" --scene "res://scenes/main/Main.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_hub.log" --scene "res://scenes/arcade/ArcadeHub.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_rockbyte.log" --scene "res://scenes/minigames/RockbyteDuel.tscn" --quit-after 2
```

If these pass, report them as `headless smoke passed`, not as `live playthrough passed`.

## Expanded Required Route QA Helpers
These helpers support the expanded required route. They are not proof that the game feels good, that interactions are reachable, or that a player can complete the route.

### ScenePathSmoke
Checks that every required route scene path still exists.

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_scene_path_smoke.log" --script "res://scripts/qa/ScenePathSmoke.gd"
```

Expected result:

- Prints each required scene as `OK`.
- Exits with code `0` when all scenes exist.
- Exits with code `1` and prints `MISSING` for any broken path.

### RequiredRouteStateSmoke
Simulates required route flags in order and prints:

- Current quest id.
- Story phase.
- Memory Signal.
- Required progress count.

It checks this sequence:

- New Memory.
- Rockbyte complete.
- Lost Token returned.
- Truth Filter complete.
- Circuit Soda complete.
- Lost Shift File complete.
- Static Service Run complete.
- Maintenance Sync complete.
- Security Tape complete.
- Final Night Walk complete.
- Memory Echo complete.
- Reveal complete.

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_required_route_state_smoke.log" --script "res://scripts/qa/RequiredRouteStateSmoke.gd"
```

Expected result:

- Main progress advances from `0/10` to `10/10`.
- Quest IDs match the next required objective.
- Story phase and Memory Signal match the simulated route state.
- Exits with code `0` when all checks pass.
- Exits with code `1` if a quest id, story phase, signal, or progress count does not match.

Use this helper to catch missing flags, bad progress counts, and wrong quest IDs. Do not use it as acceptance for movement, dialogue timing, scene transitions, minigame playability, save/load behavior, or the full live route.

### DialoguePoolSmoke
Checks that `DialoguePool.gd` can load sample JSON dialogue, return first/random/sequential sets, and fall back safely for missing files or keys.

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_dialogue_pool_smoke.log" --script "res://scripts/qa/DialoguePoolSmoke.gd"
```

Expected result:

- Prints `DialoguePoolSmoke: PASS`.
- Exits with code `0` when sample data and fallbacks work.
- Exits with code `1` if a required sample set cannot be loaded or fallback behavior breaks.

## Commands To Avoid In This Workspace
Avoid these until the `user://logs` crash is solved:

```powershell
godot --headless --path "." --script "res://tmp/SomeRunner.gd"
godot --headless --path "." "res://tmp/TemporaryQAScene.tscn"
```

Also avoid temporarily wiring QA nodes into `Main.tscn`; if a crash happens mid-run, it increases cleanup risk.

Avoid:

```powershell
# Do not use multi_tool_use.parallel for Godot scene smokes in this workspace.
```

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
