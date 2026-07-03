# The Last Token — Pixel Haven Map Structure (Canonical)

> Companion to [`DESIGN_BIBLE.md`](DESIGN_BIBLE.md) / [`STAGE_DESIGN.md`](STAGE_DESIGN.md). This defines the **newly decided floor plan** — the rooms, their purposes, and how they connect. Per project direction, this is **structure-first**: it is decided without regard to final visuals or NPC placement, which are adjusted afterward. Reference model: **Five Nights at Freddy's 1** — a central anchor with a web of distinct-purpose rooms and a gated back-of-house.

## Design goals

1. **Kill the pure hub-and-spoke.** Today Pixel Haven is a star: every room dead-ends back at the hub. The new plan adds a **front-of-house loop** so the public area reads like a real building you can circle, with multiple routes and no dead-ends.
2. **Every room earns its space** with *a few* purposes each (a stage, a lore drop, an NPC, a secret) — "not one per place, but a few at most."
3. **Front-of-house (public) vs back-of-house (staff, gated).** The mystery lives in the progressive unlock from the bright public loop into the dark, personal back rooms — 04 walking deeper into his own past.
4. **Reuse the engine.** Rooms are 640×440, no camera (one screen each), connected by `MapTransition` + `Spawn_From<Origin>` markers per the existing pattern. New rooms are built by copying a minimal room (PrizeCorner) — no new systems.

## The floor plan

```
                         ┌──────────────────┐
                         │  FRONT ENTRANCE  │  wake point · locked exit · arcade history
                         │      (NEW)       │
                         └────────┬─────────┘
                                  │
   ┌──────────────┐      ┌────────┴─────────┐      ┌──────────────┐
   │  PARTY ROOM  │──────│   ARCADE HUB     │──────│  CABINET ROW │
   │    (NEW)     │      │  (Main Floor)    │      │              │
   └──────┬───────┘      │  ★ central hub   │      └──────┬───────┘
          │              └───┬──────────┬───┘             │
          │                  │          │ (gated)         │
   ┌──────┴───────┐   ┌──────┴─────┐    │          ┌──────┴───────┐
   │ PRIZE CORNER │───│ SNACK ALCOVE│────┘          │  (loop back  │
   │              │   │             │  gated        │   to Snack)  │
   └──────────────┘   └─────────────┘               └──────────────┘
   FRONT-OF-HOUSE LOOP:  Hub ─ Cabinet Row ─ Snack Alcove ─ Prize Corner ─ Party Room ─ Hub

   ══════════════════════ gated: circuit_soda_completed ══════════════════════
                                  │  (Service Door / Back Hall)
                         ┌────────┴─────────┐      ┌──────────────┐
                         │ MAINTENANCE HALL │──────│  WORKSHOP    │  maker's workbench · prototype
                         │                  │      │   (NEW)      │
                         └────────┬─────────┘      └──────────────┘
                                  │  gated: staff_corridor_unlocked
                         ┌────────┴─────────┐      ┌──────────────┐
                         │  STAFF CORRIDOR  │──────│ MEMORY CORE  │  memory banks · late lore
                         │                  │      │   (NEW)      │
                         └────────┬─────────┘      └──────────────┘
                                  │  gated: memory_echo_completed
                         ┌────────┴─────────┐
                         │    STAFF ROOM    │  ★ the reveal (climax)
                         └──────────────────┘
```

## Rooms & purposes

Legend: **[game]** playable stage · **[NPC]** character · **[lore]** readable/environment lore · **[secret]** optional · **[nav]** structural.

### Front of house (public)

