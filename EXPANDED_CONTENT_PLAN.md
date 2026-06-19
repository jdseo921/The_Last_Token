# Expanded Content Plan

## Purpose
Plan The Last Token as a compact 45-75 minute arcade mystery without expanding into a sprawling adventure.

This is planning and scope control only. Do not implement new gameplay from this document until the current required route remains playable end to end.

## Runtime Target
- Main route: 55-75 minutes.
- Completionist route: 70-90 minutes.
- Fast tester route: 40-55 minutes.
- Required route should contain 8 playable minigame/adventure/puzzle stages, 1 required lore investigation, and the Staff Room reveal.
- Optional route should contain 2 optional minigames or puzzles, 2 optional lore chains, and post-reveal witness follow-up.

## Scope Rules
- Do not add combat.
- Do not add inventory.
- Do not add a sprawling maze.
- Do not add save-anywhere.
- Do not add extra NPCs before core NPC quest ownership works.
- Each map must have a clear purpose, landmark, and exit.
- Each required puzzle must end with owner dialogue.
- Mira should not assign every task.
- Some quests should involve multiple NPCs.
- Lore-reading quests must change what the player understands or unlock dialogue, not exist as flavor text only.

## Required Route
1. Mira / Cabinet 07 -> Rockbyte Duel.
2. Mr. Byte -> Truth Filter.
3. Vendo -> Circuit Soda.
4. Mira + Gus + Mr. Byte -> Lost Shift File lore investigation.
5. Gus -> Static Service Run.
6. Gus -> Maintenance Sync.
7. Staff Door / Mr. Byte -> Security Tape Assembly.
8. Staff Door / Memory System -> Final Night Walk.
9. Memory Echo -> identity stabilization.
10. Staff Room -> reveal.

## Required Progress Counter
The save slot Main counter tracks required route progress, not only cabinet games:

1. Rockbyte Duel.
2. Truth Filter.
3. Circuit Soda.
4. Lost Shift File.
5. Static Service Run.
6. Maintenance Sync.
7. Security Tape Assembly.
8. Final Night Walk.
9. Memory Echo.
10. Staff Room Reveal.

## Optional Route
1. Roxy -> Broken High Score.
2. Pip -> Prize Sort.
3. Owner Portrait chain.
4. Broken Cabinet chain.
5. Post-Reveal Witness Route.

## Required Content Matrix

| Order | Content | Owner | Location | Type | Story Purpose | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Rockbyte Duel | Mira / Cabinet 07 | ArcadeHub | Minigame | Recover the Lost Token and prove the arcade recognizes the player. | Story started, talk to Mira. | `rockbyte_duel_completed`, then `lost_token_quest_completed` after Mira return. | Mira: "It remembered you before you did." | Grounded -> Uneasy. | 6-8 min |
| 2 | Truth Filter | Mr. Byte | Cabinet Row | Minigame | Show that machine records and memories contradict each other. | `lost_token_quest_completed`. | `lying_cabinets_completed` | Mr. Byte: "Record conflict reduced. Identity conflict remains." | Uneasy -> Fractured. | 6-8 min |
| 3 | Circuit Soda | Vendo | Snack Alcove | Minigame | Turn identity instability into signal routing with comic pressure. | `lying_cabinets_completed`. | `circuit_soda_completed` | Vendo: "Your label is still missing, but the machine knows what shelf you go on." | Fractured, stronger hub reactivity. | 6-8 min |
| 4 | Lost Shift File | Mira + Gus + Mr. Byte | ArcadeHub, Maintenance Hall, Cabinet Row | Lore-reading quest | Prove there was a missing staff shift before the Staff Door opens. | `circuit_soda_completed`. | Planned: `lost_shift_file_completed` | Gus: "That shift was never closed. It was hidden under a repair note." | Fractured -> Fractured with staff-record pressure. | 7-10 min |
| 5 | Static Service Run | Gus | Maintenance Hall | 8-bit arcade-adventure | Restore service power before Maintenance Sync can run. | `lost_shift_file_completed`. | `static_service_run_completed` | Gus: "Power's back. Door's awake." | Fractured. | 5-7 min |
| 6 | Maintenance Sync | Gus | Maintenance Hall | Puzzle | Align two unstable signals so staff systems can hear both versions. | `static_service_run_completed`. | `maintenance_sync_completed`, `story_puzzle_completed`, `staff_room_unlocked` | Gus: "Door heard both knocks. Yours, and the one you forgot making." | Fractured -> Overloaded. | 6-8 min |
| 7 | Security Tape Assembly | Staff Door / Mr. Byte | Staff Corridor | Puzzle | Assemble corrupted tape clips that confirm the Staff Door did not record a customer. | `maintenance_sync_completed`. | `security_tape_assembly_completed` | Staff Door: "CUSTOMER RECORD NOT FOUND." | Overloaded, reveal pressure rises. | 6-9 min |
| 8 | Final Night Walk | Staff Door / Memory System | Staff Corridor | 8-bit arcade-adventure | Walk a symbolic reconstruction of the Final Night before Memory Echo. | `security_tape_assembly_completed`. | `final_night_walk_completed` | Staff Door: "ONE WALKED IN. TWO SIGNALS ANSWERED." | Overloaded. | 5-8 min |
| 9 | Memory Echo | Memory Echo | Staff Corridor | Puzzle/dialogue sequence | Stabilize identity before the Staff Room can show the truth. | `final_night_walk_completed`. | `memory_echo_completed` | Memory Echo: "The arcade stops arguing with itself." | Overloaded, Staff Room playback allowed. | 5-7 min |
| 10 | Staff Room Reveal | Staff Room | Staff Room | Reveal sequence | Name Employee 04 and make earlier clues click. | `memory_echo_completed`. | `twist_reveal_seen`, `post_reveal_roam_unlocked` | Player: "Employee 04. That was not a clue. It was my name tag." | Overloaded -> Restored. | 6-8 min |

