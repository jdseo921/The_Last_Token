# FLAG_REGISTRY.md

## Rules
- Keep every GameState flag in one place.
- Use one clear name per concept.
- Do not create duplicate flags for the same idea.
- Prefer small, obvious boolean flags unless a value is needed.

## Story Flags
- `story_started`
- `lost_token_quest_started`
- `lost_token_collected`
- `lost_token_quest_completed`
- `rockbyte_duel_completed`
- `story_puzzle_completed`
- `staff_room_unlocked`
- `twist_reveal_seen`
- `ending_seen`
- `post_reveal_roam_unlocked`

## NPC Dialogue Flags
- `mira_intro_seen`
- `mira_post_reveal_seen`
- `gus_intro_seen`
- `gus_post_reveal_seen`
- `vendo_intro_seen`
- `vendo_post_reveal_seen`
- `cabinet07_employee_hint_seen`
- `mr_byte_intro_seen`
- `mr_byte_post_reveal_seen`

## Secret Flags
- `broken_cabinet_secret_found`
- `owner_portrait_secret_found`
- `employee_04_file_found`

## Save Slot Fields
- `slot_id`
- `save_exists`
- `current_scene`
- `spawn_marker`
- `story_phase`
- `games_completed_count`
- `total_games_count`
- `secrets_found_count`
- `total_secrets_count`
- `post_reveal_roam_unlocked`
- `ending_seen`
- `twist_reveal_seen`
- `play_time_seconds`
- `last_saved_at`

## Post-Reveal Roam Flags
- `mira_post_reveal_seen`
- `gus_post_reveal_seen`
- `vendo_post_reveal_seen`
- `mr_byte_post_reveal_seen`