| Room | Status | Purposes (a few each) |
|---|---|---|
| **Front Entrance** | **NEW — built** | [nav] the way you woke in; [lore] arcade history board + the closing notice (seeds decline); [mystery] the locked exit doors — you *cannot leave*, and no one will say why yet (ties to the reveal's "already inside"). |
| **Arcade Hub (Main Floor)** | keep | [NPC] Mira (counter); [game] Rockbyte Duel via Cabinet 07; [lore] Owner Portrait (the drifting nameplate); [nav] central anchor, all spokes. |
| **Cabinet Row** | keep | [game] Truth Filter (Mr. Byte); [game/secret] Broken High Score (Roxy); [lore] staff schedule + records. |
| **Snack Alcove** | keep | [game] Circuit Soda (Vendo); [lore] Vendo's old-staff musings; [breather] comic relief. |
| **Prize Corner** | keep | [game/secret] Prize Sort (Pip); [lore] prize counter + the Blank Employee Badge; [secret] witness route. |
| **Party Room** | **NEW — built** | [lore] community wall — birthday photos with the owner half-in-frame, kids' drawings, a mascot stage (the arcade as "somewhere kinder to go"); [secret] an optional "birthday high-score" cabinet; [breather] faded celebration. |
| **Restrooms / Mirror Nook** | NEW — built | [lore/atmosphere] a mirror that briefly shows two signals standing where one stands (the strongest pre-reveal foreshadow); [secret] a hidden token. Small nook off the loop. |

### Back of house (staff, gated)

| Room | Status | Purposes |
|---|---|---|
| **Maintenance Hall** | keep | [game] Static Service Run + Maintenance Sync (Gus); [NPC] Gus; [lore] maintenance note. |
| **Workshop / Storage** | NEW — built | [lore] the maker's workbench — where 04 built the cabinets by hand (pays off cutscene panel 1); broken cabinets, spare parts; [secret] an unfinished prototype game he never shipped. Deepest maker lore. |
| **Staff Corridor** | keep | [game] Security Tape + Final Night Walk; [lore] staff records 03. |
| **Memory Core / Basement** | NEW — built | [lore] the arcade's memory heart — banks of drives literally holding everyone's memory of 04 (pays off "the system saved what it could"); a quiet, late, gated lore beat before the Staff Room. Candidate future home for Memory Echo. |
| **Staff Room** | keep | [climax] the reveal + self-conflict. |

## Connectivity (adjacency, new plan)

- **Front loop (ungated / early):** ArcadeHub ⇄ Cabinet Row ⇄ Snack Alcove ⇄ Prize Corner ⇄ **Party Room** ⇄ ArcadeHub. Plus **Front Entrance** ⇄ ArcadeHub. (Restrooms hang off Party Room.)
- **Back branch (gated, linear with spurs):** ArcadeHub ⇄ Maintenance Hall `[circuit_soda_completed]`; Maintenance Hall ⇄ **Workshop**; Maintenance Hall ⇄ Staff Corridor `[staff_corridor_unlocked]`; Staff Corridor ⇄ **Memory Core**; Staff Corridor ⇄ Staff Room `[memory_echo_completed]`.
- Existing gates are unchanged (Snack `lying_cabinets_completed`, Maintenance `circuit_soda_completed`, Staff Corridor `staff_corridor_unlocked`).

## Build status & how the new rooms are made

Each new room is a copy of the minimal room pattern (PrizeCorner): a 640×440 `Node2D` with `Background`, `CollisionBounds` (perimeter walls with **door gaps**), `Spawn_From<Origin>` markers, `Player`, an `InteractableLayer` of purpose stubs, `MapTransition` exits, and a `UILayer` (DialogueBox + InteractionPrompt). Rooms connect via a lightweight hallway or a direct `MapTransition`. Visuals and final NPC/lore text are **placeholders**, to be dressed in the later art/story passes.

- **Built, wired & cross-validated (all 5 new rooms):** Front Entrance, Party Room, Restrooms (front loop); Workshop (off Maintenance Hall); Memory Core (off Staff Corridor). Every `MapTransition.target_spawn_id` resolves to an existing marker in its target scene (verified across all 8 involved scenes), spawn markers are cleared of the 72×40 exit triggers, and each room carries purpose stubs + placeholder lore.
- **Verification note:** scenes are authored to the established pattern and statically validated (refs resolve, spawn round-trips consistent, scripts balanced), but a **Godot editor open + playtest pass** is required to confirm navigation, spawns, and collision door-gaps in-engine (there is no headless render here).
- **Later passes:** dress visuals + final NPC/lore text (the new rooms currently use hardcoded placeholder dialogue rather than the DialoguePool — fine for a shell, worth formalizing when the text is finalized).
