# The Last Token

The Last Token is a 2D top-down retro arcade mystery built in Godot 4.7 with GDScript. The player explores Pixel Haven after closing, talks to the arcade's regulars, recovers a lost token, works through eleven required quests and a roster of arcade stages, unlocks the staff room, and finds out who they actually are.

<!-- SCREENSHOT SLOT. Record docs/media/arcade-hub.png, then delete this comment and
     uncomment the line below. It is commented out so the README does not render a
     broken-image icon in the meantime.

![The Last Token — the Pixel Haven arcade hub](docs/media/arcade-hub.png)

Captures to record into docs/media/:
  arcade-hub.png   ArcadeHub with Mira at the ticket counter and the quest notice visible
  dialogue.png     A DialogueBox line with a portrait (Mira or Mr. Byte)
  minigame.gif     ~6s of Rockbyte Duel or Circuit Soda being played
  staff-room.png   A Staff Room reveal slideshow panel
  save-slots.png   The three-slot Memory Slot menu

Capture helpers exist under tools/capture_*.gd; they write PNGs to tmp/captures/ and need a
real rendering display, because the headless dummy renderer has no framebuffer.
-->

## Status

The game is complete and playable end to end. It was showcased at my university's IT club in July 2026, where roughly ten people played it, and I fixed the bugs that playtest surfaced.

What remains is minor polish:

- Exit placement between rooms.
- Adventure-stage level adjustments.

## What this demonstrates

- **Quest and flag progression.** Quest records are data, not code: [`data/quests.json`](data/quests.json) holds title, owner, location, summary, `required`, the `starts_after` prerequisite flag, and the Memory Signal each quest moves, loaded through [`scripts/QuestRegistry.gd`](scripts/QuestRegistry.gd). [`scripts/GameState.gd`](scripts/GameState.gd) (1,584 lines) is the single autoloaded source of route truth: roughly ninety named story flags, a derived current-quest resolver, story phase labels, a five-level Memory Signal, a twelve-milestone required-progress counter, and `validate_debug_state()` invariants. [`scripts/RouteCue.gd`](scripts/RouteCue.gd) and [`scripts/QuestNotice.gd`](scripts/QuestNotice.gd) turn that state into per-room guidance instead of hard-coded objective text.
- **NPC and dialogue systems.** [`scripts/DialoguePool.gd`](scripts/DialoguePool.gd) loads line sets from [`data/dialogue/`](data/dialogue) for the ten speakers registered in `CHARACTER_FILES` (NPCs, machines, and environment objects) and serves them first, random, or sequential, with defined fallbacks when a file or key is missing. [`scripts/DialogueBox.gd`](scripts/DialogueBox.gd) handles the typewriter reveal, per-speaker reveal rates, portrait rect and text-inset switching, and a separate scan-jitter presentation for the antagonist speakers that also ducks music through the AudioManager. [`scripts/DialoguePortraitRegistry.gd`](scripts/DialoguePortraitRegistry.gd) and [`scripts/ChoiceBox.gd`](scripts/ChoiceBox.gd) cover portrait resolution and branching prompts.
- **Minigame roster.** Eleven playable screens plus a template, enumerated once in [`scripts/qa/MinigameTestCatalog.gd`](scripts/qa/MinigameTestCatalog.gd) so pause, layout, and UI-architecture coverage all inherit the same inventory: Rockbyte Duel, Broken High Score, Truth Filter, Circuit Soda, Security Tape Assembly, Memory Echo, Static Service Run, Snack Service Dash, Prize Shelf Run, Night Ledger Run, and the Maintenance Sync door puzzle. Presentation is shared rather than copied — [`scripts/ui/MinigameUI.gd`](scripts/ui/MinigameUI.gd), [`scripts/ui/MinigameTextBox.gd`](scripts/ui/MinigameTextBox.gd), and [`scripts/ui/MinigameUILayoutGuard.gd`](scripts/ui/MinigameUILayoutGuard.gd), which preserves authored rectangles and shrinks text only when changed copy would overflow them. The side-scrolling stages reuse one movement FSM in [`scripts/minigames/adventure/HybridExplorerController.gd`](scripts/minigames/adventure/HybridExplorerController.gd), driven by per-stage profiles from [`HybridAdventureCatalog.gd`](scripts/minigames/adventure/HybridAdventureCatalog.gd).
- **Save/load with spawn-marker-safe restores.** [`scripts/SaveManager.gd`](scripts/SaveManager.gd) writes three JSON slots under `user://saves/`. Slot summaries are read without loading a game. Malformed player files are parsed with a `JSON` instance rather than `JSON.parse_string()`, so a corrupt save is rejected quietly with logged context instead of raising engine errors. Restores avoid exact coordinates: transient scenes (minigames, cutscenes, title flow) are mapped back to the parent room that owns them, and the room is then entered at a named spawn marker. `GameState.apply_save_data()` back-fills prerequisite flags for saves written before the route was expanded, so older saves keep loading.
- **Scene transitions.** [`scripts/SceneChanger.gd`](scripts/SceneChanger.gd) owns a fade overlay, a re-entrancy guard, named route constants for every destination, and return-point capture so a minigame can hand control back to the room that launched it. [`scripts/MapTransition.gd`](scripts/MapTransition.gd) exports target scene, target spawn id, and an optional required flag with locked dialogue; it draws a proximity-revealed destination arrow and arms itself only after the spawn frame, so a spawn overlapping an exit cannot bounce the player straight back.
- **Audio management.** [`scripts/AudioManager.gd`](scripts/AudioManager.gd) runs a pooled set of SFX players and two music players for crossfades, maps a context id (room, stage, or story phase) to a track, dims music while the unknown voice speaks, and re-reads volumes from [`scripts/GameSettings.gd`](scripts/GameSettings.gd) when settings change.
- **In-editor debug and diagnostic tooling.** [`scripts/DebugLog.gd`](scripts/DebugLog.gd) is a structured session trace: categorised events written to `user://logs` in debug builds (or with `THE_LAST_TOKEN_DEBUG=1`), a 250-entry ring buffer, `F9` for a full route snapshot, `F8` for recent events, and automatic `invalid_route_state` errors when GameState reports an impossible flag combination. [`scripts/Debug.gd`](scripts/Debug.gd) is a compile-safe bridge to it so isolated `--script` QA runs do not depend on autoload symbols. [`scripts/DevRouteMenu.gd`](scripts/DevRouteMenu.gd) adds `F10` checkpoint jumps, gated on a debug build plus an explicit flag. [`tools/`](tools) holds 48 further GDScript utilities: `audit_text_fit.gd` (measures every Label and Button against its own rect, its parent panel, and the viewport), `diag_*.gd` probes, `capture_*.gd` screenshot runners, and deterministic asset generators.

