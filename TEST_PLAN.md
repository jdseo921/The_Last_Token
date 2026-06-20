# TEST_PLAN.md

## Test Rules
- Test in Godot 4.x from `res://scenes/main/Main.tscn`.
- Godot 4.7.x is the current local test target because the project feature tag is `4.7`.
- Keep the test focused on the playable MVP path, not polish.
- Fix blockers before adding new content.
- Missing art/audio placeholders are acceptable if they do not break play.
- See `QA_AUTOMATION.md` before running Codex/Godot automation. Headless scene checks are smoke tests only; live playthrough gates still require the Godot viewport.

## Local Run And Export Readiness
1. Open Godot Project Manager.
2. Import this folder's `project.godot`.
3. Confirm the main scene is `res://scenes/main/Main.tscn`.
4. Press Play and confirm the Title Menu appears.
5. Confirm no required art/audio files are missing in a way that blocks launch.
6. Open `Project -> Export`.
7. If `export_presets.cfg` is absent, add a `Windows Desktop` preset manually.
8. Install Godot export templates if prompted.
9. Export a local Windows build outside the repo or into an ignored build folder.
10. Do not commit generated `.exe`, `.pck`, or large build output files.

## Expanded Required Route Acceptance
- Current end-to-end acceptance gate: `EXPANDED_REQUIRED_ROUTE_ACCEPTANCE.md`.
- Run this from a clean `New Memory` after the smaller Act 2 slice tests pass.
- The route is:
  1. Opening intro and Lost Token / Rockbyte Duel with Mira.
  2. Truth Filter with Mr. Byte in Cabinet Row.
  3. Circuit Soda with Vendo in Snack Alcove.
  4. Lost Shift File with Mira, Gus, and Mr. Byte.
  5. Static Service Run with Gus in Maintenance Hall.
  6. Maintenance Sync with Gus in Maintenance Hall.
  7. Security Tape Assembly in Staff Corridor.
  8. Final Night Walk in Staff Corridor.
  9. Memory Echo dialogue-choice sequence in Staff Corridor.
  10. Staff Room reveal, EndingPrompt, and Post-Reveal Roam.
- Save/load checkpoints are required after Lost Token, Truth Filter, Circuit Soda, Lost Shift File, Static Service Run, Maintenance Sync, Security Tape Assembly, Final Night Walk, Memory Echo, and the reveal.
- Pass criteria:
  - No scene path errors.
  - No missing GameState flags.
  - No save/load regression.
  - Objective text always points to the next required owner and location.
  - Each quest owner gives completion dialogue, then shorter repeat lines.
  - Staff Room reveal cannot happen before Memory Echo completion.
  - Optional content is not required.
  - The expanded route feels longer than the original MVP without feeling padded.

## Final Expanded Route Gate Result
- Date: 2026-06-20.
- Method: Codex/Godot 4.7 headless smoke plus static route review. This is not a live viewport playthrough.
- Scene path smoke: PASS via `scripts/qa/ScenePathSmoke.gd`.
- Required route state smoke: PASS via `scripts/qa/RequiredRouteStateSmoke.gd`; the simulated route reaches `Main: 10 / 10` only after `twist_reveal_seen`.
- Headless scene open smoke: PASS for every required route scene, including Circuit Soda after the parser blocker fix.
- Blocker fixed: `scripts/CircuitSoda.gd` had a Godot 4.7 parse error from inferred `next_pos`; it now uses an explicit `Vector2i` type.
- README status: unchanged because live Godot viewport acceptance has not passed yet.

## Live Runtime QA Result
- Requested live route: Title Menu through Post-Reveal Roam save/load.
- Result: blocked before step 1 in this environment.
- Reason: no Godot executable was available on PATH, and no `Godot*.exe` was found in common local install/download locations.
- Steps passed live: none. The game was not launched.
- Runtime fixes made in this pass: none.
- Remaining runtime issues: unknown until the project is opened and played in Godot.
- Do not treat the MVP as live-verified until the full route below passes in the Godot runtime.

## Publish-Readiness Polish Pass
- Date: 2026-06-19
- Scope: title menu, memory slots, ArcadeHub hints/labels, dialogue box, Rockbyte Duel, Sync Door, reveal slideshow, and ending prompt.
- Live full-route result: not completed; the 31-step interactive route still needs a human viewport playthrough.
- Headless smoke result: passed with Godot 4.7 console using project open, brief default run, and direct `res://scenes/main/Main.tscn` launch.
- README status: unchanged because the full live route has not passed.

## First Quest Runtime QA Fix Pass
- Date: 2026-06-19
- Scope: Title Menu -> New Memory -> Opening intro -> Mira -> Lost Token quest -> Cabinet 07 -> Rockbyte Duel -> Lost Token recovered -> return to Mira -> quest complete -> save/load.
- Fix scope: first-quest blockers only.
- Gameplay changes made: none.
- Headless runtime result: passed for project open, `res://scenes/main/Main.tscn`, `res://scenes/arcade/ArcadeHub.tscn`, and `res://scenes/minigames/RockbyteDuel.tscn` using Godot 4.7 console.
- Static route review result: first-quest state transitions are wired. Mira starts the Lost Token quest, Cabinet 07 launches Rockbyte Duel, Rockbyte Duel win sets `rockbyte_duel_completed` and `lost_token_collected`, Mira completion sets `lost_token_quest_completed`, and these flags are included in save data.
- Save route note: the current MVP uses the pause menu for save/load. The Memory Terminal is not present in ArcadeHub, so first-quest save/load testing should use `Esc -> Save` and `Esc -> Load`.
- Full interactive result: not passed yet; a human viewport playthrough is still required to confirm movement, dialogue input, quest notice timing, Rockbyte losing/retrying/winning, and save/load restore from Slot 1.
- Remaining first-quest issues: no script or scene launch blocker found; live-only interaction issues remain unknown until manual playthrough.

