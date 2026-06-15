# AGENTS.md

## Project Scope
The Last Token is a 2D top-down retro arcade mystery game built in Godot 4.x with GDScript and edited in Visual Studio Code. The project must stay focused on a finishable MVP for a solo developer in 4 to 6 weeks.

## Working Rules
- Favor simple, readable GDScript over clever abstractions.
- Keep systems small and direct.
- Every new feature must preserve the playable loop.
- Do not overbuild for scale, reuse, or future-proofing unless the MVP needs it immediately.
- Prefer placeholder implementation that is playable over polished systems that delay progress.
- Keep failure handling fast and light.

## Godot Version
- Target Godot 4.x only.
- Assume standard Godot scene, node, and signal patterns.
- Use straightforward scripts attached to scenes or autoloads when helpful.

## Folder Structure
- `scenes/` for game scenes and UI scenes.
- `scripts/` for GDScript files.
- `assets/` for art, audio, and other media.
- `data/` for dialogue, flags, and content tables if needed.
- `autoload/` for global state and managers.

## Coding Style
- Use clear names.
- Keep functions short.
- Prefer explicit state changes over hidden behavior.
- Keep dialogue, flags, and scene transitions easy to inspect.
- Use minimal dependencies between systems.

## Do Not Overbuild
- Do not add RPG combat.
- Do not add procedural generation.
- Do not add a large inventory system.
- Do not add save-anywhere.
- Do not add complex boss AI.
- Do not add extra NPCs before the core NPCs work.
- Do not add more than one major slideshow cutscene before the full game loop works.
- Do not add stretch features before the MVP loop is playable end to end.

## Priority Order
1. Make the game playable.
2. Make the game completable.
3. Make the twist understandable.
4. Add polish only after the loop is stable.
