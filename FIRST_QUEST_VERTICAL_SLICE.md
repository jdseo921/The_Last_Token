# FIRST_QUEST_VERTICAL_SLICE.md

## Purpose
This document defines the current quality gate for The Last Token. Until this first quest vertical slice passes in Godot, the project should not add more NPCs, minigames, endings, story branches, combat, inventory, or additional cabinet games.

The goal is to make the first playable loop feel like a complete mini-chapter before expanding the game.

## Locked Scope
Only polish and verify this path:

1. Title Menu
2. New Memory
3. Opening intro
4. Talk to Mira
5. Start Lost Token quest
6. Go to Cabinet 07
7. Play Rockbyte Duel
8. Recover Lost Token
9. Return to Mira
10. Complete first quest
11. Save/load verification

## Current QA Status
- Date: 2026-06-19
- Result: partial pass, live interactive pass still required.
- Headless Godot checks: passed for project open, `res://scenes/main/Main.tscn`, `res://scenes/arcade/ArcadeHub.tscn`, and `res://scenes/minigames/RockbyteDuel.tscn`.
- State-path review: passed for Mira quest start, Cabinet 07 launch, Rockbyte Duel win state, Lost Token collection, Mira quest completion, and save/load serialization of first quest flags.
- Save/load regression status: static expected pass for Cases A-D, but not marked fully passing. A temporary automated QA runner was attempted and removed; this shell's Godot build crashed while opening `user://logs/...` before returning automated results. Manual live save/load confirmation is still required.
- Full viewport playthrough: not completed in this shell because the route needs manual movement, dialogue input, Rockbyte win/loss play, and save-slot interaction.
- Save route note: the current MVP uses `Esc -> Save` / `Esc -> Load`. The Memory Terminal has been removed from the hub for future reuse, so first-quest save/load testing should use the pause menu unless a terminal is intentionally restored later.

## Required Player Path
1. Launch from `res://scenes/main/Main.tscn`.
2. Confirm the Title Menu is readable and focused on `New Memory`.
3. Choose `New Memory`.
4. Choose or overwrite a save slot.
5. Watch the opening intro.
6. Enter ArcadeHub with player control restored.
7. Talk to Mira.
8. Receive the Lost Token quest.
9. Understand that Cabinet 07 is the next destination.
10. Interact with Cabinet 07.
11. Complete Rockbyte Duel.
12. Return to ArcadeHub with Lost Token recovered.
13. Return to Mira.
14. Complete the first quest.
15. Save from `Esc -> Save`.
16. Load the same save from `Esc -> Load` or the Title Menu restore flow.
17. Confirm quest completion and Lost Token state persist.

## Required Story Beats
- The opening intro establishes that the player is disoriented, returning to Pixel Haven, and missing something important.
- Mira is the first emotional anchor.
- Mira clearly starts the Lost Token quest.
- Cabinet 07 is clearly framed as the machine connected to the missing token.
- Rockbyte Duel pays off the first machine confrontation.
- Winning Rockbyte Duel recovers the Lost Token.
- Returning to Mira completes the quest and should feel like the end of a small chapter.

## Required UI And Hint Behavior
- Title Menu buttons are readable and visually centered inside the menu frame.
- `New Memory`, `Restore Memory`, `Settings`, and `Quit` are obvious.
- Opening intro dialogue appears after a controlled fade, not abruptly.
- New quest notification appears when the first quest starts.
- Quest notification uses a large readable frame, fades in over 1 second, lingers for 3 seconds, and fades out over 1.5 seconds.
- Quest notification includes the tip: `Tip: Press Esc, then choose Quest to read these details again.`
- The old corner quest text is not used for the first quest.
- The pause menu has a `Quest` entry above save/load actions.
- `Esc -> Quest` shows the current quest in a large readable frame.
- Interaction prompts do not overlap dialogue, quest notices, or core gameplay UI.

## Required Save/Load Behavior
- Starting a New Memory resets first quest state.
- Opening intro plays once per new memory.
- Save/load before Rockbyte Duel preserves the active quest.
- Save/load after Rockbyte Duel preserves Lost Token recovered state.
- Save/load after returning to Mira preserves first quest completion.
- Loading an empty or invalid slot shows clear failure feedback and does not crash.
- Save/load does not count an unfinished Rockbyte Duel as a win or loss.
- Pause-menu save/load is the required save route for this gate while the Memory Terminal is absent.

## Required Rockbyte Duel Quality Criteria
- Cabinet 07 launches Rockbyte Duel reliably.
- Rules are clear before or during play:
  - Two piles remain.
  - Take 1 from Left, Right, or Both.
  - Whoever takes the final rock wins.
- Player actor appears on the left.
- Cabinet 07 or machine actor appears on the right.
- Left and right rock piles are visible and readable.
- Rock counts stay synced with gameplay state.
- Player moves use a human-style removal animation.
- Cabinet 07 moves use a machine-style flicker or digital removal animation.
- Buttons disable while animations are playing.
- Retry/failure handling is clear.
- Winning sets Rockbyte Duel completion and recovers the Lost Token.
- Exiting returns the player to ArcadeHub without moving them unexpectedly.

## Required Visual Quality Criteria
- Title screen art supports, not obscures, buttons.
- ArcadeHub is readable at supported window sizes.
- Player sprite is visible against the dark hub background.
- Mira, Cabinet 07, and key interactables have labels or clear readability.
- NPC/interactable labels do not overlap important sprites or UI.
- Machine idle animation is limited to light/screen changes, not position movement.
- Humanoid NPCs do not need idle animation for this gate.
- Placeholder visuals are acceptable only when they are intentional and readable.
- Missing optional art must not crash the game.

## Exit Criteria Before More Content
All of these must pass in a live Godot playthrough before adding new content:

1. New Memory works.
2. Opening intro plays once.
3. Mira clearly gives the quest.
4. Player knows to go to Cabinet 07.
5. Cabinet 07 launches Rockbyte Duel.
6. Rockbyte Duel has clear instructions, staged visuals, actor/rock animations, retry/failure handling, and win payoff.
7. Lost Token state persists.
8. Returning to Mira completes the quest.
9. Save/load works before and after Rockbyte Duel.
10. First quest completion feels like a satisfying mini-chapter.
11. No new content is added until this passes.

## Remaining First-Quest Issues To Verify
- Manual live test still needs to confirm the player can find and reach Mira naturally.
- Manual live test still needs to confirm the quest notice is readable during real play.
- Manual live test still needs to confirm Rockbyte Duel lose, retry, win, and return-to-hub behavior.
- Manual live test still needs to confirm save/load from the pause menu before quest start, after Mira starts the quest, after Rockbyte victory, and after first quest completion.

## Out Of Scope Until This Passes
- New NPCs.
- New minigames.
- New endings.
- New story branches.
- Combat.
- Inventory.
- Additional cabinet games.
- Large visual passes not needed to make the first quest understandable.
