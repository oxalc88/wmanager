import CoreGraphics

enum DesktopHotkeyMapping {
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
        switch keyCode {
        case KeyCode.one: return 1
        case KeyCode.two: return 2
        case KeyCode.three: return 3
        case KeyCode.four: return 4
        case KeyCode.five: return 5
        case KeyCode.six: return 6
        case KeyCode.seven: return 7
        case KeyCode.eight: return 8
        case KeyCode.nine: return 9
        default: return nil
        }
    }
}
