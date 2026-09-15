# Act 2 Escalation Plan

## Purpose
This document plans the next story phase after the Lost Token quest. It does not authorize implementation yet.

Act 2 should begin only after the first quest vertical slice passes the live Godot route in `FIRST_QUEST_VERTICAL_SLICE.md`.

## Act 2 Starting Point
Act 2 begins after:
- The player recovers the Lost Token from Cabinet 07.
- The player returns it to Mira.
- Mira completes the first quest.
- The active objective points the player toward the Staff Door or next required machine path.

At this point, the player's Memory Signal changes from `Grounded` to `Uneasy`.

## What Changes After The First Quest
- The arcade should feel more personal, not simply stranger.
- Machines should react as if they recognize a returning profile.
- Human and human-like NPCs should be more casual with the player, creating contrast with the player's confusion.
- Dialogue can refer to missing staff, old shifts, closed-night routines, or records that do not line up.
- Visual effects can become slightly more active: screen flickers, subtle UI distortion, and small lighting changes.
- Guidance should remain clear. Escalation should never obscure objectives or interaction prompts.

## NPC Reactions
Mira:
- Becomes more worried but still gentle.
- Suggests the Staff Door is responding because the token came back.
- Avoids revealing Employee 04 fully.

Gus:
- Treats the situation like another inconvenient closing-shift problem.
- Mentions missing staff casually, as if everyone already knows the story.
- Uses dry humor to push the player forward.

Vendo:
- Becomes more pointed and sarcastic.
- Treats the player like a returning account, stored customer, or misfiled employee profile.
- Can joke about vending records being more reliable than people.

Mr. Byte:
- Becomes colder and more diagnostic.
- Mentions partial profile restoration, incomplete staff directory entries, or contradictory records.
- Should feel like a help terminal that is trying to be useful and failing emotionally.

Cabinet 07:
- Should not remain the main focus after Act 1, but can acknowledge that the token transfer changed the player's profile.
- It should reinforce that the player has more than one record.

## Recommended Second Required Game
Working title: `TRUTH FILTER` / `Lying Cabinets`

This should be the second required puzzle or minigame after the Lost Token quest.

## Story Purpose
The second required game teaches:
- Not every memory statement can be trusted.
- NPCs remember things the player does not.
- Machines may have records that are technically accurate but emotionally misleading.
- The player is being treated less like a customer and more like a restored profile.

The Memory Signal should move from `Uneasy` to `Fractured` after this required game is completed.

## Core Puzzle Concept
The player is shown several short statements from arcade machines, staff notes, or cabinet logs.

The player must identify which statements are true, false, or incomplete.

Example statement types:
- `Mira closed the ticket counter alone.`
- `The missing staff member left before midnight.`
- `Cabinet 07 saved two player records.`
- `The Staff Door only opens for employees.`

The puzzle should avoid lore dumps. Each statement should be short, readable, and tied to visible hub details or prior dialogue.

## What The Puzzle Teaches
Mechanically:
- Observe contradictions.
- Compare machine statements with NPC dialogue.
- Trust context, not just official records.

Narratively:
- The arcade has conflicting memories.
- The player is connected to the missing staff record.
- Machines are not lying in a human way; they are filtering corrupted data.

## Foreshadowing Employee 04
Act 2 may hint at Employee 04 through:
- Partial staff records.
- Blank name fields.
- Machines calling the player `profile`, `signal`, or `returning staff`.
- NPCs almost saying the player's role, then backing off.
- Staff Door messages that become more specific after each major memory recovery.

Do not fully reveal Employee 04 in Act 2. The reveal still belongs to the later Staff Room sequence.

## Route Toward Staff Door / Sync Door
After Lost Token completion:
1. Mira tells the player the Staff Door is responding.
2. Staff Door rejects the player with a clearer partial-staff message.
3. Mr. Byte or Vendo points toward the next cabinet/game.
4. The player completes `Truth Filter`.
5. Memory Signal becomes `Fractured`.
6. Staff Door or Sync Door path becomes the next objective.

## Act 2 Exit Criteria
Before Act 2 is considered ready:
- First quest live gate has passed.
- The second required game has a clear objective and readable rules.
- Completion changes Memory Signal from `Uneasy` to `Fractured`.
- The player understands that records and memories can conflict.
- The route toward Staff Door / Sync Door is clear.
- Save/load preserves Act 2 progress.

## Implementation Note
Act 2 now has a first scaffold:
- Scene: `res://scenes/minigames/TruthFilter.tscn`
- Script: `res://scripts/TruthFilter.gd`
- Hub route: Lost Token returned -> Truth Filter -> Staff Door / Sync Door

This does not mean Act 2 is accepted. Use `ACT_2_ACCEPTANCE.md` for the live route.

## Out Of Scope For This Plan
- New NPCs.
- Extra endings.
- Combat.
- Inventory.
- Optional minigames.
- Final art.
- Staff Room reveal expansion.