## First Quest Save/Load Regression Pass
- Date: 2026-06-19
- Scope: first quest save/load only, Cases A-D.
- Gameplay changes made: none.
- Headless scene smoke result: passed for project open, `res://scenes/main/Main.tscn`, `res://scenes/arcade/ArcadeHub.tscn`, and `res://scenes/minigames/RockbyteDuel.tscn`.
- Automated state-runner result: blocked in this shell. A temporary QA scene and script were created, then removed; Godot crashed while opening `user://logs/...` before returning test results. This is the same local Godot logging crash seen with direct temporary scene/script runs.
- Static save/load review result: no first-quest save/load blocker found.
- Pass status: not marked fully passing because all four cases have not been completed in a live interactive Godot run.

### Case A - Before Quest
- Static result: expected pass.
- `SaveManager.start_new_memory()` resets `GameState`, writes Slot data, and preserves `story_started = false`, `lost_token_quest_started = false`, and `opening_intro_seen = false`.
- Loading that save restores the pre-quest state and `GameState.get_current_quest_id()` returns `opening_talk_to_mira`.
- Live result: still needs manual confirmation.

### Case B - Quest Started
- Static result: expected pass.
- Mira's first-quest dialogue still calls `GameState.start_lost_token_quest`.
- `lost_token_quest_started` is included in `GameState.to_save_data()` and restored in `apply_save_data()`.
- Loading this state should make `GameState.get_current_quest_id()` return `recover_lost_token`, and the ArcadeHub objective should read `Objective: Play Cabinet 07.`
- Live result: still needs manual confirmation.

### Case C - During/After Rockbyte
- Static result: expected pass.
- Saving while current scene is Rockbyte normalizes the saved scene to ArcadeHub through `SaveManager._get_current_save_scene_path()`, so an unfinished Rockbyte run restores safely instead of restoring into the minigame.
- Unfinished Rockbyte does not set `rockbyte_duel_completed` or `lost_token_collected`.
- Winning Rockbyte sets `rockbyte_duel_completed = true` and calls `GameState.collect_lost_token()`.
- Loading after victory should preserve both flags and make `GameState.get_current_quest_id()` return `return_lost_token`, with objective `Objective: Return the Lost Token to Mira.`
- Live result: still needs manual confirmation.

### Case D - Quest Completed
- Static result: expected pass.
- Mira's token-return dialogue still calls `GameState.complete_lost_token_quest`.
- Talking to Mira again after completion should show the one-time Rockbyte anecdote, then shorter repeat lines after `mira_rockbyte_anecdote_seen`.
- `lost_token_quest_completed`, `lost_token_collected`, `rockbyte_duel_completed`, and `mira_rockbyte_anecdote_seen` are saved and restored.
- Loading after completion should make `GameState.get_current_quest_id()` return `truth_filter`, with objective `Objective: Find Mr. Byte in Cabinet Row.`
- Because `rockbyte_duel_completed` persists, Cabinet 07 should not replay as incomplete.
- Live result: still needs manual confirmation.

## Memory Signal State Test
Memory Signal is a story signal, not a health meter or punishment system.

1. Start a New Memory.
2. Confirm `GameState.memory_signal_level == 0`.
3. Confirm `GameState.get_memory_signal_label()` returns `Grounded`.
4. Complete the Lost Token quest by returning the token to Mira.
5. Confirm `GameState.memory_signal_level == 1`.
6. Confirm `GameState.get_memory_signal_label()` returns `Uneasy`.
7. Save the game.
8. Load the same save.
9. Confirm Memory Signal is still `Uneasy`.
10. For future Act 2 tests, setting `truth_filter_quest_started` should make slot summaries show `Truth Filter`.
11. For future Act 2 tests, setting `lying_cabinets_completed` or `second_memory_fragment_collected` before Sync Door completion should make slot summaries show `Truth Filter Cleared`.

## Act 2 Truth Filter Test
Run this only after confirming the first quest still works.

1. Complete the Lost Token quest.
2. Confirm Memory Signal reads `Uneasy`.
3. Confirm the objective reads `Objective: Find Mr. Byte in Cabinet Row.`
4. Go to Cabinet Row.
5. Talk to Mr. Byte and confirm:
   - `Contradiction threshold reached.`
   - `Truth Filter is ready.`
   - `Please choose the least broken answer.`
6. Interact with the `TRUTH FILTER` cabinet.
7. Confirm `res://scenes/minigames/TruthFilter.tscn` opens.
8. Confirm instructions, rule text, three cabinet statements, and choice buttons are readable.
9. Pick one wrong answer and confirm retry works without hard-fail.
10. Complete all four rounds.
11. Confirm `lying_cabinets_completed` and `second_memory_fragment_collected` are true.
12. Confirm Memory Signal reads `Fractured`.
13. Return to Cabinet Row or ArcadeHub cleanly.
14. Confirm the objective reads `Objective: Find Vendo in the Snack Alcove.`
15. Talk to Mr. Byte and confirm the first-time anecdote:
   - `Truth Filter passed.`
   - `Contradictions remain.`
   - `That means the memory is alive enough to argue.`
   - `Record conflict reduced. Identity conflict remains.`
16. Talk to Mr. Byte again and confirm shorter repeat lines appear.
17. Save and load.
18. Confirm Truth Filter completion, Memory Signal, and `mr_byte_truth_filter_anecdote_seen` persist.

## Act 2 Circuit Soda Test
Run this after Truth Filter completion, when Memory Signal is `Fractured`.

1. Go to Snack Alcove.
2. Talk to Vendo.
3. Confirm Vendo introduces:
   - `Memory Signal: Fractured.`
   - `Your signal is going everywhere except where it should.`
   - `Luckily, I am a licensed beverage-adjacent routing system.`
4. Interact with the Circuit Soda machine.
5. Confirm `res://scenes/minigames/CircuitSoda.tscn` opens.
6. Rotate tiles in the 3x3 grid.
7. Confirm an incomplete route shows `Signal still misrouted.`
8. Complete all three rounds.
9. Confirm completion text:
   - `MEMORY FLOW RESTORED.`
   - `CARBONATION LEVEL: UNRELATED.`
   - `IDENTITY SIGNAL ROUTED.`
10. Return to Snack Alcove.
11. Talk to Vendo and confirm:
   - `Signal routed.`
   - `Unfortunately, routed does not mean understood.`
   - `Mira and Gus have records. Try not to enjoy paperwork.`
