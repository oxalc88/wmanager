import XCTest
@testable import WManager

final class OverlayKeyActionTests: XCTestCase {
    func testDismissKeys() {
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.escape), .dismiss)
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.returnKey), .dismiss)
    }

    func testSlotKeys() {
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.q), .slot(.topLeft))
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.a), .slot(.bottomLeft))
    }

    func testPassthroughKeys() {
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.leftArrow), .passthrough)
    }
}
