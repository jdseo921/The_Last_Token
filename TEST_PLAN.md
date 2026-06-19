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
- `lost_token_quest_completed`, `lost_token_collected`, and `rockbyte_duel_completed` are saved and restored.
- Loading after completion should make `GameState.get_current_quest_id()` return `check_staff_door`, with objective `Objective: Check the Staff Door.`
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
3. Confirm the objective reads `Objective: Find the Truth Filter.`
4. Interact with Staff Door and confirm it blocks until Truth Filter is cleared.
5. Interact with the `TRUTH FILTER` cabinet.
6. Confirm `res://scenes/minigames/TruthFilter.tscn` opens.
7. Confirm instructions, rule text, three cabinet statements, and choice buttons are readable.
8. Pick one wrong answer and confirm retry works without hard-fail.
9. Complete all four rounds.
10. Confirm `lying_cabinets_completed` and `second_memory_fragment_collected` are true.
11. Confirm Memory Signal reads `Fractured`.
12. Return to ArcadeHub.
13. Save and load.
14. Confirm Truth Filter completion and Memory Signal persist.
15. Confirm Staff Door now routes to Sync Door.

## Act 2 Aftermath Echo Test
Run this after Truth Filter completion and before entering the Staff Room reveal.

1. Return to ArcadeHub after completing Truth Filter.
2. Confirm Memory Signal reads `Fractured`.
3. Talk to Mira and confirm Fractured-state dialogue or the ticket counter echo appears.
4. Interact with the Ticket Counter and confirm the reflection echo appears if it has not already been seen.
5. Talk to Gus and confirm he warns not to pick the loudest memory.
6. Talk to Vendo and confirm `Memory Signal: Fractured.` appears.
7. Talk to Mr. Byte and confirm `Truth Filter passed.` appears.
8. Talk to Cabinet 07 and confirm its normal Fractured-state dialogue appears.
9. Confirm Cabinet 07's optional echo appears once:
   `PREVIOUS PLAYER PROFILE FOUND.`
   `STATUS: DAMAGED.`
   `RESTORE ATTEMPT: CONTINUING.`
10. Interact with Owner Portrait and confirm the shifted nameplate text ends with `0 4`.
11. Interact with Staff Door and confirm:
   `FRACTURED SIGNAL ACCEPTED.`
   `TWO-SIGNAL SYNC REQUIRED.`
12. Confirm Staff Door routes to Sync Door after the dialogue.
13. Save and load.
14. Confirm the echo flags do not replay if already seen.

## Sync Door: Two Signals Test
Run this after Truth Filter completion, when Memory Signal is `Fractured`.

1. Enter Sync Door from the Staff Door.
2. Confirm title reads `SYNC DOOR: TWO SIGNALS`.
3. Confirm instructions say:
   `Two switches must be active together.`
   `Fractured signals do not stay stable for long.`
   `Watch the signal labels before pressing.`
4. Phase 1: activate Switch A and Switch B within 5 seconds.
5. Confirm Phase 2 begins and displays `WARNING: ONE LABEL IS REVERSED.`
6. Phase 2: observe Switch A label is reversed, then activate both real switches.
7. Confirm Phase 3 begins.
8. Phase 3: activate A, then B, then press `Confirm Sync` before either expires.
9. Let the timer expire once if practical and confirm:
   `SIGNAL LOST.`
   `TRY AGAIN.`
10. Complete Phase 3 successfully.
11. Confirm success text:
   `TWO SIGNALS DETECTED.`
   `RESTORED SIGNAL PRESENT.`
   `MEMORY SIGNAL: OVERLOADED.`
   `ACCESS GRANTED.`
