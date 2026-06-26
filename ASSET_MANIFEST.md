# ASSET_MANIFEST.md

## Purpose
This manifest tracks planned visual and audio assets for The Last Token. It is a production checklist, not a requirement to add all assets before MVP testing.

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
assets/art/effects/
assets/art/effects/ambient/
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
assets/art/cutscenes/conscience/
assets/art/cutscenes/memory_reveal/
assets/art/ui/
assets/art/ui/dialogue/
assets/art/ui/title/
assets/art/ui/menus/
assets/art/ui/crt/
assets/audio/
assets/audio/music/
assets/audio/sfx/
```

The lightweight path helper is `scripts/AssetPaths.gd`. It is not autoloaded; use it only when a future visual replacement needs safe optional asset loading.

The JSON lookup draft is `data/asset_manifest.json`. It maps stable asset keys to planned or integrated paths. Deterministic 8-bit polish assets can be regenerated with `tools/generate_visual_polish_assets.gd`.

| Asset | Recommended Size | Folder | Status | Notes |
|---|---:|---|---|---|
| Player sprite | 32x32 | `assets/art/characters/player/player_gameplay.png` | Integrated | Regular gameplay sprite; face obscured for story reasons. |
| Player post-game sprite | 32x32 | `assets/art/characters/player/player_gameplay_glitch.png` | Integrated | Glitchier post-game variant; same obscured-face silhouette. |
| Player 8-direction walk sheet | 16 frames, 32x32 each | `assets/art/characters/player/player_walk_8dir_sheet.png` | Integrated | Regular movement sheet; 2 frames per direction. |
| Player post-game 8-direction walk sheet | 16 frames, 32x32 each | `assets/art/characters/player/player_walk_8dir_glitch_sheet.png` | Integrated | Glitch movement sheet; 2 frames per direction. |
| Player obscured dialogue portrait | 96x96 | `assets/art/portraits/player/player_obscured.png` | Integrated | Default protagonist dialogue portrait before the final Staff Room reveal; face and clothes are blacked out so no expression is readable. |
| Player revealed dialogue portrait | 96x96 | `assets/art/portraits/player/player_neutral.png` | Integrated | Preserved normal protagonist portrait; used only once `twist_reveal_seen` is true, starting with the final Staff Room self-conflict and post-reveal dialogue. |
| Player final conscience portrait | 96x96 | `assets/art/portraits/player/player_conscience_revealed.png` | Integrated | Used only when the antagonist is revealed as `"Player"` in the final Staff Room conversation; earlier `???` encounters intentionally have no sprite or portrait window. |
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
| Staff door open art | 64x96 | `assets/art/hub/props/staff_door_open.png` | Integrated | Generated open/unlocked staff door state; `ArcadeHub` swaps to it when `staff_room_unlocked` is true. |
| Owner portrait blank art | 48x48 | `assets/art/hub/props/owner_portrait_blank.png` | Integrated | Pre-reveal portrait state. |
| Owner portrait Employee 04 art | 48x48 | `assets/art/hub/props/owner_portrait_employee04.png` | Integrated | Generated post-reveal portrait state; `ArcadeHub` swaps to it once the player is post-reveal. |
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
| Retro UI theme frame/text language | Theme resource | `themes/retro_mechanical_theme.tres` | Integrated | Shared square-corner cyan panel/button frames plus readable retro monospace font stack, outline, and shadow treatment. |
| Route cue UI | Scripted UI | `scripts/RouteCue.gd` | Integrated | One-line `LOCAL` / `ROUTE` map guidance for hallways and side rooms. |
| Antagonist dialogue text animation | Scripted UI | `scripts/DialogueBox.gd`, `scripts/ConscienceEncounter.gd` | Integrated | Uses the same font as protagonist dialogue, with scan-jitter/flicker/reveal animation for `???` and final `"Player"` lines. |
| Ambient sprite effect helper | Scripted sprite effects | `scripts/AmbientSpriteEffects.gd` + `assets/art/effects/ambient/` | Integrated | Applies 4-frame transparent pixel sheets to hub, side rooms, Staff Corridor, and all hallway routes. |
| Dialogue portraits | 64x64 or 96x96 | `assets/art/portraits/` | In Progress | First 96x96 portrait batch generated and wired through DialogueBox; keep pending until live Godot dialogue review passes. |
| Memory recall panels | 320x180 | `assets/art/cutscenes/memory_reveal/` | Integrated | Eight mono-color 8-bit reveal panels are wired into the Staff Room slideshow; fallback remains if a file is removed. |
| Conscience overlay | 640x440 transparent overlay | `assets/art/cutscenes/conscience/conscience_overlay.png` | Planned | Optional dark/glitch overlay for `ConscienceEncounter`; current ColorRect fallback remains. |
| Conscience glitch bars | 640x440 transparent overlay or bar strip | `assets/art/cutscenes/conscience/glitch_bars.png` | Planned | Optional bar art; scripted ColorRect glitch bars remain fallback. |
| Rockbyte Duel background | 640x440 | `assets/art/minigames/rockbyte_duel/backgrounds/rockbyte_background.png` | Integrated | Generated arcade-cabinet backdrop; rules and pile UI remain script-owned for readability. |
| Sync Door screen art | 320x180 or UI pieces | `assets/art/minigames/sync_door/` | Placeholder | Switch states must remain obvious. |
| Truth Filter cabinet states | 4 frames, 64x64 each | `assets/art/minigames/truth_filter/truth_filter_cabinets_sheet.png` | Integrated | Optional state sheet with panel-color fallback. |
| Circuit Soda tile sheet | 6 frames, 32x32 each | `assets/art/minigames/circuit_soda/circuit_soda_tiles_sheet.png` | Integrated | Optional tile icons with text-button fallback. |
| Broken High Score screen art | 640x440 | `assets/art/minigames/broken_high_score/broken_high_score_screen.png` | Integrated | Optional screen background with flat-color fallback; feature remains non-blocking. |
| Adventure player 8-bit sprite | 16x16 | `assets/art/minigames/adventure/player_8bit.png` | Integrated | Shared optional player sprite for Static Service Run and Final Night Walk; colored square fallback remains. |
| Static Service maintenance tiles | 16x16 or 24x24 tiles | `assets/art/minigames/adventure/maintenance_tiles.png` | Planned | Future tile sheet for service floor/walls; current colored placeholder grid remains readable if missing. |
| Static Service static leak | 16x16 | `assets/art/minigames/adventure/static_leak.png` | Integrated | Hazard art; reads as electrical/static leak at tile scale, with text marker fallback. |
| Static Service signal fuse | 16x16 | `assets/art/minigames/adventure/signal_fuse.png` | Integrated | Collectible art for Signal Fuses; current `F` marker remains if missing. |
| Static Service breaker panel | 16x16 | `assets/art/minigames/adventure/breaker_panel.png` | Integrated | Goal tile art; visually distinct from fuses and hazards. |
| Security Tape background | 640x440 | `assets/art/minigames/security_tape/security_tape_background.png` | Integrated | Full-screen tape backdrop behind the existing panel; text contrast remains panel-owned. |
| Security Tape fragment panel | Scalable UI panel or 96x32 per button | `assets/art/minigames/security_tape/tape_fragment_panel.png` | Planned | Optional button/panel texture for tape fragments; text labels must remain legible. |
| Security Tape static overlay | 640x440 transparent overlay | `assets/art/minigames/security_tape/tape_static_overlay.png` | Integrated | Subtle generated static layer; ignores input and stays low-opacity. |
| Final Night tiles | 16x16 or 24x24 tiles | `assets/art/minigames/adventure/final_night_tiles.png` | Planned | Future tile sheet for the memory route; current purple/blue placeholder grid remains. |
| Final Night memory frame | 16x16 | `assets/art/minigames/adventure/memory_frame.png` | Integrated | Ordered collectible art; frame number/text feedback remains readable. |
| Final Night rewind static | 16x16 | `assets/art/minigames/adventure/rewind_static.png` | Integrated | Hazard art; distinct from Static Service's static leak. |
| Final Night staff door marker | 16x16 | `assets/art/minigames/adventure/staff_door_marker.png` | Integrated | Goal/exit marker art; suggests the Staff Door without revealing Staff Room content. |

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
| Player obscured | Integrated | `player_obscured.png`; default protagonist portrait before the Staff Room reveal, with face/clothes blacked out and no visible expression. |
| Player revealed | In Progress | `player_neutral.png`; preserved normal portrait, switched in only after `twist_reveal_seen` during the final Staff Room event sequence and post-reveal dialogue. |
| Player final conscience | Integrated | `player_conscience_revealed.png`; glitched shaded protagonist portrait used only by the final Staff Room `"Player"` speaker. |
| Mira | In Progress | `mira_neutral.png`, `mira_worried.png`; default portrait wired, worried variant used on emotional lines. |
| Gus | In Progress | `gus_neutral.png`, `gus_annoyed.png`; default portrait wired, annoyed variant used on joke/practical lines. |
| Vendo | In Progress | `vendo_neutral.png`; machine face/display, word-by-word dialogue tone. |
| Mr. Byte | In Progress | `mr_byte_neutral.png`; kiosk/helper display. |
| Cabinet 07 | In Progress | `cabinet_07_screen.png`; default portrait wired, explicit recognition lines added. |
| Staff Door | Planned | Optional mechanical portrait or no portrait. |
| Owner Portrait | Planned | Scratched/blank portrait close-up. |
| Employee 04 file | Planned | Corrupted file panel rather than face. |

## Conscience Antagonist Planned Hooks
- `res://assets/art/portraits/player/player_conscience_revealed.png`
- `res://assets/art/cutscenes/conscience/conscience_overlay.png`
- `res://assets/art/cutscenes/conscience/glitch_bars.png`

