# Dialogue Expansion Plan

## Purpose
Keep the expanded dialogue useful, readable, and spoiler-safe while preserving the playable MVP route.

This file is the QA record for dialogue pool growth. Add dialogue only when it improves clarity, emotional payoff, or exploration rewards.

## Anti-Bloat Rules
- Quest instructions stay brief, direct, and location-specific.
- Required interactions stay at 10 lines or fewer unless they are the Staff Room reveal or final self-conflict.
- Optional, anecdote, and post-reveal witness dialogue may be longer when it adds payoff.
- Third-and-later repeat talks should include an objective nudge.
- Employee 04 is not named outside the Staff Room before the reveal path reaches that room.
- Post-reveal witness dialogue may acknowledge Employee 04, but should not create a new ending.
- Comedy belongs to Gus, Vendo, Roxy, and Pip, but should not undercut Memory Echo, Final Night Walk, Staff Room reveal, or the final self-conflict.
- Every line remains compatible with `DialogueBox`: `{"speaker": "...", "text": "...", "portrait": "optional path"}`.

## QA Findings - 2026-06-26
- Dialogue JSON shape is compatible with `DialoguePool` and `DialogueBox`.
- Most required instruction sets are 2-6 lines.
- The Staff Room final self-conflict is intentionally long and is the major climax exception.
- Repeated ArcadeHub talk uses phase counters; third-and-later fallback sets redirect toward the active objective.
- Fixed an early-repeat gap by adding objective nudges to later Gus/Vendo pre-quest flavor sets.
- Fixed a required-path bloat issue by tightening Gus's Lost Shift File explanation so the combined Static Service handoff stays at 10 lines.
- Fixed a spoiler-safe fallback in Staff Corridor so missing JSON cannot reveal `04` before Staff Room playback.
- No new quest progression flags were added during this pass.

## Story Relevance Pass - 2026-06-26
- Required minigames still map to the story route: Rockbyte verifies the Lost Token signal, Truth Filter reduces contradictions, Circuit Soda routes the fractured signal, Static Service Run restores door power, Maintenance Sync aligns two Staff Door signals, Security Tape restores sequence order, Final Night Walk stabilizes the route, and Memory Echo prepares the Staff Room reveal.
- Rockbyte was the weakest story bridge, so its success text and Cabinet 07/Mira payoff now clarify that the token returns because the old signal matched, not simply because the player won a small arcade game.
- Security Tape completion now uses a separate Mr. Byte post-completion set instead of reusing pre-completion support lines.
- Final Night Walk terminal restored text now preserves the important route result: one walked in, two signals answered.
- Antagonist/conscience dialogue remains distanced from NPC dialogue through hallway messages and `ConscienceEncounterDirector`; no `???` lines were added to NPC anecdote pools.

## Dialogue QA Checklist
- [x] Mira route: clear Lost Token instruction, emotional anchor maintained, no Employee 04 reveal before Staff Room.
- [x] Gus route: dry practical voice, required handoffs stay concise, objective nudges present on later repeats.
- [x] Vendo route: commercial comedy stays distinct, Circuit Soda instruction remains clear, later early-flavor repeats nudge Mira.
- [x] Mr. Byte route: diagnostic voice intact, Truth Filter and record directions stay direct.
- [x] Cabinet 07 route: short status-heavy sets, Cabinet Row/Staff Door nudges remain clear.
- [x] Roxy optional route: competitive voice, optional status preserved, no required-route dependency.
- [x] Pip optional route: soft/eerie voice, Prize Sort order remains clear, optional status preserved.
- [x] Environmental objects: state-based lines stay short, Staff Room-only reveal text remains gated.
- [x] Post-reveal witness route: core witnesses mark completion; Roxy/Pip are optional unless met.
- [x] Final room self-conflict: climax-only long dialogue, no comedy undercut, `"Player"` antagonist remains distinct.
- [x] Minigame story relevance: every required puzzle has a clear story reason before or after completion, with no new progression flags.

## Manual QA Notes
- During live play, confirm each repeated NPC can be advanced quickly without feeling padded.
- Confirm objective hints and dialogue nudges agree at every story phase.
- Confirm missing portraits fall back safely through `DialoguePortraitRegistry`.
- Confirm missing dialogue JSON falls back to the hardcoded script lines without progression loss.
- Confirm post-reveal witness completion notice appears after the final required witness.
