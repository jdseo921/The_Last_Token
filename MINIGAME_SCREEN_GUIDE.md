# MINIGAME_SCREEN_GUIDE.md

## Purpose
This guide defines how future minigame screens should be built for The Last Token. The current minigames should not be replaced automatically; use `MinigameScreenTemplate.tscn` when a future pass intentionally upgrades a minigame scene. All new boxed copy must also follow [the minigame UI contract](docs/MINIGAME_UI.md).

## Core Rule
Every minigame gets its own scene. A minigame should feel like a distinct arcade cabinet screen with its own visual identity, but it must still be readable and playable without final art.

## Standard Structure
Use this structure as the baseline:

```text
MinigameScene
  BackgroundLayer
  CabinetFrameLayer
  TitleLabel
  InstructionPanel
  GameArea
  StatusPanel
  ResultPanel
  ExitButton
```

## Screen Roles
- `BackgroundLayer`: full-screen background texture or placeholder color.
- `CabinetFrameLayer`: cabinet bezel/frame art or placeholder panel.
- `TitleLabel`: minigame title.
- `InstructionPanel`: clear rules and player-facing instructions.
- `GameArea`: buttons, score displays, piles, switches, or other gameplay widgets.
- `StatusPanel`: current turn/state/hint text.
- `ResultPanel`: win/loss/story payoff text.
- `ExitButton`: return to ArcadeHub, or retry/exit if the minigame uses that flow.

## Visual Requirements
- Every minigame should have a detailed screen identity eventually.
- Every minigame must have clear instructions.
- Every minigame must have story payoff text when completed.
- Every minigame must run without final art.
- Missing background or frame art should show placeholder panels, not crash.
- CRT/glitch overlays should be subtle and must not hide rules or result text.

## Asset Paths
Future minigame art should use:
- `assets/art/minigames/rockbyte_duel/`
- `assets/art/minigames/sync_door/`
- `assets/art/minigames/broken_high_score/`
- `assets/art/ui/crt/`

Optional template exports:
- `background_texture_path`
- `frame_texture_path`

These paths can point to future PNGs. If the files are missing, the template keeps placeholders visible.

## Gameplay Safety
- Do not change story flags during a visual upgrade unless the task explicitly requires it.
- Do not change puzzle difficulty during a screen-art pass.
- Keep exit behavior obvious.
- Keep result text visible even if audio is missing.
- Test the minigame with no final art before testing with imported art.

## Manual Check
For each upgraded minigame:
1. Open its scene directly in Godot.
2. Confirm placeholder mode displays cleanly.
3. Confirm instructions are readable.
4. Confirm gameplay widgets fit inside `GameArea`.
5. Confirm status text updates are readable.
6. Confirm result text appears clearly.
7. Confirm exit/retry buttons are reachable by mouse and keyboard focus.
