# Minigame Roster

Rewritten against the shipped game. The route in this file is taken from `data/quests.json`, the counter from `GameState.get_required_progress_count()`, and the screen inventory from `scripts/qa/MinigameTestCatalog.gd`. An earlier version of this document described a 10-milestone route with Broken High Score and Prize Sort as optional; that is no longer what ships.

## Purpose
Define the required playable arcade stages and optional content for a compact required route.

## Roster Rules
- Required progress has 12 milestones, counted in `GameState.get_required_progress_count()`.
- `data/quests.json` holds 11 quests marked `"required": true`, plus the Staff Room reveal, which is tracked by `twist_reveal_seen` rather than by a quest record.
- The counter is not a one-to-one map of the quest list. One milestone is the retired Final Night Walk flag, and the Staff Corridor quest is a route gate that does not increment the counter. See the counter table below.
- Lore-reading quests are tracked separately in `LORE_QUEST_PLAN.md`.
- Conscience Encounters are short route interludes, not minigames, and do not increase the required count.
- No combat.
- No inventory.
- Required stages must return to the route safely and preserve save/load.

## Required Route

Order follows each quest's `starts_after` prerequisite flag.

| Order | Quest id | Title | Owner | Location | Type | Unlocked by | Completion flag | Memory Signal |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `lost_token` | Recover the Lost Token | Mira / Cabinet 07 | ArcadeHub | Minigame — Rockbyte Duel | `story_started` | `rockbyte_duel_completed`, `lost_token_quest_completed` | Uneasy |
| 2 | `broken_high_score` | Broken High Score | Roxy | Cabinet Row | Minigame | `lost_token_quest_completed` | `broken_high_score_completed` | No Change |
| 3 | `truth_filter` | Truth Filter | Mr. Byte | Cabinet Row | Minigame | `broken_high_score_completed` | `lying_cabinets_completed` | Fractured |
| 4 | `circuit_soda` | Route the Signal | Vendo | Snack Alcove | Minigame — Circuit Soda | `gus_hub_checkin_truth_filter_done` | `circuit_soda_completed` | Fractured |
| 5 | `prize_counter_secret` | Prize Echo Ascent | Pip | Prize Corner | Adventure — Prize Shelf Run | `vendo_unknown_clue_seen` | `prize_sort_completed` | No Change |
| 6 | `lost_shift_file` | Closing Shift Echoes | Gus | Arcade Hub, Cabinet Row, Snack Alcove | Lore investigation | `gus_hub_checkin_prize_sort_done` | `lost_shift_file_completed` | Fractured |
| 7 | `static_service_run` | Static Service Run | Gus | Maintenance Hall | Adventure | `lost_shift_file_completed` | `static_service_run_completed` | Fractured |
| 8 | `maintenance_sync` | Maintenance Sync | Gus | Maintenance Hall | Puzzle — Sync Door | `static_service_run_completed` | `maintenance_sync_completed` | Overloaded |
| 9 | `staff_corridor` | Enter the Staff Corridor | Staff Door | Staff Corridor | Route step | `maintenance_sync_completed` | none counted | Overloaded |
| 10 | `security_tape_assembly` | Assemble the Security Tape | Staff Door / Mr. Byte | Staff Room | Puzzle | `maintenance_sync_completed` | `security_tape_assembly_completed` | Overloaded |
| 11 | `memory_echo` | Stabilize the Memory Echo | Memory Echo | Staff Room | Dialogue puzzle | `security_tape_assembly_completed` | `memory_echo_completed` | Overloaded |
| 12 | — | Staff Room Reveal | Staff Room / `"Player"` | Staff Room | Reveal sequence, final self-conflict, EndingPrompt | `memory_echo_completed` | `twist_reveal_seen`, `conscience_final_room_seen` | Restored after ending |

### Retired

**Final Night Walk** was cut as a playable stage. `scripts/GameState.gd` keeps `final_night_walk_started` and `final_night_walk_completed` so existing saves keep loading and the late-game checks read the same; nothing in the shipped route launches a stage for them. `complete_memory_echo()` and `mark_twist_reveal_seen()` set the flags. The Staff Room terminal consumes the repaired tape directly.

