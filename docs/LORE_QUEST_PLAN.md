# Lore Quest Plan

## Purpose
Define lore-reading quests that matter to the mystery without adding inventory, combat, maze navigation, or long documents.

Lore quests should be short investigations through readable interactions. They should unlock dialogue, clarify the route, or make the reveal easier to understand.

## Lore Quest Rules
- No inventory.
- No long codex entries.
- No hauling items between maps.
- Use 2-4 short interactions per quest.
- Each required lore quest must unlock or justify the next required gameplay beat.
- Optional lore quests must not block the ending.

## Lore Quest Matrix

| Quest | Owner | Location | Required | Story Purpose | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Lost Shift File | Mira + Gus + Mr. Byte | ArcadeHub, Maintenance Hall, Cabinet Row | Required | Confirms a missing closing shift and gives Gus a reason to inspect staff systems. | `circuit_soda_completed`. | Planned: `lost_shift_file_completed` | Gus: "That shift was never closed. It was hidden under a repair note." | Fractured staff pressure; unlocks Maintenance Sync in the expanded route. | 7-10 min |
| Staff Records Chain | Mr. Byte / Staff Door | Cabinet Row, Staff Corridor | Optional | Connects shift file, badge number, tape damage, and Employee 04 foreshadowing. | After Lost Shift File or post-reveal. | Planned: `staff_records_chain_completed` | Mr. Byte: "Record complete enough to hurt." | No gate; increases reveal clarity. | 5-7 min |
| Post-Reveal Witness Route | Mira, Gus, Vendo, Mr. Byte, Roxy, Pip | All active maps | Optional | Gives each witness one direct post-reveal truth or apology. | `twist_reveal_seen`. | Planned: `post_reveal_witness_route_completed` | Mira: "I knew you as a coworker before I knew you as a ghost." | Restored emotional closure. | 8-12 min |
| Owner Portrait Chain | Owner Portrait | ArcadeHub, Staff Corridor, Staff Room | Optional | Lets the "04" clue become more readable across Memory Signal states. | Available from start. | `owner_portrait_secret_found`, `echo_owner_portrait_04_seen` | "The name was never gone. It waited until you could read it." | State-based text only. | 4-6 min |
| Broken Cabinet Chain | Broken Cabinet | ArcadeHub / Cabinet Row | Optional | Shows failed resets and corrupted cabinet memory without adding another minigame. | `lying_cabinets_completed`. | Planned: `broken_cabinet_chain_completed` | "RESET FAILED. EMPLOYEE SIGNAL RETURNED." | Fractured flavor only. | 4-6 min |
| Vendo Memory Cola Riddle | Vendo | ArcadeHub / Snack Alcove | Optional | Rewards noticing Vendo's product clues and names memory through a small riddle. | Route progress and repeated Vendo dialogue. | `vendo_memory_riddle_secret_found` | Vendo: "MEMORY COLA DISPENSED." | No required change. | 2-4 min |

## Required Lore Quest: Lost Shift File

Route:
1. Mira admits the old closing sheet has a blank shift.
2. Gus says the repair log hid a staff door alert under routine maintenance.
3. Mr. Byte compares the clock-in record and finds "Employee 04" damaged or withheld.
4. Return to Gus to authorize Maintenance Sync.

Design notes:
- This should feel like reading 3 short clues, not collecting 3 items.
- The player should not carry a file in inventory.
- Use objective text such as "Ask Gus about the missing shift" and "Ask Mr. Byte to compare the record."
- Completion should make Maintenance Sync feel earned.

Planned flags:
- `lost_shift_file_started`
- `lost_shift_file_mira_seen`
- `lost_shift_file_gus_seen`
- `lost_shift_file_mr_byte_seen`
- `lost_shift_file_completed`

Completion line:
- Gus: "That shift was never closed. It was hidden under a repair note."

## Optional Lore Quest: Staff Records Chain

Route:
1. Read Mr. Byte's partial staff index.
2. Inspect Staff Door denial text after Security Tape Assembly.
3. Recheck Mr. Byte or Staff Corridor terminal post-reveal for the completed record.

Design notes:
- This should make the reveal cleaner for curious players.
- It should not be required proof.
- Do not add a full employee database.

Planned flags:
- `staff_records_chain_started`
- `staff_records_index_seen`
- `staff_records_door_seen`
- `staff_records_chain_completed`

Completion line:
- Mr. Byte: "Record complete enough to hurt."

## Optional Lore Quest: Post-Reveal Witness Route

Route:
1. Talk to Mira after reveal.
2. Talk to Gus after reveal.
3. Talk to Vendo after reveal.
4. Talk to Mr. Byte after reveal.
5. Optional: talk to Roxy and Pip if their maps are available.

Design notes:
- Each witness gets 1-3 short lines.
- No one should recap the whole plot.
- This route is emotional closure, not a second ending.

Planned flags:
- `post_reveal_mira_witness_seen`
- `post_reveal_gus_witness_seen`
- `post_reveal_vendo_witness_seen`
- `post_reveal_mr_byte_witness_seen`
- `post_reveal_roxy_witness_seen`
- `post_reveal_pip_witness_seen`
- `post_reveal_witness_route_completed`

Completion line:
- Mira: "I knew you as a coworker before I knew you as a ghost."

## Acceptance Checklist
- The required lore quest unlocks a required next step.
- Optional lore does not block Staff Room reveal.
- Every lore quest has a completion flag.
- Every lore quest has a short completion anecdote.
- Each lore interaction is short enough to read without becoming a document screen.
- Save/load preserves partial progress or safely repeats harmless clue text.
