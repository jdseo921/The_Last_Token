# Expanded Required Route Acceptance

## Status
- Implementation status: expanded required route implemented with placeholder visuals.
- Acceptance status: not accepted yet.
- Required verification: full live Godot viewport playthrough.
- Scope: required route only. Roxy, Pip, Prize Sort, Broken High Score, and other optional secrets must not be required.

## Test Setup
1. Run from `res://scenes/main/Main.tscn` in Godot 4.x.
2. Start from a clean `New Memory` slot.
3. Use `Esc -> Save` and `Esc -> Load` at every checkpoint.
4. Record any script error, scene path error, soft lock, missing objective update, missing flag, or save/load mismatch.

## Full Route
1. Start a New Memory.
2. Confirm the opening intro plays.
3. Confirm ArcadeHub loads.
4. Confirm the objective points to Mira.
5. Talk to Mira.
6. Confirm Mira starts the Lost Token quest.
7. Confirm the objective points to Cabinet 07.
8. Interact with Cabinet 07.
9. Confirm `res://scenes/minigames/RockbyteDuel.tscn` opens.
10. Complete Rockbyte Duel.
11. Return to ArcadeHub cleanly.
12. Confirm the objective points to Mira.
13. Return the Lost Token to Mira.
14. Confirm Memory Signal becomes `Uneasy`.
15. Talk to Mira again and confirm the one-time Lost Token anecdote:
    - `You brought it back.`
    - `That token used to be just a prize.`
    - `Then it became proof that part of you could still return.`
    - `It remembered you before you did.`
16. Talk to Mira again and confirm shorter repeat lines appear.
17. Save and load.
18. Confirm Lost Token completion, Memory Signal, objective, and `mira_rockbyte_anecdote_seen` persist.
19. Confirm the objective points to `Find Mr. Byte in Cabinet Row`.
20. Go to Cabinet Row.
21. Talk to Mr. Byte.
22. Confirm Mr. Byte introduces Truth Filter:
    - `Contradiction threshold reached.`
    - `Truth Filter is ready.`
    - `Please choose the least broken answer.`
23. Interact with the Truth Filter cabinet.
24. Confirm `res://scenes/minigames/TruthFilter.tscn` opens.
25. Complete Truth Filter.
26. Return to Cabinet Row or ArcadeHub cleanly.
27. Confirm Memory Signal becomes `Fractured`.
28. Talk to Mr. Byte and confirm the one-time Truth Filter anecdote:
    - `Truth Filter passed.`
    - `Contradictions remain.`
    - `That means the memory is alive enough to argue.`
    - `Record conflict reduced. Identity conflict remains.`
29. Talk to Mr. Byte again and confirm shorter repeat lines appear.
30. Save and load.
31. Confirm Truth Filter completion, Memory Signal, objective, and `mr_byte_truth_filter_anecdote_seen` persist.
32. Confirm the objective points to `Find Vendo in the Snack Alcove`.
33. Go to Snack Alcove.
34. Talk to Vendo.
35. Confirm Vendo introduces Circuit Soda:
    - `Memory Signal: Fractured.`
    - `Your signal is going everywhere except where it should.`
    - `Luckily, I am a licensed beverage-adjacent routing system.`
36. Interact with the Circuit Soda machine.
37. Confirm `res://scenes/minigames/CircuitSoda.tscn` opens.
38. Complete Circuit Soda.
39. Return to Snack Alcove cleanly.
40. Talk to Vendo and confirm the one-time Circuit Soda anecdote:
    - `Signal routed.`
    - `You successfully became beverage-adjacent data.`
    - `I would offer a receipt, but the printer remembers too much.`
    - `Your label is still missing, but the machine knows what shelf you go on.`
41. Talk to Vendo again and confirm shorter repeat lines appear.
42. Save and load.
43. Confirm Circuit Soda completion, objective, and `vendo_circuit_anecdote_seen` persist.
44. Confirm the objective points to `Find Gus in Maintenance Hall`.
45. Go to Maintenance Hall.
46. Talk to Gus.
47. Confirm Gus introduces Maintenance Sync:
    - `Truth got filtered, soda got routed, and somehow I am still the janitor.`
    - `Maintenance Hall is next.`
    - `Two signals are fighting in the door.`
48. Complete Maintenance Sync.
49. Return to Maintenance Hall cleanly.
50. Confirm Memory Signal becomes `Overloaded`.
51. Confirm Staff Corridor unlocks.
52. Talk to Gus and confirm the one-time Maintenance Sync anecdote:
    - `Door's listening now.`
    - `I do not like doors that listen.`
    - `But if it opens, part of you matched something it lost.`
    - `Door heard both knocks. Yours, and the one you forgot making.`
53. Talk to Gus again and confirm shorter repeat lines appear.
54. Save and load.
55. Confirm Maintenance Sync completion, Staff Corridor unlock, Memory Signal, objective, and `gus_sync_anecdote_seen` persist.
56. Confirm the objective points to `Enter the Staff Corridor`.
57. Enter Staff Corridor.
58. Interact with Memory Echo.
59. Confirm `res://scenes/cutscenes/MemoryEcho.tscn` opens.
60. Choose one wrong answer.
61. Confirm wrong choice shows:
    - `MEMORY SIGNAL SPIKED.`
    - `TRY AGAIN.`
