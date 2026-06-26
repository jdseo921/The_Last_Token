# ART_STYLE.md

## Purpose
This document defines the future visual direction for The Last Token. The current playable MVP uses simple shapes and text labels; those placeholders should remain safe until the full gameplay route is stable. Future art should upgrade atmosphere and readability without changing story progression or required mechanics.

## Visual Direction
- 2D pixel-art retro arcade mystery.
- All generated sprites, portraits, props, backgrounds, UI art, overlays, and minigame assets for this project should be retro-style pixel art unless a future task explicitly says otherwise.
- Dark arcade hub with neon accents, screen glow, worn carpet, old plastic, and dusty machines.
- Nostalgic but unsettling: familiar arcade warmth with corrupted records, blank identity, and memory-loss unease.
- Readable silhouettes matter more than dense detail.
- Maps should stay small and atmospheric, with each interactable readable at a glance.
- Visual inspiration may come from haunted retro educational/minigame horror moods, but do not copy any specific copyrighted game assets, characters, layouts, logos, or UI.

## Tile And Asset Size Recommendations
- Tiles: `16x16`.
- Arcade-adventure tiles: `16x16` or `24x24`; keep walls, floors, hazards, collectibles, and goals readable in a small grid.
- Arcade-adventure player: `16x16`; strong silhouette, one-frame placeholder-safe.
- Arcade-adventure collectibles and hazards: `16x16`; use clear shape language before detail.
- Character sprites: `32x32`.
- Dialogue portraits: `64x64` for MVP-friendly portraits, `96x96` for final expressive portraits.
- Memory recall panels: `320x180` for low-res authored panels, `640x360` for higher-detail panels that still preserve a 16:9 composition.
- Arcade cabinet/object sprites: use dimensions that fit the hub grid, usually `32x32`, `32x48`, `48x48`, or `64x64`.
- UI icons and cursor-like markers: `16x16` or `32x32`.
- Minigame UI panels and overlays: `640x440` full-screen assets or scalable panel textures.

## Expanded Required Route Minigame Art
- Static Service Run should use a utility/service palette: dark maintenance floor, readable wall blocks, yellow Signal Fuses, blue-white static leaks, and a green or amber breaker panel.
- Final Night Walk should feel like a memory route, not the same service area: cooler purples/blues, brighter Memory Frames, rewind static that reads differently from service static, and a Staff Door marker that does not reveal Staff Room details.
- Security Tape Assembly should stay UI-first. Background and static overlays must be subtle enough that fragment text and restored order text remain readable.
- Missing minigame art must never block play. Placeholder colored tiles, text labels, and buttons remain the fallback.

## Color Palette Rules
- Use dark base colors for floors, walls, counters, cabinet shells, and background space.
- Use neon highlights for screens, signs, interactable cues, memory effects, and important status changes.
- Limit each area to a focused palette: one dark base family, one secondary material family, and two or three highlight colors.
- Preserve strong outlines and contrast around characters, props, and interactable silhouettes.
- Avoid noisy gradients and over-rendered details that blur at game scale.
- Reserve intense colors for readable signals: active machines, memories, warnings, successful restores, or corruption.

## Perspective Rules
- ArcadeHub uses top-down or slight 3/4 RPG perspective.
- Characters should be readable from above, with simple head/body silhouettes and clear facing direction if walk frames are added.
- Props and cabinets can lean slightly 3/4, but should share one consistent camera angle.
- Minigames may use screen-space UI or a custom screen view if it better communicates the game.
- Memory recall panels are cinematic illustrations and may use their own framing, but should still feel pixel-art consistent.

## Animation Rules
- MVP animation: 2-frame idle loops for important NPCs, cabinet screen blink loops, or simple flicker effects.
- Later animation: 4-frame idle loops and 2-frame walk loops.
- Keep animation subtle. The game should feel haunted and alive, not busy.
- Cabinet animations should be readable as screen flicker, scanline pulse, small light blinking, or corrupted score movement.
- Dialogue portraits can use small expression swaps before full animation is considered.
- Conscience Encounter visuals should feel like a corrupted player reflection: silhouette-first, cyan/purple glitch accents, short flickers, and no readable face before the `"Player"` name reveal.

## Naming Conventions
Use lowercase snake_case paths and filenames.

Examples:
- `assets/art/characters/player/player_idle_down.png`
- `assets/art/characters/mira/mira_idle.png`
- `assets/art/hub/cabinets/cabinet_07.png`
- `assets/art/hub/props/memory_terminal.png`
- `assets/art/portraits/mira/mira_neutral_96.png`
- `assets/art/cutscenes/memory_reveal/panel_01_memory_restore_640x360.png`
- `assets/art/cutscenes/conscience/conscience_overlay.png`
- `assets/art/cutscenes/conscience/glitch_bars.png`
- `assets/art/ui/dialogue/dialogue_frame.png`
- `assets/art/ui/crt/crt_overlay_640x440.png`

Suggested suffixes:
- `_idle`, `_walk`, `_blink`, `_screen`, `_portrait`, `_panel`.
- Direction suffixes if needed: `_down`, `_up`, `_left`, `_right`.
- Size suffix for large UI/panel files: `_64`, `_96`, `_320x180`, `_640x360`.

## File Size And Dimension Conventions
- Keep source art dimensions exact and intentional; avoid odd dimensions unless the scene requires them.
- Character sheets should use consistent frame sizes, preferably one row per animation.
- If using single-frame placeholders, keep them at final intended dimensions to make replacement safe.
- Transparent PNG is preferred for sprites, portraits, props, and UI overlays.
- Opaque PNG is fine for memory panels and full-screen backgrounds.
- Avoid committing generated source files or layered editor files unless they are small and useful. Exported PNGs are the runtime priority.
- Large files should be added only when they are actually used by scenes or documented in `ASSET_MANIFEST.md`.

## UI Style
- Menus and dialogue boxes should remain readable before they become decorative.
- Retro UI should use strong panel contrast, simple frames, minimal ornament, and consistent spacing.
- Dialogue portraits should never crowd the text area.
- Instructions and minigame rules should stay plain and legible.
- CRT/glitch effects should support atmosphere without hiding required information.

## Replacement Rule
Do not block MVP playability while replacing art. Every upgraded sprite, portrait, panel, or overlay should be introduced in a way that keeps the existing placeholder scene functional if the asset is missing or temporarily removed.
