# ASSET_MANIFEST.md

## Purpose
This manifest tracks planned visual assets for The Last Token. It is a production checklist, not a requirement to add all assets before MVP testing.

Status values:
- `Placeholder`: current simple shape/text is acceptable for MVP.
- `Planned`: asset should be created in a future visual pass.
- `In Progress`: asset exists but needs review/import/tuning.
- `Integrated`: asset is in Godot and manually checked.

## Folder Structure
Future production art should use the `assets/art/` tree. These folders may be empty until assets are created.

```text
assets/art/
assets/art/characters/
assets/art/characters/player/
assets/art/characters/mira/
assets/art/characters/gus/
assets/art/characters/vendo/
assets/art/characters/mr_byte/
assets/art/characters/roxy/
assets/art/characters/pip/
assets/art/portraits/
assets/art/portraits/player/
assets/art/portraits/mira/
assets/art/portraits/gus/
assets/art/portraits/vendo/
assets/art/portraits/mr_byte/
assets/art/portraits/roxy/
assets/art/portraits/pip/
assets/art/hub/
assets/art/hub/backgrounds/
assets/art/hub/tiles/
assets/art/hub/props/
assets/art/hub/cabinets/
assets/art/hub/effects/
assets/art/maps/
assets/art/maps/cabinet_row/
assets/art/maps/snack_alcove/
assets/art/maps/prize_corner/
assets/art/maps/maintenance_hall/
assets/art/minigames/
assets/art/minigames/rockbyte_duel/
assets/art/minigames/sync_door/
assets/art/minigames/truth_filter/
assets/art/minigames/circuit_soda/
assets/art/minigames/broken_high_score/
assets/art/minigames/adventure/
assets/art/minigames/security_tape/
assets/art/cutscenes/
assets/art/cutscenes/memory_reveal/
assets/art/ui/
assets/art/ui/dialogue/
assets/art/ui/title/
assets/art/ui/menus/
assets/art/ui/crt/
```

The lightweight path helper is `scripts/AssetPaths.gd`. It is not autoloaded; use it only when a future visual replacement needs safe optional asset loading.

The JSON lookup draft is `data/asset_manifest.json`. It maps stable asset keys to planned paths, but the referenced image files are not required to exist yet.

