# The Last Token — Story Finalization (Locked)

> **Status:** This document records the finalized story/pacing direction agreed on 2026-07-04. It **amends** [`DESIGN_BIBLE.md`](DESIGN_BIBLE.md) and [`STAGE_DESIGN.md`](STAGE_DESIGN.md); where it disagrees with them, **this wins**. The Bible's Truth (§2), Motto (§3), tone rule (§2.1), and dialogue rules (§6) are unchanged and still canon.
>
> **Doc-vs-code caution:** the planning docs run slightly ahead of the shipped code. Verify every "current state" claim against the source before acting (e.g. STAGE_DESIGN §2.4 calls Security Tape "pre-solved," but `SecurityTapeAssembly.gd` already shuffles). Trust the code.

---

## 1. Locked decisions (this pass)

1. **No optional cast.** Broken High Score (Roxy) and Prize Sort (Pip) are promoted to **required** beats. Every named character is on the required route.
2. **??? becomes an active opponent**, present or implied **inside** the gameplay — strongest in the two adventure stages — not just dialogue punctuation between beats.
3. **All five narrative-shape levers adopted** (§4).
4. **Stage redesigns adopted.** The two **adventure stages are the flagship** content: longest, most complex, multi-phase.
5. **Two new cast members added:** Reel (jukebox) and Coily (mascot animatronic) (§6).
6. **Runtime target raised to ~70–85 min** for the required route (was 45–60). The length *contrast* between the two big adventures and the nine tight beats is part of the pacing fix, not a regression.

---

## 2. Perception two-channel rule (still binding, applies to ALL cast incl. Reel & Coily)

Two mysteries resolve on separate channels:

- **Mystery A (identity):** the player is Employee 04. Cast + player + protagonist all learn it.
- **Mystery B (the ??? / split self):** only the protagonist uncovers it.

**Cast may sense the protagonist is *off* — distant, delayed, "not all here," changed — but must never name a second entity** ("two of you," "the second one," "two signatures," etc.). Mystery B is named **only** in: the ??? private encounters, the ambiguous evidence trail (maintenance note, restroom mirror, the tape anomaly *as unexplained evidence*), and the final Staff Room cutscene. Reel and Coily obey this too — Coily frames the tape anomaly as "a frame that doesn't belong," never as "a second you."

---

## 3. Finalized route — 13 beats

Legend: `*` promoted to required · `~` redesigned · `»` flagship adventure.

| # | Beat | Owner | Signal | ??? | Disposition / shape |
|---|---|---|---|---|---|
| 1 | Opening | Mira | Grounded | whisper (seed) | keep + seed ??? earlier; hook |
| 2 | Rockbyte Duel | Cabinet 07 · Mira | →Uneasy | — | keep; first win (Half A) |
| 3 | Broken High Score `*` | Roxy | Uneasy | — | promote + redesign (reflex score-repair) |
| 4 | Truth Filter `~` | Mr. Byte | →Fractured | #1 voice + decoy | redesign: Lie-Density sorter |
| 5 | Circuit Soda | Vendo | Fractured | #2 voice | keep mechanic; comic breather |
| 6 | Prize Sort `*` | Pip | Fractured | — | promote + expand; seeds the badge |
| 7 | Lost Shift File `~` | Gus · Mr. Byte · Mira | Fractured | #3 | redesign: deduction + **midpoint turn** + choice #1 |
| 8 | Static Service Run `~ »` | Gus · Reel | Fractured | interferes | **flagship adventure #1** |
| 9 | Maintenance Sync | Gus | →Overloaded | — | keep; mechanical peak, tone spike |
| 10 | Security Tape `~` | Coily · Staff Door | Overloaded | anomaly (evidence) | redesign: de-static + continuity + anomaly |
| 11 | Final Night Walk `~ »` | Memory · Coily · ??? | Overloaded | #4 | **flagship adventure #2** + **cost spike** |
| 12 | Memory Echo `~` | Reel | Overloaded | seizes control | redesign: anchor drifting memories + choice #2 |
| 13 | Staff Room Reveal | ??? · Player | →Restored | integrate | keep text/structure; add fragment/choice reprise |

Shape: two tall adventure steps (8, 11), a dip-and-turn at 7, a cost spike at 11, the climax at 13 — not one flat pace.

---

## 4. The five narrative-shape levers (and where they land)

1. **??? in three escalating modes** (§5): voice (1–5) → interferes inside puzzles (8, 10, 11) → seizes control (12).
2. **Midpoint turn** at beat 7 (Lost Shift File): goal flips from *escape* ("recover my identity and leave") to *confront* ("the arcade is the only thing holding my two halves together; the Staff Room means facing what I did").
3. **Two choices the ending remembers:** choice #1 at beat 7 (tell Mira what you found, or hold it); choice #2 at beat 12 (which memory fragments you anchor). Both reprised at beat 13 / post-game.
4. **Cost/spike beat** at 11: if ??? "wins" a segment, the player is pulled into a flash of the buried memory — a real setback that also hands over a shard of truth.
5. **Vary who drives:** not always "NPC → you." Beat 6/7 the protagonist initiates; beat 8 Gus comes to *him* alarmed; a waking machine pulls him elsewhere. Mix push/pull.

---

## 5. ??? three-mode escalation

- **Mode 1 — Voice (Uneasy→Fractured, beats 1–5, 7):** the existing glitch-overlay interludes; observing, needling, anti-motto. Seed a faint whisper as early as beat 1.
- **Mode 2 — Interference (Fractured→Overloaded, beats 8, 10, 11):** ??? affects the *stages*. It drains the lights in Static Service Run; it is the anomalous frame in Security Tape; it is the diverging/rewriting ghost-signal in Final Night Walk. Only in the private ??? interludes is it named ("that was me") — the cast still only senses wrongness.
- **Mode 3 — Seizes control (Overloaded, beat 12):** at Memory Echo, ??? briefly takes over as the memory destabilizes — its peak of agency, the last push before the Staff Room answers it.

