# The Last Token — Stage Design (Canonical)

> Companion to [`DESIGN_BIBLE.md`](DESIGN_BIBLE.md). Defines every playable stage: its **distinct verb**, its **own entertainment**, its **story connection**, its **dialogue beats** (one lore beat + one breather beat, per Bible §6), and its **coded difficulty**. Design principle: **reuse the two existing frameworks so richness does not become bloat.**

## 0. Two frameworks to build on (bloat control)

- **`ArcadeAdventureStage.gd`** — a data-driven grid engine (ASCII layouts, areas, collectibles, hazards, colors). New grid stages are *config, not code*. Extend it **once** with two reusable capabilities the redesigns need: **(a) moving hazards** on timed patrols, and **(b) a "fog"/reveal mask**. Both are generic and pay off across stages.
- **`MinigameStage` staged-presentation layer** (`scripts/minigames/common/`) — actors/props/action-queue with timeout guards and placeholder fallbacks. Currently only Rockbyte Duel uses it; adopt it for the redesigned bespoke stages so their *visuals* get richer without new animation code.
- **`ArcadeJuice.gd`** (`pulse_control`, `flash_overlay`) — shared feedback; use everywhere for feel.

Rule: **no stage gets a brand-new bespoke system** if a config + a small shared capability can express it.

---

## 1. Keep as-is mechanically (already have depth)

Only apply Bible §6 dialogue rules (ensure each has a lore + breather beat and, where mapped, a motto fragment). **Do not touch the mechanics.**

| Stage | Why it stays | Dialogue to add |
|---|---|---|
| **Rockbyte Duel** (Nim vs adaptive AI) | Real strategy + adaptive leeway. Strong opener. | Cabinet 07 motto-A beat: a win recovered the token, not the identity. Mira breather (token anecdote — already strong). |
| **Circuit Soda** (pipe-routing BFS puzzle) | Genuine logic puzzle with a real solver. | Vendo motto-B beat: kept without a label. Keep the comic breather; **vary the "X but really Y" tic.** |
| **Sync Door / Maintenance Sync** (timed reversed-label switches) | Real escalating rule; the route's mechanical peak. | Gus lore beat: "the one you forgot making." Short. |

---

## 2. Required stages — redesigns

Format per stage: **Current → Problem → New design → Story → Dialogue → Difficulty → Visual (later).**

### 2.1 Truth Filter (Mr. Byte)
- **Current:** 4-round multiple-choice quiz; wrong answers just wobble and let you retry. No stakes; same verb as Memory Echo.
- **Problem:** static trivia; no tension; mechanically duplicates Memory Echo.
- **New design — "Lie Density" sorter.** Keep the fiction (sort true vs. corrupted records) but add a **Lie-Density meter** and a **lucid window**: each record **flickers** between its true and corrupted text; you must select the *true* one **while it's lucid**. Correct picks push the meter down; wrong picks or stalling push it up. You win by holding the meter in the stable band through 5 escalating rounds. Later rounds flicker faster and add a second corrupted decoy. Reuses the existing choice UI + `ArcadeJuice` + a meter node.
- **Story:** you are literally forcing 04's contradictory memories to hold still long enough to read. The meter *is* his denial.
- **Dialogue:** *Lore* — Mr. Byte frames each record as a fragment of the final night (a schedule, a score, a locked door). *Breather* — Gus, before/after: "Do not argue with a machine that owns red pens." *Motto (A)* — completion: "Lie density reduced. Identity conflict remains." A correct sort doesn't fix everything.
- **Difficulty (coded):** flicker interval shrinks per round (Uneasy→Fractured); round 4–5 add a decoy. Knobs: `flicker_ms`, `decoy_count`, `meter_gain`.
- **Visual (later):** the `truth_filter_cabinets_sheet` (already good) as the record faces; corrupted state = glitch overlay.

