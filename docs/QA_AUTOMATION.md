# QA_AUTOMATION.md

## Purpose
This project runs an automated regression suite in headless Godot, but full gameplay QA still needs a human viewport pass. Headless checks are not proof that movement, focus, dialogue timing, collision, save menu interaction, or minigame feel has passed.

## Primary entry point

```powershell
pwsh tools/RunRegressionSuite.ps1
```

`tools/RunRegressionSuite.ps1` is the maintained validation runner. It:

1. Runs an editor-wide parse (`--headless --editor ... --quit`).
2. Boots `res://scenes/main/Main.tscn` for two seconds.
3. Runs 31 checks from `scripts/qa/` sequentially, each as its own `--script` launch.

It does not trust exit codes alone. Every log is scanned for `SCRIPT ERROR: Parse Error`, `SCRIPT ERROR: Compile Error`, `Failed to load script`, and `Failed to instantiate an autoload`, so a silent compile failure still fails the run. Each check writes its own log under `tmp/qa/<timestamp>/`, and a failure prints the offending log path.

Pass `-GodotExe` if the Godot 4.7 console executable is not at `C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe` or under `%USERPROFILE%\Downloads\`.

For scene-boot-only checks there is also `tools/RunGodotSmoke.ps1`, which opens the project and boots nine key scenes with per-run temporary log files.

## What the suite covers

`scripts/qa/` holds 33 checks plus `MinigameTestCatalog.gd`, a shared screen inventory that pause, layout, and UI-architecture coverage all read from.

Broadly, the suite covers:

- Whole-game sanity: title boots and is interactive, every `MapTransition` target scene and spawn marker exists in both directions, every shipped dialogue line fits the real DialogueBox rect, save/summary/reload round-trips, corrupt saves fail safely, every music context resolves to an existing stream (`GameSanityAudit.gd`).
- Route and quest integrity (`RequiredRouteStateSmoke.gd`, `QuestFlowAudit.gd`, `ScenePathSmoke.gd`, `StorylineSanitySmoke.gd`, `LoreConsistencySmoke.gd`).
- UI and layout (`MinigameLayoutAudit.gd`, `MinigameUiArchitectureSmoke.gd`, `MinigamePauseCoverageSmoke.gd`, `PauseMenuSmoke.gd`, `PresentationConsistencySmoke.gd`, `SaveSlotDisplaySmoke.gd`).
- Dialogue data and presentation (`DialoguePoolSmoke.gd`, `DialoguePortraitSmoke.gd`, `DialogueStyleSmoke.gd`, `DialogueHandoffSmoke.gd`, `PostMinigameDialogueSmoke.gd`).
- Descent-cue correctness in Static Service Depths (`StaticDescentCueSmoke.gd`): every arrow sits on a shelf and points at a drop that lands on another shelf. That course authors no thresholds, so a cue aimed at a gap costs the player the whole descent.
- Per-stage regressions (`HybridExplorerSmoke.gd`, `CircuitSodaSmoke.gd`, `TruthFilterSmoke.gd`, `BrokenHighScoreSmoke.gd`, `ArchiveHistorySmoke.gd`, `HallwayFlowSmoke.gd`, `OpeningArrivalSmoke.gd`, `PrizeEchoHandoffSmoke.gd`, `CircuitSodaStoryHandoffSmoke.gd`, `ClosingShiftEchoesSmoke.gd`, `UnknownVoiceMusicDuckSmoke.gd`, `DebugDiagnosticsSmoke.gd`, `NavigationUiSmoke.gd`).

Two checks exist but are not wired into the runner, and are invoked directly:

- `NavigationPrecisionSmoke.gd` — asserts the exact navigation hint per quest sub-stage and that it hands off when the next flag flips.
- `MaintenanceRouteSmoke.gd` — guards the simplified maintenance branch and a collision-free path to the service door.

## Automation boundary

Automated checks are good proof for:

- Project import/open sanity.
- Main scene launch sanity.
- Direct scene parse/load sanity.
- Missing script/resource errors.
- GDScript parser and compile errors.
- Scene path and spawn marker existence.
- Route flag, quest id, story phase, and progress-count correctness.
- Text fitting its authored rectangle.
- Save/load data round-trips and corrupt-file rejection.

Do not use automated checks as the only proof for:

- Dialogue input timing.
- Player movement and collision feel.
- Interaction range and prompts.
- Save/load menu focus and slot selection.
- Rockbyte Duel lose/retry/win feel.
- Quest notice readability.
- Full route acceptance.

Report a green run as `headless suite passed`, not as `live playthrough passed`.

## Historical note: the `user://logs` crash