12. Talk to Vendo again and confirm shorter repeat lines appear.
13. Confirm the objective reads `Objective: Find Gus in Maintenance Hall.`
14. Save and load.
15. Confirm `circuit_soda_completed` and `vendo_circuit_anecdote_seen` persist.

## Lost Shift File Required Lore Quest Test
Run this after Circuit Soda completion and before Maintenance Sync.

1. Complete Circuit Soda.
2. Confirm the objective reads `Objective: Find the Lost Shift File.`
3. Talk to Mira and confirm:
   `Vendo routed the signal, but something is still missing.`
   `Gus keeps old maintenance notes.`
   `Mr. Byte can read staff records the machines refuse to say out loud.`
   `Find the Lost Shift File before you ask the door to listen.`
4. Interact with the Closing Checklist near the ticket counter or Staff Door.
5. Confirm it reads:
   `CLOSING CHECKLIST`
   `Final Night`
   `- Count tokens`
   `- Lock Cabinet Row`
   `- Check Staff Door`
   `- Employee 04: signature missing`
6. Confirm `closing_checklist_read` is true.
7. Go to Maintenance Hall.
8. Talk to Gus and confirm he points to the maintenance note instead of launching Maintenance Sync.
9. Interact with the Maintenance Note.
10. Confirm it reads:
   `MAINTENANCE NOTE`
   `Staff Door reported two signals after closing.`
   `One signal entered.`
   `One signal remained.`
   `Gus note: I do not get paid enough for doors with opinions.`
11. Confirm `maintenance_note_read` is true.
12. Go to Cabinet Row.
13. Talk to Mr. Byte and confirm he points to the staff schedule.
14. Interact with the Staff Schedule.
15. Confirm it reads:
   `STAFF SCHEDULE`
   `Final Night`
   `Mira - Counter`
   `Gus - Maintenance`
   `Employee 04 - Cabinet shutdown`
   `Status: unresolved`
16. Confirm `staff_schedule_read` is true.
17. After all three notes are read, confirm:
   `lost_shift_file_completed` is true.
   The completion text appears:
   `LOST SHIFT FILE COMPLETE`
   `Employee 04 was assigned to Cabinet shutdown.`
18. Confirm the objective becomes `Objective: Find Gus in Maintenance Hall.`
19. Talk to Mira and confirm:
   `That was the shift we stopped talking about.`
   `I am sorry you had to read it before you remembered it.`
20. Talk to Gus after completion and confirm:
   `Employee 04. Cabinet shutdown.`
   `Yeah. That is where the night went bad.`
21. Talk to Mr. Byte after completion and confirm:
   `Lost Shift File reconstructed.`
   `Identity reference remains restricted.`
22. Save and load.
23. Confirm these flags persist:
   `lost_shift_file_started`
   `lost_shift_file_completed`
   `closing_checklist_read`
   `maintenance_note_read`
   `staff_schedule_read`
   `mira_lost_shift_intro_seen`
   `gus_lost_shift_comment_seen`
   `mr_byte_lost_shift_comment_seen`
24. Confirm Maintenance Sync is available only after `lost_shift_file_completed`.
25. Confirm the quest does not reveal that the player is Employee 04.

## Act 2 Aftermath Echo Test
Run this after Truth Filter completion and before entering the Staff Room reveal.

1. Return to ArcadeHub after completing Truth Filter.
2. Confirm Memory Signal reads `Fractured`.
3. Talk to Mira and confirm Fractured-state dialogue or the ticket counter echo appears.
4. Interact with the Ticket Counter and confirm the reflection echo appears if it has not already been seen.
5. Talk to Gus and confirm he warns not to pick the loudest memory.
6. Talk to Vendo and confirm `Signal routed.` appears after Circuit Soda completion.
7. Talk to Mr. Byte in Cabinet Row and confirm `Truth Filter passed.` appears after Truth Filter completion.
8. Talk to Cabinet 07 and confirm its normal Fractured-state dialogue appears.
9. Confirm Cabinet 07's optional echo appears once:
   `PREVIOUS PLAYER PROFILE FOUND.`
   `STATUS: DAMAGED.`
   `RESTORE ATTEMPT: CONTINUING.`
10. Interact with Owner Portrait and confirm the shifted nameplate text ends with `0 4`.
11. Interact with Staff Door and confirm:
   `FRACTURED SIGNAL ACCEPTED.`
   `TWO-SIGNAL SYNC REQUIRED.`
12. Confirm Staff Door does not bypass the required Vendo and Gus route.
13. Save and load.
14. Confirm the echo flags do not replay if already seen.

## Static Service Run Required Arcade-Adventure Test
Run this after Lost Shift File completion and before Maintenance Sync, when Memory Signal is still `Fractured`.

1. Go to Maintenance Hall.
2. If Lost Shift File is not complete, talk to Gus and confirm Maintenance Sync does not launch.
3. Complete Lost Shift File.
4. Talk to Gus and confirm Static Service Run starts.
5. Confirm `res://scenes/minigames/StaticServiceRun.tscn` opens.
6. Confirm title and objective text explain:
   `STATIC SERVICE RUN`
   `Collect 3 Signal Fuses.`
   `Avoid static leaks.`
   `Reach the breaker panel.`
7. Collect 3 Signal Fuses.
8. Touch a static leak once and confirm:
   `STATIC DISCHARGE.`
   `Signal reset.`
9. Reach the breaker panel.
10. Confirm completion text:
   `SERVICE POWER RESTORED.`
   `STAFF DOOR SYSTEMS ONLINE.`
   `MAINTENANCE SYNC AVAILABLE.`
11. Confirm `static_service_run_started` is true.
12. Confirm `static_service_run_completed` is true.
13. Return to Maintenance Hall.
14. Talk to Gus and confirm:
   `Power's back.`
   `Door's awake.`
   `Now the hard part: making it listen without letting it answer too much.`
15. Save and load.
16. Confirm Static Service Run completion and `gus_static_run_anecdote_seen` persist.
17. Confirm Maintenance Sync is now available.

## Maintenance Sync: Gus Required Quest Test
Run this after Static Service Run completion, when Memory Signal is still `Fractured`.

