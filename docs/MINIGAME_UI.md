# Minigame UI contract

Minigame UI has one source of truth: `scripts/ui/MinigameUI.gd`. It defines the readable fonts, text roles, padding, font-size floors, measurement and shared panel styling.

## Building a new screen

1. Add `scenes/ui/PauseMenu.tscn` as `PauseMenu` and set `is_minigame_context = true`. This both supplies Esc pause and installs `MinigameUILayoutGuard` on the minigame root.
2. Prefer `scenes/ui/MinigameTextBox.tscn` for instructions, status, rules and completion copy. Size the outer panel; its inner margins, wrapping, centering and font fitting are automatic.
3. Change component copy with `set_text()`. For a code-built label, call `MinigameUI.configure_label()` once and `MinigameUI.fit_label()` after changing its text.
4. Add the playable scene to `MinigameTestCatalog.PLAYABLE_SCENES`. Pause, layout and architecture audits will then cover it automatically.

## Text roles

- `TITLE`: Press Start title face, 12–20 px.
- `HEADING`: readable pixel body face, 13–18 px.
- `BODY`: instructions and prose, 11–16 px.
- `COMPACT`: dense legends, 10–13 px.
- `HUD`: counters and status, 10–14 px.

The maximum is tried first. Text shrinks only as far as its role's readable floor. If it still cannot fit, `minigame_ui_fit_ok` becomes false so QA fails instead of silently accepting unreadable copy.

## Runtime guard

The guard checks the current minigame UI after gameplay scripts update. It caches text-and-rectangle signatures, so unchanged labels only pay a cheap comparison. Wrapped or explicit multiline copy is centered horizontally and vertically as one block. Button captions are fitted without moving their authored controls.

World-space `Node2D` labels, gameplay surfaces named `TileGrid` or `ScrollingViewport`, and the `PauseMenu`, `QuestNotice`, `SettingsMenu`, `DialogueBox` and `ChoiceBox` branches are excluded. For another deliberate gameplay-surface exception, set node metadata `minigame_ui_ignore = true`.

## Regression commands

```powershell
& 'C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path '.' --script 'res://scripts/qa/MinigameUiArchitectureSmoke.gd'
& 'C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path '.' --script 'res://scripts/qa/MinigameLayoutAudit.gd'
& 'C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path '.' --script 'res://scripts/qa/MinigamePauseCoverageSmoke.gd'
```
