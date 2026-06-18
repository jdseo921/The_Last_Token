# TEST_PLAN.md

## Test Rules
- Test in Godot 4.x from `res://scenes/main/Main.tscn`.
- Keep the test focused on the playable MVP path, not polish.
- Fix blockers before adding new content.
- Missing art/audio placeholders are acceptable if they do not break play.

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
