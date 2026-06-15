# TEST_PLAN.md

## Test Rules
- Run manual tests after each major feature.
- Verify the feature in the smallest scene that can prove it works.
- Fix blockers before moving to the next build step.
- Keep tests focused on playability and completion, not polish.

## Major Feature Tests
- Player movement: start the game, move in all directions, and confirm facing changes correctly.
- Interaction: approach an NPC or cabinet and trigger an interaction prompt.
- Dialogue: start and advance dialogue without soft-locks.
- GameState: confirm flags change and persist during a session.
- Memory Slot save/load: create a new slot, save, quit, and resume the slot.
- ArcadeHub: enter the hub and reach the core interactables.
- NPCs: talk to Mira, Gus, Vendo, Cabinet 07, and Mr. Byte.
- Rockbyte Duel: start, finish, and record completion.
- Story puzzle: solve one simple puzzle and confirm progression.
- Staff room: reach the room only after required progress is complete.
- Slideshow reveal: play the reveal once and confirm the identity twist appears clearly.
- Ending: reach one ending without dead ends.
- Post-reveal roam: continue after ending and confirm changed dialogue.

## Final MVP Test
1. New Memory Slot.
2. Explore ArcadeHub.
3. Talk to Mira.
4. Play Rockbyte Duel.
5. Collect Lost Token.
6. Solve the story puzzle.
7. Enter Staff Room.
8. See the slideshow reveal.
9. Reach the ending.
10. Save and continue.
11. Enter Post-Reveal Roam.
12. Talk to NPCs again and confirm changed dialogue.
