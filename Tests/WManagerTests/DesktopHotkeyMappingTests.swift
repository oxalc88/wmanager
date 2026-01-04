import XCTest
@testable import WManager

final class DesktopHotkeyMappingTests: XCTestCase {
    func testMapsNumberKeysToDesktopIndices() {
        let expected: [CGKeyCode: Int] = [
            KeyCode.one: 1,
            KeyCode.two: 2,
            KeyCode.three: 3,
            KeyCode.four: 4,
            KeyCode.five: 5,
            KeyCode.six: 6,
            KeyCode.seven: 7,
            KeyCode.eight: 8,
            KeyCode.nine: 9
        ]

        expected.forEach { keyCode, desktop in
            XCTAssertEqual(
                DesktopHotkeyMapping.desktopIndex(for: keyCode, desktopCount: 9),
                desktop
            )
        }
    }

    func testRespectsDesktopCountLimit() {
        XCTAssertEqual(DesktopHotkeyMapping.desktopIndex(for: KeyCode.one, desktopCount: 3), 1)
        XCTAssertNil(DesktopHotkeyMapping.desktopIndex(for: KeyCode.four, desktopCount: 3))
    }

    func testClampsDesktopCountBetweenOneAndNine() {
        XCTAssertEqual(DesktopHotkeyMapping.clampedDesktopCount(0), 1)
        XCTAssertEqual(DesktopHotkeyMapping.clampedDesktopCount(12), 9)
    }

    func testIgnoresNonNumberKeys() {
        XCTAssertNil(DesktopHotkeyMapping.desktopIndex(for: KeyCode.t, desktopCount: 5))
    }
}
