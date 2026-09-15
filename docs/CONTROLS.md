# CONTROLS.md

Input actions are registered at runtime from `ACTION_BINDINGS` in `scripts/GameState.gd`, not from the project input map. `project.godot` has no `[input]` section; add new bindings to that constant.

## Movement
- Move: `WASD` / Arrow Keys
- Crouch: `S` / `Down` (adventure stages)

## Interaction
- Interact / Continue: `E` / Space
- Jump: `E` / Space (adventure stages; same physical keys as Interact)

## Cancel / Back
- Cancel / Back / Pause: Esc / Backspace

## Menus
- Menus: mouse click / keyboard focus where supported.

## Display
Window size is an in-game setting under `Settings -> Display -> Window Size`, offering `640 x 440`, `960 x 660`, and `1280 x 880`. It is handled by `scripts/DisplayOptions.gd` and persists to `user://display.cfg`. It is no longer a title-menu button.

## Debug keys
Available only in debug/editor runs:
- `F8` prints the recent structured event buffer and the session log path.
- `F9` prints a full route snapshot.
- `F10` opens the route checkpoint menu, if it has been explicitly enabled. See the dev route notes in the root `README.md`.