1. Go to Maintenance Hall.
2. If Lost Shift File is not complete, talk to Gus and confirm Maintenance Sync does not launch.
3. If Static Service Run is not complete, interact with Maintenance Sync and confirm it blocks with:
   `MAINTENANCE SYNC LOCKED.`
   `STATIC SERVICE REQUIRED.`
4. Talk to Gus and confirm:
   `Power's back. Door's listening.`
   `I still hate that sentence.`
   `Two signals are fighting in the door.`
5. Confirm `res://scenes/arcade/SyncDoorPuzzle.tscn` opens as Maintenance Sync.
6. Confirm title reads `MAINTENANCE SYNC`.
7. Confirm instructions say:
   `MAINTENANCE SYNC`
   `Two signals must be active together.`
   `One signal remembers.`
   `One signal returns.`
8. Phase 1: activate Switch A and Switch B within 5 seconds.
9. Confirm Phase 2 begins and displays `WARNING: ONE LABEL IS REVERSED.`
10. Phase 2: observe Switch A label is reversed, then activate both real switches.
11. Confirm Phase 3 begins.
12. Phase 3: activate A, then B, then press `Confirm Sync` before either expires.
13. Let the timer expire once if practical and confirm:
   `Signal lost.`
   `Try again.`
14. Complete Phase 3 successfully.
15. Confirm success text:
   `TWO SIGNALS DETECTED.`
   `RESTORED SIGNAL PRESENT.`
   `MEMORY SIGNAL: OVERLOADED.`
   `ACCESS GRANTED.`
16. Confirm `GameState.maintenance_sync_started` is true.
17. Confirm `GameState.maintenance_sync_completed` is true.
18. Confirm `GameState.story_puzzle_completed` is true.
19. Confirm `GameState.staff_room_unlocked` is true.
20. Confirm Memory Signal reads `Overloaded`.
21. Return to Maintenance Hall.
22. Talk to Gus and confirm:
   `Door's listening now.`
   `I do not like doors that listen.`
   `But if it opens, part of you matched something it lost.`
   `Door heard both knocks. Yours, and the one you forgot making.`
23. Talk to Gus again and confirm shorter repeat lines appear.
24. Confirm the objective reads `Objective: Enter the Staff Corridor.`
25. Confirm Staff Corridor unlocks.
26. Save and load.
27. Confirm Maintenance Sync completion, Staff Corridor unlock, Staff Corridor objective, and `gus_sync_anecdote_seen` persist.

## Security Tape Assembly Required Puzzle Test
Run this after Maintenance Sync completion and before Memory Echo.

1. Complete Maintenance Sync.
2. Enter Staff Corridor.
3. Interact with Memory Echo before Security Tape Assembly.
4. Confirm Memory Echo blocks with:
   `MEMORY ECHO LOCKED.`
   `SECURITY TAPE REQUIRED.`
5. Interact with the Security Tape terminal.
6. Confirm `res://scenes/minigames/SecurityTapeAssembly.tscn` opens.
7. Confirm instructions say:
   `SECURITY TAPE ASSEMBLY`
   `Arrange the fragments in the order they happened.`
   `The tape is damaged, but not silent.`
8. Select a wrong order and submit.
9. Confirm:
   `TIMESTAMP CONFLICT.`
   `The tape rewinds.`
10. Confirm retry is available.
11. Submit a second wrong order if practical.
12. Confirm the hint appears:
   `The counter went dark before Cabinet 07 stayed awake.`
13. Submit the correct order:
   `Counter lights shut off.`
   `Cabinet 07 remains powered.`
   `A staff member enters the back hall.`
   `The Staff Door records two signals.`
14. Confirm completion text:
   `TAPE ORDER RESTORED.`
   `FINAL NIGHT SEQUENCE PARTIAL.`
   `THE STAFF DOOR DID NOT RECORD A CUSTOMER.`
15. Confirm `security_tape_assembly_started` is true.
16. Confirm `security_tape_assembly_completed` is true.
17. Confirm `security_tape_wrong_order_count` preserves wrong attempts.
18. Return to Staff Corridor.
19. Save and load.
20. Confirm Security Tape completion persists.
21. Confirm Final Night Walk is now available.
22. Confirm Employee 04 and the player's name are not fully revealed by this puzzle.

## Final Night Walk Required Arcade-Adventure Test
Run this after Security Tape Assembly completion and before Memory Echo.

1. Complete Security Tape Assembly.
2. Enter Staff Corridor.
3. Interact with Memory Echo before Final Night Walk.
4. Confirm Memory Echo blocks with:
   `MEMORY ECHO LOCKED.`
   `FINAL NIGHT WALK REQUIRED.`
5. Interact with the Final Night Walk terminal.
6. Confirm `res://scenes/minigames/FinalNightWalk.tscn` opens.
7. Confirm title and objective text explain:
   `FINAL NIGHT WALK`
   `Collect the Memory Frames.`
   `Do not let the rewind static touch you.`
8. Try collecting a Memory Frame out of order.
9. Confirm:
   `TIMESTAMP CONFLICT.`
   `The memory rewinds.`
10. Collect the Memory Frames in order:
   `Counter lights shut off.`
   `Cabinet 07 stayed awake.`
   `A staff member entered the back hall.`
   `The Staff Door recorded two signals.`
11. Reach the exit.
12. Confirm completion text:
   `FINAL NIGHT ROUTE STABILIZED.`
   `MEMORY ECHO AVAILABLE.`
   `THE STAFF DOOR DID NOT RECORD A CUSTOMER.`
13. Confirm `final_night_walk_started` is true.
14. Confirm `final_night_walk_completed` is true.
15. Return to Staff Corridor.
16. Interact with Final Night Walk again and confirm Staff Door completion dialogue:
   `ROUTE ACCEPTED.`
   `FINAL NIGHT SEQUENCE STABILIZED.`
   `ONE WALKED IN.`
   `TWO SIGNALS ANSWERED.`
17. Save and load.
18. Confirm Final Night Walk completion and `staff_door_final_walk_anecdote_seen` persist.
19. Confirm Memory Echo is now available.

