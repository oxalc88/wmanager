# Plan: Desktop Move Hotkeys + Status Bar Toggle

## Goals
- Add hotkeys to move the focused window to desktop 1-5 using a modifier combo similar to "Super + Shift + Number".
- Add a menu bar (status bar) icon with a toggle to start/stop WManager without quitting.
- Keep the new behavior configurable and documented.

## Non-goals
- Implement full workspace management (create, delete, reorder spaces).
- Add any UI beyond a simple status bar menu.
- Add tests that depend on Accessibility or Mission Control.

## Open questions
- Confirm the exact modifier combo for "Super": likely Command on macOS, but could be Control or Option.
- When moving a window to another desktop, should WManager also switch to that desktop or stay on the current one?
- Should the move hotkeys override macOS screenshot shortcuts (Command + Shift + 3/4/5)?

## Technical approach
### 1) Desktop move hotkeys
- Add Settings entries:
  - `desktopMoveModifiers` (default: `.maskControl` + `.maskShift`).
  - `desktopCount` (default: 5, clamp 1...9).
- Supported modifier combos come from `CGEventFlags` (`.maskCommand`, `.maskShift`, `.maskAlternate`, `.maskControl`), and we should document common-safe defaults to avoid collisions.
- Extend `HotkeyManager` to detect number keys (1-5) with `desktopMoveModifiers`.
  - Map keycodes to desktop indexes (1-9) with a small pure helper to keep logic testable.
  - Keep existing hotkeys unchanged; only consume events that match the new move combo.
- Add a `SpaceManager` (or similar) to encapsulate moving a window to a desktop.
  - Preferred: use private CGS/Spaces APIs (e.g., `CGSMoveWindowToManagedSpace`) via `@_silgen_name`.
  - Fallback if APIs are unavailable: log a warning and let the event pass through (no-op).
  - Keep the API surface narrow: `moveFocusedWindow(to index: Int) -> Bool`.
- Update `WindowManager` to expose the focused window element or identifier required by the space API.

### 2) Status bar icon with start/stop
- Add a `StatusBarController` to create an `NSStatusItem` and menu.
  - Menu items: "Start WManager" / "Stop WManager" (toggle), "Quit".
  - Toggle should call `hotkeyManager.start()` / `hotkeyManager.stop()` and clear overlay state.
  - Update menu item title and icon state based on running state.
- Provide a default icon:
  - Option A: use an SF Symbol (`NSImage(systemSymbolName:)`) as a template image.
  - Option B: ship a PNG in `Sources/WManager/Resources/` and load via `Bundle.module`.
- Keep the activation policy as `.accessory` so the app stays menu-bar only.

### 3) Documentation and tests
- Update `README.md` with new hotkeys and the menu bar toggle behavior.
- Add unit tests for keycode-to-desktop mapping and modifier matching where possible.
- Document private API usage and risks (macOS updates may break it).

## Implementation steps
1) Add Settings and a pure key mapping helper; write unit tests for mapping.
2) Prototype `SpaceManager` with private API calls and verify against a focused window.
3) Wire new hotkeys in `HotkeyManager` and guard against conflicts.
4) Add `StatusBarController` and menu actions; integrate into `AppDelegate`.
5) Update README and any notes about permissions or conflicts.

## Follow-ups
- Add a menu option to adjust hotkey modifiers at runtime (instead of editing `Settings.swift`).

## Risks / Notes
- Moving windows between Spaces is not supported by public APIs; private APIs can break across macOS releases.
- Command + Shift + Number conflicts with screenshots; confirm preferred modifiers before implementing.
- Status bar icon resources need to be bundled explicitly in SwiftPM if not using SF Symbols.
