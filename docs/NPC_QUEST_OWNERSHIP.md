# NPC Quest Ownership

## Purpose
Assign clear ownership for a 45-75 minute compact arcade mystery so Mira remains the emotional anchor without becoming the quest board.

## Ownership Rules
- Each required quest has a named owner or owner pair.
- Each required puzzle ends with owner dialogue.
- At least two required beats involve more than one NPC or object.
- NPCs should own story problems that fit their role.
- Object-owned quests are allowed when the object is the right authority.
- Completion dialogue should tell the player why the content mattered and where to go next.

## Required Ownership Matrix

| Owner | Required Content | Location | Responsibility | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Mira + Cabinet 07 | Rockbyte Duel | ArcadeHub | Mira frames the emotional problem; Cabinet 07 guards the Lost Token. | Story started. | `rockbyte_duel_completed`, `lost_token_quest_completed` | Mira: "It remembered you before you did." | Grounded -> Uneasy. | 6-8 min |
| Mr. Byte | Truth Filter | Cabinet Row | Interprets contradictory records and authorizes the record test. | `lost_token_quest_completed`. | `lying_cabinets_completed` | Mr. Byte: "Record conflict reduced. Identity conflict remains." | Uneasy -> Fractured. | 6-8 min |
| Vendo | Circuit Soda | Snack Alcove | Routes unstable memory signal through a readable arcade machine metaphor. | `lying_cabinets_completed`. | `circuit_soda_completed` | Vendo: "Your label is still missing, but the machine knows what shelf you go on." | Fractured pressure increases. | 6-8 min |
| Mira + Gus + Mr. Byte | Lost Shift File | ArcadeHub, Maintenance Hall, Cabinet Row | Multi-NPC lore investigation that proves a staff shift is missing. | `circuit_soda_completed`. | Planned: `lost_shift_file_completed` | Gus: "That shift was never closed. It was hidden under a repair note." | Staff-record suspicion becomes explicit. | 7-10 min |
| Gus | Static Service Run | Maintenance Hall | Turns the Staff Door power problem into a short 8-bit service route. | `lost_shift_file_completed`. | `static_service_run_completed` | Gus: "Power's back. Door's awake." | Fractured. | 5-7 min |
| Gus | Maintenance Sync | Maintenance Hall | Makes the Staff Door problem practical and aligns two signals. | `static_service_run_completed`. | `maintenance_sync_completed`, `story_puzzle_completed` | Gus: "Door heard both knocks. Yours, and the one you forgot making." | Fractured -> Overloaded. | 6-8 min |
| Staff Door + Mr. Byte | Security Tape Assembly | Staff Corridor | Staff Door blocks entry; Mr. Byte helps reconstruct corrupted tape. | `maintenance_sync_completed`. | `security_tape_assembly_completed` | Staff Door: "CUSTOMER RECORD NOT FOUND." | Overloaded pressure rises. | 6-9 min |
| Staff Door / Memory System | Final Night Walk | Staff Corridor | Lets the player walk through a symbolic reconstruction before Memory Echo. | `security_tape_assembly_completed`. | `final_night_walk_completed` | Staff Door: "ONE WALKED IN. TWO SIGNALS ANSWERED." | Overloaded pressure rises. | 5-8 min |
| Memory Echo | Memory Echo | Staff Corridor | Stabilizes identity through short memory-choice prompts. | `final_night_walk_completed`. | `memory_echo_completed` | Memory Echo: "The arcade stops arguing with itself." | Overloaded, Staff Room playback allowed. | 5-7 min |
| ??? / `"Player"` | Final Self-Conflict | Staff Room | Confronts the protagonist's regret after the reveal slideshow and unlocks final self-recognition before EndingPrompt. | `twist_reveal_seen`. | `conscience_final_room_seen`, `player_glitched_form_unlocked` | `"Player"`: "Then carry it." | Overloaded emotional pressure; no progress-count change. | 5-8 min total |
| Staff Room | Staff Room Reveal | Staff Room | Reveals Employee 04 and resolves the main mystery. | `memory_echo_completed`. | `twist_reveal_seen`, `post_reveal_roam_unlocked` | Player: "Employee 04. That was not a clue. It was my name tag." | Overloaded -> Restored. | 6-8 min |

