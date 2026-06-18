# STAGED_MINIGAME_CONVERSION_GUIDE.md

## Purpose
Use this guide when converting an existing minigame into a staged actor scene. The goal is better visual feedback and atmosphere while preserving the playable MVP loop.

This is a presentation pass only. Do not require final art before gameplay works. Do not add new minigames, new rules, new endings, or new story branches while converting presentation.

## 1. Required Scene Structure
Use the existing minigame scene as the owner of rules, UI, and result flow. Add a staged presentation area inside it:

```text
MinigameScene
  BackgroundLayer
  CabinetFrameLayer
  TitleLabel
  InstructionPanel
  GameArea
    Stage
  StatusPanel
  ButtonArea
  EffectsLayer
```

The `Stage` should instance `res://scenes/minigames/common/MinigameStage.tscn`.

`MinigameStage` already provides:
- `BackgroundLayer`
- `PropLayer`
- `ActorLayer`
- `EffectsLayer`
- `UILayer`

Keep instructions, counts, result text, retry buttons, and exit buttons outside the stage unless the minigame specifically needs them inside the staged view.

## 2. Required Scripts
Use these common scripts instead of writing one-off animation systems:

| Script | Purpose |
| --- | --- |
| `scripts/minigames/common/MinigameStage.gd` | Owns actors, props, effects, and stage positions. |
| `scripts/minigames/common/MinigameActor.gd` | Displays player, NPCs, machines, terminals, ghosts, or object NPCs. |
| `scripts/minigames/common/MinigameProp.gd` | Base prop behavior for switches, doors, panels, tokens, and generic objects. |
| `scripts/minigames/common/RockPileProp.gd` | Counted rock pile presentation. |
| `scripts/minigames/common/MinigameActionQueue.gd` | Plays small visual action sequences in order. |
| `scripts/minigames/common/MinigameConfigLoader.gd` | Loads optional participant config JSON. |

Minigame-specific scripts still own rules, input, win/loss checks, and `GameState` changes.

## 3. How To Choose Participants
Define participants in a config file when useful:

```json
{
  "minigame_id": "example_minigame",
  "title": "EXAMPLE MINIGAME",
  "background": "res://assets/art/minigames/example/backgrounds/example_background.png",
  "participants": [
    {
      "actor_id": "player",
      "display_name": "Player",
      "actor_type": "player",
      "side": "left"
    },
    {
      "actor_id": "machine01",
      "display_name": "Machine 01",
      "actor_type": "machine",
      "side": "right",
      "idle_flicker_enabled": true
    }
  ]
}
```

Load with:

```gdscript
const CONFIG_LOADER := preload("res://scripts/minigames/common/MinigameConfigLoader.gd")

var config: Dictionary = CONFIG_LOADER.load_config("res://data/minigames/example_config.json")
```

Always keep hardcoded fallback participant data in the minigame script. Missing config must not break the game.

## 4. How Actor Types Affect Animation
Choose the actor type based on how the participant should feel:

| Actor type | Motion style | Removal style |
| --- | --- | --- |
| `player` | reach, carry, idle bob, success bob, failure shake | `carry` |
| `human_npc` | reach, carry, idle bob or blink, simple gestures | `carry` |
| `ghost` | flicker, float, semi-transparent fallback | `vanish` |
| `machine` | screen pulse, glitch, no walking or carrying | `digital_crumble` |
| `terminal` | text flash, screen flicker, no physical movement | `digital_crumble` |
| `object_npc` | bounce, shake, subtle twitch, no walking | `shake` |

When choosing prop removal effects, ask the stage:

```gdscript
var style := str(stage.call("get_removal_style_for_actor", "cabinet07"))
```

This keeps future human, ghost, machine, and terminal versions visually distinct without changing rules.

## 5. How To Add Props
Props should represent game objects, not rules.

Examples:
- rocks
- switches
- doors
- score boards
- tokens
- broken digits
- light strips

Add props through the stage:

```gdscript
var pile := stage.call("add_prop", ROCK_PILE_PROP_SCENE, {
  "prop_id": "left_pile",
  "pile_id": "left_pile",
  "max_rocks": 5,
  "current_rocks": 5,
  "position": Vector2(250, 230)
})
```

The minigame logic should keep the real count or state. The prop shows the visual version and animates changes.