The final portrait is integrated. Earlier `???` encounters do not show an antagonist sprite, silhouette, or portrait window. `ConscienceEncounter.tscn` keeps only the dark overlay, glitch bars, and dialogue panel until the Staff Room reveal names the antagonist. `Player.gd` uses the normal sprite with glitch modulation if the glitched gameplay art is missing.

## Music Track Checklist
| Track | Path | Status | Notes |
|---|---|---|---|
| Title attract loop | `assets/audio/music/title_attract_loop.mp3` | Integrated | Title Menu. |
| Arcade hub grounded | `assets/audio/music/arcade_hub_grounded.mp3` | Integrated | ArcadeHub while Memory Signal is Grounded. |
| Arcade hub uneasy/fractured | `assets/audio/music/arcade_hub_uneasy_fractured.mp3` | Integrated | ArcadeHub after Memory Signal changes before post-reveal. |
| Cabinet Row records | `assets/audio/music/cabinet_row_records.mp3` | Integrated | Cabinet Row. |
| Snack Alcove Vendo | `assets/audio/music/snack_alcove_vendo.mp3` | Integrated | Snack Alcove. |
| Maintenance Hall static | `assets/audio/music/maintenance_hall_static.mp3` | Integrated | Maintenance Hall. |
| Staff Corridor overloaded | `assets/audio/music/staff_corridor_overloaded.mp3` | Integrated | Staff Corridor. |
| Staff Room reveal bed | `assets/audio/music/staff_room_reveal_bed.mp3` | Integrated | Staff Room and Ending Prompt. |
| Post-reveal roam | `assets/audio/music/post_reveal_roam.mp3` | Integrated | ArcadeHub post-reveal roam. |
| Rockbyte Duel game | `assets/audio/music/rockbyte_duel_game.mp3` | Integrated | Rockbyte Duel. |
| Truth Filter game | `assets/audio/music/truth_filter_game.mp3` | Integrated | Truth Filter. |
| Circuit Soda game | `assets/audio/music/circuit_soda_game.mp3` | Integrated | Circuit Soda. |
| Static Service Run game | `assets/audio/music/static_service_run_game.mp3` | Integrated | Static Service Run. |
| Maintenance Sync game | `assets/audio/music/maintenance_sync_game.mp3` | Integrated | Maintenance Sync. |
| Security Tape / Final Night game | `assets/audio/music/security_tape_final_night_game.mp3` | Integrated | Security Tape Assembly and Final Night Walk. |
| Memory Echo / conscience | `assets/audio/music/memory_echo_conscience.mp3` | Integrated | Memory Echo. |

