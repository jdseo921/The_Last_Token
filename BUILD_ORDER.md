# BUILD_ORDER.md

## Implementation Order
1. project scaffold
2. player movement
3. interaction
4. dialogue
5. GameState
6. Memory Slot save/load
7. ArcadeHub
8. Mira, Gus, Vendo, Cabinet 07, Mr. Byte
9. Rockbyte Duel
10. one story puzzle
11. staff room
12. slideshow reveal
13. ending
14. post-reveal roaming
15. polish

## Build Rules
- Do not skip ahead if a lower step is still unstable.
- Keep each step playable before moving on.
- Prefer one thin vertical slice over many partial systems.
- Add stretch features only after step 15 is unnecessary for completion.

## Milestone Checks
- After movement, the player can move and face interactables.
- After interaction and dialogue, the player can talk to the core NPCs.
- After save/load, a new Memory Slot can be created and resumed.
- After ArcadeHub, the player can reach all MVP content in one loop.
- After reveal and ending, the player can continue in post-reveal roam mode.
