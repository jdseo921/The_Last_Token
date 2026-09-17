# Architecture

The systems behind the headline bullets in the [README](../README.md), at the detail the
README used to carry. Nothing here is new: this is the long form, moved out so the README
reads in two minutes.

## Quest and flag progression

Quest records are data, not code: [`data/quests.json`](../data/quests.json) holds title, owner, location, summary, `required`, the `starts_after` prerequisite flag, and the Memory Signal each quest moves, loaded through [`scripts/QuestRegistry.gd`](../scripts/QuestRegistry.gd). [`scripts/GameState.gd`](../scripts/GameState.gd) (1,589 lines) is the single autoloaded source of route truth: more than a hundred named story flags, a derived current-quest resolver, story phase labels, a five-level Memory Signal, a twelve-milestone required-progress counter, and `validate_debug_state()` invariants. [`scripts/RouteCue.gd`](../scripts/RouteCue.gd) and [`scripts/QuestNotice.gd`](../scripts/QuestNotice.gd) turn that state into per-room guidance instead of hard-coded objective text.

## NPC and dialogue systems

[`scripts/DialoguePool.gd`](../scripts/DialoguePool.gd) loads line sets from [`data/dialogue/`](../data/dialogue) for the ten speakers registered in `CHARACTER_FILES` (NPCs, machines, and environment objects) and serves them first, random, or sequential, with defined fallbacks when a file or key is missing. [`scripts/DialogueBox.gd`](../scripts/DialogueBox.gd) handles the typewriter reveal, per-speaker reveal rates, portrait rect and text-inset switching, and a separate scan-jitter presentation for the antagonist speakers that also ducks music through the AudioManager. [`scripts/DialoguePortraitRegistry.gd`](../scripts/DialoguePortraitRegistry.gd) and [`scripts/ChoiceBox.gd`](../scripts/ChoiceBox.gd) cover portrait resolution and branching prompts.

## Minigame roster

Eleven playable screens plus a template, enumerated once in [`scripts/qa/MinigameTestCatalog.gd`](../scripts/qa/MinigameTestCatalog.gd) so pause, layout, and UI-architecture coverage all inherit the same inventory: Rockbyte Duel, Broken High Score, Truth Filter, Circuit Soda, Security Tape Assembly, Memory Echo, Static Service Run, Snack Service Dash, Prize Shelf Run, Night Ledger Run, and the Maintenance Sync door puzzle. Presentation is shared rather than copied — [`scripts/ui/MinigameUI.gd`](../scripts/ui/MinigameUI.gd), [`scripts/ui/MinigameTextBox.gd`](../scripts/ui/MinigameTextBox.gd), and [`scripts/ui/MinigameUILayoutGuard.gd`](../scripts/ui/MinigameUILayoutGuard.gd), which preserves authored rectangles and shrinks text only when changed copy would overflow them. The side-scrolling stages reuse one movement FSM in [`scripts/minigames/adventure/HybridExplorerController.gd`](../scripts/minigames/adventure/HybridExplorerController.gd), driven by per-stage profiles from [`HybridAdventureCatalog.gd`](../scripts/minigames/adventure/HybridAdventureCatalog.gd).

## Save/load with spawn-marker-safe restores

[`scripts/SaveManager.gd`](../scripts/SaveManager.gd) writes three JSON slots under `user://saves/`. Slot summaries are read without loading a game. Malformed player files are parsed with a `JSON` instance rather than `JSON.parse_string()`, so a corrupt save is rejected quietly with logged context instead of raising engine errors. Restores avoid exact coordinates: transient scenes (minigames, cutscenes, title flow) are mapped back to the parent room that owns them, and the room is then entered at a named spawn marker. `GameState.apply_save_data()` back-fills prerequisite flags for saves written before the route was expanded, so older saves keep loading.

## Scene transitions

[`scripts/SceneChanger.gd`](../scripts/SceneChanger.gd) owns a fade overlay, a re-entrancy guard, named route constants for every destination, and return-point capture so a minigame can hand control back to the room that launched it. [`scripts/MapTransition.gd`](../scripts/MapTransition.gd) exports target scene, target spawn id, and an optional required flag with locked dialogue; it draws a proximity-revealed destination arrow and arms itself only after the spawn frame, so a spawn overlapping an exit cannot bounce the player straight back.

## Audio management

[`scripts/AudioManager.gd`](../scripts/AudioManager.gd) runs a pooled set of SFX players and two music players for crossfades, maps a context id (room, stage, or story phase) to a track, dims music while the unknown voice speaks, and re-reads volumes from [`scripts/GameSettings.gd`](../scripts/GameSettings.gd) when settings change.

## In-editor debug and diagnostic tooling

[`scripts/DebugLog.gd`](../scripts/DebugLog.gd) is a structured session trace: categorised events written to `user://logs` in debug builds (or with `THE_LAST_TOKEN_DEBUG=1`), a 250-entry ring buffer, `F9` for a full route snapshot, `F8` for recent events, and automatic `invalid_route_state` errors when GameState reports an impossible flag combination. [`scripts/Debug.gd`](../scripts/Debug.gd) is a compile-safe bridge to it so isolated `--script` QA runs do not depend on autoload symbols. [`scripts/DevRouteMenu.gd`](../scripts/DevRouteMenu.gd) adds `F10` checkpoint jumps, gated on a debug build plus an explicit flag. [`tools/`](../tools) holds 49 further GDScript utilities: `audit_text_fit.gd` (measures every Label and Button against its own rect, its parent panel, and the viewport), `diag_*.gd` probes, `capture_*.gd` screenshot runners, and deterministic asset generators.