## Required-progress counter

`GameState.TOTAL_REQUIRED_PROGRESS_COUNT` is 12. These are the flags counted, in order:

| # | Flag | Source |
| --- | --- | --- |
| 1 | `rockbyte_duel_completed` | Rockbyte Duel |
| 2 | `broken_high_score_completed` | Broken High Score |
| 3 | `lying_cabinets_completed` | Truth Filter |
| 4 | `circuit_soda_completed` | Circuit Soda |
| 5 | `prize_sort_completed` | Prize Echo Ascent |
| 6 | `lost_shift_file_completed` | Closing Shift Echoes (or all three read-flags) |
| 7 | `static_service_run_completed` | Static Service Run |
| 8 | `maintenance_sync_completed` | Maintenance Sync |
| 9 | `security_tape_assembly_completed` | Security Tape Assembly |
| 10 | `final_night_walk_completed` | Retired stage, back-filled by `complete_memory_echo()` |
| 11 | `memory_echo_completed` | Memory Echo |
| 12 | `twist_reveal_seen` | Staff Room reveal |

## Non-minigame route interludes

| Content | Owner | Trigger ids in `mark_conscience_encounter_seen()` | Flags |
| --- | --- | --- | --- |
| Conscience Encounters | `???` / `"Player"` | `after_truth_filter`, `after_circuit_soda`, `after_lost_shift_file`, `staff_corridor_approach`, `final_conscience` | `conscience_encounter_1_seen` through `conscience_encounter_4_seen`, `conscience_final_encounter_seen`, `conscience_name_revealed` |
| Final room conversation | `"Player"` | `mark_conscience_final_room_seen()` | `conscience_final_room_seen`, `player_creator_monologue_seen`, `player_glitched_form_unlocked` |

## Optional content

| Content | Quest id | Owner | Location | Unlocked by | Completion flag |
| --- | --- | --- | --- | --- | --- |
| Night Ledger | `after_hours_archive` | Night Ledger | After-Hours Archive | `circuit_soda_completed` | `night_ledger_completed` |
| Staff Records Chain | `staff_records_chain` | Staff Records | Cabinet Row, Maintenance Hall, Staff Corridor | `lying_cabinets_completed` | `staff_records_chain_completed` |
| Post-Reveal Witness Route | `post_reveal_witness_route` | Mira / Gus / Vendo / Mr. Byte / Cabinet 07 | Multiple | `post_reveal_roam_unlocked` | `witness_route_completed` |
| Snack Service Dash | none | Service Dash cabinet | Snack Alcove | Always available in the room | none counted |

`GameState.TOTAL_OPTIONAL_GAMES_COUNT` is 1, and the optional counter only counts `night_ledger_completed`. Snack Service Dash is a playable adventure stage reachable from Snack Alcove with no quest record and no completion flag.

## Playable screens

Eleven screens plus a template, from `scripts/qa/MinigameTestCatalog.gd`. Pause coverage, layout coverage, and UI architecture coverage all inherit this list.

Rockbyte Duel, Broken High Score, Truth Filter, Circuit Soda, Security Tape Assembly, Memory Echo, Static Service Run, Snack Service Dash, Prize Shelf Run, Night Ledger Run, Sync Door Puzzle, plus `MinigameScreenTemplate.tscn`.

Four of these are hybrid adventure stages driven by `HybridAdventureCatalog` profiles: `snack_service_dash`, `prize_shelf_run`, `static_service_run`, `night_ledger_run`.

## Progress display

The save slot menu does **not** display progress counters. `SaveSlotMenu._format_slot_text` renders three lines:

```text
MEMORY SLOT 2
STATUS: Fractured
LAST SAVED: 2026-07-19T22:15:30
```

`SaveSlotDisplaySmoke.gd` asserts that the slot text omits `MAIN:`, `OPTIONAL:`, and `SECRETS:` so the list does not change shape as the player progresses. The counters still exist on the save data and in `GameState`, and the route smokes print them as `main=x/12`.

## Playtime estimate

Design-time estimates, never measured:

- Required route: 55-75 minutes.
- Completionist route: 70-90 minutes.
- Fast tester route: 40-55 minutes.