| Asset | Recommended Size | Folder | Status | Notes |
|---|---:|---|---|---|
| Player sprite | 32x32 | `assets/art/characters/player/player_gameplay.png` | Integrated | Regular gameplay sprite; face obscured for story reasons. |
| Player post-game sprite | 32x32 | `assets/art/characters/player/player_gameplay_glitch.png` | Integrated | Glitchier post-game variant; same obscured-face silhouette. |
| Player 8-direction walk sheet | 16 frames, 32x32 each | `assets/art/characters/player/player_walk_8dir_sheet.png` | Integrated | Regular movement sheet; 2 frames per direction. |
| Player post-game 8-direction walk sheet | 16 frames, 32x32 each | `assets/art/characters/player/player_walk_8dir_glitch_sheet.png` | Integrated | Glitch movement sheet; 2 frames per direction. |
| Mira sprite | 32x32 | `assets/art/characters/mira/` | Placeholder | Warm but slightly haunted silhouette. |
| Mira diagonal facing sheet | 4 frames, 32x32 each | `assets/art/characters/mira/mira_turn_diagonal_sheet.png` | Integrated | Used when Mira turns toward the protagonist. |
| Gus sprite | 32x32 | `assets/art/characters/gus/` | Placeholder | Practical arcade regular. |
| Gus diagonal facing sheet | 4 frames, 32x32 each | `assets/art/characters/gus/gus_turn_diagonal_sheet.png` | Integrated | Used when Gus turns toward the protagonist. |
| Vendo sprite | 32x48 or 48x48 | `assets/art/characters/vendo/` | Placeholder | Machine-like NPC; vending-machine readable. |
| Mr. Byte sprite | 32x48 or 48x48 | `assets/art/characters/mr_byte/` | Placeholder | Kiosk/helper machine silhouette. |
| Cabinet 07 sprite | 48x64 or 64x64 | `assets/art/hub/cabinets/` | Placeholder | Important story cabinet; screen glow. |
| Broken Cabinet sprite | 48x48 or 64x48 | `assets/art/hub/cabinets/` | Placeholder | Damaged readable cabinet. |
| Memory Terminal sprite | 48x32 or 64x48 | `assets/art/hub/props/` | Placeholder | Save terminal; clear interactable glow. |
| Staff Door sprite | 64x96 | `assets/art/hub/props/` | Placeholder | Locked/open states eventually. |
| Owner Portrait sprite | 32x32 or 48x48 | `assets/art/hub/props/` | Placeholder | Scratched nameplate, unsettling blankness. |
| Arcade hub background | 640x440 or tiled | `assets/art/hub/backgrounds/arcade_hub_background_640x440.png` | Integrated | Optional full-scene backdrop; keep interactables readable. |
| Ticket counter art | 96x48 or tiled | `assets/art/hub/props/ticket_counter.png` | Integrated | Replaces ticket counter placeholder when present. |
| Memory terminal art | 48x32 or 64x48 | `assets/art/hub/props/memory_terminal.png` | Integrated | Replaces terminal placeholder when present. |
| Staff door closed art | 64x96 | `assets/art/hub/props/staff_door_closed.png` | Integrated | Closed/locked staff door state. |
| Staff door open art | 64x96 | `assets/art/hub/props/staff_door_open.png` | Planned | Open/unlocked staff door state. |
| Owner portrait blank art | 48x48 | `assets/art/hub/props/owner_portrait_blank.png` | Integrated | Pre-reveal portrait state. |
| Owner portrait Employee 04 art | 48x48 | `assets/art/hub/props/owner_portrait_employee04.png` | Planned | Post-reveal portrait state. |
| Cabinet 07 idle art | 48x64 or 64x64 | `assets/art/hub/cabinets/cabinet_07_idle.png` | Integrated | Idle cabinet state. |
| Cabinet 07 flicker art | 48x64 or 64x64 | `assets/art/hub/cabinets/cabinet_07_flicker.png` / `cabinet_07_flicker_sheet.png` | Integrated | Optional flicker overlay/state; sheet kept for future animation. |
| Broken cabinet art | 48x48 or 64x48 | `assets/art/hub/cabinets/broken_cabinet.png` | Integrated | Replaces broken cabinet placeholder when present. |
| Cabinet Row background | 640x440 | `assets/art/maps/cabinet_row/cabinet_row_background_640x440.png` | Integrated | Optional map background with placeholder fallback. |
| Snack Alcove background | 640x440 | `assets/art/maps/snack_alcove/snack_alcove_background_640x440.png` | Integrated | Optional map background with placeholder fallback. |
| Prize Corner background | 640x440 | `assets/art/maps/prize_corner/prize_corner_background_640x440.png` | Integrated | Optional map background with placeholder fallback. |
| Maintenance Hall background | 640x440 | `assets/art/maps/maintenance_hall/maintenance_hall_background_640x440.png` | Integrated | Optional map background with placeholder fallback. |
| Arcade floor tiles | 16x16 | `assets/art/hub/tiles/` | Placeholder | Dark carpet/tile pattern; low noise. |
| Arcade wall tiles | 16x16 | `assets/art/hub/tiles/` | Placeholder | Dim walls, trim, posters optional later. |
| Ticket counter | 96x48 or tiled | `assets/art/hub/props/` | Placeholder | Counter should not overpower Mira. |
| Vending machine | 48x64 | `assets/art/hub/props/` | Placeholder | Could share Vendo visual if useful. |
| Title background | 640x440 | `assets/art/ui/title/title_background_640x440.png` | Integrated | Retro arcade title backdrop; fallback stays dark. |
| Title logo | Flexible, pixel-aligned | `assets/art/ui/title/the_last_token_logo.png` | Integrated | Replaces fallback `THE LAST TOKEN` text when present. |
| Title menu frame | 384x240 or scalable | `assets/art/ui/title/title_menu_frame.png` | Integrated | Wider decorative frame behind menu buttons. |
| Settings menu frame | 456x356 | `assets/art/ui/menus/settings_menu_frame.png` | Integrated | Decorative frame behind scrollable settings controls. |
| Quest window frame | 1024x704 scalable | `assets/art/ui/menus/quest_window_frame.png` | Integrated | Quest notification and detail frame scaled to 80% of the active viewport. |
| Title scanline overlay | 640x440 | `assets/art/ui/title/title_scanline_overlay.png` | Integrated | Subtle overlay only; must not reduce readability. |
| CRT overlay | 640x440 | `assets/art/ui/crt/` | Planned | Keep subtle; do not reduce readability. |
| Dialogue portraits | 64x64 or 96x96 | `assets/art/portraits/` | In Progress | First 96x96 portrait batch generated and wired through DialogueBox; keep pending until live Godot dialogue review passes. |
| Memory recall panels | 320x180 or 640x360 | `assets/art/cutscenes/memory_reveal/` | Placeholder | 8 reveal panels currently support fallback. |
| Rockbyte Duel screen art | 320x180 or UI pieces | `assets/art/minigames/rockbyte_duel/` | Placeholder | Keep rules and piles readable. |
| Sync Door screen art | 320x180 or UI pieces | `assets/art/minigames/sync_door/` | Placeholder | Switch states must remain obvious. |
| Truth Filter cabinet states | 4 frames, 64x64 each | `assets/art/minigames/truth_filter/truth_filter_cabinets_sheet.png` | Integrated | Optional state sheet with panel-color fallback. |
| Circuit Soda tile sheet | 6 frames, 32x32 each | `assets/art/minigames/circuit_soda/circuit_soda_tiles_sheet.png` | Integrated | Optional tile icons with text-button fallback. |
| Broken High Score screen art | 640x440 | `assets/art/minigames/broken_high_score/broken_high_score_screen.png` | Integrated | Optional screen background with flat-color fallback; feature remains non-blocking. |
| Adventure player 8-bit sprite | 16x16 | `assets/art/minigames/adventure/player_8bit.png` | Planned | Shared optional player sprite for Static Service Run and Final Night Walk; colored square fallback remains. |
| Static Service maintenance tiles | 16x16 or 24x24 tiles | `assets/art/minigames/adventure/maintenance_tiles.png` | Planned | Future tile sheet for service floor/walls; current colored placeholder grid remains readable if missing. |
| Static Service static leak | 16x16 | `assets/art/minigames/adventure/static_leak.png` | Planned | Hazard art; must read as electrical/static leak at tile scale. |
| Static Service signal fuse | 16x16 | `assets/art/minigames/adventure/signal_fuse.png` | Planned | Collectible art for 3 Signal Fuses; current `F` marker remains if missing. |
| Static Service breaker panel | 16x16 | `assets/art/minigames/adventure/breaker_panel.png` | Planned | Goal tile art; must be visibly distinct from fuses and hazards. |
| Security Tape background | 640x440 or scalable | `assets/art/minigames/security_tape/security_tape_background.png` | Planned | Optional full-screen backdrop behind the existing panel; must not reduce text contrast. |
| Security Tape fragment panel | Scalable UI panel or 96x32 per button | `assets/art/minigames/security_tape/tape_fragment_panel.png` | Planned | Optional button/panel texture for tape fragments; text labels must remain legible. |
| Security Tape static overlay | 640x440 transparent overlay | `assets/art/minigames/security_tape/tape_static_overlay.png` | Planned | Optional subtle static layer; must ignore input and stay low-opacity. |
| Final Night tiles | 16x16 or 24x24 tiles | `assets/art/minigames/adventure/final_night_tiles.png` | Planned | Future tile sheet for the memory route; current purple/blue placeholder grid remains. |
| Final Night memory frame | 16x16 | `assets/art/minigames/adventure/memory_frame.png` | Planned | Ordered collectible art; frame number/text feedback must remain readable. |
| Final Night rewind static | 16x16 | `assets/art/minigames/adventure/rewind_static.png` | Planned | Hazard art; should feel distinct from Static Service's static leak. |
| Final Night staff door marker | 16x16 | `assets/art/minigames/adventure/staff_door_marker.png` | Planned | Goal/exit marker art; should suggest the Staff Door without revealing Staff Room content. |