## Optional Staff Records Chain Test
Run this after Truth Filter completion. This quest is optional and must not block the required route.

1. Complete Truth Filter.
2. Go to Cabinet Row and read Record 01.
3. Confirm it reads:
   `RESTORE SYSTEM NOTE`
   `Subject memory incomplete.`
   `Do not repeat name until signal stabilizes.`
4. Confirm `staff_record_01_read` is true.
5. Go to Maintenance Hall and read Record 02.
6. Confirm it reads:
   `MAINTENANCE WARNING`
   `Door responds to two signatures.`
   `One physical. One stored.`
7. Confirm `staff_record_02_read` is true.
8. When Staff Corridor is reachable, read Record 03.
9. Confirm it reads:
   `STAFF CORRIDOR LOG`
   `Employee number readable after overload.`
   `04`
10. Confirm `staff_record_03_read` is true.
11. After all three records are read, confirm:
   `staff_records_chain_completed` is true.
   The completion text appears:
   `STAFF RECORDS CHAIN COMPLETE`
   `The arcade knew the number before it knew the name.`
12. Save and load.
13. Confirm all three read flags and `staff_records_chain_completed` persist.
14. Confirm Staff Records Chain does not change Main progress and does not block Maintenance Sync, Security Tape Assembly, Memory Echo, or the Staff Room reveal.

## Optional Post-Reveal Witness Route Test
Run this after `post_reveal_roam_unlocked` is true. This route is optional and must not block saving, restoring, or ending flow.

1. Talk to Mira and confirm `witness_mira_heard` is true.
2. Talk to Gus and confirm `witness_gus_heard` is true.
3. Talk to Vendo and confirm `witness_vendo_heard` is true.
4. Talk to Mr. Byte and confirm `witness_mr_byte_heard` is true.
5. Talk to Cabinet 07 and confirm `witness_cabinet07_heard` is true.
6. Go to Cabinet Row, talk to Roxy, and confirm `witness_roxy_heard` is true.
7. Go to Prize Corner, talk to Pip, and confirm `witness_pip_heard` is true.
8. Confirm the completion text appears:
   `POST-REVEAL WITNESSES COMPLETE`
   `Pixel Haven remembers you in pieces. Together, they almost make a person.`
9. Confirm `witness_route_completed` is true.
10. Confirm `post_reveal_witness_route_completed` is also true for old save compatibility.
11. Save and load.
12. Confirm all witness flags and route completion persist.
13. Confirm the route counts as the fifth secret but does not change Main or Optional game counters.

## First Quest Vertical Slice Test
This is the active quality gate before adding more NPCs, minigames, endings, story branches, combat, inventory, or cabinet games. Run this from `res://scenes/main/Main.tscn` in Godot.

1. Launch the project and confirm the Title Menu appears.
2. Confirm `New Memory` has default focus and the title buttons are readable inside the menu frame.
3. Choose `New Memory`.
4. Choose a save slot and confirm overwrite feedback is clear if the slot already exists.
5. Confirm the opening fade and first-person Player intro dialogue play.
6. Confirm the intro does not replay after saving/loading the same memory.
7. Confirm ArcadeHub loads and player movement works.
8. Confirm the old lower-left quest text is not shown.
9. Talk to Mira.
10. Confirm Mira clearly starts the Lost Token quest.
11. Confirm the new quest popup appears in a large readable frame.
12. Confirm the quest popup fades in over 1 second, lingers for 3 seconds, and fades out over 1.5 seconds.
13. Confirm the popup tip says the quest details can be reviewed from `Esc -> Quest`.
14. Press `Esc`, choose `Quest`, and confirm the active quest title and details fit in a large readable frame.
15. Save before playing Rockbyte Duel.
16. Return to Title or reload the save.
17. Confirm the active Lost Token quest persists.
18. Go to Cabinet 07 and interact.
19. Confirm Rockbyte Duel launches.
20. Confirm Rockbyte Duel instructions are clear.
21. Confirm the player actor, Cabinet 07 actor, left rock pile, and right rock pile are visible.
22. Take a move and confirm buttons disable during the animation sequence.
23. Confirm player rock removal uses a human-style animation.
24. Confirm Cabinet 07 rock removal uses a machine-style flicker or digital animation.
25. Confirm rock counts remain synced with the visuals.
26. Lose once if practical and confirm retry/failure handling is clear.
27. Win Rockbyte Duel.
28. Confirm the Lost Token is recovered and Rockbyte Duel completion is recorded.
29. Return to ArcadeHub.
30. Save after Rockbyte Duel with `Esc -> Save`.
31. Reload the save with `Esc -> Load` or the Title Menu restore flow and confirm Lost Token recovered state persists.
32. Return to Mira.
33. Confirm Mira completes the quest.
34. Save after quest completion with `Esc -> Save`.
35. Reload the save with `Esc -> Load` or the Title Menu restore flow and confirm first quest completion persists.
36. Confirm the first quest path feels like a complete mini-chapter before continuing development.

Pass condition: every step above passes in a live Godot playthrough. If any step fails, fix that first quest issue before expanding content.

## Live Godot Acceptance Fix Pass
- Date: 2026-06-18
- Requested route: full 32-step acceptance route from `res://scenes/main/Main.tscn` through post-reveal restore.
- Result: blocked before launch.
- Commands attempted: `Get-Command godot`, `Get-Command godot4`, `where.exe godot`, `where.exe godot4`, and a search for `Godot*.exe` in common local install/download locations.
- Godot executable found: no.
- Acceptance steps passed live: none.
- Runtime issues fixed: none, because the game could not be launched.
- Remaining blocker: install Godot 4.4.x or provide the executable path, then rerun the full route.
- Project status: not live-verified and not publishable until the full route passes in Godot.

## Final MVP Acceptance Pass
- Date: 2026-06-18
- Method: static script/scene/resource-path review only; live Godot launch was unavailable in this shell.
- Final acceptance status: not live accepted yet.
- Export readiness: ready for local test-build export preparation, but final exported build should be playtested before sharing broadly.
- README status: kept as `MVP candidate pending final live playtest`.

