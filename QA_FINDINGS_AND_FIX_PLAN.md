# QA Findings & Fix Plan - WManager
## 0. Test Environment
- macOS version: 15.6.1 (24G90)
- Hardware: Apple Silicon (arm64)
- Monitors/layout: not detected (CLI-only run), not verified
- Dock position: not verified
- Accessibility permission state: not verified; no prompt observed during short `swift run`

## 1. Build & Smoke Results
- Repo discovery: scanned `Sources/WManager` for hotkeys, overlay, layout, and window control; logging via `NSLog` in `Sources/WManager/AccessibilityHelper.swift` and `Sources/WManager/HotkeyManager.swift`.
- `swift --version`: pass
  - `Apple Swift version 6.2.3 (swiftlang-6.2.3.3.21 clang-1700.6.3.2)`
- `swift build -c debug`: pass
  - `Building for debugging...`
  - `Build complete! (0.27s)`
- `swift build -c release`: pass
  - `Building for production...`
  - `Build complete! (0.94s)`
- `swift test`: pass
  - Current evidence (2026-08-08): `Executed 68 tests, with 0 failures (0 unexpected)`, 5 expected UI skips.
- `swift run`: built and launched; terminated after ~3s to avoid a long-running background process.
  - Log: `logs/qa_swift_run.log` (no app output; only build messages)
  - Manual hotkeys, Accessibility prompts, and overlay behavior not exercised in this run.

## 2. Test Matrix (Pass/Fail)
| ID | Feature | Steps summary | Expected | Actual | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| B1 | Build debug | `swift build -c debug` | Build succeeds | Succeeds | Pass | Uses SwiftPM cache outside workspace |
| B2 | Build release | `swift build -c release` | Build succeeds | Succeeds | Pass |  |
| T1 | Unit tests | `swift test` | Tests pass | Pass | Pass | 68 tests, 0 failures |
| R1 | Run app | `swift run` (short run) | App launches, prompts for Accessibility | Build succeeded; UI not exercised | Partial | No prompt observed in short run |
| F1 | Tiling left/right/max | Hotkeys on Terminal/Finder/etc | Window tiles to visible frame | Not run | Not Run | Requires manual UI + Accessibility |
| F2 | Overlay show/dismiss | Cmd+Opt+T and Esc | Overlay shows, Esc dismisses | Not run | Not Run | Requires manual UI |
| F3 | Overlay selection | Q/W/E/A/S/D spanning | Correct rects | Not run | Not Run | Requires manual UI |
| F4 | Edge cases | Multi-monitor, Dock positions, tiny windows | Correct visible-frame behavior | Not run | Not Run | Requires manual UI |
| S1 | Safety non-goals | Fullscreen, non-resizable | Graceful no-op | Not run | Not Run | Requires manual UI |
| P1 | Performance | 10 min hotkeys | Stable, no spikes | Not run | Not Run | Requires manual UI |

## 3. Issues Found (Prioritized)
No issues found in this CLI-only run. Manual UI coverage (hotkeys/overlay/multi-monitor) was not executed.

## 4. Hardening Recommendations (Not bugs, but likely future failures)
- Add unit tests for geometry (slot to rect mapping, visibleFrame math, spanning union) to `Tests/WManagerTests`.
- Add structured logging with a debug toggle (minimal, off by default) to help diagnose Accessibility failures and event tap issues.
- Add a dry-run mode that prints computed frames without moving windows for safe validation.

## 5. Fix Roadmap (1-2 day plan)
1) Run manual overlay tests (key-only focus changes, rapid input).
2) Run tiling hotkeys on at least two apps and on a secondary monitor if available.

Notes:
- Manual UI tests (hotkeys, overlay, multi-monitor, Dock positions, fullscreen) could not be executed in this non-interactive run.
- LaunchAgent QA was intentionally skipped per user request.
