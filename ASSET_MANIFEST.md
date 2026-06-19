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
assets/art/minigames/
assets/art/minigames/rockbyte_duel/
assets/art/minigames/sync_door/
assets/art/minigames/broken_high_score/
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
| Player sprite | 32x32 | `assets/art/characters/player/` | Placeholder | Idle first; walk frames later. |
| Mira sprite | 32x32 | `assets/art/characters/mira/` | Placeholder | Warm but slightly haunted silhouette. |
| Gus sprite | 32x32 | `assets/art/characters/gus/` | Placeholder | Practical arcade regular. |
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
| Arcade floor tiles | 16x16 | `assets/art/hub/tiles/` | Placeholder | Dark carpet/tile pattern; low noise. |
| Arcade wall tiles | 16x16 | `assets/art/hub/tiles/` | Placeholder | Dim walls, trim, posters optional later. |
| Ticket counter | 96x48 or tiled | `assets/art/hub/props/` | Placeholder | Counter should not overpower Mira. |
| Vending machine | 48x64 | `assets/art/hub/props/` | Placeholder | Could share Vendo visual if useful. |
| Title background | 640x440 | `assets/art/ui/title/title_background_640x440.png` | Integrated | Retro arcade title backdrop; fallback stays dark. |
| Title logo | Flexible, pixel-aligned | `assets/art/ui/title/the_last_token_logo.png` | Integrated | Replaces fallback `THE LAST TOKEN` text when present. |
| Title menu frame | 416x270 or scalable | `assets/art/ui/title/title_menu_frame.png` | Integrated | Decorative frame behind menu buttons. |
| Title scanline overlay | 640x440 | `assets/art/ui/title/title_scanline_overlay.png` | Integrated | Subtle overlay only; must not reduce readability. |
| CRT overlay | 640x440 | `assets/art/ui/crt/` | Planned | Keep subtle; do not reduce readability. |
| Dialogue portraits | 64x64 or 96x96 | `assets/art/portraits/` | In Progress | First 96x96 portrait batch generated and wired through DialogueBox; keep pending until live Godot dialogue review passes. |
| Memory recall panels | 320x180 or 640x360 | `assets/art/cutscenes/memory_reveal/` | Placeholder | 8 reveal panels currently support fallback. |
| Rockbyte Duel screen art | 320x180 or UI pieces | `assets/art/minigames/rockbyte_duel/` | Placeholder | Keep rules and piles readable. |
| Sync Door screen art | 320x180 or UI pieces | `assets/art/minigames/sync_door/` | Placeholder | Switch states must remain obvious. |
| Future Broken High Score screen art | 320x180 or UI pieces | `assets/art/minigames/broken_high_score/` | Planned | Do not integrate until optional feature gate passes. |

## Hub Character Idle Sheet Checklist
| Sheet | Recommended Size | Folder | Status | Notes |
|---|---:|---|---|---|
| Player idle sheet | 2 frames, 32x32 each | `assets/art/characters/player/player_idle_sheet.png` | Integrated | Sheet is 64x32 total; optional hub-only visual, movement remains script-owned. |
| Mira idle sheet | 2 frames, 32x32 each | `assets/art/characters/mira/mira_idle_sheet.png` | Integrated | Sheet is 64x32 total; can replace placeholder body when present. |
| Gus idle sheet | 2 frames, 32x32 each | `assets/art/characters/gus/gus_idle_sheet.png` | Integrated | Sheet is 64x32 total; can replace placeholder body when present. |
| Vendo idle sheet | 2 frames, 48x48 each | `assets/art/characters/vendo/vendo_idle_sheet.png` | Integrated | Sheet is 96x48 total; larger machine silhouette for readability. |
| Mr. Byte idle sheet | 2 frames, 48x48 each | `assets/art/characters/mr_byte/mr_byte_idle_sheet.png` | Integrated | Sheet is 96x48 total; larger terminal silhouette for readability. |

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
