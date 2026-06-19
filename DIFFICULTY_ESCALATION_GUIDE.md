# Difficulty Escalation Guide

## Purpose
Difficulty in The Last Token should rise because the mystery asks for more careful observation, not because controls become harder or information becomes hidden.

This guide keeps future puzzles and minigames readable while Act 2 and later phases become more complex.

## Core Rules
- New puzzle complexity must be tied to story meaning.
- Required puzzles should teach one main idea at a time.
- Failure should give better guidance, not punishment.
- Visual effects should not hide puzzle state.
- Timers should be avoided unless the puzzle is designed around calm retry loops.
- Save/load must never trap the player inside an unclear or failed state.

## First Quest Benchmark
Rockbyte Duel is the baseline:
- Rules are visible immediately.
- The player has three simple actions.
- Loss is recoverable.
- Retry is clear.
- Win has a story payoff.

Future required puzzles should be more complex than Rockbyte Duel only after they clearly teach their new concept.

## Act 2 Difficulty Direction
Recommended second required game: `TRUTH FILTER` / `Lying Cabinets`.

Difficulty should increase through:
- Comparing short statements.
- Remembering what NPCs said.
- Observing which machines react personally.
- Noticing contradictions.

Avoid:
- Long text walls.
- Hidden pixel hunts.
- Fast reflex checks.
- Randomized solutions for required progression.
- Punishing wrong guesses with lost progress.

## Memory Signal And Difficulty

Grounded:
- Simple objectives.
- Direct instructions.
- Low consequence failure.

Uneasy:
- Slightly more interpretive objectives.
- NPCs and machines begin giving different kinds of information.
- Puzzle asks the player to notice one contradiction.

Fractured:
- Multiple statements may be incomplete or contradictory.
- Player must compare two or three sources.
- UI should help track the current puzzle state clearly.

Overloaded:
- Strongest required puzzle pressure.
- Use accumulated knowledge from prior puzzles.
- Keep controls simple and feedback immediate.

Restored:
- Difficulty should relax or become reflective.
- Post-reveal content should focus on emotional payoff and optional discovery.

## Failure And Hint Policy
For required puzzles:
- First failure: explain what changed.
- Second failure: give a stronger hint.
- Third failure onward: provide a direct nudge or simplify the pattern.

Example:
- `The cabinet accepts true records only.`
- `One statement conflicts with what Mira said.`
- `Check the line about the missing staff member.`

Failure should not:
- Remove story progress.
- Increase hostile effects to unreadable levels.
- Force long replay sequences.
- Mock the player harshly.

## AI / Opponent Behavior
If a minigame has an opponent:
- Early attempts can be slightly challenging.
- After repeated losses, increase leeway.
- Make the change feel like the machine is exposing a pattern, not secretly cheating.
- Persist loss count only if it improves guidance.

Rockbyte Duel currently follows this model by becoming more forgiving after repeated losses.

## Required Puzzle Readability Checklist
Every required minigame or puzzle should have:
- A visible title.
- Clear instructions.
- A clear current state.
- Immediate feedback after input.
- A retry or exit path.
- A story payoff on completion.
- Save/load behavior that cannot mark unfinished attempts as completed.

## Act 2 Quality Gate
Before Act 2 difficulty is accepted:
- Player understands why the second puzzle is harder than Rockbyte Duel.
- Wrong answers produce useful hints.
- The solution is based on observed story information.
- Memory Signal escalation is visible but not distracting.
- The next objective toward Staff Door / Sync Door is clear.

## Truth Filter Scaffold
The current Act 2 scaffold uses four fixed rounds:
- One-truth rule.
- One-lie rule.
- Reversed-meaning rule.
- Hidden-statement rule.

Wrong answers do not hard-fail. They show a wobble message and allow retry.
