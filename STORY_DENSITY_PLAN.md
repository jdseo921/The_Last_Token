# Story Density Plan

## Purpose
Keep a 45-75 minute version of The Last Token dense, readable, and emotionally clear without turning it into a lore dump.

## Density Rules
- Keep dialogue short.
- Give every required puzzle one story job.
- Give every required puzzle an owner reaction afterward.
- Use lore-reading quests to change player understanding, not to decorate the world.
- Let repeated object text carry clues over time.
- Optional content can deepen the mystery, but the main reveal must work without it.

## Emotional Throughline
1. Grounded: "I know this place. I do not know why."
2. Uneasy: "The machines remember me."
3. Fractured: "The records and people remember different versions."
4. Staff-record pressure: "A shift went missing, and someone hid it."
5. Overloaded: "The door is listening to more than one version of me."
6. Conscience: "The other signal is my regret, not another person."
7. Restored: "I was Employee 04."

## Required Story Jobs

| Content | Owner | Story Job | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Rockbyte Duel | Mira / Cabinet 07 | A machine returns something that belongs to the player. | Story started. | `rockbyte_duel_completed`, `lost_token_quest_completed` | Mira: "It remembered you before you did." | Grounded -> Uneasy. | 6-8 min |
| Truth Filter | Mr. Byte | Contradictions become evidence instead of noise. | `lost_token_quest_completed`. | `lying_cabinets_completed` | Mr. Byte: "Contradiction preserved." | Uneasy -> Fractured. | 6-8 min |
| Circuit Soda | Vendo | Identity can be routed, mislabeled, and recognized anyway. | `lying_cabinets_completed`. | `circuit_soda_completed` | Vendo: "Your label is still missing." | Fractured pressure rises. | 6-8 min |
| Lost Shift File | Mira + Gus + Mr. Byte | A missing staff shift is confirmed by multiple sources. | `circuit_soda_completed`. | Planned: `lost_shift_file_completed` | Gus: "That shift was never closed." | Staff-record suspicion becomes explicit. | 7-10 min |
| Static Service Run | Gus | The abstract door problem becomes a physical service-power task. | `lost_shift_file_completed`. | `static_service_run_completed` | Gus: "Power's back." | Fractured stays active. | 5-7 min |
| Maintenance Sync | Gus | Two unstable signals must align before staff systems respond. | `static_service_run_completed`. | `maintenance_sync_completed`, `story_puzzle_completed` | Gus: "Door heard both knocks." | Fractured -> Overloaded. | 6-8 min |
| Security Tape Assembly | Staff Door / Mr. Byte | The player sees proof of entering the back room without the full name reveal. | `maintenance_sync_completed`. | `security_tape_assembly_completed` | Staff Door: "CUSTOMER RECORD NOT FOUND." | Overloaded pressure rises. | 6-9 min |
| Final Night Walk | Staff Door / Memory System | The player physically walks through the reconstructed past before identity stabilization. | `security_tape_assembly_completed`. | `final_night_walk_completed` | Staff Door: "ONE WALKED IN. TWO SIGNALS ANSWERED." | Overloaded pressure rises. | 5-8 min |
| Memory Echo | Memory Echo | The player stabilizes enough to survive the reveal. | `final_night_walk_completed`. | `memory_echo_completed` | Memory Echo: "The arcade stops arguing with itself." | Staff Room playback allowed. | 5-7 min |
| Conscience Encounters | ??? / `"Player"` | Recurring regret starts hostile, becomes useful, and names itself after the reveal slideshow. | Route milestones after Truth Filter, Circuit Soda, Lost Shift File, Final Night Walk, and Staff Room reveal. | `conscience_final_room_seen`, `player_glitched_form_unlocked` | `"Player"`: "Then carry it." | Overloaded emotional pressure, no progress-count change. | 5-8 min total |
| Staff Room Reveal | Staff Room | Employee 04 is named and prior clues resolve. | `memory_echo_completed`. | `twist_reveal_seen`, `post_reveal_roam_unlocked` | Player: "It was my name tag." | Overloaded -> Restored. | 6-8 min |

