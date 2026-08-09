import XCTest
@testable import WManager

final class DesktopHotkeyMappingTests: XCTestCase {

    // MARK: - Option+Number → switchToDesktop

    func testOptionOneMatchesSwitchToDesktop0() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.one, flags: .maskAlternate)
        XCTAssertEqual(action, .switchToDesktop(0))
    }

    func testOptionNineMatchesSwitchToDesktop8() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.nine, flags: .maskAlternate)
        XCTAssertEqual(action, .switchToDesktop(8))
    }

    func testOptionFiveMatchesSwitchToDesktop4() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.five, flags: .maskAlternate)
        XCTAssertEqual(action, .switchToDesktop(4))
    }

    // MARK: - Option+Shift+Number → moveToDesktop

    func testOptionShiftOneMatchesMoveToDesktop0() {
        let action = DesktopHotkeyMapping.match(
            keyCode: KeyCode.one,
            flags: [.maskAlternate, .maskShift]
        )
        XCTAssertEqual(action, .moveToDesktop(0))
    }

    func testOptionShiftSevenMatchesMoveToDesktop6() {
        let action = DesktopHotkeyMapping.match(
            keyCode: KeyCode.seven,
            flags: [.maskAlternate, .maskShift]
        )
        XCTAssertEqual(action, .moveToDesktop(6))
    }

    // MARK: - Non-matching combos

    func testControlNumberDoesNotMatch() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.one, flags: .maskControl)
        XCTAssertNil(action)
    }

    func testCommandNumberDoesNotMatch() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.one, flags: .maskCommand)
        XCTAssertNil(action)
    }

    func testOptionCommandNumberDoesNotMatch() {
        let action = DesktopHotkeyMapping.match(
            keyCode: KeyCode.one,
            flags: [.maskAlternate, .maskCommand]
        )
        XCTAssertNil(action)
    }

    func testNonNumberKeyDoesNotMatch() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.a, flags: .maskAlternate)
        XCTAssertNil(action)
    }

    func testArrowKeyDoesNotMatch() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.leftArrow, flags: .maskAlternate)
        XCTAssertNil(action)
    }

    func testNoModifiersDoesNotMatch() {
        let action = DesktopHotkeyMapping.match(keyCode: KeyCode.one, flags: [])
        XCTAssertNil(action)
    }

    // MARK: - All number keys map to correct indices

    func testAllNumberKeysMapCorrectly() {
        let expected: [(CGKeyCode, Int)] = [
            (KeyCode.one, 0), (KeyCode.two, 1), (KeyCode.three, 2),
            (KeyCode.four, 3), (KeyCode.five, 4), (KeyCode.six, 5),
            (KeyCode.seven, 6), (KeyCode.eight, 7), (KeyCode.nine, 8),
        ]
        for (keyCode, index) in expected {
            let action = DesktopHotkeyMapping.match(keyCode: keyCode, flags: .maskAlternate)
            XCTAssertEqual(action, .switchToDesktop(index), "Key \(keyCode) should map to index \(index)")
        }
    }
}
