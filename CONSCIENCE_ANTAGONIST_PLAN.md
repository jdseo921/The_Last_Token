# Conscience Antagonist Plan

## Role
`???` is the protagonist's regret and conscience given arcade-system shape. It knows what the protagonist did to Pixel Haven, but it begins as a hostile presence because the protagonist is still treating regret like an enemy instead of evidence.

The name becomes `"Player"` in the final room conversation because the antagonist is not a separate person. The quotation marks mark the difference between the controllable game identity and the person who made the decision that closed the arcade.

Before that reveal, `???` has no sprite, silhouette, or portrait window. Once the final Staff Room conversation displays the antagonist as `"Player"`, its dialogue uses the shaded, pixel-glitched protagonist portrait.

The controllable protagonist's normal dialogue portrait is also withheld until the Staff Room reveal. Before `twist_reveal_seen`, `Player` dialogue uses a blacked-out portrait with the face and clothes obscured and no visible expression. Starting with the final Staff Room self-conflict and post-reveal dialogue, `Player` switches to the normal neutral portrait.

The conscience caused the protagonist's memory loss to protect them from hardship, poverty, exhaustion, regret, failure, bitterness, and self-blame. The final conversation makes clear that the protagonist was an arcade game maker who cared more about players finding joy and solace than about profit, and that pride and regret both belong to them.

## Trigger Order
| Encounter | ID | Trigger | What It Reveals |
| --- | --- | --- | --- |
| Encounter 1 | `after_truth_filter` | After Truth Filter completion, on return to Cabinet Row. | The arcade remembers the protagonist's buried decision. |
| Encounter 2 | `after_circuit_soda` | After Circuit Soda completion, on return to Snack Alcove. | Signal routing mirrors how the protagonist labeled broken things as fixed. |
| Encounter 3 | `after_lost_shift_file` | After Lost Shift File completion or on return to Maintenance Hall. | Employee 04, Mira, Gus, and Mr. Byte all carried pieces of the final night. |
| Encounter 4 | `after_final_night_walk` | After Final Night Walk completion, on return to Staff Corridor. | The second Staff Door signal is almost named. |
| Final Room Conversation | Staff Room terminal flow | After the Staff Room reveal slideshow, before EndingPrompt. | `???` is revealed as `"Player"` and the protagonist accepts pride and regret together. |

## Final Room Conversation Effects
- Sets `conscience_final_room_seen`.
- Sets `conscience_name_revealed`.
- Sets `player_creator_monologue_seen`.
- Calls `GameState.unlock_player_glitched_form()`.
- Runs after `twist_reveal_seen` is set by the reveal slideshow.
- Does not set `post_reveal_roam_unlocked`.
- Shows the existing EndingPrompt after the conversation.

## Glitched Player Form
`GameState.should_use_glitched_player_sprite()` returns true when `player_glitched_form_unlocked`, `twist_reveal_seen`, or `post_reveal_roam_unlocked` is true.

`Player.gd` prefers the glitch gameplay sprite or 8-direction glitch sheet. If glitch art is missing, it falls back to the normal visual with cyan/purple modulation and flicker. Save/load persists the form through `player_glitched_form_unlocked`.

## Reveal Safety
The Staff Room reveal still belongs to the Staff Room terminal and slideshow. Staff Corridor only gates on Memory Echo completion. The final self-conflict conversation plays after the slideshow, so `"Player"` is not revealed before the Staff Room.

If an old save has `twist_reveal_seen` true but `conscience_final_room_seen` false, the Staff Room terminal can play the final self-conflict conversation once as a compatibility fallback.

## Save/Load Expectations
- Seen encounter flags prevent one-shot encounters from repeating.
- Loading after `player_glitched_form_unlocked` shows the glitched player form immediately.
- Loading after the Staff Room reveal still shows post-reveal state through existing reveal and ending flags.
- Legacy post-reveal saves still use the glitched player visual because `twist_reveal_seen` also enables it.

## Acceptance Test
1. Start New Memory.
2. Complete Truth Filter.
3. Confirm Encounter 1 appears once.
4. Confirm `???` has no sprite, silhouette, or portrait window.
5. Confirm pre-reveal `Player` dialogue uses the obscured blacked-out portrait, not the normal neutral portrait.
6. Save/load.
7. Confirm Encounter 1 does not repeat.
8. Complete Circuit Soda.
9. Confirm Encounter 2 appears once.
10. Complete Lost Shift File.
11. Confirm Encounter 3 appears once.
12. Complete Final Night Walk.
13. Confirm Encounter 4 appears once.
14. Confirm all `???` encounters remain text-only with no antagonist sprite or portrait window.
15. Complete Memory Echo.
16. Interact with Staff Room door.
17. Confirm Staff Room opens.
18. Start terminal reveal.
19. Watch the reveal slideshow.
20. Confirm the protagonist speaks first after the slideshow.
21. Confirm the protagonist now uses the normal neutral portrait.
22. Confirm antagonist name is `"Player"`.
23. Confirm `"Player"` uses the shaded, pixel-glitched protagonist portrait.
24. Confirm the memory-loss explanation is clear.
25. Confirm the protagonist describes valuing player joy over profit.
26. Confirm pride and regret are both accepted.
27. Confirm `player_glitched_form_unlocked` becomes true after the conversation.
28. Confirm player sprite changes or fallback glitch effect appears.
29. Confirm EndingPrompt appears.
30. Confirm post-reveal roam still works.
31. Save/load after final conversation and confirm glitched form persists.
32. Save/load after reveal and confirm post-reveal state persists.

Do not mark accepted until this is live-tested in Godot.
