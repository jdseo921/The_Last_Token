# MINIGAME_ANIMATION_GUIDE.md

## Purpose
This guide defines a lightweight animation vocabulary for future staged minigames in The Last Token. Animation should add presence and clarity without requiring final sprite sheets or complex systems.

## Animation Scope
- MVP animation should be simple.
- Idle animations can be bobbing, blinking, flickering, breathing, or tiny screen pulses.
- Action animations can be short tweens, visibility changes, small particle placeholders, or sprite frame changes.
- Result animations can be a panel reveal, flash, screen shake-lite, or prop state change.
- Final sprite sheets are optional, not required.

## Timing Guidelines
- Idle loops: slow and subtle, usually `1.0` to `3.0` seconds.
- Action beats: short, usually `0.15` to `0.6` seconds.
- Result reveal: readable, usually `0.4` to `1.0` seconds.
- Avoid long unskippable sequences.

## Actor Idle Examples

### player
- subtle breathing bob
- two-frame idle
- small head turn if future frames exist
- default removal style: `carry`

### human_npc
- breathing bob
- blink frame
- tiny posture shift
- default removal style: `carry`

### machine
- screen flicker
- light pulse
- scanline shimmer
- brief glitch flash
- no walking or carrying motions
- default removal style: `digital_crumble`

### terminal
- text cursor blink
- indicator light pulse
- panel glow
- no physical movement
- default removal style: `digital_crumble`

### ghost
- alpha flicker
- small vertical drift
- slight distortion pulse
- semi-transparent placeholder if no sprite exists
- default removal style: `vanish`

### object_npc
- wobble
- glow pulse
- subtle mechanical twitch
- no walking
- default removal style: `shake`

## Actor Style Rules
- `player`: natural reach/carry actions, small idle bob, success bob, failure shake.
- `human_npc`: similar to player, with reach/carry actions, idle bob or blink, and simple success/failure gestures.
- `ghost`: flicker plus reach, slight float idle, semi-transparent placeholder.
- `machine`: no walking/carrying; use flicker, glitch, beam-like pulses, digital crumble, and small screen pulses.
- `terminal`: screen flicker, text flash, no physical movement.
- `object_npc`: subtle bounce or shake, no walking.

Staged minigames should ask `MinigameStage.get_removal_style_for_actor(actor_id)` when choosing prop removal effects. The actor itself owns the mapping through `get_removal_style_for_actor()`:

| Actor type | Removal style |
| --- | --- |
| `player` | `carry` |
| `human_npc` | `carry` |
| `ghost` | `vanish` |
| `machine` | `digital_crumble` |
| `terminal` | `digital_crumble` |
| `object_npc` | `shake` |

## Action Animation Examples

### Player Removes Rock
1. player actor leans toward center
2. selected rock flashes
3. rock moves slightly or disappears
4. player returns to idle

### Human NPC Removes Rock
1. NPC reaches toward prop
2. prop blinks
3. prop hides or dims
4. NPC returns to idle

### Machine Removes Rock
1. machine screen flashes
2. selected rock flickers
3. rock disappears through digital crumble placeholder
4. status text updates

### Terminal Triggers Lights
1. terminal light turns on
2. switch or door prop pulses
3. result state appears

### Ghost Acts
1. ghost flickers brighter
2. target prop jitters
3. prop changes state
4. ghost fades back to idle alpha

## Prop Animation Examples
- rock hide/show
- rock dim when removed
- switch off/on glow
- door locked/open offset
- score digit flicker
- token flash
- CRT overlay pulse

## Placeholder Effects
Use these before final art:
- `ColorRect` flash
- `Polygon2D` shape shift
- alpha flicker
- scale pulse
- small position tween
- label text swap
- simple particle-like blocks if already cheap to add

Do not build heavy particle systems for the MVP.

## Result Animation Examples
- win panel slides in
- loss panel flickers in
- story payoff text types in
- cabinet frame flashes once
- background pulse fades out

Result animations must never obscure the actual result text.

## Implementation Guidance
- Prefer reusable helper scripts such as future `MinigameActor`, `MinigameProp`, and `MinigameActionQueue`.
- Keep minigame rule scripts focused on rules.
- Trigger presentation with high-level calls like `stage.play_player_action(choice)`.
- Allow actions to complete quickly.
- Provide instant fallback if a node or asset is missing.

## Rockbyte Duel Animation Plan
- Player actor idles on the left.
- Cabinet 07 idles on the right with screen flicker.
- Two rock piles sit in the center.
- Player action: reach/carry motion toward selected pile.
- Cabinet action: digital crumble/glitch removes rock.
- Win result: Lost Token payoff text appears with a brief cabinet flash.
- Loss result: Retry text flickers in.

## Sync Door Animation Plan
- Player actor stands near two switches.
- Door/system actor sits opposite or behind the door.
- Switch props light up while active.
- Door prop slides or brightens on success.
- Terminal/system lights pulse while both switches sync.
- Success result tells the player to return and enter the Staff Room.

## Review Checklist
- Animation improves readability.
- No animation is required to understand the rules.
- No final sprite sheet is required.
- Missing art falls back to shape/text animation.
- Input and result buttons remain responsive.
- Effects do not hide instructions, counts, switches, or result text.