### Acceptance Criteria Status
1. Title Menu appears on launch: static pass; `project.godot` main scene points to `res://scenes/main/Main.tscn`, which instances `TitleMenu`.
2. New Memory works: static pass; Title Menu opens SaveSlotMenu in `new_game` mode and SaveManager starts/reset/saves a slot.
3. Restore Memory works: static pass; Title Menu opens SaveSlotMenu in `load` mode and SaveManager applies valid slot data.
4. SaveSlotMenu does not soft-lock: static pass; close signal and focus paths are present, but live input must still be verified.
5. Player can move in ArcadeHub: static pass from scene/script wiring; live collision/input verification required.
6. Player can interact with all required NPCs/objects: static pass from ArcadeHub interaction handlers; live trigger verification required.
7. Objective hint updates correctly: static pass from GameState-driven `_refresh_objective_hint()`.
8. Vendo riddle works and saves: static pass; riddle flag is set, saved, loaded, and counted as a secret.
9. Rockbyte Duel works and saves completion: static pass; win sets Rockbyte completion and Lost Token flags.
10. Mira accepts Lost Token: static pass; Mira completion handler sets quest completion.
11. Staff Door gating works: static pass; route checks required puzzle and Staff Corridor flags.
12. Maintenance Sync works and unlocks Staff Corridor: static pass; puzzle success sets `story_puzzle_completed` and unlocks the route toward Security Tape Assembly.
13. Staff Room reveal plays all 8 slides: static pass; StaffRoom passes 8 slide entries to SlideshowCutscene.
14. EndingPrompt appears: static pass; StaffRoom instantiates EndingPrompt after reveal completion.
15. Save and Continue returns to ArcadeHub: static pass; EndingPrompt marks post-reveal, saves active slot when present, and changes to ArcadeHub.
16. Post-Reveal Roam dialogue appears: static pass; ArcadeHub branches on post-reveal/twist state.
17. Post-reveal save/load works: static pass; SaveManager preserves post-reveal flags and restores safely to ArcadeHub.
18. Completion counters are correct: static pass target is now Main `0-10 / 10`, Optional `0-2 / 2`, and Secrets `0-5 / 5`.
19. Secret counters are correct: static pass target includes Broken Cabinet, Owner Portrait, Vendo Memory Cola, Employee 04 file, and the future post-reveal witness route flag.
20. Missing art/audio does not crash game: static pass by script behavior; live confirmation still required.

### Remaining Known Issues For Acceptance
- Full live acceptance route still needs to be run in Godot 4.4.x.
- Runtime-only issues such as collision bounds, focus timing, input repeat, and exported-build packaging remain unknown until live testing.
- Missing cutscene art and audio are expected placeholders and should not block acceptance if placeholder panels/audio-safe fallbacks work.

## MVP QA Hardening Result

### What Passed Static Review
- Main scene launches through `Main.tscn` and instances `TitleMenu.tscn`.
- Title Menu opens `SaveSlotMenu` in `new_game` and `load` modes.
- New Memory Slot flow calls `SaveManager.start_new_memory(slot_id)`, resets `GameState`, assigns `active_slot_id`, writes the initial save, and opens ArcadeHub.
- Save/load data includes story flags, NPC flags, secret flags, counters, story phase, active slot metadata, and current scene.
- Loading a valid save clears the current `GameState`, applies the selected slot's `GameState`, sets `active_slot_id`, and restores a valid saved scene or falls back to ArcadeHub.
- StaffRoom saves made after post-reveal roam normalize back to ArcadeHub, preventing restore into the reveal room after the ending.
- Mira, Cabinet 07, Rockbyte Duel, Truth Filter, Circuit Soda, Lost Shift File, Maintenance Sync, Security Tape Assembly, Staff Corridor, StaffRoom terminal, slideshow reveal, EndingPrompt, and post-reveal ArcadeHub dialogue all have connected script paths for the required expanded route.
- Vendo's riddle flag is saved, loaded, and counted as a secret.
- Completion counters match the expanded intended totals: main `0-10 / 10`, optional `0-2 / 2`, secrets `0-5 / 5`.
- SlideshowCutscene handles missing panel images with placeholder UI and emits `cutscene_finished` once.
- Save and Continue marks ending/post-reveal state, saves when an active slot exists, and returns to ArcadeHub.

### What Failed and Was Fixed
- Fixed confusing SaveSlotMenu behavior where the visible mode control could be clicked to cycle between `Save Memory`, `Restore Memory`, and `New Memory`. This could let a title or ending flow perform the wrong slot action. The control now displays the active mode and is disabled as an informational label.

### Remaining Known Issues
- A full live playthrough in the Godot editor is still required to confirm collisions, focus behavior, and button input timing end-to-end.
- Cutscene image files under `res://assets/cutscenes/twist/` may be missing by design and should show placeholder panels.
- Audio files may be missing by design; AudioManager should keep gameplay non-breaking.
- Player position/facing restoration is placeholder-level; the save system restores story state and scene path, not exact room placement.

### End-to-End MVP Status
- Static review result: no remaining script/path/state blocker was found for the required path.
- Live runtime result: not completed in this shell because Godot is unavailable.
- Current expected status: playable end-to-end after live Godot verification confirms no editor/runtime-only issues.

