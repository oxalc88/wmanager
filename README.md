# WManager

Minimal tiling helper for macOS (Swift + AppKit). This is a focused, low-overhead
utility: global hotkeys, simple layouts, no window tracking daemon.

## What it does
- Two-way tiling (left, right, maximize) similar to GNOME.
- A 6-slot "Tactile" grid (Q/W/E/A/S/D) with optional spanning by pressing
  multiple slots in sequence.
- A lightweight overlay to preview the grid.

## Build and run
```bash
swift run
```

The first run will prompt for Accessibility permission. Grant it in
System Settings -> Privacy & Security -> Accessibility.

## Hotkeys (default)
- Command + Option + Left: left half
- Command + Option + Right: right half
- Command + Option + Up: maximize (within the visible frame)
- Command + Option + T: toggle the 6-slot grid (Esc to dismiss)
- Q/W/E/A/S/D: choose slots while the grid is visible
- Escape: dismiss the grid

While the grid is visible, switch focus (Command + Tab or click another window)
and press Q/W/E/A/S/D to place that window.
The grid auto-closes after selecting two slots by default; adjust
`overlaySelectionMaxCount` in `Sources/WManager/Settings.swift` if you prefer a
different limit or `nil` for no limit.

You can change modifiers, gaps, and colors in `Sources/WManager/Settings.swift`.

## Notes
- Some windows do not allow resizing or have minimum sizes.
- Full-screen apps are not managed.
- If you switch to Command-only modifiers, expect conflicts with common app
  shortcuts (e.g., Command + Left/Right in browsers).
