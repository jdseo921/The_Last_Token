# VISUAL_UPGRADE_PLAN.md

## Purpose
This plan breaks the future visual pass into safe phases. The current MVP should remain playable throughout the process. Do not add gameplay, NPCs, minigames, or endings as part of visual upgrade work unless a separate approved gameplay task says to do so.

## Current Gate: First Quest Vertical Slice
Before starting additional visual expansion, the project should pass `FIRST_QUEST_VERTICAL_SLICE.md`.

The active visual priority is only this loop:

1. Title Menu
2. New Memory
3. Opening intro
4. Mira starts the Lost Token quest
5. Cabinet 07 launches Rockbyte Duel
6. Rockbyte Duel plays clearly with staged actor and rock visuals
7. Lost Token is recovered
8. Returning to Mira completes the quest
9. Save/load confirms the state

Visual work should support this gate before adding new NPCs, new minigames, new endings, additional story branches, combat, inventory, or extra cabinet games.

## Phase 1: Asset Pipeline And Placeholder Replacement Support
Goal: make art replacement safe before making lots of art.

Tasks:
- Finalize `ART_STYLE.md`, `ASSET_PIPELINE.md`, and `ASSET_MANIFEST.md`.
- Create the recommended `assets/` subfolders as art becomes available.
- Confirm Godot import settings preserve pixel art.
- Add fallback checks for any optional texture loading.
- Keep placeholder shapes visible until replacements are verified.
- Document scene node names that should remain stable.

Exit criteria:
- New art can be imported without breaking a scene.
- Missing art still fails softly.
- Placeholder MVP remains playable.
- First quest visual requirements remain readable and testable.

## Phase 2: Dialogue Portraits
Goal: improve character presence without changing dialogue content.

Tasks:
- Add portrait layout support to the dialogue box.
- Create portraits for Player, Mira, Gus, Vendo, Mr. Byte, Cabinet 07, and key machine/object speakers.
- Keep player dialogue instant, machine dialogue word-by-word, and natural dialogue letter-by-letter.
- Ensure portraits never crowd text or prompts.

Exit criteria:
- Dialogue remains readable at all supported window sizes.
- Missing portraits fall back to no portrait or a simple placeholder.

## Phase 3: Hub Sprite/Tileset Pass
Goal: replace the expanded placeholder ArcadeHub with atmospheric pixel art.

Tasks:
- Create floor and wall tiles.
- Replace ticket counter, Memory Terminal, Cabinet 07, Broken Cabinet, Staff Door, Owner Portrait, Vendo, and Mr. Byte visuals.
- Add player and NPC sprites.
- Preserve existing interactable positions and collision unless a manual test proves a change is needed.
- Keep labels or prompts until sprites are readable enough without them.

Exit criteria:
- ArcadeHub reads clearly without feeling crowded.
- All required interactables remain reachable.
- Objective hint, post-reveal hint, and interaction prompt remain readable.
- Mira, Cabinet 07, and the first quest route remain visually obvious.

## Phase 4: Minigame Screen Templates
Goal: make minigames feel like haunted arcade screens while keeping rules clear.

Tasks:
- Create a shared retro screen style for minigames.
- Use `MINIGAME_PRESENTATION_ARCHITECTURE.md` to keep game rules separate from staged presentation.
- Use `MINIGAME_ANIMATION_GUIDE.md` for reusable idle/action/result animation patterns.
- Upgrade Rockbyte Duel screen art and pile presentation.
- Upgrade Sync Door screen art and switch feedback.
- Keep instructions readable and puzzle difficulty unchanged.
- Do not add optional Broken High Score here unless its separate feature gate has passed.

Exit criteria:
- Minigames are visually stronger but mechanically unchanged.
- Minigame rule scripts still own rules and `GameState` changes.
- Presentation scripts/components own actors, props, effects, and animation loops.
- Win/loss/success feedback remains clear without audio.
- Rockbyte Duel meets the first quest gate before any later minigame receives polish.

## Phase 5: Memory Recall Panel Art
Goal: replace slideshow placeholders with pixel-art memory panels.

Tasks:
- Create eight memory recall panels at `320x180` or `640x360`.
- Preserve captions and slide order.
- Keep missing panel fallback intact.
- Review panels for readability and unwanted artifacts.
- Use CRT/glitch effects sparingly so captions stay readable.

Exit criteria:
- Full reveal slideshow plays with all panels.
- Missing or disabled panel still shows the intentional placeholder fallback.

## Phase 6: Animation Polish
Goal: add life without increasing scope.

Tasks:
- Add 2-frame idle loops for important NPCs and machines.
- Add cabinet screen flicker or blink loops.
- Add 2-frame player walk loops if movement still reads too static.
- Add staged minigame actor/prop animation only through reusable presentation components.
- Keep placeholder bob, blink, flicker, and small tween animations available when final sprite sheets are missing.
- Later, upgrade key idles to 4-frame loops if the MVP remains stable.

Exit criteria:
- Animations do not distract from interaction prompts or dialogue.
- No animation is required for progression.
- Minigames remain playable with no final art assets.

## Phase 7: Optional Extra Minigame Content
Goal: support optional content after the core route is live-accepted.

Tasks:
- Only after full live acceptance, consider optional features like Broken High Score.
- Add art for optional minigames only after the gameplay feature exists and is approved.
- Keep optional content out of required story progression.
- Update `ASSET_MANIFEST.md` and `TEST_PLAN.md` when optional content is added.

Exit criteria:
- Optional content can be skipped.
- Save/load and completion counters remain accurate.
- Main story progression remains unaffected.

## Review Rule
Every phase needs a short manual Godot check before moving on. Visual polish should make the MVP clearer, not harder to test.
