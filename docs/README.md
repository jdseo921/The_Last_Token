# The Last Token — Design Docs (Canonical)

This folder is the **single source of truth** for story and gameplay direction. It reworks and consolidates the ~30 scattered root-level planning docs into two clear, non-contradictory documents.

## Read these

1. **[DESIGN_BIBLE.md](DESIGN_BIBLE.md)** — canon (premise, the twist, the dark-past tone rule), the theme & **motto distribution map**, characters & voice, the Memory Signal system, dialogue rules, and the **45–60 min story flow**.
2. **[STAGE_DESIGN.md](STAGE_DESIGN.md)** — every playable stage's redesign: distinct verb, entertainment, story connection, per-stage dialogue (lore + breather + motto), coded difficulty, and build order.

## Canon rule

Where these docs and any older root-level doc disagree, **these win.** "Canon" = the shipped game data (`data/dialogue/*.json`, `data/quests.json`, `scripts/StaffRoom.gd`), reconciled here. The old planning docs are advisory only and slated for `docs/archive/` (see Bible §9) — nothing is deleted without approval.

## Status

- **Story & gameplay direction:** drafted here, pending sign-off.
- **Art direction:** deferred to the visual phase (per project sequencing). Per-stage visual notes are captured in `STAGE_DESIGN.md` for that pass; the existing `ART_STYLE.md` / `VISUAL_UPGRADE_PLAN.md` will be reworked then.

## Implementation order (Bible + Stage §7)

1. Dialogue single-source cleanup (remove triplication; fix signal values).
2. Story pass — seed foreshadowing, motto fragments, breathers (data only).
3. Framework capabilities (moving hazards + fog in `ArcadeAdventureStage`).
4. Stage redesigns (route order, cheapest wins first).
5. Ending reprise (conditional fragment collection).
6. Art pass (deferred).
