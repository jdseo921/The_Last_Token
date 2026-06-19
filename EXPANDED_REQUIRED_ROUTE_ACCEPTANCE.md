# Expanded Required Route Acceptance

## Status
- Implementation status: route implemented with placeholder visuals.
- Acceptance status: not accepted yet.
- Reason: the full expanded route still needs a live Godot viewport playthrough.
- Scope: required route only. Optional NPCs, optional minigames, and secrets must not be required for completion.

## Test Setup
1. Run from `res://scenes/main/Main.tscn` in Godot 4.x.
2. Start from a clean `New Memory` slot.
3. Use `Esc -> Save` and `Esc -> Load` for every save/load checkpoint.
4. Record any script error, scene path error, soft lock, missing objective update, or save/load mismatch.

## Expanded Required Route
1. Start a New Memory.
2. Confirm ArcadeHub loads and the first objective points toward Mira.
3. Talk to Mira and start the Lost Token quest.
4. Play Cabinet 07.
5. Complete Rockbyte Duel.
6. Return to ArcadeHub cleanly.
7. Save and load.
8. Confirm Rockbyte completion and Lost Token recovery persist.
9. Return the Lost Token to Mira.
10. Confirm Memory Signal becomes `Uneasy`.
11. Talk to Mira again and confirm the one-time Rockbyte anecdote:
    - `You brought it back.`
    - `That token used to be just a prize.`
    - `Then it became proof that part of you could still return.`
    - `It remembered you before you did.`
12. Talk to Mira again and confirm shorter repeat lines appear.
13. Confirm objective points to `Find Mr. Byte in Cabinet Row`.
14. Go to Cabinet Row.
15. Talk to Mr. Byte and confirm Truth Filter introduction.
16. Interact with the Truth Filter cabinet.
17. Confirm `res://scenes/minigames/TruthFilter.tscn` opens.
18. Complete Truth Filter.
19. Return to Cabinet Row or ArcadeHub cleanly.
20. Confirm Memory Signal becomes `Fractured`.
21. Talk to Mr. Byte and confirm the one-time Truth Filter anecdote:
    - `Truth Filter passed.`
    - `Contradictions remain.`
    - `That means the memory is alive enough to argue.`
    - `Record conflict reduced. Identity conflict remains.`
22. Talk to Mr. Byte again and confirm shorter repeat lines appear.
23. Confirm objective points to `Find Vendo in the Snack Alcove`.
24. Save and load.
25. Confirm Truth Filter completion, Memory Signal, objective, and Mr. Byte anecdote state persist.
26. Go to Snack Alcove.
27. Talk to Vendo and confirm Circuit Soda introduction.
28. Interact with the Circuit Soda machine.
29. Confirm `res://scenes/minigames/CircuitSoda.tscn` opens.
30. Complete all Circuit Soda rounds.
31. Return to Snack Alcove cleanly.
32. Talk to Vendo and confirm the one-time Circuit Soda anecdote:
    - `Signal routed.`
    - `You successfully became beverage-adjacent data.`
    - `I would offer a receipt, but the printer remembers too much.`
    - `Your label is still missing, but the machine knows what shelf you go on.`
33. Talk to Vendo again and confirm shorter repeat lines appear.
34. Confirm objective points to `Find Gus in Maintenance Hall`.
35. Save and load.
36. Confirm Circuit Soda completion, objective, and Vendo anecdote state persist.
37. Go to Maintenance Hall.
38. Talk to Gus and confirm Maintenance Sync introduction.
39. Complete Maintenance Sync.
40. Return to Maintenance Hall cleanly.
41. Confirm Memory Signal becomes `Overloaded`.
42. Confirm Staff Corridor unlocks.
43. Talk to Gus and confirm the one-time Maintenance Sync anecdote:
    - `Door's listening now.`
    - `I do not like doors that listen.`
    - `But if it opens, part of you matched something it lost.`
    - `Door heard both knocks. Yours, and the one you forgot making.`
44. Talk to Gus again and confirm shorter repeat lines appear.
45. Confirm objective points to `Enter the Staff Corridor`.
46. Save and load.
47. Confirm Maintenance Sync completion, Staff Corridor unlock, Memory Signal, objective, and Gus anecdote state persist.
48. Enter Staff Corridor.
49. Interact with Memory Echo.
50. Confirm the one-time Memory Echo anecdote:
    - `Echo stabilized.`
    - `The arcade stops arguing with itself.`
    - `That might be worse.`
51. Interact with Memory Echo again and confirm shorter repeat lines appear.
52. Save and load.
53. Confirm Memory Echo anecdote state persists and Staff Corridor remains accessible.
54. Enter Staff Room.
55. Confirm the pre-reveal Staff Room interactions still work.
56. Start the reveal sequence.
57. Advance through the full reveal sequence.
58. Confirm missing reveal art uses placeholders without blocking progression.
59. Confirm the ending prompt appears.
60. Choose `Save and Continue`.
61. Confirm the game saves and returns to the correct post-reveal state.
62. Save and load after the reveal.
63. Confirm reveal, ending, post-reveal state, and required route completion persist.

## Pass Criteria
- No script errors.
- No scene path errors.
- No soft locks or dead-end rooms.
- No save/load regression at any checkpoint.
- Objective text always points to the next required owner and location.
- Each required quest owner gives first-time completion dialogue after their puzzle is complete.
- Each required quest owner switches to shorter repeat lines after the anecdote flag is set.
- No optional NPC, optional minigame, optional secret, or optional post-reveal interaction is required to reach the ending.
- Memory Signal progresses as `Grounded -> Uneasy -> Fractured -> Overloaded`.
- Full route takes longer than the original MVP route without feeling padded.

## Required Save Flags
Confirm these survive save/load at the appropriate checkpoints:
- `rockbyte_duel_completed`
- `lost_token_collected`
- `lost_token_quest_completed`
- `mira_rockbyte_anecdote_seen`
- `lying_cabinets_completed`
- `second_memory_fragment_collected`
- `mr_byte_truth_filter_anecdote_seen`
- `circuit_soda_completed`
- `vendo_circuit_anecdote_seen`
- `maintenance_sync_completed`
- `story_puzzle_completed`
- `staff_room_unlocked`
- `gus_sync_anecdote_seen`
- `memory_echo_anecdote_seen`
- `twist_reveal_seen`

## Failure Triage
If the route fails, fix in this order:
1. Scene path or transition errors.
2. Save/load state loss.
3. Objective text pointing to the wrong owner or location.
4. Missing required completion dialogue.
5. Optional content accidentally blocking the main route.
6. Pacing issues where a required puzzle feels like filler.
