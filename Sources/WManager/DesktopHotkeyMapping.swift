import CoreGraphics

enum DesktopHotkeyMapping {
    enum Action: Equatable {
        case switchToDesktop(Int)
        case moveToDesktop(Int)
    }

    private static let numberKeyCodes: [CGKeyCode: Int] = [
        KeyCode.one: 0,
        KeyCode.two: 1,
        KeyCode.three: 2,
        KeyCode.four: 3,
        KeyCode.five: 4,
        KeyCode.six: 5,
        KeyCode.seven: 6,
        KeyCode.eight: 7,
        KeyCode.nine: 8,
    ]

    private static let relevantModifiers: CGEventFlags = [
        .maskCommand, .maskShift, .maskAlternate, .maskControl
    ]

    static func match(keyCode: CGKeyCode, flags: CGEventFlags) -> Action? {
        guard let desktopIndex = numberKeyCodes[keyCode] else { return nil }

        let pressed = flags.intersection(relevantModifiers)

        if pressed == .maskAlternate {
            return .switchToDesktop(desktopIndex)
        }

        if pressed == [.maskAlternate, .maskShift] {
            return .moveToDesktop(desktopIndex)
        }

        return nil
    }
}