### 2.2 Lost Shift File (read + deduce)
- **Current:** walk to 3 readables, press E, talk to Gus. Zero interaction.
- **Problem:** passive reading; no "aha."
- **New design — reconstruct the final night.** Keep the 3-object hunt (Closing Checklist, Staff Schedule, Maintenance Note), but each yields a **clue token** (a *time*, a *role*, a *door-event*). At Mr. Byte's kiosk, the player **assembles** them: order the three events into the night's timeline **and** deduce the redacted staff slot (choose from candidates using the clues). A wrong assembly gives a gentle nudge, not a fail. Turns reading into deduction. Reuses `ChoiceBox` / a small ordering UI.
- **Story:** the player *earns* the realization that a shift was hidden — the number-before-name motif is discovered, not told.
- **Dialogue:** *Lore* — the three objects (already written well) plus a new synthesis line from Mr. Byte: "The arcade counted what it could not say." *Breather* — Gus deflects with "I called it maintenance and kept moving." *Motto (B, soft):* the number was a door, not a verdict.
- **Difficulty (coded):** trivial mechanically by design (it's the story's quiet center); challenge is comprehension. Keep short.
- **Visual (later):** clue tokens as small readable note sprites.

### 2.3 Static Service Run (Gus)
- **Current:** grid maze, collect 16 fuses, **static hazards are immobile tiles** that reset you to spawn. Identical engine to Final Night Walk.
- **Problem:** generic collect-maze; no tension; a twin of stage 8.
- **New design — power the dark route.** Reframe from "collect" to **"restore power, and power reveals the path."** The maze starts mostly **dark (fog mask)**; each breaker-node you activate lights its section and exposes the next stretch. **Static hazards MOVE** on timed patrols along the wires (use the new moving-hazard capability) — touching one browns-out a section (soft setback), not a full reset. Reach the main breaker to finish. This is a light vision-and-timing maze, mechanically distinct from stage 8's memory retrace.
- **Story:** you are waking the service route so Gus can question the door. The dark that recedes as you work mirrors memory returning.
- **Dialogue:** *Lore* — Gus: the door "reported two signals after closing." *Breather + Motto (B)* — Gus completion: "Routine work is easier to carry than fear... Cleaner does not mean safe." Carrying on *is* the win.
- **Difficulty (coded):** hazard patrol speed + count scale with Fractured; fog radius shrinks late. Knobs: `hazard_speed`, `hazard_count`, `fog_radius`.
- **Visual (later):** the maintenance_hall palette; lit sections bloom warm, unlit stay cold.

### 2.4 Security Tape Assembly
- **Current:** click 4 fragment buttons to order them — but `FRAGMENTS` **already ships in the correct order** with no shuffle, so top-to-bottom wins first try.
- **Problem:** the puzzle is pre-solved. Genuinely no gameplay.
- **New design — reconstruct + spot the anomaly.** (1) **Shuffle** the fragments at `_ready` (the one-line fix that makes it a puzzle at all). (2) Add a **de-static step**: each frame is snowy; a quick input clears it to reveal its image. (3) Order frames by **visual continuity** (a figure crossing the frames). (4) The twist: **one anomalous frame** (the "second signal") keeps trying to insert itself out of place — the player must recognize and seat the anomaly correctly. Ordering + spot-the-difference; reuses the existing ordering UI + shuffle + one anomaly flag.
- **Story:** the tape proves "the door did not record a *customer*." The anomaly the player keeps finding **is** 04 — two signals, one door.
- **Dialogue:** *Lore* — Mr. Byte: "Sequence now describes a route. It does not yet describe the cause." *Breather* — Staff Door's "procedurally rude" deadpan. *No motto here* (pure dread beat — keeps the motif from over-repeating).
- **Difficulty (coded):** frame count + shuffle entropy scale; anomaly gets subtler. Knobs: `frame_count`, `anomaly_subtlety`.
- **Visual (later):** reuse `tape_static_overlay`; **replace the flat wireframe `security_tape_background`** in the art pass.