Earlier in development, temporary QA scenes, direct `--script` state runners, and parallel scene smoke launches repeatedly crashed while opening `user://logs/...`:

```text
ERROR: Failed to open 'user://logs/godot...log'.
CrashHandlerException: Program crashed with signal 11
```

This document previously advised avoiding `--script` runners entirely. That advice predates the regression suite, which runs 31 of them. Both runners give every launch a unique `--log-file` and pass `--disable-crash-handler`, and the suite runs strictly sequentially.

Two constraints from that period still hold:

- Do not run multiple Godot headless commands at the same time in this workspace. Parallel launches can collide in the same `user://logs` location.
- Do not temporarily wire QA nodes into `Main.tscn`. A crash mid-run increases cleanup risk.

## Individual smoke commands

Run these only as smoke checks, and never in parallel:

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_project.log" --quit
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_main.log" --scene "res://scenes/main/Main.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_hub.log" --scene "res://scenes/arcade/ArcadeHub.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --disable-crash-handler --path "." --log-file "$env:TEMP\the_last_token_smoke_rockbyte.log" --scene "res://scenes/minigames/RockbyteDuel.tscn" --quit-after 2
```

To run a single QA check, swap the scene argument for `--script "res://scripts/qa/<Check>.gd"`.

## Route helpers in detail

### ScenePathSmoke
Checks that every required route scene path still exists.

Expected result:

- Prints each required scene as `OK`.
- Exits `0` when all scenes exist.
- Exits `1` and prints `MISSING` for any broken path.

### RequiredRouteStateSmoke
Simulates the required route flag by flag and asserts the current quest id, story phase, Memory Signal, and required progress count at every beat, from New Memory through post-reveal roam and the witness route.

Expected result:

- Main progress advances from `0/12` to `12/12`.
- Quest IDs match the next required objective.
- Story phase and Memory Signal match the simulated route state.
- Prints `RequiredRouteStateSmoke: PASS` and exits `0`.
- Exits `1` if a quest id, story phase, signal, or progress count does not match.

Use it to catch missing flags, bad progress counts, and wrong quest IDs. It is not acceptance for movement, dialogue timing, scene transitions, minigame playability, save/load behaviour, or the full live route.

### DialoguePoolSmoke
Checks that `DialoguePool.gd` can load sample JSON dialogue, return first/random/sequential sets, and fall back safely for missing files or keys.

Expected result:

- Prints `DialoguePoolSmoke: PASS`.
- Exits `0` when sample data and fallbacks work.
- Exits `1` if a required sample set cannot be loaded or fallback behaviour breaks.

## Manual gate

The manual playthrough in `TEST_PLAN.md` remains the only proof for feel and readability. For the first quest specifically, confirm in a viewport run:

1. New Memory works.
2. Opening intro plays once.
3. Mira starts the Lost Token quest.
4. Quest objective points to Cabinet 07.
5. Cabinet 07 launches Rockbyte Duel.
6. Rockbyte Duel can be lost, retried, and won.
7. Lost Token recovery persists through save/load.
8. Mira completes the quest.
9. Completion persists through save/load.
10. Objective points to the next required beat.

## Maintainability rules
- Keep save/load state checks in `GameState` and `SaveManager` easy to inspect.
- Keep transient scenes such as minigames restoring to their parent room unless a specific safe restore path exists.
- Add a new playable screen to `scripts/qa/MinigameTestCatalog.gd` once; pause, layout, and UI architecture coverage inherit it.
- Add a new check to the `$tests` array in `tools/RunRegressionSuite.ps1`, or it will not run.
- Keep QA documentation honest: static review, headless suite, and live playthrough are different results.
- Keep temporary generated files in `tmp/`, and do not rely on them for committed project behaviour.
