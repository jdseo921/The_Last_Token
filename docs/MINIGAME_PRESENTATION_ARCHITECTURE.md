# MINIGAME_PRESENTATION_ARCHITECTURE.md

## Purpose
This document defines the future staged presentation architecture for The Last Token minigames. The current minigames are still allowed to be simple, readable UI scenes. Future upgrades should make each minigame feel like a detailed haunted arcade screen without tangling animation code into gameplay rules.

## Core Principles
- Game logic and presentation must remain separate.
- Minigame scripts own rules, input decisions, win/loss checks, and `GameState` changes.
- Presentation scripts own actor movement, prop animation, backgrounds, effects, idle loops, and result staging.
- Art assets are optional. Placeholder visuals must work if assets are missing.
- Every staged minigame must remain playable with keyboard/mouse and no final art.
- Avoid one-off animation code inside every minigame script.
- Use reusable components so Rockbyte Duel, Sync Door, and future optional minigames share presentation language.

## Recommended Scene Shape
Future staged minigames should build on the screen template style:

```text
MinigameScene
  BackgroundLayer
  CabinetFrameLayer
  StageRoot
    MinigameStage
      Actors
      Props
      Effects
  InstructionPanel
  StatusPanel
  MinigameResultPanel
  ButtonArea
```

The existing `MinigameScreenTemplate.tscn` is a basic screen layout. A future staged scene can extend it with `StageRoot`, actors, props, and queued presentation actions.

## Reusable Concepts

### MinigameStage
Owns the staged visual space for a minigame.

Responsibilities:
- holds actor, prop, and effect nodes
- exposes named positions such as `player_left`, `machine_right`, `center_props`
- starts/stops idle presentation effects
- receives presentation events from the minigame logic script
- never decides game rules

Example events:
- `show_intro()`
- `play_player_action("take_left")`
- `play_machine_action("take_both")`
- `show_success()`
- `show_failure()`

### MinigameActor
Represents a visible participant or character-like object.

Actor types:
- `player`
- `human_npc`
- `machine`
- `terminal`
- `ghost`
- `object_npc`

Responsibilities:
- safe optional sprite loading
- placeholder shape fallback
- idle loop selection
- action animation playback
- facing/pose state if needed

Actors should not change score, flags, or puzzle state.

### MinigameProp
Represents game objects such as rocks, switches, doors, score digits, tokens, panels, or light strips.

Responsibilities:
- show/hide prop states
- play small prop effects
- update visual count/state from logic
- preserve readable fallback shapes

Examples:
- rock block visible/empty
- switch off/on
- door locked/open
- score digit broken/restored

### MinigameActionQueue
Runs short presentation actions in order so logic can trigger animation without becoming animation code.

Responsibilities:
- queue simple tweens and visibility changes
- avoid overlapping important actions
- emit a finished signal when a sequence completes
- support instant completion or skip if needed

Example action sequence:
1. player actor leans toward rock pile
2. selected rock flashes
3. rock hides
4. player returns to idle
5. status text updates

### MinigameResultPanel
Displays win/loss/story payoff text in a consistent way.

Responsibilities:
- show result title and body text
- keep text readable without art
- provide clear exit/retry affordance
- optionally request a small result animation from the stage

Result panels should not decide whether the player won; they only display the result supplied by the minigame logic.

## Communication Between Logic And Presentation
The minigame logic script should call presentation methods after state changes.

Example flow:

```gdscript
func _take_player_turn(choice: String) -> void:
    _apply_rule_change(choice)
    stage.play_player_action(choice)
    _refresh_ui()
```

Keep presentation calls descriptive and high-level. Avoid direct tween setup in the rule code.

## Optional Asset Safety
Every reusable presentation component should support:
- missing sprite texture
- missing background texture
- missing frame texture
- missing effect texture
- no final sprite sheets

Fallbacks can be:
- ColorRect blocks
- Polygon2D shapes
- Labels
- simple panels
- subtle ColorRect overlays

Missing art must never block play.

## Rockbyte Duel Example
Future staged presentation:
- player actor on the left
- Cabinet 07 machine actor on the right
- two rock piles in the center
- player removes a rock with a reach/carry animation
- Cabinet 07 removes rock with a digital crumble/glitch effect
- status panel shows turn and move feedback
- result panel shows Lost Token payoff on win

Logic remains unchanged:
- left/right pile counts
- valid moves
- cabinet move selection
- win/loss condition
- `GameState.rockbyte_duel_completed`
- `GameState.collect_lost_token()`

## Sync Door Example
Future staged presentation:
- player actor near the switches
- door/system actor on the opposite side
- two switch props that light up when active
- door prop that animates from locked to open on success
- terminal lights or text pulse during active windows
- result panel tells player to return and enter the Staff Room

Logic remains unchanged:
- switch timers
- both switches active success condition
- `GameState.story_puzzle_completed`
- `GameState.unlock_staff_room()`

## What Not To Do
- Do not add minigame-specific animation systems directly into every rules script.
- Do not make final art required for play.
- Do not hide instructions behind effects.
- Do not change puzzle difficulty during presentation work.
- Do not let staged animations delay required input for too long.
- Do not add new content as part of a presentation architecture pass.

## Manual Review Checklist
- Can the minigame run with no art assets?
- Are instructions readable before and after presentation changes?
- Does every action have visible feedback?
- Does keyboard/mouse input still work?
- Does result text remain visible?
- Are game rules and `GameState` changes still owned by the minigame logic script?