### 2.5 Final Night Walk
- **Current:** grid maze, collect frames **in numbered order**, any wrong order **resets all** progress. Same engine as Static Service Run; harsh.
- **Problem:** twin of stage 3; punishing reset; "ordered collectible" flag is the only idea.
- **New design — memory retrace (spatial Simon).** The route 04 walked that night **flashes as a ghost-trail**, then hides; the player **reproduces it from memory**, segment by segment, each segment longer than the last. A **second ghost-signal** sometimes branches onto a *different* path — the player must follow **their own**, not the intruder's. Distinct verb (memory, not collection). Reuses the grid engine + a path-flash overlay + the new fog to hide the untraced route.
- **Story:** the literal reliving of the final night; the diverging ghost **is** the conscience beginning to separate. The most elegiac stage.
- **Dialogue:** *Lore* — Memory System: "One walked in. Two signals answered." *Breather + Motto (B)* — Mira beforehand: "You have survived every answer so far. Survive this one slowly." *`???` after.*
- **Difficulty (coded):** path length grows per segment; flash duration shrinks; intruder-branch frequency rises (Overloaded). Knobs: `path_len`, `flash_ms`, `intruder_rate`.
- **Visual (later):** ghost-trail = the memory-wisp effect; palette darkens toward the Staff Door.

### 2.6 Memory Echo
- **Current:** 3-question dialogue quiz via `ChoiceBox`; wrong = "try again." Same verb as Truth Filter.
- **Problem:** duplicates Truth Filter right before the climax.
- **New design — anchor the drifting memories.** The memory is fragmenting: short fragments of 04's past **drift across the screen**, some *true* (his real memories / the motto fragments the player collected), some *distortions* from `???`. The player **anchors the true ones** under gentle time pressure before they drift off. Where Truth Filter *sorts external records under pressure*, Memory Echo *catches internal memories that move* — a calmer, sadder, recognition game. **This is where collected motto fragments literally resurface** as the "true" anchors, pre-assembling the ending.
- **Story:** the last stabilization; 04 chooses which memories are *his*. Choosing the motto fragments here is the mechanical rehearsal for choosing them in the Staff Room.
- **Dialogue:** *Lore* — the anchored fragments are 04's own words about why he made games. *Breather* — none; this beat is quiet and held. *Motto (both):* the fragments the player anchors are the two halves.
- **Difficulty (coded):** drift speed + distractor count rise; true/false grow subtler. Knobs: `drift_speed`, `distractor_count`.
- **Visual (later):** memory-wisp + `memory_frame` motifs; **replace the flat reveal-panel tier** in the art pass — this beat feeds the climax.

### 2.7 Staff Room Reveal (keep; philosophical two-hander)
- **Current:** slideshow → ~80-line self-conflict → EndingPrompt. The best writing in the game.
- **Keep** the structure. **Direction (revised):** the climax is a **philosophical talk between the protagonist and `???` only** — **no other figure is named.** The motto surfaces as the protagonist's own self-realization (the rule he built into every cabinet; the mercy he never turned on himself), and the exchange ends on quiet finality (*"we take our turns together"* — resolving `???`'s own *"one keeps taking your turn"* motif), not outward warmth. The hopeful, explicit NPC callbacks are **reserved for post-game** (§6).
- **Visual (later):** the 8 reveal panels are the flat placeholder climax; **highest-priority art replacement.**

---

## 3. `???` Conscience interludes (tune, don't redesign)

Four short overlays already fire after Truth Filter, Circuit Soda, Lost Shift File, Final Night Walk. Keep them short and game-logic-voiced (the anti-motto). **One tuning note:** make each interlude echo the *specific* motto fragment the player just heard, but **invert** it — so `???` is heard arguing against the very wisdom the arcade is teaching. This directly sets up the Staff Room refutation.

---

## 4. Optional stages — recommended lean, distinct roster

> **This section is the "major change" flagged in Bible §8.1.** Rather than four near-identical maze reskins, here is a small set where each optional is *mechanically distinct and story-linked*. Confirm or adjust.

