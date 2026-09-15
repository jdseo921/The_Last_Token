# NPC Dialogue Guide

## Purpose
Keep early dialogue focused on the first quest while making Pixel Haven feel inhabited.

## Core Contrast
- Player: confused, first-person, direct. The player should ask clear questions and notice missing memory without explaining too much.
- Mira: gentle, familiar, slightly sad. She knows more than she says, but she should guide rather than lecture.
- Gus: casual, dry, practical. Uses humor to push the player toward the objective.
- Vendo: sarcastic, commercial, casually rude. Machine dialogue still renders in uppercase/word-by-word.
- Mr. Byte: cold helper-system tone. Gives blunt hints and incomplete records.
- Cabinet 07: unsettling machine recognition. Speaks like a diagnostic system and should not become chatty.

## Repeated Talk Rule
For each story phase, non-critical NPCs can show varied flavor dialogue for the first two talks. From the third talk onward, they should nudge the player back to the active objective.

This is implemented through `GameState.npc_dialogue_counts`, keyed by NPC and story phase.

## First Quest Notes
- Before Mira, side NPCs can mention Pixel Haven, Mira, Cabinet 07, or the missing staff without revealing the twist.
- After Mira starts the Lost Token quest, repeated dialogue should point toward Cabinet 07.
- After Rockbyte Duel is won, repeated dialogue should point back to Mira.
- After the Lost Token is returned, repeated dialogue should point toward the Staff Door.

## QA Pass Check
When checking dialogue polish, verify:
- Player confusion is clear in the opening and first quest.
- Mira has different follow-up lines after giving the quest.
- Gus, Vendo, and Mr. Byte have at least two early flavor variants per relevant phase.
- Third-and-later talks become objective nudges.
- Machine dialogue remains readable and distinct from human dialogue.
