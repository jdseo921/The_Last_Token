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
| Arcade floor tiles | 16x16 | `assets/art/hub/tiles/` | Placeholder | Dark carpet/tile pattern; low noise. |
| Arcade wall tiles | 16x16 | `assets/art/hub/tiles/` | Placeholder | Dim walls, trim, posters optional later. |
| Ticket counter | 96x48 or tiled | `assets/art/hub/props/` | Placeholder | Counter should not overpower Mira. |
| Vending machine | 48x64 | `assets/art/hub/props/` | Placeholder | Could share Vendo visual if useful. |
| CRT overlay | 640x440 | `assets/art/ui/crt/` | Planned | Keep subtle; do not reduce readability. |
| Dialogue portraits | 64x64 or 96x96 | `assets/art/portraits/` | Planned | Player, Mira, Gus, Vendo, Mr. Byte, machines as needed. |
| Memory recall panels | 320x180 or 640x360 | `assets/art/cutscenes/memory_reveal/` | Placeholder | 8 reveal panels currently support fallback. |
| Rockbyte Duel screen art | 320x180 or UI pieces | `assets/art/minigames/rockbyte_duel/` | Placeholder | Keep rules and piles readable. |
| Sync Door screen art | 320x180 or UI pieces | `assets/art/minigames/sync_door/` | Placeholder | Switch states must remain obvious. |
| Future Broken High Score screen art | 320x180 or UI pieces | `assets/art/minigames/broken_high_score/` | Planned | Do not integrate until optional feature gate passes. |

## Dialogue Portrait Checklist
| Portrait | Status | Notes |
|---|---|---|
| Player | Planned | Neutral/confused/restored variants later. |
| Mira | Planned | Human, warm, worried. |
| Gus | Planned | Human, dry/practical. |
| Vendo | Planned | Machine face/display, word-by-word dialogue tone. |
| Mr. Byte | Planned | Kiosk/helper display. |
| Cabinet 07 | Planned | Could be screen portrait or cabinet close-up. |
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
