# Expanded Content Plan

## Purpose
This document plans how The Last Token can grow from the current MVP into a 45-60 minute retro arcade mystery without losing scope control.

This is a planning document only. It does not authorize new scenes, new NPCs, new minigames, or gameplay implementation until the current quality gates pass.

## Runtime Target
Target runtime: 45-60 minutes for a player who completes the main route and explores optional secrets.

Approximate pacing:
- Opening and first quest: 8-12 minutes.
- Act 2 puzzle chain: 15-22 minutes.
- Staff Door / Staff Corridor escalation: 8-12 minutes.
- Staff Room reveal and ending: 6-10 minutes.
- Optional secrets and post-reveal roam: 8-15 minutes.

The route should feel like a compact mystery, not a stretched MVP. Every required puzzle must return the player to story with NPC dialogue.

## Scope Rules
- Do not add combat.
- Do not add inventory.
- Do not add extra endings before the main ending is stable.
- Do not add optional content until the required route is playable.
- Do not make Mira the owner of every quest.
- Do not let Cabinet 07 become the only story machine.
- Do not expand maps unless the current map has a clear purpose and a clear exit.

## Main Route
1. Title Menu / New Memory
2. Opening intro
3. ArcadeHub
4. Mira gives the Lost Token quest
5. Cabinet 07 launches Rockbyte Duel
6. Return to Mira
7. Mr. Byte points the player into Truth Filter
8. Vendo owns Circuit Soda puzzle
9. Gus owns Maintenance Sync puzzle
10. Staff Corridor opens
11. Memory Echo sequence
12. Staff Room reveal
13. Ending
14. Post-Reveal Roam / secrets

## Required Quest Chain

| Order | Quest | Owner | Location | Puzzle | Memory Signal | Required |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Lost Token | Mira | ArcadeHub | Rockbyte Duel via Cabinet 07 | Grounded -> Uneasy | Yes |
| 2 | Truth Filter | Mr. Byte | Cabinet Row | Truth Filter | Uneasy -> Fractured | Yes |
| 3 | Circuit Soda | Vendo | Snack Alcove | Signal flow / drink routing puzzle | Fractured, deepens pressure | Yes |
| 4 | Maintenance Sync | Gus | Maintenance Hall | Sync Door / two-signal puzzle | Fractured -> Overloaded | Yes |
| 5 | Memory Echo | Staff Door / Arcade | Staff Corridor | Short observation sequence | Overloaded | Yes |
| 6 | Staff Room Reveal | Staff Room | Staff Room | Reveal slideshow / final choice prompt | Overloaded -> Restored | Yes |

## Optional Content Chain

| Optional Content | Owner | Location | Purpose | Availability |
| --- | --- | --- | --- | --- |
| Broken High Score | Roxy | Cabinet Row | Reinforce corrupted records and missing score identity | After Lost Token or Truth Filter |
| Prize Counter Secret | Pip | Prize Corner | Reward observation and arcade lore curiosity | After Prize Corner opens |
| Owner Portrait Chain | Owner Portrait | ArcadeHub / Staff Corridor | Foreshadow Employee 04 through shifting details | Across Memory Signal states |
| Broken Cabinet Interactions | Broken Cabinet | ArcadeHub / Cabinet Row | Short machine echoes and corrupted cabinet reactions | After Truth Filter |
| Post-Reveal Dialogue | All core NPCs | All maps | Let NPCs speak openly about Employee 04 | After reveal |

Optional content should add texture, not block the ending.

## Act Structure

### Act 1: Lost Token
Memory Signal: Grounded -> Uneasy

Purpose:
- Establish Pixel Haven.
- Establish the player is confused.
- Make Mira the emotional anchor.
- Teach cabinet interactions through Rockbyte Duel.
- End with the first recovered object and a small emotional payoff.

Completion return dialogue:
- Mira says the token woke something up.
- The player notices the arcade feels more personal.
- The next lead points away from Mira and toward machine records.

### Act 2: Contradictions
Memory Signal: Uneasy -> Fractured

Purpose:
- Shift quest ownership to Mr. Byte.
- Teach the player that memory records can contradict dialogue.
- Make machines sound more personal and less neutral.
- Move the player into Cabinet Row.