62. Confirm the same question retries.
63. Complete all three Memory Echo prompts with the preferred answers:
    - Echo 1: `Maybe. I do not remember.`
    - Echo 2: `Because I was not ready.`
    - Echo 3: `Both, somehow.`
64. Confirm completion text:
    - `MEMORY ECHO STABILIZED.`
    - `RESTORE PLAYBACK AVAILABLE.`
65. Return to Staff Corridor cleanly.
66. Confirm the objective points to `Enter the Staff Room`.
67. Interact with Memory Echo again and confirm the one-time Memory Echo anecdote:
    - `Echo stabilized.`
    - `The arcade stops arguing with itself.`
    - `That might be worse.`
68. Interact with Memory Echo again and confirm shorter repeat lines appear:
    - `Echo stable.`
    - `Quiet is not always better.`
69. Save and load.
70. Confirm Memory Echo completion, Staff Room objective, and `memory_echo_anecdote_seen` persist.
71. Interact with the Staff Room door.
72. Confirm it says:
    - `RESTORE PLAYBACK AVAILABLE.`
    - `ENTER STAFF ROOM?`
73. Confirm `res://scenes/arcade/StaffRoom.tscn` opens.
74. Interact with the Staff Room terminal.
75. Confirm the pre-reveal terminal dialogue starts normally.
76. Advance through the full reveal slideshow.
77. Confirm missing reveal art uses placeholders without blocking progression.
78. Confirm `twist_reveal_seen` is set after the slideshow.
79. Confirm the EndingPrompt appears.
80. Choose `Save and Continue`.
81. Confirm the game returns to ArcadeHub in Post-Reveal Roam.
82. Save and load.
83. Confirm reveal, ending, post-reveal state, and required route completion persist.
84. Confirm post-reveal NPC/object interactions still work.

## Early Reveal Gate
Run this once with a debug jump, old save, or temporary forced scene entry.

1. Enter `res://scenes/arcade/StaffRoom.tscn` before `memory_echo_completed` is true.
2. Interact with the terminal.
3. Confirm the reveal does not start.
4. Confirm the terminal says:
   - `RESTORE PLAYBACK LOCKED.`
   - `MEMORY ECHO REQUIRED.`
5. Confirm no script error or soft lock occurs.
6. Load or return to the normal route and complete Memory Echo.
7. Enter Staff Room again.
8. Confirm the reveal can start normally.

## Save/Load Checkpoints
Save and load at these exact checkpoints:
- After Lost Token completion.
- After Truth Filter completion.
- After Circuit Soda completion.
- After Maintenance Sync completion.
- After Memory Echo completion.
- After reveal / Save and Continue.

Each checkpoint must preserve:
- Relevant completion flags.
- Relevant anecdote flags.
- Current objective.
- Memory Signal label.
- Route access locks and unlocks.

## Required Owners And Completion Dialogue
Every required quest must have an owner and a completion story beat:

| Required Step | Owner | Location | Completion Flag | Anecdote Flag |
| --- | --- | --- | --- | --- |
| Rockbyte Duel / Lost Token | Mira | ArcadeHub | `lost_token_quest_completed` | `mira_rockbyte_anecdote_seen` |
| Truth Filter | Mr. Byte | Cabinet Row | `lying_cabinets_completed` | `mr_byte_truth_filter_anecdote_seen` |
| Circuit Soda | Vendo | Snack Alcove | `circuit_soda_completed` | `vendo_circuit_anecdote_seen` |
| Maintenance Sync | Gus | Maintenance Hall | `maintenance_sync_completed` | `gus_sync_anecdote_seen` |
| Memory Echo | Memory Echo | Staff Corridor | `memory_echo_completed` | `memory_echo_anecdote_seen` |

## Pass Criteria
- No script errors.
- No scene path errors.
- No missing GameState flags.
- No soft locks or dead-end rooms.
- No save/load regression at any checkpoint.
- Objective text always points to the next required owner and location.
- Every required quest has an owner.
- Every required quest has completion dialogue.
- Every required owner switches to shorter repeat lines after the anecdote flag is set.
- Memory Signal changes are clear: `Grounded -> Uneasy -> Fractured -> Overloaded`.
- Staff Room reveal cannot happen before Memory Echo completion.
- Optional Roxy/Pip content is not required.
- Full route feels coherent and longer than the MVP without feeling padded.

## Failure Triage
If the route fails, fix in this order:
1. Script errors, missing methods, or missing GameState flags.
2. Scene path or transition errors.
3. Save/load state loss.
4. Objective text pointing to the wrong owner or location.
5. Missing required completion dialogue.
6. Staff Room reveal bypassing Memory Echo.
7. Optional content accidentally blocking the required route.
8. Pacing issues where a required puzzle feels like filler.
