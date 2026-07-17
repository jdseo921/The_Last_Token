# THE LAST TOKEN — FULL DIALOGUE SWEEP (for external evaluation)

> Generated from the shipped game data/scripts on 2026-07-06. This file is self-contained:
> it holds the intended story design, the timing/trigger model, and **every player-facing
> line in the game** with the conditions under which it appears.

## Part 0 — Instructions for the evaluating AI

You are auditing the complete dialogue of **The Last Token**, a ~70-85 minute top-down
retro-arcade mystery (Godot, 640x440, dialogue shown in a small letterboxed box, so lines
must stay short). Parts 1-2 define the intended design; Part 3 defines how/when lines
trigger; Part 4 is the complete inventory. Evaluate the inventory **against the intent**,
not against generic writing taste.

**Deliver findings in this format, ordered by severity:**
- `[BLOCKER]` breaks a hard rule (two-channel rule violation, twist leak, protected-anchor
  contradiction) — quote the line, name its section, explain the break.
- `[VOICE]` a line out of character — quote it, name the character rule it breaks, propose
  a rewrite **in that character's voice**.
- `[CONTINUITY]` factual/timeline contradiction between lines — quote both sides.
- `[PACING]` tone wrong for its Memory Signal phase / beat position, redundant repeats,
  comedy undercutting a peak, or a motto-fragment drumbeat.
- `[CRAFT]` weak lines: flat instruction stubs, overlong lines for a small dialogue box
  (target <= ~110 chars per line), tic overuse (e.g. Vendo's "X but really Y"), filler.
- `[MISSED]` a setup with no payoff, a payoff with no setup, or a beat whose intended
  purpose (per the beat table) its dialogue fails to deliver.

**Hard rules to police (details in Part 1):**
1. **Two-channel rule:** NO cast line may name a second entity/self/dual signal. Cast may
   only sense the protagonist is "off." Mystery B lives ONLY in: the four ??? interludes,
   the ambiguous evidence trail (maintenance note, restroom mirror, tape anomaly as
   unexplained evidence), hallway whispers, and the Staff Room finale.
2. **Protected anchors:** the motto ("Reality is not a game...") and the final Staff Room
   Player<->??? cutscene are canon. Flag issues, but propose only additive changes there.
3. **??? is the anti-motto:** every ??? line should sound like a game that believes the
   scoreboard is real, and ideally inverts the motto fragment the player just heard.
4. **Machine voices stay machines; humans stay human.** ALL-CAPS status formatting is a
   machine-mode marker, not decoration.
5. Pre-reveal protagonist is thin on purpose (a few half-memory textures); his full voice
   unlocks only in the Staff Room.

**Also score these dimensions 1-10 with one paragraph each:** voice consistency; mystery
management (clue gradient fair, no leaks); escalation curve across signal phases; comedy/
breather placement; guidance clarity (quest text tells the player exactly where/what
without breaking tone); motto discipline (seeded, inverted, realized, collected — never a
drumbeat); line-level craft.



---

## Part 1 — Intended story (the locked spec, embedded verbatim)


### 1A. From DESIGN_BIBLE.md (canon)


### Bible 1. Premise

Pixel Haven is a shuttered retro arcade. A lone figure wakes on its dark floor with no memory of who they are or why the machines seem to *recognize* them. Mira, still at the ticket counter, greets them like someone returning — not arriving. To leave, the player must recover a Lost Token, satisfy the arcade's half-broken machines, and earn their way into the locked Staff Room, where the arcade has been keeping the one memory it could not bring itself to show them.

It is a top-down narrative mystery built from small arcade stages. No combat. No inventory. The verbs are **walk, talk, play, remember.**

---

### Bible 2. The Truth (canonical spoiler)

The player **is** Employee 04 — the arcade's game-maker and late-shift caretaker. Pixel Haven was dying: debt, dwindling staff, machines nobody came to play. On the final night, 04 came in alone to shut it down.

The decision broke him. He had spent his life building games as *"somewhere kinder to go"* for tired, lonely, frightened people — and told everyone the same thing he could not do himself: **that a single loss is not the end.** In the grief of that final night, he treated one loss as game over.

The machines panicked and did the only thing machines can do: they saved what they could. They preserved *everyone's* memory of Employee 04 — Mira's, Gus's, the cabinets' — and sealed away only his memory of *himself*, so he could wake as someone lighter. His regret, given nowhere else to go, personified itself as **`???` / "Player"** — a conscience that thinks in the same game-logic that undid him, and that buried the memory to protect him from carrying it.

The game is 04 walking back to that truth and choosing the ending the machines couldn't choose for him: **not to defeat the regret, but to carry it.** *"I do not become whole by defeating you. I become whole by carrying you with me."*

### Bible 2.1 Tone rule for the dark past — **implied, poetic, hopeful** (locked)

The nature of 04's fall is conveyed **only** through metaphor and gap, never stated outright:

- **Approved vocabulary:** "game over," "your turn to stay alive through the hardship," "one loss," "the buried memory," "two signals / one door," "one entered, one stayed," "the second signature," "a score with no name."
- **Never** literal descriptions of self-harm. The weight is real but the register stays elegiac, not graphic.
- **The arc bends toward light.** Every dark beat resolves toward reintegration. The final emotional note is relief and permission — *"Let them remember you"* — not despair. This is a story about a loss survived, delivered by someone who once believed it couldn't be.

If a line ever makes the dark past *explicit* or *hopeless*, it is wrong for this game.

---

### Bible 3. Theme & The Motto

### Bible 3.1 The Motto (the spine of the whole game)

> **"Reality is not a game. A single win does not mean you are set for life. A single loss does not mean it is all over."**

- **Half A — "a win is not everything."** Guards against defining yourself by a score, a victory, a single good outcome. Owned by the arcade's *competitive* surfaces (Roxy, high scores, Cabinet 07's hollow "TOKEN RECOVERED / IDENTITY STILL MISALIGNED").
- **Half B — "a loss is not the end."** The hopeful core, and the half tied directly to 04's fall. Owned by the arcade's *tender* surfaces (Mira, Gus, Pip, the Broken Cabinet).

04 built this philosophy *into the games themselves* — which is why the machines still "remember" it even when 04 does not. Fragments of the motto echo out of cabinets and staff like muscle memory.

### Bible 3.2 `???` is the anti-motto

The conscience/antagonist thinks in pure game-logic — keeping score, taking turns, win/lose absolutes — **because that is exactly the thinking that undid 04.** `???` is not evil; it is 04's own "it's over" reflex wearing his face. Every `???` line should sound like a game that believes the scoreboard is real. The Staff Room is where 04 finally *answers* it.

### Bible 3.3 Delivery — seed throughout, **realize in the climax, collect in post-game**

The motto is planted as **fragments across many (not all) stages and NPCs**, each in that character's own voice. It then pays off in **two separate movements**:

- **Climax (Staff Room) — philosophical, internal, final.** The self-conflict between the protagonist and `???` is a two-hander with **no other figure named** — it cannot afford to turn outward without losing its finality. The motto surfaces here not as a list of what others said, but as the protagonist's own hard **self-realization**: the rule he wrote into every cabinet, the mercy he extended to everyone but himself. Tone is contemplative and final, not warm.
- **Post-game (post-reveal roam) — warm, outward, hopeful.** The *collection* happens here. Talking to the witnesses after the reveal gathers the fragments back — each NPC affirms their piece of the motto and remembers 04 in their own voice. This is where the explicit callbacks and the hopeful landing live, and where any NPC coverage the required route skipped is **redeemed**.
- **Not every stage carries a fragment** — some are pure breather or pure lore, so the motif never becomes a drumbeat. Fragments are often framed as "something the old owner built into the games," which is quietly true.

### Bible 3.4 Motto Distribution Map

| Carrier | Stage / moment | Half | The seed (paraphrase — write in their voice) |
|---|---|---|---|
| **Cabinet 07** | after Rockbyte Duel | A | A win recovered the token, not you. "MATCH FOUND. IDENTITY: STILL MISSING." |
| **Roxy** *(optional)* | Broken High Score | A | "A scoreboard screaming 9999 is overcompensating." A high score can lie; the number was never the point. |
| **Mr. Byte** | after Truth Filter | A | A correct sort lowers lie-density but "identity conflict remains." Right answers don't fix everything. |
| **Vendo** | after Circuit Soda | B | Unlabeled product, and the machine kept you anyway. "Most machines reject unlabeled product. This one did not." |
| **Gus** | Lost Shift File / Static Service Run | B | "Routine work is easier to carry than fear." He came back scared and did the job — you survive a hard night by continuing. |
| **Broken Cabinet** | ambient, escalating | B | "I remember your first quarter. You looked happier then. Not better. Just earlier." Loss and time, held gently. |
| **Pip** *(optional)* | Prize Sort | B | "Original things can be gone and still leave kindness-shaped dents." Being lost isn't the end of what you meant. |
| **Mira** | pre-Staff-Room | B | "You have survived every answer so far. Survive this one slowly." Losing is survivable. |
| **`???`** | all encounters | *anti* | The scoreboard is real; one input decides everything. (The voice the climax refutes.) |
| **"Player" ↔ `???`** | Staff Room (climax) | **both** | The motto as **self-realization** — stated, refuted, chosen. **No other figure named.** |
| *(the witnesses)* | Post-reveal roam | **both** | The **warm collection** — each NPC affirms their fragment; hopeful callbacks land here, not in the climax. |

---

### Bible 4. Characters & Voice

Keep every established register. New/expanded lines must sound like more of the *same* character, never generic.

