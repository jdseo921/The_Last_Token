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
4. Confirm objective points to `Find Mr. Byte in Cabinet Row`.
5. Go to Cabinet Row.
6. Talk to Mr. Byte.
7. Confirm Mr. Byte says:
   - `Contradiction threshold reached.`
   - `Truth Filter is ready.`
   - `Please choose the least broken answer.`
8. Interact with the Truth Filter cabinet.
9. Confirm `TruthFilter.tscn` opens.
10. Confirm instructions are readable.
11. Try at least one wrong answer.
12. Confirm wrong answers show:
   - `MEMORY SIGNAL WOBBLED.`
   - `Try again.`
13. Complete all four rounds.
14. Confirm completion text:
   - `TRUTH FILTER PASSED.`
   - `SECOND MEMORY FRAGMENT RECOVERED.`
   - `YOUR MEMORY IS NO LONGER THE ONLY WITNESS.`
15. Return to Cabinet Row or ArcadeHub cleanly.
16. Confirm Memory Signal becomes `Fractured`.
17. Confirm objective points to `Find Vendo in the Snack Alcove`.
18. Talk to Mr. Byte and confirm:
   - `Truth Filter passed.`
   - `Contradictions remain.`
   - `That means the memory is alive enough to argue.`
   - `Record conflict reduced. Identity conflict remains.`
19. Go to Snack Alcove.
20. Talk to Vendo.
21. Confirm Vendo introduces Circuit Soda with:
   - `Memory Signal: Fractured.`
   - `Your signal is going everywhere except where it should.`
   - `Luckily, I am a licensed beverage-adjacent routing system.`
22. Interact with the Circuit Soda machine.
23. Complete all three Circuit Soda rounds.
24. Confirm completion text:
   - `MEMORY FLOW RESTORED.`
   - `CARBONATION LEVEL: UNRELATED.`
   - `IDENTITY SIGNAL ROUTED.`
25. Return to Snack Alcove.
26. Talk to Vendo and confirm:
   - `Signal routed.`
   - `You successfully became beverage-adjacent data.`
   - `I would offer a receipt, but the printer remembers too much.`
   - `Your label is still missing, but the machine knows what shelf you go on.`
27. Confirm Memory Signal remains `Fractured`.
28. Confirm objective points to `Find Gus in Maintenance Hall`.
29. Go to Maintenance Hall.
30. Talk to Gus and confirm:
   - `Truth got filtered, soda got routed, and somehow I am still the janitor.`
   - `Maintenance Hall is next.`
   - `Two signals are fighting in the door.`
31. Complete Maintenance Sync.
32. Confirm completion text:
   - `TWO SIGNALS DETECTED.`
   - `RESTORED SIGNAL PRESENT.`
   - `MEMORY SIGNAL: OVERLOADED.`
   - `ACCESS GRANTED.`
33. Confirm Memory Signal becomes `Overloaded`.
34. Confirm objective points to `Enter the Staff Corridor`.
35. Confirm Staff Corridor unlocks.
36. Talk to Gus and confirm:
   - `Door's listening now.`
   - `I do not like doors that listen.`
   - `But if it opens, part of you matched something it lost.`
   - `Door heard both knocks. Yours, and the one you forgot making.`
37. Enter Staff Corridor and interact with Memory Echo.
38. Confirm:
   - `Echo stabilized.`
   - `The arcade stops arguing with itself.`
   - `That might be worse.`
39. Save.
40. Load.
41. Confirm Truth Filter, Circuit Soda, Maintenance Sync, and all required anecdote flags persist.
42. Confirm no full Employee 04 reveal happens during Act 2.
43. Confirm Mira, Gus, Vendo, Mr. Byte, Cabinet 07, and Staff Door have Act 2 foreshadowing dialogue.
44. Confirm the first quest still works from a clean New Memory.

## Pass Criteria
- No script errors.
- No scene path errors.
- No save/load regression.
- Act 2 route is understandable without a full quest journal.
- Truth Filter is required before Circuit Soda.
- Circuit Soda is required after Truth Filter and before Maintenance Hall progression.
- Maintenance Sync is required after Circuit Soda and before Staff Corridor access.
- Memory Signal visibly changes from `Uneasy` to `Fractured` to `Overloaded`.

## Known Pending Verification
- Live movement and collision around the new Truth Filter cabinet.
- Readability of the Memory Signal label at all supported window sizes.
- Manual save/load after Truth Filter completion.
- Manual save/load after Circuit Soda completion.
- Manual save/load after Maintenance Sync completion.
- Full first quest regression after this Act 2 insertion.