### Exact Expanded Required Path
1. Launch game.
2. Confirm Title Menu appears.
3. New Memory -> Slot 1.
4. Confirm ArcadeHub loads.
5. Move player.
6. Talk to Mira and start the Lost Token quest.
7. Interact with Cabinet 07.
8. Complete Rockbyte Duel.
9. Return to ArcadeHub.
10. Save/load and confirm Rockbyte state persists.
11. Talk to Mira and complete Lost Token quest.
12. Confirm the objective points to Cabinet Row / Mr. Byte.
13. Complete Truth Filter in Cabinet Row.
14. Confirm Memory Signal becomes `Fractured`.
15. Save/load and confirm Truth Filter state persists.
16. Confirm the objective points to Snack Alcove / Vendo.
17. Complete Circuit Soda in Snack Alcove.
18. Save/load and confirm Circuit Soda state persists.
19. Confirm the objective points to Maintenance Hall / Gus.
20. Complete Static Service Run in Maintenance Hall.
21. Save/load and confirm Static Service Run state persists.
22. Complete Maintenance Sync in Maintenance Hall.
23. Confirm Memory Signal becomes `Overloaded`.
24. Confirm Staff Corridor unlocks.
25. Save/load and confirm Maintenance Sync state persists.
26. Complete Security Tape Assembly in Staff Corridor.
27. Save/load and confirm Security Tape state persists.
28. Complete Final Night Walk in Staff Corridor.
29. Save/load and confirm Final Night Walk state persists.
30. Complete Memory Echo in Staff Corridor.
31. Save/load and confirm Memory Echo state persists.
32. Enter Staff Room.
33. Interact with Employee 04 file before reveal.
34. Interact with terminal.
35. Advance through all reveal slides.
36. Confirm EndingPrompt appears.
37. Choose Save and Continue.
38. Confirm ArcadeHub loads in Post-Reveal Roam.
39. Save again.
40. Return to Title.
41. Restore Slot 1.
42. Confirm post-reveal state persists.

## 1. Launch and Title Menu Test
1. Launch the project.
2. Confirm the Title Menu appears first.
3. Confirm the title reads `THE LAST TOKEN`.
4. Confirm buttons are visible: `New Memory`, `Restore Memory`, `Quit`.
5. Press `New Memory` and confirm the Memory Slot menu opens in new-game mode.
6. Back out and confirm the Title Menu returns.
7. Press `Restore Memory` and confirm the Memory Slot menu opens in restore/load mode.
8. Back out and confirm the Title Menu returns.

## 2. New Memory Test
1. From Title Menu, choose `New Memory`.
2. Choose `Memory Slot 1`.
3. If the slot already exists, confirm overwrite works.
4. Confirm ArcadeHub loads.
5. Confirm player movement works.
6. Confirm the startup hint points toward Mira.
7. Confirm `SaveManager.active_slot_id` is set by saving/loading behavior.

## 3. Save/Restore Memory Test
1. Talk to Mira to start the Lost Token quest.
2. Save at the Memory Terminal.
3. Return to Title using the ending/title flow if available, or relaunch the game.
4. Choose `Restore Memory`.
5. Load `Memory Slot 1`.
6. Confirm ArcadeHub loads, not the Title Menu shell.
7. Confirm Mira quest state persists.
8. Confirm slot summary shows story phase, main progress count, optional games count, secrets count, Memory Signal, and last saved timestamp.
9. Load a different slot if one exists and confirm old flags from the previous slot do not leak.
10. Overwrite an existing slot with `New Memory` and confirm old story, secret, and post-reveal flags are gone.

## 4. Main Story Path Test
1. Talk to Mira and start the Lost Token quest.
2. Interact with Cabinet 07.
3. Complete Rockbyte Duel.
4. Return to ArcadeHub.
5. Talk to Mira and return the Lost Token.
6. Confirm the objective points to Cabinet Row / Mr. Byte.
7. Complete Truth Filter.
8. Confirm the objective points to Snack Alcove / Vendo.
9. Complete Circuit Soda.
10. Confirm the objective points to the Lost Shift File.
11. Read the Closing Checklist, Maintenance Note, and Staff Schedule.
12. Confirm the objective points to Maintenance Hall / Gus.
13. Complete Static Service Run.
14. Complete Maintenance Sync.
15. Confirm Staff Corridor unlocks.
16. Complete Security Tape Assembly.
17. Complete Final Night Walk.
18. Complete Memory Echo.
19. Enter Staff Room.

## 5. Staff Room Reveal Test
1. In Staff Room, interact with the Employee 04 file before the reveal.
2. Confirm it does not award the Employee 04 secret before the reveal.
3. Interact with the terminal.
4. Confirm the pre-reveal terminal dialogue appears.
5. Advance through all 8 reveal slides.
6. Confirm missing image panels use clean placeholders.
7. Confirm `twist_reveal_seen` is set after the slideshow.
8. Confirm `employee_04_file_found` is set after the reveal.
9. Confirm EndingPrompt appears after the final slide.

## 6. Ending Test
1. Confirm ending text explains that memories and machines have changed.
2. Confirm buttons appear: `Save and Continue`, `Return to Title`.
3. Press `Save and Continue`.
4. If an active slot exists, confirm the game saves and returns to ArcadeHub.
5. If no active slot exists, confirm SaveSlotMenu opens in save mode first.
6. Confirm returning to ArcadeHub keeps player control working.
7. Press `Return to Title` in a separate run.
8. If an active slot exists, confirm the save-before-title prompt appears.
9. Confirm both save and no-save paths return to Title/Main without erasing GameState.

## 7. Post-Reveal Roam Test
1. After `Save and Continue`, confirm ArcadeHub loads.
2. Confirm the post-reveal hint appears:
   `The arcade is quiet now.`
   `But some machines are still awake.`
3. Talk to Mira, Gus, Vendo, Cabinet 07, Mr. Byte, Owner Portrait, and Broken Cabinet.
4. Confirm each has post-reveal dialogue.
5. Save at the Memory Terminal.
6. Return to Title or relaunch.
7. Restore the same slot.
8. Confirm post-reveal state and hint persist.

## 8. Save Slot Progress Counter Test
1. Start a new memory.
2. Save.
3. Confirm the slot displays:
   `Memory Slot 1`
   `Status: New Memory` or the current earliest story phase
   `Main: 0 / 10`
   `Optional: 0 / 2`
   `Secrets: 0 / 5`
   `Signal: Grounded`
   `Last Saved: [timestamp]`
