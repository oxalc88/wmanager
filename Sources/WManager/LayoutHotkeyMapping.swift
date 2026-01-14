import CoreGraphics

enum LayoutHotkeyMapping {
    private static let numberKeyCodes: [CGKeyCode] = [
        KeyCode.one,
        KeyCode.two,
        KeyCode.three,
        KeyCode.four
    ]

    static func layoutIndex(for keyCode: CGKeyCode, layoutCount: Int) -> Int? {
        let allowedCount = clampLayoutCount(layoutCount)
        guard let index = numberKeyCodes.prefix(allowedCount).firstIndex(of: keyCode) else {
            return nil
        }
        return index
    }

    static func clampLayoutCount(_ count: Int) -> Int {
        return min(max(count, 1), numberKeyCodes.count)
    }
}
