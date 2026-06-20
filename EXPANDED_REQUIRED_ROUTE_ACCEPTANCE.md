# Expanded Required Route Acceptance

## Status
- Implementation status: expanded required route implemented with placeholder visuals.
- Acceptance status: not accepted yet.
- Required verification: full live Godot viewport playthrough.
- Scope: required route only. Roxy, Pip, Prize Sort, Broken High Score, and other optional secrets must not be required.
- Do not mark accepted unless a live Godot playthrough has actually passed.

## Final Gate Results
- Date: 2026-06-20.
- Method: Codex/Godot 4.7 headless smoke plus static route review. This is not a live viewport playthrough.
- Scene path smoke: PASS. All required route scenes listed in `scripts/qa/ScenePathSmoke.gd` exist.
- Required route state smoke: PASS. Simulated route advances from `Main: 0 / 10` on New Memory to `Main: 10 / 10` after `twist_reveal_seen`.
- Headless scene open smoke: PASS for Main, ArcadeHub, CabinetRow, SnackAlcove, MaintenanceHall, StaffCorridor, StaffRoom, RockbyteDuel, TruthFilter, CircuitSoda, StaticServiceRun, SyncDoorPuzzle, SecurityTapeAssembly, FinalNightWalk, MemoryEcho, SlideshowCutscene, and EndingPrompt.
- Blocker fixed during this gate: `scripts/CircuitSoda.gd` had a Godot 4.7 parse error from inferred `next_pos`; it now uses an explicit `Vector2i` type.
- README status: unchanged because the required full live Godot viewport playthrough has not passed yet.

## Setup
- Run from `res://scenes/main/Main.tscn` in Godot 4.x.
- Start from a clean `New Memory` slot.
- Use `Esc -> Save` and `Esc -> Load` at every checkpoint.
- Record any script error, scene path error, soft lock, missing objective update, missing flag, or save/load mismatch.

## Required Route Order
- Step 1: Rockbyte Duel.
- Step 2: Truth Filter.
- Step 3: Circuit Soda.
- Step 4: Lost Shift File.
- Step 5: Static Service Run.
- Step 6: Maintenance Sync.
- Step 7: Security Tape Assembly.
- Step 8: Final Night Walk.
- Step 9: Memory Echo.
- Step 10: Staff Room Reveal.

## Critical Pass Route
This is the minimum route needed to prove the required game can be completed end to end.

- Start a clean `New Memory` slot from `res://scenes/main/Main.tscn`.
- Talk to Mira, start the Lost Token quest, complete Rockbyte Duel, and return the Lost Token to Mira.
- Go to Cabinet Row, talk to Mr. Byte, complete Truth Filter, and confirm Memory Signal becomes `Fractured`.
- Go to Snack Alcove, talk to Vendo, and complete Circuit Soda.
- Read all Lost Shift File records: Closing Checklist, Maintenance Note, and Staff Schedule.
- Go to Maintenance Hall, talk to Gus, complete Static Service Run, then complete Maintenance Sync.
- Enter Staff Corridor and confirm Memory Echo blocks until Security Tape Assembly and Final Night Walk are complete.
- Complete Security Tape Assembly.
- Complete Final Night Walk.
- Complete Memory Echo.
- Enter Staff Room and complete the reveal slideshow.
- Choose `Save and Continue`, return to ArcadeHub, save/load, and confirm post-reveal roam works.

## Full Completion Route
Use this when validating the required route plus optional progression.

- Complete the full required playtest script below.
- Complete Broken High Score and confirm Optional progress increments.
- Complete Prize Sort and confirm Optional progress increments.
- Find available secrets and confirm Secrets progress increments separately from Main and Optional progress.
- After post-reveal roam unlocks, talk to remaining witnesses and confirm post-reveal interactions still work.
- Save/load after optional progress and confirm required completion, optional completion, secrets, Memory Signal, and post-reveal state persist.

## Act 1: Lost Token
1. Start a New Memory.
2. Confirm the opening intro plays.
3. Confirm ArcadeHub loads.
4. Confirm the objective points to Mira.
5. Talk to Mira.
6. Confirm Mira starts the Lost Token quest.
7. Confirm the objective points to Cabinet 07.
8. Interact with Cabinet 07.
9. Confirm `res://scenes/minigames/RockbyteDuel.tscn` opens.
10. Complete Rockbyte Duel.
11. Return to ArcadeHub cleanly.
12. Confirm the objective points to Mira.
13. Return the Lost Token to Mira.
14. Confirm Memory Signal becomes `Uneasy`.
15. Talk to Mira again and confirm the one-time Lost Token anecdote:
    - `You brought it back.`
    - `That token used to be just a prize.`
    - `Then it became proof that part of you could still return.`
    - `It remembered you before you did.`