## QA automation

[`scripts/qa/`](scripts/qa) holds 35 automated checks plus a shared scene inventory (36 files, 4,876 lines), driven by one PowerShell entry point.

```powershell
pwsh tools/RunRegressionSuite.ps1
```

[`tools/RunRegressionSuite.ps1`](tools/RunRegressionSuite.ps1) runs an editor-wide parse precheck, boots the main scene, then executes all 35 sequentially in headless Godot. It does not trust exit codes alone: every log is scanned for `SCRIPT ERROR: Parse Error`, `SCRIPT ERROR: Compile Error`, `Failed to load script`, and `Failed to instantiate an autoload`, so a silent compile failure still fails the run. Each check writes its own log under `tmp/qa/<timestamp>/`, and a failing run prints the offending log path.

What the suite asserts, with the real engine running:

- **Whole-game sanity** — [`GameSanityAudit.gd`](scripts/qa/GameSanityAudit.gd): the title scene boots and is interactive; every `MapTransition` target scene *and* target spawn marker exists, in both directions, across all seventeen rooms; every dialogue line in the shipped data fits the real DialogueBox text rect at the real font size; save to summary to reload round-trips, and deliberately corrupted save files fail safely; every music context resolves to a stream that exists.
- **Route and quest integrity** — [`RequiredRouteStateSmoke.gd`](scripts/qa/RequiredRouteStateSmoke.gd) replays the whole required route flag by flag and asserts the quest id, story phase, Memory Signal, and progress count at every beat. [`QuestFlowAudit.gd`](scripts/qa/QuestFlowAudit.gd) walks the same route and checks that quest data is complete and that RouteCue produces guidance from every room. [`ScenePathSmoke.gd`](scripts/qa/ScenePathSmoke.gd) checks that required scene paths still resolve.
- **UI and layout** — [`MinigameLayoutAudit.gd`](scripts/qa/MinigameLayoutAudit.gd) instantiates every catalogued minigame screen and measures visible labels and buttons against their parent rectangles, including alternate states and multi-line capacity. [`MinigameUiArchitectureSmoke.gd`](scripts/qa/MinigameUiArchitectureSmoke.gd), [`MinigamePauseCoverageSmoke.gd`](scripts/qa/MinigamePauseCoverageSmoke.gd), [`PauseMenuSmoke.gd`](scripts/qa/PauseMenuSmoke.gd), [`PresentationConsistencySmoke.gd`](scripts/qa/PresentationConsistencySmoke.gd), and [`SaveSlotDisplaySmoke.gd`](scripts/qa/SaveSlotDisplaySmoke.gd) cover shared UI structure, pause coverage on every screen, and slot-text layout.
- **Dialogue and story data** — [`DialoguePoolSmoke.gd`](scripts/qa/DialoguePoolSmoke.gd) (loading, set selection, missing-file and missing-key fallbacks), [`DialoguePortraitSmoke.gd`](scripts/qa/DialoguePortraitSmoke.gd) (portrait sources stay at or above the displayed rect, so art is only ever downscaled), [`DialogueStyleSmoke.gd`](scripts/qa/DialogueStyleSmoke.gd), [`DialogueHandoffSmoke.gd`](scripts/qa/DialogueHandoffSmoke.gd), [`PostMinigameDialogueSmoke.gd`](scripts/qa/PostMinigameDialogueSmoke.gd), [`StorylineSanitySmoke.gd`](scripts/qa/StorylineSanitySmoke.gd), and [`LoreConsistencySmoke.gd`](scripts/qa/LoreConsistencySmoke.gd).
- **Per-stage regressions** — [`HybridExplorerSmoke.gd`](scripts/qa/HybridExplorerSmoke.gd) for the shared movement FSM, plus focused checks for Circuit Soda, Truth Filter, Broken High Score, the Night Ledger archive, the hallway network, the opening arrival, the prize-echo handoff, closing-shift echoes, unknown-voice music ducking, and the debug diagnostics themselves.

