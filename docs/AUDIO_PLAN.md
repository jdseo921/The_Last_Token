# AUDIO_PLAN.md

## Purpose
This file tracks background music and lightweight SFX integration for The Last Token. Music should support the emotional state of each map or minigame without changing progression, save/load, or SFX behavior.

Runtime music is handled by `scripts/AudioManager.gd`.

## Playback Rules
- Music files live in `res://assets/audio/music/`.
- SFX files live in `res://assets/audio/sfx/`.
- `AudioManager.play_music(track_id)` resolves `.wav`, `.ogg`, or `.mp3`.
- `AudioManager` SFX helpers resolve `.wav`, `.ogg`, or `.mp3` by base name.
- Missing tracks print a lightweight warning and do not crash gameplay.
- Music changes use a two-player crossfade.
- Tracks loop through the `finished` signal so MP3 loop metadata is not required.
- `GameSettings.music_volume` controls music playback volume.
- `GameSettings.sfx_volume` controls one-shot SFX volume.
- Existing SFX methods and old ambience aliases remain compatible.

## Track List
| Track ID | Filename | Plays In | Expected Mood | Loop | Runtime Polish |
|---|---|---|---|---|---|
| `title_attract_loop` | `title_attract_loop.mp3` | Title Menu | beckoning, arcade-attract glow | Required | Required |
| `arcade_hub_grounded` | `arcade_hub_grounded.mp3` | ArcadeHub, Grounded state | familiar, quiet, exploratory | Required | Required |
| `arcade_hub_uneasy_fractured` | `arcade_hub_uneasy_fractured.mp3` | ArcadeHub after memory destabilizes | uneasy, fractured, investigative | Required | Required |
| `cabinet_row_records` | `cabinet_row_records.mp3` | Cabinet Row | diagnostic, archival, strange | Required | Required |
| `snack_alcove_vendo` | `snack_alcove_vendo.mp3` | Snack Alcove | branded, synthetic, comic-odd | Required | Required |
| `maintenance_hall_static` | `maintenance_hall_static.mp3` | Maintenance Hall | practical, tense, electrical | Required | Required |
| `staff_corridor_overloaded` | `staff_corridor_overloaded.mp3` | Staff Corridor | overloaded, narrowing, dangerous | Required | Required |
| `staff_room_reveal_bed` | `staff_room_reveal_bed.mp3` | Staff Room, Ending Prompt | reveal bed, solemn, unresolved | Required | Required |
| `post_reveal_roam` | `post_reveal_roam.mp3` | Post-Reveal Roam | quiet closure, remembered pieces | Required | Required |
| `rockbyte_duel_game` | `rockbyte_duel_game.mp3` | Rockbyte Duel | small cabinet contest, playful tension | Required | Required |
| `truth_filter_game` | `truth_filter_game.mp3` | Truth Filter | logic test, signal doubt | Required | Required |
| `circuit_soda_game` | `circuit_soda_game.mp3` | Circuit Soda | fizzy machine puzzle, odd confidence | Required | Required |
| `static_service_run_game` | `static_service_run_game.mp3` | Static Service Run | service crawl, electrical pressure | Required | Required |
| `maintenance_sync_game` | `maintenance_sync_game.mp3` | Maintenance Sync | timing puzzle, two signals | Required | Required |
| `security_tape_final_night_game` | `security_tape_final_night_game.mp3` | Security Tape Assembly, Final Night Walk | tape reconstruction, final route | Required | Required |
| `memory_echo_conscience` | `memory_echo_conscience.mp3` | Memory Echo | intimate, unstable, conscience-facing | Required | Required |

## SFX List
| SFX ID | Filename | Plays In | Runtime Polish |
|---|---|---|---|
| `ui_confirm` | `ui_confirm.wav` | Buttons and accepted menu actions | Required |
| `ui_cancel` | `ui_cancel.wav` | Back/cancel actions | Required |
| `interact` | `interact.wav` | Player interactions | Required |
| `dialogue_advance` | `dialogue_advance.wav` | Dialogue and conscience line advances | Required |
| `token_get` | `token_get.wav` | Token/collectible rewards | Required |
| `glitch` | `glitch.wav` | Glitch flashes and conscience line effects | Required |
| `save` | `save.wav` | Save completion | Required |
| `error` | `error.wav` | Wrong choices and blocked actions | Required |
| `quest_update` | `quest_update.wav` | Quest notices and major completion beats | Required |
| `memory_panel` | `memory_panel.wav` | Staff Room reveal panel changes | Integrated generated one-shot |
| `memory_accept` | `memory_accept.wav` | Accepted Memory Echo answers | Integrated generated one-shot |
| `door_unlock` | `door_unlock.wav` | Maintenance Sync Staff Door open moment | Integrated generated one-shot |
| `button_pulse` | `button_pulse.wav` | Minigame button presses, switches, route-step confirms | Integrated generated one-shot |
| `score_blip` | `score_blip.wav` | Correct puzzle beats, accepted fragments, collectibles | Integrated generated one-shot |
| `error_buzz` | `error_buzz.wav` | Wrong arcade actions, blockers, failed routes | Integrated generated one-shot |
| `success_jingle` | `success_jingle.wav` | Completed arcade stages and major puzzle success | Integrated generated one-shot |

## Context Map
| Context | Track ID |
|---|---|
| `title` | `title_attract_loop` |
| `arcade_hub` Grounded | `arcade_hub_grounded` |
| `arcade_hub` Uneasy or later | `arcade_hub_uneasy_fractured` |
| `arcade_hub` post-reveal | `post_reveal_roam` |
| `cabinet_row` | `cabinet_row_records` |
| `snack_alcove` | `snack_alcove_vendo` |
| `maintenance_hall` | `maintenance_hall_static` |
| `staff_corridor` | `staff_corridor_overloaded` |
| `staff_room` | `staff_room_reveal_bed` |
| `rockbyte_duel` | `rockbyte_duel_game` |
| `truth_filter` | `truth_filter_game` |
| `circuit_soda` | `circuit_soda_game` |
| `static_service_run` | `static_service_run_game` |
| `maintenance_sync` | `maintenance_sync_game` |
| `security_tape_assembly` | `security_tape_final_night_game` |
| `final_night_walk` | `security_tape_final_night_game` |
| `memory_echo` | `memory_echo_conscience` |
| `ending` | `staff_room_reveal_bed` |
| `post_reveal` | `post_reveal_roam` |

## Manual QA Focus
- Confirm each scene starts the expected track.
- Confirm transitions crossfade instead of cutting abruptly.
- Confirm the Music Volume slider affects active playback.
- Confirm the SFX Volume slider affects generated and pre-existing one-shots.
- Confirm minigames give instant audio feedback: pulse on input, blip on accepted progress, buzz on errors, and jingle on completion.
- Temporarily rename one music file and confirm gameplay continues with only a warning.

## Current Audio Gaps
- No required background music track is missing in the current `AudioManager.MUSIC_TRACKS` list.
- No currently registered SFX file is missing in `assets/audio/sfx/`.
- Larger bespoke audio, such as a fully produced ending sting or replacement background track, should remain a composition pass rather than a generated simple SFX task.
