You are a senior QA engineer + pragmatic Swift/AppKit debugger.

Repo context (read this first):
- Project: WManager — minimal tiling helper for macOS (Swift + AppKit).
- Features:
  1) Two-way tiling: left half, right half, maximize (visible frame)
  2) Tactile overlay grid: 6 slots (Q/W/E/A/S/D) + optional spanning via multi-slot selection
  3) Global hotkeys, lightweight overlay preview
- Known constraints: some windows can’t resize; fullscreen apps not managed.
- Run: `swift run` (Accessibility permission required).
- Settings: `Sources/WManager/Settings.swift` includes overlaySelectionMaxCount, modifiers, gaps, colors.

Your task:
1) Build a QA plan AND execute as much as possible locally via terminal + manual steps.
2) Produce ONE fix-ready document: `QA_FINDINGS_AND_FIX_PLAN.md`.
3) Every issue must include: severity, reproducibility, exact steps, expected vs actual, evidence (logs/screenshot note), suspected root cause, and a concrete fix proposal referencing real files/functions found in the repo (do not invent file names—inspect the repo first).
4) If something requires manual action (e.g., granting Accessibility), note it and continue. Do not stop.
5) Be aggressive about edge cases: multi-monitor, Dock position, menu bar, notch, Stage Manager, Spaces, different window types (resizable/non-resizable), focus changes while overlay open, key repeat, hotkey conflicts.
6) Do not write generic advice. Make it actionable enough that I can implement fixes immediately.

Execution steps (do these in order, capture output snippets for the doc):
A) Repo discovery
- List structure: `ls -R` (brief)
- Identify key files: hotkeys, window manipulation, overlay UI, geometry/layout calculations.
- Note any logging mechanism / debug flags.

B) Build and basic sanity
- `swift --version`
- `swift build -c debug` and `swift build -c release`
- If tests exist: `swift test` (include output)
- Run: `swift run` (note Accessibility prompts + first-run behavior)
- Confirm process stays alive and hotkeys respond.

C) Functional QA (manual + observable evidence)
Test on at least these apps (or closest available): Terminal, Finder, Safari/Chrome, System Settings, Xcode (or any complex window), a non-resizable window if possible.
For each test, record pass/fail + notes.

1) Two-way tiling
- Cmd+Opt+Left => left half within visible frame (respects Dock + menu bar)
- Cmd+Opt+Right => right half
- Cmd+Opt+Up => maximize within visible frame (NOT full screen)
Edge cases:
- Window already near min size
- Very small window
- Already maximized then press left/right repeatedly
- Drag window between monitors then tile
- Different Dock positions: bottom vs left/right (note expected behavior)

2) Overlay behavior
- Cmd+Opt+T shows overlay grid
- Esc dismisses overlay reliably
- Overlay does NOT steal focus permanently
- While overlay visible: switch focus (Cmd+Tab or click), then press Q/W/E/A/S/D to place focused window
- Selection count behavior matches overlaySelectionMaxCount
- Spanning (multi-slot selection) produces correct rect
Edge cases:
- Press keys very fast / key repeat
- Press invalid keys (should ignore safely)
- Overlay invoked twice quickly
- Overlay while no standard window is focused
- Overlay on secondary monitor (if supported): does it show on correct screen?

3) Safety / non-goals handling
- Fullscreen apps: verify the tool does nothing (and doesn’t glitch)
- Non-resizable windows: confirm graceful failure (no crash, no infinite loop)
- Permission denied scenario: remove Accessibility permission and verify clear error/guide

D) Performance & stability checks
- Watch CPU/memory briefly (Activity Monitor optional). Note if overlay causes spikes.
- Keep running 10 minutes; trigger hotkeys frequently; look for crashes/hangs.
- If logging exists, check log volume (should not spam).

Output document requirements (STRICT):
Create `QA_FINDINGS_AND_FIX_PLAN.md` with this structure:

# QA Findings & Fix Plan — WManager
## 0. Test Environment
- macOS version (from `sw_vers`)
- Hardware (Apple Silicon vs Intel if detectable)
- Monitors/layout (single/dual, scaling if known)
- Dock position (if changed)
- Accessibility permission state

## 1. Build & Smoke Results
- Commands run + pass/fail + key output snippets

## 2. Test Matrix (Pass/Fail)
A table of test cases with:
- ID, Feature, Steps summary, Expected, Actual, Status, Notes

## 3. Issues Found (Prioritized)
For each issue:
- ID + Title
- Severity (Blocker/Critical/Major/Minor)
- Frequency (Always/Often/Sometimes/Rare)
- Repro steps (numbered)
- Expected vs Actual
- Evidence (terminal output snippet, log path, screenshot note)
- Suspected root cause (based on reading the code)
- Proposed fix (specific: file(s), function(s), logic changes, pitfalls)
- Regression tests to re-run

## 4. Hardening Recommendations (Not bugs, but likely future failures)
- Add unit tests for geometry (slot->rect mapping, visibleFrame math, spanning union)
- Add structured logging with debug toggle
- Add “dry run” mode that prints computed frames without moving windows
(Only recommend things that match the current design goals: minimal, no daemon.)

## 5. Fix Roadmap (1–2 day plan)
- Ordered list of fixes, with dependencies

Also:
- If you cannot reproduce something, say so explicitly.
- Never claim a fix without pointing to real code locations.
- If you must guess, label it as a hypothesis and propose how to validate quickly.

Now start: inspect repo, run commands, execute tests, and write the document.
