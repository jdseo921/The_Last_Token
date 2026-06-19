# Map Expansion Plan

## Purpose
This document defines how The Last Token can expand from the current ArcadeHub into a compact 45-60 minute layout.

This is planning only. Do not create new scenes from this document until the required content gate for the previous area passes.

## Map Design Rules
- Every map needs a story reason.
- Every map needs a clear owner, landmark, and exit.
- Maps should be small and atmospheric.
- Do not add maze-like navigation.
- Do not split content across many rooms if one readable room works.
- Every new map must support save/load return positions.
- Every new map must remain readable at supported resolutions.

## Planned Map List

| Map | Purpose | Primary NPC/Object | Required Content | Optional Content |
| --- | --- | --- | --- | --- |
| ArcadeHub | Starting hub and emotional anchor | Mira / Cabinet 07 | Lost Token | Owner Portrait, Broken Cabinet |
| Cabinet Row | Machine record area | Mr. Byte | Truth Filter | Roxy / Broken High Score |
| Snack Alcove | Signal routing and comic contrast | Vendo | Circuit Soda | Snack machine lore |
| Prize Corner | Optional secret area | Pip | None | Prize Counter secret |
| Maintenance Hall | Staff access preparation | Gus | Maintenance Sync / Sync Door | Maintenance notes |
| Staff Corridor | Pre-reveal pressure | Staff Door / memory echoes | Memory Echo | Owner Portrait final clue |
| Staff Room | Reveal and ending | Memory system | Reveal slideshow | Post-reveal reflections |

## Area Details

### ArcadeHub
Role:
- Main starting area.
- Emotional base.
- First quest route.
- Return point between early quests.

Required contents:
- Player spawn.
- Mira near ticket counter.
- Cabinet 07.
- Staff Door access point.
- Route to Cabinet Row, later Snack Alcove and Maintenance Hall.

Optional contents:
- Owner Portrait.
- Broken Cabinet.
- Post-reveal dialogue changes.

Visual identity:
- Dark arcade floor.
- Ticket counter glow.
- Cabinet 07 visually obvious.
- Staff Door visible but not immediately accessible.

Story use:
- The player starts confused.
- Mira gives the first anchor.
- The room becomes more reactive as Memory Signal rises.

Expansion gate:
- First quest vertical slice must pass before this area expands further.

### Cabinet Row
Role:
- Machine logic and record contradiction area.
- Act 2 required route.

Required contents:
- Mr. Byte.
- Truth Filter cabinet or terminal.
- Clear route back to ArcadeHub.

Optional contents:
- Roxy.
- Broken High Score.
- Additional machine flavor barks after Truth Filter.

Visual identity:
- Tighter cabinet corridor.
- Many screens, some corrupted.
- Mr. Byte should read as a help terminal or kiosk.
- Truth Filter should stand apart from decorative cabinets.

Story use:
- The player learns that memory statements can be filtered.
- Machine records become more personal.
- Optional high-score content reinforces corrupted identity.

Expansion gate:
- Truth Filter must be complete, readable, and save/load stable before adding Roxy content.

### Snack Alcove
Role:
- Vendo's required quest space.
- A tonal breather that still advances the mystery.

Required contents:
- Vendo.
- Circuit Soda puzzle access.
- Route back to ArcadeHub or Cabinet Row.

Optional contents:
- Snack signage.
- Small lore notes about staff breaks and missing shifts.

Visual identity:
- Vending machine glow.
- Small seating or break-area details.
- Brighter neon accents than Maintenance Hall.

Story use:
- Translate memory instability into signal flow.
- Let Vendo joke while giving real guidance.
- Prepare the player for Sync Door logic.

Expansion gate:
- Circuit Soda must be designed as a small standalone puzzle with clear rules before the area is built.

### Prize Corner
Role:
- Optional secret area.
- Reward observation without blocking progress.

Required contents:
- None for main route.

Optional contents:
- Pip.
- Prize Counter secret quest.
- Small prize displays and ticket references.

Visual identity:
- Slightly warmer color palette.
- Glass case, small prizes, ticket machines.
- Still eerie, but more nostalgic than hostile.

