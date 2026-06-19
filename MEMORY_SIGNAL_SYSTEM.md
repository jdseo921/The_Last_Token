# Memory Signal System

## Purpose
Memory Signal is an in-world story state that communicates how stable the player's restored memory feels.

It is not a health meter, sanity meter, punishment system, or mental illness mechanic. It should never shame the player or reduce player ability.

Memory Signal guides:
- Tone.
- Dialogue.
- Visual pressure.
- UI effects.
- Puzzle complexity.
- Machine recognition behavior.

## Design Rules
- Keep it readable.
- Do not obscure gameplay.
- Do not punish players for the state.
- Do not use it as a fail condition.
- Do not frame it as mental illness.
- Treat it as a corrupted-memory signal inside Pixel Haven.
- Escalate atmosphere, not frustration.

## States

### Grounded
Timing:
- Before the first quest starts.

Meaning:
- The arcade is strange but readable.
- The player is confused, but the world still behaves like a place.

Dialogue:
- Player asks basic questions.
- Mira is gentle and careful.
- Side NPCs are casual or lightly strange.
- Machines speak in simple diagnostic terms.

Visual/UI:
- Minimal glitch effects.
- Clear objective guidance.
- Stable hub lighting.

Difficulty:
- First interactions should be easy to understand.
- Rockbyte Duel can be strange, but rules must be clear.

### Uneasy
Timing:
- After the Lost Token is returned to Mira.

Meaning:
- The arcade begins reacting personally to the player.
- Machines treat the player less like a visitor.

Dialogue:
- NPCs mention old routines, missing staff, or things the player should remember.
- Player confusion becomes more specific.
- Machines mention partial profiles, records, or employee signals.

Visual/UI:
- Slightly stronger cabinet flicker.
- Subtle quest notification effects.
- Occasional mild screen pulse or scanline emphasis.

Difficulty:
- Puzzles can require observation across dialogue and environment.
- Instructions must still be direct.

### Fractured
Timing:
- After the second major puzzle/minigame.

Meaning:
- Contradictions become obvious.
- The player learns that records and memories do not fully agree.

Dialogue:
- NPCs disagree gently or accidentally.
- Machines provide technically precise but incomplete statements.
- Player begins noticing contradictions aloud.

Visual/UI:
- More noticeable but brief glitch accents.
- Hub props may show alternate states or flickers.
- Objective text remains stable and readable.

Difficulty:
- Puzzles can ask the player to compare statements.
- Difficulty may increase through reasoning, not speed or punishment.

### Overloaded
Timing:
- Before the Staff Room reveal.

Meaning:
- The arcade is pressing toward the truth.
- Machines and UI react strongly to the player's presence.

Dialogue:
- Machines become more direct.
- NPCs are less able to avoid the truth.
- Player recognizes pieces but not the whole picture.

Visual/UI:
- Stronger glitch pressure.
- Heavier cabinet flicker.
- More urgent quest notification style.
- Never cover interact prompts, dialogue text, or puzzle controls.

Difficulty:
- Final pre-reveal puzzle can be the most complex required puzzle.
- It should test what the player has learned, not introduce a sudden new system.

### Restored
Timing:
- Post-reveal roam.

Meaning:
- The player understands Employee 04.
- The arcade can speak more openly.

Dialogue:
- NPCs can discuss Employee 04 directly.
- Machines can acknowledge restored identity.
- Player can sound steadier, though not necessarily happy.

Visual/UI:
- Effects can stabilize or become intentional.
- Glitches should feel resolved rather than chaotic.

Difficulty:
- Post-reveal interactions should be reflective.
- Required gameplay should not spike after the reveal.

## Implementation Notes For Later
When implemented, Memory Signal can be derived from story flags instead of saved as a separate independent meter.

Possible mapping:
- `Grounded`: `not lost_token_quest_completed`
- `Uneasy`: `lost_token_quest_completed and not second_required_game_completed`
- `Fractured`: `second_required_game_completed and not story_puzzle_completed`
- `Overloaded`: `story_puzzle_completed and not twist_reveal_seen`
- `Restored`: `post_reveal_roam_unlocked`

Current implementation uses:
- `Grounded`: before Lost Token quest completion.
- `Uneasy`: `lost_token_quest_completed` and Truth Filter not completed.
- `Fractured`: `lying_cabinets_completed` or `second_memory_fragment_collected`.
- `Overloaded`: `story_puzzle_completed` or `staff_room_unlocked`.
- `Restored`: `post_reveal_roam_unlocked`.

Use helper methods for labels and visual intensity rather than scattering conditionals across scenes.

## QA Checklist
- Memory Signal changes only at major story beats.
- The player is never penalized mechanically.
- Dialogue, visuals, and puzzle complexity all match the current state.
- Effects stay readable at every supported resolution.
- Save/load restores the correct apparent state through existing story flags.