## Lore-Reading Story Jobs

| Lore Quest | Owner | Required | Story Purpose | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Lost Shift File | Mira + Gus + Mr. Byte | Yes | Confirms a hidden staff shift and justifies entering maintenance. | `circuit_soda_completed`. | Planned: `lost_shift_file_completed` | Mira: "I remember locking up. I do not remember locking you in." | Fractured staff pressure. | 7-10 min |
| Staff Records Chain | Mr. Byte / Staff Door | No | Connects shift file, badge number, and tape damage for careful readers. | After Lost Shift File or post-reveal. | Planned: `staff_records_chain_completed` | Mr. Byte: "Record complete enough to hurt." | No gate; improves comprehension. | 5-7 min |
| Post-Reveal Witness Route | Core NPCs | No | Lets each witness acknowledge what they knew or avoided. | `twist_reveal_seen`. | Planned: `post_reveal_witness_route_completed` | Mira: "I knew you as a coworker before I knew you as a ghost." | Restored closure. | 8-12 min |

## Optional Story Jobs

| Content | Owner | Story Job | Unlock | Completion Flag | Completion Dialogue / Anecdote | Memory Signal Effect | Est. Time |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Broken High Score | Roxy | The player's score can return while the name stays blank. | `rockbyte_duel_completed`. | `broken_high_score_completed` | Roxy: "Score came back. Name stayed blank." | No required change. | 5-7 min |
| Prize Sort | Pip | Tokens, prizes, and badge memories have an order. | `lying_cabinets_completed` or post-reveal. | `prize_sort_completed`, `pip_secret_completed` | Pip: "Some rewards remember their owner." | No required change. | 4-6 min |
| Owner Portrait Chain | Owner Portrait | The "04" clue becomes readable over time. | Start; changes by state. | `owner_portrait_secret_found`, `echo_owner_portrait_04_seen` | "The letters no longer hide." | State-based text only. | 4-6 min |
| Broken Cabinet Chain | Broken Cabinet | Failed reset echoes imply this has happened before. | `lying_cabinets_completed`. | Planned: `broken_cabinet_chain_completed` | "RESET FAILED. EMPLOYEE SIGNAL RETURNED." | Fractured flavor. | 4-6 min |
| Vendo Memory Cola Riddle | Vendo | A small riddle uses product language to name memory directly. | Route progress and repeated Vendo dialogue. | `vendo_memory_riddle_secret_found` | Vendo: "MEMORY COLA DISPENSED." | No required change. | 2-4 min |

## Memory Signal Text Use

### Grounded
- Mira is gentle.
- Cabinet 07 is strange but simple.
- Objects mostly describe what they are.

### Uneasy
- Mr. Byte can mention mismatch, conflict, and damaged records.
- Mira can admit she remembers the player too clearly.
- Objects start adding one extra unsettling detail.

### Fractured
- Vendo and Gus become more important.
- Lore-reading starts to matter.
- Object text can mention shifts, labels, badges, or reset damage.

### Overloaded
- Staff systems become direct.
- Dialogue gets shorter and sharper.
- Security Tape Assembly and Memory Echo should avoid jokes except tiny breathers.
- The conscience can almost say the truth, but the `"Player"` name waits until after the Staff Room reveal slideshow.

### Restored
- NPCs can say Employee 04.
- Optional Witness Route resolves personal angles.
- Object text can stop hiding the meaning.

## Repetition Rules
- First interaction: story or flavor.
- Second interaction: alternate flavor or reminder.
- Third and later interactions: clear objective nudge.
- Post-completion: owner anecdote once, then short repeat.
- Post-reveal: replace evasive hints with direct acknowledgement.

## Anti-Lore-Dump Checklist
- Does this beat reveal one useful thing, not five?
- Does it point to a next action or sharpen the player's theory?
- Could the same information be delivered through an object, owner line, or puzzle rule instead of a paragraph?
- Does optional lore stay optional?
- Does the Employee 04 reveal still land in Staff Room?
