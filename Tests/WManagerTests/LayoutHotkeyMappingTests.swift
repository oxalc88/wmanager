import XCTest
@testable import WManager

final class LayoutHotkeyMappingTests: XCTestCase {
    func testMapsNumberKeysToLayoutIndices() {
        let expected: [CGKeyCode: Int] = [
            KeyCode.one: 0,
            KeyCode.two: 1,
            KeyCode.three: 2,
            KeyCode.four: 3
        ]

        expected.forEach { keyCode, index in
            XCTAssertEqual(
                LayoutHotkeyMapping.layoutIndex(for: keyCode, layoutCount: 4),
                index
            )
        }
    }

    func testRespectsLayoutCountLimit() {
        XCTAssertEqual(LayoutHotkeyMapping.layoutIndex(for: KeyCode.one, layoutCount: 2), 0)
        XCTAssertNil(LayoutHotkeyMapping.layoutIndex(for: KeyCode.three, layoutCount: 2))
    }

    func testClampsLayoutCountBetweenOneAndFour() {
        XCTAssertEqual(LayoutHotkeyMapping.clampLayoutCount(0), 1)
        XCTAssertEqual(LayoutHotkeyMapping.clampLayoutCount(9), 4)
    }

    func testIgnoresNonNumberKeys() {
        XCTAssertNil(LayoutHotkeyMapping.layoutIndex(for: KeyCode.t, layoutCount: 4))
    }
}
