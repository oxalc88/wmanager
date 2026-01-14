import XCTest
@testable import WManager

final class OverlayKeyActionTests: XCTestCase {
    func testDismissKeys() {
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.escape), .dismiss)
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.returnKey), .dismiss)
    }

    func testSlotKeys() {
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.q), .cell(GridCell.cell(row: 0, column: 0)!))
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.a), .cell(GridCell.cell(row: 1, column: 0)!))
    }

    func testPassthroughKeys() {
        XCTAssertEqual(OverlayKeyAction.action(for: KeyCode.leftArrow), .passthrough)
    }
}
