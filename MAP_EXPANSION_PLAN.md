# Map Expansion Plan

## Purpose
Plan multiple compact maps for a 45-75 minute arcade mystery while avoiding maze growth.

This is planning only. Each map expansion must preserve the playable loop and save/load stability.

## Map Rules
- Each map has one clear purpose, one primary landmark, and one obvious exit.
- No sprawling maze.
- No room exists only to pad walking time.
- Required content should be near the map's main landmark.
- Optional content should sit off to the side, not behind confusing navigation.
- If a map cannot justify at least one story beat, fold the content into an existing map.

## Map Matrix

| Map | Required Content | Optional Content | Owner / Landmark | Unlock | Exit Rule | Est. Route Time |
| --- | --- | --- | --- | --- | --- | --- |
| ArcadeHub | Rockbyte Duel, start of Lost Shift File, Staff Room return path | Owner Portrait Chain, Broken Cabinet Chain, Vendo Memory Cola Riddle | Mira, Cabinet 07, Staff Door | Start | Exits to Cabinet Row, Snack Alcove, Maintenance Hall, Staff Corridor when unlocked. | 10-14 min total across visits |
| Cabinet Row | Truth Filter, Lost Shift File record step | Broken High Score, Staff Records Chain | Mr. Byte, Truth Filter cabinet | After Lost Token | Clear return to ArcadeHub. | 8-12 min |
| Snack Alcove | Circuit Soda | Vendo Memory Cola Riddle, snack note flavor | Vendo, Circuit Soda machine | After Truth Filter | Clear return to ArcadeHub or Cabinet Row. | 6-9 min |
| Prize Corner | None required | Prize Sort, post-reveal Pip witness | Pip, prize counter | After Truth Filter or as optional side path | Clear return to ArcadeHub. | 4-8 min |
| Maintenance Hall | Lost Shift File repair-note step, Static Service Run, Maintenance Sync | Broken Cabinet or maintenance note echoes | Gus, Sync Door | After Circuit Soda | Clear return to ArcadeHub; later opens Staff Corridor. | 14-20 min |
| Staff Corridor | Security Tape Assembly, Final Night Walk, Memory Echo | Owner Portrait final clue, Staff Records Chain | Staff Door, tape terminal, Final Night terminal, Memory Echo | After Maintenance Sync | Straight route: Maintenance Hall/Hub side -> Staff Room door. | 16-24 min |
| Staff Room | Staff Room reveal | Post-reveal inspection details | Reveal panels, staff table | After Memory Echo | Exit returns to ArcadeHub or ending prompt. | 6-10 min |

## Area Plans

### ArcadeHub
Purpose:
- Starting emotional anchor.
- Teaches interactions and first minigame return.
- Hosts recurring object clues.

Required content:
- Mira introduces the Lost Token.
- Cabinet 07 launches Rockbyte Duel.
- Lost Shift File starts when Mira admits an old shift record is missing.

Optional content:
- Owner Portrait Chain.
- Broken Cabinet Chain.
- Vendo Memory Cola Riddle if Vendo is represented in hub dialogue.

Expansion control:
- Do not add more decorative cabinets unless they provide readable state changes.

### Cabinet Row
Purpose:
- Machine records and contradiction logic.

Required content:
- Mr. Byte owns Truth Filter.
- Mr. Byte contributes the "clock-in mismatch" page for Lost Shift File.

Optional content:
- Roxy and Broken High Score.
- Staff Records Chain after Lost Shift File.

Expansion control:
- Truth Filter and Broken High Score must remain visually distinct.

### Snack Alcove
Purpose:
- Signal routing and tonal breather.

Required content:
- Vendo owns Circuit Soda.

Optional content:
- Vendo Memory Cola Riddle.
- Short snack-break note that can support Staff Records Chain.

Expansion control:
- Keep this as one small room, not a full food court.

### Prize Corner
Purpose:
- Optional warmth and observation.

Required content:
- None.

Optional content:
- Pip owns Prize Sort.
- Pip can join Post-Reveal Witness Route.

Expansion control:
- Prize Sort must not require inventory or hauling items across maps.

### Maintenance Hall
Purpose:
- Practical systems and staff access.

Required content:
- Gus contributes the repair note for Lost Shift File.
- Gus owns Static Service Run after Lost Shift File.
- Gus owns Maintenance Sync.

Optional content:
- Maintenance note echoes and broken cabinet callbacks.

Expansion control:
- The hall should be a short utility room, not a labyrinth.

### Staff Corridor
Purpose:
- Final pressure before reveal.

Required content:
- Staff Door blocks access.
- Security Tape Assembly reconstructs corrupted footage.
- Final Night Walk reconstructs the route through the past.
- Memory Echo stabilizes identity.

Optional content:
- Owner Portrait final "04" clue.
- Staff Records Chain terminal.

Expansion control:
- Keep the corridor straight and tense. No branching maze.

### Staff Room
Purpose:
- Reveal and emotional resolution.

Required content:
- Employee 04 reveal.
- Ending prompt or return-to-roam handoff.

Optional content:
- Short post-reveal object inspections.
- Witness Route can point back out to NPCs.

Expansion control:
- Do not expand into a large back-office zone before the reveal is working.

## Navigation Flow
Main route:
ArcadeHub -> Cabinet Row -> Snack Alcove -> ArcadeHub/Maintenance Hall -> Cabinet Row/Maintenance Hall for Lost Shift File -> Maintenance Hall for Static Service Run and Maintenance Sync -> Staff Corridor for Security Tape Assembly, Final Night Walk, and Memory Echo -> Staff Room.

Optional route:
Cabinet Row for Roxy, Prize Corner for Pip, ArcadeHub/Staff Corridor for object chains, all maps for Post-Reveal Witness Route.

## Save/Load Requirements
Each map must safely preserve:
- Current map or safe return map.
- Player return position.
- Required quest flags.
- Optional content flags.
- Memory Signal state as derived from flags.
- Whether owner completion anecdotes have already played.

If a player saves inside a minigame, tape assembly, transition, or reveal, loading should return them to a safe map position.

## Expansion Order
1. Keep current route stable through Staff Room reveal.
2. Add Lost Shift File as a lore-reading bridge before Maintenance Sync.
3. Add Static Service Run in Maintenance Hall before Maintenance Sync.
4. Add Security Tape Assembly in Staff Corridor before Final Night Walk.
5. Add Final Night Walk in Staff Corridor before Memory Echo.
4. Strengthen optional object chains.
5. Add Post-Reveal Witness Route after the reveal is clear.