## Hub Character Idle Sheet Checklist
| Sheet | Recommended Size | Folder | Status | Notes |
|---|---:|---|---|---|
| Player idle sheet | 2 frames, 32x32 each | `assets/art/characters/player/player_idle_sheet.png` | Integrated | Sheet is 64x32 total; optional hub-only visual, movement remains script-owned. |
| Mira idle sheet | 2 frames, 32x32 each | `assets/art/characters/mira/mira_idle_sheet.png` | Integrated | Sheet is 64x32 total; can replace placeholder body when present. |
| Gus idle sheet | 2 frames, 32x32 each | `assets/art/characters/gus/gus_idle_sheet.png` | Integrated | Sheet is 64x32 total; can replace placeholder body when present. |
| Vendo idle sheet | 2 frames, 48x48 each | `assets/art/characters/vendo/vendo_idle_sheet.png` | Integrated | Sheet is 96x48 total; larger machine silhouette for readability. |
| Mr. Byte idle sheet | 2 frames, 48x48 each | `assets/art/characters/mr_byte/mr_byte_idle_sheet.png` | Integrated | Sheet is 96x48 total; larger terminal silhouette for readability. |
| Roxy idle sheet | 2 frames, 32x32 each | `assets/art/characters/roxy/roxy_idle_sheet.png` | Integrated | Sheet is 64x32 total; optional interactable idle animation with placeholder fallback. |
| Pip idle sheet | 2 frames, 32x32 each | `assets/art/characters/pip/pip_idle_sheet.png` | Integrated | Sheet is 64x32 total; optional interactable idle animation with placeholder fallback. |

