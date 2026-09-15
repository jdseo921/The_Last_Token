# The Last Token — Documentation Index

Every design, content, QA, and build document lives in this folder. Only `README.md` and `AGENTS.md` remain at the repository root.

Most of these are working records kept from development, not maintained specifications. Where a planning document and shipped behaviour disagree, **shipped behaviour wins**, and [`STORY_CANON.md`](STORY_CANON.md) is the arbiter for story questions.

## Start here

1. [`STORY_CANON.md`](STORY_CANON.md) — the story source of truth: protagonist and `???` truth, themes, reveal pacing, dialogue guardrails. Read with the shipped content in `data/dialogue/*.json`, `data/quests.json`, and `scripts/GameState.gd`.
2. [`MINIGAME_UI.md`](MINIGAME_UI.md) — the current UI and layout contract for every minigame and adventure screen.
3. [`BUILD.md`](BUILD.md) and [`DEBUGGING.md`](DEBUGGING.md) — validation, diagnostics, and the export workflow.
4. [`QA_AUTOMATION.md`](QA_AUTOMATION.md) — what the automated suite does and does not prove.

## Current contracts

| Document | Covers |
| --- | --- |
| [`STORY_CANON.md`](STORY_CANON.md) | Story consistency check for required-route and optional dialogue |
| [`MINIGAME_UI.md`](MINIGAME_UI.md) | Fonts, text roles, padding, font-size floors, and the layout guard |
| [`MINIGAME_ROSTER.md`](MINIGAME_ROSTER.md) | The shipped required route, the 12-milestone counter, optional content, and the playable screen list |
| [`FLAG_REGISTRY.md`](FLAG_REGISTRY.md) | Naming rules for GameState flags |
| [`CONTROLS.md`](CONTROLS.md) | Input bindings, display setting, and debug keys |

## Design and systems

| Document | Covers |
| --- | --- |
| [`DESIGN_BIBLE.md`](DESIGN_BIBLE.md) | Historical planning baseline: themes, pacing, difficulty philosophy |
| [`STAGE_DESIGN.md`](STAGE_DESIGN.md) | Historical per-stage design: verb, entertainment, story connection |
| [`STORY_FINALIZATION.md`](STORY_FINALIZATION.md) | Finalized story and pacing amendments to the Bible |
| [`DIALOGUE_SWEEP.md`](DIALOGUE_SWEEP.md) | Full player-facing dialogue sweep generated from shipped data |
| [`DESIGN_LOCK.md`](DESIGN_LOCK.md) | Locked genre, scope, and premise |
| [`MAP_STRUCTURE.md`](MAP_STRUCTURE.md) | Floor plan: rooms, purposes, and connections |
| [`MEMORY_SIGNAL_SYSTEM.md`](MEMORY_SIGNAL_SYSTEM.md) | The Memory Signal story state and its rules |
| [`MINIGAME_PRESENTATION_ARCHITECTURE.md`](MINIGAME_PRESENTATION_ARCHITECTURE.md) | Keeping minigame rules separate from staged presentation |
| [`MINIGAME_SCREEN_GUIDE.md`](MINIGAME_SCREEN_GUIDE.md) | How a minigame screen should be built |
| [`MINIGAME_ANIMATION_GUIDE.md`](MINIGAME_ANIMATION_GUIDE.md) | Idle, action, and result animation vocabulary |
| [`DIFFICULTY_ESCALATION_GUIDE.md`](DIFFICULTY_ESCALATION_GUIDE.md) | Raising difficulty through observation, not input |
| [`ART_STYLE.md`](ART_STYLE.md) | Intended visual direction |
| [`AUDIO_PLAN.md`](AUDIO_PLAN.md) | Music and SFX integration plan |
| [`NPC_DIALOGUE_GUIDE.md`](NPC_DIALOGUE_GUIDE.md) | Voice and tone per character |

## Content plans

Scope and content proposals written during development. Several describe routes and counts that the shipped game has since changed.

