# MINIGAME_ASSET_MANIFEST.md

## Purpose
This manifest tracks planned assets for staged animated minigames. These files are not required yet. Current minigames must continue to use placeholder visuals when any asset is missing.

## Folder Structure

```text
scenes/minigames/common/
scripts/minigames/common/
assets/art/minigames/common/
assets/art/minigames/common/actors/
assets/art/minigames/common/props/
assets/art/minigames/common/effects/
assets/art/minigames/common/backgrounds/
assets/art/minigames/rockbyte_duel/
assets/art/minigames/rockbyte_duel/backgrounds/
assets/art/minigames/rockbyte_duel/props/
assets/art/minigames/rockbyte_duel/effects/
assets/art/minigames/sync_door/
assets/art/minigames/sync_door/backgrounds/
assets/art/minigames/sync_door/props/
assets/art/minigames/sync_door/effects/
```

## Rules
- Do not require these files to exist yet.
- Use placeholder visuals if they are missing.
- Keep all future file paths documented.
- Do not modify current minigame behavior just to add assets.
- Do not generate images until a dedicated visual asset task asks for it.
- Art should follow `ART_STYLE.md`, `ASSET_PIPELINE.md`, and `MINIGAME_ANIMATION_GUIDE.md`.

## Common Actor Assets

| Asset Key | File Path | Purpose | Status |
|---|---|---|---|
| `player_minigame_idle` | `res://assets/art/minigames/common/actors/player_minigame_idle.png` | Player idle actor for staged minigames. | Planned |
| `player_minigame_reach` | `res://assets/art/minigames/common/actors/player_minigame_reach.png` | Player reach/action pose. | Planned |
| `player_minigame_carry` | `res://assets/art/minigames/common/actors/player_minigame_carry.png` | Player carry/action pose. | Planned |
| `cabinet07_idle` | `res://assets/art/minigames/common/actors/cabinet07_idle.png` | Cabinet 07 machine idle actor. | Planned |
| `cabinet07_glitch` | `res://assets/art/minigames/common/actors/cabinet07_glitch.png` | Cabinet 07 glitch/action pose or frame. | Planned |
| `npc_generic_idle` | `res://assets/art/minigames/common/actors/npc_generic_idle.png` | Generic human NPC idle actor. | Planned |
| `npc_generic_reach` | `res://assets/art/minigames/common/actors/npc_generic_reach.png` | Generic human NPC reach/action pose. | Planned |

## Rockbyte Duel Assets

| Asset Key | File Path | Purpose | Status |
|---|---|---|---|
| `rockbyte_background` | `res://assets/art/minigames/rockbyte_duel/backgrounds/rockbyte_background.png` | Dedicated Rockbyte Duel background. | Planned |
| `rock_pile_left` | `res://assets/art/minigames/rockbyte_duel/props/rock_pile_left.png` | Left pile visual. | Planned |
| `rock_pile_right` | `res://assets/art/minigames/rockbyte_duel/props/rock_pile_right.png` | Right pile visual. | Planned |
| `rock_single` | `res://assets/art/minigames/rockbyte_duel/props/rock_single.png` | Single rock/token visual for count displays. | Planned |
| `rock_crumble_effect` | `res://assets/art/minigames/rockbyte_duel/effects/rock_crumble_effect.png` | Physical crumble/remove effect. | Planned |
| `digital_crumble_effect` | `res://assets/art/minigames/rockbyte_duel/effects/digital_crumble_effect.png` | Cabinet 07 digital remove effect. | Planned |
| `cabinet_frame_rockbyte` | `res://assets/art/minigames/rockbyte_duel/backgrounds/cabinet_frame_rockbyte.png` | Rockbyte Duel cabinet frame/bezel. | Planned |

## Sync Door Assets

| Asset Key | File Path | Purpose | Status |
|---|---|---|---|
| `sync_door_background` | `res://assets/art/minigames/sync_door/backgrounds/sync_door_background.png` | Dedicated Sync Door background. | Planned |
| `switch_a_off` | `res://assets/art/minigames/sync_door/props/switch_a_off.png` | Switch A inactive state. | Planned |
| `switch_a_on` | `res://assets/art/minigames/sync_door/props/switch_a_on.png` | Switch A active state. | Planned |
| `switch_b_off` | `res://assets/art/minigames/sync_door/props/switch_b_off.png` | Switch B inactive state. | Planned |
| `switch_b_on` | `res://assets/art/minigames/sync_door/props/switch_b_on.png` | Switch B active state. | Planned |
| `sync_door_locked` | `res://assets/art/minigames/sync_door/props/sync_door_locked.png` | Locked Staff Door state. | Planned |
| `sync_door_open` | `res://assets/art/minigames/sync_door/props/sync_door_open.png` | Open Staff Door state. | Planned |

## Integration Notes
- Future scripts should load these paths safely with `ResourceLoader.exists()` or a helper such as `AssetPaths.load_texture_or_null()`.
- Missing staged-minigame art should leave shape/text placeholders visible.
- Do not replace working UI instructions with art-only instructions.
- Do not change Rockbyte Duel or Sync Door rules during asset integration.