4. Complete Rockbyte Duel and save.
5. Confirm Main increments to `1 / 10`.
6. Complete Truth Filter and save.
7. Confirm Main increments to `2 / 10`.
8. Complete Circuit Soda and save.
9. Confirm Main increments to `3 / 10`.
10. Complete Lost Shift File and save.
11. Confirm Main increments to `4 / 10`.
12. Complete Static Service Run and save.
13. Confirm Main increments to `5 / 10`.
14. Complete Maintenance Sync and save.
15. Confirm Main increments to `6 / 10`.
16. Complete Security Tape Assembly and save.
17. Confirm Main increments to `7 / 10`.
18. Complete Final Night Walk and save.
19. Confirm Main increments to `8 / 10`.
20. Complete Memory Echo and save.
21. Confirm Main increments to `9 / 10`.
22. Complete the Staff Room reveal and save.
23. Confirm Main increments to `10 / 10`.
24. Complete optional Broken High Score if available and save.
25. Confirm Optional increments to `1 / 2`.
26. Complete Prize Sort if available and save.
27. Confirm Optional increments to `2 / 2`.
28. Confirm optional games do not change Main.

## 9. Optional Broken High Score Test
Run this after Cabinet Row is reachable. This content is optional and must not block the required route.

1. Go to Cabinet Row.
2. Talk to Roxy and confirm:
   `Finally. Player Two showed up.`
   `You look like someone who loses to menus.`
   `Try the Broken High Score cabinet.`
   `The screen lies, but badly.`
3. Interact with the Broken High Score cabinet.
4. Confirm `res://scenes/minigames/BrokenHighScore.tscn` opens.
5. Confirm instructions say:
   `BROKEN HIGH SCORE`
   `The target says 9999.`
   `Some digits are broken.`
   `Reach the real score.`
6. Press `+10 Score` until score reaches at least `99`.
7. Confirm completion text:
   `PREVIOUS SCORE FOUND.`
   `EMPLOYEE 04 — 000000.`
   `RECORD RESTORED.`
8. Return to Cabinet Row.
9. Talk to Roxy and confirm:
   `Huh. Your score came back.`
   `That usually does not happen after a reset.`
   `Do not let it go to your head. You still walk like a tutorial.`
10. Talk to Roxy again and confirm shorter repeat lines appear.
11. Save and load.
12. Confirm `roxy_met`, `broken_high_score_completed`, and `roxy_high_score_anecdote_seen` persist.
13. Continue the required route and confirm Staff Corridor and Staff Room are still reachable without completing Broken High Score on a separate save.
14. After the reveal, return to Roxy and confirm:
   `So you were Employee 04.`
   `That explains the blank high score.`
   `Hard to rank a memory.`

## 10. Optional Prize Sort Test
Run this after Prize Corner is reachable. This content is optional and must not block the required route.

1. Go to Prize Corner.
2. Talk to Pip before Lost Token completion if practical and confirm:
   `Hi! I am a legally distinct prize animal.`
   `I am filled with cotton and confidential information.`
3. After Lost Token completion, talk to Pip and confirm:
   `You used to want the blue one.`
   `You never had enough tickets.`
4. After Truth Filter completion, talk to Pip and confirm:
   `You are softer this time.`
   `Less screaming.`
5. Confirm Prize Sort opens with:
   `Arrange the prizes from oldest memory to newest memory.`
6. Choose the correct order:
   `Ticket Stub`
   `Lost Token`
   `Blank Employee Badge`
7. Confirm completion text:
   `Prizes sorted.`
   `Some rewards remember their owner before the owner remembers them.`
8. Save and load.
9. Confirm `pip_met`, `prize_sort_completed`, and `pip_post_reveal_secret_seen` save/load correctly at their relevant checkpoints.
10. Continue the required route on a separate save and confirm Prize Sort is not required for Staff Corridor, Staff Room, reveal, or ending.
11. After the reveal, return to Pip and confirm:
   `There you are.`
   `Yep. Still not the original.`
   `But you wave nicer now.`
12. Save and load.
13. Confirm `pip_post_reveal_secret_seen` persists.

## 11. Secret Counter Test
1. Start a new memory.
2. Confirm secrets begin at `0 / 5`.
3. Trigger Broken Cabinet secret and save.
4. Confirm secrets increase by 1.
5. See post-reveal Owner Portrait text and save.
6. Confirm Owner Portrait secret increases by 1 only after post-reveal text.
7. Complete or inspect the Employee 04 file after reveal.
8. Confirm Employee 04 secret is counted.
9. Solve Vendo's Memory Riddle with `MEMORY COLA`.
10. Confirm Vendo riddle secret is counted.
11. Complete the optional post-reveal witness route.
12. Confirm the witness route is counted as the fifth secret.
13. Confirm Staff Records Chain is optional lore and does not change the secret counter unless that is intentionally changed later.
14. Confirm Broken High Score is optional content and does not change the secret counter unless that is intentionally changed later.
15. Confirm Prize Sort is optional content and does not change the secret counter unless that is intentionally changed later.

## 12. Expanded Save Compatibility Test
1. Load an old save that does not include the new future flags.
2. Confirm missing flags default safely to false:
   `security_tape_assembly_started`
   `security_tape_assembly_completed`
   `static_service_run_started`
   `static_service_run_completed`
   `gus_static_run_anecdote_seen`
   `final_night_walk_started`
   `final_night_walk_completed`
   `staff_door_final_walk_anecdote_seen`
   `lost_shift_file_started`
   `lost_shift_file_completed`
   `staff_record_01_read`
   `staff_record_02_read`
   `staff_record_03_read`
   `staff_records_chain_completed`
   `witness_mira_heard`
   `witness_gus_heard`
   `witness_vendo_heard`
   `witness_mr_byte_heard`
   `witness_cabinet07_heard`
   `witness_roxy_heard`
   `witness_pip_heard`
   `witness_route_completed`
3. Confirm the save slot displays Main, Optional, Secrets, Signal, and Last Saved.
4. Confirm old saves with Rockbyte Duel completed show Main at least `1 / 10`.
5. Confirm old saves with Broken High Score completed show Optional at least `1 / 2`.
6. Save again and reload.
7. Confirm the expanded counters remain stable.

## 13. Known Placeholders
- Cutscene panel images under `res://assets/cutscenes/twist/` may be missing and should show placeholder panels.
- Audio files may be missing; AudioManager should fail silently.
- Visuals are placeholder shapes and labels.
- Rockbyte Duel uses simple/randomized cabinet moves, so retries may be needed.
- Save/load restores GameState and scene path, but exact player position restoration is still placeholder-level.
- Title Menu restore opens the Memory Slot menu; full polished title flow is not final.