## 6. How To Use MinigameActionQueue
Use `MinigameActionQueue` when a turn needs more than one visual beat.

Basic setup:

```gdscript
const ACTION_QUEUE_SCRIPT := preload("res://scripts/minigames/common/MinigameActionQueue.gd")

var action_queue: Node = ACTION_QUEUE_SCRIPT.new()
add_child(action_queue)
action_queue.call("set_stage", stage)
```

Example sequence:

```gdscript
action_queue.call("clear")
action_queue.call("add_action", {
  "type": "actor_action",
  "actor_id": "player",
  "action": "carry",
  "target_prop_id": "left_pile"
})
action_queue.call("add_action", {
  "type": "prop_action",
  "prop_id": "left_pile",
  "action": "remove_amount",
  "amount": 1,
  "style": "carry"
})
action_queue.call("play")
await Signal(action_queue, "sequence_finished")
```

Useful action types:
- `actor_action`
- `prop_action`
- `wait`
- `status_text`

If an actor or prop is missing, the queue should skip safely and let gameplay continue.

## 7. Keep Logic Separate From Presentation
The minigame script owns:
- input
- legal move checks
- score/count changes
- win/loss checks
- retry/exit behavior
- `GameState` updates

The stage owns:
- actors
- props
- idle motion
- removal animation
- flicker, shake, pulse, and placeholder effects

Good pattern:

```gdscript
_apply_player_move(choice)
await _play_player_move_visual(choice)
_refresh_ui()
_check_result()
```

Avoid changing rules inside actor, prop, or queue scripts. A prop may animate from 5 rocks to 4 rocks, but the minigame script decides that the real count became 4.

## 8. Keep Placeholder Fallbacks Working
Every staged minigame must run without final art.

Required fallback behavior:
- missing background shows placeholder background
- missing actor sprite shows placeholder body and label
- missing prop texture shows simple shapes
- missing config uses hardcoded fallback participants
- missing effect art skips the effect or uses color/scale/tween feedback

Do not block input because an animation asset is missing. Do not hide instructions behind placeholder effects.

## 9. How To Test Staged Minigames
Manual check:
1. Open the minigame scene directly.
2. Confirm instructions are readable.
3. Confirm left/right participants appear.
4. Confirm props appear.
5. Trigger each player action.
6. Confirm action sequence plays once.
7. Confirm counts/status text match the real logic.
8. Confirm win/loss still fires the same `GameState` changes.
9. Confirm retry and exit still work.
10. Temporarily rename the config or art paths and confirm fallback visuals work.

Headless smoke checks:

```powershell
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --path "." "res://scenes/minigames/RockbyteDuel.tscn" --quit-after 2
& "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" --headless --path "." --quit
```

## 10. Avoid Scope Creep
During a staged conversion, do not add:
- new minigames
- new NPCs
- new endings
- new story branches
- new puzzle rules
- combat
- final sprite packs
- complex cutscenes
- long unskippable animations

Keep the pass small: actors, props, readable UI, safe animation, same rules.

## Examples

### Rockbyte Duel
Participants:
- player on the left
- Cabinet 07 on the right

Props:
- left rock pile in the center
- right rock pile in the center

Presentation:
- player carries/removes rocks
- Cabinet 07 flickers and digitally crumbles rocks
- win plays player success and Cabinet 07 machine pulse
- loss plays player failure and Cabinet 07 machine pulse

Rules remain:
- two piles start at 5
- take left, right, or both
- final rock wins
- win sets `GameState.rockbyte_duel_completed`
- win calls `GameState.collect_lost_token()`

### Broken High Score Future Example
Participants:
- player on the left
- Roxy on the right

Props:
- score board in the center
- score tick markers or broken digit props

Presentation:
- player collects score ticks
- score board flickers as digits correct
- Roxy reacts with a human/NPC gesture
- result text reveals restored record information

Rules should remain simple:
- target appears broken
- real target is checked by the minigame script
- completion state is saved by `GameState`

### Sync Door Future Example
Participants:
- player actor near switch system
- door/system actor opposite the player

Props:
- switch A
- switch B
- staff door
- optional terminal light props

Presentation:
- switches light up when active
- door/system actor flickers while checking sync
- door opens or brightens on success
- status text tells the player to return and enter the Staff Room

Rules remain:
- both switches must be active together
- success updates existing progression only
- no new required story branch is added
