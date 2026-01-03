# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` defines the Swift Package Manager executable.
- `Sources/WManager/` holds the app sources (hotkeys, overlay, window control).
- `Tests/WManagerTests/` should contain XCTest specs (create if missing).
- `README.md` documents usage and default shortcuts.

## Build, Test, and Development Commands
- `swift build` compiles the executable.
- `swift run` launches the background app; the first run requests Accessibility access.
- `swift test` runs XCTest (add tests under `Tests/WManagerTests/`).

## Coding Style & Naming Conventions
- Use 4-space indentation and follow Swift API Design Guidelines.
- Types use `UpperCamelCase`; methods and variables use `lowerCamelCase`.
- File names should match their primary type (for example, `HotkeyManager.swift`).
- Keep hotkey and layout logic pure where possible for easy testing.

## Testing Guidelines
- Framework: XCTest via SwiftPM.
- Naming: files end with `Tests.swift`, test methods begin with `test`.
- Focus on deterministic unit tests (layout math, slot unions); avoid tests that require Accessibility permissions.
- Expect tests for new behavior; no formal coverage target yet.

## Commit & Pull Request Guidelines
- Follow `docs/rules/commits_rules.md` for all commit rules (format, body structure, atomic staging).
- Quick rules: use Conventional Commits with optional scopes, include a short bullet list plus a brief rationale paragraph, and commit only the files you touched with explicit paths.
- Never amend commits, avoid destructive git commands, and quote paths with brackets/parentheses when staging.
- PRs should include a short description, testing notes, and screenshots for overlay/UI changes.

## Permissions & Configuration
- The app requires Accessibility permission to move/resize windows.
- Runtime tweaks live in `Sources/WManager/Settings.swift` (modifiers, gaps, overlay colors).