Traversability is covered too: [`RouteTraversalSmoke.gd`](scripts/qa/RouteTraversalSmoke.gd) flood-fills each of the 17 rooms from its spawn point using the real player body against the real physics world, then asserts every exit, every interactable and every other spawn marker lies in that one connected region. It uses shape queries rather than reading the collision export, so collision derived from sprites and polygons counts too.

The suite's boundary is stated in [`docs/QA_AUTOMATION.md`](docs/QA_AUTOMATION.md): headless checks cover structure, data, state, and layout — not movement feel, input timing, or readability. Those are verified by playing the game.

## Project scale

Measured from tracked files at the current commit:

| | Files | Lines |
| --- | ---: | ---: |
| Game and UI GDScript (`scripts/`, excluding `scripts/qa/`) | 70 | 18,670 |
| QA GDScript (`scripts/qa/`) | 36 | 4,876 |
| Tooling GDScript (`tools/`) | 48 | 5,005 |
| **Total GDScript** | **154** | **28,551** |

Also 49 `.tscn` scenes, 13 JSON data files (quests, dialogue, minigame config, asset manifest), and 2 PowerShell runners.

## Engine

- Godot 4.7.stable (`project.godot` lists the `4.7` feature tag).
- Main scene: `res://scenes/main/Main.tscn`.
- Fixed 640x440 viewport, `canvas_items` stretch, no Camera2D — each room is one screen.
- Nine autoloads: `DebugLog`, `GameState`, `SceneChanger`, `SaveManager`, `AudioManager`, `DisplayOptions`, `GameSettings`, `ConscienceEncounterDirector`, `DevRouteMenu`.

## Play it