16. Talk to Mira again and confirm shorter repeat lines appear.
17. Save and load.
18. Confirm Lost Token completion, Memory Signal, objective, and `mira_rockbyte_anecdote_seen` persist.

## Act 2: Truth Filter and Circuit Soda
19. Confirm the objective points to `Find Mr. Byte in Cabinet Row`.
20. Go to Cabinet Row.
21. Talk to Mr. Byte.
22. Confirm Mr. Byte introduces Truth Filter:
    - `Contradiction threshold reached.`
    - `Truth Filter is ready.`
    - `Please choose the least broken answer.`
23. Interact with the Truth Filter cabinet.
24. Confirm `res://scenes/minigames/TruthFilter.tscn` opens.
25. Complete Truth Filter.
26. Return to Cabinet Row or ArcadeHub cleanly.
27. Confirm Memory Signal becomes `Fractured`.
28. Talk to Mr. Byte and confirm the one-time Truth Filter anecdote:
    - `Truth Filter passed.`
    - `Contradictions remain.`
    - `That means the memory is alive enough to argue.`
    - `Record conflict reduced. Identity conflict remains.`
29. Talk to Mr. Byte again and confirm shorter repeat lines appear.
30. Save and load.
31. Confirm Truth Filter completion, Memory Signal, objective, and `mr_byte_truth_filter_anecdote_seen` persist.
32. Confirm the objective points to `Find Vendo in the Snack Alcove`.
33. Go to Snack Alcove.
34. Talk to Vendo.
35. Confirm Vendo introduces Circuit Soda:
    - `Memory Signal: Fractured.`
    - `Your signal is going everywhere except where it should.`
    - `Luckily, I am a licensed beverage-adjacent routing system.`
36. Interact with the Circuit Soda machine.
37. Confirm `res://scenes/minigames/CircuitSoda.tscn` opens.
38. Complete Circuit Soda.
39. Return to Snack Alcove cleanly.
40. Talk to Vendo and confirm the one-time Circuit Soda anecdote:
    - `Signal routed.`
    - `Unfortunately, routed does not mean understood.`
    - `Mira and Gus have records. Try not to enjoy paperwork.`
41. Talk to Vendo again and confirm shorter repeat lines appear.
42. Save and load.
43. Confirm Circuit Soda completion, objective, and `vendo_circuit_anecdote_seen` persist.

## Lore Quest: Lost Shift File
44. Confirm the objective reads `Objective: Find the Lost Shift File.`
45. Go to Maintenance Hall.
46. Try Maintenance Sync before reading the Lost Shift File.
47. Confirm the Maintenance Sync object blocks with:
    - `MAINTENANCE SYNC LOCKED.`
    - `LOST SHIFT FILE REQUIRED.`
48. Talk to Gus and confirm:
    - `I can help with the door.`
    - `But not until you know what shift you are standing in.`
    - `Find the Lost Shift File first.`
49. Read the Maintenance Note and confirm `maintenance_note_read` is true.
50. Return to ArcadeHub.
51. Read the Closing Checklist and confirm `closing_checklist_read` is true.
52. Go to Cabinet Row.
53. Read the Staff Schedule and confirm `staff_schedule_read` is true.
54. Confirm `lost_shift_file_completed` is true.
55. Confirm the completion notice appears:
    - `LOST SHIFT FILE COMPLETE`
    - `Employee 04 was assigned to Cabinet shutdown.`
56. Save and load.
57. Confirm Lost Shift File completion, all note-read flags, and objective persist.

## Arcade Adventure: Static Service Run
58. Confirm the objective points to `Restore service power with Gus`.
59. Go to Maintenance Hall.
60. Talk to Gus.
61. Confirm Gus starts Static Service Run after the Lost Shift File context.
62. Confirm `res://scenes/minigames/StaticServiceRun.tscn` opens.
63. Collect 3 Signal Fuses.
64. Touch one static leak and confirm:
    - `STATIC DISCHARGE.`
    - `Signal reset.`
65. Reach the breaker panel and confirm:
    - `SERVICE POWER RESTORED.`
    - `STAFF DOOR SYSTEMS ONLINE.`
    - `MAINTENANCE SYNC AVAILABLE.`
66. Return to Maintenance Hall cleanly.
67. Talk to Gus and confirm the one-time Static Service Run anecdote:
    - `Power's back.`
    - `Door's awake.`
    - `Now the hard part: making it listen without letting it answer too much.`
68. Save and load.
69. Confirm Static Service Run completion, objective, and `gus_static_run_anecdote_seen` persist.