## Optional Content Matrix

| Content | Owner | Location | Type | Story Purpose | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Broken High Score | Roxy | Cabinet Row | Minigame | Restore a corrupted score and show the player's name is missing from arcade records. | `rockbyte_duel_completed`; best after Cabinet Row opens. | `broken_high_score_completed` | Roxy: "Your score came back. Name stayed blank. That is usually bad." | No required state change; Fractured/Restored variants allowed. | 5-7 min |
| Prize Sort | Pip | Prize Corner | Puzzle | Arrange prize labels into the memory order: Ticket Stub, Lost Token, Blank Employee Badge. | `lying_cabinets_completed` or post-reveal. | `prize_sort_completed`, `pip_secret_completed` | Pip: "Some rewards remember their owner before the owner remembers them." | No required state change; adds optional warmth. | 4-6 min |
| Owner Portrait Chain | Owner Portrait | ArcadeHub, Staff Corridor, Staff Room | Lore-reading chain | Foreshadow "04" through repeated object inspection. | Available from start; new text by Memory Signal. | `owner_portrait_secret_found`, `echo_owner_portrait_04_seen` | Object: "The name was never gone. It waited until you could read it." | Text changes by state; no progression gate. | 4-6 min |
| Broken Cabinet Chain | Broken Cabinet | ArcadeHub / Cabinet Row | Lore-reading chain | Give short corrupted machine echoes about failed resets. | After `lying_cabinets_completed`. | Planned: `broken_cabinet_chain_completed` | Broken Cabinet: "RESET FAILED. EMPLOYEE SIGNAL RETURNED." | Adds Fractured texture only. | 4-6 min |
| Staff Records Chain | Mr. Byte / Staff Door | Cabinet Row, Staff Corridor | Lore-reading quest | Let optional readers connect shift records, badge numbers, and the locked room. | After `lost_shift_file_completed` or post-reveal. | Planned: `staff_records_chain_completed` | Mr. Byte: "Record complete enough to hurt." | No gate; improves reveal comprehension. | 5-7 min |
| Post-Reveal Witness Route | Mira, Gus, Vendo, Mr. Byte, Roxy, Pip | All active maps | Lore-reading quest | Let NPCs acknowledge Employee 04 with short personal witness lines. | `twist_reveal_seen`. | Planned: `post_reveal_witness_route_completed` | Mira: "I knew you as a coworker before I knew you as a ghost." | Restored; emotional closure. | 8-12 min |
| Vendo Memory Cola Riddle | Vendo | ArcadeHub / Snack Alcove | Lore riddle | Reward players who notice Vendo's product-language clue about memory. | Currently tied to repeated Vendo dialogue after route progress. | `vendo_memory_riddle_secret_found` | Vendo: "MEMORY COLA DISPENSED. TRY NOT TO DRINK THE RECEIPT." | No required state change. | 2-4 min |

## Pacing Budget
- Opening, Mira, Cabinet 07, Rockbyte Duel: 8-10 minutes.
- Mr. Byte and Truth Filter: 6-8 minutes.
- Vendo and Circuit Soda: 6-8 minutes.
- Lost Shift File lore investigation: 7-10 minutes.
- Static Service Run: 5-7 minutes.
- Gus and Maintenance Sync: 6-8 minutes.
- Security Tape Assembly: 6-9 minutes.
- Final Night Walk: 5-8 minutes.
- Memory Echo: 5-7 minutes.
- Staff Room reveal and immediate ending beat: 6-8 minutes.
- Optional minigames, lore chains, and post-reveal witness route: 15-25 minutes.

## Implementation Gates
1. Keep current required route playable before adding Lost Shift File.
2. Add Lost Shift File as short readable interactions before changing Maintenance Sync gating.
3. Add Security Tape Assembly only after Maintenance Sync and Staff Corridor save/load are stable.
4. Add optional lore chains only after the required reveal remains clear.
5. Do not add new maps unless the route needs them; expand existing maps first.

## Current Implementation Snapshot
Implemented or scaffolded now:
- Rockbyte Duel.
- Truth Filter.
- Circuit Soda.
- Lost Shift File required lore investigation.
- Static Service Run.
- Maintenance Sync / Sync Door.
- Security Tape Assembly.
- Final Night Walk.
- Memory Echo.
- Staff Room reveal.
- Broken High Score.
- Prize Sort.
- Owner Portrait interactions.
- Vendo Memory Cola riddle.
- Staff Records Chain optional lore quest.
- Post-Reveal Witness Route completion structure.
- Multiple maps: ArcadeHub, Cabinet Row, Snack Alcove, Prize Corner, Maintenance Hall, Staff Corridor, Staff Room.

Still missing as planned content:
- Broken Cabinet Chain completion structure.
