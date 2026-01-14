import XCTest
@testable import WManager

final class OverlaySelectionStateTests: XCTestCase {
    func testSelectAccumulatesSlots() {
        var state = OverlaySelectionState()
        let topLeft = GridCell.cell(row: 0, column: 0)!
        let bottomRight = GridCell.cell(row: 1, column: 2)!
        let first = state.select(topLeft)
        XCTAssertEqual(first, [topLeft])

        let second = state.select(bottomRight)
        XCTAssertEqual(second, [topLeft, bottomRight])
        XCTAssertEqual(state.selection, [topLeft, bottomRight])
    }

    func testClearRemovesSelection() {
        var state = OverlaySelectionState()
        let topCenter = GridCell.cell(row: 0, column: 1)!
        _ = state.select(topCenter)
        state.clear()
        XCTAssertTrue(state.selection.isEmpty)
    }

    func testSelectWithMaxCountSignalsLimit() {
        var state = OverlaySelectionState()
        let topLeft = GridCell.cell(row: 0, column: 0)!
        let bottomRight = GridCell.cell(row: 1, column: 2)!
        let first = state.select(topLeft, maxSelectionCount: 2)
        XCTAssertEqual(first.selection, [topLeft])
        XCTAssertFalse(first.reachedLimit)

        let second = state.select(bottomRight, maxSelectionCount: 2)
        XCTAssertEqual(second.selection, [topLeft, bottomRight])
        XCTAssertTrue(second.reachedLimit)
    }
}