Tuning note (from STAGE_DESIGN §3): each ??? interlude should echo the *specific* motto fragment the player just heard and **invert** it, so the climax has something concrete to refute.

---

## 6. New cast (added this pass)

Both obey the Bible's voice discipline and the §2 perception rule. Art/portraits deferred to the visual pass.

### Reel — the jukebox / house sound system
- **Role:** the arcade's music/ambience AI. Owns **Memory Echo** (beat 12) and scores **Static Service Run** (beat 8).
- **Voice:** warm, wistful; speaks in setlists, liner-notes, and B-sides; remembers each night by its music. Never clinical. Music = memory.
- **Motto:** Half B — "a song ends; the music doesn't."
- **Arc:** plays denial as easy-listening early; by Memory Echo it is helping 04 pick out which track is really his.
- **Why:** music-as-memory is deeply on-theme, leverages the existing music integration, and gives the cold Memory Echo a warm owner.

### Coily — the mascot animatronic
- **Role:** the arcade's old public face, powered down in the back, flickering awake as the signal overloads. Owns **Security Tape** (beat 10) and haunts **Final Night Walk** (beat 11).
- **Voice:** forced mascot cheer cracking into grief; front-of-house nostalgia; remembers the crowds and the decline. Catchphrases that curdle.
- **Motto:** Half B — the good years ended, and the joy was still real.
- **Arc:** boots up performing for a crowd that is not there; ends as a grieving witness who helps 04 look at the night.
- **Why:** warms the machine-cold Staff Corridor exactly when stakes peak; distinct from Pip (small whimsical prize vs. grand sad host).

**Ownership after additions:** Mira (frame/opening/7/pre-reveal/post), Gus (7, 8, 9 — the maintenance cluster), Mr. Byte (4, 7-support), Vendo (5), Roxy (3), Pip (6), Reel (8-score, 12), Coily (10, 11-accents), + object-voices (Cabinet 07, Staff Door, Broken Cabinet, Owner Portrait). ~1–2 stages each.

---

## 7. Flagship adventures (the quality bar)

Both multi-phase (~8–12 min), escalating, ??? as a felt opponent. Built on `ArcadeAdventureStage.gd` + the two new reusable capabilities (moving hazards, fog/reveal mask).

### 8 · Static Service Run — "wake the dead route" (Gus on comms, Reel scoring)
- **Phase 1 – Dark:** fog-masked service tunnels; flip breaker nodes, each lights its section and reveals the next stretch. (Teaches fog/light.)
- **Phase 2 – Live wires:** static discharges patrol the lit cabling on timed routes; cross on the gaps; a hit browns-out a section (soft setback, not a full reset).
- **Phase 3 – ??? interferes:** near full power, ??? cuts the lights back off behind you — the route you lit goes dark again; outrun the dark to the main breaker.
- **Finale:** hold three breakers up while ??? trips them — a hands-full timing/route problem. Power holds → the Fractured world warms a shade.
- **Coded knobs:** `hazard_speed`, `hazard_count`, `fog_radius`, `drain_rate`.

### 11 · Final Night Walk — "retrace the last night" (Memory + ??? + Coily; emotional-mechanical peak)
- **Phase 1 – Ghost-trail:** the route 04 walked flashes, then hides; reproduce it from memory, segment by segment, each longer (spatial Simon).
- **Phase 2 – The diverging signal:** a second ghost-trail branches onto wrong paths; follow yours, not the intruder's. ??? is the intruder — escalating.
- **Phase 3 – ??? rewrites memory:** it overwrites stretches of the true trail with plausible false ones; you must feel which segment is really yours. **Cost spike:** step onto ???'s trail → pulled into a flash of the buried memory (a shard of truth as the penalty) before being set back.
- **Finale – the door:** both trails converge on the Staff Door; you walk your own path through ???'s last interference. Hands straight to the reveal.
- **Coded knobs:** `path_len`, `flash_ms`, `intruder_rate`, `rewrite_rate`.

---

## 8. Runtime

Required route ~70–85 min. Two flagship adventures ~10 min each; the other nine beats stay tight (3–5 min). The deliberate long/short contrast is part of the pacing fix.

---

## 9. Build order

1. **Story/data pass (zero engine risk, ship first):** create Reel + Coily voice files; wire ??? mode escalation + inversion into the interludes; write the midpoint-turn dialogue (beat 7) + choice #1/#2 dialogue; seed the earlier ??? whisper; fragment reprise hooks. Re-voice any flat instruction stubs.
2. **Framework capabilities:** add moving-hazard + fog/reveal-mask to `ArcadeAdventureStage.gd` (generic, both adventures need them).
3. **Stage redesigns**, route order, cheapest-first: Security Tape (de-static + continuity + anomaly) → Truth Filter (Lie-Density sorter) → Lost Shift File (deduction + turn + choice) → Broken High Score → Prize Sort → **Static Service Run** → **Final Night Walk** → Memory Echo (anchor + choice + ??? seize).
4. **Scene placement** of Reel (Snack Alcove / sound system) and Coily (Staff Corridor) as interactable NPCs; wire to DialoguePool + routing.
5. **Post-game payoff:** warm fragment collection across the witness dialogues; climax reprise of the player's fragments/choices.
6. **Art pass:** deferred to the visual phase (portraits for Reel/Coily; flagship reveal panels; per-stage visual notes in STAGE_DESIGN).
