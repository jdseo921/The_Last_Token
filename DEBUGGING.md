# Debugging The Last Token

Debug builds create a structured session trace in `user://logs`. Set `THE_LAST_TOKEN_DEBUG=1` to enable the same trace in another local build.

## During play

- **F9** prints a complete route snapshot: scene, active quest, story phase, progress, memory signal, pending spawn, return point, and blocking UI state.
- **F8** prints the latest 30 structured events and the session-log path.
- Scene transitions, minigame return points, interactions, dialogue speakers/portraits, music changes, unknown-voice ducking, saves, loads, and route changes are recorded automatically.
- Impossible route combinations produce `invalid_route_state` errors with the violated prerequisite.
- Text that cannot fit its UI rectangle at the minimum allowed font size produces a `text_did_not_fit` warning with the node path, available size, and offending copy.

## Full regression suite

From PowerShell in the project root:

```powershell
pwsh tools/RunRegressionSuite.ps1
```

The runner executes all focused story, dialogue, navigation, hallway, save, audio, minigame, adventure, pause, layout, and scene checks. Each test receives its own persistent log under `tmp/qa/<timestamp>/`, and the failing log path is printed immediately.

## Useful event categories

- `story`: quest/phase changes and invalid progression combinations
- `scene`: transition requests, minigame return capture, and return failures
- `interaction`: exact interactable, handler, and player node paths
- `dialogue`: line count, speaker, portrait path, and antagonist state
- `audio`: active track, context mapping, fades, and `???` ducking
- `save`: rejected saves/loads, normalized resume scenes, and safe spawns
- `ui`: text-fit failures with the responsible control path

Old-save migration keys are deliberately retained in `GameState.gd`. A retired name found only inside compatibility loading is not a live route dependency.
