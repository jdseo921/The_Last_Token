# Minigame Roster

## Purpose
Define the required playable arcade stages and optional minigames for a compact 55-75 minute required route.

## Roster Rules
- Required progress now has 10 milestones: 8 playable minigame/adventure/puzzle stages, 1 required lore investigation, and the Staff Room reveal.
- Optional route has exactly 2 optional minigames/puzzles.
- Lore-reading quests are tracked separately in `LORE_QUEST_PLAN.md`.
- No combat.
- No inventory.
- Required stages must return to the route safely and preserve save/load.

## Required Progress Route

| Order | Content | Owner | Location | Type | Unlock | Completion Flag | Memory Signal | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Rockbyte Duel | Mira / Cabinet 07 | ArcadeHub | Minigame | Story started | `rockbyte_duel_completed` | Grounded -> Uneasy | Implemented |
| 2 | Truth Filter | Mr. Byte | Cabinet Row | Minigame | `lost_token_quest_completed` | `lying_cabinets_completed` | Uneasy -> Fractured | Implemented |
| 3 | Circuit Soda | Vendo | Snack Alcove | Minigame | `lying_cabinets_completed` | `circuit_soda_completed` | Fractured | Implemented |
| 4 | Lost Shift File | Mira / Gus / Mr. Byte | ArcadeHub / Cabinet Row / Maintenance Hall | Lore investigation | `circuit_soda_completed` | `lost_shift_file_completed` | Fractured | Implemented |
| 5 | Static Service Run | Gus | Maintenance Hall | 8-bit arcade-adventure | `lost_shift_file_completed` | `static_service_run_completed` | Fractured | Implemented with placeholder visuals |
| 6 | Maintenance Sync | Gus | Maintenance Hall | Puzzle | `static_service_run_completed` | `maintenance_sync_completed` | Fractured -> Overloaded | Implemented |
| 7 | Security Tape Assembly | Staff Door / Mr. Byte | Staff Corridor | Puzzle | `maintenance_sync_completed` | `security_tape_assembly_completed` | Overloaded | Implemented |
| 8 | Final Night Walk | Staff Door / Memory System | Staff Corridor | 8-bit arcade-adventure | `security_tape_assembly_completed` | `final_night_walk_completed` | Overloaded | Implemented with placeholder visuals |
| 9 | Memory Echo | Memory Echo | Staff Corridor | Dialogue puzzle | `final_night_walk_completed` | `memory_echo_completed` | Overloaded | Implemented |
| 10 | Staff Room Reveal | Staff Room | Staff Room | Reveal sequence | `memory_echo_completed` | `twist_reveal_seen` | Restored after ending | Implemented |

## Optional Minigames And Puzzles

| Content | Owner | Location | Unlock | Completion Flag | Status |
| --- | --- | --- | --- | --- | --- |
| Broken High Score | Roxy | Cabinet Row | `rockbyte_duel_completed` | `broken_high_score_completed` | Implemented |
| Prize Sort | Pip | Prize Corner | `lying_cabinets_completed` or post-reveal | `prize_sort_completed`, `pip_secret_completed` | Implemented as map puzzle |

## Progress Display
Recommended save slot display:

`Main: x / 10`  
`Optional: x / 2`  
`Secrets: x / y`  
`Signal: [Memory Signal]`

## Playtime Estimate
- Required route: 55-75 minutes.
- Completionist route: 70-90 minutes.
- Fast tester route: 40-55 minutes.