| Document | Covers |
| --- | --- |
| [`NPC_QUEST_OWNERSHIP.md`](NPC_QUEST_OWNERSHIP.md) | Which NPC owns which quest |
| [`STORY_DENSITY_PLAN.md`](STORY_DENSITY_PLAN.md) | Keeping a short run dense without a lore dump |
| [`LORE_QUEST_PLAN.md`](LORE_QUEST_PLAN.md) | Lore-reading quests |
| [`DIALOGUE_EXPANSION_PLAN.md`](DIALOGUE_EXPANSION_PLAN.md) | Dialogue pool growth record |
| [`CONSCIENCE_ANTAGONIST_PLAN.md`](CONSCIENCE_ANTAGONIST_PLAN.md) | The `???` antagonist and its resolution |
| [`EXPANDED_CONTENT_PLAN.md`](EXPANDED_CONTENT_PLAN.md) | Scope control for the expanded route |
| [`MAP_EXPANSION_PLAN.md`](MAP_EXPANSION_PLAN.md) | Adding maps without maze growth |
| [`VISUAL_UPGRADE_PLAN.md`](VISUAL_UPGRADE_PLAN.md) | Phased visual upgrade |
| [`ACT_2_ESCALATION_PLAN.md`](ACT_2_ESCALATION_PLAN.md) | Story phase after the Lost Token quest |
| [`STAGED_MINIGAME_CONVERSION_GUIDE.md`](STAGED_MINIGAME_CONVERSION_GUIDE.md) | Converting a minigame to a staged actor scene |
| [`BUILD_ORDER.md`](BUILD_ORDER.md) | Original implementation order |
| [`FIRST_QUEST_VERTICAL_SLICE.md`](FIRST_QUEST_VERTICAL_SLICE.md) | The first-quest quality gate |

## QA and acceptance

| Document | Covers |
| --- | --- |
| [`QA_AUTOMATION.md`](QA_AUTOMATION.md) | Headless automation boundary, smoke commands, route helpers |
| [`TEST_PLAN.md`](TEST_PLAN.md) | Manual playthrough test plan |
| [`DEBUGGING.md`](DEBUGGING.md) | Runtime trace, F8/F9 overlays, event categories, regression suite |
| [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) | Current open work, known risks, and what has since been resolved |
| [`ACT_2_ACCEPTANCE.md`](ACT_2_ACCEPTANCE.md) | Act 2 acceptance checklist — superseded status record |
| [`EXPANDED_REQUIRED_ROUTE_ACCEPTANCE.md`](EXPANDED_REQUIRED_ROUTE_ACCEPTANCE.md) | Expanded route acceptance checklist — superseded status record, gates the pre-12-milestone route |
| [`ADVENTURE_STAGE_ACCEPTANCE.md`](ADVENTURE_STAGE_ACCEPTANCE.md) | Adventure stage acceptance against the shared controller |

## Build and assets

| Document | Covers |
| --- | --- |
| [`BUILD.md`](BUILD.md) | Export preset, templates, release build, validation entry point |
| [`BUILD_NOTES.md`](BUILD_NOTES.md) | Engine target and local build notes |
| [`ASSET_PIPELINE.md`](ASSET_PIPELINE.md) | How generated and final art enters the project |
| [`ASSET_MANIFEST.md`](ASSET_MANIFEST.md) | Planned visual and audio asset checklist |
| [`MINIGAME_ASSET_MANIFEST.md`](MINIGAME_ASSET_MANIFEST.md) | Planned staged-minigame assets |
| [`ART_TODO.md`](ART_TODO.md) | Per-map art prompts and references |
| [`FONT_CREDITS.md`](FONT_CREDITS.md) | Font authors and licenses |

## Status

- **Story and gameplay direction:** implemented in the shipped data.
- **Protagonist reveal:** distributed through the required route, with the Player carrying the dream and `???` carrying its material cost until integration.
- **UI:** minigames and adventure stages use the shared fitting and layout guard described in [`MINIGAME_UI.md`](MINIGAME_UI.md).
- **Build:** a verified Windows export exists; see [`BUILD.md`](BUILD.md).
- **Validation:** `tools/RunRegressionSuite.ps1` is the maintained entry point.