## Optional Ownership Matrix

| Owner | Optional Content | Location | Responsibility | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Roxy | Broken High Score | Cabinet Row | Owns competitive optional arcade challenge and blank score clue. | `rockbyte_duel_completed`. | `broken_high_score_completed` | Roxy: "Your score came back. Name stayed blank. That is usually bad." | No required change. | 5-7 min |
| Pip | Prize Sort | Prize Corner | Owns prize-label memory order and softer optional clue. | `lying_cabinets_completed` or post-reveal. | `prize_sort_completed`, `pip_secret_completed` | Pip: "Some rewards remember their owner before the owner remembers them." | No required change. | 4-6 min |
| Owner Portrait | Owner Portrait Chain | ArcadeHub, Staff Corridor, Staff Room | Owns environmental "04" foreshadowing. | Available from start; changes by state. | `owner_portrait_secret_found`, `echo_owner_portrait_04_seen` | "The name was never gone. It waited until you could read it." | Text changes by Memory Signal. | 4-6 min |
| Broken Cabinet | Broken Cabinet Chain | ArcadeHub / Cabinet Row | Owns failed reset and cabinet-corruption echoes. | `lying_cabinets_completed`. | Planned: `broken_cabinet_chain_completed` | "RESET FAILED. EMPLOYEE SIGNAL RETURNED." | Fractured flavor only. | 4-6 min |
| Mr. Byte / Staff Door | Staff Records Chain | Cabinet Row, Staff Corridor | Owns optional records that connect badge, shift, and tape details. | After Lost Shift File or post-reveal. | Planned: `staff_records_chain_completed` | Mr. Byte: "Record complete enough to hurt." | Improves reveal comprehension. | 5-7 min |
| Core NPCs | Post-Reveal Witness Route | All active maps | Each witness gives one direct post-reveal truth. | `twist_reveal_seen`. | Planned: `post_reveal_witness_route_completed` | Mira: "I knew you as a coworker before I knew you as a ghost." | Restored emotional closure. | 8-12 min |
| Vendo | Vendo Memory Cola Riddle | ArcadeHub / Snack Alcove | Owns a small riddle secret using product-language clues. | Route progress and repeated Vendo dialogue. | `vendo_memory_riddle_secret_found` | Vendo: "MEMORY COLA DISPENSED." | No required change. | 2-4 min |

## NPC Roles By Phase

| Phase | Lead Owner | Support Owners | Notes |
| --- | --- | --- | --- |
| Grounded | Mira | Cabinet 07 | The player needs emotional orientation, not exposition. |
| Uneasy | Mr. Byte | Mira | Records start contradicting memory. |
| Fractured | Vendo | Mr. Byte, Gus | Signal routing and staff systems become the core mystery. |
| Fractured Investigation | Mira + Gus + Mr. Byte | Staff records | Lost Shift File must feel collaborative, not like a fetch quest. |
| Overloaded | Gus, Staff Door, Mr. Byte | Memory Echo, ??? / `"Player"` | Back-room systems recognize two versions of the player; Final Night Walk makes the past physically traversable; the conscience names itself after the Staff Room reveal slideshow. |
| Restored | All core NPCs | Optional owners | Post-reveal lines can finally name Employee 04. |

## Dialogue Requirements
- Required owner dialogue should play once after completion, then switch to short repeat lines.
- Every required completion beat should include owner reaction, a player realization, and next objective direction.
- Optional completion dialogue may be shorter, but must still say why the side content mattered.
- Lore-reading quest dialogue should be specific enough to change the player's theory.

## Mira Boundary
Mira owns the emotional start and post-reveal closure. She can participate in Lost Shift File, but she should not assign Truth Filter, Circuit Soda, Maintenance Sync, Security Tape Assembly, or every optional route.
