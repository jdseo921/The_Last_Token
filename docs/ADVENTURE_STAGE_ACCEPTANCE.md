# Hybrid Adventure Acceptance Checklist

All seven adventure scenes use `HybridAdventureStage`, authored profiles from
`HybridAdventureCatalog`, and `HybridExplorerController`. The target is a
three-to-four-minute first clear, not a speed-run time.

## Movement FSM

- Confirm the player visibly transitions among Idle, Run, Jump, WallCling, and Crouch.
- Tap Jump for a short hop and hold it for a higher jump.
- Confirm the ground jump can be followed by exactly three mid-air jumps.
- Crouch under a low route and confirm both movement speed and collision height shrink.
- Touch a wall while airborne and confirm the player automatically clings/slides.
- Press Jump while clinging and confirm the free kick launches diagonally away.
- Hold Up and press Jump while clinging: the player rises vertically and loses 25 wall energy.
- Confirm wall energy never recharges in the air and recharges only on solid ground.

## Shared Stage Contract

- Play Ticket Depth Sweep, Cabinet Signal Climb, Carbonation Underpass,
  Prize Echo Ascent, Static Service Depths, Fractured Night Crossing, and
  Night Ledger Traverse.
- In each stage, visit the upper rail, main rail, and sub-layer through portals.
- Confirm every W/S portal lands above visible solid ground without intersecting
  a wall, static patch, or moving-hazard sweep.
- Confirm four thresholds update the respawn point without erasing collected items.
- Confirm each threshold has a visible SAVE marker and every respawn settles on
  safe main-rail floor.
- Collect every stage item and all three keys; the exit must remain locked until both are complete.
- On ordered routes, only the next numbered pickup should glow at full strength;
  touching a later pickup must not spam the error sound or erase progress.
- Confirm static and moving hazards return the player to the latest threshold while preserving progress.
- Confirm Reset rebuilds the route, ESC opens the standard minigame pause menu, and completion returns to the correct map/spawn point.
- Check title, objective, counters, energy, status, controls, and completion copy at one, two, and three lines; every text block must stay centered inside its own panel.

## 2D / 3D Host Bridge

- Connect `master_scene_event` on the explorer or `hybrid_transition_requested`
  on the stage from a master 3D scene.
- Confirm emitted dictionaries include the event, 2D position, FSM state,
  current wall energy, and event-specific data.
- Optionally assign `master_3d_bridge_path` to a node implementing
  `receive_2d_exploration_data(packet)` and confirm it receives the same data.

## Automated Checks

- `scripts/qa/HybridExplorerSmoke.gd`
- `tools/smoke_adventure.gd` (authored-route geometry plus live movement,
  pickup, respawn, portal, reset, HUD, and pause checks)
- `scripts/qa/ArchiveHistorySmoke.gd`
- `scripts/qa/MinigameLayoutAudit.gd`
- `scripts/qa/MinigameUiArchitectureSmoke.gd`
- `scripts/qa/MinigamePauseCoverageSmoke.gd`