Story use:
- Show the arcade had ordinary memories before it became haunted.
- Give optional clues about tokens, prizes, and staff routines.
- Provide post-reveal emotional callbacks.

Expansion gate:
- Add only after the required route through Maintenance Sync is stable.

### Maintenance Hall
Role:
- Practical systems area.
- Bridge from arcade floor to Staff Door access.

Required contents:
- Gus.
- Maintenance Sync puzzle or Sync Door interface.
- Staff Door system access.

Optional contents:
- Maintenance notes.
- Small mechanical echoes.

Visual identity:
- Less neon, more utility lighting.
- Exposed panels, cables, fuse boxes.
- Gus should be easy to find.

Story use:
- Gus frames the two-signal problem.
- The player sees that the arcade's staff systems recognize conflicting versions.
- Success unlocks the Staff Corridor and changes Memory Signal to Overloaded.

Expansion gate:
- Truth Filter and Circuit Soda must both clearly prepare the player for signal logic.

### Staff Corridor
Role:
- Transition space before the reveal.
- Short, intense, not a full maze.

Required contents:
- Staff-only hallway.
- Memory Echo interactions.
- Entrance to Staff Room.

Optional contents:
- Owner Portrait final clue.
- Staff notices with partial names.

Visual identity:
- Stronger glitch pressure.
- Narrower, quieter space.
- Fewer arcade lights.
- UI and effects must remain readable.

Story use:
- Slow the player down.
- Let the player express confusion and recognition.
- Make the Staff Room feel earned.

Expansion gate:
- Sync Door must be live-tested and save/load stable.

### Staff Room
Role:
- Reveal space.
- Ending setup.
- Post-reveal return point.

Required contents:
- Memory Echo or reveal slideshow.
- Employee 04 reveal.
- Ending prompt.

Optional contents:
- Post-reveal inspection details.
- Changed dialogue if returning to hub.

Visual identity:
- Quiet back room.
- Staff objects, monitors, memory panels.
- Less arcade spectacle, more emotional specificity.

Story use:
- Explain the twist clearly.
- Tie together token, records, missing staff, and Employee 04.
- Unlock Restored Memory Signal and post-reveal roam.

Expansion gate:
- Do not expand the reveal until the required route to reach it is stable.

## Route Flow

### Early Game
ArcadeHub -> Cabinet 07 -> ArcadeHub

The player should learn:
- Who Mira is.
- What Cabinet 07 does.
- How objectives work.
- How minigame return works.

### Mid Game
ArcadeHub -> Cabinet Row -> Snack Alcove -> Maintenance Hall

The player should learn:
- Records conflict.
- Signals can be routed.
- The Staff Door needs two stable inputs.

### Late Game
Maintenance Hall -> Staff Corridor -> Staff Room

The player should learn:
- The arcade recognizes the player as more than one record.
- Employee 04 is the missing staff identity.
- The reveal resolves the Memory Signal.

### Post-Reveal
Staff Room -> ArcadeHub / optional areas

The player can:
- Revisit NPCs.
- Read changed dialogue.
- Resolve optional secrets.
- Return to title or save and continue.

## Navigation Guidance
Each new route should use:
- A clear objective update.
- A temporary quest notice.
- A small persistent hub objective when no menu/dialogue is open.
- NPC nudges on repeated dialogue.
- Visual landmarks, not only text.

## Save/Load Requirements
Each map expansion must save:
- Current map or safe return map.
- Player return position.
- Quest flags.
- Minigame completion flags.
- Optional secret flags.
- Memory Signal state through progress flags.

If a player saves inside a minigame or transition, loading should return them to a safe map position rather than a broken intermediate state.

## Implementation Order Recommendation
1. Finish first quest live gate.
2. Stabilize Truth Filter in Cabinet Row.
3. Add Snack Alcove only when Circuit Soda has a written puzzle plan.
4. Add Maintenance Hall after Vendo's route is stable.
5. Add Staff Corridor as a short transition, not a large map.
6. Polish Staff Room reveal.
7. Add optional Prize Corner / Roxy / Pip content after the ending route is complete.