Required puzzle:
- Truth Filter.

Completion return dialogue:
- Mr. Byte says the contradiction is now readable.
- The player realizes their memory is no longer the only witness.
- Vendo becomes the next owner by commenting on signal flow.

### Act 2.5: Signal Flow
Memory Signal: Fractured

Purpose:
- Give Vendo a required quest instead of using him only for jokes.
- Translate identity/signal instability into a readable arcade puzzle.
- Give the player a more kinetic or pattern-based break after Truth Filter.

Required puzzle:
- Circuit Soda.

Working concept:
- Route colored signal streams through vending-machine channels.
- Match unstable labels to stable output.
- Keep it simple: no inventory, no timers unless very gentle.

Completion return dialogue:
- Vendo jokes that the player's signal has carbonation but no label.
- The story implication is that identity can be routed, filtered, and mislabeled.
- Gus becomes the next owner because the Staff Door needs maintenance-level sync.

### Act 3 Setup: Maintenance Sync
Memory Signal: Fractured -> Overloaded

Purpose:
- Give Gus a major required role.
- Make the Staff Door feel earned.
- Test the player's understanding that two versions/signals need to align.

Required puzzle:
- Maintenance Sync / Sync Door.

Completion return dialogue:
- Gus says the door is listening to both versions now.
- The player is not told the full truth yet, but knows the door recognizes something doubled.
- Staff Corridor opens.

### Act 3: Staff Corridor And Memory Echo
Memory Signal: Overloaded

Purpose:
- Slow the player down before the reveal.
- Make the route feel like crossing a threshold.
- Use short first-person player observations, not a lore dump.

Required sequence:
- Staff Corridor.
- Memory Echo.

Possible interactions:
- Staff notices with missing names.
- Reflections that do not match the player.
- Arcade sounds muffled behind the door.
- One or two forced dialogue beats from the player.

### Finale: Staff Room Reveal
Memory Signal: Overloaded -> Restored

Purpose:
- Reveal Employee 04 clearly.
- Make earlier clues click.
- Deliver the emotional payoff.
- Unlock post-reveal roam.

Required sequence:
- Staff Room reveal slideshow or memory panels.
- Ending prompt.
- Save and Continue / Return to Title.

Post-reveal:
- NPCs can speak more openly.
- Optional secrets can resolve.
- The arcade feels less hostile and more mournful.

## Quest Definitions

### Lost Token
Quest giver: Mira

Location: ArcadeHub / Cabinet 07

Minigame: Rockbyte Duel

Story purpose:
- Establish Mira's familiarity with the player.
- Establish Cabinet 07 as a machine that recognizes incomplete records.
- Recover the first symbolic memory object.

Completion reward:
- Lost Token recovered.
- Memory Signal becomes Uneasy.
- Truth Filter route opens.

Completion anecdote:
> "It remembered enough to give this back. That means something in here still knows you."

Required or optional: Required

### Truth Filter
Quest giver: Mr. Byte

Location: Cabinet Row

Minigame: Truth Filter

Story purpose:
- Teach that records and memories conflict.
- Move authority from Mira's emotional memory to machine evidence.
- Foreshadow Employee 04 through incomplete staff records.

Completion reward:
- Second Memory Fragment recovered.
- Memory Signal becomes Fractured.
- Vendo / Circuit Soda route opens.

Completion anecdote:
> "Contradiction accepted. Your memory is no longer the only witness."

Required or optional: Required

### Circuit Soda
Quest giver: Vendo

Location: Snack Alcove

Minigame: Circuit Soda

Story purpose:
- Turn signal routing into a playful but unsettling puzzle.
- Show Vendo as more than a joke machine.
- Suggest the player's identity is being redirected through broken systems.

Completion reward:
- Signal Flow stabilized.
- Staff systems become easier to read.
- Gus / Maintenance Sync route opens.

Completion anecdote:
> "Congratulations. Your identity now flows smoother than orange soda through a busted hose."

Memory Signal effect:
- Stays Fractured, but increases visual pressure and machine recognition.

Required or optional: Required

### Maintenance Sync
Quest giver: Gus

Location: Maintenance Hall

Minigame: Sync Door / Maintenance Sync

