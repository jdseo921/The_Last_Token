# The Last Token — Design Docs (Canonical)

The current story source of truth is **[STORY_CANON.md](STORY_CANON.md)** plus the shipped content in `data/dialogue/*.json`, `data/quests.json`, and `scripts/GameState.gd`.

`DESIGN_BIBLE.md`, `STAGE_DESIGN.md`, `DIALOGUE_SWEEP.md`, and `STORY_FINALIZATION.md` are historical planning records. They contain retired scene names and superseded story proposals; do not use them as current implementation specifications.

## Read these

1. **[STORY_CANON.md](STORY_CANON.md)** — current protagonist/`???` truth, themes, reveal pacing, and dialogue guardrails.
2. **[MINIGAME_UI.md](MINIGAME_UI.md)** — current UI and layout contract.
3. **[BUILD.md](BUILD.md)** and **[DEBUGGING.md](../DEBUGGING.md)** — current validation, diagnostics, and export workflow.

## Canon rule

Where historical planning and shipped behavior disagree, `STORY_CANON.md` and shipped behavior win.

## Status

- **Story & gameplay direction:** implemented in the shipped data.
- **Protagonist reveal:** distributed through the required route, with the Player carrying the dream and `???` carrying its material cost until integration.
- **UI:** minigames and adventure stages use the shared fitting/layout guard described in `MINIGAME_UI.md`.
- **Build:** a verified Windows export exists; see **[BUILD.md](BUILD.md)**.
- **Validation:** `tools/RunRegressionSuite.ps1` is the maintained entry point.
