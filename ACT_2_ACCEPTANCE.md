# Act 2 Acceptance

## Status
- Implementation status: scaffold implemented.
- Acceptance status: not accepted yet.
- Reason: the full Act 2 route still needs a live Godot viewport playthrough.

## Required Route
1. Start a New Memory.
2. Complete the first quest:
   - Talk to Mira.
   - Play Cabinet 07.
   - Win Rockbyte Duel.
   - Return the Lost Token to Mira.
3. Confirm Memory Signal becomes `Uneasy`.
4. Confirm objective points to `Find the Truth Filter`.
5. Interact with Staff Door before Truth Filter.
6. Confirm Staff Door blocks with:
   - `STAFF ACCESS LOCKED.`
   - `TRUTH FILTER REQUIRED.`
   - `MEMORY SIGNAL UNSTABLE.`
7. Enter Truth Filter.
8. Confirm instructions are readable.
9. Try at least one wrong answer.
10. Confirm wrong answers show:
   - `MEMORY SIGNAL WOBBLED.`
   - `Try again.`
11. Complete all four rounds.
12. Confirm completion text:
   - `TRUTH FILTER PASSED.`
   - `SECOND MEMORY FRAGMENT RECOVERED.`
   - `YOUR MEMORY IS NO LONGER THE ONLY WITNESS.`
13. Confirm Memory Signal becomes `Fractured`.
14. Return to ArcadeHub.
15. Save.
16. Load.
17. Confirm Truth Filter completion persists.
18. Confirm Staff Door now routes to Sync Door.
19. Confirm no full Employee 04 reveal happens during Act 2.
20. Confirm Mira, Gus, Vendo, Mr. Byte, Cabinet 07, and Staff Door have Act 2 foreshadowing dialogue.
21. Confirm the first quest still works from a clean New Memory.

## Pass Criteria
- No script errors.
- No scene path errors.
- No save/load regression.
- Act 2 route is understandable without a full quest journal.
- Truth Filter is required before Sync Door.
- Memory Signal visibly changes from `Uneasy` to `Fractured`.

## Known Pending Verification
- Live movement and collision around the new Truth Filter cabinet.
- Readability of the Memory Signal label at all supported window sizes.
- Manual save/load after Truth Filter completion.
- Full first quest regression after this Act 2 insertion.