## Simple SFX Checklist
| SFX | Path | Status | Notes |
|---|---|---|---|
| Memory panel cue | `assets/audio/sfx/memory_panel.wav` | Integrated | Generated short one-shot for Staff Room slideshow panel changes. |
| Memory accept cue | `assets/audio/sfx/memory_accept.wav` | Integrated | Generated short one-shot for accepted Memory Echo answers. |
| Door unlock cue | `assets/audio/sfx/door_unlock.wav` | Integrated | Generated short one-shot for Maintenance Sync opening the Staff Door. |
| Button pulse cue | `assets/audio/sfx/button_pulse.wav` | Integrated | Generated short one-shot for minigame button/switch input. |
| Score blip cue | `assets/audio/sfx/score_blip.wav` | Integrated | Generated short one-shot for correct puzzle beats and collectibles. |
| Error buzz cue | `assets/audio/sfx/error_buzz.wav` | Integrated | Generated short one-shot for arcade-style wrong actions. |
| Success jingle cue | `assets/audio/sfx/success_jingle.wav` | Integrated | Generated short one-shot for completed minigame/puzzle beats. |

## Ambient Map Effect Checklist
| Effect Sheet | Frame Size | Status | Notes |
|---|---:|---|---|
| Static spark | 4 frames, 16x16 each | Integrated | `static_spark_sheet.png`; cabinet flicker, broken screens, service sparks. |
| Blink dot | 4 frames, 16x16 each | Integrated | `blink_dot_sheet.png`; tiny status pips and readiness markers. |
| Scanline bar | 4 frames, 32x8 each | Integrated | `scanline_bar_sheet.png`; machine screens and hallway static stripes. |
| Warning light | 4 frames, 16x16 each | Integrated | `warning_light_sheet.png`; maintenance route warnings. |
| Soda bubble | 4 frames, 16x16 each | Integrated | `soda_bubble_sheet.png`; Vendo, Circuit Soda, and snack-route motion. |
| Prize twinkle | 4 frames, 16x16 each | Integrated | `prize_twinkle_sheet.png`; prize counter and shelf glints. |
| Memory wisp | 4 frames, 24x16 each | Integrated | `memory_wisp_sheet.png`; Truth Filter, Staff Corridor, and memory systems. |
| Neon arrow | 4 frames, 16x16 each | Integrated | `neon_arrow_sheet.png`; route-readable exit arrows in maps and hallways. |
| Ticket glint | 4 frames, 16x16 each | Integrated | `ticket_glint_sheet.png`; ticket/prize glass highlights. |
| Staff lock blink | 4 frames, 16x16 each | Integrated | `staff_lock_blink_sheet.png`; Staff Door and sync-door gate feedback. |

## Memory Recall Panel Checklist
| Panel | Status | Notes |
|---|---|---|
| Panel 01 | Integrated | Mono-color 8-bit Staff Door lock beat. |
| Panel 02 | Integrated | Mono-color 8-bit Staff Room / file context. |
| Panel 03 | Integrated | Mono-color 8-bit shutdown intent. |
| Panel 04 | Integrated | Mono-color 8-bit machine panic. |
| Panel 05 | Integrated | Mono-color 8-bit system-save / token beat. |
| Panel 06 | Integrated | Mono-color 8-bit everyone-remembered beat. |
| Panel 07 | Integrated | Mono-color 8-bit player-forgot beat. |
| Panel 08 | Integrated | Mono-color 8-bit Employee 04 reveal. |

## Integration Notes
- Keep this manifest updated when any asset moves from planned to integrated.
- Do not remove placeholder behavior when integrating an asset.
- New optional content art, including Broken High Score, should remain planned until the gameplay feature itself is approved.
