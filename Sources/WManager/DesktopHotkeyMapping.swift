import CoreGraphics

enum DesktopHotkeyMapping {
    private static let numberKeyCodes: [CGKeyCode] = [
        KeyCode.one,
        KeyCode.two,
        KeyCode.three,
        KeyCode.four,
        KeyCode.five,
        KeyCode.six,
        KeyCode.seven,
        KeyCode.eight,
        KeyCode.nine
    ]

    static func clampedDesktopCount(_ count: Int) -> Int {
        return min(max(count, 1), 9)
    }

    static func desktopIndex(for keyCode: CGKeyCode, desktopCount: Int) -> Int? {
        let allowedCount = clampedDesktopCount(desktopCount)
        guard let index = desktopIndex(for: keyCode), index <= allowedCount else {
            return nil
        }
        return index
    }

    private static func desktopIndex(for keyCode: CGKeyCode) -> Int? {
        guard let index = numberKeyCodes.firstIndex(of: keyCode) else {
            return nil
        }
        return index + 1
    }
}
