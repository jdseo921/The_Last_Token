# ASSET_PIPELINE.md

## Purpose
This pipeline prepares The Last Token for a later high-quality retro visual pass without changing gameplay now. The current placeholder scenes must remain playable while art is generated, reviewed, imported, and swapped in.

## Asset Folders
Generated and final art should live under `res://assets/art/`.

Recommended structure:
- `res://assets/art/ui/title/`
- `res://assets/art/ui/menus/`
- `res://assets/art/ui/dialogue/`
- `res://assets/art/ui/crt/`
- `res://assets/art/hub/backgrounds/`
- `res://assets/art/hub/tiles/`
- `res://assets/art/hub/props/`
- `res://assets/art/hub/cabinets/`
- `res://assets/art/hub/effects/`
- `res://assets/art/characters/player/`
- `res://assets/art/characters/mira/`
- `res://assets/art/characters/gus/`
- `res://assets/art/characters/vendo/`
- `res://assets/art/characters/mr_byte/`
- `res://assets/art/portraits/player/`
- `res://assets/art/portraits/mira/`
- `res://assets/art/portraits/gus/`
- `res://assets/art/portraits/vendo/`
- `res://assets/art/portraits/mr_byte/`
- `res://assets/art/cutscenes/memory_reveal/`
- `res://assets/art/minigames/rockbyte_duel/`
- `res://assets/art/minigames/sync_door/`
- `res://assets/art/minigames/broken_high_score/`

Keep temporary references, rejected AI outputs, and prompt experiments outside the repo unless they are intentionally curated.

## Naming Assets
Use lowercase snake_case. Include object name, purpose, and size when helpful.

All generated visual assets for The Last Token should default to retro-style pixel art: dark arcade mood, clean silhouettes, limited neon cyan/magenta/green highlights, and no copyrighted characters, logos, cabinet art, or recognizable real game references.

Examples:
- `player_idle_down.png`
- `mira_idle_32.png`
- `cabinet_07_screen_blink.png`
- `dialogue_portrait_mr_byte_96.png`
- `memory_panel_03_shutdown_640x360.png`
- `crt_overlay_640x440.png`

Avoid names like:
- `final_final.png`
- `image123.png`
- `cool_arcade_asset.png`
- names copied from unrelated copyrighted works.

## Importing Into Godot
1. Place PNG assets in the correct `res://assets/art/` subfolder.
2. Open Godot and let it import the files.
3. For pixel art, use nearest-neighbor filtering or project/import settings that preserve crisp pixels.
4. Verify transparency in the editor preview.
5. Reference assets from scenes with `res://assets/art/...` paths.
6. Keep placeholder nodes or fallback labels until the replacement is confirmed in a live scene.

## Safe Placeholder Replacement
- Replace one category at a time: player, NPCs, cabinets, tiles, portraits, panels, UI.
- Keep node names stable when possible so scripts do not break.
- Prefer swapping a visual child node or texture resource over restructuring gameplay nodes.
- Do not remove CollisionShape2D, Area2D, signal wiring, or script references during art replacement.
- If an asset is optional, scripts should either check `ResourceLoader.exists()` or keep a visible placeholder.
- Missing art must not crash the game.

## Optional Dialogue Portraits
Dialogue lines can optionally include a portrait path:

```gdscript
{"speaker": "Mira", "text": "Welcome back.", "portrait": "res://assets/art/portraits/mira/mira_neutral.png"}
```

Portrait paths are optional. If the key is missing, empty, invalid, or points to a non-texture resource, the dialogue box hides the portrait and keeps the normal text layout. Do not update every dialogue line until portrait assets are reviewed and imported.

## AI Art Review Before Commit
AI-generated art must be reviewed by a person before it becomes project art.

Reject or revise assets with:
- unreadable silhouettes at game scale
- inconsistent perspective
- unwanted text artifacts or fake lettering
- distorted hands/faces if portraits are used
- excessive detail that becomes noise
- copyrighted characters, logos, cabinet art, mascots, or UI copied from existing games
- mismatched palette or lighting

Recommended review flow:
1. Check the asset at native size.
2. Check it scaled in Godot at the intended window size.
3. Compare it against `ART_STYLE.md`.
4. Verify it fits the object role in `ASSET_MANIFEST.md`.
5. Only then wire it into a scene.

## Required Manual Checks
Before committing imported art, confirm:
- correct dimensions
- transparent background where expected
- pixel-grid consistency
- no unwanted text artifacts
- no unreadable tiny details
- no inconsistent perspective
- no copyrighted logos or recognizable protected characters
- visible at `640x440`, `960x660`, and `1280x880`
- does not obscure dialogue, prompts, objectives, or minigame instructions

## Runtime Safety Rules
- Missing art should show a placeholder shape, label, or intentional fallback panel.
- Cutscene panels may use the existing `MEMORY PANEL / Placeholder image pending` fallback until final panels exist.
- Audio and visual effects should fail softly.
- Art replacement should not change story flags, save data, scene transitions, or input mappings.

## Commit Guidance
- Commit art in small groups by feature or area.
- Mention scene files updated alongside assets.
- Do not commit large rejected batches.
- Do not commit generated builds, `.exe`, `.pck`, editor logs, or unrelated cache files.