## Maintenance Sync
70. Confirm Maintenance Sync now launches.
71. Complete Maintenance Sync.
72. Return to Maintenance Hall cleanly.
73. Confirm Memory Signal becomes `Overloaded`.
74. Confirm Staff Corridor unlocks.
75. Talk to Gus and confirm the one-time Maintenance Sync anecdote:
    - `Door's listening now.`
    - `I do not like doors that listen.`
    - `But if it opens, part of you matched something it lost.`
    - `Door heard both knocks. Yours, and the one you forgot making.`
76. Talk to Gus again and confirm shorter repeat lines appear.
77. Save and load.
78. Confirm Maintenance Sync completion, Staff Corridor unlock, Memory Signal, objective, and `gus_sync_anecdote_seen` persist.
79. Confirm the objective points to `Enter the Staff Corridor`.
80. Enter Staff Corridor.

## Security Tape Assembly
81. Interact with Memory Echo and confirm it blocks with:
    - `MEMORY ECHO LOCKED.`
    - `SECURITY TAPE REQUIRED.`
82. Interact with Security Tape.
83. Confirm `res://scenes/minigames/SecurityTapeAssembly.tscn` opens.
84. Submit a wrong order and confirm:
    - `TIMESTAMP CONFLICT.`
    - `The tape rewinds.`
85. Submit the correct order:
    - `Counter lights shut off.`
    - `Cabinet 07 remains powered.`
    - `A staff member enters the back hall.`
    - `The Staff Door records two signals.`
86. Confirm completion text:
    - `TAPE ORDER RESTORED.`
    - `FINAL NIGHT SEQUENCE PARTIAL.`
    - `THE STAFF DOOR DID NOT RECORD A CUSTOMER.`
87. Return to Staff Corridor cleanly.
88. Save and load.
89. Confirm Security Tape completion, wrong-order count, and objective persist.
90. Confirm the objective points to `Walk the Final Night route`.

## Arcade Adventure: Final Night Walk
91. Interact with Memory Echo and confirm it blocks with:
    - `MEMORY ECHO LOCKED.`
    - `FINAL NIGHT WALK REQUIRED.`
92. Interact with Final Night Walk.
93. Confirm `res://scenes/minigames/FinalNightWalk.tscn` opens.
94. Try collecting a Memory Frame out of order and confirm:
    - `TIMESTAMP CONFLICT.`
    - `The memory rewinds.`
95. Collect the four Memory Frames in order.
96. Reach the exit and confirm:
    - `FINAL NIGHT ROUTE STABILIZED.`
    - `MEMORY ECHO AVAILABLE.`
    - `THE STAFF DOOR DID NOT RECORD A CUSTOMER.`
97. Return to Staff Corridor cleanly.
98. Save and load.
99. Confirm Final Night Walk completion, objective, and `staff_door_final_walk_anecdote_seen` behavior persist.
100. Confirm the objective points to `Stabilize the Memory Echo`.

## Memory Echo
101. Interact with Memory Echo.
102. Confirm `res://scenes/cutscenes/MemoryEcho.tscn` opens.
103. Choose one wrong answer.
104. Confirm wrong choice shows:
    - `MEMORY SIGNAL SPIKED.`
    - `TRY AGAIN.`
105. Confirm the same question retries.
106. Complete all three Memory Echo prompts with the preferred answers:
    - Echo 1: `Maybe. I do not remember.`
    - Echo 2: `Because I was not ready.`
    - Echo 3: `Both, somehow.`
107. Confirm completion text:
    - `MEMORY ECHO STABILIZED.`
    - `RESTORE PLAYBACK AVAILABLE.`
108. Return to Staff Corridor cleanly.
109. Confirm the objective points to `Enter the Staff Room`.
110. Interact with Memory Echo again and confirm the one-time Memory Echo anecdote:
    - `Echo stabilized.`
    - `The arcade stops arguing with itself.`
    - `That might be worse.`
111. Interact with Memory Echo again and confirm shorter repeat lines appear:
    - `Echo stable.`
    - `Quiet is not always better.`
112. Save and load.
113. Confirm Memory Echo completion, Staff Room objective, and `memory_echo_anecdote_seen` persist.

## Staff Room Reveal
114. Interact with the Staff Room door.
115. Confirm it says:
    - `RESTORE PLAYBACK AVAILABLE.`
    - `ENTER STAFF ROOM?`
116. Confirm `res://scenes/arcade/StaffRoom.tscn` opens.
117. Interact with the Staff Room terminal.
118. Confirm the pre-reveal terminal dialogue starts normally.
119. Advance through the full reveal slideshow.
120. Confirm missing reveal art uses placeholders without blocking progression.
121. Confirm `twist_reveal_seen` is set after the slideshow.
122. Confirm the EndingPrompt appears.

## Ending / Post-Reveal Roam
123. Choose `Save and Continue`.
124. Confirm the game returns to ArcadeHub in Post-Reveal Roam.
125. Save and load.
126. Confirm reveal, ending, post-reveal state, and required route completion persist.
127. Confirm post-reveal NPC/object interactions still work.