Download the Windows x64 build from
[Releases](https://github.com/jdseo921/The_Last_Token/releases/latest). Unzip
`TheLastToken.exe` and `TheLastToken.pck` into the same folder and run the exe —
the `.pck` carries the game content and the exe will not start without it
alongside. No Godot install needed.

## Open the project

1. Install Godot 4.7.
2. Open Godot's Project Manager.
3. Choose `Import`.
4. Select this folder's `project.godot`.
5. Open the project.

## Run the game

1. Open the project in Godot.
2. Press Play.
3. If prompted for a main scene, choose `res://scenes/main/Main.tscn`.

## Windows export

`export_presets.cfg` at the repo root is configured for Windows Desktop and excludes `tools/`, `tmp/`, `docs/`, `*.md`, and `scripts/qa/` from the shipped build.

```
godot --headless --path . --export-release "Windows Desktop" build/windows/TheLastToken.exe
```

That writes `TheLastToken.exe` plus `TheLastToken.pck` — ship both together. `build/` is gitignored. Full build notes, including export templates, are in [`docs/BUILD.md`](docs/BUILD.md).

## Controls

Input actions are registered at runtime from `ACTION_BINDINGS` in [`scripts/GameState.gd`](scripts/GameState.gd) rather than from the project input map.

- Move: `WASD` / Arrow Keys
- Interact / Continue / Jump: `E` / `Space`
- Crouch: `S` / `Down`
- Cancel / Back / Pause: `Esc` / `Backspace`
- Menus: mouse click or keyboard focus

Window size is an in-game setting (Settings -> Display -> Window Size) offering `640 x 440`, `960 x 660`, and `1280 x 880`, persisted to `user://display.cfg`. Settings also covers master, SFX, and music volume, dialogue box opacity, and text speed.

## Core gameplay loop

Explore the arcade, talk to Mira and the other regulars, play the required arcade stages, investigate the closing-shift records, restore service power, assemble the Security Tape, stabilize the Memory Echo, enter the Staff Room, watch the reveal slideshow, and continue into post-reveal roam.

The required chain in [`data/quests.json`](data/quests.json) runs:

1. Recover the Lost Token — Mira / Cabinet 07 — Rockbyte Duel
2. Broken High Score — Roxy — Cabinet Row
3. Truth Filter — Mr. Byte — Cabinet Row
4. Route the Signal — Vendo — Circuit Soda
5. Prize Echo Ascent — Pip — Prize Corner
6. Closing Shift Echoes — Gus — lore investigation, no minigame
7. Static Service Run — Gus — Maintenance Hall
8. Maintenance Sync — Gus — door puzzle
9. Enter the Staff Corridor — Staff Door
10. Assemble the Security Tape — Staff Room
11. Stabilize the Memory Echo — Staff Room
12. Staff Room reveal, ending prompt, post-reveal roam

Three quests are optional: the Night Ledger archive run, the staff records chain, and the post-reveal witness route. Conscience encounters are short dialogue interludes between required beats, not stages.

`GameState` tracks required progress as a twelve-milestone count (`TOTAL_REQUIRED_PROGRESS_COUNT`). That count is not a one-to-one map of the list above: one milestone is a retired Final Night Walk stage whose flag is now back-filled when the Memory Echo completes, and the Staff Corridor step is a route gate that does not increment the counter.

## Save files

The Esc pause menu opens save and load across three slots, stored as `user://saves/slot_1.json`, `slot_2.json`, and `slot_3.json`. Each slot in the menu shows its slot number, story phase, and last-saved timestamp; live quest counters were deliberately removed from the slot text so the list does not change shape as the player progresses. Loads restore through safe scene spawn markers instead of exact player coordinates.

## Dev route checkpoints and debug overlays

The route checkpoint menu is disabled by default and only builds itself in a debug or editor run. Enable it with `--dev-route-menu`, `THE_LAST_TOKEN_DEV_ROUTE_MENU=1`, or the `the_last_token/dev_route_menu_enabled` project setting, then press `F10` to jump to one of ten route checkpoints. Do not enable it for normal play or exports.

In the same debug builds, `F9` prints a route snapshot and `F8` prints the recent structured event buffer plus the session log path. [`docs/DEBUGGING.md`](docs/DEBUGGING.md) lists the event categories.

## Current placeholders

- Some map and character visuals are still simple shapes and labels. Route cues point at the next required room or local action, and small ambient sprite effects carry cabinet, static, and exit signals.
- The Staff Room reveal uses eight mono-color 8-bit panels under `assets/art/cutscenes/memory_reveal/`. The slideshow falls back to a `MEMORY PANEL / Placeholder image pending` card if an image is removed.
- Sixteen music tracks are wired through `AudioManager`; the sixteen SFX are simple generated WAV one-shots.
- Exact player position restore is intentionally not implemented. Story state, safe scene paths, and safe spawn markers are restored instead.
- Rockbyte Duel uses simple cabinet AI, so a win may take a retry.
- Generated polish assets are deterministic and project-local. The generators live under `tools/` and cover reveal panels, hub and minigame sprites, ambient effect sheets, stage backgrounds, and the WAV one-shots.

## Documentation

Design, content, QA, and build documents live in [`docs/`](docs). Start at [`docs/README.md`](docs/README.md) for the index, or [`docs/STORY_CANON.md`](docs/STORY_CANON.md) for the current story source of truth. [`AGENTS.md`](AGENTS.md) holds the working rules the project was built under.

## License

Code is MIT licensed — see [`LICENSE`](LICENSE). Placeholder art and audio assets are excluded from that grant.