12. Confirm `GameState.story_puzzle_completed` is true.
13. Confirm `GameState.staff_room_unlocked` is true.
14. Return to ArcadeHub.
15. Save and load.
16. Confirm Staff Room remains unlocked and Sync Door solved state persists.

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
11. Staff Door gating works: static pass; route checks Lost Token and puzzle/staff flags.
12. Sync Door works and unlocks Staff Room: static pass; puzzle success sets `story_puzzle_completed` and unlocks Staff Room.
13. Staff Room reveal plays all 8 slides: static pass; StaffRoom passes 8 slide entries to SlideshowCutscene.
14. EndingPrompt appears: static pass; StaffRoom instantiates EndingPrompt after reveal completion.
15. Save and Continue returns to ArcadeHub: static pass; EndingPrompt marks post-reveal, saves active slot when present, and changes to ArcadeHub.
16. Post-Reveal Roam dialogue appears: static pass; ArcadeHub branches on post-reveal/twist state.
17. Post-reveal save/load works: static pass; SaveManager preserves post-reveal flags and restores safely to ArcadeHub.
18. Completion counters are correct: static pass; only Rockbyte Duel, Sync Door, and reveal count as games.
19. Secret counters are correct: static pass; only the four explicit secret flags count.
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
- Mira, Cabinet 07, Rockbyte Duel, Staff Door, Sync Door Puzzle, StaffRoom terminal, slideshow reveal, EndingPrompt, and post-reveal ArcadeHub dialogue all have connected script paths for the required MVP route.
- Vendo's riddle flag is saved, loaded, and counted as a secret.
- Completion counters match the intended totals: games `0-3 / 3`, secrets `0-4 / 4`.
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

### Exact Final MVP Path
1. Launch game.
2. Confirm Title Menu appears.
3. New Memory -> Slot 1.
4. Confirm ArcadeHub loads.
5. Move player.
6. Talk to Mira and start the Lost Token quest.
7. Talk to Gus, Vendo, Mr. Byte, Cabinet 07, Owner Portrait, and Broken Cabinet.
8. Play Vendo riddle once wrong and once correctly.
9. Interact with Cabinet 07.
10. Complete Rockbyte Duel.
11. Return to ArcadeHub.
12. Talk to Mira and complete Lost Token quest.
13. Save at Memory Terminal.
14. Return to Title or relaunch.
15. Restore Slot 1.
16. Confirm quest state persists.
17. Interact with Staff Door.
18. Complete Sync Door Puzzle.
19. Return to ArcadeHub.
20. Enter Staff Room.
21. Interact with Employee 04 file before reveal.
22. Interact with terminal.
23. Advance through all 8 reveal slides.
24. Confirm EndingPrompt appears.
25. Choose Save and Continue.
26. Confirm ArcadeHub loads in Post-Reveal Roam.
27. Talk to all post-reveal NPCs.
28. Save again.
29. Return to Title.
30. Restore Slot 1.
31. Confirm post-reveal state persists.

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
8. Confirm slot summary shows a story phase, games count, secrets count, and last saved timestamp.
9. Load a different slot if one exists and confirm old flags from the previous slot do not leak.
10. Overwrite an existing slot with `New Memory` and confirm old story, secret, and post-reveal flags are gone.

## 4. Main Story Path Test
1. Talk to Mira and start the Lost Token quest.
2. Talk to Gus, Vendo, Mr. Byte, Broken Cabinet, and Owner Portrait.
3. Interact with Cabinet 07.
4. Complete Rockbyte Duel.
5. Return to ArcadeHub.
6. Talk to Mira and return the Lost Token.
7. Interact with Staff Door.
8. Complete Sync Door Puzzle.
9. Return to ArcadeHub.
10. Interact with Staff Door again and confirm Staff Room loads.

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

## 8. Completion Counter Test
1. Start a new memory.
2. Confirm games completed begins at `0 / 3`.
3. Complete Rockbyte Duel and save.
4. Confirm games completed is `1 / 3`.
5. Complete Sync Door Puzzle and save.
6. Confirm games completed is `2 / 3`.
7. Complete the reveal and save.
8. Confirm games completed is `3 / 3`.
9. Confirm Lost Token quest completion does not count as a game.

## 9. Secret Counter Test
1. Start a new memory.
2. Confirm secrets begin at `0 / 4`.
3. Trigger Broken Cabinet secret and save.
4. Confirm secrets increase by 1.
5. See post-reveal Owner Portrait text and save.
6. Confirm Owner Portrait secret increases by 1 only after post-reveal text.
7. Complete or inspect the Employee 04 file after reveal.
8. Confirm Employee 04 secret is counted.
9. Solve Vendo's Memory Riddle with `MEMORY COLA`.
10. Confirm Vendo riddle secret is counted.
11. Confirm total secrets is `4 / 4`.

## 10. Known Placeholders
- Cutscene panel images under `res://assets/cutscenes/twist/` may be missing and should show placeholder panels.
- Audio files may be missing; AudioManager should fail silently.
- Visuals are placeholder shapes and labels.
- Rockbyte Duel uses simple/randomized cabinet moves, so retries may be needed.
- Save/load restores GameState and scene path, but exact player position restoration is still placeholder-level.
- Title Menu restore opens the Memory Slot menu; full polished title flow is not final.
