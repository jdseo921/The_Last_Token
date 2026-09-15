# The Last Token — MVP Test Plan

Test the Godot 4.7 project from `res://scenes/main/Main.tscn`. Automated headless checks protect state transitions, content wiring, and UI structure; the final acceptance gate remains a clean-save viewport playthrough.

## Canonical required route

1. Arrive as a curious stranger; the protagonist does not yet know the arcade was theirs.
2. Talk to Mira, recover the first token through Rockbyte Duel, and return it to her.
3. Follow Mira's lead to Roxy, then catch up with Gus.
4. Complete Broken High Score and Truth Filter; return to Mr. Byte, then Gus.
5. Meet Vendo in Snack Alcove, complete Circuit Soda, return to Vendo, hear `???`, and ask Vendo about the voice.
6. Reach Prize Corner, meet Pip, complete Prize Echo Ascent, return its item to Pip, then take Pip's lead to Gus.
7. Follow Closing Shift Echoes in strict order: Mira → Broken Score → Service Dash → Gus.
8. Complete Static Service Run and Maintenance Sync with Gus.
9. Restore Security Tape Assembly, complete Final Night Walk, and stabilize Memory Echo.
10. Enter the Staff Room, complete the reveal and final self-conflict, then enter Post-Reveal Roam.

The internal quest ID `lost_shift_file` remains for old-save compatibility. Its only player-facing name is **Closing Shift Echoes**.

## Optional route

- After Circuit Soda is complete, the After-Hours Archive may be explored.
- Night Ledger is the room's only NPC-like machine and must be spoken to before its stage opens.
- Night Ledger Traverse awards the Duplex Token and extra protagonist history.
- The optional route must never advance, replace, or gate the required route.

## Story sanity gates

- Early protagonist dialogue expresses confusion, not prior arcade knowledge.
- Cast recognition is distributed: Mira remembers the youthful dream, Pip remembers wanting and work, Gus remembers the late closing routine, and Mr. Byte connects records and staff responsibility.
- No pre-reveal dialogue explicitly identifies the protagonist as Employee 04 or explains the full separation.
- `???` represents the burdened half without being framed as a simple villain.
- A win or loss provides evidence and perspective; it never defines the protagonist's whole life.
- Youthful hope and adult responsibility are reconciled in the ending rather than treating either half as disposable.
- Required completion dialogue returns control to the player and points to the next owner/location.

## Quest and navigation gates

- Service Hallway stays inaccessible until Catch Up with Gus is complete.
- After-Hours Archive stays gated until Circuit Soda completion.
- Prize Echo Ascent is launched by the interactable beside Pip, not by Pip's body.
- After Prize Echo Ascent, the route returns to Pip before Gus Has a Lead begins.
- Closing Shift Echoes accepts clues only in its authored order.
- Navigation appears immediately when a new required objective becomes active and closes when the correct conversation starts.
- Later-hallway `???` events remain silent when entered early and are not consumed until their story prerequisite is met.

## Minigame and adventure gates

- Every playable minigame supports the shared Escape pause menu.
- Wrapped and multiline text remains horizontally and vertically centered within its authored box.
- Rockbyte Duel remains the layout reference for readable retro typography and consistent padding.
- Adventure stages reserve their upper and lower UI bands for instructions/status and leave the center viewport unobstructed.
- Hybrid adventures support movement, variable jump, multi-jump, crouch, wall cling/kick/rise, portals, checkpoints, ordered collection where required, and reset.
- A clean playthrough of each required adventure is completable without unreachable collectibles or unavoidable respawn loops.

## Save/load gates

- Slot display shows only slot number, status, and last-saved time.
- Save/load preserves the current required handoff and safe return spawn.
- Old saves using retired archive or Lost Shift File keys migrate into the current Night Ledger and Closing Shift Echoes state.
- Staff Room access never unlocks before Memory Echo completion.
- Post-reveal state and witness conversations survive save/load.

## Automated checks

Run the focused smoke scripts under `scripts/qa/`:

- `StorylineSanitySmoke.gd`
- `QuestFlowAudit.gd`
- `RequiredRouteStateSmoke.gd`
- `LoreConsistencySmoke.gd`
- `DialoguePoolSmoke.gd`
- `DialogueHandoffSmoke.gd`
- `ClosingShiftEchoesSmoke.gd`
- `ScenePathSmoke.gd`
- `HybridExplorerSmoke.gd`
- `MinigameLayoutAudit.gd`
- `MinigameUiArchitectureSmoke.gd`
- `MinigamePauseCoverageSmoke.gd`
- `GameSanityAudit.gd`

All must exit successfully without parser, missing-resource, or invalid-node errors.

## Live acceptance pass

From **New Memory**, complete the canonical route without the developer route menu. At each handoff confirm:

- the dialogue motivation flows into the next objective;
- the objective names the correct person/object and location;
- the route is physically reachable and collisions do not overlap interactions;
- the returning player receives a completion response before the next quest begins;
- no machine speaks the player's post-minigame monologue for them;
- audio, pause, navigation, save, and load continue working.

Finally export the `Windows Desktop` preset and launch the generated build once.
