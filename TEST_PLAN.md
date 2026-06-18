# TEST_PLAN.md

## Test Rules
- Run manual tests after each major feature.
- Verify the feature in the smallest scene that can prove it works.
- Fix blockers before moving to the next build step.
- Keep tests focused on playability and completion, not polish.

## MVP Verification Pass
Date: 2026-06-18

### What Passed
- Main scene path exists: `res://scenes/main/Main.tscn`.
- Required autoloads are registered: `GameState`, `SceneChanger`, and `SaveManager`.
- ArcadeHub contains the required MVP interactables: Mira, Gus, Vendo, Mr. Byte, Broken Cabinet, Owner Portrait, Cabinet 07, Staff Door, and Memory Terminal.
- Player movement and interaction prompt wiring are present through `Player.gd`.
- Dialogue can finish and restore player control through `ArcadeHub.gd` and `DialogueBox.gd`.
- Mira starts and completes the Lost Token quest through existing GameState flags.
- Cabinet 07 starts Rockbyte Duel after the Lost Token quest begins.
- Rockbyte Duel can mark `rockbyte_duel_completed` and collect the Lost Token before returning to ArcadeHub.
- Staff Door blocks early access until both `lost_token_quest_completed` and `rockbyte_duel_completed` are true.
- Sync Door Puzzle unlocks Staff Room access through `story_puzzle_completed` and `staff_room_unlocked`.
- Post-reveal dialogue branches exist for Mira, Gus, Vendo, and Mr. Byte.
- Save data includes the post-reveal flags needed to preserve the ending state.

### What Failed And Was Fixed
- `scripts/StaffRoom.gd` had two script bodies concatenated together, including a second `extends`, which would prevent the script from loading. Fixed by replacing it with one valid Staff Room controller.
- Staff Room had no playable terminal path into the reveal. Fixed by adding the existing Player scene, a terminal interactable, and wiring the terminal to the existing SlideshowCutscene and EndingPrompt scenes.
- The slideshow reveal did not set the twist flag or advance to the ending prompt. Fixed by marking `twist_reveal_seen` when the slideshow finishes and then showing `EndingPrompt`.
- Memory Terminal opened SaveSlotMenu only in save mode, even though load support already existed. Fixed by adding a Save/Load mode button.
- SaveSlotMenu had no close button, which could trap the player in the menu. Fixed by adding a Close button that restores player control through the existing `menu_closed` signal.
- SaveSlotMenu used invalid GDScript ternary syntax. Fixed with Godot 4-compatible inline `if ... else` syntax.
- SaveSlotMenu controls had no explicit layout bounds, making button interaction unreliable. Fixed with simple panel and button bounds.

### Remaining Known Issues
- Godot could not be launched from this shell because no `godot` command was available, no local Godot executable was found in the project or LocalAppData, and the Program Files search timed out. A final in-editor click-through is still needed.
- Rockbyte Duel includes random cabinet moves, so a win may require retrying if the cabinet wins first.
- Slideshow uses placeholder panels with captions only, which is acceptable for MVP but not final art polish.

## Exact Final MVP Path
1. Launch `res://scenes/main/Main.tscn`.
2. Move the player in ArcadeHub.
3. Talk to Mira to start the Lost Token quest.
4. Talk to Gus.
5. Talk to Vendo.
6. Talk to Mr. Byte.
7. Interact with Broken Cabinet.
8. Interact with Owner Portrait.
9. Interact with Cabinet 07.
10. Play Rockbyte Duel until the player wins.
11. Exit Rockbyte Duel back to ArcadeHub.
12. Talk to Mira to complete the Lost Token quest.
13. Interact with Staff Door.
14. In Sync Door Puzzle, press Switch A and Switch B before either timer expires.
15. Return to ArcadeHub.
16. Interact with Staff Door again to enter Staff Room.
17. Move to the Staff Room terminal and interact with it.
18. Advance through the slideshow reveal.
19. At EndingPrompt, press Continue.
20. Return to ArcadeHub in post-reveal roam.
21. Talk to Mira, Gus, Vendo, Cabinet 07, and Mr. Byte again.
22. Interact with Memory Terminal.
23. Save to a Memory Slot.
24. Use Switch to Load.
25. Load the saved slot.
26. Confirm `twist_reveal_seen`, `ending_seen`, and `post_reveal_roam_unlocked` remain active through post-reveal dialogue.

## Optional Content Test: Vendo's Memory Riddle
1. Talk to Vendo before the twist reveal.
2. Advance Vendo's normal dialogue until the riddle choice appears.
3. Choose a wrong answer.
4. Confirm Vendo gives the wrong-answer response and player control returns.
5. Talk to Vendo again.
6. Choose `MEMORY COLA`.
7. Confirm `vendo_memory_riddle_secret_found` is true and the secret count increases to include the riddle.
8. Save to a Memory Slot.
9. Load the same slot.
10. Confirm Vendo no longer repeats the choice menu after the riddle is solved.
11. After post-reveal roam is unlocked, talk to Vendo and confirm the MEMORY COLA post-reveal line appears.

## Audio Hook Test
1. Run the game with no audio files in `assets/audio/sfx/` or `assets/audio/music/`.
2. Confirm missing audio files do not crash the game.
3. Advance dialogue and confirm dialogue still works.
4. Interact with an NPC or object and confirm interaction still works.
5. Save successfully at the Memory Terminal.
6. Try loading an empty slot and confirm the game does not crash.
7. Win and lose Rockbyte Duel at least once.
8. Solve Sync Door Puzzle.
9. Advance through the slideshow reveal and confirm `glitch_flash` still plays visually.
10. Continue from EndingPrompt into post-reveal roam.

## Final Playable Test For Sharing
1. Start a new playable session.
2. Use the Memory Terminal to create a New Memory save.
3. Load that Memory Slot.
4. Start and complete Rockbyte Duel.
5. Complete the Lost Token quest with Mira.
6. Complete Sync Door Puzzle.
7. Enter Staff Room and interact with the terminal.
8. Reveal the twist through the slideshow.
9. Continue into post-reveal roam.
10. Save again after post-reveal roam is unlocked.
11. Load the post-reveal save.
12. Talk to Mira, Gus, Vendo, Cabinet 07, and Mr. Byte.
13. Confirm post-reveal dialogue/state persists.