## Early Reveal Gate
Run this once with a debug jump, old save, or temporary forced scene entry.

- Enter `res://scenes/arcade/StaffRoom.tscn` before `memory_echo_completed` is true.
- Interact with the terminal.
- Confirm the reveal does not start.
- Confirm the terminal says:
   - `RESTORE PLAYBACK LOCKED.`
   - `MEMORY ECHO REQUIRED.`
- Confirm no script error or soft lock occurs.
- Load or return to the normal route and complete Memory Echo.
- Enter Staff Room again.
- Confirm the reveal can start normally.

## Save/load Checkpoints
Save and load at these exact checkpoints:
- After Lost Token completion.
- After Truth Filter completion.
- After Circuit Soda completion.
- After one or two Lost Shift File notes have been read.
- After Lost Shift File completion.
- After Static Service Run completion.
- After Maintenance Sync completion.
- After Security Tape Assembly completion.
- After Final Night Walk completion.
- After Memory Echo completion.
- After reveal / Save and Continue.

Each checkpoint must preserve:
- Relevant completion flags.
- Relevant anecdote flags.
- Current objective.
- Memory Signal label.
- Route access locks and unlocks.
- Save slot summary values:
  - `Main: x / 10`
  - `Optional: x / 2`
  - `Secrets: x / y`
  - `Signal: [Memory Signal]`
  - `Last Saved: [timestamp]`

## Optional Content Smoke Test
Optional content must not block the required route.

- Complete Broken High Score.
- Save and load.
- Confirm Optional progress increments by one and Main progress does not change.
- Complete Prize Sort.
- Save and load.
- Confirm Optional progress increments to `2 / 2` and Main progress does not change.
- Find a secret.
- Save and load.
- Confirm Secrets progress increments and Main/Optional progress do not change.
- Confirm Roxy, Pip, Prize Sort, Broken High Score, and other optional secrets are not required for Staff Room Reveal.

## Required Owners and Completion Dialogue
Every required quest must have an owner and a completion story beat:

| Required Step | Owner | Location | Completion Flag | Anecdote Flag |
| --- | --- | --- | --- | --- |
| Rockbyte Duel / Lost Token | Mira | ArcadeHub | `lost_token_quest_completed` | `mira_rockbyte_anecdote_seen` |
| Truth Filter | Mr. Byte | Cabinet Row | `lying_cabinets_completed` | `mr_byte_truth_filter_anecdote_seen` |
| Circuit Soda | Vendo | Snack Alcove | `circuit_soda_completed` | `vendo_circuit_anecdote_seen` |
| Lost Shift File | Mira / Gus / Mr. Byte | ArcadeHub / Cabinet Row / Maintenance Hall | `lost_shift_file_completed` | `mira_lost_shift_intro_seen`, `gus_lost_shift_comment_seen`, `mr_byte_lost_shift_comment_seen` |
| Static Service Run | Gus | Maintenance Hall | `static_service_run_completed` | `gus_static_run_anecdote_seen` |
| Maintenance Sync | Gus | Maintenance Hall | `maintenance_sync_completed` | `gus_sync_anecdote_seen` |
| Security Tape Assembly | Staff Door / Mr. Byte | Staff Corridor | `security_tape_assembly_completed` | None |
| Final Night Walk | Staff Door / Memory System | Staff Corridor | `final_night_walk_completed` | `staff_door_final_walk_anecdote_seen` |
| Memory Echo | Memory Echo | Staff Corridor | `memory_echo_completed` | `memory_echo_anecdote_seen` |
| Staff Room Reveal | Staff Room Terminal | Staff Room | `twist_reveal_seen` | None |

## Pass Criteria
- No script errors.
- No scene path errors.
- No missing GameState flags.
- No soft locks or dead-end rooms.
- No save/load regression at any checkpoint.
- Objective text always points to the next required owner and location.
- Save slots accurately separate Main, Optional, and Secrets progress.
- Every required quest has an owner.
- Every required quest has completion dialogue.
- Every required owner switches to shorter repeat lines after the anecdote flag is set.
- Memory Signal changes are clear: `Grounded -> Uneasy -> Fractured -> Overloaded`.
- Staff Room reveal cannot happen before Memory Echo completion.
- Optional Roxy/Pip content is not required.
- Full route feels coherent and longer than the MVP without feeling padded.

## Failure Triage
If the route fails, fix in this order:

- Script errors, missing methods, or missing GameState flags.
- Scene path or transition errors.
- Save/load state loss.
- Objective text pointing to the wrong owner or location.
- Missing required completion dialogue.
- Staff Room reveal bypassing Memory Echo.
- Optional content accidentally blocking the required route.
- Pacing issues where a required puzzle feels like filler.
