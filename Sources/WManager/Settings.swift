import Cocoa

enum Settings {
    // Use Command + Option by default to avoid collisions with common app shortcuts.
    static let hotkeyModifiers: CGEventFlags = [.maskCommand, .maskAlternate]
    static let allowAdditionalModifiers = false

    static let desktopMoveModifiers: CGEventFlags = [.maskControl, .maskShift]
    static let desktopCount = 5

    static let overlayAutoHideSeconds: TimeInterval? = nil
    static let overlaySelectionMaxCount: Int? = 2

    static let outerPadding: CGFloat = 8
    static let innerGap: CGFloat = 8

    static let overlayLineWidth: CGFloat = 2
    static let overlayLineColor = NSColor(calibratedWhite: 1.0, alpha: 0.6)
    static let overlayBackgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.18)
    static let overlayHighlightColor = NSColor(calibratedWhite: 1.0, alpha: 0.12)
    static let overlayLabelColor = NSColor(calibratedWhite: 1.0, alpha: 0.85)
    static let overlayLabelFontSize: CGFloat = 36
}