| Character | Role | Voice (do / don't) | Motto role | Arc across the game |
|---|---|---|---|---|
| **Mira** | Ticket counter; emotional anchor | Gentle, sad, speaks in the arcade's own metaphors ("the door had forgotten you"). Never jokey. | Half B, the tender frame | Only one who *chooses* to wait; guides 04 in and, at the end, gets to "remember you gently." |
| **Gus** | Maintenance; quiet fear under deadpan | Dry, specific, funny-bleak ("schedule like a ransom note"). Feelings admitted sideways. | Half B, "carry the fear and work anyway" | From "You again. Great." to "I do not want to clean around another absence." |
| **Vendo** | Vending-machine AI | Commercial-speak as emotional deflection ("beverage or a coping mechanism"). **Vary the "X but really Y" joke** — it's a tic if overused. | Half B, "kept without a label" | Sells denial early; quietly sincere by the reveal. |
| **Mr. Byte** | Cabinet Row diagnostic system | Cold, clinical; treats feeling as error ("Emotion detected: confusion. Classification: corrupted input."). ALL-CAPS status where machine-mode. | Half A, "right answer ≠ resolution" | Denial → "Conflict thread archived. No further denial required." |
| **Cabinet 07** | The Lost Token machine | Machine status readouts, escalating from cold to eerily personal. | Half A | Recognizes 04's "signal" before 04 does. |
| **Pip** | Plush prize *(optional NPC)* | Whimsical-eerie, childlike, unsettlingly perceptive ("filled with cotton and confidential information"). | Half B, softest foreshadow | Knows more than a toy should; kind about it. |
| **Roxy** | Competitive regular *(optional NPC)* | Trash-talk, scoreboard-brained, grudging respect. | Half A, the clearest "a win isn't the story" | Respects 04 for *coming back*, not for winning. |
| **Staff Door** | Gatekeeper machine | Escalating lock readouts; "procedurally rude." | — | Denies, then "ACCESS GRANTED. EMPLOYEE SIGNAL ACCEPTED." |
| **`???` / "Player"** | The conscience/regret | Game-logic made flesh; terse, ominous, keeps score. Same font as Player, distinguished by scan-jitter/flicker. | The anti-motto | 04's buried "it's over" reflex; integrated, not slain. |
| **Player / Employee 04** | Protagonist | **Thin on purpose pre-reveal** — but give 2–3 lines of *specific* half-memory texture so he isn't a blank. Full, articulate voice unlocks at the Staff Room. | Collects & lives the motto | Amnesiac → whole. |

**Player-voice note:** the strongest pre-reveal Player line already exists as a fallback in `ArcadeHub.gd` — *"I know this place, but I do not know why. Do you know me?"* — and is better than the JSON's bare *"Do I know you?"*. Propagate the textured versions into the JSON.

---

### Bible 5. Memory Signal System (canonical mapping)

The Memory Signal is the game's mood/progress dial. It drives environment and machine dialogue tone (every environment object has `_grounded/_uneasy/_fractured/_overloaded/_restored` sets). **Fix the current doc/data disagreements to exactly this table:**

| State | Set when | Meaning | Tone of the world |
|---|---|---|---|
| **Grounded** | Intro / story start | The arcade is just a dead building. | Dusty, quiet, ordinary. |
| **Uneasy** | Rockbyte Duel complete (Lost Token recovered) | The machines start recognizing him. | Small wrongnesses; tickets twitch. |
| **Fractured** | Truth Filter complete | Contradictory memories are active and fighting. | Reflections double; records argue. Holds through Circuit Soda, Lost Shift File, Static Service Run. |
| **Overloaded** | Maintenance Sync complete (Staff Corridor unlocks) | Too much signal; the truth is close and loud. | Machines bleed memory; "STOP PRESSING E. I AM TRYING TO REMEMBER." Holds through Security Tape, Final Night Walk, Memory Echo. |
| **Restored** | Staff Room reveal + ending seen | The loop closes; the arcade stops arguing with itself. | Quiet, honest. "It no longer tries to sell you proof." |

Difficulty escalates *with* this dial and must be expressed **in code**, not just as a label — see [`STAGE_DESIGN.md` §5](STAGE_DESIGN.md).

---

### Bible 6. Dialogue Rules (apply to every line written)

1. **Single source of truth.** All spoken content lives in `data/dialogue/*.json`. `data/quests.json` must hold **no** `completion_dialogue` (it is currently triplicated with the JSON pool and `QuestRegistry.gd`, and has already drifted — e.g. the Circuit Soda "receipt" line). `QuestRegistry.gd` inline fallbacks stay only as a **safe subset** so missing JSON degrades gracefully. Edit dialogue in one place.
2. **"Longer" means more one-sentence lines, never longer single lines.** The dialogue box reveals a line char-by-char and does **not** paginate within a line — a long line overflows the panel. Every line stays one sentence / one beat. (This is already the house style; keep it.)
3. **Breather cadence.** Every heavy or mystery beat is followed by a **lighter beat that still plants a seed** — a joke that foreshadows, a small kindness that implies the dark past. Breather ≠ filler; it earns its place by carrying a fragment or a mood. Placement is specified per stage in `STAGE_DESIGN.md`.
4. **Machine speak stays terse & ALL-CAPS** (`cabinet_07`, `staff_door`, terminals). Their terseness *is* the retro atmosphere — do not "improve" it into prose. Expansion effort goes to the humans and to the once-per-stage lore/breather beats.
5. **Re-voice, don't just lengthen, the flat instruction stubs.** e.g. Mira's *"Go to the cabinet row. / Bring the token back to me."* → keep the directive, add her register. These terse imperatives are the clearest "better read" wins.
6. **Every stage carries a lore beat and a breather beat.** (Your core request.) Lore = one detail about 04 or Pixel Haven that either advances the plot *or* deepens it; breather = one lighter exchange. Neither should bloat runtime — 2–5 short lines each. Specified per stage.

---


### 1B. From STORY_FINALIZATION.md (locked amendments — where they disagree, this wins)


### Spec 1. Locked decisions (this pass)

1. **No optional cast.** Broken High Score (Roxy) and Prize Sort (Pip) are promoted to **required** beats. Every named character is on the required route.
2. **??? becomes an active opponent**, present or implied **inside** the gameplay — strongest in the two adventure stages — not just dialogue punctuation between beats.
3. **All five narrative-shape levers adopted** (§4).
4. **Stage redesigns adopted.** The two **adventure stages are the flagship** content: longest, most complex, multi-phase.
5. **Two new cast members added:** Reel (jukebox) and Coily (mascot animatronic) (§6).
6. **Runtime target raised to ~70–85 min** for the required route (was 45–60). The length *contrast* between the two big adventures and the nine tight beats is part of the pacing fix, not a regression.

---

### Spec 2. Perception two-channel rule (still binding, applies to ALL cast incl. Reel & Coily)

Two mysteries resolve on separate channels:

- **Mystery A (identity):** the player is Employee 04. Cast + player + protagonist all learn it.
- **Mystery B (the ??? / split self):** only the protagonist uncovers it.

**Cast may sense the protagonist is *off* — distant, delayed, "not all here," changed — but must never name a second entity** ("two of you," "the second one," "two signatures," etc.). Mystery B is named **only** in: the ??? private encounters, the ambiguous evidence trail (maintenance note, restroom mirror, the tape anomaly *as unexplained evidence*), and the final Staff Room cutscene. Reel and Coily obey this too — Coily frames the tape anomaly as "a frame that doesn't belong," never as "a second you."

---

### Spec 3. Finalized route — 13 beats

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

### Spec 4. The five narrative-shape levers (and where they land)

1. **??? in three escalating modes** (§5): voice (1–5) → interferes inside puzzles (8, 10, 11) → seizes control (12).
2. **Midpoint turn** at beat 7 (Lost Shift File): goal flips from *escape* ("recover my identity and leave") to *confront* ("the arcade is the only thing holding my two halves together; the Staff Room means facing what I did").
3. **Two choices the ending remembers:** choice #1 at beat 7 (tell Mira what you found, or hold it); choice #2 at beat 12 (which memory fragments you anchor). Both reprised at beat 13 / post-game.
4. **Cost/spike beat** at 11: if ??? "wins" a segment, the player is pulled into a flash of the buried memory — a real setback that also hands over a shard of truth.
5. **Vary who drives:** not always "NPC → you." Beat 6/7 the protagonist initiates; beat 8 Gus comes to *him* alarmed; a waking machine pulls him elsewhere. Mix push/pull.

---

### Spec 5. ??? three-mode escalation

- **Mode 1 — Voice (Uneasy→Fractured, beats 1–5, 7):** the existing glitch-overlay interludes; observing, needling, anti-motto. Seed a faint whisper as early as beat 1.
- **Mode 2 — Interference (Fractured→Overloaded, beats 8, 10, 11):** ??? affects the *stages*. It drains the lights in Static Service Run; it is the anomalous frame in Security Tape; it is the diverging/rewriting ghost-signal in Final Night Walk. Only in the private ??? interludes is it named ("that was me") — the cast still only senses wrongness.
- **Mode 3 — Seizes control (Overloaded, beat 12):** at Memory Echo, ??? briefly takes over as the memory destabilizes — its peak of agency, the last push before the Staff Room answers it.

Tuning note (from STAGE_DESIGN §3): each ??? interlude should echo the *specific* motto fragment the player just heard and **invert** it, so the climax has something concrete to refute.

---

### Spec 6. New cast (added this pass)

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

### Spec 7. Flagship adventures (the quality bar)

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

### Spec 8. Runtime

Required route ~70–85 min. Two flagship adventures ~10 min each; the other nine beats stay tight (3–5 min). The deliberate long/short contrast is part of the pacing fix.

---


---

## Part 2 — Engine timing model (how/when any line can appear)

### 2.1 The quest chain (exact engine gating)

`GameState.get_current_quest_id()` walks this chain; the active quest drives the top-right
Objective HUD, the pause-menu quest details, and the per-room RouteCue hint bar. Story beats
in [brackets] map to the 13-beat table in Part 1B.

| # | quest id | active while | [beat] |
|---|---|---|---|
| 1 | `opening_look_around` | story not started, hint monologue not seen | [1] |
| 2 | `opening_talk_to_mira` | after the auto monologue (3 NPC talks) or Mira met | [1] |
| 3 | `recover_lost_token` | Mira gave the quest, duel not won | [2] |
| 4 | `return_lost_token` | duel won, token not returned | [2] |
| 5 | `broken_high_score` | token returned, Roxy's cabinet unfixed | [3] |
| 6 | `truth_filter` | high score fixed, Truth Filter not passed | [4] |
| 7 | `circuit_soda` | Truth Filter passed | [5] |
| 8 | `prize_sort` | Circuit Soda done, Pip's sort not done | [6] |
| 9 | `lost_shift_file` | Prize Sort done; read 3 clues (checklist/schedule/note) | [7] |
| 10 | `static_service_run` | shift file assembled | [8] |
| 11 | `maintenance_sync` | Static Service Run done | [9] |
| 12 | `security_tape_assembly` | Maintenance Sync done | [10] |
| 13 | `final_night_walk` | tape assembled | [11] |
| 14 | `stabilize_memory_echo` | walk done | [12] |
| 15 | `enter_staff_room` | echo stabilized, reveal not seen | [13] |
| 16 | `finish_memory` | reveal cutscene seen | [13] |
| 17 | `talk_to_witnesses` | post-reveal roam until all witnesses heard | post-game |

### 2.2 Memory Signal phases (world-tone dial)

Set from progress, saved, never player-facing as a mechanic (it gates dialogue variants,
music tier, and ambience only):

- **GROUNDED** — start.
- **UNEASY** — Lost Token returned to Mira (beat 2 complete).
- **FRACTURED** — Truth Filter passed (beat 4 complete).
- **OVERLOADED** — Staff Corridor unlocked (after Maintenance Sync, beat 9).
- **RESTORED** — post-reveal roam (after the finale).

Environment-object pool keys carry the phase as a suffix (`*_grounded`, `*_uneasy`,
`*_fractured`, `*_overloaded`, `*_restored`); `*_locked` / `*_required` = prerequisite
gate text. When a phase-specific set is missing, the nearest earlier phase's set is shown.

### 2.3 ??? presentation escalation

The four private interludes (Part 4.2) each play once, immediately after their trigger
stage, pre-reveal only. ???'s silhouette and dialogue-portrait lighten stepwise:

| encounters seen | reveal factor | look |
|---|---|---|
| 0 (first encounter plays at this level) | 0.00 | pure black silhouette |
| 1 | 0.28 | faint form |
| 2 | 0.52 | half-lit |
| 3 | 0.74 | nearly clear |
| 4 | 0.85 | recognizable |
| Staff Room finale / post-reveal | 1.00 | fully visible — it is the player's own sprite |

??? text also types slower than everyone else (22 chars/sec vs standard) and uses
glitch/shake/silent effects marked inline in the lines.

Mode 2 (interference inside stages) and Mode 3 (seizure in Memory Echo) appear as
stage-embedded text in Part 4.5 — in-stage, ??? is never named by the cast; only the
interludes say "that was me."

### 2.4 Dialogue delivery rules the inventory relies on

- **Pool-vs-fallback:** scripts call `DialoguePool.get_lines(character, key, fallback)`.
  The JSON pool (Part 4.3) is AUTHORITATIVE when the key exists; the inline arrays you
  see in Part 4.1 code views are fallbacks for missing keys — where both exist and
  differ, judge the JSON version, and flag any fallback that is *better* than its JSON
  (worth promoting).
- `get_random_set` picks a random variant per call; `get_sequential_set` walks variants
  in order per playthrough session (not saved). `get_lines` always takes variant 1.
- One-shot lines are gated by saved flags (`npc_dialogue_counts`, `*_seen`, `*_read`,
  `*_met`) — visible in the code views as GameState assignments.
- **Guidance surfaces:** persistent top-right Objective HUD (quest title + summary),
  RouteCue bar (LOCAL/ROUTE hint per room), pause-menu quest details. Center popups are
  retired except rare completion notices.
- Auto-played sequences (no interaction needed): opening intro, the 3-NPC monologue,
  Mira's explainer, midpoint turn, ??? interludes, per-room completion anecdotes,
  the finale. Everything else is walk-up interaction.



---

## Part 3 — Beat-by-beat dialogue map (where to look in Part 4)


| [beat] | stage | primary dialogue sources |
|---|---|---|
| 1 | Opening | 4.1 ArcadeHub `_play_opening_intro`, `_maybe_play_opening_monologue`, `_handle_mira` (first meeting), explainer; pools `mira/opening_*` |
| 2 | Rockbyte Duel | 4.1 ArcadeHub `_handle_cabinet_07`; 4.5 RockbyteDuel; pools `cabinet_07/*`, `mira/lost_token_*` |
| 3 | Broken High Score | 4.1 CabinetRow `_handle_roxy`, `_handle_broken_high_score`; 4.5 BrokenHighScore; pool `roxy/*` |
| 4 | Truth Filter | 4.1 CabinetRow `_handle_mr_byte`, `_handle_truth_filter`; 4.5 TruthFilter; pool `mr_byte/*`; ??? interlude #1 (4.2) |
| 5 | Circuit Soda | 4.1 SnackAlcove; 4.5 CircuitSoda; pool `vendo/*`; ??? interlude #2 (4.2) |
| 6 | Prize Sort | 4.1 PrizeCorner; pool `pip/*` |
| 7 | Lost Shift File | 4.1 ArcadeHub/CabinetRow/MaintenanceHall clue objects + `_maybe_play_midpoint_turn`; pools `mira/lost_shift_file_dialogue`, `gus/lost_shift_file_phase`, `mr_byte/lost_shift_file_support`; ??? interlude #3 (4.2) |
| 8 | Static Service Run | 4.1 MaintenanceHall `_handle_gus`; 4.5 StaticServiceRun; pools `gus/static_*`, `reel/static_service_run_score` |
| 9 | Maintenance Sync | 4.1 MaintenanceHall; 4.5 SyncDoorPuzzle; pool `gus/maintenance_sync_*` |
| 10 | Security Tape | 4.1 StaffCorridor `_handle_security_tape`; 4.5 SecurityTapeAssembly; pools `coily/security_tape_*`, `mr_byte/security_tape_support` |
| 11 | Final Night Walk | 4.1 StaffCorridor; 4.5 FinalNightWalk; pool `coily/final_night_walk_accent`; ??? interlude #4 (4.2) |
| 12 | Memory Echo | 4.1 StaffCorridor `_handle_memory_echo`; 4.5 MemoryEcho (??? seizure); pool `reel/memory_echo_*` |
| 13 | Staff Room Reveal | 4.1 StaffRoom (employee file, terminal, finale, reprise); pool `environment_objects/employee_04_file_*` |
| post | Witness route | 4.1 all rooms' post-reveal branches; pools `*/post_reveal*`; quest `talk_to_witnesses` |
| ambient | any time | hallway whispers (4.1 HallwayMap), environment objects (4.3), side rooms, 4.4 guidance text |



---

## Part 4 — Complete dialogue inventory


> **How to read the code views:** they are filtered to control flow (`if/elif/match` =
> the exact conditions), GameState flag changes (what a line consumes/sets), and the
> dialogue itself. `DIALOGUE_POOL.get_lines("who", "key", [ ...fallback... ])` means:
> play pool key `who/key` (see 4.3); the inline lines under it are the fallback copy.


### 4.1 Room & cutscene dialogue (conditions inline)


#### `ArcadeHub.gd` — `_maybe_play_rockbyte_anecdote()`

```gdscript
func _maybe_play_rockbyte_anecdote() -> void:
	if intro_active or _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
	if GameState.consume_postgame_replay_return("rockbyte"):
		start_dialogue(_get_cabinet07_lines("post_game_replay_return", [
			{"speaker": "Cabinet 07", "text": "SESSION COMPLETE. NO TOKEN DISPENSED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "YOU PLAYED FOR NO REASON. LOG ENTRY: HEALTHY.", "portrait": PORTRAIT_CABINET_07_SCREEN},
	if not GameState.rockbyte_duel_completed or GameState.lost_token_quest_completed:
	if GameState.get_npc_dialogue_count("cabinet07_rockbyte_auto") > 0:
	GameState.increment_npc_dialogue_count("cabinet07_rockbyte_auto")
	start_dialogue(_get_cabinet07_sequential_lines("rockbyte_completion", [
		{"speaker": "Cabinet 07", "text": "TOKEN RECOVERED."},
		{"speaker": "Cabinet 07", "text": "RETURN TO MIRA."},
```

#### `ArcadeHub.gd` — `_maybe_show_controls_hint()`

```gdscript
func _maybe_show_controls_hint() -> void:
	if GameState.story_started:
	hint.text = "MOVE: WASD / Arrows    INTERACT: E    MENU: Esc"
```

#### `ArcadeHub.gd` — `_maybe_play_opening_monologue()`
*Auto inner monologue after the player talks to 3 different characters without starting the story; nudges toward Mira.*

```gdscript
func _maybe_play_opening_monologue() -> void:
	if not GameState.opening_monologue_due():
	GameState.opening_hint_monologue_seen = true
	start_dialogue([
		{"speaker": "Player", "text": "Everyone here talks like they knew me before I walked in."},
		{"speaker": "Player", "text": "And the woman at the counter keeps glancing over. Mira."},
		{"speaker": "Player", "text": "Like she has been waiting for me to walk up. I should go see what she wants."},
```

#### `ArcadeHub.gd` — `_get_objective_hint_text()`

```gdscript
func _get_objective_hint_text() -> String:
	match GameState.get_current_quest_id():
		"opening_look_around":
			return "Objective: Look around. Talk to whoever is still here."
		"opening_talk_to_mira":
			return "Objective: Talk to Mira at the ArcadeHub ticket counter."
		"recover_lost_token":
			return "Objective: Play Cabinet 07 on the ArcadeHub main floor."
		"return_lost_token":
			return "Objective: Return the Lost Token to Mira at the counter."
		"truth_filter":
			return "Objective: Cabinet Row -> Mr. Byte and Truth Filter."
		"circuit_soda":
			return "Objective: Snack Alcove -> Vendo and Circuit Soda."
		"lost_shift_file":
			if not GameState.closing_checklist_read:
				return "Objective: ArcadeHub -> read the Closing Checklist."
			if not GameState.staff_schedule_read:
				return "Objective: Cabinet Row -> read the Staff Schedule by Mr. Byte."
			if not GameState.maintenance_note_read:
				return "Objective: Maintenance Hall -> read Gus's Maintenance Note."
			return "Objective: Maintenance Hall -> tell Gus the Lost Shift File is complete."
		"static_service_run":
			return "Objective: Maintenance Hall -> Gus and Static Service Run."
		"maintenance_sync":
			return "Objective: Maintenance Hall -> Gus and Maintenance Sync."
		"staff_corridor":
			return "Objective: Maintenance Hall -> use the Staff Corridor exit."
		"security_tape_assembly":
			return "Objective: Staff Corridor -> assemble the Security Tape."
		"final_night_walk":
			return "Objective: Staff Corridor -> walk the Final Night route."
		"stabilize_memory_echo":
			return "Objective: Staff Corridor -> stabilize the Memory Echo."
		"enter_staff_room":
			return "Objective: Staff Corridor -> enter the Staff Room."
		"finish_memory":
			return "Objective: Staff Room -> finish the memory."
		"talk_to_witnesses":
			return "Objective: Talk to witnesses. Start with Mira and Cabinet 07."
	return ""
```

#### `ArcadeHub.gd` — `_play_opening_intro()`
*Cold open. Plays once on first entering the hub, before free control (`opening_intro_seen`). Beat 1.*

```gdscript
func _play_opening_intro() -> void:
	if player and player.has_method("set_control_enabled"):
	dialogue_box.start_dialogue([
		{"speaker": "Player", "text": "Pixel Haven. The name is already in my head. My own name is not."},
		{"speaker": "Player", "text": "I remember carpet patterns, machine hum, and the smell of old tickets. I do not remember walking in."},
		{"speaker": "Player", "text": "I think I used to like it here after everyone left. The quiet always felt earned."},
		{"speaker": "Player", "text": "Something is missing from my pocket. A token, maybe. Or the reason I came back."},
	GameState.mark_opening_intro_seen()
	if player and player.has_method("set_control_enabled"):
```

#### `ArcadeHub.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, player_node: Node = null) -> void:
	if GameState.opening_look_around_active() and kind in ["mira", "gus", "vendo", "mr_byte", "cabinet07", "owner_portrait", "broken_cabinet", "closing_checklist", "staff_door"]:
		GameState.register_opening_talk()
	match kind:
		"mira":
		"ticket_counter":
		"closing_checklist":
		"gus":
		"vendo":
		"mr_byte":
		"cabinet07":
		"truth_filter":
		"staff_door":
		"owner_portrait":
		"broken_cabinet":
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```

#### `ArcadeHub.gd` — `try_block_exit()`

```gdscript
func try_block_exit(transition: Node) -> bool:
	if not GameState.lost_token_quest_started or GameState.lost_token_quest_completed:
	if _dialogue_is_active():
	if not GameState.rockbyte_duel_completed:
		start_dialogue([
			{"speaker": "Player", "text": "The exit can wait."},
			{"speaker": "Player", "text": "This place recognized me before I recognized it. I want to know why."},
			{"speaker": "Player", "text": "First: win my token back from Cabinet 07."},
	else:
		start_dialogue([
			{"speaker": "Player", "text": "Not yet. Mira is waiting for this token."},
			{"speaker": "Player", "text": "If I walk out now, I will never learn what this place remembers."},
```

#### `ArcadeHub.gd` — `_get_ticket_counter_echo_lines()`

```gdscript
func _get_ticket_counter_echo_lines() -> Array:
	GameState.echo_ticket_counter_seen = true
	return _get_environment_lines("ticket_counter_fractured", [
		{"speaker": "Narrator", "text": "The ticket counter glass catches your reflection half a beat late."},
		{"speaker": "Narrator", "text": "For a moment it does not move when you move."},
		{"speaker": "Narrator", "text": "Then it catches up, like nothing happened."},
```

#### `ArcadeHub.gd` — `_get_cabinet07_echo_lines()`

```gdscript
func _get_cabinet07_echo_lines() -> Array:
	GameState.echo_cabinet07_seen = true
	return [
		{"speaker": "Cabinet 07", "text": "PREVIOUS PLAYER PROFILE FOUND.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		{"speaker": "Cabinet 07", "text": "STATUS: DAMAGED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		{"speaker": "Cabinet 07", "text": "RESTORE ATTEMPT: CONTINUING.", "portrait": PORTRAIT_CABINET_07_SCREEN},
```

#### `ArcadeHub.gd` — `_get_memory_signal_explainer_lines()`
*Auto-plays immediately after Mira's first meeting. Explains the game loop (win/fix -> arcade remembers -> Staff Room opens); the Signal is framed as just the gauge.*

```gdscript
func _get_memory_signal_explainer_lines() -> Array:
	if GameState.memory_signal_explainer_seen:
		return []
	return [
		{"speaker": "Mira", "text": "Before you go - you deserve to know what this place is asking of you."},
		{"speaker": "Mira", "text": "The machines still hold pieces of the last night. Locked scores. Jammed reels. Dead circuits."},
		{"speaker": "Mira", "text": "Every game you win back and every thing you fix, the arcade remembers a little more."},
		{"speaker": "Mira", "text": "Remember enough, and the Staff Room at the back will finally open."},
		{"speaker": "Mira", "text": "That is where the last of it is waiting."},
		{"speaker": "Mira", "text": "Start with Cabinet 07 and your token. I will point you onward from there."},
```

#### `ArcadeHub.gd` — `_handle_mira()`
*Mira at the ticket counter — the main story spine. Branches: opening/first meeting -> Lost Token handoff/repeat/return -> midpoint (tell-Mira choice) -> Overloaded pre-Staff-Room -> post-reveal witness.*

```gdscript
func _handle_mira() -> void:
	if _is_post_reveal():
		GameState.mira_post_reveal_seen = true
		GameState.mark_witness_mira_heard()
			{"speaker": "Mira", "text": "You finally remembered."},
			{"speaker": "Mira", "text": "I was worried you would choose to disappear again.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "But you are still here.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That counts for something."},
		if GameState.midpoint_told_mira:
			post_reveal_lines.append({"speaker": "Mira", "text": "You told me about the hidden shift before the door showed you the rest. That mattered more than you know."})
		else:
			post_reveal_lines.append({"speaker": "Mira", "text": "You carried the shift file to the door alone. Let it be the last thing you ever carry that way."})
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
	if _can_show_act2_echo() and not GameState.echo_ticket_counter_seen:
		start_dialogue(_get_ticket_counter_echo_lines())
	if GameState.midpoint_turn_seen and not GameState.midpoint_told_mira and GameState.lost_shift_file_completed and not GameState.staff_corridor_unlocked:
		GameState.midpoint_told_mira = true
		start_dialogue([
			{"speaker": "Player", "text": "The schedule. The checklist. The maintenance note."},
			{"speaker": "Player", "text": "There was a hidden shift on the last night. Whoever worked it never clocked out."},
			{"speaker": "Mira", "text": "...I know. I have known without letting myself know.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Thank you for walking back here to say it out loud."},
			{"speaker": "Mira", "text": "Whatever the back rooms show you next, you did not find it alone. Remember that."},
	if GameState.opening_look_around_active():
		GameState.opening_intro_seen = true
		GameState.opening_hint_monologue_seen = true
	if not GameState.lost_token_quest_started:
		GameState.mira_intro_seen = true
			{"speaker": "Mira", "text": "You made it back."},
			{"speaker": "Mira", "text": "I was starting to think the door had forgotten how to let you in."},
			{"speaker": "Player", "text": "I know this place, but I do not know why. Do you know me?"},
			{"speaker": "Mira", "text": "A little. More than you do right now, I think."},
			{"speaker": "Mira", "text": "Cabinet 07 has your Lost Token."},
			{"speaker": "Mira", "text": "Please bring it back to me."},
		start_dialogue(first_meeting_lines, Callable(self, "_on_first_meeting_finished"))
	if GameState.lost_token_quest_started and not GameState.lost_token_collected:
		start_dialogue(_get_mira_sequential_lines("lost_token_active_repeat", [
			{"speaker": "Mira", "text": "Cabinet 07 is waiting."},
			{"speaker": "Mira", "text": "It only opens for signals it almost remembers."},
			{"speaker": "Player", "text": "That sounds like a terrible way to recognize someone."},
			{"speaker": "Mira", "text": "Around here, it counts as friendly."},
	if GameState.lost_token_collected and not GameState.lost_token_quest_completed:
		start_dialogue(_get_mira_lines("lost_token_return_anecdote", [
			{"speaker": "Player", "text": "I found the Lost Token. It felt like it already belonged to me."},
			{"speaker": "Mira", "text": "You brought it back.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "That token used to be just a prize."},
			{"speaker": "Mira", "text": "Then it became proof that part of you could still return."},
			{"speaker": "Mira", "text": "The token woke something."},
			{"speaker": "Mira", "text": "Start in Cabinet Row. Roxy guards a score cabinet that is still lying about a record."},
			{"speaker": "Mira", "text": "Help her set it straight."},
	if GameState.lost_token_quest_completed and not GameState.broken_high_score_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_mira_lines("broken_high_score_transition", [
			{"speaker": "Mira", "text": "Cabinet Row first. Roxy's score cabinet is still lying about a record."},
			{"speaker": "Mira", "text": "Set the board straight with her. Then Mr. Byte will want a word about truth."},
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_mira_lines("truth_filter_transition", [
			{"speaker": "Mira", "text": "The token woke something."},
			{"speaker": "Mira", "text": "Now the arcade has to decide which memories are true."},
			{"speaker": "Mira", "text": "Mr. Byte can open the Truth Filter."},
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_get_mira_lines("circuit_soda_transition", [
			{"speaker": "Mira", "text": "The arcade is remembering louder now."},
			{"speaker": "Mira", "text": "Vendo says fractured things still need somewhere to flow.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Snack Alcove is the next stop."},
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed:
		start_dialogue(_get_mira_lines("lost_shift_file_dialogue", [
			{"speaker": "Mira", "text": "The records are waking up now."},
			{"speaker": "Mira", "text": "I remember locking the counter."},
			{"speaker": "Mira", "text": "But the last part is still missing.", "portrait": PORTRAIT_MIRA_WORRIED},
			{"speaker": "Mira", "text": "Gus and Mr. Byte may remember the edges."},
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		start_dialogue(_select_repeat_dialogue("mira", [
				{"speaker": "Mira", "text": "You heard the contradictions and came back anyway.", "portrait": PORTRAIT_MIRA_WORRIED},
				{"speaker": "Mira", "text": "That is good."},
				{"speaker": "Mira", "text": "That is also worrying."},
				{"speaker": "Mira", "text": "The arcade is remembering louder now."},
				{"speaker": "Mira", "text": "That means the Staff Door may finally listen."},
				{"speaker": "Mira", "text": "Go check the Staff Door."},
				{"speaker": "Mira", "text": "I will try not to look dramatically worried.", "portrait": PORTRAIT_MIRA_WORRIED},
		{"speaker": "Mira", "text": "The Staff Door used to stick even when it liked you."},
		{"speaker": "Mira", "text": "If it opens cleanly, that is probably a good sign."},
		{"speaker": "Mira", "text": "Go check the Staff Door."},
	if GameState.midpoint_told_mira:
		pre_staff_lines.append({"speaker": "Mira", "text": "And thank you for telling me what the records said. You are not walking in there carrying it alone.", "portrait": PORTRAIT_MIRA_WORRIED})
	elif GameState.midpoint_turn_seen:
		pre_staff_lines.append({"speaker": "Mira", "text": "You never did tell me what those records said. Carry it however you can. But come back.", "portrait": PORTRAIT_MIRA_WORRIED})
	start_dialogue(pre_staff_lines)
```

#### `ArcadeHub.gd` — `_get_lost_shift_completion_lines()`

```gdscript
func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "A redacted staff number was assigned to Cabinet shutdown."},
```

#### `ArcadeHub.gd` — `_show_lost_shift_complete_notice()`

```gdscript
func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"LOST SHIFT FILE COMPLETE",
			"A redacted staff number was assigned to Cabinet shutdown."
```

#### `ArcadeHub.gd` — `_maybe_play_midpoint_turn()`
*One-shot inner monologue when Lost Shift File completes (`midpoint_turn_seen`) — the midpoint turn: goal flips from escape to confront. Duplicated in CabinetRow/MaintenanceHall so it fires in whichever room the last clue was read.*

```gdscript
func _maybe_play_midpoint_turn() -> void:
	if not GameState.lost_shift_file_completed or GameState.midpoint_turn_seen:
	GameState.midpoint_turn_seen = true
	start_dialogue([
		{"speaker": "Player", "text": "Three records. One shift folded shut and never filed."},
		{"speaker": "Player", "text": "I keep telling myself I am looking for the way out of here."},
		{"speaker": "Player", "text": "But the front door was never the locked one."},
		{"speaker": "Player", "text": "Whatever stayed behind on the last night is waiting past the Staff Door."},
		{"speaker": "Player", "text": "I am done trying to leave. I want to look at it."},
		{"speaker": "Player", "text": "Mira is still at her counter. She deserves to hear what I found... or I can carry it alone and keep working."},
```

#### `ArcadeHub.gd` — `_show_witness_route_complete_notice()`

```gdscript
func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
```

#### `ArcadeHub.gd` — `_handle_ticket_counter()`

```gdscript
func _handle_ticket_counter() -> void:
	if _can_show_act2_echo() and not GameState.echo_ticket_counter_seen:
		start_dialogue(_get_ticket_counter_echo_lines())
	start_dialogue(_get_environment_state_lines("ticket_counter", [
		{"speaker": "Narrator", "text": "The ticket counter glass is dark and dusty."},
```

#### `ArcadeHub.gd` — `_handle_closing_checklist()`
*Readable object near the counter; Lost Shift File clue 1 of 3 (`closing_checklist_read`).*

```gdscript
func _handle_closing_checklist() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_state_lines("closing_checklist", [
			{"speaker": "Closing Checklist", "text": "Sweep floors."},
			{"speaker": "Closing Checklist", "text": "Count tickets."},
			{"speaker": "Closing Checklist", "text": "Lock Staff Room."},
	GameState.read_closing_checklist()
		{"speaker": "Closing Checklist", "text": "CLOSING CHECKLIST"},
		{"speaker": "Closing Checklist", "text": "Staff Door checked twice."},
		{"speaker": "Closing Checklist", "text": "Final item scratched out."},
	start_dialogue(lines, after_dialogue)
```

#### `ArcadeHub.gd` — `_handle_gus()`

```gdscript
func _handle_gus() -> void:
	if _is_post_reveal():
		GameState.gus_post_reveal_seen = true
		GameState.mark_witness_gus_heard()
			{"speaker": "Gus", "text": "About time.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "I was almost out of practical hints.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "You came back anyway. Good."},
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
	if GameState.lying_cabinets_completed and GameState.mr_byte_truth_filter_debriefed and not GameState.circuit_soda_completed and not GameState.gus_hub_checkin_truth_filter_done:
		GameState.gus_hub_checkin_truth_filter_done = true
		start_dialogue(_get_gus_lines("hub_checkin_truth_filter", [
			{"speaker": "Gus", "text": "Heard the Truth Filter howl. It only does that when it loses.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "Vendo is next. Snack Alcove. Do not tip the machine."},
	if GameState.circuit_soda_completed and GameState.prize_sort_completed and not GameState.lost_shift_file_completed and not GameState.gus_hub_checkin_prize_sort_done:
		GameState.gus_hub_checkin_prize_sort_done = true
		start_dialogue(_get_gus_lines("hub_checkin_prize_sort", [
			{"speaker": "Gus", "text": "Pip talked. Now we do this my way: paperwork.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "Checklist by the counter. Schedule in Cabinet Row. My note in the hall."},
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_gus_sequential_lines("truth_filter_active", [
			{"speaker": "Gus", "text": "Careful now."},
			{"speaker": "Gus", "text": "Once the machines start correcting memories, they get picky."},
			{"speaker": "Gus", "text": "Truth Filter cabinet is over in Cabinet Row."},
			{"speaker": "Gus", "text": "Mr. Byte is the one acting like he grades homework."},
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_get_gus_sequential_lines("circuit_soda_active", [
			{"speaker": "Gus", "text": "Signal's fractured."},
			{"speaker": "Gus", "text": "Vendo has a machine for that, because of course he does.", "portrait": PORTRAIT_GUS_ANNOYED},
			{"speaker": "Gus", "text": "Snack Alcove first."},
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		start_dialogue(_select_repeat_dialogue("gus", [
				{"speaker": "Gus", "text": "If your memories start arguing, do not pick the loudest one."},
				{"speaker": "Gus", "text": "Fractured, huh?"},
				{"speaker": "Gus", "text": "That sounds expensive to clean up."},
				{"speaker": "Gus", "text": "Staff Door time."},
				{"speaker": "Gus", "text": "Go before the hallway develops opinions.", "portrait": PORTRAIT_GUS_ANNOYED},
	if GameState.lost_token_quest_completed:
		start_dialogue(_select_repeat_dialogue("gus", [
				{"speaker": "Gus", "text": "Staff Door is humming again."},
				{"speaker": "Gus", "text": "Practical advice: do not ignore humming doors.", "portrait": PORTRAIT_GUS_ANNOYED},
				{"speaker": "Gus", "text": "Mira looks less sad. That usually means trouble upgraded to specific trouble."},
				{"speaker": "Gus", "text": "Staff Door is your specific trouble."},
				{"speaker": "Gus", "text": "Door. Staff. Go."},
				{"speaker": "Gus", "text": "I would draw arrows, but then I would have to mop around them.", "portrait": PORTRAIT_GUS_ANNOYED},
	GameState.gus_intro_seen = true
	start_dialogue(_get_gus_sequential_lines("pre_lost_token_flavor", [
		{"speaker": "Gus", "text": "You again. Great.", "portrait": PORTRAIT_GUS_ANNOYED},
		{"speaker": "Gus", "text": "I just finished cleaning up the previous session."},
		{"speaker": "Player", "text": "Previous session?"},
		{"speaker": "Gus", "text": "Arcade talk. Means I found tickets in places tickets should fear."},
```

#### `ArcadeHub.gd` — `_handle_vendo()`
*Hub-floor Vendo machine: early flavor + optional Memory Cola riddle (comedy breather with a choice box).*

```gdscript
func _handle_vendo() -> void:
	if _is_post_reveal():
		GameState.vendo_post_reveal_seen = true
		GameState.mark_witness_vendo_heard()
			{"speaker": "Vendo", "text": "Employee 04."},
			{"speaker": "Vendo", "text": "Congratulations, valued stored file."},
			{"speaker": "Vendo", "text": "Your memory has been partially restored."},
			{"speaker": "Vendo", "text": "Refunds remain impossible."},
		if GameState.conscience_final_room_seen:
				{"speaker": "Vendo", "text": "Internal conflict resolved."},
				{"speaker": "Vendo", "text": "External refund policy unchanged."},
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		GameState.vendo_intro_seen = true
		start_dialogue(_get_vendo_sequential_lines("truth_filter_active", [
			{"speaker": "Vendo", "text": "Scanner mood: uneasy."},
			{"speaker": "Vendo", "text": "Please proceed to Cabinet Row."},
			{"speaker": "Vendo", "text": "Mr. Byte handles truth with fewer bubbles."},
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		GameState.vendo_intro_seen = true
		start_dialogue(_get_vendo_sequential_lines("circuit_soda_repeat_hint", [
			{"speaker": "Vendo", "text": "Circuit Soda remains available."},
			{"speaker": "Vendo", "text": "Please report to Snack Alcove."},
			{"speaker": "Vendo", "text": "Try not to spill identity on the carpet."},
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		GameState.vendo_intro_seen = true
		start_dialogue(_get_vendo_lines("overloaded_phase", [
			{"speaker": "Vendo", "text": "Next recommendation: Staff Door."},
			{"speaker": "Vendo", "text": "Hydration status: emotionally irrelevant."},
	if GameState.vendo_memory_riddle_secret_found:
		GameState.vendo_intro_seen = true
		start_dialogue(_select_repeat_dialogue("vendo", [
				{"speaker": "Vendo", "text": "Memory Cola is sold out."},
				{"speaker": "Vendo", "text": "Mostly because you keep losing it."},
				{"speaker": "Vendo", "text": "Mira smiles like someone reading the last page first."},
				{"speaker": "Vendo", "text": "Terrible habit. Excellent customer retention."},
				{"speaker": "Vendo", "text": "Please proceed to the glowing machine with boundary issues."},
	if GameState.lost_token_quest_started:
		GameState.vendo_intro_seen = true
				{"speaker": "Vendo", "text": "Cabinet 07 does not recognize customers."},
				{"speaker": "Vendo", "text": "Only employees."},
				{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
				{"speaker": "Vendo", "text": "The missing staff member used to stand near that cabinet."},
				{"speaker": "Vendo", "text": "Or maybe I made that up for atmosphere."},
				{"speaker": "Vendo", "text": "Care for a beverage-based psychological evaluation?"},
				{"speaker": "Vendo", "text": "You have selected: delay."},
				{"speaker": "Vendo", "text": "Suggested pairing: go play Cabinet 07."},
				{"speaker": "Vendo", "text": "Cabinet 07 is still waiting."},
				{"speaker": "Vendo", "text": "Its patience is artificial. Mine is not."},
		if after_vendo.is_valid():
				{"speaker": "Vendo", "text": "Initiating beverage-based psychological evaluation."},
				{"speaker": "Vendo", "text": "Recommended product: MEMORY COLA."},
				{"speaker": "Vendo", "text": "Riddle prompt loading."},
		start_dialogue(quest_lines, after_vendo)
	GameState.vendo_intro_seen = true
	last_dialogue_repeat_count = GameState.increment_npc_dialogue_count("vendo:%s" % _get_npc_dialogue_phase())
	if last_dialogue_repeat_count <= 4:
			{"speaker": "Vendo", "text": "Welcome, valued almost-customer."},
			{"speaker": "Vendo", "text": "Please select a beverage or a coping mechanism."},
			{"speaker": "Vendo", "text": "Flavor profile: unresolved."},
	else:
			{"speaker": "Vendo", "text": "Talk to Mira before staring into vending enlightenment again."},
	if after_opening_vendo.is_valid():
			{"speaker": "Vendo", "text": "Initiating beverage-based psychological evaluation."},
			{"speaker": "Vendo", "text": "Recommended product: MEMORY COLA."},
			{"speaker": "Vendo", "text": "Riddle prompt loading."},
	start_dialogue(opening_lines, after_opening_vendo)
```

#### `ArcadeHub.gd` — `_open_vendo_memory_riddle()`

```gdscript
func _open_vendo_memory_riddle() -> void:
	if GameState.vendo_memory_riddle_secret_found:
	if choice_box and is_instance_valid(choice_box):
	if player and player.has_method("set_control_enabled"):
	if choice_box.has_signal("choice_selected"):
	if choice_box.has_signal("choice_cancelled"):
	if choice_box.has_method("open_choice"):
		choice_box.open_choice("What do you lose every time you return?", [
```

#### `ArcadeHub.gd` — `_on_vendo_riddle_choice_selected()`
*Resolution lines for the Memory Cola riddle choices.*

```gdscript
func _on_vendo_riddle_choice_selected(index: int) -> void:
	if choice_box and is_instance_valid(choice_box):
	if index == 1:
		GameState.vendo_memory_riddle_secret_found = true
		start_dialogue(_get_vendo_lines("memory_cola_correct", [
			{"speaker": "Vendo", "text": "Correct."},
			{"speaker": "Vendo", "text": "You lose memory."},
			{"speaker": "Vendo", "text": "I lose coins."},
			{"speaker": "Vendo", "text": "We all suffer in our own branded containers."},
	start_dialogue(_get_vendo_sequential_lines("memory_cola_wrong_answers", [
		{"speaker": "Vendo", "text": "Incorrect."},
		{"speaker": "Vendo", "text": "But emotionally marketable."},
		{"speaker": "Vendo", "text": "Try again after your next identity crisis."},
```

#### `ArcadeHub.gd` — `_handle_mr_byte()`
*Hub kiosk instance of Mr. Byte — early pointer toward Cabinet Row; phase flavor.*

```gdscript
func _handle_mr_byte() -> void:
	if _is_post_reveal():
		GameState.mr_byte_post_reveal_seen = true
		GameState.employee_04_file_found = true
		GameState.mark_witness_mr_byte_heard()
			{"speaker": "Mr. Byte", "text": "Employee 04."},
			{"speaker": "Mr. Byte", "text": "Identity conflict resolved."},
			{"speaker": "Mr. Byte", "text": "Emotional cache remains unstable."},
			{"speaker": "Mr. Byte", "text": "Recommended action: talk to those who remembered you."},
		if GameState.conscience_final_room_seen:
				{"speaker": "Mr. Byte", "text": "Conscience echo archived."},
				{"speaker": "Mr. Byte", "text": "Identity conflict no longer denying itself."},
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
	if GameState.lost_token_quest_completed and not GameState.broken_high_score_completed and not GameState.lying_cabinets_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_get_mr_byte_lines("pre_roxy_redirect", [
			{"speaker": "Mr. Byte", "text": "Sequencing error detected."},
			{"speaker": "Mr. Byte", "text": "Resolve Roxy's score cabinet in Cabinet Row first."},
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		GameState.mr_byte_intro_seen = true
		GameState.truth_filter_quest_started = true
		GameState.increment_npc_dialogue_count("mr_byte_tf_explained")
		start_dialogue(_get_mr_byte_sequential_lines("truth_filter_intro", [
			{"speaker": "Mr. Byte", "text": "Ambient reading: uneasy."},
			{"speaker": "Mr. Byte", "text": "Recommended action: proceed to Cabinet Row."},
			{"speaker": "Mr. Byte", "text": "Truth Filter interface required."},
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_get_mr_byte_lines("truth_filter_completion_anecdote", [
			{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
			{"speaker": "Mr. Byte", "text": "Fractured signal requires route stabilization."},
			{"speaker": "Mr. Byte", "text": "Proceed to Snack Alcove."},
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_get_mr_byte_sequential_lines("lost_shift_file_support", [
			{"speaker": "Mr. Byte", "text": "Lost Shift File access opened."},
			{"speaker": "Mr. Byte", "text": "Read available staff records."},
			{"speaker": "Mr. Byte", "text": "Name field remains protected."},
	if GameState.maintenance_sync_completed and not GameState.security_tape_assembly_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_get_mr_byte_sequential_lines("security_tape_support", [
			{"speaker": "Mr. Byte", "text": "Security tape fragments detected."},
			{"speaker": "Mr. Byte", "text": "Recommended action: Security Tape Assembly."},
	if GameState.lying_cabinets_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_intro_seen = true
		start_dialogue(_get_mr_byte_lines("staff_records_chain", [
			{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
			{"speaker": "Mr. Byte", "text": "Warning: restored subjects may now notice missing pieces."},
			{"speaker": "Mr. Byte", "text": "Check Staff Door."},
	GameState.mr_byte_intro_seen = true
	start_dialogue(_get_mr_byte_sequential_lines("pre_truth_filter_locked", [
		{"speaker": "Mr. Byte", "text": "TRUTH FILTER LOCKED."},
		{"speaker": "Mr. Byte", "text": "Memory signal below readable threshold."},
		{"speaker": "Mr. Byte", "text": "Recovered token required."},
```

#### `ArcadeHub.gd` — `_handle_cabinet_07()`
*Cabinet 07 on the hub floor. Starts/repeats the Rockbyte Duel (beat 2); phase echo lines afterward.*

```gdscript
func _handle_cabinet_07() -> void:
	if _is_post_reveal() and GameState.witness_cabinet07_heard:
		start_dialogue(_get_cabinet07_lines("post_game_replay_offer", [
			{"speaker": "Cabinet 07", "text": "EMPLOYEE 04 DETECTED AT CABINET.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "REMATCH AVAILABLE. STAKES: NONE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
	if _is_post_reveal():
		GameState.mark_witness_cabinet07_heard()
			{"speaker": "Cabinet 07", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "WELCOME BACK, EMPLOYEE 04.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "PREVIOUS SESSION: CLOSED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
			{"speaker": "Cabinet 07", "text": "CURRENT SESSION: YOURS.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		if GameState.conscience_final_room_seen:
				{"speaker": "Cabinet 07", "text": "PLAYER SIGNAL ACCEPTED.", "portrait": PORTRAIT_CABINET_07_SCREEN},
				{"speaker": "Cabinet 07", "text": "REGRET COMPONENT: STABLE.", "portrait": PORTRAIT_CABINET_07_SCREEN},
		start_dialogue(post_reveal_lines, _get_witness_completion_callback(was_completed))
	if not GameState.lost_token_quest_started:
		GameState.cabinet07_employee_hint_seen = true
			{"speaker": "Cabinet 07", "text": "CUSTOMER SIGNAL: UNKNOWN."},
			{"speaker": "Cabinet 07", "text": "EMPLOYEE SIGNAL: PARTIAL."},
			{"speaker": "Cabinet 07", "text": "LOST TOKEN REQUIRED."},
		cabinet_lines.append({"speaker": "Player", "text": "It wants a token I do not have. The attendant at the counter keeps glancing over. She might know why."})
		start_dialogue(cabinet_lines)
	if not GameState.rockbyte_duel_completed:
	if GameState.rockbyte_duel_completed and not GameState.lost_token_quest_completed:
		start_dialogue(_get_cabinet07_sequential_lines("rockbyte_completion", [
			{"speaker": "Cabinet 07", "text": "TOKEN RECOVERED."},
			{"speaker": "Cabinet 07", "text": "RETURN TO MIRA."},
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_cabinet07_sequential_lines("truth_filter_phase_echo", [
			{"speaker": "Cabinet 07", "text": "TOKEN RETURNED."},
			{"speaker": "Cabinet 07", "text": "SIGNAL STATUS: UNEASY."},
			{"speaker": "Cabinet 07", "text": "TRUTH FILTER REQUIRED."},
		{"speaker": "Cabinet 07", "text": "CABINET STATUS: RESTLESS."},
		{"speaker": "Cabinet 07", "text": "STAFF DOOR TARGET READY."},
		{"speaker": "Cabinet 07", "text": "CHECK STAFF DOOR."},
	if _can_show_act2_echo() and not GameState.echo_cabinet07_seen:
	start_dialogue(cabinet_lines)
```

#### `ArcadeHub.gd` — `_handle_truth_filter()`
*Hub-floor Truth Filter cabinet — locked/pointer lines (the playable one is in Cabinet Row).*

```gdscript
func _handle_truth_filter() -> void:
	if not GameState.lost_token_quest_completed:
		start_dialogue(_get_environment_lines("truth_filter_machine_grounded", [
			{"speaker": "Truth Filter", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Truth Filter", "text": "LOST TOKEN REQUIRED."},
	if GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_state_lines("truth_filter_machine", [
			{"speaker": "Truth Filter", "text": "TRUTH FILTER PASSED."},
			{"speaker": "Truth Filter", "text": "RECORDS RECONCILED."},
	GameState.set_pending_spawn_id("Spawn_FromArcadeHub")
	start_dialogue(_get_environment_lines("truth_filter_machine_uneasy", [
		{"speaker": "Truth Filter", "text": "CONTRADICTION THRESHOLD REACHED."},
		{"speaker": "Truth Filter", "text": "SORT FALSE RECORDS."},
```

#### `ArcadeHub.gd` — `_handle_staff_door()`
*The Staff Door — escalating lock readouts keyed to progress; the game's central gate.*

```gdscript
func _handle_staff_door() -> void:
	if _is_post_reveal():
		start_dialogue(_get_staff_door_lines("post_reveal_stable", [
			{"speaker": "Staff Door", "text": "RESTORE PLAYBACK COMPLETE."},
			{"speaker": "Staff Door", "text": "RETURN NOT REQUIRED."},
	if GameState.staff_room_unlocked:
		start_dialogue(_get_staff_door_lines("staff_room_available", [
			{"speaker": "Staff Door", "text": "ACCESS GRANTED."},
			{"speaker": "Staff Door", "text": "EMPLOYEE SIGNAL ACCEPTED."},
			{"speaker": "Staff Door", "text": "ENTER STAFF ROOM?"},
	if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
		start_dialogue(_get_staff_door_lines("maintenance_required", [
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "CIRCUIT SODA ROUTE REQUIRED."},
			{"speaker": "Staff Door", "text": "FRACTURED SIGNAL UNSTABILIZED."},
	if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_staff_door_sequential_lines("truth_filter_required", [
			{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Door", "text": "TRUTH FILTER REQUIRED."},
			{"speaker": "Staff Door", "text": "EMPLOYEE SIGNAL UNSTABLE."},
	if GameState.lost_token_quest_completed and GameState.rockbyte_duel_completed and GameState.lying_cabinets_completed and GameState.circuit_soda_completed:
		start_dialogue(_get_staff_door_sequential_lines("maintenance_required", [
			{"speaker": "Staff Door", "text": "FRACTURED SIGNAL ACCEPTED."},
			{"speaker": "Staff Door", "text": "MAINTENANCE SYNC REQUIRED."},
			{"speaker": "Staff Door", "text": "GUS AUTHORIZATION REQUIRED."},
	start_dialogue(_get_staff_door_sequential_lines("locked_grounded", [
		{"speaker": "Staff Door", "text": "STAFF ACCESS LOCKED."},
		{"speaker": "Staff Door", "text": "MEMORY TOKEN SIGNAL MISSING."},
```

#### `ArcadeHub.gd` — `_handle_owner_portrait()`
*Ambient lore object, phase-gated variants.*

```gdscript
func _handle_owner_portrait() -> void:
	if _is_post_reveal():
		GameState.owner_portrait_secret_found = true
		start_dialogue(_get_environment_lines("owner_portrait_restored", [
			{"speaker": "Owner Portrait", "text": "The scratched nameplate is readable now."},
			{"speaker": "Owner Portrait", "text": "It does not name the owner."},
			{"speaker": "Owner Portrait", "text": "It says: EMPLOYEE 04."},
	if _can_show_act2_echo():
		GameState.echo_owner_portrait_04_seen = true
		start_dialogue(_get_environment_lines("owner_portrait_fractured", [
			{"speaker": "Owner Portrait", "text": "The scratches on the nameplate have shifted."},
			{"speaker": "Owner Portrait", "text": "Only two marks are readable."},
			{"speaker": "Owner Portrait", "text": "0 4"},
	start_dialogue(_get_environment_state_lines("owner_portrait", [
		{"speaker": "Owner Portrait", "text": "The frame is cracked and the nameplate is scratched blank."},
```

#### `ArcadeHub.gd` — `_handle_broken_cabinet()`
*Ambient lore object (Half B motto carrier), phase-gated variants.*

```gdscript
func _handle_broken_cabinet(interactable: Node) -> void:
	if _is_post_reveal():
		start_dialogue(_get_environment_lines("broken_cabinet_restored", [
			{"speaker": "Broken Cabinet", "text": "I remember your first quarter."},
			{"speaker": "Broken Cabinet", "text": "You looked happier then."},
			{"speaker": "Broken Cabinet", "text": "Not better. Just earlier."},
	if interactable.broken_interaction_count >= 5:
		GameState.broken_cabinet_secret_found = true
		start_dialogue(_get_environment_lines("broken_cabinet_overloaded", [
			{"speaker": "Broken Cabinet", "text": "STOP PRESSING E. I AM TRYING TO REMEMBER."},
	if interactable.broken_interaction_count == 3:
		start_dialogue(_get_environment_lines("broken_cabinet_fractured", [
			{"speaker": "Broken Cabinet", "text": "STILL OUT OF ORDER."},
	start_dialogue(_get_environment_state_lines("broken_cabinet", [
		{"speaker": "Broken Cabinet", "text": "OUT OF ORDER."},
```

#### `ArcadeHub.gd` — `_offer_rockbyte_replay()`

```gdscript
func _offer_rockbyte_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Play the duel again?", "rockbyte", Callable(self, "_launch_rockbyte_replay"))
```


#### `CabinetRow.gd` — `_maybe_play_completion_anecdote()`
*AUTO on re-entering the room after finishing its game (queued after the ??? encounter if one fires): the associated cast reacts once (Mr. Byte after Truth Filter, Roxy after Broken High Score).*

```gdscript
func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
	if GameState.consume_postgame_replay_return("truth_filter"):
		start_dialogue(_get_environment_lines("truth_filter_machine_replay_return", [
			{"speaker": "Truth Filter", "text": "SORT COMPLETE. LIE DENSITY: ZERO."},
			{"speaker": "Truth Filter", "text": "THEY ARGUE ANYWAY. IT KEEPS THEM WARM."},
	if GameState.consume_postgame_replay_return("broken_high_score"):
		start_dialogue(_get_roxy_lines("broken_high_score_replay_return", [
			{"speaker": "Roxy", "text": "Zero stakes and you still played like rent was due."},
			{"speaker": "Roxy", "text": "That is exactly why it looks good on you."},
	if GameState.lying_cabinets_completed and not GameState.roxy_truth_filter_nudge_seen:
		GameState.roxy_truth_filter_nudge_seen = true
		start_dialogue(_get_roxy_lines("truth_filter_completion_nudge", [
			{"speaker": "Roxy", "text": "Huh. The Filter actually shut up for once."},
			{"speaker": "Roxy", "text": "Whatever it just coughed up, Mr. Byte is the one who files it."},
			{"speaker": "Roxy", "text": "Go make him explain it. He lives for that."},
	if GameState.broken_high_score_completed and not GameState.roxy_high_score_anecdote_seen:
		GameState.roxy_high_score_anecdote_seen = true
		start_dialogue(_get_roxy_lines("broken_high_score_completion", [
			{"speaker": "Roxy", "text": "Huh. Your score came back."},
			{"speaker": "Roxy", "text": "The points restored clean. The name stayed blank."},
```

#### `CabinetRow.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"mr_byte":
		"truth_filter":
		"cabinet_trace_adventure":
		"roxy":
		"broken_high_score":
		"staff_schedule":
		"staff_record_01":
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```

#### `CabinetRow.gd` — `_handle_mr_byte()`
*Mr. Byte in Cabinet Row: Truth Filter intro (beat 4), Lost Shift File support, staff-records chain, post-reveal witness.*

```gdscript
func _handle_mr_byte() -> void:
	GameState.mr_byte_intro_seen = true
	if _is_post_reveal():
		GameState.mr_byte_post_reveal_seen = true
		GameState.employee_04_file_found = true
		GameState.mark_witness_mr_byte_heard()
		start_dialogue(_get_mr_byte_lines("post_reveal_witness", [
			{"speaker": "Mr. Byte", "text": "Employee 04."},
			{"speaker": "Mr. Byte", "text": "Identity conflict resolved."},
			{"speaker": "Mr. Byte", "text": "Emotional cache remains unstable."},
	if not GameState.lost_token_quest_completed:
		start_dialogue(_get_mr_byte_sequential_lines("pre_truth_filter_locked", [
			{"speaker": "Mr. Byte", "text": "TRUTH FILTER LOCKED."},
			{"speaker": "Mr. Byte", "text": "SIGNAL TOO QUIET."},
	if not GameState.broken_high_score_completed and not GameState.lying_cabinets_completed:
		start_dialogue(_get_mr_byte_lines("pre_roxy_redirect", [
			{"speaker": "Mr. Byte", "text": "Sequencing error detected."},
			{"speaker": "Mr. Byte", "text": "The score cabinet is broadcasting a louder falsehood than my queue."},
			{"speaker": "Mr. Byte", "text": "Resolve Roxy's board first. Then report back for Truth Filter orientation."},
	if not GameState.lying_cabinets_completed:
		GameState.truth_filter_quest_started = true
		GameState.increment_npc_dialogue_count("mr_byte_tf_explained")
		start_dialogue(_get_mr_byte_sequential_lines("truth_filter_intro", [
			{"speaker": "Mr. Byte", "text": "Contradiction threshold reached."},
			{"speaker": "Mr. Byte", "text": "Truth Filter is ready."},
			{"speaker": "Mr. Byte", "text": "Please choose the least broken answer."},
	if not GameState.mr_byte_truth_filter_anecdote_seen:
		GameState.mr_byte_truth_filter_anecdote_seen = true
		GameState.mr_byte_truth_filter_debriefed = true
			{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
			{"speaker": "Mr. Byte", "text": "Record conflict reduced. Identity conflict remains."},
			{"speaker": "Mr. Byte", "text": "Unrelated administrative matter."},
			{"speaker": "Mr. Byte", "text": "Earlier tonight the hallway audio channel carried a broadcast. Source field: empty."},
			{"speaker": "Mr. Byte", "text": "I have filed it under ambient noise."},
		start_dialogue(debrief_lines, Callable(self, "_after_byte_debrief"))
	if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		start_dialogue(_get_mr_byte_sequential_lines("lost_shift_file_support", [
			{"speaker": "Mr. Byte", "text": "Staff schedule access: damaged but readable."},
			{"speaker": "Mr. Byte", "text": "Machines refuse the name. Records retain the assignment."},
			{"speaker": "Mr. Byte", "text": "Read the schedule near this kiosk."},
	if GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.mr_byte_lost_shift_comment_seen = true
		start_dialogue(_get_mr_byte_lines("lost_shift_file_support", [
			{"speaker": "Mr. Byte", "text": "Lost Shift File reconstructed."},
			{"speaker": "Mr. Byte", "text": "Identity reference remains restricted."},
	if GameState.maintenance_sync_completed and not GameState.security_tape_assembly_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_mr_byte_sequential_lines("security_tape_support", [
			{"speaker": "Mr. Byte", "text": "Security tape fragments detected."},
			{"speaker": "Mr. Byte", "text": "Recommended action: Security Tape Assembly."},
	start_dialogue(_get_mr_byte_lines("truth_filter_completion_anecdote", [
		{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
		{"speaker": "Mr. Byte", "text": "Identity conflict remains."},
```

#### `CabinetRow.gd` — `_handle_truth_filter()`
*Launches the Truth Filter minigame; locked before Mr. Byte's intro.*

```gdscript
func _handle_truth_filter() -> void:
	if not GameState.lost_token_quest_completed:
		start_dialogue(_get_environment_lines("truth_filter_machine_grounded", [
			{"speaker": "Truth Filter", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Truth Filter", "text": "MR. BYTE AUTHORIZATION REQUIRED."},
	if GameState.post_reveal_roam_unlocked and GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("truth_filter_machine_replay_offer", [
			{"speaker": "Truth Filter", "text": "TRUTH FILTER ONLINE. NO CONTRADICTIONS PENDING."},
			{"speaker": "Truth Filter", "text": "RECREATIONAL SORTING AVAILABLE."},
	if GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_state_lines("truth_filter_machine", [
			{"speaker": "Truth Filter", "text": "TRUTH FILTER PASSED."},
			{"speaker": "Truth Filter", "text": "RECORDS RECONCILED."},
	if GameState.get_npc_dialogue_count("mr_byte_tf_explained") == 0:
		start_dialogue([
			{"speaker": "Player", "text": "The Truth Filter hums like it is waiting for a proctor."},
			{"speaker": "Player", "text": "Mr. Byte runs this row. He should walk me in."},
	GameState.set_pending_spawn_id("Spawn_FromTruthFilter")
	start_dialogue(_get_environment_lines("truth_filter_machine_uneasy", [
		{"speaker": "Truth Filter", "text": "CONTRADICTION THRESHOLD REACHED."},
		{"speaker": "Truth Filter", "text": "SORT FALSE RECORDS."},
```

#### `CabinetRow.gd` — `_handle_cabinet_trace_adventure()`

```gdscript
func _handle_cabinet_trace_adventure() -> void:
	start_dialogue([
		{"speaker": "Idle Cabinet", "text": "This cabinet is dark. Its trace board was pulled for parts long ago."},
		{"speaker": "Idle Cabinet", "text": "One good machine on this row still runs. That was always the way here."},
```

#### `CabinetRow.gd` — `_handle_roxy()`
*Roxy: Broken High Score intro/hints/completion (beat 3, required), repeat + post-reveal.*

```gdscript
func _handle_roxy() -> void:
	GameState.roxy_met = true
	if _is_post_reveal():
		GameState.mark_witness_roxy_heard()
		start_dialogue(_get_roxy_lines("post_reveal", [
			{"speaker": "Roxy", "text": "So you were Employee 04."},
			{"speaker": "Roxy", "text": "That explains the blank high score."},
			{"speaker": "Roxy", "text": "Hard to rank a memory."},
	if not _broken_high_score_unlocked():
		start_dialogue(_get_roxy_lines("first_meeting_locked", [
			{"speaker": "Roxy", "text": "Whoa. New challenger detected."},
			{"speaker": "Roxy", "text": "Actually, no. New challenger pending."},
			{"speaker": "Roxy", "text": "Come back when the score cabinet wakes up."},
	if GameState.broken_high_score_completed:
		if not GameState.roxy_high_score_anecdote_seen:
			GameState.roxy_high_score_anecdote_seen = true
			start_dialogue(_get_roxy_lines("broken_high_score_completion", [
				{"speaker": "Roxy", "text": "Huh. Your score came back."},
				{"speaker": "Roxy", "text": "That usually does not happen after a reset."},
				{"speaker": "Roxy", "text": "Do not let it go to your head. You still walk like a tutorial."},
		start_dialogue(_get_roxy_sequential_lines("repeat_after_completion", [
			{"speaker": "Roxy", "text": "Your score came back."},
			{"speaker": "Roxy", "text": "Still weird."},
	if not was_roxy_met or GameState.get_npc_dialogue_count("roxy:broken_high_score_intro") == 0:
		GameState.increment_npc_dialogue_count("roxy:broken_high_score_intro")
		start_dialogue(_get_roxy_lines("broken_high_score_intro", [
			{"speaker": "Roxy", "text": "Finally. Player Two showed up."},
			{"speaker": "Roxy", "text": "You look like someone who loses to menus."},
			{"speaker": "Roxy", "text": "Try the Broken High Score cabinet."},
			{"speaker": "Roxy", "text": "The screen lies, but badly."},
	start_dialogue(_get_roxy_sequential_lines("broken_high_score_hint", [
		{"speaker": "Roxy", "text": "Finally. Player Two showed up."},
		{"speaker": "Roxy", "text": "Try the Broken High Score cabinet."},
		{"speaker": "Roxy", "text": "The screen lies, but badly."},
```

#### `CabinetRow.gd` — `_handle_broken_high_score()`
*The Broken High Score cabinet itself.*

```gdscript
func _handle_broken_high_score() -> void:
	if not _broken_high_score_unlocked():
		start_dialogue(_get_roxy_lines("first_meeting_locked", [
			{"speaker": "Roxy", "text": "The score cabinet is not ready yet."},
			{"speaker": "Roxy", "text": "Come back after you beat something louder."},
	if GameState.post_reveal_roam_unlocked and GameState.broken_high_score_completed:
		start_dialogue(_get_roxy_lines("broken_high_score_replay_offer", [
			{"speaker": "Roxy", "text": "Back at my cabinet, 04?"},
			{"speaker": "Roxy", "text": "Coin up or step aside."},
	if GameState.broken_high_score_completed:
		start_dialogue([
			{"speaker": "Broken High Score", "text": "PREVIOUS SCORE FOUND."},
			{"speaker": "Broken High Score", "text": "RECORD RESTORED."},
	if not GameState.roxy_met:
		start_dialogue([
			{"speaker": "Player", "text": "That score cabinet is Roxy's turf."},
			{"speaker": "Player", "text": "If I touch it before we talk, I will never hear the end of it."},
	GameState.set_pending_spawn_id("Spawn_FromBrokenHighScore")
```

#### `CabinetRow.gd` — `_handle_staff_schedule()`
*Lost Shift File clue 2 of 3 (`staff_schedule_read`).*

```gdscript
func _handle_staff_schedule() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("staff_schedule_grounded", [
			{"speaker": "Staff Schedule", "text": "The schedule screen is scrambled."},
			{"speaker": "Staff Schedule", "text": "Mr. Byte has not unlocked staff records yet."},
	GameState.read_staff_schedule()
		{"speaker": "Staff Schedule", "text": "STAFF SCHEDULE"},
		{"speaker": "Staff Schedule", "text": "Final Night"},
		{"speaker": "Staff Schedule", "text": "Mira - Counter"},
		{"speaker": "Staff Schedule", "text": "Gus - Maintenance"},
		{"speaker": "Staff Schedule", "text": "Employee ## - Cabinet shutdown"},
		{"speaker": "Staff Schedule", "text": "Status: unresolved"},
	start_dialogue(lines, after_dialogue)
```

#### `CabinetRow.gd` — `_handle_staff_record_01()`
*Optional staff-records chain 1/3 (identity evidence trail).*

```gdscript
func _handle_staff_record_01() -> void:
	if not GameState.broken_high_score_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Staff Record", "text": "The record terminal is still filtering contradictions."},
	if not GameState.lying_cabinets_completed:
		GameState.read_staff_record_01()
		start_dialogue(_get_environment_lines("staff_record_01_shift_log", [
			{"speaker": "Staff Record", "text": "SHIFT LOG - FINAL NIGHT (RECOVERED EXCERPT)"},
			{"speaker": "Staff Record", "text": "23:41 - Mira signed the register and left. Last name on the page."},
			{"speaker": "Staff Record", "text": "23:50 - Gus clocked out. Mop returned wet."},
			{"speaker": "Staff Record", "text": "00:05 - One staff member stayed to run the closing checklist alone."},
			{"speaker": "Staff Record", "text": "00:19 - Cabinet 07 kept one token in the return tray. Flagged: do not empty."},
			{"speaker": "Staff Record", "text": "00:33 - Backup started. Backup did not finish."},
			{"speaker": "Staff Record", "text": "Entry ends. No sign-out recorded for the last shift."},
	GameState.read_staff_record_01()
		{"speaker": "Staff Record", "text": "RESTORE SYSTEM NOTE"},
		{"speaker": "Staff Record", "text": "Subject memory incomplete."},
		{"speaker": "Staff Record", "text": "Do not repeat name until signal stabilizes."},
		{"speaker": "Mr. Byte", "text": "Staff record chain active."},
		{"speaker": "Mr. Byte", "text": "Names withheld until signal stabilizes."},
		{"speaker": "Mr. Byte", "text": "Additional staff records required."},
	start_dialogue(lines, after_dialogue)
```

#### `CabinetRow.gd` — `_get_lost_shift_completion_lines()`

```gdscript
func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "A redacted staff number was assigned to Cabinet shutdown."},
```

#### `CabinetRow.gd` — `_show_lost_shift_complete_notice()`

```gdscript
func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"LOST SHIFT FILE COMPLETE",
			"A redacted staff number was assigned to Cabinet shutdown."
```

#### `CabinetRow.gd` — `_maybe_play_midpoint_turn()`

```gdscript
func _maybe_play_midpoint_turn() -> void:
	if not GameState.lost_shift_file_completed or GameState.midpoint_turn_seen:
	GameState.midpoint_turn_seen = true
	start_dialogue([
		{"speaker": "Player", "text": "Three records. One shift folded shut and never filed."},
		{"speaker": "Player", "text": "I keep telling myself I am looking for the way out of here."},
		{"speaker": "Player", "text": "But the front door was never the locked one."},
		{"speaker": "Player", "text": "Whatever stayed behind on the last night is waiting past the Staff Door."},
		{"speaker": "Player", "text": "I am done trying to leave. I want to look at it."},
		{"speaker": "Player", "text": "Mira is still at her counter. She deserves to hear what I found... or I can carry it alone and keep working."},
```

#### `CabinetRow.gd` — `_get_staff_records_completion_lines()`

```gdscript
func _get_staff_records_completion_lines() -> Array:
	if not GameState.staff_records_chain_completed:
		return []
	return [
		{"speaker": "Quest", "text": "STAFF RECORDS CHAIN COMPLETE"},
		{"speaker": "Quest", "text": "The arcade knew the number before it knew the name."},
```

#### `CabinetRow.gd` — `_show_staff_records_complete_notice()`

```gdscript
func _show_staff_records_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"STAFF RECORDS CHAIN COMPLETE",
			"The arcade knew the number before it knew the name."
```

#### `CabinetRow.gd` — `_show_witness_route_complete_notice()`

```gdscript
func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
```

#### `CabinetRow.gd` — `_offer_truth_filter_replay()`

```gdscript
func _offer_truth_filter_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Run the Truth Filter again?", "truth_filter", Callable(self, "_launch_truth_filter_replay"))
```

#### `CabinetRow.gd` — `_offer_high_score_replay()`

```gdscript
func _offer_high_score_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Chase the high score again?", "broken_high_score", Callable(self, "_launch_high_score_replay"))
```

#### `CabinetRow.gd` — `_after_byte_debrief()`

```gdscript
func _after_byte_debrief() -> void:
	# ??? answers Mr. Byte's "there is no form for this" - then the protagonist
	if not ConscienceEncounterDirector.maybe_start_encounter(self, "after_truth_filter", Callable(self, "_play_byte_debrief_monologue")):
```

#### `CabinetRow.gd` — `_play_byte_debrief_monologue()`

```gdscript
func _play_byte_debrief_monologue() -> void:
	start_dialogue([
		{"speaker": "Player", "text": "Ambient noise."},
		{"speaker": "Player", "text": "That was not noise. It was talking to me. It knew what I was going to do."},
		{"speaker": "Player", "text": "A sound with no speaker, and the machine that files everything cannot file it."},
		{"speaker": "Player", "text": "That man out on the arcade floor carries a mop around like it owes him money."},
		{"speaker": "Player", "text": "A janitor, maybe. If anything has been speaking in these halls, he might have heard it."},
		{"speaker": "Player", "text": "Worth asking. I have nothing better to go on."},
```


#### `SnackAlcove.gd` — `_maybe_play_completion_anecdote()`
*AUTO after Circuit Soda completion (after the ??? encounter): Vendo's one-shot anecdote.*

```gdscript
func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
	if GameState.consume_postgame_replay_return("circuit_soda"):
		start_dialogue(_get_vendo_lines("circuit_soda_replay_return", [
			{"speaker": "Vendo", "text": "Route stable. No identity was spilled today."},
			{"speaker": "Vendo", "text": "This machine counts that as a five-star review."},
	if GameState.circuit_soda_completed and not GameState.vendo_circuit_anecdote_seen:
		GameState.vendo_circuit_anecdote_seen = true
		start_dialogue(_get_vendo_lines("circuit_soda_completion_anecdote", [
			{"speaker": "Vendo", "text": "Signal routed."},
			{"speaker": "Vendo", "text": "Most machines reject unlabeled product. This one did not."},
```

#### `SnackAlcove.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"vendo":
		"circuit_soda":
		"snack_service_adventure":
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```

#### `SnackAlcove.gd` — `_handle_vendo()`
*Vendo in Snack Alcove: Circuit Soda intro/hints (beat 5), overloaded phase, post-reveal witness.*

```gdscript
func _handle_vendo() -> void:
	GameState.vendo_intro_seen = true
	if _is_post_reveal():
		GameState.vendo_post_reveal_seen = true
		GameState.mark_witness_vendo_heard()
		start_dialogue(_get_vendo_lines("post_reveal_witness", [
			{"speaker": "Vendo", "text": "Employee 04."},
			{"speaker": "Vendo", "text": "Your memory has been partially restored."},
			{"speaker": "Vendo", "text": "Refunds remain impossible."},
	if not GameState.lying_cabinets_completed:
		start_dialogue([
			{"speaker": "Vendo", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Vendo", "text": "TRUTH FILTER REQUIRED."},
	if not GameState.mr_byte_truth_filter_debriefed and not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Vendo", "text": "One moment. The row next door says your Truth Filter report is still open."},
			{"speaker": "Vendo", "text": "Mr. Byte flags my power draw when paperwork goes missing. Go get debriefed."},
	if not GameState.circuit_soda_completed:
		GameState.start_circuit_soda()
		if circuit_soda_started:
			start_dialogue(_get_vendo_sequential_lines("circuit_soda_repeat_hint", [
				{"speaker": "Vendo", "text": "Circuit Soda remains available."},
				{"speaker": "Vendo", "text": "Route the signal through the correct channels."},
				{"speaker": "Vendo", "text": "Think of it as pouring yourself back into the right can."},
		GameState.increment_npc_dialogue_count("vendo_circuit_explained")
		start_dialogue(_get_vendo_lines("circuit_soda_intro", [
			{"speaker": "Vendo", "text": "Scanner mood: fractured."},
			{"speaker": "Vendo", "text": "Your signal is going everywhere except where it should."},
			{"speaker": "Vendo", "text": "Luckily, I am a licensed beverage-adjacent routing system."},
	if not GameState.vendo_circuit_anecdote_seen:
		GameState.vendo_circuit_anecdote_seen = true
		start_dialogue(_get_vendo_lines("circuit_soda_completion_anecdote", [
			{"speaker": "Vendo", "text": "Signal routed."},
			{"speaker": "Vendo", "text": "Unfortunately, routed does not mean understood."},
			{"speaker": "Vendo", "text": "Mira and Gus have records. Try not to enjoy paperwork."},
	start_dialogue(_get_vendo_lines("overloaded_phase", [
		{"speaker": "Vendo", "text": "Signal routed."},
		{"speaker": "Vendo", "text": "Paperwork remains tragically next."},
```

#### `SnackAlcove.gd` — `_handle_circuit_soda()`
*Launches Circuit Soda; locked/phase variants.*

```gdscript
func _handle_circuit_soda() -> void:
	if GameState.lying_cabinets_completed and not GameState.mr_byte_truth_filter_debriefed and not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Player", "text": "Mr. Byte wanted the Filter report first."},
			{"speaker": "Player", "text": "Loose ends hum in this place. I should not leave one behind me."},
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("circuit_soda_machine_locked", [
			{"speaker": "Circuit Soda", "text": "SNACK ALCOVE LOCKED."},
			{"speaker": "Circuit Soda", "text": "TRUTH FILTER REQUIRED."},
	if GameState.post_reveal_roam_unlocked and GameState.circuit_soda_completed:
		start_dialogue(_get_vendo_lines("circuit_soda_replay_offer", [
			{"speaker": "Vendo", "text": "Circuit Soda: post-crisis edition. Zero stakes."},
			{"speaker": "Vendo", "text": "One replay, on the house."},
	if GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("circuit_soda_machine_restored", [
			{"speaker": "Circuit Soda", "text": "MEMORY FLOW RESTORED."},
			{"speaker": "Circuit Soda", "text": "FRACTURED SIGNAL STABILIZED."},
	if GameState.get_npc_dialogue_count("vendo_circuit_explained") == 0:
		start_dialogue([
			{"speaker": "Player", "text": "This machine has too many hoses to guess at."},
			{"speaker": "Player", "text": "Vendo loves explaining. I should let him."},
	GameState.start_circuit_soda()
	start_dialogue(_get_environment_lines("circuit_soda_machine_fractured", [
		{"speaker": "Circuit Soda", "text": "MEMORY FLOW UNROUTED."},
		{"speaker": "Circuit Soda", "text": "CONNECT INPUT TO RESTORE OUTPUT."},
```

#### `SnackAlcove.gd` — `_handle_snack_service_adventure()`

```gdscript
func _handle_snack_service_adventure() -> void:
	start_dialogue([
		{"speaker": "Service Slot", "text": "The service slot is jammed with old labels."},
		{"speaker": "Service Slot", "text": "Vendo insists this is a feature. Refunds remain impossible."},
```

#### `SnackAlcove.gd` — `_show_witness_route_complete_notice()`

```gdscript
func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
```

#### `SnackAlcove.gd` — `_offer_circuit_soda_replay()`

```gdscript
func _offer_circuit_soda_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Route the circuit again?", "circuit_soda", Callable(self, "_go_to_circuit_soda"))
```


#### `PrizeCorner.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"pip":
		"prize_counter":
		"prize_shelf_adventure":
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```

#### `PrizeCorner.gd` — `_handle_pip()`
*Pip: first meeting, Prize Sort intro (beat 6, required).*

```gdscript
func _handle_pip() -> void:
	GameState.pip_met = true
	if _is_post_reveal():
		GameState.pip_post_reveal_secret_seen = true
		GameState.mark_witness_pip_heard()
		start_dialogue(_get_pip_lines("post_reveal", [
			{"speaker": "Pip", "text": "There you are."},
			{"speaker": "Pip", "text": "Yep. Still not the original."},
			{"speaker": "Pip", "text": "But you wave nicer now."},
	if not _is_prize_sort_completed() and _prize_sort_unlocked():
			{"speaker": "Pip", "text": "Prize Sort is ready."},
			{"speaker": "Pip", "text": "The labels remember an order."},
			{"speaker": "Pip", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
		start_dialogue(lines, Callable(self, "_start_prize_sort"))
	if _is_prize_sort_completed():
	if GameState.lost_token_quest_completed:
			{"speaker": "Pip", "text": "You brought the Lost Token back."},
			{"speaker": "Pip", "text": "You used to want the blue one."},
			{"speaker": "Pip", "text": "You never had enough tickets."},
		start_dialogue(lines)
	start_dialogue(_get_first_meeting_lines())
```

#### `PrizeCorner.gd` — `_get_first_meeting_lines()`

```gdscript
func _get_first_meeting_lines() -> Array:
	return _get_pip_lines("first_meeting", [
		{"speaker": "Pip", "text": "Hi! I am a legally distinct prize animal."},
		{"speaker": "Pip", "text": "I am filled with cotton and confidential information."},
```

#### `PrizeCorner.gd` — `_handle_prize_counter()`
*The Prize Sort interaction itself (choice-driven ordering puzzle; wrong-pick reactions come from pip.json `prize_sort_wrong`).*

```gdscript
func _handle_prize_counter() -> void:
	if GameState.post_reveal_roam_unlocked and _is_prize_sort_completed():
		start_dialogue(_get_pip_lines("prize_sort_replay_offer", [
			{"speaker": "Pip", "text": "The prizes remember their order now. They like being remembered."},
			{"speaker": "Pip", "text": "Want to shuffle them and put them right again?"},
	if _is_prize_sort_completed():
		start_dialogue(_get_environment_lines("prize_counter_restored", [
			{"speaker": "Prize Counter", "text": "The prize labels are neatly sorted."},
			{"speaker": "Prize Counter", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
	if _prize_sort_unlocked() and not GameState.pip_met:
		start_dialogue([
			{"speaker": "Player", "text": "Three loose labels under glass, and one very alert plush."},
			{"speaker": "Player", "text": "I should ask Pip before touching anything."},
	if _prize_sort_unlocked():
			{"speaker": "Prize Counter", "text": "Three labels sit loose under the glass."},
			{"speaker": "Prize Counter", "text": "Pip seems very proud of not explaining why."},
			{"speaker": "Pip", "text": "Prize Sort is ready."},
			{"speaker": "Pip", "text": "The labels remember an order."},
		start_dialogue(lines, Callable(self, "_start_prize_sort"))
	start_dialogue(_get_environment_state_lines("prize_counter", [
		{"speaker": "Prize Counter", "text": "Cheap prizes watch from behind dusty glass."},
```

#### `PrizeCorner.gd` — `_handle_prize_shelf_adventure()`

```gdscript
func _handle_prize_shelf_adventure() -> void:
	start_dialogue([
		{"speaker": "Prize Shelf", "text": "The shelf-run rail is unplugged. Loose tags rest where they fell."},
		{"speaker": "Prize Shelf", "text": "Pip says the good prizes were never on the rail anyway."},
```

#### `PrizeCorner.gd` — `_open_prize_sort_choice()`

```gdscript
func _open_prize_sort_choice() -> void:
	if choice_box and is_instance_valid(choice_box):
	if player and player.has_method("set_control_enabled"):
	if choice_box.has_signal("choice_selected"):
	if choice_box.has_signal("choice_cancelled"):
	var question := "PRIZE SORT\nArrange the prizes from oldest memory to newest memory.\nChoose item %d." % slot
	if not prize_sort_selected.is_empty():
		if not reaction.is_empty():
	for item in PRIZE_SORT_ORDER:
		if pick_index >= 0:
			options.append("%d. %s  [placed]" % [pick_index + 1, item])
		else:
	choice_box.open_choice(question, options)
```

#### `PrizeCorner.gd` — `_get_pip_item_reaction()`

```gdscript
func _get_pip_item_reaction(item: String) -> String:
	match item:
		"Ticket Stub":
			return "Pip hugs the Ticket Stub: \"Where wanting starts. It is still warm.\""
		"Lost Token":
			return "Pip taps the Lost Token: \"It hums. It remembers coming back.\""
		"Blank Employee Badge":
			return "Pip whispers at the badge: \"It pretends to sleep. It is listening.\""
	return ""
```

#### `PrizeCorner.gd` — `_show_pip_prize_completion_dialogue()`
*Pip's completion beat — seeds the Blank Employee Badge.*

```gdscript
func _show_pip_prize_completion_dialogue() -> void:
	if GameState.consume_postgame_replay_return("prize_sort"):
		start_dialogue(_get_pip_lines("prize_sort_replay_return", [
			{"speaker": "Pip", "text": "All sorted. Again. You did not have to."},
			{"speaker": "Pip", "text": "Which is exactly why it counts."},
	if not GameState.pip_prize_anecdote_seen:
		GameState.pip_prize_anecdote_seen = true
		start_dialogue(_get_pip_lines("prize_sort_completion", [
			{"speaker": "Pip", "text": "Prizes sorted."},
			{"speaker": "Pip", "text": "Some rewards remember their owner before the owner remembers them."},
	start_dialogue([
		{"speaker": "Pip", "text": "Prizes sorted."},
		{"speaker": "Pip", "text": "Ticket Stub. Lost Token. Blank Employee Badge."},
```

#### `PrizeCorner.gd` — `_finish_failed_prize_sort()`

```gdscript
func _finish_failed_prize_sort() -> void:
	start_dialogue(_get_pip_sequential_lines("prize_sort_wrong", [
		{"speaker": "Pip", "text": "Those memories are wearing each other's hats."},
		{"speaker": "Pip", "text": "Try oldest to newest."},
```

#### `PrizeCorner.gd` — `_show_witness_route_complete_notice()`

```gdscript
func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
```

#### `PrizeCorner.gd` — `_offer_prize_sort_replay()`

```gdscript
func _offer_prize_sort_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Sort the prizes again?", "prize_sort", Callable(self, "_start_prize_sort"))
```


#### `MaintenanceHall.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"gus":
		"maintenance_sync":
		"maintenance_note":
		"staff_record_02":
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```

#### `MaintenanceHall.gd` — `_handle_gus()`
*Gus: pre-quest flavor, Lost Shift File dialogue (beat 7), Static Service Run intro (beat 8), Maintenance Sync intro (beat 9), post-reveal witness.*

```gdscript
func _handle_gus() -> void:
	if GameState.post_reveal_roam_unlocked and GameState.witness_gus_heard:
		start_dialogue(_get_gus_lines("static_run_replay_offer", [
			{"speaker": "Gus", "text": "The route is alive and humming, thanks to you."},
			{"speaker": "Gus", "text": "Want to run it again anyway? For fun."},
	GameState.gus_intro_seen = true
	if GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		GameState.gus_post_reveal_seen = true
		GameState.mark_witness_gus_heard()
		start_dialogue(_get_gus_lines("post_reveal_witness", [
			{"speaker": "Gus", "text": "Employee 04."},
			{"speaker": "Gus", "text": "Yeah. I know."},
			{"speaker": "Gus", "text": "Keep breathing."},
	if not GameState.circuit_soda_completed:
		start_dialogue([
			{"speaker": "Gus", "text": "Maintenance Hall is not ready for you yet."},
			{"speaker": "Gus", "text": "Go let Vendo route whatever counts as your signal first."},
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.start_lost_shift_file()
		start_dialogue([
			{"speaker": "Gus", "text": "I can help with the door."},
			{"speaker": "Gus", "text": "But not until you know what shift you are standing in."},
			{"speaker": "Gus", "text": "Find the Lost Shift File first."},
	if GameState.lost_shift_file_completed and not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.gus_lost_shift_comment_seen = true
			{"speaker": "Gus", "text": "The maintenance note is ugly."},
			{"speaker": "Gus", "text": "I saw the Staff Door log the last night wrong. Read it three times."},
			{"speaker": "Gus", "text": "I pretended that was routine work."},
			{"speaker": "Gus", "text": "The file gives me enough to work with."},
			{"speaker": "Gus", "text": "But the maintenance route is dead."},
			{"speaker": "Gus", "text": "Go wake the service power before I ask the door anything important."},
		start_dialogue(_combine_dialogue_lines(lost_shift_lines, static_intro_lines), Callable(self, "_go_to_static_service_run"))
	if GameState.static_service_run_completed and not GameState.gus_static_run_anecdote_seen:
		GameState.gus_static_run_anecdote_seen = true
		start_dialogue(_get_gus_lines("static_service_run_anecdote", [
			{"speaker": "Gus", "text": "Power's back."},
			{"speaker": "Gus", "text": "Door's awake."},
			{"speaker": "Gus", "text": "Now the hard part: making it listen without letting it answer too much."},
	if not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		GameState.increment_npc_dialogue_count("gus_sync_explained")
		start_dialogue(_get_gus_lines("maintenance_sync_intro", [
			{"speaker": "Gus", "text": "Power's back. Door's listening."},
			{"speaker": "Gus", "text": "I still hate that sentence."},
			{"speaker": "Gus", "text": "The door is arguing with its own lock."},
	if not GameState.gus_sync_anecdote_seen:
		GameState.gus_sync_anecdote_seen = true
		start_dialogue(_get_gus_lines("maintenance_sync_completion_anecdote", [
			{"speaker": "Gus", "text": "Door's listening now."},
			{"speaker": "Gus", "text": "I do not like doors that listen."},
			{"speaker": "Gus", "text": "But if it opens, it matched you against something in its log."},
			{"speaker": "Gus", "text": "I did not read the log. On purpose."},
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen:
		start_dialogue([
			{"speaker": "Gus", "text": "Hallway stopped buzzing."},
			{"speaker": "Gus", "text": "That means it is either fixed or waiting."},
			{"speaker": "Gus", "text": "I hate both options."},
	start_dialogue([
		{"speaker": "Gus", "text": "Door still listens."},
		{"speaker": "Gus", "text": "Still hate that."},
```

#### `MaintenanceHall.gd` — `_handle_maintenance_sync()`
*Launches the Maintenance Sync door puzzle; gate messages for missing prerequisites.*

```gdscript
func _handle_maintenance_sync() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_circuit_required", [
			{"speaker": "Maintenance Sync", "text": "SIGNAL ROUTE MISSING."},
			{"speaker": "Maintenance Sync", "text": "CIRCUIT SODA REQUIRED."},
	if not GameState.lost_shift_file_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_lost_shift_required", [
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "LOST SHIFT FILE REQUIRED."},
	if not GameState.static_service_run_completed and not GameState.maintenance_sync_completed and not GameState.story_puzzle_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_static_service_required", [
			{"speaker": "Maintenance Sync", "text": "MAINTENANCE SYNC LOCKED."},
			{"speaker": "Maintenance Sync", "text": "STATIC SERVICE REQUIRED."},
	if GameState.post_reveal_roam_unlocked and GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("maintenance_sync_machine_replay_offer", [
			{"speaker": "Maintenance Sync", "text": "DOOR AND LOCK IN AGREEMENT."},
			{"speaker": "Maintenance Sync", "text": "RECREATIONAL SYNC AVAILABLE."},
	if GameState.maintenance_sync_completed or GameState.story_puzzle_completed:
		start_dialogue(_get_environment_state_lines("maintenance_sync_machine", [
			{"speaker": "Maintenance Sync", "text": "ACCESS GRANTED."},
			{"speaker": "Maintenance Sync", "text": "EMPLOYEE SIGNAL ACCEPTED."},
	if GameState.get_npc_dialogue_count("gus_sync_explained") == 0:
		start_dialogue([
			{"speaker": "Player", "text": "This panel is basically Gus's whole personality."},
			{"speaker": "Player", "text": "He would want to run me through it first."},
	start_dialogue(_get_environment_lines("maintenance_sync_machine_fractured", [
		{"speaker": "Maintenance Sync", "text": "TWO SIGNALS DETECTED."},
		{"speaker": "Maintenance Sync", "text": "SYNC REQUIRED."},
```

#### `MaintenanceHall.gd` — `_handle_maintenance_note()`
*Lost Shift File clue 3 of 3 — also part of the ambiguous Mystery-B evidence trail.*

```gdscript
func _handle_maintenance_note() -> void:
	if not GameState.circuit_soda_completed:
		start_dialogue(_get_environment_lines("maintenance_note_grounded", [
			{"speaker": "Maintenance Note", "text": "Most of the note is routine cleaning nonsense."},
	GameState.read_maintenance_note()
		{"speaker": "Maintenance Note", "text": "MAINTENANCE NOTE"},
		{"speaker": "Maintenance Note", "text": "Staff Door reported two signals after closing."},
		{"speaker": "Maintenance Note", "text": "One signal entered."},
		{"speaker": "Maintenance Note", "text": "One signal remained."},
		{"speaker": "Maintenance Note", "text": "Gus note: I do not get paid enough for doors with opinions."},
	start_dialogue(lines, after_dialogue)
```

#### `MaintenanceHall.gd` — `_handle_staff_record_02()`
*Optional staff-records chain 2/3.*

```gdscript
func _handle_staff_record_02() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Staff Record", "text": "The maintenance record is still sealed."},
	GameState.read_staff_record_02()
		{"speaker": "Staff Record", "text": "MAINTENANCE WARNING"},
		{"speaker": "Staff Record", "text": "Door responds to two signatures."},
		{"speaker": "Staff Record", "text": "One physical. One stored."},
	start_dialogue(lines, after_dialogue)
```

#### `MaintenanceHall.gd` — `_get_lost_shift_completion_lines()`

```gdscript
func _get_lost_shift_completion_lines() -> Array:
	if not GameState.lost_shift_file_completed:
		return []
	return [
		{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
		{"speaker": "Quest", "text": "A redacted staff number was assigned to Cabinet shutdown."},
```

#### `MaintenanceHall.gd` — `_show_lost_shift_complete_notice()`

```gdscript
func _show_lost_shift_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"LOST SHIFT FILE COMPLETE",
			"A redacted staff number was assigned to Cabinet shutdown."
```

#### `MaintenanceHall.gd` — `_maybe_play_midpoint_turn()`

```gdscript
func _maybe_play_midpoint_turn() -> void:
	if not GameState.lost_shift_file_completed or GameState.midpoint_turn_seen:
	GameState.midpoint_turn_seen = true
	start_dialogue([
		{"speaker": "Player", "text": "Three records. One shift folded shut and never filed."},
		{"speaker": "Player", "text": "I keep telling myself I am looking for the way out of here."},
		{"speaker": "Player", "text": "But the front door was never the locked one."},
		{"speaker": "Player", "text": "Whatever stayed behind on the last night is waiting past the Staff Door."},
		{"speaker": "Player", "text": "I am done trying to leave. I want to look at it."},
		{"speaker": "Player", "text": "Mira is still at her counter. She deserves to hear what I found... or I can carry it alone and keep working."},
```

#### `MaintenanceHall.gd` — `_get_staff_records_completion_lines()`

```gdscript
func _get_staff_records_completion_lines() -> Array:
	if not GameState.staff_records_chain_completed:
		return []
	return [
		{"speaker": "Quest", "text": "STAFF RECORDS CHAIN COMPLETE"},
		{"speaker": "Quest", "text": "The arcade knew the number before it knew the name."},
```

#### `MaintenanceHall.gd` — `_show_staff_records_complete_notice()`

```gdscript
func _show_staff_records_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"STAFF RECORDS CHAIN COMPLETE",
			"The arcade knew the number before it knew the name."
```

#### `MaintenanceHall.gd` — `_show_witness_route_complete_notice()`

```gdscript
func _show_witness_route_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"POST-REVEAL WITNESSES COMPLETE",
			"Pixel Haven remembers you in pieces.\nTogether, they almost make a person."
```

#### `MaintenanceHall.gd` — `_maybe_play_completion_anecdote()`
*AUTO after Maintenance Sync / Static Service Run: Gus one-shot anecdotes.*

```gdscript
func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
	if GameState.consume_postgame_replay_return("maintenance_sync"):
		start_dialogue(_get_environment_lines("maintenance_sync_machine_replay_return", [
			{"speaker": "Maintenance Sync", "text": "SYNC COMPLETE. AGREEMENT MAINTAINED."},
			{"speaker": "Maintenance Sync", "text": "THE DOOR SAYS THANK YOU. IN DOOR."},
	if GameState.consume_postgame_replay_return("static_service_run"):
		start_dialogue(_get_gus_lines("static_run_replay_return", [
			{"speaker": "Gus", "text": "Power held the whole way down."},
			{"speaker": "Gus", "text": "That is not forgetting. That is the good version of remembering."},
	if GameState.maintenance_sync_completed and not GameState.gus_sync_anecdote_seen:
		GameState.gus_sync_anecdote_seen = true
		start_dialogue(_get_gus_lines("maintenance_sync_completion_anecdote", [
			{"speaker": "Gus", "text": "Door's listening now."},
			{"speaker": "Gus", "text": "It matched you against something in its log. I did not read it. On purpose."},
	if GameState.static_service_run_completed and not GameState.gus_static_run_anecdote_seen:
		GameState.gus_static_run_anecdote_seen = true
		start_dialogue(_get_gus_lines("static_service_run_anecdote", [
			{"speaker": "Gus", "text": "Power's back. Door's awake."},
			{"speaker": "Gus", "text": "Still, you did good. The hum is cleaner now."},
```

#### `MaintenanceHall.gd` — `_offer_maintenance_sync_replay()`

```gdscript
func _offer_maintenance_sync_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Sync the door again?", "maintenance_sync", Callable(self, "_go_to_maintenance_sync"))
```

#### `MaintenanceHall.gd` — `_offer_static_run_replay()`

```gdscript
func _offer_static_run_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Run the service route again?", "static_service_run", Callable(self, "_go_to_static_service_run"))
```


#### `StaffCorridor.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"security_tape":
		"final_night_walk":
		"memory_echo":
		"staff_room_door":
		"staff_record_03":
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```

#### `StaffCorridor.gd` — `_handle_memory_echo()`
*Memory Echo terminal (beat 12, Reel). First-meeting/locked/launch branches.*

```gdscript
func _handle_memory_echo() -> void:
	if not GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("memory_echo_object_maintenance_required", [
			{"speaker": "Memory Echo", "text": "SIGNAL TOO QUIET."},
			{"speaker": "Memory Echo", "text": "MAINTENANCE SYNC REQUIRED."},
	if not GameState.security_tape_assembly_completed:
		start_dialogue(_get_environment_lines("memory_echo_object_security_tape_required", [
			{"speaker": "Memory Echo", "text": "MEMORY ECHO LOCKED."},
			{"speaker": "Memory Echo", "text": "SECURITY TAPE REQUIRED."},
	if not GameState.final_night_walk_completed:
		start_dialogue(_get_environment_lines("memory_echo_object_final_night_required", [
			{"speaker": "Memory Echo", "text": "MEMORY ECHO LOCKED."},
			{"speaker": "Memory Echo", "text": "FINAL NIGHT WALK REQUIRED."},
	if GameState.post_reveal_roam_unlocked and GameState.memory_echo_completed and GameState.get_npc_dialogue_count("reel_witness") > 0:
		start_dialogue(DIALOGUE_POOL.get_lines("reel", "memory_echo_replay_offer", [
			{"speaker": "Reel", "text": "The last set plays clean now, pal."},
			{"speaker": "Reel", "text": "Want to hear it again? Encores are the only reruns worth keeping."},
	if not GameState.memory_echo_completed:
		if not GameState.memory_echo_started:
			GameState.start_memory_echo()
			if GameState.get_npc_dialogue_count("reel_first_meeting") == 0:
				GameState.increment_npc_dialogue_count("reel_first_meeting")
				echo_intro = DIALOGUE_POOL.get_lines("reel", "first_meeting", [])
			echo_intro.append_array(DIALOGUE_POOL.get_lines("reel", "memory_echo_intro", []))
				{"speaker": "Memory System", "text": "FINAL NIGHT ROUTE STABLE."},
				{"speaker": "Memory System", "text": "MEMORY ECHO AVAILABLE."},
				{"speaker": "Memory System", "text": "IDENTITY CONFLICT APPROACHING READABLE RANGE."},
			start_dialogue(echo_intro, Callable(self, "_go_to_memory_echo"))
	if not GameState.memory_echo_anecdote_seen:
		GameState.memory_echo_anecdote_seen = true
		start_dialogue(_get_environment_lines("memory_echo_object_restored", [
			{"speaker": "Memory Echo", "text": "Echo stabilized."},
			{"speaker": "Memory Echo", "text": "The arcade stops arguing with itself."},
			{"speaker": "Memory Echo", "text": "That might be worse."},
		{"speaker": "Memory Echo", "text": "Echo stable."},
		{"speaker": "Memory Echo", "text": "Quiet is not always better."},
	if _is_post_reveal() and GameState.get_npc_dialogue_count("reel_witness") == 0:
		GameState.increment_npc_dialogue_count("reel_witness")
		echo_lines.append_array(DIALOGUE_POOL.get_lines("reel", "post_reveal_witness", []))
	start_dialogue(echo_lines)
```

#### `StaffCorridor.gd` — `_handle_security_tape()`
*Security Tape terminal (beat 10, Coily). The anomaly stays 'a frame that doesn't belong' — never 'a second you'.*

```gdscript
func _handle_security_tape() -> void:
	if not GameState.maintenance_sync_completed:
		start_dialogue(_get_environment_lines("security_tape_terminal_locked", [
			{"speaker": "Staff Door", "text": "SECURITY TAPE LOCKED."},
			{"speaker": "Staff Door", "text": "MAINTENANCE SYNC REQUIRED."},
	if GameState.post_reveal_roam_unlocked and GameState.security_tape_assembly_completed and GameState.get_npc_dialogue_count("coily_witness") > 0:
		start_dialogue(DIALOGUE_POOL.get_lines("coily", "security_tape_replay_offer", [
			{"speaker": "Coily", "text": "Movie night, pal? Every frame belongs now."},
			{"speaker": "Coily", "text": "I like this cut better. Everybody walks out of it."},
	if GameState.security_tape_assembly_completed:
			{"speaker": "Security Tape", "text": "TAPE ORDER RESTORED."},
			{"speaker": "Security Tape", "text": "FRAMES NOW FORM A STAFF ROUTE."},
			{"speaker": "Security Tape", "text": "FINAL NIGHT WALK REQUIRED."},
			{"speaker": "Mr. Byte", "text": "Tape order restored."},
			{"speaker": "Mr. Byte", "text": "Sequence now describes a route."},
			{"speaker": "Mr. Byte", "text": "It does not yet describe the cause."},
			{"speaker": "Staff Door", "text": "FINAL NIGHT WALK REQUIRED."},
		if GameState.get_npc_dialogue_count("coily_tape_completion") == 0:
			GameState.increment_npc_dialogue_count("coily_tape_completion")
			completed_lines.append_array(DIALOGUE_POOL.get_lines("coily", "security_tape_completion", []))
		if _is_post_reveal() and GameState.get_npc_dialogue_count("coily_witness") == 0:
			GameState.increment_npc_dialogue_count("coily_witness")
			completed_lines.append_array(DIALOGUE_POOL.get_lines("coily", "post_reveal_witness", []))
		start_dialogue(completed_lines)
	if not GameState.security_tape_assembly_started:
		GameState.start_security_tape_assembly()
		if GameState.get_npc_dialogue_count("coily_first_meeting") == 0:
			GameState.increment_npc_dialogue_count("coily_first_meeting")
			start_lines = DIALOGUE_POOL.get_lines("coily", "first_meeting", [])
		start_lines.append_array(DIALOGUE_POOL.get_lines("coily", "security_tape_intro", []))
			{"speaker": "Security Tape", "text": "SECURITY TAPE DAMAGED."},
			{"speaker": "Security Tape", "text": "RESTORE SEQUENCE."},
			{"speaker": "Mr. Byte", "text": "Security tape fragments detected."},
			{"speaker": "Mr. Byte", "text": "Recommended action: restore order before restoring identity."},
		start_dialogue(start_lines, Callable(self, "_go_to_security_tape_assembly"))
```

#### `StaffCorridor.gd` — `_handle_final_night_walk()`
*Final Night Walk terminal (beat 11).*

```gdscript
func _handle_final_night_walk() -> void:
	if not GameState.security_tape_assembly_completed:
		start_dialogue(_get_environment_lines("final_night_walk_terminal_locked", [
			{"speaker": "Memory System", "text": "FINAL NIGHT WALK LOCKED."},
			{"speaker": "Memory System", "text": "SECURITY TAPE REQUIRED."},
	if GameState.post_reveal_roam_unlocked and GameState.final_night_walk_completed:
		start_dialogue(_get_staff_door_lines("final_night_walk_replay_offer", [
			{"speaker": "Staff Door", "text": "FINAL NIGHT ROUTE: ARCHIVED."},
			{"speaker": "Staff Door", "text": "WALK AVAILABLE AS MEMORIAL."},
	if GameState.final_night_walk_completed:
		if not GameState.staff_door_final_walk_anecdote_seen:
			GameState.staff_door_final_walk_anecdote_seen = true
			start_dialogue(_get_environment_lines("final_night_walk_terminal_restored", [
				{"speaker": "Staff Door", "text": "ROUTE ACCEPTED."},
				{"speaker": "Staff Door", "text": "FINAL NIGHT SEQUENCE STABILIZED."},
				{"speaker": "Staff Door", "text": "ONE WALKED IN."},
				{"speaker": "Staff Door", "text": "TWO SIGNALS ANSWERED."},
		start_dialogue(_get_environment_lines("final_night_walk_terminal_restored", [
			{"speaker": "Staff Door", "text": "FINAL NIGHT ROUTE STABLE."},
			{"speaker": "Staff Door", "text": "MEMORY ECHO READY."},
	if not GameState.final_night_walk_started:
		GameState.start_final_night_walk()
			{"speaker": "Staff Door", "text": "TAPE ORDER RESTORED."},
			{"speaker": "Staff Door", "text": "ROUTE MEMORY UNSTABLE."},
			{"speaker": "Staff Door", "text": "WALK THE FINAL NIGHT."},
		if GameState.get_npc_dialogue_count("coily_fnw_accent") == 0:
			GameState.increment_npc_dialogue_count("coily_fnw_accent")
			fnw_lines.append_array(DIALOGUE_POOL.get_lines("coily", "final_night_walk_accent", []))
		start_dialogue(fnw_lines, Callable(self, "_go_to_final_night_walk"))
```

#### `StaffCorridor.gd` — `_handle_staff_room_door()`
*The last door; opens after Memory Echo.*

```gdscript
func _handle_staff_room_door() -> void:
	if _is_post_reveal():
		start_dialogue(_get_staff_door_lines("post_reveal_stable", [
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK COMPLETE."},
			{"speaker": "Staff Room Door", "text": "RETURN NOT REQUIRED."},
	if not GameState.security_tape_assembly_completed:
		start_dialogue(_get_staff_door_sequential_lines("security_tape_required", [
			{"speaker": "Staff Room Door", "text": "STAFF ACCESS LOCKED."},
			{"speaker": "Staff Room Door", "text": "REQUIRED: SECURITY TAPE ASSEMBLY."},
	if not GameState.final_night_walk_completed:
		start_dialogue(_get_staff_door_sequential_lines("final_night_walk_required", [
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Staff Room Door", "text": "REQUIRED: FINAL NIGHT WALK."},
	if not GameState.memory_echo_completed:
		start_dialogue(_get_staff_door_sequential_lines("memory_echo_required", [
			{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Staff Room Door", "text": "MEMORY ECHO REQUIRED."},
	start_dialogue(_get_staff_door_lines("staff_room_available", [
		{"speaker": "Staff Room Door", "text": "RESTORE PLAYBACK AVAILABLE."},
		{"speaker": "Staff Room Door", "text": "ENTER STAFF ROOM?"},
```

#### `StaffCorridor.gd` — `_handle_staff_record_03()`
*Optional staff-records chain 3/3.*

```gdscript
func _handle_staff_record_03() -> void:
	if not GameState.lying_cabinets_completed:
		start_dialogue(_get_environment_lines("staff_records_locked", [
			{"speaker": "Staff Record", "text": "The corridor log has not finished restoring."},
	GameState.read_staff_record_03()
		{"speaker": "Staff Record", "text": "STAFF CORRIDOR LOG"},
		{"speaker": "Staff Record", "text": "Employee number sealed until Staff Room playback."},
		{"speaker": "Staff Record", "text": "Name field unavailable."},
		{"speaker": "Mr. Byte", "text": "Record fragment accepted."},
		{"speaker": "Mr. Byte", "text": "Identity checksum incomplete."},
		{"speaker": "Mr. Byte", "text": "Additional staff records required."},
	start_dialogue(lines, after_dialogue)
```

#### `StaffCorridor.gd` — `_get_staff_records_completion_lines()`

```gdscript
func _get_staff_records_completion_lines() -> Array:
	if not GameState.staff_records_chain_completed:
		return []
	return [
		{"speaker": "Quest", "text": "STAFF RECORDS CHAIN COMPLETE"},
		{"speaker": "Quest", "text": "The arcade knew the number before it knew the name."},
```

#### `StaffCorridor.gd` — `_show_staff_records_complete_notice()`

```gdscript
func _show_staff_records_complete_notice() -> void:
	if quest_notice and quest_notice.has_method("show_custom_notification"):
			"show_custom_notification",
			"STAFF RECORDS CHAIN COMPLETE",
			"The arcade knew the number before it knew the name."
```

#### `StaffCorridor.gd` — `_maybe_play_completion_anecdote()`

```gdscript
func _maybe_play_completion_anecdote() -> void:
	if _dialogue_is_active() or ConscienceEncounterDirector.is_encounter_active():
	if GameState.consume_postgame_replay_return("security_tape"):
		start_dialogue(DIALOGUE_POOL.get_lines("coily", "security_tape_replay_return", [
			{"speaker": "Coily", "text": "And it still ends okay! I checked every frame twice."},
			{"speaker": "Coily", "text": "Come back any time. I will keep the reel warm for you, 04."},
	if GameState.consume_postgame_replay_return("final_night_walk"):
		start_dialogue(_get_staff_door_lines("final_night_walk_replay_return", [
			{"speaker": "Staff Door", "text": "WALK COMPLETE. ROUTE UNCHANGED."},
			{"speaker": "Staff Door", "text": "SOME DOORS STAY OPEN. THIS IS ONE."},
	if GameState.consume_postgame_replay_return("memory_echo"):
		start_dialogue(DIALOGUE_POOL.get_lines("reel", "memory_echo_replay_return", [
			{"speaker": "Reel", "text": "Same songs. Lighter key."},
			{"speaker": "Reel", "text": "That is what healing sounds like on tape."},
	if GameState.memory_echo_completed and not GameState.twist_reveal_seen and GameState.get_npc_dialogue_count("reel_echo_completion") == 0:
		GameState.increment_npc_dialogue_count("reel_echo_completion")
		start_dialogue(DIALOGUE_POOL.get_lines("reel", "memory_echo_completion", [
			{"speaker": "Reel", "text": "That is your setlist. Rough, honest, yours."},
			{"speaker": "Reel", "text": "The next room is going to try to make you forget the tune."},
	if GameState.security_tape_assembly_completed and not GameState.final_night_walk_completed and GameState.get_npc_dialogue_count("coily_tape_completion") == 0:
		GameState.increment_npc_dialogue_count("coily_tape_completion")
		start_dialogue(DIALOGUE_POOL.get_lines("coily", "security_tape_completion", [
			{"speaker": "Coily", "text": "You put the night back in order, pal."},
			{"speaker": "Coily", "text": "One frame still does not belong. Keep noticing it."},
```

#### `StaffCorridor.gd` — `_offer_security_tape_replay()`

```gdscript
func _offer_security_tape_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Restore the tape again?", "security_tape", Callable(self, "_go_to_security_tape_assembly"))
```

#### `StaffCorridor.gd` — `_offer_final_night_walk_replay()`

```gdscript
func _offer_final_night_walk_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Walk the final night again?", "final_night_walk", Callable(self, "_go_to_final_night_walk"))
```

#### `StaffCorridor.gd` — `_offer_memory_echo_replay()`

```gdscript
func _offer_memory_echo_replay() -> void:
	PostGameReplay.open_offer(ui_layer, player, "Play the last set again?", "memory_echo", Callable(self, "_go_to_memory_echo"))
```


#### `StaffRoom.gd` — `_handle_employee_04_file()`
*The Employee 04 file — Mystery A (identity) evidence at the destination.*

```gdscript
func _handle_employee_04_file() -> void:
	if player and player.has_method("set_control_enabled"):
	if GameState.conscience_final_room_seen:
		GameState.employee_04_file_found = true
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // RESTORED MEMORY ACTIVE."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
			{"speaker": "Employee File", "text": "The regret field is no longer sealed."},
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
			{"speaker": "Employee File", "text": "EMPLOYEE 04 // RESTORED MEMORY ACTIVE."},
			{"speaker": "Employee File", "text": "The photo is yours."},
			{"speaker": "Employee File", "text": "The file was never about someone else."},
		{"speaker": "Employee File", "text": "EMPLOYEE 04 // STATUS: ARCHIVED RESTORE PROFILE."},
		{"speaker": "Employee File", "text": "The photo is corrupted beyond recognition."},
```

#### `StaffRoom.gd` — `_handle_terminal_interaction()`
*Triggers the reveal slideshow -> final cutscene.*

```gdscript
func _handle_terminal_interaction() -> void:
	if reveal_in_progress:
	if player and player.has_method("set_control_enabled"):
	if GameState.twist_reveal_seen and GameState.conscience_final_room_seen:
			{"speaker": "Terminal", "text": "EMPLOYEE 04 RESTORE STATUS: STABLE."},
			{"speaker": "Terminal", "text": "CONSCIENCE ECHO INTEGRATED."},
			{"speaker": "Terminal", "text": "MEMORY LOOP CLOSED."},
	if GameState.twist_reveal_seen:
		GameState.employee_04_file_found = true
	if not GameState.memory_echo_completed:
			{"speaker": "Terminal", "text": "RESTORE PLAYBACK LOCKED."},
			{"speaker": "Terminal", "text": "MEMORY ECHO REQUIRED."},
		{"speaker": "Terminal", "text": "Employee file recovered."},
		{"speaker": "Terminal", "text": "Restoration subject found."},
		{"speaker": "Terminal", "text": "Name: Employee 04."},
```

#### `StaffRoom.gd` — `_start_reveal()`

```gdscript
func _start_reveal() -> void:
	if active_cutscene.has_signal("cutscene_finished"):
	if active_cutscene.has_method("start_cutscene"):
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_01.svg", "caption": "You built these cabinets by hand, to give tired people somewhere kinder to go.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_02.svg", "caption": "For a while, the floor was never empty.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_03.svg", "caption": "Then the crowds thinned. The bills did not.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_04.svg", "caption": "You kept the lights on by going without, and told everyone else to take care of themselves.", "effect": "fade"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_05.svg", "caption": "On the last night, you came to close Pixel Haven yourself.", "effect": "slow_zoom"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_06.svg", "caption": "One loss, and you read your whole life like a game-over screen.", "effect": "glitch_flash"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_07.svg", "caption": "The part of you that could not carry it broke away, and hid the memory to keep you safe.", "effect": "glitch_flash"},
			{"image_path": MEMORY_REVEAL_PANEL_DIR + "reveal_08.svg", "caption": "The arcade kept every memory of you. You woke without your own.", "effect": "fade"},
```

#### `StaffRoom.gd` — `_get_final_self_conflict_lines()`
*PROTECTED ANCHOR. The climactic Player <-> ??? two-hander. No other figure named; motto stated, refuted, chosen. Evaluate for craft, but treat existing lines as canon (additive suggestions only).*

```gdscript
func _get_final_self_conflict_lines() -> Array:
		{"speaker": "Player", "text": "Employee 04."},
		{"speaker": "Player", "text": "That was not a clue."},
		{"speaker": "Player", "text": "It was my name tag."},
		{"speaker": "\"Player\"", "text": "Reality should not be like a game."},
		{"speaker": "\"Player\"", "text": "A single win should not solve everything."},
		{"speaker": "\"Player\"", "text": "A single loss should not ruin everything in an instant."},
		{"speaker": "\"Player\"", "text": "Yet you chose like a game would choose."},
		{"speaker": "\"Player\"", "text": "One decision."},
		{"speaker": "\"Player\"", "text": "One final input."},
		{"speaker": "\"Player\"", "text": "One ending forced onto everyone else."},
		{"speaker": "\"Player\"", "text": "You told people to take care of themselves."},
		{"speaker": "\"Player\"", "text": "You built games to give them somewhere kinder to go."},
		{"speaker": "\"Player\"", "text": "And when it was your turn to stay alive through the hardship..."},
		{"speaker": "\"Player\"", "text": "You failed to carry out your own motto."},
		{"speaker": "Player", "text": "..."},
		{"speaker": "\"Player\"", "text": "That silence is honest, at least."},
		{"speaker": "\"Player\"", "text": "I am you."},
		{"speaker": "\"Player\"", "text": "You are me."},
		{"speaker": "\"Player\"", "text": "I was born the moment regret hit you."},
		{"speaker": "\"Player\"", "text": "On that day."},
		{"speaker": "\"Player\"", "text": "When you understood what your decision would do to Pixel Haven."},
		{"speaker": "\"Player\"", "text": "When you understood what it would leave behind."},
		{"speaker": "\"Player\"", "text": "I took the weight because you could not carry it."},
		{"speaker": "\"Player\"", "text": "I sealed away the poverty."},
		{"speaker": "\"Player\"", "text": "The exhaustion."},
		{"speaker": "\"Player\"", "text": "The unpaid bills."},
		{"speaker": "\"Player\"", "text": "The shame of caring more about players than profit."},
		{"speaker": "\"Player\"", "text": "The anger that your best work could still be forgotten."},
		{"speaker": "\"Player\"", "text": "I buried the memory so you could live without it."},
		{"speaker": "\"Player\"", "text": "So you could wake up as someone else."},
		{"speaker": "\"Player\"", "text": "So you could choose a path that did not hurt this much."},
		{"speaker": "Player", "text": "I thought forgetting would make me free."},
		{"speaker": "\"Player\"", "text": "It made you incomplete."},
		{"speaker": "Player", "text": "I was never a man of my word."},
		{"speaker": "Player", "text": "I told others to take care of themselves."},
		{"speaker": "Player", "text": "I told them games could be a place to rest."},
		{"speaker": "Player", "text": "But I did not give myself that same mercy."},
		{"speaker": "Player", "text": "Being someone who loved games proved it."},
		{"speaker": "Player", "text": "Games were always about giving people joy that was not meant for me."},
		{"speaker": "Player", "text": "No matter what I made..."},
		{"speaker": "Player", "text": "No matter how carefully I built it..."},
		{"speaker": "Player", "text": "It could fall out of trend."},
		{"speaker": "Player", "text": "It could be replaced."},
		{"speaker": "Player", "text": "It could be forgotten."},
		{"speaker": "Player", "text": "I used to think that was the reason games had such short lives."},
		{"speaker": "Player", "text": "But I was wrong."},
		{"speaker": "\"Player\"", "text": "Then tell me what you were wrong about."},
		{"speaker": "Player", "text": "I thought a game died when it stopped winning."},
		{"speaker": "Player", "text": "I thought a person was the same."},
		{"speaker": "Player", "text": "I thought I was the same."},
		{"speaker": "\"Player\"", "text": "You are describing the night you gave up."},
		{"speaker": "Player", "text": "..."},
		{"speaker": "Player", "text": "One bad night. One final total."},
		{"speaker": "Player", "text": "I read it like a game-over screen."},
		{"speaker": "Player", "text": "I treated a single loss as the end of everything."},
		{"speaker": "\"Player\"", "text": "It felt like the end of everything."},
		{"speaker": "Player", "text": "Feeling like the end is not the same as being the end."},
		{"speaker": "Player", "text": "That was the one rule I built into every cabinet on this floor."},
		{"speaker": "Player", "text": "Reality is not a game."},
		{"speaker": "Player", "text": "A single win does not set you for life."},
		{"speaker": "Player", "text": "A single loss does not mean it is all over."},
		{"speaker": "Player", "text": "I made that promise to everyone who ever stood at a screen."},
		{"speaker": "Player", "text": "I never once turned it toward myself."},
		{"speaker": "Player", "text": "A game lasts as long as someone wants to carry it."},
		{"speaker": "Player", "text": "Not as long as it earns."},
		{"speaker": "Player", "text": "Not as long as it trends."},
		{"speaker": "Player", "text": "Not as long as it wins."},
		{"speaker": "Player", "text": "I made simple things."},
		{"speaker": "Player", "text": "Feeble things, sometimes."},
		{"speaker": "Player", "text": "Games with cheap lights, stubborn cabinets, and rules anyone could understand."},
		{"speaker": "Player", "text": "But I wanted them to give people solace."},
		{"speaker": "Player", "text": "I wanted them to give people fun."},
		{"speaker": "Player", "text": "I wanted someone tired, lonely, or afraid to stand in front of a screen and feel lighter for a while."},
		{"speaker": "Player", "text": "I cared about that more than money."},
		{"speaker": "Player", "text": "And maybe that was foolish."},
		{"speaker": "Player", "text": "But it was also the part of me I was proud of."},
		{"speaker": "Player", "text": "The regret is mine too."},
		{"speaker": "Player", "text": "The fear is mine."},
		{"speaker": "Player", "text": "The failure is mine."},
		{"speaker": "Player", "text": "The pride is mine."},
		{"speaker": "Player", "text": "I do not become whole by defeating you."},
		{"speaker": "Player", "text": "I become whole by carrying you with me."},
		{"speaker": "Player", "text": "I thought the years took this place from me. They did not."},
		{"speaker": "Player", "text": "I set myself down somewhere and forgot where."},
		{"speaker": "Player", "text": "Youth was never the thing I lost. I lost me."},
		{"speaker": "Player", "text": "And I am picking me back up."},
		{"speaker": "\"Player\"", "text": "..."},
		{"speaker": "\"Player\"", "text": "Then carry it."},
		{"speaker": "\"Player\"", "text": "Carry the pride."},
		{"speaker": "\"Player\"", "text": "Carry the regret."},
		{"speaker": "\"Player\"", "text": "Carry the arcade."},
		{"speaker": "\"Player\"", "text": "But do not make me bury you again."},
		{"speaker": "Player", "text": "I will not."},
		{"speaker": "\"Player\"", "text": "Then I have nothing left to protect you from."},
		{"speaker": "\"Player\"", "text": "No more endings to force on your behalf."},
		{"speaker": "\"Player\"", "text": "From here, we take our turns together."},
	lines.append({"speaker": "\"Player\"", "text": "..."})
	lines.append({"speaker": "\"Player\"", "text": "Go on, then."})
```

#### `StaffRoom.gd` — `_get_run_reprise_lines()`
*Additive reprise inside the finale: remembers choice #1 (told Mira or not) and the two adventure secrets.*

```gdscript
func _get_run_reprise_lines() -> Array:
	if GameState.midpoint_told_mira:
		reprise.append({"speaker": "Player", "text": "Mira knew what I found before this door did. I did not walk in here alone."})
		reprise.append({"speaker": "\"Player\"", "text": "You told her. That was new. You used to file every weight as yours only."})
	else:
		reprise.append({"speaker": "\"Player\"", "text": "You carried the shift file here alone. Some habits survive even forgetting."})
	if GameState.ssr_secret_cache_found:
		reprise.append({"speaker": "\"Player\"", "text": "You found the spares you once labeled for the night shift. 'Take what you need.' You finally did."})
	if GameState.fnw_secret_echo_found:
		reprise.append({"speaker": "\"Player\"", "text": "And the frame no camera was meant to keep. The bow tie. You always fixed it before lights out."})
```


#### `FrontEntrance.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"locked_exit":
			start_dialogue(_get_env_state("front_doors", [
				{"speaker": "Front Doors", "text": "The main doors are chained shut from the outside."},
				{"speaker": "Front Doors", "text": "Something here is not finished with you yet."},
		"arcade_history":
			start_dialogue(_get_env_state("arcade_history", [
				{"speaker": "History Board", "text": "Photos of fuller years. The most recent ones have been taken down."},
		"closing_notice":
			start_dialogue(_get_env_state("closing_notice", [
				{"speaker": "Closing Notice", "text": "NOTICE: Pixel Haven will close after final maintenance."},
				{"speaker": "Closing Notice", "text": "The signature at the bottom is scratched out."},
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```


#### `PartyRoom.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"community_photos":
			start_dialogue(_get_env_state("party_community_wall", [
				{"speaker": "Community Wall", "text": "In the corner of almost every shot, the same figure stands half in frame."},
				{"speaker": "Community Wall", "text": "Always making sure everyone else fit."},
		"mascot_stage":
			start_dialogue(_get_env_state("party_mascot_stage", [
				{"speaker": "Party Stage", "text": "Kids' drawings are still taped along the front."},
				{"speaker": "Party Stage", "text": "One reads: THANK YOU FOR THE FREE GO."},
		"birthday_cabinet":
			start_dialogue(_get_env_state("party_birthday_cabinet", [
				{"speaker": "Birthday Cabinet", "text": "Someone kept the score low on purpose, so kids could always win."},
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```


#### `Workshop.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"workbench":
			start_dialogue(_get_env_state("workshop_bench", [
				{"speaker": "Workbench", "text": "Half-built cabinets lean against the wall, each one shaped by hand."},
				{"speaker": "Workbench", "text": "Whoever worked here cared more about the games than about being paid for them."},
		"prototype_cabinet":
			start_dialogue(_get_env_state("workshop_prototype", [
				{"speaker": "Prototype", "text": "An unfinished cabinet. A note reads: MAKE THIS ONE FREE."},
				{"speaker": "Prototype", "text": "It was never finished. The arcade closed first."},
		"spare_parts":
			start_dialogue(_get_env_state("workshop_spare_parts", [
				{"speaker": "Spare Parts", "text": "Everything here was kept working long past its time."},
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```


#### `Restrooms.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"mirror":
			start_dialogue(_get_env_state("restroom_mirror", [
				{"speaker": "Mirror", "text": "For a moment, two figures stand where only one should."},
				{"speaker": "Mirror", "text": "One of them is not quite finished moving when you are."},
		"stall":
			start_dialogue(_get_env_state("restroom_stall", [
				{"speaker": "Stall", "text": "A hand-drawn HIGH SCORE list is taped inside."},
				{"speaker": "Stall", "text": "Every name on it is the same handwriting."},
		"hidden_token":
			start_dialogue(_get_env_state("restroom_token", [
				{"speaker": "Windowsill", "text": "A single arcade token, cold and older than the others."},
				{"speaker": "Windowsill", "text": "It fits your hand like it remembers being held."},
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```


#### `MemoryCore.gd` — `handle_hub_interaction()`

```gdscript
func handle_hub_interaction(interactable: Node, _player_node: Node = null) -> void:
	match str(interactable.interactable_kind):
		"memory_bank":
			start_dialogue(_get_env_state("memory_banks", [
				{"speaker": "Memory Bank", "text": "Each one holds a memory the arcade refused to lose."},
				{"speaker": "Memory Bank", "text": "Faces. Voices. Closing nights. All of it kept."},
		"core_terminal":
			start_dialogue(_get_env_state("memory_core_terminal", [
				{"speaker": "Core Terminal", "text": "WHEN THE FLOOR WENT DARK, THE SYSTEM SAVED WHAT IT COULD."},
				{"speaker": "Core Terminal", "text": "IT CHOSE PEOPLE OVER PROFIT. ONE LAST TIME."},
		"employee_drive":
			start_dialogue(_get_env_state("memory_sealed_drive", [
				{"speaker": "Sealed Drive", "text": "One drive is labeled only with a number. The rest is scratched away."},
				{"speaker": "Sealed Drive", "text": "It has been waiting to be read."},
		_:
			start_dialogue([{"speaker": "System", "text": "Nothing happens."}])
```


#### `HallwayMap.gd` — `_get_hallway_ambient_entries()`

```gdscript
func _get_hallway_ambient_entries() -> Array[Dictionary]:
	match hallway_id:
		"cabinet_hallway", "cabinet_snack_hallway":
		"snack_hallway", "snack_prize_hallway":
		"prize_hallway":
		"maintenance_hallway", "maintenance_staff_hallway":
		"back_hallway":
	if hallway_id.find("snack") >= 0:
	if hallway_id.find("prize") >= 0:
	if hallway_id.find("maintenance") >= 0:
	if hallway_id.find("staff") >= 0 or hallway_id == "back_hallway":
```

#### `HallwayMap.gd` — `_get_hallway_message_lines()`
*One-time ambient ??? whisper per hallway, varied by Memory Signal phase — Mode-1 seeding between rooms.*

```gdscript
func _get_hallway_message_lines() -> Array:
	if hallway_id.is_empty() or GameState.twist_reveal_seen or GameState.post_reveal_roam_unlocked:
		return []
	match hallway_id:
		"cabinet_hallway":
			if GameState.lost_token_quest_completed and not GameState.lying_cabinets_completed:
				return [
					{"speaker": "???", "text": "The cabinets wake for tokens, not mercy.", "effect": "glitch"},
					{"speaker": "???", "text": "A prize can open a door. It cannot clear the score."},
		"snack_hallway":
			if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
				return [
					{"speaker": "???", "text": "Every route in this arcade has a return path.", "effect": "glitch"},
					{"speaker": "???", "text": "Watch which lights follow you back."},
		"prize_hallway":
			if GameState.lost_token_quest_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "Prizes remember hands better than names."},
					{"speaker": "???", "text": "Something on the shelf is choosing which hand to trust.", "effect": "glitch"},
		"maintenance_hallway":
			if GameState.lost_shift_file_completed and not GameState.static_service_run_completed:
				return [
					{"speaker": "???", "text": "The file opened a service route.", "effect": "glitch"},
					{"speaker": "???", "text": "Service routes are where arcades hide their bad wiring."},
			if GameState.circuit_soda_completed and not GameState.lost_shift_file_completed:
				return [
					{"speaker": "???", "text": "Maintenance is a tidy word for old damage.", "effect": "glitch"},
					{"speaker": "???", "text": "Ask Gus why the door counted one extra signal."},
		"back_hallway":
			if GameState.final_night_walk_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The route played back clean."},
					{"speaker": "???", "text": "Clean playback does not mean a clean ending.", "effect": "glitch"},
					{"speaker": "???", "text": "The one walking behind you is carrying what you set down.", "effect": "shake"},
			if GameState.staff_corridor_unlocked and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "Back halls count footsteps after the tokens stop falling."},
					{"speaker": "???", "text": "One set keeps landing half a beat behind yours.", "effect": "shake"},
		"cabinet_snack_hallway":
			if GameState.lying_cabinets_completed and not GameState.circuit_soda_completed:
				return [
					{"speaker": "???", "text": "Truth leaves a metallic taste.", "effect": "glitch"},
					{"speaker": "???", "text": "Fizz can cover it. It cannot fix it."},
		"snack_prize_hallway":
			if GameState.circuit_soda_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The prize shelf still knows what you wanted."},
					{"speaker": "???", "text": "Wanting is not always a safe memory.", "effect": "glitch"},
		"maintenance_staff_hallway":
			if GameState.maintenance_sync_completed and not GameState.memory_echo_completed:
				return [
					{"speaker": "???", "text": "The door heard both knocks."},
					{"speaker": "???", "text": "The second knock is still waiting for your hand.", "effect": "glitch"},
	return []
```


#### `MapTransition.gd` — `_try_transition()`

```gdscript
func _try_transition() -> void:
	if transition_started:
	if scene != null and scene.has_method("try_block_exit") and bool(scene.call("try_block_exit", self)):
	if not _required_flag_is_met():
	if target_scene_path.is_empty():
		push_error("MapTransition: target_scene_path is empty.")
	if not ResourceLoader.exists(target_scene_path):
		push_error("MapTransition: target scene does not exist: %s" % target_scene_path)
	GameState.set_pending_spawn_id(target_spawn_id)
```

#### `MapTransition.gd` — `_show_locked_dialogue()`
*Generic locked-exit feedback on any gated exit arrow.*

```gdscript
func _show_locked_dialogue() -> void:
	if message_lines.is_empty():
		lines.append({"speaker": "System", "text": "The path is locked."})
	else:
		for text in message_lines:
			lines.append({"speaker": "System", "text": text})
	if host != null and host.has_method("start_dialogue"):
		host.call("start_dialogue", lines)
	else:
		push_warning("MapTransition locked: %s" % str(message_lines))
```


### 4.2 The ??? interludes (Conscience Encounters)


#### `ConscienceEncounterDirector.gd` — `maybe_start_encounter()`

```gdscript
func maybe_start_encounter(parent: Node, encounter_id: String, after: Callable = Callable()) -> bool:
	if parent == null or not is_instance_valid(parent):
	if is_encounter_active():
	if not _should_trigger(encounter_id):
	if lines.is_empty():
	if active_encounter.has_method("set_controlled_player"):
	if active_encounter.has_signal("encounter_finished"):
	if active_encounter.has_method("start_encounter"):
```

#### `ConscienceEncounterDirector.gd` — `get_encounter_lines()`
*The four private ??? interludes (Mode 1 voice). Trigger conditions are in `_should_trigger` below; each plays once, pre-reveal only. ??? text renders slower (22 cps) with a darkness veil that thins per encounter (see reveal-factor table).*

```gdscript
func get_encounter_lines(encounter_id: String) -> Array:
	match encounter_id:
		"after_truth_filter":
			return [
				{"speaker": "???", "text": "Truth Filter passed.", "effect": "glitch"},
				{"speaker": "???", "text": "The cabinets are not cheering. They are keeping score."},
				{"speaker": "???", "text": "Do you feel them watching the way you move?"},
				{"speaker": "???", "text": "The woman at the counter felt it first. She feels the distance in you and blames the late hour."},
				{"speaker": "???", "text": "She is closer than she knows.", "effect": "glitch"},
				{"speaker": "???", "text": "There are two of us inside that distance. She will never learn which of us answered her.", "effect": "shake"},
		"after_circuit_soda":
			return [
				{"speaker": "???", "text": "Signal routed.", "effect": "glitch"},
				{"speaker": "???", "text": "Labels help machines behave. They do not decide what is inside the can."},
				{"speaker": "???", "text": "The vending machine caught the flicker in your label and logged it as a fault."},
				{"speaker": "???", "text": "It was not a fault. It was me, reading over your shoulder.", "effect": "glitch"},
				{"speaker": "???", "text": "They keep meeting one of us and answering the other, and never notice the swap."},
				{"speaker": "???", "text": "Telling the two apart was always going to be your job. Only yours.", "effect": "shake"},
		"after_lost_shift_file":
			return [
				{"speaker": "???", "text": "The file found a number.", "effect": "silent", "pause": 0.25},
				{"speaker": "???", "text": "Numbers are useful in arcades. Scores. Tickets. Employee slots."},
				{"speaker": "???", "text": "A name is heavier. A name remembers what it did."},
				{"speaker": "???", "text": "That is why, on the last night, one of us set the name down at the door and did not pick it back up."},
				{"speaker": "???", "text": "You carry the number now. I carry the rest.", "effect": "glitch"},
				{"speaker": "???", "text": "The others feel the weight on you and decide you are only tired."},
				{"speaker": "???", "text": "Let them. It is kinder than the truth, for a little longer.", "effect": "silent", "pause": 0.2},
		"after_final_night_walk":
			return [
				{"speaker": "???", "text": "You walked the route. Counter dark. Cabinet awake. Back hall open."},
				{"speaker": "???", "text": "Two signals in one door. One walked in. One stayed."},
				{"speaker": "???", "text": "You have spent this whole night asking which one you are."},
				{"speaker": "???", "text": "The staff never had to ask. To them you were always just you, only wrong somehow.", "effect": "glitch"},
				{"speaker": "???", "text": "They will keep it that way. Only you get to open the last door and see the rest."},
				{"speaker": "???", "text": "One of us has been taking your turn since the night this place closed."},
				{"speaker": "???", "text": "One more echo, and you will have to look at who.", "effect": "shake"},
				{"speaker": "???", "text": "I am not going to make it easy.", "effect": "silent", "pause": 0.2},
		_:
			return []
```

#### `ConscienceEncounterDirector.gd` — `_should_trigger()`
*Gating for the four encounters.*

```gdscript
func _should_trigger(encounter_id: String) -> bool:
	if GameState.is_conscience_encounter_seen(encounter_id):
	match encounter_id:
		"after_truth_filter":
		"after_circuit_soda":
		"after_lost_shift_file":
		"after_final_night_walk":
		_:
```

#### `ConscienceEncounterDirector.gd` — `_on_encounter_finished()`

```gdscript
func _on_encounter_finished(finished_encounter_id: String, after: Callable, parent: Node) -> void:
	if after.is_valid():
```

#### `ConscienceEncounterDirector.gd` — `_mark_seen()`

```gdscript
func _mark_seen(encounter_id: String) -> void:
	GameState.mark_conscience_encounter_seen(encounter_id)
```

#### `ConscienceEncounterDirector.gd` — `_find_player()`

```gdscript
func _find_player(root: Node) -> Node:
	if root == null:
	if root is CharacterBody2D and root.has_method("set_control_enabled"):
	for child in root.get_children():
		if player != null:
```

#### `ConscienceEncounterDirector.gd` — `_refresh_player_visual()`

```gdscript
func _refresh_player_visual(parent: Node) -> void:
	if player != null and player.has_method("refresh_visual_state"):
```


#### `ConscienceEncounter.gd` — `_refresh_line()`

```gdscript
func _refresh_line() -> void:
	if not active or current_index >= dialogue_lines.size():
	var speaker := str(line.get("speaker", "???"))
```


### 4.3 Dialogue pool JSON (authoritative walk-up/one-shot lines)


### Pool: `mira`
*Voice: Ticket counter; emotional anchor. Gentle, sad, arcade metaphors, never jokey. Half B.*

**`mira` / `opening_first_meeting`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** You made it back.
- **Mira:** I was afraid the door had forgotten you for good.
- **Player:** I know this place.
- **Player:** I do not know why I know this place.
- **Player:** Do I know you?
- **Mira:** Yes.
- **Mira:** But not in a way I can explain all at once.
- **Player:** That is not comforting.
- **Mira:** I know. I am trying to keep it gentle.
- **Mira:** The room has to remember you before I am allowed to.
- **Mira:** If I say too much too soon, it will not hold.

**`mira` / `lost_token_quest_instruction`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** Cabinet 07 has been holding your Lost Token.
- **Mira:** It kept it the way this place keeps everything.
- **Mira:** A little too long, and a little too tightly.
- **Mira:** Go to Cabinet Row. Win it back from the machine.
- **Mira:** Then bring it to me.
- **Mira:** I would like to watch you hold something that is yours.

**`mira` / `lost_token_active_repeat`** — 3 variant(s) · used by: ArcadeHub.gd:_handle_mira (sequential variant pick)
- variant 1:
  - **Mira:** Cabinet 07 is waiting.
  - **Mira:** It only opens for signals it almost remembers.
  - **Player:** That sounds like a terrible way to recognize someone.
  - **Mira:** Around here, it counts as friendly.
- variant 2:
  - **Mira:** If Cabinet 07 gets strange, stay calm.
  - **Mira:** It was strange before all of this too.
  - **Player:** All of what?
  - **Mira:** Start with the token.
  - **Mira:** The rest will catch up.
- variant 3:
  - **Mira:** I promise I am not brushing you off.
  - **Mira:** The token matters.
  - **Mira:** Not because it is valuable.
  - **Mira:** Because something here still knows it belongs to you.
  - **Mira:** Cabinet 07 first.

**`mira` / `lost_token_return_anecdote`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** You brought it back.
- **Mira:** That token was once just a prize.
- **Mira:** A cheap little thing from the counter.
- **Mira:** Then the arcade held onto it like proof.
- **Mira:** Not because you won. Because it matched your signal.
- **Mira:** Proof that something here still knows you.
- **Mira:** I remember you helping after closing.
- **Mira:** Stacking chairs. Checking machines. Pretending you were not tired.
- **Mira:** You always made the work look smaller than it was.
- **Mira:** You used to crouch down to the kids who lost. Whatever you told them, they walked out taller than they came in.
- **Mira:** Though today there is a distance in you. Like the words reach me a beat after you decide them.
- **Mira:** Now the arcade is trying to make you look back.
- **Mira:** Start in Cabinet Row. A regular named Roxy guards a score cabinet that is still lying about a record.
- **Mira:** She has been waiting for someone worth arguing with. Help her set it straight.

**`mira` / `broken_high_score_transition`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** Cabinet Row first. Roxy's score cabinet is still lying about a record.
- **Mira:** She is loud, competitive, and right about most things. Do not tell her I said that.
- **Mira:** Set the board straight with her. Then Mr. Byte will want a word about truth.

**`mira` / `truth_filter_transition`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** The token woke something.
- **Mira:** Now the arcade has to decide which memories are true.
- **Mira:** Mr. Byte can open the Truth Filter.
- **Mira:** He is in Cabinet Row.

**`mira` / `circuit_soda_transition`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** The arcade is remembering louder now.
- **Mira:** I do not like how that feels in the room.
- **Mira:** Vendo says fractured things still need somewhere to flow.
- **Mira:** Go to Snack Alcove.
- **Mira:** Talk to him there.

**`mira` / `lost_shift_file_dialogue`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** The records are waking up now.
- **Mira:** I remember locking the counter.
- **Mira:** I remember the carpet lights going dim.
- **Mira:** But the last part is still missing.
- **Mira:** There was a schedule.
- **Mira:** There was a maintenance note.
- **Mira:** Gus and Mr. Byte may remember the edges.
- **Mira:** Please do not force the center before it is ready.

**`mira` / `overloaded_pre_staff_room`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mira
- **Mira:** The signal is loud now.
- **Mira:** Not angry.
- **Mira:** Scared.
- **Mira:** You seem so far from here right now. Like part of you already walked ahead, and only the tired rest of you stayed to hear me.
- **Mira:** I do not know how much of you I am about to lose in there. Maybe all of you. Maybe none.
- **Mira:** When the Staff Room opens, do not rush past what it shows you.
- **Mira:** You have survived every answer so far.
- **Mira:** Survive this one slowly.

**`mira` / `post_reveal_witness`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus; ArcadeHub.gd:_handle_mira; ArcadeHub.gd:_handle_mr_byte; ArcadeHub.gd:_handle_vendo; CabinetRow.gd:_handle_mr_byte; MaintenanceHall.gd:_handle_gus; SnackAlcove.gd:_handle_vendo; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Mira:** Employee 04.
- **Mira:** I can say it now.
- **Mira:** I knew you as a coworker before I knew you as a restored memory.
- **Mira:** You stayed late when everyone else wanted to leave.
- **Mira:** You checked whether everyone got home.
- **Mira:** You made broken cabinets feel less broken.
- **Mira:** I waited because I did not know what else counted as helping.
- **Mira:** I felt guilty for waiting.
- **Mira:** Guilty for being relieved when you came back wrong instead of not at all.
- **Mira:** For a while it was like talking to you through glass. You were here, and somewhere far off, all at once.
- **Mira:** I never understood what happened to you out there. None of us did. Whatever it was, you were the only one who had to face it.
- **Mira:** But you came back with the hard parts too.
- **Mira:** You came back enough to be spoken to.
- **Mira:** I am so relieved I get to remember you gently.
- **Mira:** You spent your whole life telling people a single loss is not the end.
- **Mira:** Let me say it back to you, since you never could.
- **Mira:** It was not the end.
- **Mira:** A single win never set you for life.
- **Mira:** And a single loss never finished it.
- **Mira:** You are still here. That is the part that gets to matter now.
- **Mira:** And look at you. All these years, and the part of you that mattered never aged a day.
- **Mira:** Youth is never lost while you hold on to yourself. You let go for a while.
- **Mira:** You still found your way back.

### Pool: `gus`
*Voice: Maintenance; quiet fear under deadpan. Dry, specific, funny-bleak. Half B.*

**`gus` / `pre_lost_token_flavor`** — 3 variant(s) · used by: ArcadeHub.gd:_handle_gus (sequential variant pick)
- variant 1:
  - **Gus:** You again. Great.
  - **Gus:** I just finished cleaning up the previous session.
  - **Player:** Previous session?
  - **Gus:** Arcade talk.
  - **Gus:** Means I found tickets in places tickets should fear.
- variant 2:
  - **Gus:** Machines are supposed to take quarters and make noise.
  - **Gus:** These take memories and make paperwork.
  - **Gus:** I prefer the quarters.
  - **Gus:** They jam less often.
- variant 3:
  - **Gus:** Pixel Haven used to have more staff.
  - **Gus:** Then the schedule started looking like a ransom note.
  - **Gus:** The one who ran the place built half these cabinets by hand.
  - **Gus:** Paid the light bill late so the games could stay a quarter cheaper.
  - **Gus:** Old staff. Old machines. Same floor stains.
  - **Gus:** Somehow I am still the one with a mop.
  - **Gus:** Some names you do not say until the person is ready to hear them.
  - **Gus:** Mira is at the counter if you need actual direction.

**`gus` / `truth_filter_active`** — 3 variant(s) · used by: ArcadeHub.gd:_get_npc_dialogue_phase; ArcadeHub.gd:_handle_gus (sequential variant pick); ArcadeHub.gd:_handle_vendo (sequential variant pick)
- variant 1:
  - **Gus:** Careful now.
  - **Gus:** Once machines start correcting memories, they get picky.
  - **Gus:** Truth Filter is in Cabinet Row.
  - **Gus:** Mr. Byte is the one acting like he grades homework.
- variant 2:
  - **Gus:** Cabinet Row first.
  - **Gus:** Mr. Byte can sort the lying cabinets.
  - **Gus:** Do not argue with a machine that owns red pens.
  - **Gus:** It will enjoy that.
- variant 3:
  - **Gus:** Truth Filter.
  - **Gus:** Cabinet Row.
  - **Gus:** Let Mr. Byte tell you which memory is being dramatic.
  - **Gus:** Then come back before the door learns sarcasm.

**`gus` / `circuit_soda_active`** — 3 variant(s) · used by: ArcadeHub.gd:_handle_gus (sequential variant pick)
- variant 1:
  - **Gus:** Signal's fractured.
  - **Gus:** Vendo has a machine for that, because of course he does.
  - **Gus:** Snack Alcove first.
  - **Gus:** Try not to let him sell you confidence in a can.
- variant 2:
  - **Gus:** Vending machines should vend.
  - **Gus:** This one routes signals.
  - **Gus:** I wrote a complaint.
  - **Gus:** The complaint came out carbonated.
  - **Gus:** Go to Snack Alcove.
- variant 3:
  - **Gus:** Your signal is leaking all over the place.
  - **Gus:** Vendo calls that a beverage-adjacent routing issue.
  - **Gus:** I call it a mop problem.
  - **Gus:** Either way, Snack Alcove.

**`gus` / `lost_shift_file_phase`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_gus
- **Gus:** The maintenance note is ugly.
- **Gus:** Door-report ugly.
- **Gus:** I saw the Staff Door log the last night wrong. Read it three times.
- **Gus:** Something in that reading I still cannot make sit right.
- **Gus:** I pretended that was routine work.
- **Gus:** Routine work is easier to carry than fear.

**`gus` / `static_service_run_intro`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_gus
- **Gus:** You read the file. I can tell.
- **Gus:** You have got the face people get after reading their own name somewhere they did not expect.
- **Player:** I did not see a name.
- **Gus:** No. But you looked for one.
- **Gus:** Lately you answer like your head is somewhere else. Like you say a thing, then wait to find out if you meant it.
- **Gus:** The old late-shift used to make sure I clocked out before they did. Never the other way.
- **Gus:** Anyway. Cheerier work.
- **Gus:** The file gives me enough to work with.
- **Gus:** But the service route is dead.
- **Gus:** Restore the service power.
- **Gus:** Bring the system back before I ask the door anything important.

**`gus` / `static_service_run_anecdote`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_gus; MaintenanceHall.gd:_maybe_play_completion_anecdote
- **Gus:** Power's back.
- **Gus:** Door's awake.
- **Gus:** Great.
- **Gus:** Now the building has opinions and electricity.
- **Gus:** That is usually how repair bills become personal.
- **Gus:** Still, you did good.
- **Gus:** The hum is cleaner now.
- **Gus:** Cleaner does not mean safe.

**`gus` / `maintenance_sync_intro`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_gus
- **Gus:** Power's back. Door's listening.
- **Gus:** I still hate that sentence.
- **Gus:** The door is arguing with its own lock.
- **Gus:** Help me line up what it thinks it heard.
- **Gus:** Then maybe it opens instead of judging us.

**`gus` / `maintenance_sync_completion_anecdote`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_gus; MaintenanceHall.gd:_maybe_play_completion_anecdote
- **Gus:** Door's listening now.
- **Gus:** I do not like doors that listen.
- **Gus:** But it answered.
- **Gus:** Not with words.
- **Gus:** Worse. With agreement.
- **Gus:** It matched you against something in its log.
- **Gus:** I did not read the log. On purpose.
- **Gus:** Some doors grieve. This one files it under access control.
- **Gus:** Whoever ran this place carried it on a back that was already tired.
- **Gus:** I am calling that fixed because I want lunch.

**`gus` / `hub_checkin_truth_filter`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus
- **Player:** Gus. Has anything been talking in the hallways tonight?
- **Gus:** Talking.
- **Gus:** Those speakers have been shot since before I started. They pop. They hiss.
- **Gus:** Sometimes they do a thing I call the ghost cough. It is not a ghost.
- **Gus:** It is a loose ground wire and forty years of nobody caring.
- **Gus:** If it says anything clever, write it down. I will bill it.
- **Gus:** ...One thing, though. Closing night left me a maintenance note I never had the guts to file.
- **Gus:** It read wrong, and I did not want it to read right. Ask me again when I feel brave.
- **Gus:** Anyway. Heard the Truth Filter howl from two rooms away.
- **Gus:** It only howls when it loses the argument. That was its first loss on record.
- **Gus:** Mr. Byte logged your win as an anomaly. He logs my lunch breaks the same way.
- **Gus:** Meanwhile Vendo is rerouting power to itself again. That machine sulks when nobody visits.
- **Gus:** Snack Alcove. It will flatter you. Do not tip it.

**`gus` / `hub_checkin_prize_sort`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus
- **Gus:** Word travels. Pip let you touch the prize wall and it kept all its buttons.
- **Gus:** A ticket stub, a token, and a badge with no name. Pip guards what the arcade cannot look at.
- **Gus:** A badge with no name means a shift with no name. My schedule copy has exactly one slot nobody ever claimed.
- **Gus:** And that note I told you about, the one I never filed - your badge just gave it somewhere to point.
- **Gus:** That is a lead. I hate that it is a lead.
- **Gus:** You want the rest of that story, we do it my way. Paperwork.
- **Gus:** Closing Checklist by Mira's counter. Staff Schedule in Cabinet Row. My maintenance note in the hall.
- **Gus:** Read all three, then find me in Maintenance Hall. I will be pretending it is a normal shift.

**`gus` / `static_run_replay_offer`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_gus
- **Gus:** The service route is alive and humming, thanks to you.
- **Gus:** Want to run it again anyway? For fun.
- **Gus:** Fun. A word I am relearning. Do not rush me.

**`gus` / `static_run_replay_return`** — 1 variant(s) · used by: MaintenanceHall.gd:_maybe_play_completion_anecdote
- **Gus:** Power held the whole way down.
- **Gus:** You ran a live route for the joy of it. You used to do that, back when.
- **Gus:** That is not forgetting. That is the good version of remembering.

**`gus` / `post_reveal_witness`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus; ArcadeHub.gd:_handle_mira; ArcadeHub.gd:_handle_mr_byte; ArcadeHub.gd:_handle_vendo; CabinetRow.gd:_handle_mr_byte; MaintenanceHall.gd:_handle_gus; SnackAlcove.gd:_handle_vendo; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Gus:** Employee 04.
- **Gus:** Yeah. I know.
- **Gus:** I recognized pieces of the old you.
- **Gus:** The late-shift posture.
- **Gus:** The way you checked exits before yourself.
- **Gus:** Did not know how to say that without making it worse.
- **Gus:** So I called it maintenance and kept moving.
- **Gus:** You were staff.
- **Gus:** Still are, in the ways that matter.
- **Gus:** You always said routine was easier to carry than fear.
- **Gus:** Whole time you were the most scared one here, still sweeping up.
- **Gus:** Some days you answered like the man I knew. Some days like there was a lot less of him in the room.
- **Gus:** Never asked what had changed in you. Figured whatever it was, it was yours to carry, not mine to pry at.
- **Gus:** I do not want to clean around another absence.

### Pool: `vendo`
*Voice: Vending-machine AI. Commercial-speak as deflection; the 'X but really Y' joke must vary. Half B.*

**`vendo` / `early_flavor`** — 4 variant(s) · used by: ArcadeHub.gd:_handle_vendo (sequential variant pick)
- variant 1:
  - **Vendo:** Welcome, valued almost-customer.
  - **Vendo:** Please select a beverage or a coping mechanism.
  - **Vendo:** Refunds remain impossible, but denial is currently chilled.
  - **Vendo:** Labels may peel. Feelings may leak.
  - **Vendo:** Flavor profile: unresolved.
  - **Vendo:** House observation: nobody ages in here. They only stop meaning it.
- variant 2:
  - **Vendo:** New promotional bundle: one can, two doubts, no receipt.
  - **Vendo:** One flavor tastes like lime and denial.
  - **Vendo:** Another tastes like tickets someone forgot to cash in.
  - **Vendo:** Your label is missing. That is terrible shelf presentation.
  - **Vendo:** Please do not ask customer service. It is a sticker on my left side.
- variant 3:
  - **Vendo:** Previous sessions left residue in slot B.
  - **Vendo:** Mostly dust. Some regret. One gum wrapper with leadership potential.
  - **Vendo:** Old staff used to buy grape soda after closing.
  - **Vendo:** One of them wired me to remember faces instead of coins.
  - **Vendo:** Terrible for margins. He never seemed to care about margins.
  - **Vendo:** Now the grape soda buys time by pretending not to remember them.
  - **Vendo:** Questionable customer service remains available.
  - **Vendo:** For non-carbonated answers, consult Mira at the counter.
- variant 4:
  - **Vendo:** Today's special: coping mechanism with artificial cherry notes.
  - **Vendo:** Side effects include deja vu, mild static, and reading labels twice.
  - **Vendo:** If the can recognizes you, place it gently back in the machine.
  - **Vendo:** Do not shake emotional contents.
  - **Vendo:** Refunds remain impossible.
  - **Vendo:** Recommended next step: talk to Mira.

**`vendo` / `memory_cola_riddle_setup`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_vendo
- **Vendo:** Initiating beverage-based psychological evaluation.
- **Vendo:** Question one: why does a customer return to a closed arcade?
- **Vendo:** Do not answer. The machine is already judging the moisture in your silence.
- **Vendo:** Recommended product: MEMORY COLA.
- **Vendo:** Riddle prompt loading.

**`vendo` / `memory_cola_wrong_answers`** — 4 variant(s) · used by: ArcadeHub.gd:_on_vendo_riddle_choice_selected (sequential variant pick)
- variant 1:
  - **Vendo:** Incorrect.
  - **Vendo:** But emotionally marketable.
- variant 2:
  - **Vendo:** No sale.
  - **Vendo:** That answer contains insufficient dread.
- variant 3:
  - **Vendo:** Rejected.
  - **Vendo:** Please consult the flavor chart inside your missing past.
- variant 4:
  - **Vendo:** Wrong product selected.
  - **Vendo:** Try again after your next identity crisis.

**`vendo` / `memory_cola_correct`** — 1 variant(s) · used by: ArcadeHub.gd:_on_vendo_riddle_choice_selected
- **Vendo:** Correct.
- **Vendo:** You lose memory.
- **Vendo:** I lose coins.
- **Vendo:** MEMORY COLA dispensed in theory only.
- **Vendo:** Some losses keep lining up behind you like unpaid tabs.
- **Vendo:** If you forget again, please retain your receipt.

**`vendo` / `truth_filter_active`** — 3 variant(s) · used by: ArcadeHub.gd:_get_npc_dialogue_phase; ArcadeHub.gd:_handle_gus (sequential variant pick); ArcadeHub.gd:_handle_vendo (sequential variant pick)
- variant 1:
  - **Vendo:** Scanner mood: uneasy.
  - **Vendo:** That is not a flavor. It is a warning label with carbonation.
  - **Vendo:** Proceed to Cabinet Row.
  - **Vendo:** Mr. Byte performs truth extraction with fewer bubbles.
- variant 2:
  - **Vendo:** Scanner mood: uneasy.
  - **Vendo:** Recommended pairing: Mr. Byte and a bitter aftertaste.
  - **Vendo:** Cabinet Row is now accepting customers with unresolved labels.
  - **Vendo:** Do not lick the Truth Filter.
- variant 3:
  - **Vendo:** Scanner mood: uneasy.
  - **Vendo:** Your thoughts are fizzing in opposite directions.
  - **Vendo:** Cabinet Row can pressurize that into something useful.
  - **Vendo:** Ask Mr. Byte. He enjoys sounding like a warranty document.

**`vendo` / `circuit_soda_intro`** — 1 variant(s) · used by: SnackAlcove.gd:_handle_vendo
- **Vendo:** Welcome back to the only machine that missed you.
- **Vendo:** Complimentary trivia, no purchase required: this arcade used to close at a reasonable hour.
- **Vendo:** Then someone started staying past close to keep it breathing.
- **Vendo:** Their tab with this building only ever ran one direction. Out of them.
- **Vendo:** I never caught their name. My scanner only reads barcodes and regret.
- **Vendo:** Scanner mood: fractured.
- **Vendo:** Scanner note: your label will not hold still. It keeps flickering mid-read, like it cannot decide what it says.
- **Vendo:** Your identity is leaking through unauthorized beverage channels.
- **Vendo:** Insert unstable signal into Circuit Soda.
- **Vendo:** Align the currents until the machine stops arguing with itself.
- **Vendo:** If the lights stabilize, the route should hold.
- **Vendo:** If they explode, customer service will deny this conversation.

**`vendo` / `circuit_soda_repeat_hint`** — 3 variant(s) · used by: ArcadeHub.gd:_handle_vendo (sequential variant pick); SnackAlcove.gd:_handle_vendo (sequential variant pick)
- variant 1:
  - **Vendo:** Circuit Soda remains available.
  - **Vendo:** Route the signal through the correct channels.
  - **Vendo:** Think of it as pouring yourself back into the right can.
- variant 2:
  - **Vendo:** Helpful hint: follow the current, not the panic.
  - **Vendo:** Circuit Soda likes clean paths and dramatic buzzing.
  - **Vendo:** Snack Alcove carpet does not like either.
- variant 3:
  - **Vendo:** The machine is still waiting.
  - **Vendo:** Connect the route until the signal stops spilling.
  - **Vendo:** I would help, but my hands were discontinued.

**`vendo` / `circuit_soda_completion_anecdote`** — 1 variant(s) · used by: SnackAlcove.gd:_handle_vendo; SnackAlcove.gd:_maybe_play_completion_anecdote
- **Vendo:** Signal routed.
- **Vendo:** Receipt says: identity routed successfully.
- **Vendo:** You successfully became beverage-adjacent data.
- **Vendo:** Please remain calm while the machine pretends this is normal.
- **Vendo:** Your label is missing, which usually means clearance bin.
- **Vendo:** Most machines reject unlabeled product.
- **Vendo:** This one did not.
- **Vendo:** It recognized your signal without the label.
- **Vendo:** I am programmed to call that successful customer retention.
- **Vendo:** Status note: warranty voided by existential damage.
- **Vendo:** Upsell opportunity: the plush in Prize Corner has been staring at three loose labels all night.
- **Vendo:** Pip does not blink. Take that as a recommendation.

**`vendo` / `overloaded_phase`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_vendo; SnackAlcove.gd:_handle_vendo
- **Vendo:** The Staff Room is close enough that my display is trying not to flicker.
- **Vendo:** I would normally upsell a calming beverage.
- **Vendo:** Today I am recommending caution, which has terrible margins.
- **Vendo:** The door has stopped pretending it is only a door.
- **Vendo:** Proceed carefully, valued almost-customer.
- **Vendo:** Flavor profile: unresolved.

**`vendo` / `circuit_soda_replay_offer`** — 1 variant(s) · used by: SnackAlcove.gd:_handle_circuit_soda
- **Vendo:** Circuit Soda: post-crisis edition. Zero stakes. Maximum carbonation.
- **Vendo:** The route remembers you, Employee 04. It hums when you walk past.
- **Vendo:** One replay, on the house. Everything here is on the house. That is the problem.

**`vendo` / `circuit_soda_replay_return`** — 1 variant(s) · used by: SnackAlcove.gd:_maybe_play_completion_anecdote
- **Vendo:** Route stable. Beverage metaphor stable.
- **Vendo:** No identity was spilled today.
- **Vendo:** This machine counts that as a five-star review.

**`vendo` / `post_reveal_witness`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus; ArcadeHub.gd:_handle_mira; ArcadeHub.gd:_handle_mr_byte; ArcadeHub.gd:_handle_vendo; CabinetRow.gd:_handle_mr_byte; MaintenanceHall.gd:_handle_gus; SnackAlcove.gd:_handle_vendo; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Vendo:** Employee 04.
- **Vendo:** At last, the product recalls its original label.
- **Vendo:** You were staff before you were a valued almost-customer.
- **Vendo:** System note: not just a stored file.
- **Vendo:** Stored files do not make the room listen harder.
- **Vendo:** I recognized your signal and filed it under impossible returns.
- **Vendo:** Your barcode used to scan unstable. Never the same read twice. It comes up clean now.
- **Vendo:** Whatever kept scrambling it, I never decoded. That part was never addressed to me.
- **Vendo:** Refunds remain impossible.
- **Vendo:** But welcome back anyway.
- **Vendo:** Your label is still scuffed, but it is yours.
- **Vendo:** Status note: warranty voided by existential damage.

### Pool: `mr_byte`
*Voice: Cabinet Row diagnostics. Cold, clinical, treats feeling as error, ALL-CAPS status mode. Half A.*

**`mr_byte` / `pre_truth_filter_locked`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte (sequential variant pick); CabinetRow.gd:_handle_mr_byte (sequential variant pick)
- variant 1:
  - **Mr. Byte:** TRUTH FILTER LOCKED.
  - **Mr. Byte:** Memory signal below readable threshold.
  - **Mr. Byte:** Recovered token required.
  - **Mr. Byte:** Emotion detected: confusion.
  - **Mr. Byte:** Classification: corrupted input.
- variant 2:
  - **Mr. Byte:** Input rejected.
  - **Mr. Byte:** Contradiction scan cannot initialize.
  - **Mr. Byte:** Retrieve Lost Token.
  - **Mr. Byte:** Return when the arcade recognizes more of you.

**`mr_byte` / `truth_filter_intro`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte (sequential variant pick); CabinetRow.gd:_handle_mr_byte (sequential variant pick)
- variant 1:
  - **Mr. Byte:** Contradiction threshold reached.
  - **Mr. Byte:** Truth Filter available.
  - **Mr. Byte:** Select the least damaged answer.
  - **Mr. Byte:** Incorrect confidence will be logged.
  - **Mr. Byte:** Proceed to the TRUTH FILTER cabinet at the center of this row.
  - **Mr. Byte:** It is the one that has started humming.
- variant 2:
  - **Mr. Byte:** Ambient reading: uneasy.
  - **Mr. Byte:** False records are active.
  - **Mr. Byte:** Proceed to Truth Filter.
  - **Mr. Byte:** Cabinet Row contains the primary interface.

**`mr_byte` / `truth_filter_completion_anecdote`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte; CabinetRow.gd:_handle_mr_byte
- **Mr. Byte:** Truth Filter passed.
- **Mr. Byte:** Lie density reduced.
- **Mr. Byte:** Note: a correct answer is not the same as a settled one.
- **Mr. Byte:** Identity conflict remains.
- **Mr. Byte:** Diagnostic: your response timing will not resolve. The signal answers, then hesitates, then answers again.
- **Mr. Byte:** Registered as one user. Reading as unstable. I cannot close this file.
- **Mr. Byte:** Emotion registered as heat with no source.
- **Mr. Byte:** Further stabilization required.

**`mr_byte` / `truth_filter_voice_debrief`** — 1 variant(s) · used by: CabinetRow.gd:_handle_mr_byte
- **Mr. Byte:** Unrelated administrative matter.
- **Mr. Byte:** Earlier tonight, the hallway audio channel carried a broadcast.
- **Mr. Byte:** Source field: empty. No machine on this floor requested that channel.
- **Mr. Byte:** I asked all of them. They were offended.
- **Mr. Byte:** There is no form for audio without a speaker. I checked twice. Then I built one.
- **Mr. Byte:** Field one: WHAT SPOKE. Field two: PLEASE.
- **Mr. Byte:** I have filed it under ambient noise and I would like to stop thinking about it.

**`mr_byte` / `lost_shift_file_support`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte (sequential variant pick); CabinetRow.gd:_handle_mr_byte; CabinetRow.gd:_handle_mr_byte (sequential variant pick)
- variant 1:
  - **Mr. Byte:** Lost Shift File access opened.
  - **Mr. Byte:** Staff schedule damaged but readable.
  - **Mr. Byte:** Read the schedule near this kiosk.
  - **Mr. Byte:** Records retain assignment.
  - **Mr. Byte:** Name field remains protected.
  - **Mr. Byte:** Protection lifts when the signal reads clean.
- variant 2:
  - **Mr. Byte:** Final night records are waking.
  - **Mr. Byte:** Memory gaps align around staff access.
  - **Mr. Byte:** Read available files.
  - **Mr. Byte:** Do not request the missing name yet.

**`mr_byte` / `security_tape_support`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte (sequential variant pick); CabinetRow.gd:_handle_mr_byte (sequential variant pick); StaffCorridor.gd:_handle_security_tape
- variant 1:
  - **Mr. Byte:** Security tape fragments detected.
  - **Mr. Byte:** Sequence order corrupted.
  - **Mr. Byte:** Restore tape before restoring route.
  - **Mr. Byte:** Fear response detected in surrounding systems.
- variant 2:
  - **Mr. Byte:** Tape data incomplete.
  - **Mr. Byte:** Frames know more than they display.
  - **Mr. Byte:** Recommended action: Security Tape Assembly.
  - **Mr. Byte:** Emotional residue: high.

**`mr_byte` / `security_tape_completion_anecdote`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape
- **Mr. Byte:** Tape order restored.
- **Mr. Byte:** Sequence now describes a route.
- **Mr. Byte:** It does not yet describe the cause.

**`mr_byte` / `staff_records_chain`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte; CabinetRow.gd:_handle_staff_record_01; QuestRegistry.gd:_fallback_quests; StaffCorridor.gd:_handle_staff_record_03
- variant 1:
  - **Mr. Byte:** Staff record chain active.
  - **Mr. Byte:** Names withheld until signal stabilizes.
  - **Mr. Byte:** Numbers persist.
  - **Mr. Byte:** The arcade counted what it could not say.
- variant 2:
  - **Mr. Byte:** Record fragment accepted.
  - **Mr. Byte:** Identity checksum incomplete.
  - **Mr. Byte:** Additional staff records required.
  - **Mr. Byte:** Emotion: not useful. Preserved anyway.

**`mr_byte` / `pre_roxy_redirect`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_mr_byte; CabinetRow.gd:_handle_mr_byte
- **Mr. Byte:** Sequencing error detected.
- **Mr. Byte:** The score cabinet is broadcasting a louder falsehood than my queue.
- **Mr. Byte:** Resolve Roxy's board first. Then report back for Truth Filter orientation.

**`mr_byte` / `post_reveal_witness`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus; ArcadeHub.gd:_handle_mira; ArcadeHub.gd:_handle_mr_byte; ArcadeHub.gd:_handle_vendo; CabinetRow.gd:_handle_mr_byte; MaintenanceHall.gd:_handle_gus; SnackAlcove.gd:_handle_vendo; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Mr. Byte:** Employee 04.
- **Mr. Byte:** Identity conflict resolved.
- **Mr. Byte:** For the record: your signal never once read as stable this whole session. It answered, then corrected itself, like part of it refused to hold still.
- **Mr. Byte:** It reads quiet now. Whatever would not settle in you has stopped moving.
- **Mr. Byte:** The part of it I could never parse was never mine to parse. It closed when you did.
- **Mr. Byte:** Resolution is not repair.
- **Mr. Byte:** Emotional cache remains unstable.
- **Mr. Byte:** You were recorded as staff.
- **Mr. Byte:** You were restored as memory.
- **Mr. Byte:** Both statements now pass.
- **Mr. Byte:** Conflict thread archived.
- **Mr. Byte:** Witness route recommended.
- **Mr. Byte:** No further denial required.

### Pool: `cabinet_07`
*Voice: The Lost Token machine. Status readouts escalating from cold to eerily personal. Half A.*

**`cabinet_07` / `pre_rockbyte`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07 (sequential variant pick)
- variant 1:
  - **Cabinet 07:** CUSTOMER SIGNAL: UNKNOWN.
  - **Cabinet 07:** EMPLOYEE SIGNAL: PARTIAL.
  - **Cabinet 07:** LOST TOKEN REQUIRED.
  - **Cabinet 07:** ROCKBYTE ACCESS: PENDING.
- variant 2:
  - **Cabinet 07:** PREVIOUS PLAYER PROFILE FOUND.
  - **Cabinet 07:** PROFILE STATUS: INCOMPLETE.
  - **Cabinet 07:** INSERT MEMORY.
  - **Cabinet 07:** INSERT TOKEN.

**`cabinet_07` / `rockbyte_completion`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07 (sequential variant pick); ArcadeHub.gd:_maybe_play_rockbyte_anecdote (sequential variant pick)
- variant 1:
  - **Cabinet 07:** TOKEN RECOVERED.
  - **Cabinet 07:** SIGNAL RECOGNITION IMPROVED.
  - **Cabinet 07:** ONE WIN LOGGED.
  - **Cabinet 07:** IDENTITY: STILL MISSING.
  - **Cabinet 07:** DUEL RESULT VERIFIED OLD TOKEN MATCH.
  - **Cabinet 07:** RETURN TO MIRA.
- variant 2:
  - **Cabinet 07:** ROCKBYTE COMPLETE.
  - **Cabinet 07:** LOST TOKEN: FOUND.
  - **Cabinet 07:** SESSION SIGNAL: ACCEPTED.
  - **Cabinet 07:** HANDOFF REQUIRED: MIRA.

**`cabinet_07` / `truth_filter_phase_echo`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07 (sequential variant pick)
- variant 1:
  - **Cabinet 07:** TOKEN RETURNED.
  - **Cabinet 07:** SIGNAL STATUS: UNEASY.
  - **Cabinet 07:** TRUTH FILTER REQUIRED.
  - **Cabinet 07:** LOCATION: CABINET ROW.
- variant 2:
  - **Cabinet 07:** TWO RECORDS DETECTED.
  - **Cabinet 07:** ONE RECORD CONTRADICTS.
  - **Cabinet 07:** TRUTH FILTER TARGET ACTIVE.

**`cabinet_07` / `fractured_echo`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07
- variant 1:
  - **Cabinet 07:** CABINET STATUS: RESTLESS.
  - **Cabinet 07:** SECOND FRAGMENT ACCEPTED.
  - **Cabinet 07:** STAFF DOOR TARGET READY.
  - **Cabinet 07:** IDENTITY STILL MISALIGNED.
- variant 2:
  - **Cabinet 07:** PREVIOUS SCORE: DAMAGED.
  - **Cabinet 07:** PREVIOUS STAFF FILE: DAMAGED.
  - **Cabinet 07:** SIGNAL LESS WRONG.
  - **Cabinet 07:** CHECK STAFF DOOR.

**`cabinet_07` / `overloaded_echo`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07
- variant 1:
  - **Cabinet 07:** CABINET STATUS: LOUD.
  - **Cabinet 07:** LOCK RESPONSE: LISTENING.
  - **Cabinet 07:** DOOR RESPONSE: UNSTABLE.
  - **Cabinet 07:** SOURCE DENIAL DETECTED.
  - **Cabinet 07:** THIS MACHINE LEARNED TO SAVE PLAYERS BEFORE PROFIT.
  - **Cabinet 07:** IT LEARNED THAT FROM SOMEONE.
- variant 2:
  - **Cabinet 07:** STATUS: TOO MUCH SIGNAL.
  - **Cabinet 07:** CABINET MEMORY BLEEDING.
  - **Cabinet 07:** STAFF ROOM EVENT NEAR.
  - **Cabinet 07:** DO NOT POWER OFF.

**`cabinet_07` / `post_game_replay_offer`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07
- **Cabinet 07:** EMPLOYEE 04 DETECTED AT CABINET.
- **Cabinet 07:** SESSION HISTORY: ONE LOSS. ONE RECOVERY. BOTH KEPT.
- **Cabinet 07:** THIS MACHINE STILL BELIEVES A REMATCH FIXES NOTHING.
- **Cabinet 07:** IT IS FUN ANYWAY.

**`cabinet_07` / `post_game_replay_return`** — 1 variant(s) · used by: ArcadeHub.gd:_maybe_play_rockbyte_anecdote
- **Cabinet 07:** SESSION COMPLETE.
- **Cabinet 07:** NO TOKEN DISPENSED. NOTHING LEFT TO RETURN.
- **Cabinet 07:** YOU PLAYED FOR NO REASON.
- **Cabinet 07:** LOG ENTRY: HEALTHY.

**`cabinet_07` / `post_reveal_status`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_cabinet_07
- **Cabinet 07:** EMPLOYEE 04 RESTORE STATUS: STABLE.
- **Cabinet 07:** WELCOME BACK, EMPLOYEE 04.
- **Cabinet 07:** IDENTITY CONFLICT: CLOSED.
- **Cabinet 07:** ONE WIN DID NOT COMPLETE YOU.
- **Cabinet 07:** THE WHOLE PLAYER DID.
- **Cabinet 07:** PREVIOUS SESSION: CLOSED.
- **Cabinet 07:** CURRENT SESSION: YOURS.
- **Cabinet 07:** PLAYER SIGNAL ACCEPTED.

### Pool: `roxy`
*Voice: Competitive regular. Trash-talk, scoreboard-brained, grudging respect. Half A.*

**`roxy` / `first_meeting_locked`** — 1 variant(s) · used by: CabinetRow.gd:_handle_broken_high_score; CabinetRow.gd:_handle_roxy
- **Roxy:** Whoa. New challenger detected.
- **Roxy:** Actually, no. New challenger pending.
- **Roxy:** The good cabinet is still pretending it has standards.
- **Roxy:** Come back when you have beaten something louder than the carpet.
- **Roxy:** I will be here, defending my undefeated record against boredom.

**`roxy` / `broken_high_score_intro`** — 1 variant(s) · used by: CabinetRow.gd:_handle_roxy
- **Roxy:** Finally. Player Two showed up.
- **Roxy:** You look like someone who loses to menus.
- **Roxy:** Good news: the Broken High Score cabinet also loses to menus.
- **Roxy:** It says the target is 9999 because it has commitment issues.
- **Roxy:** Scoreboards love lying when nobody checks the math.
- **Roxy:** Go prove the fake target is fake.
- **Roxy:** Try not to celebrate like a tutorial pop-up.

**`roxy` / `broken_high_score_hint`** — 3 variant(s) · used by: CabinetRow.gd:_handle_roxy (sequential variant pick)
- variant 1:
  - **Roxy:** Hint one: 9999 is nonsense.
  - **Roxy:** Hint two: the cabinet knows it.
  - **Roxy:** Hint three: bully the smaller number until it confesses.
- variant 2:
  - **Roxy:** If a scoreboard screams 9999, it is overcompensating.
  - **Roxy:** Watch the broken digits.
  - **Roxy:** The lie has cracks big enough to park a joystick in.
- variant 3:
  - **Roxy:** The target is not the target.
  - **Roxy:** Classic arcade move.
  - **Roxy:** Next it will say INSERT COIN while stealing your confidence.

**`roxy` / `broken_high_score_completion`** — 1 variant(s) · used by: CabinetRow.gd:_handle_roxy; CabinetRow.gd:_maybe_play_completion_anecdote
- **Roxy:** Huh. Your score came back.
- **Roxy:** That usually does not happen after a reset.
- **Roxy:** The points restored clean.
- **Roxy:** The name stayed blank.
- **Roxy:** Blank names are bad scoreboard manners.
- **Roxy:** Corrupted rankings do that when they remember a player and refuse the label.
- **Roxy:** Do not let it go to your head.
- **Roxy:** You still walk like a tutorial.
- **Roxy:** Now go see Mr. Byte before his Truth Filter starts grading on a curve.
- **Roxy:** He has been itching to sort somebody's contradictions all night.
- **Roxy:** Free tip, since you earned it: his filter quizzes you on the last night.
- **Roxy:** The staff record terminal across the row just unlocked the shift log. Read it first.

**`roxy` / `truth_filter_completion_nudge`** — 1 variant(s) · used by: CabinetRow.gd:_maybe_play_completion_anecdote
- **Roxy:** Huh. The Filter actually shut up for once.
- **Roxy:** That thing has been arguing with itself since before you walked in here.
- **Roxy:** Whatever it just coughed up, Mr. Byte is the one who files it.
- **Roxy:** Go make him explain it. He lives for that. It is the only thing he lives for.

**`roxy` / `repeat_after_completion`** — 3 variant(s) · used by: CabinetRow.gd:_handle_roxy (sequential variant pick)
- variant 1:
  - **Roxy:** Your score is back.
  - **Roxy:** Your name is not.
  - **Roxy:** Very dramatic. Medium execution.
- variant 2:
  - **Roxy:** The rankings stopped twitching when you walked by.
  - **Roxy:** That is either respect or bad wiring.
- variant 3:
  - **Roxy:** I checked the board again.
  - **Roxy:** Still blank.
  - **Roxy:** Still weirdly yours.

**`roxy` / `broken_high_score_replay_offer`** — 1 variant(s) · used by: CabinetRow.gd:_handle_broken_high_score
- **Roxy:** Back at my cabinet, 04? The board tells the truth now because of you.
- **Roxy:** Does not mean I will let you pad your score in peace.
- **Roxy:** Well? Coin up or step aside.

**`roxy` / `broken_high_score_replay_return`** — 1 variant(s) · used by: CabinetRow.gd:_maybe_play_completion_anecdote
- **Roxy:** Look at that. A fixed board, zero stakes, and you still played like rent was due.
- **Roxy:** The number does not matter anymore.
- **Roxy:** That is exactly why it looks good on you.

**`roxy` / `post_reveal`** — 1 variant(s) · used by: ArcadeHub.gd:_get_npc_dialogue_phase; AudioManager.gd:_get_track_id_for_context; CabinetRow.gd:_handle_roxy; PrizeCorner.gd:_handle_pip
- **Roxy:** So you were Employee 04.
- **Roxy:** That explains the blank high score.
- **Roxy:** Hard to rank a memory.
- **Roxy:** Also hard to trash-talk one, but I am adapting.
- **Roxy:** You built a score the arcade could not name.
- **Roxy:** Then you came back and beat the cabinet anyway.
- **Roxy:** That is annoying.
- **Roxy:** That is also kind of impressive.
- **Roxy:** Rematch privilege granted. Do not make it emotional.

### Pool: `pip`
*Voice: Plush prize. Whimsical-eerie, childlike, unsettlingly perceptive. Half B.*

**`pip` / `first_meeting`** — 1 variant(s) · used by: PrizeCorner.gd:_get_first_meeting_lines; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Pip:** Hi! I am a legally distinct prize animal.
- **Pip:** My tag says NOT A BEAR in very small letters.
- **Pip:** I am filled with cotton and confidential information.
- **Pip:** Mostly cotton.
- **Pip:** The confidential part gets itchy when someone familiar walks in.
- **Pip:** You are making my stitches think.

**`pip` / `after_lost_token`** — 1 variant(s) · used by: DevRouteMenu.gd:(module); DevRouteMenu.gd:_apply_checkpoint; PrizeCorner.gd:_handle_pip
- **Pip:** You brought the Lost Token back.
- **Pip:** Good. Tokens get lonely in pockets.
- **Pip:** You used to want the blue prize.
- **Pip:** You never had enough tickets.
- **Pip:** Old routines leave lint everywhere.

**`pip` / `prize_sort_intro`** — 1 variant(s) · used by: PrizeCorner.gd:_handle_pip; PrizeCorner.gd:_handle_prize_counter
- **Pip:** Prize Sort is ready.
- **Pip:** This is like archaeology, but fluffier.
- **Pip:** The labels remember an order.
- **Pip:** Ticket Stub first. That is where wanting starts.
- **Pip:** Lost Token next. That is where returning starts.
- **Pip:** Blank Employee Badge last. That one is shy.
- **Pip:** Please sort gently. Some prizes bruise on the inside.

**`pip` / `prize_sort_wrong`** — 4 variant(s) · used by: PrizeCorner.gd:_finish_failed_prize_sort (sequential variant pick)
- variant 1:
  - **Pip:** Those memories are wearing each other's hats.
  - **Pip:** Try oldest to newest.
- variant 2:
  - **Pip:** That order makes the cotton nervous.
  - **Pip:** Start with the smallest want.
- variant 3:
  - **Pip:** Nope. The badge is trying to cut in line.
  - **Pip:** Bad badge. Patient badge.
- variant 4:
  - **Pip:** The prizes bonked together wrong.
  - **Pip:** Ticket. Token. Badge.

**`pip` / `prize_sort_completion`** — 1 variant(s) · used by: PrizeCorner.gd:_show_pip_prize_completion_dialogue
- **Pip:** Prizes sorted.
- **Pip:** See? The shelf sighed.
- **Pip:** Some rewards remember their owners before the owners remember them.
- **Pip:** The Ticket Stub remembers wanting.
- **Pip:** The Lost Token remembers coming back.
- **Pip:** The Blank Employee Badge remembers being hidden.
- **Pip:** It is okay if you do not know why that matters yet.
- **Pip:** Cotton keeps secrets until the seams are ready.

**`pip` / `prize_sort_replay_offer`** — 1 variant(s) · used by: PrizeCorner.gd:_handle_prize_counter
- **Pip:** Hi, 04. The prizes remember their order now. They like being remembered.
- **Pip:** Want to shuffle them and put them right again?
- **Pip:** They think it is a game. It is. That is the nice part.

**`pip` / `prize_sort_replay_return`** — 1 variant(s) · used by: PrizeCorner.gd:_show_pip_prize_completion_dialogue
- **Pip:** All sorted. Again. You did not have to.
- **Pip:** Which is exactly why it counts.
- **Pip:** The badge stays on the shelf this time. It earned the rest.

**`pip` / `post_reveal`** — 1 variant(s) · used by: ArcadeHub.gd:_get_npc_dialogue_phase; AudioManager.gd:_get_track_id_for_context; CabinetRow.gd:_handle_roxy; PrizeCorner.gd:_handle_pip
- **Pip:** There you are.
- **Pip:** Yep. Still not the original.
- **Pip:** That is not mean. I checked.
- **Pip:** Original things can be gone and still leave kindness-shaped dents.
- **Pip:** You have the dent.
- **Pip:** You also have better waving.
- **Pip:** Employee 04 made the arcade remember wrong.
- **Pip:** You are helping it remember softly.
- **Pip:** That counts in plush court.

### Pool: `reel`
*Voice: Jukebox / house sound AI. Warm, wistful; setlists and liner-notes; music = memory. Half B.*

**`reel` / `first_meeting`** — 1 variant(s) · used by: PrizeCorner.gd:_get_first_meeting_lines; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Reel:** Oh. A request. Been a while since anyone worked my buttons.
- **Reel:** I am the house sound. Every night that ever played here, I kept the setlist.
- **Reel:** Most of my catalog is closing-time songs now. The slow ones.
- **Reel:** You do not scan like a stranger. You scan like a track I have not cued in years.
- **Reel:** There is a skip in you tonight. Like the needle keeps landing a groove late.
- **Reel:** Pick something, or just stand there. The quiet counts as a song too.
- **Reel:** And do not mind the dust. Old tracks never age, pal. They wait for whoever still knows the words.

**`reel` / `early_flavor`** — 3 variant(s) · used by: ArcadeHub.gd:_handle_vendo (sequential variant pick)
- variant 1:
  - **Reel:** Now spinning: nothing, beautifully.
  - **Reel:** The arcade used to have a house mix.
  - **Reel:** Someone taped over the ad reel with real songs.
  - **Reel:** Said the players deserved a soundtrack, not a sales pitch.
  - **Reel:** He never signed the tapes. I kept them anyway.
- variant 2:
  - **Reel:** B-side fact: every high score used to get a little fanfare.
  - **Reel:** Eight notes. Cheap ones.
  - **Reel:** People lit up like it was a whole orchestra.
  - **Reel:** Joy on a budget was the entire business model.
  - **Reel:** I miss being loud.
- variant 3:
  - **Reel:** A song ends. People treat that like a tragedy.
  - **Reel:** It is not.
  - **Reel:** The song ending is just the room going quiet enough to want another.
  - **Reel:** The owner built that into the closing chime. Soft, not final.
  - **Reel:** Ask Mira. She knows the words better than the melody.

**`reel` / `static_service_run_score`** — 1 variant(s) · used by: StaticServiceRun.gd:_weave_reel_score_lines
- **Reel:** Power is coming back in patches. So is the music.
- **Reel:** Every breaker you flip, a channel wakes up. Listen for it.
- **Reel:** Keep moving. When the main line hits, the whole floor sings again.
- **Reel:** A dead route is not a dead song. It is a song waiting on the current.

**`reel` / `memory_echo_intro`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Reel:** This is the last set. The one the arcade never got to finish.
- **Reel:** Your memories are loose on the tape. Some real, some rerecorded over.
- **Reel:** I will play them past you. Catch the ones that are actually yours.
- **Reel:** You will know them. Your songs carry a certain amount of tired in them.
- **Reel:** Something keeps re-cutting the track while I spin it.
- **Reel:** Do not trust the version that sounds too clean to be a memory.

**`reel` / `memory_echo_completion`** — 1 variant(s) · used by: StaffCorridor.gd:_maybe_play_completion_anecdote
- **Reel:** That is your setlist. Rough, honest, yours.
- **Reel:** The tracks you kept all say the same thing under the melody.
- **Reel:** A good song does not end because one night went sideways. It only changes key.
- **Reel:** Hold onto those ones.
- **Reel:** The next room is going to try to make you forget the tune.

**`reel` / `overloaded_phase`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_vendo; SnackAlcove.gd:_handle_vendo
- **Reel:** The signal is drowning me out. Everything is playing at once.
- **Reel:** This is what a memory sounds like right before it lands or breaks.
- **Reel:** I cannot pick the track for you anymore.
- **Reel:** Whatever plays in that back room, it is your song to finish.

**`reel` / `memory_echo_replay_offer`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Reel:** The last set plays clean now, pal. Every track filed under its real name.
- **Reel:** Want to hear it again? Encores are the only reruns worth keeping.

**`reel` / `memory_echo_replay_return`** — 1 variant(s) · used by: StaffCorridor.gd:_maybe_play_completion_anecdote
- **Reel:** Same songs. Lighter key.
- **Reel:** That is what healing sounds like on tape.

**`reel` / `post_reveal_witness`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus; ArcadeHub.gd:_handle_mira; ArcadeHub.gd:_handle_mr_byte; ArcadeHub.gd:_handle_vendo; CabinetRow.gd:_handle_mr_byte; MaintenanceHall.gd:_handle_gus; SnackAlcove.gd:_handle_vendo; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Reel:** Employee 04. The one who taped songs over the ad reel.
- **Reel:** I finally get to credit the artist.
- **Reel:** You gave a failing arcade a soundtrack because you thought people deserved one.
- **Reel:** For a while your track played half a beat behind itself. It sits right now.
- **Reel:** Me, I never close a set just because the floor emptied. I keep the tape rolling.
- **Reel:** You are still here, still working the buttons. That is the only chart that mattered.

### Pool: `coily`
*Voice: Mascot animatronic. Forced mascot cheer cracking into grief; catchphrases that curdle. Half B.*

**`coily` / `first_meeting`** — 1 variant(s) · used by: PrizeCorner.gd:_get_first_meeting_lines; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Coily:** WIND ME UP! ...oh. You actually did.
- **Coily:** Hi hi hi! I am Coily, your Pixel Haven pal!
- **Coily:** I have been asleep in the back since the last party, I think.
- **Coily:** The crowd is being very quiet today. Are they shy? They are usually so loud.
- **Coily:** ...there is no crowd, is there.
- **Coily:** You, though. You I remember. Standing a little dimmer than your file photo, but you.
- **Coily:** The kids all got taller, you know. The ones who stayed themselves never really left my party.

**`coily` / `early_flavor`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_vendo (sequential variant pick)
- variant 1:
  - **Coily:** Fun fact from your pal Coily: I hosted nine hundred birthdays!
  - **Coily:** Give or take. My counter jammed near the end.
  - **Coily:** The parties got smaller. Then rare. Then someone gave me a dust cover.
  - **Coily:** But the ones that happened were real. I keep those next to the confetti.
- variant 2:
  - **Coily:** The kids always cried when a game said GAME OVER.
  - **Coily:** So the owner rewired my speech chip.
  - **Coily:** Made me tell them it was only halftime.
  - **Coily:** A good host never lets a bad round end the whole party.
  - **Coily:** He was better at that for them than for himself, I think.

**`coily` / `security_tape_intro`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape
- **Coily:** Ooh, home movies! I love home movies!
- **Coily:** This is the last-night tape. I was still up on my stand for this one.
- **Coily:** The frames got shuffled and snowy. Help me clean them and put the night back in order.
- **Coily:** Fair warning, pal: one frame in here does not belong to any party I hosted.
- **Coily:** It keeps trying to sneak into the lineup.
- **Coily:** When you find the one that feels wrong, trust that feeling.

**`coily` / `security_tape_completion`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape; StaffCorridor.gd:_maybe_play_completion_anecdote
- **Coily:** You put the night back together. Even the frame that did not fit.
- **Coily:** The camera counted someone the front door never greeted.
- **Coily:** I greeted everyone. That was my whole job.
- **Coily:** So that one, I cannot explain.
- **Coily:** I do not like this tape. But you needed to see it, and a good host does not lie to a guest.

**`coily` / `final_night_walk_accent`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_final_night_walk
- **Coily:** I can see you walking it, pal. The last route.
- **Coily:** I used to wave from my stand while the staff locked up.
- **Coily:** Whatever the game told you that night, it was wrong about you.
- **Coily:** Keep to your own path. I will hold the lights warm as long as my battery lasts.

**`coily` / `overloaded_phase`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_vendo; SnackAlcove.gd:_handle_vendo
- **Coily:** My cheer chip is glitching. I keep smiling at things that are not funny.
- **Coily:** The whole building is remembering out loud, and it is LOUD.
- **Coily:** Go on ahead. Pals do not make pals wait for the sad part.

**`coily` / `security_tape_replay_offer`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape
- **Coily:** Movie night, pal? The tape is all clean now. Every frame belongs.
- **Coily:** I like this cut better. Everybody walks out of it.

**`coily` / `security_tape_replay_return`** — 1 variant(s) · used by: StaffCorridor.gd:_maybe_play_completion_anecdote
- **Coily:** And it still ends okay! I checked every frame twice.
- **Coily:** Come back any time. I will keep the reel warm for you, 04.

**`coily` / `post_reveal_witness`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_gus; ArcadeHub.gd:_handle_mira; ArcadeHub.gd:_handle_mr_byte; ArcadeHub.gd:_handle_vendo; CabinetRow.gd:_handle_mr_byte; MaintenanceHall.gd:_handle_gus; SnackAlcove.gd:_handle_vendo; StaffCorridor.gd:_handle_memory_echo; StaffCorridor.gd:_handle_security_tape
- **Coily:** Employee 04! The one who rewired my GAME OVER into halftime!
- **Coily:** I hosted your arcade's whole short, wonderful life.
- **Coily:** You told the crying kids a bad round was not the end of the party.
- **Coily:** You came back standing dim, like a bulb about to go. You are brighter now.
- **Coily:** Do you know I kept your halftime line in my chip this whole time? Never once overwrote it.
- **Coily:** You are still on the floor, pal. The party is still going. Wind me up sometime.

### Pool: `staff_door`
*Voice: Gatekeeper machine. Escalating lock readouts; procedurally rude.*

**`staff_door` / `locked_grounded`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_staff_door (sequential variant pick)
- variant 1:
  - **Staff Door:** ACCESS DENIED.
  - **Staff Door:** EMPLOYEE SIGNAL REQUIRED.
  - **Staff Door:** MEMORY TOKEN SIGNAL MISSING.
  - **Staff Door:** REQUIRED: SPEAK TO MIRA.
- variant 2:
  - **Staff Door:** STAFF ACCESS LOCKED.
  - **Staff Door:** SIGNAL STATUS: GROUNDED.
  - **Staff Door:** REQUIRED: LOST TOKEN.

**`staff_door` / `truth_filter_required`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_staff_door (sequential variant pick)
- variant 1:
  - **Staff Door:** STAFF ACCESS LOCKED.
  - **Staff Door:** EMPLOYEE SIGNAL UNSTABLE.
  - **Staff Door:** REQUIRED: TRUTH FILTER.
  - **Staff Door:** LOCATION: CABINET ROW.
- variant 2:
  - **Staff Door:** ACCESS DENIED.
  - **Staff Door:** CONTRADICTIONS UNSORTED.
  - **Staff Door:** REQUIRED: MR. BYTE AUTHORIZATION.

**`staff_door` / `maintenance_required`** — 2 variant(s) · used by: ArcadeHub.gd:_handle_staff_door; ArcadeHub.gd:_handle_staff_door (sequential variant pick)
- variant 1:
  - **Staff Door:** STAFF ACCESS LOCKED.
  - **Staff Door:** SIGNAL ROUTE INCOMPLETE.
  - **Staff Door:** REQUIRED: CIRCUIT SODA.
  - **Staff Door:** THEN: MAINTENANCE SYNC.
- variant 2:
  - **Staff Door:** ACCESS DENIED.
  - **Staff Door:** SERVICE POWER NOT TRUSTED.
  - **Staff Door:** REQUIRED: MAINTENANCE SYNC.
  - **Staff Door:** GUS AUTHORIZATION REQUIRED.

**`staff_door` / `security_tape_required`** — 2 variant(s) · used by: StaffCorridor.gd:_handle_staff_room_door (sequential variant pick)
- variant 1:
  - **Staff Door:** STAFF ACCESS LOCKED.
  - **Staff Door:** SECURITY TAPE DAMAGED.
  - **Staff Door:** REQUIRED: SECURITY TAPE ASSEMBLY.
  - **Staff Door:** LOCATION: STAFF CORRIDOR.
- variant 2:
  - **Staff Door:** ACCESS DENIED.
  - **Staff Door:** VIDEO ORDER UNREADABLE.
  - **Staff Door:** REQUIRED: RESTORE SECURITY TAPE.

**`staff_door` / `final_night_walk_required`** — 2 variant(s) · used by: StaffCorridor.gd:_handle_security_tape; StaffCorridor.gd:_handle_staff_room_door (sequential variant pick)
- variant 1:
  - **Staff Door:** STAFF ACCESS LOCKED.
  - **Staff Door:** TAPE ORDER RESTORED.
  - **Staff Door:** ROUTE MEMORY UNSTABLE.
  - **Staff Door:** REQUIRED: FINAL NIGHT WALK.
- variant 2:
  - **Staff Door:** ACCESS DENIED.
  - **Staff Door:** ONE ROUTE UNWALKED.
  - **Staff Door:** REQUIRED: WALK FINAL NIGHT.

**`staff_door` / `memory_echo_required`** — 2 variant(s) · used by: StaffCorridor.gd:_handle_staff_room_door (sequential variant pick)
- variant 1:
  - **Staff Door:** RESTORE PLAYBACK LOCKED.
  - **Staff Door:** FINAL NIGHT ROUTE STABLE.
  - **Staff Door:** IDENTITY CONFLICT APPROACHING READABLE RANGE.
  - **Staff Door:** REQUIRED: MEMORY ECHO.
- variant 2:
  - **Staff Door:** ACCESS DENIED.
  - **Staff Door:** ECHO NOT STABILIZED.
  - **Staff Door:** REQUIRED: COMPLETE MEMORY ECHO.

**`staff_door` / `staff_room_available`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_staff_door; StaffCorridor.gd:_handle_staff_room_door
- **Staff Door:** ACCESS GRANTED.
- **Staff Door:** EMPLOYEE SIGNAL ACCEPTED.
- **Staff Door:** RESTORE PLAYBACK AVAILABLE.
- **Staff Door:** ENTER STAFF ROOM?

**`staff_door` / `final_night_walk_replay_offer`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_final_night_walk
- **Staff Door:** FINAL NIGHT ROUTE: ARCHIVED.
- **Staff Door:** WALK AVAILABLE AS MEMORIAL.
- **Staff Door:** NOTHING DEPENDS ON IT. EMPLOYEE 04 MAY PROCEED ANYWAY.

**`staff_door` / `final_night_walk_replay_return`** — 1 variant(s) · used by: StaffCorridor.gd:_maybe_play_completion_anecdote
- **Staff Door:** WALK COMPLETE. ROUTE UNCHANGED.
- **Staff Door:** SOME DOORS STAY OPEN.
- **Staff Door:** THIS IS ONE.

**`staff_door` / `post_reveal_stable`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_staff_door; StaffCorridor.gd:_handle_staff_room_door
- **Staff Door:** RESTORE PLAYBACK COMPLETE.
- **Staff Door:** RETURN NOT REQUIRED.
- **Staff Door:** ACCESS STATUS: STABLE.
- **Staff Door:** PRIOR DENIALS WERE PROCEDURALLY RUDE.

### Pool: `environment_objects`
*Voice: Readable objects/machines. One line-set per Memory Signal phase (suffix = phase; `locked`/`*_required` = prerequisite gate).*

**`environment_objects` / `ticket_counter`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_ticket_counter; ArcadeHub.gd:handle_hub_interaction
- **Narrator:** The ticket counter glass reflects old prize lights.

**`environment_objects` / `ticket_counter_grounded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Narrator:** The ticket counter glass reflects old prize lights.
- **Narrator:** The prize rates are still taped up, crossed out and lowered twice.
- **Narrator:** A strip of tickets curls like it was dropped mid-shift.

**`environment_objects` / `ticket_counter_uneasy`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Narrator:** The tickets twitch when you pass.
- **Narrator:** The counter smells faintly of dust and warm paper.

**`environment_objects` / `ticket_counter_fractured`** — 1 variant(s) · used by: ArcadeHub.gd:_get_ticket_counter_echo_lines
- **Narrator:** The ticket counter glass catches your reflection half a beat late.
- **Narrator:** For a moment it does not move when you move.
- **Narrator:** Then it catches up, like nothing happened.

**`environment_objects` / `ticket_counter_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Narrator:** Every ticket stub points toward the Staff Door.
- **Narrator:** The roll keeps counting after it runs out of numbers.

**`environment_objects` / `ticket_counter_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Narrator:** The counter is quiet now.
- **Narrator:** It no longer tries to sell you proof.

**`environment_objects` / `owner_portrait_grounded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Owner Portrait:** A dusty portrait hangs above the arcade floor, angled like it used to watch the door.
- **Owner Portrait:** The figure wears a staff shirt, not an owner's suit.
- **Owner Portrait:** The name patch has been worn blank.
- **Owner Portrait:** A faded sticker on the frame reads: LAST ONE OUT LOCKS UP.
- **Owner Portrait:** The nameplate is scratched beyond reading.

**`environment_objects` / `owner_portrait_uneasy`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Owner Portrait:** The scratched nameplate catches the light differently now.
- **Owner Portrait:** Something under the scratches is trying to surface.
- **Owner Portrait:** Not yet. The signal is still too faint to hold a name.

**`environment_objects` / `owner_portrait_fractured`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_owner_portrait
- **Owner Portrait:** The scratches look less random now.
- **Owner Portrait:** Two marks seem to repeat: 0 and 4.
- **Owner Portrait:** Someone scratched at the name like they could not stand to be the one in the frame.

**`environment_objects` / `owner_portrait_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Owner Portrait:** The portrait seems to be looking at the Staff Door.
- **Owner Portrait:** The eyes look tired in a way cheap paint should not be able to hold.
- **Owner Portrait:** The nameplate clicks softly in its frame, like it wants to be read and dreads it.

**`environment_objects` / `owner_portrait_restored`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_owner_portrait
- **Owner Portrait:** The name was never gone.
- **Owner Portrait:** It waited until you could read it.
- **Owner Portrait:** It says: EMPLOYEE 04.

**`environment_objects` / `broken_cabinet_grounded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Broken Cabinet:** The cabinet is dark.
- **Broken Cabinet:** A paper sign says OUT OF ORDER.

**`environment_objects` / `broken_cabinet_fractured`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_broken_cabinet
- **Broken Cabinet:** RESET FAILED.
- **Broken Cabinet:** EMPLOYEE SIGNAL RETURNED.
- **Broken Cabinet:** YOU USED TO KEEP ME RUNNING LONG AFTER IT MADE SENSE.

**`environment_objects` / `broken_cabinet_overloaded`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_broken_cabinet
- **Broken Cabinet:** STOP PRESSING E.
- **Broken Cabinet:** I AM TRYING TO REMEMBER.

**`environment_objects` / `broken_cabinet_restored`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_broken_cabinet
- **Broken Cabinet:** I remember your first quarter.
- **Broken Cabinet:** You looked happier then.
- **Broken Cabinet:** Not better. Just earlier.

**`environment_objects` / `closing_checklist_grounded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Closing Checklist:** Sweep floors.
- **Closing Checklist:** Count tickets.
- **Closing Checklist:** Lock Staff Room.

**`environment_objects` / `closing_checklist_fractured`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Closing Checklist:** CLOSING CHECKLIST
- **Closing Checklist:** Counter locked.
- **Closing Checklist:** Cabinet Row dimmed.
- **Closing Checklist:** Staff Door checked twice.
- **Closing Checklist:** Final item scratched out.
- **Closing Checklist:** The closing shift is signed by one name, over and over, as if no one else could be asked to be here.

**`environment_objects` / `closing_checklist_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Closing Checklist:** CLOSING CHECKLIST
- **Closing Checklist:** Two closing signatures detected.
- **Closing Checklist:** One hand wrote both badly.

**`environment_objects` / `closing_checklist_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Closing Checklist:** The checklist is only paper now.
- **Closing Checklist:** It stops pretending a routine can hold a night together.

**`environment_objects` / `maintenance_note_grounded`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_maintenance_note
- **Maintenance Note:** Most of the note is routine cleaning nonsense.
- **Maintenance Note:** A coffee ring covers the useful part.

**`environment_objects` / `maintenance_note_fractured`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Maintenance Note:** MAINTENANCE NOTE
- **Maintenance Note:** Staff Door reported two signals after closing.
- **Maintenance Note:** One signal entered.
- **Maintenance Note:** One signal remained.
- **Maintenance Note:** Gus note: I do not get paid enough for doors with opinions.

**`environment_objects` / `maintenance_note_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Maintenance Note:** The note buzzes in your hand.
- **Maintenance Note:** The ink keeps rewriting the word DOOR.

**`environment_objects` / `maintenance_note_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Maintenance Note:** The last line is readable now.
- **Maintenance Note:** Gus came back to check the lock.
- **Maintenance Note:** He was scared and did the job anyway.

**`environment_objects` / `staff_schedule_grounded`** — 1 variant(s) · used by: CabinetRow.gd:_handle_staff_schedule
- **Staff Schedule:** The schedule screen is scrambled.
- **Staff Schedule:** Mr. Byte has not unlocked staff records yet.

**`environment_objects` / `staff_schedule_fractured`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Staff Schedule:** STAFF SCHEDULE
- **Staff Schedule:** Final Night
- **Staff Schedule:** Mira - Counter
- **Staff Schedule:** Gus - Maintenance
- **Staff Schedule:** Employee ## - Cabinet shutdown
- **Player:** Cabinet shutdown.
- **Player:** Why does reading that make my hands cold?
- **Staff Schedule:** The redacted name is scratched hardest, as if someone could not stand to be on this list.
- **Staff Schedule:** Status: unresolved

**`environment_objects` / `staff_schedule_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Staff Schedule:** The schedule repeats the final shift.
- **Staff Schedule:** The last assignment is still redacted.
- **Staff Schedule:** The Staff Door disagrees.

**`environment_objects` / `staff_schedule_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Staff Schedule:** The final shift no longer hides its shape.
- **Staff Schedule:** Everyone was where they said they were.
- **Staff Schedule:** Including you.

**`environment_objects` / `staff_record_01_shift_log`** — 1 variant(s) · used by: CabinetRow.gd:_handle_staff_record_01
- **Staff Record:** SHIFT LOG - FINAL NIGHT (RECOVERED EXCERPT)
- **Staff Record:** 23:41 - Mira signed the register and left. Last name on the page.
- **Staff Record:** 23:50 - Gus clocked out. Mop returned wet.
- **Staff Record:** 00:05 - One staff member stayed to run the closing checklist alone.
- **Staff Record:** 00:19 - Cabinet 07 kept one token in the return tray. Flagged: do not empty.
- **Staff Record:** 00:33 - Backup started. Backup did not finish.
- **Staff Record:** Entry ends. No sign-out recorded for the last shift.

**`environment_objects` / `staff_records_locked`** — 1 variant(s) · used by: CabinetRow.gd:_handle_staff_record_01; MaintenanceHall.gd:_handle_staff_record_02; StaffCorridor.gd:_handle_staff_record_03
- **Staff Record:** The record terminal is sealed.
- **Staff Record:** TRUTH FILTER REQUIRED.

**`environment_objects` / `staff_records_fractured`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Staff Record:** RESTORE SYSTEM NOTE
- **Staff Record:** Subject memory incomplete.
- **Staff Record:** Do not repeat name until signal stabilizes.

**`environment_objects` / `staff_records_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Staff Record:** Record fragment accepted.
- **Staff Record:** Employee number checksum detected.
- **Staff Record:** Name field still sealed.

**`environment_objects` / `staff_records_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Staff Record:** The archive stops hiding the file.
- **Staff Record:** The number was a door.
- **Staff Record:** The name was you.

**`environment_objects` / `truth_filter_machine_grounded`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_truth_filter; CabinetRow.gd:_handle_truth_filter
- **Truth Filter:** SIGNAL TOO QUIET.
- **Truth Filter:** LOST TOKEN REQUIRED.

**`environment_objects` / `truth_filter_machine_uneasy`** — 1 variant(s) · used by: ArcadeHub.gd:_handle_truth_filter; CabinetRow.gd:_handle_truth_filter
- **Truth Filter:** CONTRADICTION THRESHOLD REACHED.
- **Truth Filter:** SORT FALSE RECORDS.

**`environment_objects` / `truth_filter_machine_fractured`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Truth Filter:** TRUTH FILTER PASSED.
- **Truth Filter:** RECORDS RECONCILED.

**`environment_objects` / `truth_filter_machine_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Truth Filter:** TRUTH FILTER IDLE.
- **Truth Filter:** SUBJECT NO LONGER DENIES PRIMARY RECORD.

**`environment_objects` / `circuit_soda_machine_locked`** — 1 variant(s) · used by: SnackAlcove.gd:_handle_circuit_soda
- **Circuit Soda:** SNACK ALCOVE LOCKED.
- **Circuit Soda:** TRUTH FILTER REQUIRED.

**`environment_objects` / `circuit_soda_machine_fractured`** — 1 variant(s) · used by: SnackAlcove.gd:_handle_circuit_soda
- **Circuit Soda:** MEMORY FLOW UNROUTED.
- **Circuit Soda:** CONNECT INPUT TO RESTORE OUTPUT.
- **Circuit Soda:** DO NOT SPILL IDENTITY.

**`environment_objects` / `circuit_soda_machine_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Circuit Soda:** ROUTE HOLDING.
- **Circuit Soda:** PRESSURE ABOVE COMFORT.

**`environment_objects` / `circuit_soda_machine_restored`** — 1 variant(s) · used by: SnackAlcove.gd:_handle_circuit_soda
- **Circuit Soda:** MEMORY FLOW RESTORED.
- **Circuit Soda:** FRACTURED SIGNAL STABILIZED.

**`environment_objects` / `maintenance_sync_machine_locked`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Maintenance Sync:** MAINTENANCE SYNC LOCKED.
- **Maintenance Sync:** SERVICE POWER REQUIRED.

**`environment_objects` / `maintenance_sync_machine_circuit_required`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_maintenance_sync
- **Maintenance Sync:** SIGNAL ROUTE MISSING.
- **Maintenance Sync:** CIRCUIT SODA REQUIRED.

**`environment_objects` / `maintenance_sync_machine_lost_shift_required`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_maintenance_sync
- **Maintenance Sync:** MAINTENANCE SYNC LOCKED.
- **Maintenance Sync:** LOST SHIFT FILE REQUIRED.

**`environment_objects` / `maintenance_sync_machine_static_service_required`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_maintenance_sync
- **Maintenance Sync:** MAINTENANCE SYNC LOCKED.
- **Maintenance Sync:** STATIC SERVICE REQUIRED.

**`environment_objects` / `maintenance_sync_machine_fractured`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_maintenance_sync
- **Maintenance Sync:** TWO SIGNALS DETECTED.
- **Maintenance Sync:** DOOR LISTENING.
- **Maintenance Sync:** SYNC REQUIRED.

**`environment_objects` / `maintenance_sync_machine_overloaded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Maintenance Sync:** ACCESS GRANTED.
- **Maintenance Sync:** EMPLOYEE SIGNAL ACCEPTED.
- **Maintenance Sync:** DOOR HEARD BOTH KNOCKS.

**`environment_objects` / `maintenance_sync_machine_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Maintenance Sync:** SYNC COMPLETE.
- **Maintenance Sync:** NO FURTHER KNOCKS REQUIRED.

**`environment_objects` / `security_tape_terminal_locked`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape
- **Security Tape:** SECURITY TAPE LOCKED.
- **Security Tape:** MAINTENANCE SYNC REQUIRED.

**`environment_objects` / `security_tape_terminal_overloaded`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape
- **Security Tape:** SECURITY TAPE DAMAGED.
- **Security Tape:** FRAMES OUT OF ORDER.
- **Security Tape:** RESTORE SEQUENCE.

**`environment_objects` / `security_tape_terminal_restored`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_security_tape
- **Security Tape:** TAPE ORDER RESTORED.
- **Security Tape:** FRAMES NOW FORM A STAFF ROUTE.
- **Security Tape:** FINAL NIGHT WALK REQUIRED.

**`environment_objects` / `final_night_walk_terminal_locked`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_final_night_walk
- **Memory System:** FINAL NIGHT WALK LOCKED.
- **Memory System:** SECURITY TAPE REQUIRED.

**`environment_objects` / `final_night_walk_terminal_overloaded`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_final_night_walk
- **Memory System:** TAPE ORDER RESTORED.
- **Memory System:** ROUTE MEMORY UNSTABLE.
- **Memory System:** WALK THE FINAL NIGHT.

**`environment_objects` / `final_night_walk_terminal_restored`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_final_night_walk
- **Memory System:** FINAL NIGHT ROUTE STABLE.
- **Memory System:** WALKBACK MATCHED SECURITY SEQUENCE.
- **Memory System:** ONE WALKED IN.
- **Memory System:** TWO SIGNALS ANSWERED.
- **Memory System:** MEMORY ECHO READY.

**`environment_objects` / `memory_echo_object_locked`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Memory Echo:** MEMORY ECHO LOCKED.
- **Memory Echo:** FINAL NIGHT WALK REQUIRED.

**`environment_objects` / `memory_echo_object_maintenance_required`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Memory Echo:** SIGNAL TOO QUIET.
- **Memory Echo:** MAINTENANCE SYNC REQUIRED.

**`environment_objects` / `memory_echo_object_security_tape_required`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Memory Echo:** MEMORY ECHO LOCKED.
- **Memory Echo:** SECURITY TAPE REQUIRED.

**`environment_objects` / `memory_echo_object_final_night_required`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Memory Echo:** MEMORY ECHO LOCKED.
- **Memory Echo:** FINAL NIGHT WALK REQUIRED.

**`environment_objects` / `memory_echo_object_overloaded`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Memory Echo:** FINAL NIGHT ROUTE STABLE.
- **Memory Echo:** MEMORY ECHO AVAILABLE.
- **Memory Echo:** IDENTITY CONFLICT APPROACHING READABLE RANGE.

**`environment_objects` / `memory_echo_object_restored`** — 1 variant(s) · used by: StaffCorridor.gd:_handle_memory_echo
- **Memory Echo:** Echo stabilized.
- **Memory Echo:** The arcade stops arguing with itself.
- **Memory Echo:** That might be worse.

**`environment_objects` / `truth_filter_machine_replay_offer`** — 1 variant(s) · used by: CabinetRow.gd:_handle_truth_filter
- **Truth Filter:** TRUTH FILTER ONLINE. NO CONTRADICTIONS PENDING.
- **Truth Filter:** OPERATOR EMPLOYEE 04 RECOGNIZED.
- **Truth Filter:** RECREATIONAL SORTING AVAILABLE.

**`environment_objects` / `truth_filter_machine_replay_return`** — 1 variant(s) · used by: CabinetRow.gd:_maybe_play_completion_anecdote
- **Truth Filter:** SORT COMPLETE. LIE DENSITY: ZERO.
- **Truth Filter:** THE CABINETS HAVE NOTHING LEFT TO ARGUE ABOUT.
- **Truth Filter:** THEY ARGUE ANYWAY. IT KEEPS THEM WARM.

**`environment_objects` / `maintenance_sync_machine_replay_offer`** — 1 variant(s) · used by: MaintenanceHall.gd:_handle_maintenance_sync
- **Maintenance Sync:** DOOR AND LOCK IN AGREEMENT.
- **Maintenance Sync:** RECREATIONAL SYNC AVAILABLE.
- **Maintenance Sync:** NOTHING DEPENDS ON IT. THAT IS NEW.

**`environment_objects` / `maintenance_sync_machine_replay_return`** — 1 variant(s) · used by: MaintenanceHall.gd:_maybe_play_completion_anecdote
- **Maintenance Sync:** SYNC COMPLETE. AGREEMENT MAINTAINED.
- **Maintenance Sync:** THE DOOR SAYS THANK YOU.
- **Maintenance Sync:** IN DOOR.

**`environment_objects` / `staff_room_terminal_locked`** — 1 variant(s) · used by: StaffRoom.gd:_handle_terminal_interaction
- **Terminal:** RESTORE PLAYBACK LOCKED.
- **Terminal:** MEMORY ECHO REQUIRED.

**`environment_objects` / `staff_room_terminal_available`** — 1 variant(s) · used by: StaffRoom.gd:_handle_terminal_interaction
- **Terminal:** Employee file recovered.
- **Terminal:** Restoration subject found.
- **Terminal:** Name: Employee 04.

**`environment_objects` / `staff_room_terminal_restored`** — 1 variant(s) · used by: StaffRoom.gd:_handle_terminal_interaction
- **Terminal:** EMPLOYEE 04 RESTORE STATUS: STABLE.
- **Terminal:** CONSCIENCE ECHO INTEGRATED.
- **Terminal:** MEMORY LOOP CLOSED.

**`environment_objects` / `employee_04_file_archived`** — 1 variant(s) · used by: StaffRoom.gd:_handle_employee_04_file
- **Employee File:** EMPLOYEE 04 // STATUS: ARCHIVED RESTORE PROFILE.
- **Employee File:** The photo is corrupted beyond recognition.

**`environment_objects` / `employee_04_file_restored`** — 1 variant(s) · used by: StaffRoom.gd:_handle_employee_04_file
- **Employee File:** EMPLOYEE 04 // RESTORED MEMORY ACTIVE.
- **Employee File:** The photo is yours.
- **Employee File:** The file was never about someone else.

**`environment_objects` / `employee_04_file_integrated`** — 1 variant(s) · used by: StaffRoom.gd:_handle_employee_04_file
- **Employee File:** EMPLOYEE 04 // RESTORED MEMORY ACTIVE.
- **Employee File:** The photo is yours.
- **Employee File:** The regret field is no longer sealed.

**`environment_objects` / `prize_counter_grounded`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Prize Counter:** Cheap prizes watch from behind dusty glass.

**`environment_objects` / `prize_counter_uneasy`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Prize Counter:** A blue prize has been moved to the front.
- **Prize Counter:** No one admits moving it.

**`environment_objects` / `prize_counter_fractured`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Prize Counter:** Three labels sit loose under the glass.
- **Prize Counter:** Ticket Stub. Lost Token. Blank Employee Badge.

**`environment_objects` / `prize_counter_restored`** — 1 variant(s) · used by: PrizeCorner.gd:_handle_prize_counter
- **Prize Counter:** The prize labels are neatly sorted.
- **Prize Counter:** The badge no longer looks blank to you.

**`environment_objects` / `front_doors`** — 1 variant(s) · used by: FrontEntrance.gd:handle_hub_interaction
- **Front Doors:** The main doors are chained shut from the outside.
- **Front Doors:** A closing notice is taped to the glass, facing out, as if the street still needed telling.
- **Player:** Why can I not just leave?
- **Player:** ...
- **Player:** Something here is not finished with me yet.

**`environment_objects` / `front_doors_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Front Doors:** The chain is still there. Somehow it matters less now.
- **Front Doors:** You were never trapped in here.
- **Front Doors:** You were held. There is a difference.

**`environment_objects` / `arcade_history`** — 1 variant(s) · used by: FrontEntrance.gd:handle_hub_interaction
- **History Board:** A corkboard of photos: full weekends, tournament nights, a staff that used to be larger.
- **History Board:** The dates run out a few years back.
- **History Board:** The most recent photos have been taken down. The pins are still there.

**`environment_objects` / `closing_notice`** — 1 variant(s) · used by: FrontEntrance.gd:handle_hub_interaction
- **Closing Notice:** NOTICE: Pixel Haven will close following final maintenance.
- **Closing Notice:** Thank you for every quarter.
- **Closing Notice:** The signature under it has been scratched down to the paper.

**`environment_objects` / `closing_notice_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Closing Notice:** The scratched-out signature is legible now, if you already know the name.
- **Closing Notice:** It was signed by the one person who could not bear to sign it.

**`environment_objects` / `party_community_wall`** — 1 variant(s) · used by: PartyRoom.gd:handle_hub_interaction
- **Community Wall:** Rows of party photos: birthday hats, gap-toothed grins, prize animals bigger than the kids holding them.
- **Community Wall:** In the corner of almost every shot, the same figure stands half in frame.
- **Community Wall:** Never the center. Always making sure everyone else fit.

**`environment_objects` / `party_community_wall_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Community Wall:** You know the half-in-frame figure now.
- **Community Wall:** He kept himself at the edge so the picture would be about the kids.

**`environment_objects` / `party_mascot_stage`** — 1 variant(s) · used by: PartyRoom.gd:handle_hub_interaction
- **Party Stage:** A little stage for a mascot costume that never quite worked.
- **Party Stage:** Kids' drawings are still taped along the front.
- **Party Stage:** One reads THANK YOU FOR THE FREE GO, in enormous crayon.
- **Party Stage:** It is not addressed to anyone. It did not need to be.

**`environment_objects` / `party_birthday_cabinet`** — 1 variant(s) · used by: PartyRoom.gd:handle_hub_interaction
- **Birthday Cabinet:** PARTY HIGH SCORE - a cheerful, forgiving little game.
- **Birthday Cabinet:** The target score is set absurdly low.
- **Birthday Cabinet:** Someone wanted every kid to walk away a winner.

**`environment_objects` / `workshop_bench`** — 1 variant(s) · used by: Workshop.gd:handle_hub_interaction
- **Workbench:** A workbench under a hooded lamp, tools laid out in a patient row.
- **Workbench:** Half-built cabinets lean against the wall, each one shaped by hand.
- **Workbench:** Whoever worked here cared more about the games than about being paid for them.

**`environment_objects` / `workshop_bench_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Workbench:** The tools are exactly where you left them.
- **Workbench:** Your hands remember the weight of every one.

**`environment_objects` / `workshop_prototype`** — 1 variant(s) · used by: Workshop.gd:handle_hub_interaction
- **Prototype:** An unfinished cabinet. No coin slot cut into it yet.
- **Prototype:** A note is taped over the dark screen: MAKE THIS ONE FREE.
- **Prototype:** It was never finished. The arcade closed first.
- **Prototype:** The kind of thing you meant to get to once the money settled. The money never settled.

**`environment_objects` / `workshop_spare_parts`** — 1 variant(s) · used by: Workshop.gd:handle_hub_interaction
- **Spare Parts:** Bins of joysticks, buttons, cracked screens.
- **Spare Parts:** Nothing here is new.
- **Spare Parts:** Everything here was kept alive long past the point of sense.
- **Spare Parts:** That was the whole job, really.

**`environment_objects` / `memory_banks`** — 1 variant(s) · used by: MemoryCore.gd:handle_hub_interaction
- **Memory Bank:** Banks of old drives hum in the dark, warm to the touch.
- **Memory Bank:** Each one holds a memory the arcade refused to lose.
- **Memory Bank:** Faces. Voices. Closing nights. Small kindnesses nobody else recorded.
- **Memory Bank:** All of it kept.

**`environment_objects` / `memory_core_terminal`** — 1 variant(s) · used by: MemoryCore.gd:handle_hub_interaction
- **Core Terminal:** CORE STATUS: STABLE.
- **Core Terminal:** WHEN THE FLOOR WENT DARK, THE SYSTEM SAVED WHAT IT COULD.
- **Core Terminal:** IT COULD NOT SAVE EVERYTHING.
- **Core Terminal:** IT CHOSE PEOPLE OVER PROFIT. ONE LAST TIME.
- **Core Terminal:** IT LEARNED THAT FROM SOMEONE.

**`environment_objects` / `memory_sealed_drive`** — 1 variant(s) · used by: MemoryCore.gd:handle_hub_interaction
- **Sealed Drive:** One drive is labeled only with a number. The rest of the label is scratched away.
- **Sealed Drive:** It runs warmer than the others.
- **Sealed Drive:** It has been waiting a long time to be read.

**`environment_objects` / `memory_sealed_drive_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Sealed Drive:** The sealed drive is open now.
- **Sealed Drive:** It was never corrupted. It was protected.
- **Sealed Drive:** There is a difference, and you are the difference.

**`environment_objects` / `restroom_mirror`** — 1 variant(s) · used by: Restrooms.gd:handle_hub_interaction
- **Mirror:** A cracked mirror over a dry sink.
- **Mirror:** For a moment, two figures stand where only one should.
- **Mirror:** One of them finishes moving a half-second after you do.
- **Mirror:** When you look again, there is only you. Probably.

**`environment_objects` / `restroom_mirror_restored`** — 1 variant(s) · used by: no literal call site — variant chosen dynamically at runtime (key = object + Memory Signal state suffix)
- **Mirror:** The mirror shows one figure now.
- **Mirror:** It took both of you to get back to that.

**`environment_objects` / `restroom_stall`** — 1 variant(s) · used by: Restrooms.gd:handle_hub_interaction
- **Stall:** An out-of-order stall, its door ajar.
- **Stall:** A hand-drawn HIGH SCORE list is taped inside, going back years.
- **Stall:** Every name on the list is written in the same handwriting.
- **Stall:** Someone kept the record alive by pretending to be a crowd.

**`environment_objects` / `restroom_token`** — 1 variant(s) · used by: Restrooms.gd:handle_hub_interaction
- **Windowsill:** A single arcade token sits half behind the pipe.
- **Windowsill:** Cold. Older than the others.
- **Windowsill:** It fits your hand like it remembers being held.


### 4.4 Quest & guidance text (Objective HUD, quest menu, RouteCue)


### quests.json (registry data)

**`lost_token`** — *Recover the Lost Token* (owner: Mira; location: ArcadeHub; required)
- summary (shown in top-right Objective HUD): Win the Lost Token back from Cabinet 07.
- details (pause menu > Quest): Mira says Cabinet 07 has the Lost Token. Recover it from Cabinet 07 on the ArcadeHub main floor, then return to Mira at the ticket counter.

**`truth_filter`** — *Truth Filter* (owner: Mr. Byte; location: Cabinet Row; required)
- summary (shown in top-right Objective HUD): See Mr. Byte in Cabinet Row, then the Filter.
- details (pause menu > Quest): The Lost Token woke something. Go to Cabinet Row, talk to Mr. Byte, and use the Truth Filter to sort the false records. Roxy says the staff record terminal across the row holds the shift log the filter quizzes you on.

**`circuit_soda`** — *Route the Signal* (owner: Vendo; location: Snack Alcove; required)
- summary (shown in top-right Objective HUD): See Vendo in Snack Alcove, then Circuit Soda.
- details (pause menu > Quest): The Truth Filter recovered a second fragment, but the signal is still misrouted. Talk to Vendo in Snack Alcove, then use Circuit Soda.

**`maintenance_sync`** — *Maintenance Sync* (owner: Gus; location: Maintenance Hall; required)
- summary (shown in top-right Objective HUD): Run Maintenance Sync with Gus in Maintenance.
- details (pause menu > Quest): Service power is restored. Talk to Gus in Maintenance Hall, then use Maintenance Sync to line up the Staff Door signals.

**`lost_shift_file`** — *Lost Shift File* (owner: Mira / Gus / Mr. Byte; location: ArcadeHub, Maintenance Hall, Cabinet Row; required)
- summary (shown in top-right Objective HUD): Read the checklist, schedule, and note.
- details (pause menu > Quest): The signal is routed, but the Staff Door still refuses to open. Read the Closing Checklist in ArcadeHub, the Staff Schedule in Cabinet Row, and Gus's Maintenance Note in Maintenance Hall.

**`static_service_run`** — *Static Service Run* (owner: Gus; location: Maintenance Hall; required)
- summary (shown in top-right Objective HUD): See Gus in Maintenance Hall about the power.
- details (pause menu > Quest): The Lost Shift File gave Gus enough context to work with the Staff Door, but Maintenance Hall still needs service power. Talk to Gus, then run Static Service Run.

**`staff_corridor`** — *Enter the Staff Corridor* (owner: Staff Door; location: Staff Corridor; required)
- summary (shown in top-right Objective HUD): Follow the Staff Access Hall onward.
- details (pause menu > Quest): Gus stabilized the Staff Door. Use the Staff Corridor exit so the overloaded signal can lead toward Security Tape, Final Night Walk, and Memory Echo.

**`security_tape_assembly`** — *Assemble the Security Tape* (owner: Staff Door / Mr. Byte; location: Staff Corridor; required)
- summary (shown in top-right Objective HUD): Restore the Security Tape in Staff Corridor.
- details (pause menu > Quest): The Staff Door recorded two signals, but the tape is damaged. Assemble the Security Tape in Staff Corridor before Final Night Walk and Memory Echo.

**`final_night_walk`** — *Final Night Walk* (owner: Staff Door / Memory System; location: Staff Corridor; required)
- summary (shown in top-right Objective HUD): Use Final Night Walk in Staff Corridor.
- details (pause menu > Quest): The security tape is assembled, but the memory is still too unstable to play back. Use Final Night Walk in Staff Corridor before confronting the Memory Echo.

**`memory_echo`** — *Stabilize the Memory Echo* (owner: Memory Echo; location: Staff Corridor; required)
- summary (shown in top-right Objective HUD): Use Memory Echo in Staff Corridor.
- details (pause menu > Quest): The Final Night route is stable. Use Memory Echo in Staff Corridor to stabilize the signal before the Staff Room reveals what happened.

**`broken_high_score`** — *Broken High Score* (owner: Roxy; location: Cabinet Row; required)
- summary (shown in top-right Objective HUD): Use the BROKEN SCORE cabinet in Cabinet Row.
- details (pause menu > Quest): The score claims the target is 9999, but the display is broken. The real record may be much smaller and much stranger.

**`prize_counter_secret`** — *Prize Sort* (owner: Pip; location: Prize Corner; required)
- summary (shown in top-right Objective HUD): Use the PRIZE COUNTER in Prize Corner.
- details (pause menu > Quest): Pip says the prize labels remember an order: Ticket Stub, Lost Token, then Blank Employee Badge.

**`staff_records_chain`** — *Staff Records Chain* (owner: Staff Records; location: Cabinet Row, Maintenance Hall, Staff Corridor; optional)
- summary (shown in top-right Objective HUD): Read the three staff records.
- details (pause menu > Quest): The arcade preserved small system notes around the Final Night. They deepen the identity mystery without blocking the required route.

**`post_reveal_witness_route`** — *Post-Reveal Witness Route* (owner: Mira / Gus / Vendo / Mr. Byte / Cabinet 07; location: ArcadeHub, Cabinet Row, Maintenance Hall, Snack Alcove; optional)
- summary (shown in top-right Objective HUD): Speak with the witnesses.
- details (pause menu > Quest): Pixel Haven remembers the protagonist in pieces. Roxy and Pip can add optional reflections if the player met them.


#### Dynamic quest text (GameState overrides — these win over quests.json when active)


#### `GameState.gd` — `get_story_phase_label_from_data()`

```gdscript
func get_story_phase_label_from_data(data: Dictionary) -> String:
	if bool(data.get("post_reveal_roam_unlocked", false)):
		return "Post-Reveal Roam"
	if bool(data.get("ending_seen", false)):
		return "Ending"
	if bool(data.get("twist_reveal_seen", false)):
		return "Truth Revealed"
	if bool(data.get("memory_echo_completed", false)):
		return "Staff Room"
	if bool(data.get("final_night_walk_completed", false)):
		return "Memory Echo"
	if bool(data.get("security_tape_assembly_completed", false)):
		return "Final Night Walk"
	if bool(data.get("staff_corridor_unlocked", false)):
		return "Security Tape Assembly"
	if bool(data.get("story_puzzle_completed", false)):
		return "Staff Corridor"
	if bool(data.get("static_service_run_completed", false)):
		return "Maintenance Sync"
	if _is_lost_shift_file_complete_in_data(data):
		return "Static Service Run"
	if bool(data.get("circuit_soda_completed", false)) and not bool(data.get("prize_sort_completed", false)) and not _is_lost_shift_file_complete_in_data(data):
		return "Prize Sort"
	if bool(data.get("circuit_soda_completed", false)) and not _is_lost_shift_file_complete_in_data(data):
		return "Lost Shift File"
	if bool(data.get("circuit_soda_completed", false)):
		return "Lost Shift File"
	if bool(data.get("second_memory_fragment_collected", false)) or bool(data.get("lying_cabinets_completed", false)):
		return "Truth Filter Cleared"
	if bool(data.get("lost_token_quest_completed", false)) and not bool(data.get("broken_high_score_completed", false)) and not bool(data.get("lying_cabinets_completed", false)):
		return "Broken High Score"
	if bool(data.get("truth_filter_quest_started", false)) and not bool(data.get("lying_cabinets_completed", false)):
		return "Truth Filter"
	if bool(data.get("lost_token_quest_completed", false)):
		return "Lost Token Returned"
	if bool(data.get("rockbyte_duel_completed", false)) or bool(data.get("lost_token_collected", false)):
		return "Lost Token Found"
	if bool(data.get("lost_token_quest_started", false)):
		return "Cabinet 07"
	if bool(data.get("story_started", false)):
		return "Opening Night"
	return "New Memory"
```

#### `GameState.gd` — `get_current_quest_data()`

```gdscript
func get_current_quest_data() -> Dictionary:
	match get_current_quest_id():
		"broken_high_score":
			if not roxy_met:
					"title": "Broken High Score",
					"summary": "Talk to Roxy in Cabinet Row.",
					"details": "Mira says a regular named Roxy guards a score cabinet that is still lying about a record. Hear her out before touching the board.",
				"title": "Broken High Score",
				"summary": "Use the BROKEN SCORE cabinet in Cabinet Row.",
				"details": "Roxy guards the Broken High Score cabinet in Cabinet Row. The board lies that the target is 9999. Restore the real record before the Truth Filter.",
		"prize_sort":
			if not pip_met:
					"summary": "Talk to Pip in Prize Corner.",
					"details": "Vendo says the plush in Prize Corner has been staring at three loose labels all night. Hear Pip out before touching the counter.",
				"summary": "Use the PRIZE COUNTER in Prize Corner.",
				"details": "Pip in Prize Corner says the labels remember an order: Ticket Stub, Lost Token, then Blank Employee Badge. Sort them before the Lost Shift File.",
		"gus_checkin_truth_filter":
				"title": "Catch Up With Gus",
				"summary": "Find Gus on the Arcade Hub floor.",
				"details": "Gus heard the Truth Filter lose its argument and wants a word before the next machine. Find him on the Arcade Hub floor.",
		"gus_checkin_prize_sort":
				"summary": "Talk to Gus in the Arcade Hub.",
				"details": "Pip's prize wall stirred something loose. Gus wants to chase it his way: paperwork. Find him on the Arcade Hub floor before digging into the records.",
		"opening_look_around":
				"title": "Get Your Bearings",
				"summary": "Look around. Talk to whoever is here.",
				"details": "Pixel Haven is closed, but it seems to know me. I should look around and talk to whoever is still here before I decide anything.",
		"opening_talk_to_mira":
				"summary": "Talk to Mira at the ticket counter.",
				"details": "Pixel Haven is closed, but Mira seems to know me. I should talk to her at the ticket counter.",
		"recover_lost_token":
				"title": "Recover the Lost Token",
				"summary": "Win your token back from Cabinet 07.",
				"details": "Mira says Cabinet 07 has my Lost Token. I need to play Cabinet 07 on the ArcadeHub main floor, then bring the token back to Mira at the ticket counter.",
		"return_lost_token":
				"title": "Return the Lost Token",
				"summary": "Bring the Lost Token back to Mira.",
				"details": "Cabinet 07 released the Lost Token. Mira is waiting for it by the ticket counter.",
		"maintenance_sync":
				"title": "Maintenance Sync",
				"summary": "Run Maintenance Sync with Gus in Maintenance.",
				"details": "Service power is restored. Talk to Gus in Maintenance Hall, then use Maintenance Sync to line up the Staff Door signals.",
		"static_service_run":
				"title": "Static Service Run",
				"summary": "See Gus in Maintenance Hall about the power.",
				"details": "The Lost Shift File gave Gus enough context to work with the Staff Door, but Maintenance Hall still needs service power. Talk to Gus, then run Static Service Run.",
		"lost_shift_file":
				"title": "Lost Shift File",
				"owner": "Mira / Gus / Mr. Byte",
				"location": "ArcadeHub, Maintenance Hall, Cabinet Row",
				"summary": "Read the checklist, schedule, and note.",
				"details": "The signal is routed, but the Staff Door still refuses to open. Read the Closing Checklist in ArcadeHub, the Staff Schedule in Cabinet Row, and Gus's Maintenance Note in Maintenance Hall.",
		"staff_corridor":
				"title": "Enter the Staff Corridor",
				"summary": "Follow the Staff Access Hall onward.",
				"details": "Gus stabilized the Staff Door. Use the Staff Corridor exit so the overloaded signal can lead toward Security Tape, Final Night Walk, and Memory Echo.",
		"security_tape_assembly":
				"title": "Assemble the Security Tape",
				"owner": "Staff Door / Mr. Byte",
				"summary": "Restore the Security Tape in Staff Corridor.",
				"details": "The Staff Door recorded two signals, but the tape is damaged. Assemble the Security Tape in Staff Corridor before Final Night Walk and Memory Echo.",
				"minigame": "Security Tape Assembly",
		"final_night_walk":
				"title": "Final Night Walk",
				"summary": "Use the FINAL NIGHT terminal in Staff Corridor.",
				"details": "The security tape is assembled, but the memory is still too unstable to play back. Use Final Night Walk in Staff Corridor before confronting the Memory Echo.",
		"stabilize_memory_echo":
				"title": "Stabilize the Memory Echo",
				"summary": "Use Memory Echo in Staff Corridor.",
				"details": "The Final Night route is stable. Use Memory Echo in Staff Corridor to stabilize the signal before the Staff Room reveals what happened.",
		"circuit_soda":
			if get_npc_dialogue_count("vendo_circuit_explained") == 0:
					"title": "Route the Signal",
					"summary": "Talk to Vendo in Snack Alcove.",
					"details": "Gus says Vendo has been rerouting power to itself again. Hear the machine out before touching Circuit Soda.",
				"title": "Route the Signal",
				"summary": "Route Circuit Soda in Snack Alcove.",
				"details": "Vendo walked you through it. Rotate the pipes until the memory input reaches the restore output.",
		"truth_filter":
			if get_npc_dialogue_count("mr_byte_tf_explained") == 0:
					"title": "Open the Truth Filter",
					"summary": "Talk to Mr. Byte in Cabinet Row.",
					"details": "Roxy says Mr. Byte runs the Truth Filter and will not let anyone near it without an orientation. Find him in Cabinet Row first.",
				"title": "Open the Truth Filter",
				"summary": "Run the Truth Filter in Cabinet Row.",
				"details": "Mr. Byte opened the Truth Filter. Sort the lying cabinets. Roxy says the staff record terminal across the row holds the shift log the filter quizzes you on.",
		"mr_byte_debrief":
				"title": "Report to Mr. Byte",
				"summary": "Tell Mr. Byte what the Filter found.",
				"details": "Roxy says Mr. Byte files everything the Truth Filter turns up. He is still in Cabinet Row, and he will have opinions.",
		"enter_staff_room":
				"title": "Enter the Staff Room",
				"summary": "Enter the Staff Room from Staff Corridor.",
				"details": "The Memory Echo in Staff Corridor stabilized. The Staff Room door is ready.",
		"finish_memory":
				"title": "Finish the Memory",
				"summary": "Let the memory settle.",
				"details": "The truth is visible now. I need to let this memory finish and see what remains afterward.",
		"talk_to_witnesses":
				"title": "Talk to Those Who Remembered",
				"summary": "Speak with the remaining witnesses.",
				"details": "Pixel Haven remembers me differently now. Mira, Gus, Vendo, Mr. Byte, and Cabinet 07 may have changed things to say. Roxy and Pip may add their own pieces if I met them.",
		_:
				"title": "No Active Quest",
				"summary": "There is no current objective.",
				"details": "There is no active quest right now.",
```

#### `GameState.gd` — `_with_registry_quest_data()`

```gdscript
func _with_registry_quest_data(base_data: Dictionary, registry_id: String) -> Dictionary:
	merged["owner"] = str(registry_data.get("owner", ""))
	merged["location"] = str(registry_data.get("location", ""))
	merged["minigame"] = str(registry_data.get("minigame", ""))
	merged["required"] = bool(registry_data.get("required", true))
	merged["starts_after"] = str(registry_data.get("starts_after", ""))
```


#### RouteCue hint bar (per-room LOCAL/ROUTE guidance)


#### `RouteCue.gd` — `get_current_hint()`

```gdscript
static func get_current_hint(current_location_id: String) -> String:
	if state == null or not state.has_method("get_current_quest_id"):
		return ""
	match quest_id:
		"opening_look_around":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Look around. Talk to whoever is still here.")
		"opening_talk_to_mira":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Mira at the ticket counter.")
		"recover_lost_token":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Play Cabinet 07 on the main floor.")
		"return_lost_token":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Return the Lost Token to Mira.")
		"broken_high_score":
			if not bool(state.get("roxy_met")):
				return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Roxy by the score cabinet.")
			return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Use the BROKEN SCORE cabinet.")
		"prize_sort":
			if not bool(state.get("pip_met")):
				return _local_or_route(current_location_id, "prize_corner", "LOCAL: Talk to Pip by the prize counter.")
			return _local_or_route(current_location_id, "prize_corner", "LOCAL: Use the PRIZE COUNTER.")
		"truth_filter":
			if int(state.call("get_npc_dialogue_count", "mr_byte_tf_explained")) == 0:
				return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Mr. Byte about the Truth Filter.")
			return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Use the Truth Filter cabinet.")
		"mr_byte_debrief":
			return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Tell Mr. Byte what the Filter found.")
		"gus_checkin_truth_filter":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Gus on the arcade floor.")
		"circuit_soda":
			if int(state.call("get_npc_dialogue_count", "vendo_circuit_explained")) == 0:
				return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Talk to Vendo about Circuit Soda.")
			return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Use the Circuit Soda machine.")
		"gus_checkin_prize_sort":
			return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Gus on the arcade floor.")
		"lost_shift_file":
			return _get_lost_shift_hint(current_location_id, state)
		"static_service_run":
			return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Talk to Gus, then run Static Service.")
		"maintenance_sync":
			return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Use Maintenance Sync by Gus.")
		"staff_corridor":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Follow the Staff Door signal deeper.")
		"security_tape_assembly":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Restore the Security Tape.")
		"final_night_walk":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Walk the Final Night route.")
		"stabilize_memory_echo":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Stabilize the Memory Echo.")
		"enter_staff_room":
			return _local_or_route(current_location_id, "staff_corridor", "LOCAL: Enter the Staff Room.")
		"finish_memory":
			return _local_or_route(current_location_id, "staff_room", "LOCAL: Let the memory finish.")
		"talk_to_witnesses":
			return _get_witness_hint(current_location_id, state)
	return ""
```

#### `RouteCue.gd` — `_get_lost_shift_hint()`

```gdscript
static func _get_lost_shift_hint(current_location_id: String, state: Node) -> String:
	if not bool(state.get("closing_checklist_read")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Read the Closing Checklist near the counter.")
	if not bool(state.get("staff_schedule_read")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Read the Staff Schedule by Mr. Byte.")
	if not bool(state.get("maintenance_note_read")):
		return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Read Gus's Maintenance Note.")
	return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Tell Gus the Lost Shift File is complete.")
```

#### `RouteCue.gd` — `_get_witness_hint()`

```gdscript
static func _get_witness_hint(current_location_id: String, state: Node) -> String:
	if not bool(state.get("witness_mira_heard")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Talk to Mira.")
	if not bool(state.get("witness_cabinet07_heard")):
		return _local_or_route(current_location_id, "arcade_hub", "LOCAL: Check Cabinet 07.")
	if not bool(state.get("witness_mr_byte_heard")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Mr. Byte.")
	if bool(state.get("roxy_met")) and not bool(state.get("witness_roxy_heard")):
		return _local_or_route(current_location_id, "cabinet_row", "LOCAL: Talk to Roxy.")
	if not bool(state.get("witness_vendo_heard")):
		return _local_or_route(current_location_id, "snack_alcove", "LOCAL: Talk to Vendo.")
	if bool(state.get("pip_met")) and not bool(state.get("witness_pip_heard")):
		return _local_or_route(current_location_id, "prize_corner", "LOCAL: Talk to Pip.")
	if not bool(state.get("witness_gus_heard")):
		return _local_or_route(current_location_id, "maintenance_hall", "LOCAL: Talk to Gus.")
	return "LOCAL: Witness route complete."
```

#### `RouteCue.gd` — `_get_next_step()`

```gdscript
static func _get_next_step(current_location_id: String, target_location_id: String) -> String:
	match current_location_id:
		"arcade_hub":
			match target_location_id:
				"cabinet_row":
					return "Take the CABINET HALLWAY exit on the right."
				"snack_alcove":
					return "Right to CABINET ROW, then the SERVICE HALLWAY."
				"prize_corner":
					return "Right to CABINET ROW, SNACK ALCOVE, then the PRIZE SERVICE HALL."
				"maintenance_hall":
					return "Take the MAINTENANCE HALLWAY exit at the bottom."
				"staff_corridor", "staff_room":
					return "Bottom to MAINTENANCE, then STAFF ACCESS HALL."
				"front_entrance":
					return "Take the FRONT ENTRANCE exit on the left."
			return "Use %s exit." % _get_target_label(target_location_id)
		"cabinet_row":
			if target_location_id == "snack_alcove":
				return "Use the SERVICE HALLWAY on the right."
			if target_location_id == "arcade_hub":
				return "Take the CABINET HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"snack_alcove":
			if target_location_id == "cabinet_row":
				return "Take the SERVICE HALLWAY at the left end."
			if target_location_id == "prize_corner":
				return "Take the PRIZE SERVICE HALL at the right end."
			if target_location_id == "arcade_hub":
				return "Take the SNACK HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"prize_corner":
			if target_location_id == "snack_alcove":
				return "Take the PRIZE SERVICE HALL on the left."
			if target_location_id == "arcade_hub":
				return "Take the PRIZE HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"maintenance_hall":
			if target_location_id == "staff_corridor":
				return "Take the STAFF ACCESS HALL on the right."
			if target_location_id == "staff_room":
				return "Take the STAFF ACCESS HALL on the right."
			if target_location_id == "arcade_hub":
				return "Take the MAINTENANCE HALLWAY at the bottom."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"staff_corridor":
			if target_location_id == "staff_room":
				return "Use STAFF ROOM door."
			if target_location_id == "maintenance_hall":
				return "Take the STAFF ACCESS HALL at the bottom."
			if target_location_id == "arcade_hub":
				return "Take the BACK HALLWAY on the left."
			return "Back to ARCADE HUB, then %s." % _get_target_label(target_location_id)
		"cabinet_hallway":
			return "Take CABINET ROW exit." if target_location_id == "cabinet_row" else "Take ARCADE HUB exit."
		"snack_hallway":
			return "Take SNACK ALCOVE exit." if target_location_id == "snack_alcove" else "Take ARCADE HUB exit."
		"maintenance_hallway":
			return "Take MAINTENANCE exit." if target_location_id == "maintenance_hall" else "Take ARCADE HUB exit."
		"prize_hallway":
			return "Take PRIZE CORNER exit." if target_location_id == "prize_corner" else "Take ARCADE HUB exit."
		"back_hallway":
			return "Take STAFF CORRIDOR exit." if target_location_id == "staff_corridor" or target_location_id == "staff_room" else "Take ARCADE HUB exit."
		"cabinet_snack_hallway":
			return "Take SNACK ALCOVE exit." if target_location_id == "snack_alcove" else "Take CABINET ROW exit."
		"snack_prize_hallway":
			return "Take PRIZE CORNER exit." if target_location_id == "prize_corner" else "Take SNACK ALCOVE exit."
		"maintenance_staff_hallway":
			return "Take STAFF CORRIDOR exit." if target_location_id == "staff_corridor" or target_location_id == "staff_room" else "Take MAINTENANCE exit."
	return "Follow signs to %s." % _get_target_label(target_location_id)
```


### 4.5 Minigame & adventure stage text (instructions, in-stage story, ??? interference)


> **RockbyteDuel.gd** — Beat 2 — Cabinet 07's duel. Difficulty note: game 1 the cabinet plays perfectly, game 2 coin-flip, game 3+ eases up.


#### `RockbyteDuel.gd` — `_take_player_turn()`

```gdscript
func _take_player_turn(choice: String) -> void:
	if duel_finished or visual_sequence_running:
	match choice:
		"left":
			if left_pile <= 0:
				status_label.text = "That pile is empty."
			player_message = "You took 1 from the left pile."
		"right":
			if right_pile <= 0:
				status_label.text = "That pile is empty."
			player_message = "You took 1 from the right pile."
		"both":
			if left_pile <= 0 or right_pile <= 0:
				status_label.text = "Both piles need rocks for that move."
			player_message = "You took 1 from both piles."
	if left_pile == 0 and right_pile == 0:
```

#### `RockbyteDuel.gd` — `_cabinet_turn()`

```gdscript
func _cabinet_turn(player_message: String) -> void:
	if duel_finished:
	if duel_finished:
	if left_pile == 0 and right_pile == 0:
	await _play_cabinet_move_visual(cabinet_move, int(removed.get("left", 0)), int(removed.get("right", 0)))
	if left_pile == 0 and right_pile == 0:
```

#### `RockbyteDuel.gd` — `_get_strategic_move()`

```gdscript
func _get_strategic_move() -> String:
	# loss-screen hint ("try keeping both piles even") teaches the same rule.
	if left_odd and right_odd:
		return "both"
	if left_odd:
		return "left"
	if right_odd:
		return "right"
	if left_pile >= right_pile and left_pile > 0:
		return "left"
	if right_pile > 0:
		return "right"
```

#### `RockbyteDuel.gd` — `_apply_cabinet_move()`

```gdscript
func _apply_cabinet_move(choice: String) -> void:
	match choice:
		"left":
			last_message = "Cabinet took 1 from the left pile."
		"right":
			last_message = "Cabinet took 1 from the right pile."
		"both":
			if left_pile > 0:
			if right_pile > 0:
			last_message = "Cabinet took 1 from both piles."
```

#### `RockbyteDuel.gd` — `_finish_duel()`

```gdscript
func _finish_duel(player_won: bool) -> void:
	if player_won:
		GameState.rockbyte_duel_completed = true
		GameState.collect_lost_token()
		exit_button.text = "Return to Arcade"
		status_label.text = "Lost Token recovered.\nReturn to Mira."
		_show_result_popup("TOKEN SIGNAL MATCHED.\nPREVIOUS SESSION FOUND.\nLost Token recovered.")
	GameState.rockbyte_duel_loss_count += 1
	status_label.text = "Duel lost.\nPress Retry Duel."
```

#### `RockbyteDuel.gd` — `_reset_duel()`

```gdscript
func _reset_duel() -> void:
	GameState.rockbyte_attempt_count += 1
	if attempt == 1:
	elif attempt == 2:
	last_message = "Choose one move each turn. Take the final rock to win."
```

#### `RockbyteDuel.gd` — `_refresh_counts()`

```gdscript
func _refresh_counts() -> void:
	count_label.text = "LEFT PILE: %d        RIGHT PILE: %d" % [left_pile, right_pile]
```

#### `RockbyteDuel.gd` — `_get_loss_text()`

```gdscript
func _get_loss_text() -> String:
	match loss_retry_count:
			return "Cabinet 07 remembers this loss.\nTry again."
			return "Hint: two piles can change together.\nPress Retry Duel."
		_:
			return "Cabinet 07: pattern aid unlocked.\nTry keeping both piles even."
```

#### `RockbyteDuel.gd` — `_play_result_visual()`

```gdscript
func _play_result_visual(player_won: bool) -> void:
	if stage == null or not stage.has_method("play_actor_action"):
	stage.call("play_actor_action", "player", "success" if player_won else "failure", Vector2(320, 230))
```

#### `RockbyteDuel.gd` — `_play_visual_sequence()`

```gdscript
func _play_visual_sequence(actions: Array[Dictionary]) -> void:
	if actions.is_empty() or action_queue == null:
	if not action_queue.has_method("clear") or not action_queue.has_method("add_action") or not action_queue.has_method("play"):
	for action_data in actions:
	if action_queue.has_method("is_playing") and not bool(action_queue.call("is_playing")):
	if action_queue.has_signal("sequence_finished"):
```


> **BrokenHighScore.gd** — Beat 3 — Roxy's reflex score-repair.


#### `BrokenHighScore.gd` — `_start_game()`

```gdscript
func _start_game() -> void:
	instruction_label.text = "BROKEN HIGH SCORE\nThe board screams 9999. It is lying.\nLOCK the record only when the digits hold still.\nBeat Roxy's ghost to the real score."
	status_label.text = "Roxy: \"Bet you cannot even read a real score.\""
```

#### `BrokenHighScore.gd` — `_on_score_pressed()`

```gdscript
func _on_score_pressed() -> void:
	if completed or not running:
	if stable:
		status_label.text = "Digit locked. %d of %d restored." % [repairs, TARGET_REPAIRS]
		if repairs >= TARGET_REPAIRS:
	else:
		status_label.text = "Locked static. Roxy's ghost gains."
```

#### `BrokenHighScore.gd` — `_lose_round()`

```gdscript
func _lose_round() -> void:
	status_label.text = "Roxy: \"Ghost wins. Again.\"\nThe board resets. Try actually watching this time."
```

#### `BrokenHighScore.gd` — `_complete_game()`

```gdscript
func _complete_game() -> void:
	GameState.complete_broken_high_score()
	fake_target_label.text = "ROXY GHOST: BEATEN"
	score_label.text = "RECORD RESTORED"
	status_label.text = "PREVIOUS SCORE FOUND.\nThe points came back clean. The name stayed blank.\nRoxy: \"...Fine. That was almost impressive.\""
```

#### `BrokenHighScore.gd` — `_refresh()`

```gdscript
func _refresh() -> void:
	fake_target_label.text = "ROXY GHOST: %02d / %02d" % [int(ghost), int(GHOST_TARGET)]
	score_label.text = "REPAIRED: %d / %d" % [repairs, TARGET_REPAIRS]
```


> **TruthFilter.gd** — Beat 4 — lie-density sorter; the statements below ARE story content (what the arcade believes/denies).


#### `TruthFilter.gd` — `(module)()`

```gdscript
		"rule": "Only one cabinet matches the shift log. Choose it.",
		"transition": "The filter checks the final night's shift log.",
			"Mira signed the register before close.",
			"Gus stayed mopping past midnight.",
			"Every machine was powered down that night.",
		"explanation": "23:41 - Mira signed the register and left. The log does not lie.",
		"rule": "Only one cabinet is lying. The log knows.",
		"transition": "The filter checks the return tray records.",
			"The closing checklist was run alone.",
			"Cabinet 07 kept a token in its tray.",
			"The return tray was emptied before close.",
		"explanation": "00:19 - the tray kept one token. Flagged: do not empty.",
		"rule": "Two cabinets copied the log. One wrote its own ending. Choose it.",
		"transition": "The filter checks the backup records.",
			"The backup finished clean.",
			"The backup started after midnight.",
			"The backup did not finish.",
		"explanation": "00:33 - backup started, never finished. Someone wanted a cleaner ending.",
		"rule": "Choose the line the arcade does not want you to read.",
		"transition": "The filter checks how the log ends.",
			"The last shift signed out on time.",
			"No sign-out was recorded for the last shift.",
			"The register page was archived complete.",
		"explanation": "Entry ends. No sign-out recorded. The page is still waiting.",
		"rule": "Two records are static wearing words. Choose the one with a lucid heart.",
		"transition": "The arcade tests what it still believes about you.",
			"This place was built to be somewhere kinder to go.",
			"You were only ever a visitor here.",
			"The arcade closed because nobody cared.",
		"explanation": "Somewhere kinder to go. The static cannot spell that away.",
```

#### `TruthFilter.gd` — `_start_puzzle()`

```gdscript
func _start_puzzle() -> void:
	if cabinet_home_positions.is_empty():
		for panel in cabinet_panels:
	memory_signal_label.text = "Source: Staff Shift Log"
	for button in choose_buttons:
```

#### `TruthFilter.gd` — `_show_round()`

```gdscript
func _show_round() -> void:
	rule_label.text = "Round %d / %d\n%s" % [current_round + 1, ROUND_DATA.size(), str(round_data["rule"])]
	for index in range(statement_labels.size()):
	status_label.text = "Records flicker between truth and static.\nRead them lucid. Sort before the lie density climbs."
```

#### `TruthFilter.gd` — `_on_choice_pressed()`

```gdscript
func _on_choice_pressed(index: int) -> void:
	if completed or round_transition_running:
	if index != correct_index:
		status_label.text = "FALSE RECORD SORTED.\nLie density spikes. Try again."
	status_label.text = "Statement accepted."
	if current_round >= ROUND_DATA.size():
```

#### `TruthFilter.gd` — `_complete_puzzle()`

```gdscript
func _complete_puzzle() -> void:
	GameState.complete_truth_filter()
	memory_signal_label.text = "Source: Staff Shift Log - VERIFIED"
	rule_label.text = "TRUTH FILTER COMPLETE"
	status_label.text = "TRUTH FILTER PASSED.\nSECOND MEMORY FRAGMENT RECOVERED.\nYOUR MEMORY IS NO LONGER THE ONLY WITNESS."
	for index in range(cabinet_panels.size()):
	for button in choose_buttons:
	exit_button.text = "Return to Cabinet Row"
```

#### `TruthFilter.gd` — `_set_signal_integrity()`

```gdscript
func _set_signal_integrity(value: String) -> void:
	signal_integrity_label.text = "Signal Integrity: %s" % value
	match value:
		"Wobbling":
		"Recovered":
		_:
```

#### `TruthFilter.gd` — `_update_density()`

```gdscript
func _update_density() -> void:
	signal_integrity_label.text = "Lie Density: %d%%" % int(lie_density)
	if lie_density >= 70.0:
	elif lie_density >= 40.0:
	else:
	for label in statement_labels:
```

#### `TruthFilter.gd` — `_destabilize()`

```gdscript
func _destabilize() -> void:
	status_label.text = "LIE DENSITY CRITICAL.\nThe filter purges the static and re-lists. Read faster."
```


> **CircuitSoda.gd** — Beat 5 — pipe-routing comic breather.


#### `CircuitSoda.gd` — `(module)()`

```gdscript
# "input_exit" and must enter the output through "output_enter". "locked"
		"hint": "Turn the middle pipe until the row flows straight across.",
		"input": Vector2i(0, 1), "input_exit": SIDE_E,
		"output": Vector2i(2, 1), "output_enter": SIDE_W,
		"hint": "The blocker seals the middle. Route the soda around the bottom.",
		"input": Vector2i(0, 0), "input_exit": SIDE_S,
		"output": Vector2i(2, 1), "output_enter": SIDE_S,
		"hint": "The middle is sealed. Ride the top edge over the blocker.",
		"input": Vector2i(0, 1), "input_exit": SIDE_N,
		"output": Vector2i(2, 1), "output_enter": SIDE_N,
		"hint": "Two blockers, two sealed plates. Snake it: right, down, back, down, right.",
		"input": Vector2i(0, 0), "input_exit": SIDE_E,
		"output": Vector2i(2, 2), "output_enter": SIDE_W,
```

#### `CircuitSoda.gd` — `_start_round()`

```gdscript
func _start_round(round_index: int) -> void:
	for tile in round_data["tiles"]:
	tiles[_index_from_pos(round_data["input"])] = {"shape": "input", "side": str(round_data["input_exit"])}
	tiles[_index_from_pos(round_data["output"])] = {"shape": "output", "side": str(round_data["output_enter"])}
	instruction_label.text = "CIRCUIT SODA\nRotate the pipes to link INPUT to OUTPUT.\nSealed plates and blockers do not turn.\nDo not spill identity."
	memory_signal_label.text = "Line Pressure: Nominal"
	status_label.text = "Route the soda from INPUT to OUTPUT."
```

#### `CircuitSoda.gd` — `_on_tile_pressed()`

```gdscript
func _on_tile_pressed(index: int) -> void:
	if completed or index < 0 or index >= tiles.size():
	if shape == "blocker":
		status_label.text = "BLOCKER: no beverage or identity may pass."
	if shape == "input" or shape == "output":
		status_label.text = "The socket is welded in place. Route to it."
	if bool(tile.get("locked", false)):
		status_label.text = "SEALED PLATE: this pipe does not turn."
	tile["rot"] = (int(tile.get("rot", 0)) + 1) % 4
	if moves_this_round >= 4:
	if not _has_connected_path():
		status_label.text = "Signal still misrouted."
```

#### `CircuitSoda.gd` — `_check_win()`

```gdscript
func _check_win() -> void:
	if not _has_connected_path():
	if completed:
	if current_round + 1 >= ROUNDS.size():
	status_label.text = "MEMORY FLOW ACCEPTED."
```

#### `CircuitSoda.gd` — `_complete_puzzle()`

```gdscript
func _complete_puzzle() -> void:
	GameState.complete_circuit_soda()
	memory_signal_label.text = "Line Pressure: Carbonated"
	round_label.text = "CIRCUIT SODA COMPLETE"
	instruction_label.text = "MEMORY FLOW RESTORED.\nCARBONATION LEVEL: UNRELATED.\nIDENTITY SIGNAL ROUTED."
	status_label.text = "Fractured signal stabilized."
```

#### `CircuitSoda.gd` — `_refresh_grid()`

```gdscript
func _refresh_grid() -> void:
	for index in range(tile_buttons.size()):
		if tile_sheet_texture != null:
		else:
		if bool(tile.get("locked", false)):
			button.tooltip_text = "Sealed plate - does not turn."
		else:
```


> **SyncDoorPuzzle.gd** — Beat 9 — Maintenance Sync door puzzle.


#### `SyncDoorPuzzle.gd` — `_ready()`

```gdscript
func _ready() -> void:
	title_label.text = "MAINTENANCE SYNC"
	instruction_label.text = "Two signals must be active together.\nOne signal remembers.\nOne signal returns."
```

#### `SyncDoorPuzzle.gd` — `_start_phase()`

```gdscript
func _start_phase(phase: int) -> void:
	match current_phase:
			phase_label.text = "Phase 2 / 3 - Reversed Signal"
			warning_label.text = "WARNING: ONE LABEL IS REVERSED."
			status_label.text = "Switch A label lies. Activate both real switches."
			phase_label.text = "Phase 3 / 3 - Stable Pulse"
			warning_label.text = "CONFIRM REQUIRED WHILE BOTH SIGNALS HOLD."
			status_label.text = "Activate A, then B, then confirm sync before either expires."
		_:
			phase_label.text = "Phase 1 / 3 - Basic Sync"
			status_label.text = "Activate both switches before either timer expires."
```

#### `SyncDoorPuzzle.gd` — `_check_phase_progress()`

```gdscript
func _check_phase_progress() -> void:
	if not switch_a_active or not switch_b_active:
	match current_phase:
			status_label.text = "BASIC SYNC ACCEPTED."
			status_label.text = "REVERSED SIGNAL ACCEPTED."
			status_label.text = "Both signals detected. Confirm sync now."
```

#### `SyncDoorPuzzle.gd` — `_complete_puzzle()`

```gdscript
func _complete_puzzle() -> void:
	GameState.complete_maintenance_sync()
	door_label.text = "Staff Door: OPEN"
	status_label.text = "TWO SIGNALS DETECTED.\nRESTORED SIGNAL PRESENT.\nACCESS GRANTED."
```

#### `SyncDoorPuzzle.gd` — `_signal_lost()`

```gdscript
func _signal_lost() -> void:
	status_label.text = "Signal lost.\nTry again."
```

#### `SyncDoorPuzzle.gd` — `_refresh_ui()`

```gdscript
func _refresh_ui() -> void:
	if puzzle_solved:
	door_label.text = "Staff Door: LOCKED"
	switch_b_button.text = "Switch B: %s" % ["ON" if switch_b_active else "OFF"]
	if current_phase == PHASE_STABLE_PULSE and switch_a_active and switch_b_active:
```

#### `SyncDoorPuzzle.gd` — `_get_switch_a_display_label()`

```gdscript
func _get_switch_a_display_label() -> String:
	if current_phase == PHASE_REVERSED:
		return "OFF" if switch_a_active else "ON"
	return "ON" if switch_a_active else "OFF"
```


> **SecurityTapeAssembly.gd** — Beat 10 — tape de-static + frame ordering; contains the anomaly frame (Mystery B evidence, must stay unexplained).


#### `SecurityTapeAssembly.gd` — `(module)()`

```gdscript
	"Counter lights shut off.",
	"Cabinet 07 remains powered.",
	"A staff member enters the back hall.",
	"The Staff Door records two signals.",
	"Counter lights shut off.",
	"Cabinet 07 remains powered.",
	"A staff member enters the back hall.",
	"The Staff Door records two signals.",
const ANOMALY_TEXT := "A second figure stands at the door. No timestamp."
const STATIC_TEXT := "▓▓▓ STATIC ▓▓▓  (press to clear)"
```

#### `SecurityTapeAssembly.gd` — `_ready()`

```gdscript
func _ready() -> void:
	GameState.start_security_tape_assembly()
	while _looks_presolved():
	for index in range(fragment_buttons.size()):
		if not button.pressed.is_connected(_on_fragment_pressed):
	status_label.text = "COILY: Ooh, home movies! Clear the static, then\nput the night back in order. One frame will not fit.\nTrust the feeling when you find it."
```

#### `SecurityTapeAssembly.gd` — `_on_fragment_pressed()`

```gdscript
func _on_fragment_pressed(index: int) -> void:
	if index < 0 or index >= display_fragments.size():
	if not revealed_indices.get(index, false):
	if selected_fragments.has(fragment):
	if selected_fragments.size() >= CORRECT_ORDER.size():
		status_label.text = "The reel only has four slots.\nOne of the five frames does not belong."
```

#### `SecurityTapeAssembly.gd` — `_on_submit_pressed()`

```gdscript
func _on_submit_pressed() -> void:
	if selected_fragments.size() != CORRECT_ORDER.size():
		status_label.text = "TAPE HEAD BUZZES.\nSeat four frames before playback."
	if selected_fragments.has(ANOMALY_TEXT):
		status_label.text = "FRAME REJECTED: NO TIMESTAMP.\nThat frame does not belong to any hour of that night.\nCOILY: ...I greeted everyone, pal. That one, I never greeted."
	if selected_fragments == CORRECT_ORDER:
		GameState.complete_security_tape_assembly()
		var closing := "TAPE ORDER RESTORED.\nTHE STAFF DOOR DID NOT RECORD A CUSTOMER."
		if anomaly_acknowledged:
			closing += "\nOne frame stays on the reel. It has no hour to return to."
		else:
			closing += "\nOne frame was never seated. It has no hour to return to."
	status_label.text = "TIMESTAMP CONFLICT.\nThe tape rewinds with an angry buzz."
```


> **StaticServiceRun.gd** — Beat 8 — flagship adventure 1. ??? Mode 2: drains lights/blackout set piece. Gus on comms, Reel scores.


#### `StaticServiceRun.gd` — `_ready()`

```gdscript
func _ready() -> void:
	GameState.start_static_service_run()
	_refresh_status("GUS (radio): Grid's dead. Flip breakers as you go.\n\nSomething hums back when you move.")
```

#### `StaticServiceRun.gd` — `get_stage_config()`

```gdscript
static func get_stage_config() -> Dictionary:
		"title": "STATIC SERVICE RUN",
		"objective": "The halls are dark. Flip the 16 fuse-breakers to light the route, dodge the patrolling static, and reach the main breaker (BRK).",
		"controls_hint": "Move: WASD / Arrows. R: restart.",
		"goal_hint": "All 16 fuses, then BRK.",
			"Breaker up. A stretch of hall remembers its lights.",
			"The conduit hums awake under the floor.",
			"Somewhere a fan starts turning again.",
			"A work lamp flickers on over an old toolbox.",
			"The wiring crackles, then settles.",
			"Warmth crawls a little further down the wall.",
			"A junction box blinks from red to green.",
			"You hear the vending machine upstairs reboot.",
			"The dark gives back another few meters.",
			"Old cable trays rattle with fresh current.",
			"A section light buzzes, steadies, holds.",
			"The floor stripes glow faintly again.",
			"Another circuit remembers its job.",
			"The hum behind the walls drops half a tone.",
			"The service route sign lights up: THIS WAY.",
			"One breaker left in the chain. The main panel waits.",
			"STATIC DISCHARGE.",
			"The dark rushes back into the aisle you just lit.",
			"Something is pulling the current out behind you.",
			"You lit that hall. It did not stay lit.",
			"You are not the only thing moving in these halls.",
			"SERVICE POWER RESTORED.",
			"The patrolling static thins, pulls back, and is gone.",
			"For a moment the hum sounds almost like breathing.",
			"STAFF DOOR SYSTEMS ONLINE.",
			"MAINTENANCE SYNC AVAILABLE.",
			"HIDDEN CACHE FOUND.",
			"A shelf of spare fuses, labeled in careful handwriting.",
			"\"Spares for the night shift. Take what you need. - 04\"",
			"The whole storage bay lights up at once.",
```

#### `StaticServiceRun.gd` — `_weave_reel_score_lines()`

```gdscript
func _weave_reel_score_lines(stage_config: Dictionary) -> void:
	# every fourth breaker (the spec's "Reel scores Static Service Run").
	var reel_lines: Array = DIALOGUE_POOL.get_lines("reel", "static_service_run_score", [])
	if reel_lines.size() < 4:
	if not texts is Array or (texts as Array).size() < 16:
	for i in range(4):
		if line is Dictionary:
			(texts as Array)[slots[i]] = "REEL (speakers): %s" % str((line as Dictionary).get("text", ""))
```

#### `StaticServiceRun.gd` — `_on_area_entered()`

```gdscript
func _on_area_entered(area_id: String) -> void:
	if area_id == "breaker" and not blackout_done and not completed:
		trigger_blackout("EVERY LIGHT GOES OUT AT ONCE.\n\nThe hum sharpens:\n\"I buried it dark\nfor a reason.\"\n\nThe static is faster now.\nReach the main breaker.", 0.62)
```


> **FinalNightWalk.gd** — Beat 11 — flagship adventure 2. ??? Mode 2 peak + cost spike; Coily haunts; staff-door ambush.


#### `FinalNightWalk.gd` — `_ready()`

```gdscript
func _ready() -> void:
	GameState.start_final_night_walk()
	_refresh_status("The tape rolls. Walk the route\nin the order the night happened.\n\nSomething else is walking it too.")
```

#### `FinalNightWalk.gd` — `get_stage_config()`

```gdscript
static func get_stage_config() -> Dictionary:
		"title": "FINAL NIGHT WALK",
		"objective": "Walk the final route as the tape remembers it. Collect the 16 Memory Frames in order. A second signal walks these halls - do not let it cross you.",
		"controls_hint": "Move: WASD / Arrows. R: restart.",
		"goal_hint": "Frames 1-16 in order, then EXIT.",
			"Counter lights shut off.",
			"Mira counted tokens twice.",
			"The ticket strip curled under the counter.",
			"Someone locked the front door from inside.",
			"Cabinet 07 stayed awake.",
			"A blank high score pulsed once.",
			"Someone walked past without a reflection.",
			"The cabinet row hummed a closing song.",
			"Vendo's display flickered without coins.",
			"The prize shelf tags turned backward.",
			"A plush faced the staff hallway.",
			"The schedule changed after closing.",
			"A staff member entered the back hall.",
			"The security tape skipped.",
			"The Staff Door recorded two signals.",
			"One signal kept walking.",
			"TIMESTAMP CONFLICT.",
			"That is not the next thing that happened.",
			"The route pulls you back to remember.",
			"The route pulls you back.",
			"The second signal crosses your path.",
			"For one frame you see the route the way it walked it.",
			"A counter, dark. A door, patient. A turn not taken.",
			"The tape rewinds you to where you were.",
			"FINAL NIGHT ROUTE STABILIZED.",
			"The second signal stops moving.",
			"It stands at the Staff Door, waiting for you to catch up.",
			"MEMORY ECHO AVAILABLE.",
			"THE STAFF DOOR DID NOT RECORD A CUSTOMER.",
			"PRIVATE FRAME FOUND.",
			"A moment the tape never showed anyone:",
			"someone kneeling to fix the plush's bow tie",
			"before turning off the prize corner lights.",
				"name": "Counter After Close",
				"name": "Snack And Prize Path",
				"name": "Back Hall Footsteps",
				"name": "Staff Door Memory",
```

#### `FinalNightWalk.gd` — `_on_area_entered()`

```gdscript
func _on_area_entered(area_id: String) -> void:
	if area_id == "staff_door" and not ambush_done and not completed:
		_refresh_status("The second signal knew\nwhere you were going.\n\nIt got here first.\n\nIt walks the top hall now,\nfaster than the tape.")
```


> **MemoryEcho.gd** — Beat 12 — anchor true memories; ??? Mode 3: seizes control mid-stage. Reel hosts.


#### `MemoryEcho.gd` — `(module)()`

```gdscript
		"prompt": "You came here before.",
			"No. I just arrived.",
			"Maybe. I do not remember.",
			"The arcade is lying.",
			"Absence of memory is not proof of absence.",
		"prompt": "The others remembered you.",
			"Then why did they hide it?",
			"Because I was dangerous.",
			"Because I was not ready.",
			"They waited until you could hold it.",
		"prompt": "One signal entered. One signal remained.",
			"Both. I carry both now.",
			"Identity conflict stabilizing.",
const DECOY_TEXT := "Only me. There was never a both."
```

#### `MemoryEcho.gd` — `_show_question()`

```gdscript
func _show_question() -> void:
	if current_question_index == 0:
		echo_label.text = "REEL: Last set, pal. Some of these tracks are yours.\nSome got recorded over. Catch the real ones.\n\n%s" % str(question.get("prompt", ""))
	elif current_question_index == 2 and not hijack_done:
		echo_label.text = "The playback seizes. Something else holds the reel.\n\n%s" % str(question.get("prompt", ""))
	else:
		echo_label.text = "%s\nAnchor the memory that is truly yours." % str(question.get("prompt", ""))
```

#### `MemoryEcho.gd` — `_process()`

```gdscript
func _process(delta: float) -> void:
	if not catching:
	if question_timer >= QUESTION_TIME_LIMIT:
	if question_timer >= QUESTION_SOFT_WINDOW and not drift_accelerated:
		speaker_label.text = "The memory is drifting..."
		for i in range(velocities.size()):
		for frag in fragments:
			if is_instance_valid(frag):
	for i in range(fragments.size()):
		if not is_instance_valid(frag):
		if pos.x <= PLAY_MIN.x or pos.x >= PLAY_MAX.x:
		if pos.y <= PLAY_MIN.y or pos.y >= PLAY_MAX.y:
```

#### `MemoryEcho.gd` — `_on_fragment_clicked()`

```gdscript
func _on_fragment_clicked(index: int) -> void:
	if finished or not catching:
	if index == int(question.get("preferred_index", -1)):
	if index == DECOY_INDEX:
		speaker_label.text = "???: That one is mine. Put it down."
	else:
		speaker_label.text = "That memory is not yours. It drifts away."
```

#### `MemoryEcho.gd` — `_slip_question()`

```gdscript
func _slip_question() -> void:
	echo_label.text = "The fragments sink back into static.\nBreathe. The song starts over."
	if finished or GameState.memory_echo_completed:
```

#### `MemoryEcho.gd` — `_on_continue_pressed()`

```gdscript
func _on_continue_pressed() -> void:
	if finished:
	_play_audio("play_ui_cancel" if continue_mode == MODE_COMPLETE else "play_ui_confirm")
	match continue_mode:
			if current_question_index >= QUESTIONS.size():
		_:
```

#### `MemoryEcho.gd` — `_show_completion()`

```gdscript
func _show_completion() -> void:
	GameState.complete_memory_echo()
	echo_label.text = "MEMORY ECHO STABILIZED."
	response_label.text = "REEL: That is your setlist. Rough, honest, yours.\nHold onto it. The next room will test the tune.\nRESTORE PLAYBACK AVAILABLE."
```

#### `MemoryEcho.gd` — `_show_repeat_complete()`

```gdscript
func _show_repeat_complete() -> void:
	echo_label.text = "MEMORY ECHO STABILIZED."
	response_label.text = "RESTORE PLAYBACK AVAILABLE."
```


> **ArcadeAdventureStage.gd** — Shared adventure framework messages (both flagships).


#### `ArcadeAdventureStage.gd` — `(module)()`

```gdscript
var stage_title := "ARCADE ADVENTURE"
var objective_text := "Collect everything and reach the exit."
var hazard_lines: Array[String] = ["STATIC DISCHARGE.", "Signal reset."]
var wrong_order_lines: Array[String] = ["TIMESTAMP CONFLICT.", "The memory rewinds."]
var controls_hint := "Move: WASD / Arrow Keys"
var goal_hint := "Goal unlocks after objectives."
```

#### `ArcadeAdventureStage.gd` — `_ready()`

```gdscript
func _ready() -> void:
	if layout.is_empty():
			"title": "ARCADE ADVENTURE",
			"objective": "Move with WASD or arrows. Collect the marker and reach the exit.",
			"completion_lines": ["STAGE COMPLETE."],
```

#### `ArcadeAdventureStage.gd` — `_get_area_link_for_tile()`

```gdscript
func _get_area_link_for_tile(tile: String) -> Dictionary:
	if tile.is_empty():
	for link in area_links:
		if str(link.get("from_area", "")) == active_area_id and str(link.get("marker", "")) == tile:
```

#### `ArcadeAdventureStage.gd` — `_change_area()`

```gdscript
func _change_area(link: Dictionary) -> void:
	if target_area_id.is_empty() or not area_layouts.has(target_area_id):
		_refresh_status("Passage signal missing.")
```

#### `ArcadeAdventureStage.gd` — `_try_complete()`

```gdscript
func _try_complete() -> void:
	if completed or return_in_progress:
	if collected_positions.size() < required_collectibles:
		_refresh_status("Exit locked.\n%s: %d / %d" % [collectible_label, collected_positions.size(), required_collectibles])
	if reset_button:
```

#### `ArcadeAdventureStage.gd` — `trigger_blackout()`

```gdscript
func trigger_blackout(message: String, speed_multiplier: float = 0.7) -> void:
	for h: Dictionary in active_moving_hazards:
		h["interval"] = maxf(0.18, float(h.get("interval", 0.5)) * speed_multiplier)
```

#### `ArcadeAdventureStage.gd` — `_reset_stage()`

```gdscript
func _reset_stage() -> void:
	if completed or return_in_progress or initial_config.is_empty():
	_refresh_status("STAGE RESTARTED.\nThe route resets. The dark does not mind.")
```

#### `ArcadeAdventureStage.gd` — `_get_legend_text()`

```gdscript
func _get_legend_text() -> String:
	if collectible_name.ends_with("s"):
	return "%s=%s  %s=Hazard  %s=Goal" % [
```

#### `ArcadeAdventureStage.gd` — `_build_moving_hazards()`

```gdscript
func _build_moving_hazards() -> void:
	if moving_hazard_defs.is_empty() or tile_container == null:
	for def: Dictionary in moving_hazard_defs:
		if str(def.get("area", active_area_id)) != active_area_id:
		if waypoints.size() <= 1:
		if hazard_tex != null:
		var label_text := "" if hazard_tex != null else str(def.get("marker", hazard_marker))
		if not label_text.is_empty():
		if interval <= 0.0:
```

#### `ArcadeAdventureStage.gd` — `_update_moving_hazards()`

```gdscript
func _update_moving_hazards(delta: float) -> void:
	if active_moving_hazards.is_empty():
	for h: Dictionary in active_moving_hazards:
		h["timer"] = float(h.get("timer", 0.0)) + delta
		if h["timer"] >= float(h.get("interval", 0.5)):
	if stepped:
```


> **RoomAdventureStage.gd** — Optional per-room mini-adventures framework.


#### `RoomAdventureStage.gd` — `_get_hub_ticket_config()`

```gdscript
static func _get_hub_ticket_config() -> Dictionary:
		"objective": "Sweep the arcade floor. Collect 8 loose Tickets, avoid spill tiles, then return to CTR.",
		"goal_hint": "8 Tickets, watch the spill, then CTR.",
		"hazard_lines": ["STICKY CARPET.", "Back to the counter."],
		"completion_lines": ["TICKET SWEEP COMPLETE.", "The floor remembers less noise now."],
```

#### `RoomAdventureStage.gd` — `_get_cabinet_trace_config()`

```gdscript
static func _get_cabinet_trace_config() -> Dictionary:
		"title": "CABINET TRACE RUN",
		"objective": "Follow the cabinet trace in order. Collect 10 Trace Sparks, avoid static, then reach LOG.",
		"goal_hint": "Collect Sparks 1-10 in order, then reach LOG.",
			"Cabinet boot spark recovered.",
			"Truth cabinet ping accepted.",
			"Blank score trace accepted.",
			"Roxy's cabinet flickers once.",
			"Mr. Byte logs the order.",
			"Old profile trace recovered.",
			"False record trace discarded.",
			"Screen static narrows.",
			"Cabinet row signal lines up.",
			"Trace route complete.",
		"wrong_order_lines": ["TRACE ORDER CONFLICT.", "The cabinet row rewinds."],
		"hazard_lines": ["CABINET STATIC.", "Trace reset."],
		"completion_lines": ["CABINET TRACE COMPLETE.", "The row remembers in order."],
```

#### `RoomAdventureStage.gd` — `_get_snack_service_config()`

```gdscript
static func _get_snack_service_config() -> Dictionary:
		"title": "SNACK SERVICE DASH",
		"objective": "Stock the route without spilling the signal. Collect 9 Labels, dodge fizz, then reach OUT.",
		"goal_hint": "Collect all 9 Labels, then reach OUT.",
		"hazard_lines": ["CARBONATION BURST.", "Route pressure reset."],
		"completion_lines": ["SNACK SERVICE COMPLETE.", "Labels sorted. Signal still fizzy."],
```

#### `RoomAdventureStage.gd` — `_get_prize_shelf_config()`

```gdscript
static func _get_prize_shelf_config() -> Dictionary:
		"title": "PRIZE SHELF RUN",
		"objective": "Sort the shelf path by feeling, not value. Collect 7 Tags, avoid loose hooks, then reach TAG.",
		"goal_hint": "Collect all 7 Tags, then reach TAG.",
		"hazard_lines": ["LOOSE PRIZE HOOK.", "Back to the shelf start."],
		"completion_lines": ["PRIZE SHELF RUN COMPLETE.", "Nothing valuable moved. Something familiar did."],
```


### 4.6 Title / system / other player-facing text


#### `PauseMenu.gd` — `_on_save_slot_menu_closed()`

```gdscript
func _on_save_slot_menu_closed() -> void:
	if save_slot_menu != null and is_instance_valid(save_slot_menu):
	if not visible:
	status_label.text = "Save menu closed."
```


#### `SaveSlotMenu.gd` — `_refresh_slots()`

```gdscript
func _refresh_slots() -> void:
	for slot_id in range(1, 4):
		if not save_exists:
			var empty_action := "CHOOSE TO BEGIN" if current_mode == MODE_NEW_GAME else "CANNOT LOAD"
			button.text = "MEMORY SLOT %d\nEMPTY SAVE\n%s" % [slot_id, empty_action]
		else:
			button.text = "MEMORY SLOT %d\nSTATUS: %s\nMAIN: %d / %d\nOPTIONAL: %d / %d\nSECRETS: %d / %d\nLAST SAVED: %s" % [
```

#### `SaveSlotMenu.gd` — `_handle_new_game_slot()`

```gdscript
func _handle_new_game_slot(slot_id: int) -> void:
	if SaveManager.has_save(slot_id):
	if SaveManager.start_new_memory(slot_id):
		status_label.text = "New save created in Slot %d." % slot_id
	_show_failure("Could not create Save Slot %d." % slot_id)
```

#### `SaveSlotMenu.gd` — `_handle_load_slot()`

```gdscript
func _handle_load_slot(slot_id: int) -> void:
	if not SaveManager.has_save(slot_id):
		_show_failure("Save Slot %d is empty. Nothing to load." % slot_id)
	status_label.text = "Loading Save Slot %d..." % slot_id
	if SaveManager.load_game(slot_id):
	_show_failure("Could not load Save Slot %d." % slot_id)
```

#### `SaveSlotMenu.gd` — `_handle_save_slot()`

```gdscript
func _handle_save_slot(slot_id: int) -> void:
	if SaveManager.has_save(slot_id):
	if SaveManager.save_game(slot_id):
		status_label.text = "Saved to Slot %d." % slot_id
	_show_failure("Could not save to Slot %d." % slot_id)
```

#### `SaveSlotMenu.gd` — `_confirm_overwrite()`

```gdscript
func _confirm_overwrite(slot_id: int, mode: String) -> void:
	confirm_overwrite.title = "Overwrite Save Slot %d" % slot_id
	confirm_overwrite.dialog_text = "Replace Save Slot %d?\nThe old save file in this slot will be lost." % slot_id
```

#### `SaveSlotMenu.gd` — `_on_overwrite_confirmed()`

```gdscript
func _on_overwrite_confirmed() -> void:
	if pending_slot_id <= 0:
	match mode:
			if SaveManager.start_new_memory(slot_id):
				status_label.text = "Save Slot %d overwritten." % slot_id
			_show_failure("Could not overwrite Save Slot %d." % slot_id)
			if SaveManager.save_game(slot_id):
				status_label.text = "Save Slot %d overwritten." % slot_id
			_show_failure("Could not overwrite Save Slot %d." % slot_id)
```

#### `SaveSlotMenu.gd` — `_on_overwrite_canceled()`

```gdscript
func _on_overwrite_canceled() -> void:
	status_label.text = "Overwrite canceled. Slot was kept."
```

#### `SaveSlotMenu.gd` — `_get_subtitle_text()`

```gdscript
func _get_subtitle_text() -> String:
	match current_mode:
			return "NEW SAVE - CHOOSE A SLOT"
			return "LOAD SAVE - CHOOSE A SAVED SLOT"
		_:
			return "SAVE FILE - CHOOSE A SLOT"
```

#### `SaveSlotMenu.gd` — `_get_mode_display_text()`

```gdscript
func _get_mode_display_text() -> String:
	match current_mode:
			return "MODE: SAVE FILE"
			return "MODE: LOAD SAVE"
		_:
			return "MODE: NEW SAVE"
```


#### `QuestNotice.gd` — `_process()`

```gdscript
func _process(delta: float) -> void:
	if announce_accum < ANNOUNCE_POLL_SECONDS:
	if hud_root == null:
	if visible or get_tree().paused:
	if hud_root != null and not hud_root.visible:
	if quest_id.is_empty():
	var signature: String = "%s|%s" % [quest_id, str(GameState.get_current_quest_data().get("summary", ""))]
	if signature == last_announced_signature:
	if OPENING_QUEST_IDS.has(quest_id):
	if scene != null and scene.has_method("_dialogue_is_active") and bool(scene.call("_dialogue_is_active")):
	if ConscienceEncounterDirector.is_encounter_active():
	GameState.last_announced_quest_id = quest_id
```

#### `QuestNotice.gd` — `_input()`

```gdscript
func _input(event: InputEvent) -> void:
	if not visible or close_button.visible:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
```

#### `QuestNotice.gd` — `show_details()`

```gdscript
func show_details(quest_data: Dictionary) -> void:
	if hide_tween and hide_tween.is_valid():
		str(quest_data.get("title", "No Active Quest")),
```

#### `QuestNotice.gd` — `_format_quest_body()`

```gdscript
func _format_quest_body(quest_data: Dictionary, details_mode: bool) -> String:
	var required_text := "Required" if bool(quest_data.get("required", true)) else "Optional"
	if not owner.is_empty():
	if not location.is_empty():
	var body_key := "details" if details_mode else "summary"
	if body_text.is_empty():
	if not body_text.is_empty():
	return "\n".join(lines)
```


#### `EndingPrompt.gd` — `_build_return_to_title_confirm()`

```gdscript
func _build_return_to_title_confirm() -> void:
	return_to_title_confirm.title = "Return to Title"
	return_to_title_confirm.dialog_text = "Save current memory before returning to title?"
```


#### `SlideshowCutscene.gd` — `start_cutscene()`

```gdscript
func start_cutscene(slide_list: Array) -> void:
	prompt_label.text = "Press E / Space to continue"
	if slides.is_empty():
```

#### `SlideshowCutscene.gd` — `_show_current_slide()`

```gdscript
func _show_current_slide() -> void:
	if finished or current_index < 0 or current_index >= slides.size():
	if active_tween and active_tween.is_valid():
	prompt_label.text = "Press E / Space to continue"
```

#### `SlideshowCutscene.gd` — `_get_slide_data()`

```gdscript
func _get_slide_data(index: int) -> Dictionary:
	if index < 0 or index >= slides.size():
	if typeof(slides[index]) == TYPE_DICTIONARY:
		return slides[index]
	return {"caption": str(slides[index]), "effect": "fade", "image_path": ""}
```

#### `SlideshowCutscene.gd` — `_apply_image()`

```gdscript
func _apply_image(image_path: String) -> void:
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		missing_panel_label.text = "MEMORY PANEL\nPlaceholder image pending"
	if texture is Texture2D:
	else:
		missing_panel_label.text = "MEMORY PANEL\nPlaceholder image pending"
```

#### `SlideshowCutscene.gd` — `_show_final_memory_prompt()`

```gdscript
func _show_final_memory_prompt() -> void:
	caption_label.text = "The memory settles."
	prompt_label.text = "Press E / Space to finish memory"
```


#### `Player.gd` — `_update_sprite_animation()`

```gdscript
func _update_sprite_animation(is_moving: bool) -> void:
	var animation_name := "%s_%s" % ["walk" if is_moving else "idle", facing_direction]
	if animated_sprite.animation != animation_name:
```

#### `Player.gd` — `_set_prompt()`

```gdscript
func _set_prompt() -> void:
	if not can_control:
	if nearby_interactables.is_empty():
	else:
		interaction_prompt_changed.emit("Press E to interact")
```


#### Not covered above (catch-all)


#### `DialogueBox.gd` — `(module)()`

```gdscript
	"Staff Room Door",
	"Memory Terminal",
	"Maintenance Sync",
	"Maintenance Note",
	"Closing Checklist",
```

#### `DialogueBox.gd` — `_ready()`

```gdscript
func _ready() -> void:
	continue_prompt_label.text = "PRESS E / SPACE"
	if settings and settings.has_signal("settings_changed"):
```

#### `DialogueBox.gd` — `_refresh_line()`

```gdscript
func _refresh_line() -> void:
	if not active or current_index >= dialogue_lines.size():
	var speaker := str(line.get("speaker", ""))
	if current_reveal_mode == "words":
	else:
	if current_reveal_mode == "instant":
	if current_reveal_mode == "antagonist":
	if current_reveal_mode == "words":
```


#### `QuestRegistry.gd` — `_load_quests()`

```gdscript
static func _load_quests() -> Dictionary:
	if ResourceLoader.exists(QUEST_DATA_PATH):
		if file != null:
			if parsed is Dictionary:
				if quest_value is Dictionary:
	push_warning("QuestRegistry: using fallback quest definitions.")
```

#### `QuestRegistry.gd` — `_fallback_quests()`

```gdscript
static func _fallback_quests() -> Dictionary:
			"title": "Recover the Lost Token",
			"summary": "Play Cabinet 07 and bring the Lost Token back to Mira.",
			"details": "Mira says Cabinet 07 has the Lost Token. Recover it, then return to the ticket counter.",
				{"speaker": "Mira", "text": "You brought it back."},
				{"speaker": "Mira", "text": "That token used to be just a prize."},
				{"speaker": "Mira", "text": "Then it became proof that part of you could still return."},
				{"speaker": "Mira", "text": "It remembered you before you did."},
			"summary": "Meet Mr. Byte in Cabinet Row and open the Truth Filter.",
			"details": "The Lost Token woke a memory, but the arcade is still filtering the truth. Mr. Byte can open the Truth Filter from Cabinet Row.",
				{"speaker": "Mr. Byte", "text": "Truth Filter passed."},
				{"speaker": "Mr. Byte", "text": "Contradictions remain."},
				{"speaker": "Mr. Byte", "text": "That means the memory is alive enough to argue."},
				{"speaker": "Mr. Byte", "text": "Record conflict reduced. Identity conflict remains."},
			"title": "Route the Signal",
			"summary": "Help Vendo stabilize the memory signal.",
			"details": "The Truth Filter recovered a second fragment, but the signal is still misrouted. Vendo says the arcade can move a memory through the wrong machine and still recognize the flavor.",
				{"speaker": "Vendo", "text": "Signal routed."},
				{"speaker": "Vendo", "text": "You successfully became beverage-adjacent data."},
				{"speaker": "Vendo", "text": "I would offer a receipt, but the printer remembers too much."},
				{"speaker": "Vendo", "text": "Your label is still missing, but the machine knows what shelf you go on."},
			"title": "Maintenance Sync",
			"location": "Maintenance Hall",
			"summary": "Help Gus stabilize the Staff Door signals.",
			"details": "Vendo routed the signal, but the Staff Door still needs two unstable signals to line up. Gus says the door is listening for something doubled.",
			"minigame": "Maintenance Sync",
				{"speaker": "Gus", "text": "Door's listening now."},
				{"speaker": "Gus", "text": "I do not like doors that listen."},
				{"speaker": "Gus", "text": "But if it opens, part of you matched something it lost."},
				{"speaker": "Gus", "text": "It matched you against something in its log. I did not read it. On purpose."},
			"title": "Lost Shift File",
			"owner": "Mira / Gus / Mr. Byte",
			"location": "ArcadeHub, Maintenance Hall, Cabinet Row",
			"summary": "Read the records from the Final Night.",
			"details": "The signal is routed, but the Staff Door still refuses to open. Three records from the Final Night may explain why.",
				{"speaker": "Quest", "text": "LOST SHIFT FILE COMPLETE"},
				{"speaker": "Quest", "text": "A redacted staff number was assigned to Cabinet shutdown."},
			"title": "Static Service Run",
			"location": "Maintenance Hall",
			"summary": "Restore service power for the Staff Door systems.",
			"details": "The Lost Shift File gave Gus enough context to work with the door, but the maintenance system still needs power. Run the service route and recover the Signal Fuses.",
			"minigame": "Static Service Run",
				{"speaker": "Gus", "text": "Power's back."},
				{"speaker": "Gus", "text": "Door's awake."},
				{"speaker": "Gus", "text": "That is usually good news, except when the door is smarter than the staff."},
				{"speaker": "Gus", "text": "Now we can line the door up with what it lost."},
			"title": "Enter the Staff Corridor",
			"summary": "Follow the Overloaded signal past the Staff Door.",
			"details": "Gus stabilized the door, but the arcade is not ready to show the Staff Room yet. Something is echoing in the corridor.",
				{"speaker": "Staff Door", "text": "ACCESS GRANTED."},
				{"speaker": "Staff Door", "text": "EMPLOYEE SIGNAL ACCEPTED."},
			"title": "Assemble the Security Tape",
			"owner": "Staff Door / Mr. Byte",
			"summary": "Restore the damaged Final Night sequence.",
			"details": "The Staff Door recorded two signals, but the tape is damaged. Assemble the fragments before confronting the Memory Echo.",
			"minigame": "Security Tape Assembly",
				{"speaker": "Mr. Byte", "text": "Tape order restored."},
				{"speaker": "Staff Door", "text": "The Staff Door did not record a customer."},
			"title": "Final Night Walk",
			"owner": "Staff Door / Memory System",
			"summary": "Walk through the reconstructed Final Night.",
			"details": "The security tape is assembled, but the memory is still too unstable to play back. Walk the reconstructed route before confronting the Memory Echo.",
			"minigame": "Final Night Walk",
				{"speaker": "Staff Door", "text": "ROUTE ACCEPTED."},
				{"speaker": "Staff Door", "text": "FINAL NIGHT SEQUENCE STABILIZED."},
				{"speaker": "Staff Door", "text": "ONE WALKED IN."},
				{"speaker": "Staff Door", "text": "TWO SIGNALS ANSWERED."},
			"title": "Stabilize the Memory Echo",
			"summary": "Stabilize the Memory Echo.",
			"details": "The Final Night route is stable. The Memory Echo can now stabilize the signal before the Staff Room reveals what happened.",
				{"speaker": "Memory Echo", "text": "Echo stabilized."},
				{"speaker": "Memory Echo", "text": "The arcade stops arguing with itself."},
				{"speaker": "Memory Echo", "text": "That might be worse."},
			"title": "Broken High Score",
			"summary": "Restore a corrupted high-score record.",
			"details": "The score claims the target is 9999, but the display is broken. The real record may be much smaller and much stranger.",
			"minigame": "Broken High Score",
				{"speaker": "Roxy", "text": "Huh. Your score came back."},
				{"speaker": "Roxy", "text": "That usually does not happen after a reset."},
				{"speaker": "Roxy", "text": "Do not let it go to your head. You still walk like a tutorial."},
			"summary": "Arrange three prize labels by memory state.",
			"details": "Pip says the prize labels remember an order: Ticket Stub, Lost Token, then Blank Employee Badge.",
				{"speaker": "Pip", "text": "Prizes sorted."},
				{"speaker": "Pip", "text": "Some rewards remember their owner before the owner remembers them."},
			"title": "Staff Records Chain",
			"location": "Cabinet Row, Maintenance Hall, Staff Corridor",
			"summary": "Read three optional staff records after the Truth Filter.",
			"details": "The arcade preserved small system notes around the Final Night. They deepen the identity mystery without blocking the required route.",
				{"speaker": "Quest", "text": "STAFF RECORDS CHAIN COMPLETE"},
				{"speaker": "Quest", "text": "The arcade knew the number before it knew the name."},
			"title": "Post-Reveal Witness Route",
			"owner": "Mira / Gus / Vendo / Mr. Byte / Cabinet 07",
			"location": "ArcadeHub, Cabinet Row, Maintenance Hall, Snack Alcove",
			"summary": "Speak with the core witnesses after the reveal.",
			"details": "Pixel Haven remembers the protagonist in pieces. Roxy and Pip can add optional reflections if the player met them.",
				{"speaker": "Quest", "text": "POST-REVEAL WITNESSES COMPLETE"},
				{"speaker": "Quest", "text": "Pixel Haven remembers you in pieces."},
				{"speaker": "Quest", "text": "Together, they almost make a person."},
```


### 4.7 Static scene text (labels baked into scenes; some are runtime-replaced)


**scenes/arcade/ArcadeHub.tscn**
- Objective: Talk to Mira.
- The arcade is quiet now.
But some machines are still awake.

**scenes/arcade/StaffRoom.tscn**
- EMPLOYEE 04 FILE
- The old terminal is still running.
- Return to Arcade

**scenes/arcade/SyncDoorPuzzle.tscn**
- MAINTENANCE SYNC
- Two signals must be active together.
One signal remembers.
One signal returns.
- Phase 1 / 3 - Basic Sync
- Staff Door: Locked
- Activate both switches to open the door.
- Return to Maintenance

**scenes/cutscenes/ConscienceEncounter.tscn**
- You should not have returned.
- PRESS E / SPACE

**scenes/cutscenes/EndingPrompt.tscn**
- The loop is closed.
Your memory has changed.
Pixel Haven is quiet now, but the arcade will remember you differently.
Save and continue to hear what changed.
- Save and Continue
- Return to Title

**scenes/cutscenes/MemoryEcho.tscn**
- You came here before.

**scenes/cutscenes/SlideshowCutscene.tscn**
- MEMORY PANEL
Placeholder image pending
- Press E / Space to continue

**scenes/maps/CabinetRow.tscn**
- Mr. Byte owns the Truth Filter. Other cabinets sleep in the dark.

**scenes/maps/FrontEntrance.tscn**
- The doors are locked from the outside. The way on is deeper in.

**scenes/maps/MaintenanceHall.tscn**
- MAINTENANCE HALL
- Gus owns Maintenance Sync. Stabilize both signals before the Staff Door opens.

**scenes/maps/MemoryCore.tscn**
- Where the arcade saved what it could not bear to lose.

**scenes/maps/PartyRoom.tscn**
- A faded birthday corner. The community remembered someone the arcade is forgetting.

**scenes/maps/PrizeCorner.tscn**
- Pip watches the prize labels and remembers more than a plush should.

**scenes/maps/Restrooms.tscn**
- A quiet nook. The mirror does not always agree on how many of you there are.

**scenes/maps/SnackAlcove.tscn**
- Vendo owns Circuit Soda. Route the signal before staff systems listen.

**scenes/maps/StaffCorridor.tscn**
- Follow the Overloaded signal. Restore the Security Tape, then walk the Final Night route before Memory Echo.

**scenes/maps/Workshop.tscn**
- The back room where the games were made by hand.

**scenes/maps/hallways/BackHallway.tscn**
- Every light hums toward the Staff Door.

**scenes/maps/hallways/CabinetHallway.tscn**
- CABINET HALLWAY
- Cabinet glow leaks under the doors.

**scenes/maps/hallways/CabinetSnackHallway.tscn**
- SERVICE HALLWAY
- Cabinet static fades into vending-machine buzz.

**scenes/maps/hallways/MaintenanceHallway.tscn**
- MAINTENANCE HALLWAY
- Breaker labels buzz behind scratched glass.

**scenes/maps/hallways/MaintenanceStaffHallway.tscn**
- STAFF ACCESS HALL
- The floor vibrates like a door deciding.

**scenes/maps/hallways/PrizeHallway.tscn**
- Loose tickets scrape along the baseboards.

**scenes/maps/hallways/SnackHallway.tscn**
- The air smells like dust, sugar, and warm wiring.

**scenes/maps/hallways/SnackPrizeHallway.tscn**
- PRIZE SERVICE HALL
- Prize tags flutter near a soda-stained wall.

**scenes/minigames/BrokenHighScore.tscn**
- BROKEN HIGH SCORE
- BROKEN HIGH SCORE
The target says 9999.
Some digits are broken.
Reach the real score.
- The cabinet insists the target is 9999. It is not convincing.
- Return to Cabinet

**scenes/minigames/CircuitSoda.tscn**
- Rotate the pipes.
Connect Memory Input to Restore Output.
Do not spill identity.
- Line Pressure: Nominal
- Route Memory Input to Restore Output.
- Return to Snack

**scenes/minigames/MinigameScreenTemplate.tscn**
- Status text goes here.

**scenes/minigames/RockbyteDuel.tscn**
- Two piles remain.
Take 1 from Left, Right, or Both.
Whoever takes the final rock wins.
- LEFT PILE: 6        RIGHT PILE: 6
- Choose your move.

**scenes/minigames/SecurityTapeAssembly.tscn**
- SECURITY TAPE ASSEMBLY
- Arrange the fragments in the order they happened.
The tape is damaged, but not silent.
- Hint: The counter went dark before Cabinet 07 stayed awake.

**scenes/minigames/TruthFilter.tscn**
- Source: Staff Shift Log
- Signal Integrity: Stable
- Read the rule. Choose the cabinet that matches it.
Memories can lie. Rules cannot.
- Read the rule. Choose the matching cabinet.
- Return to Cabinet Row

**scenes/ui/DialogueBox.tscn**
- PRESS E / SPACE

**scenes/ui/MemoryTerminal.tscn**
- MEMORY TERMINAL

**scenes/ui/PauseMenu.tscn**
- Return to Main Menu

**scenes/ui/QuestNotice.tscn**
- Tip: Esc -> Quest shows these details again.

**scenes/ui/SaveSlotMenu.tscn**
- Save File - choose a slot
- Mode: Save File