| Optional | Owner | Verb (distinct) | Story hook | Motto | Disposition |
|---|---|---|---|---|---|
| **Broken High Score** | Roxy | **Reflex score-repair** — the board lies (9999); hit each corrupted digit as it stabilizes to restore the *real* small score, racing Roxy's ghost. | Your old score returns but stays **nameless** — the arcade remembers your *play*, not your name. | **A** | Redesign from the 10-click stub. |
| **Prize Sort** | Pip | **Memory-order puzzle** — sort prizes by the *feeling* they belong to (wanting → returning → hiding), with a red-herring or two; Pip reacts to each. | The Blank Employee Badge is the seed of the reveal. | **B** | Expand from the 3-item sort. |
| **Staff Records Chain** | Mr. Byte / terminals | **Optional lore hunt** — read the extra system notes; no fail. | Deepens the number-before-name mystery for the curious. | — | Keep; enrich text. |
| **Closing Shift** *(repurpose ONE adventure scene)* | Gus | **Timed tidy-up score-attack** in the hub (sweep before the lights die) — a *par-time* arcade challenge, replayable. | 04's actual old job; the routine he clung to. | **B** | Repurpose `HubTicketSweep`; **retire the other three maze reskins** (`CabinetTraceRun`, `SnackServiceDash`, `PrizeShelfRun`) or fold their best layout into this one. |

**Rationale (criticism):** four mazes on one engine read as one stage played four times — the sameness you wanted to avoid. Three distinct optionals + one replayable score-attack give *more* variety for *less* content. If you'd rather keep all four as separate games, say so and I'll instead differentiate each with a unique verb (more work, more surface).

---

## 5. Difficulty curve (coded, mapped to Memory Signal)

Escalation must be real, not a UI label. The `target_minutes` config is dead and should be **wired to a visible, optional par-timer** (display-only, no fail) on the two grid stages, or removed.

| Signal phase | Stages | Coded escalation |
|---|---|---|
| **Grounded / Uneasy** (teach) | Rockbyte, Truth Filter | Rockbyte's adaptive leeway (exists); Truth Filter slow flicker, no decoys. Forgiving. |
| **Fractured** (stakes) | Circuit Soda, Lost Shift File, Static Service Run | Circuit Soda multi-round routing (exists); SSR moving hazards + shrinking fog. Real setbacks, soft. |
| **Overloaded** (peak) | Sync Door, Security Tape, Final Night Walk, Memory Echo | Sync Door reversed labels + confirm (exists); Security Tape subtler anomaly; FNW longer paths + faster flash + intruder branches; Memory Echo faster drift. |

Each redesigned stage exposes **named difficulty knobs** (listed per stage above) so tuning is data, not rewrites.

---

## 6. Motto payoff — post-game witness collection (implementation note)

**Revised:** the climax names no one (§2.7). The **collection** happens in **post-reveal roam** instead, distributed across the witness dialogues — this is also where NPC coverage the required route skipped is redeemed, and where the hopeful tone lives.

- In each NPC's `post_reveal` / `post_reveal_witness` set, ensure the character **affirms their fragment warmly and in-voice**: Mira (survive slowly), Gus (carry the fear), Vendo (kept without a label), Mr. Byte (a right answer isn't a settled one), Cabinet 07 (a win isn't a whole player); optional Roxy (a score can lie) and Pip (kindness-shaped dents) if the player met them.
- Optionally, a **closing witness beat** (e.g., a final Mira line once the player has spoken to the others) states the motto in full and hopefully — the warm mirror of the climax's cold self-realization.
- **No conditional build needed in `StaffRoom.gd`** — the payoff is distributed across post-game dialogue the player opts into.

---

## 7. Build order (once approved)

1. **Dialogue single-source cleanup** — strip `completion_dialogue` from `quests.json`; reconcile `QuestRegistry.gd` fallbacks; fix memory-signal values to Bible §5. *(No new content; removes drift.)*
2. **Story pass (data only)** — seed foreshadowing + motto fragments + breather beats across `data/dialogue/*.json`; re-voice instruction stubs; textured pre-reveal Player lines. *(Ships player-visible story improvement with zero engine risk.)*
3. **Framework capabilities** — add moving-hazard + fog to `ArcadeAdventureStage`; confirm staged-presentation adoption points.
4. **Stage redesigns** — in route order: Security Tape (shuffle, cheapest win) → Truth Filter → Static Service Run → Final Night Walk → Memory Echo → Lost Shift File deduction → optionals.
5. **Post-game payoff** — affirm each fragment warmly in the post-reveal witness dialogues (not the climax).
6. **Art pass** — deferred to the visual phase (replace flat placeholders: reveal panels, security-tape/rockbyte backgrounds; per-stage visual notes above).