## Dialogue Portrait Checklist
| Portrait | Status | Notes |
|---|---|---|
| Player | In Progress | `player_neutral.png`; default portrait wired, explicit confusion line added. |
| Mira | In Progress | `mira_neutral.png`, `mira_worried.png`; default portrait wired, worried variant used on emotional lines. |
| Gus | In Progress | `gus_neutral.png`, `gus_annoyed.png`; default portrait wired, annoyed variant used on joke/practical lines. |
| Vendo | In Progress | `vendo_neutral.png`; machine face/display, word-by-word dialogue tone. |
| Mr. Byte | In Progress | `mr_byte_neutral.png`; kiosk/helper display. |
| Cabinet 07 | In Progress | `cabinet_07_screen.png`; default portrait wired, explicit recognition lines added. |
| Staff Door | Planned | Optional mechanical portrait or no portrait. |
| Owner Portrait | Planned | Scratched/blank portrait close-up. |
| Employee 04 file | Planned | Corrupted file panel rather than face. |

## Memory Recall Panel Checklist
| Panel | Status | Notes |
|---|---|---|
| Panel 01 | Placeholder | Opening memory beat. |
| Panel 02 | Placeholder | Staff room context. |
| Panel 03 | Placeholder | Shutdown intent. |
| Panel 04 | Placeholder | Machines panic. |
| Panel 05 | Placeholder | System saves what it can. |
| Panel 06 | Placeholder | Everyone remembered. |
| Panel 07 | Placeholder | Player forgot. |
| Panel 08 | Placeholder | Employee 04 reveal. |

## Integration Notes
- Keep this manifest updated when any asset moves from planned to integrated.
- Do not remove placeholder behavior when integrating an asset.
- New optional content art, including Broken High Score, should remain planned until the gameplay feature itself is approved.