Story purpose:
- Give Gus practical ownership of the route to the Staff Room.
- Test the two-signal idea before the reveal.
- Make the Staff Door unlock feel like a major step.

Completion reward:
- Staff Door unlocks.
- Staff Corridor opens.
- Memory Signal becomes Overloaded.

Completion anecdote:
> "Door finally heard both of you. Try not to think too hard about that sentence."

Required or optional: Required

### Broken High Score
Quest giver: Roxy

Location: Cabinet Row

Minigame: Broken High Score

Story purpose:
- Reinforce corrupted records and identity reset.
- Let an optional NPC own a lighter arcade-style challenge.
- Give the player a side clue about previous attempts.

Completion reward:
- Previous score restored.
- Optional lore line about Employee 04's blank score record.

Completion anecdote:
- "Huh. Your score came back."
- "That usually does not happen after a reset."
- "Do not let it go to your head. You still walk like a tutorial."

Memory Signal effect:
- No required state change. Can add optional Fractured/Restored dialogue variants.

Required or optional: Optional

Acceptance notes:
- Real target is `99`; fake target display remains `9999`.
- Completion saves `broken_high_score_completed`.
- Roxy's completion anecdote saves `roxy_high_score_anecdote_seen`.
- This content must not block Staff Corridor, Staff Room, reveal, or ending.

### Prize Counter Secret
Quest giver: Pip

Location: Prize Corner

Puzzle: Observation / prize trade secret

Story purpose:
- Reward players who inspect details.
- Add warmth and contrast through a smaller personal secret.
- Foreshadow that tokens, prizes, and staff records were once connected.

Completion reward:
- Prize Sort completion flag.
- A small post-reveal line or memory object reference.

Completion anecdote:
- "Prizes sorted."
- "Some rewards remember their owner before the owner remembers them."

Memory Signal effect:
- No required state change.

Required or optional: Optional

Prize Sort order:
1. Ticket Stub
2. Lost Token
3. Blank Employee Badge

Acceptance notes:
- Completion saves `prize_sort_completed`.
- Pip's post-reveal callback saves `pip_post_reveal_secret_seen`.
- This content must not block Staff Corridor, Staff Room, reveal, or ending.

### Owner Portrait Chain
Quest giver: Owner Portrait / environment

Location: ArcadeHub, Staff Corridor, Staff Room

Puzzle: Repeated observation across story phases

Story purpose:
- Foreshadow Employee 04 through changing visual details.
- Encourage revisiting old objects.
- Make the hub feel reactive.

Completion reward:
- Optional lore completion.
- Post-reveal confirmation line.

Completion anecdote:
> "The name was never gone. It was waiting for you to be able to read it."

Memory Signal effect:
- Changes available text by state, but does not change state.

Required or optional: Optional

## Required Return-To-Story Rule
Every required game or puzzle must end with:
- A clear success message.
- Return to the map.
- Dialogue with the owner NPC or involved machine.
- Updated objective.
- Save/load preserving the new state.

The player should never finish a puzzle and wonder why it mattered.

## Expanded Route Acceptance Gate
Use `EXPANDED_REQUIRED_ROUTE_ACCEPTANCE.md` as the live acceptance gate for the required expanded route.

The route must verify:
- New Memory through Lost Token, Truth Filter, Circuit Soda, Maintenance Sync, Memory Echo, Staff Room reveal, and ending.
- Save/load after Rockbyte, Truth Filter, Circuit Soda, Maintenance Sync, Memory Echo, and reveal.
- Objective text always points to the next required owner and location.
- Required owner completion anecdotes play once, then switch to shorter repeat lines.
- Optional NPCs, optional minigames, and optional secrets are not required.
- The route is meaningfully longer than the original MVP without feeling padded.

## Expansion Gates
Before adding each major piece:
1. The previous required route must pass live testing.
2. Save/load must preserve all new flags.
3. Objective text must clearly point to the next owner.
4. The new map must have a clear entrance and exit.
5. The puzzle must have a story reason and a completion dialogue beat.

## Non-Goals
- A sprawling arcade with many unused cabinets.
- A quest board.
- A full inventory.
- Branching endings.
- Multiple puzzle solutions requiring large state tracking.
- Large lore documents inside the game.

Keep the game compact, readable, and emotionally sharp.
