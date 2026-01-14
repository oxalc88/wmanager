import XCTest
@testable import WManager

final class GridWeightTests: XCTestCase {
    func testDefaultWeights_InitializesExpectedValues() {
        let weights = GridWeight.default()
        XCTAssertEqual(weights.columns, [1, 1, 1])
        XCTAssertEqual(weights.rows, [1, 1])
    }

    func testColumnWeightModification_IncreaseDecrease() {
        var weights = GridWeight(columns: [1, 1, 1], rows: [1, 1])
        weights.incrementColumn(at: 0)
        XCTAssertEqual(weights.columns[0], 2)

        weights.decrementColumn(at: 0)
        XCTAssertEqual(weights.columns[0], 1)
    }

    func testRowWeightModification_IncreaseDecrease() {
        var weights = GridWeight(columns: [1, 1, 1], rows: [1, 1])
        weights.incrementRow(at: 1)
        XCTAssertEqual(weights.rows[1], 2)

        weights.decrementRow(at: 1)
        XCTAssertEqual(weights.rows[1], 1)
    }

    func testWeightBoundsValidation_MinMax() {
        var weights = GridWeight(columns: [0, 1, 1], rows: [1, 1])
        weights.decrementColumn(at: 0)
        XCTAssertEqual(weights.columns[0], 0)

        var maxed = GridWeight(columns: [5, 1, 1], rows: [1, 1])
        maxed.incrementColumn(at: 0)
        XCTAssertEqual(maxed.columns[0], 5)
    }

    func testGridDimensionCalculation_ExcludesZeroWeightColumnsAndRows() {
        let weights = GridWeight(columns: [1, 0, 1], rows: [1, 0])
        XCTAssertEqual(weights.activeColumnCount, 2)
        XCTAssertEqual(weights.activeRowCount, 1)
    }

    func testGridProportions_FromWeights() {
        let weights = GridWeight(columns: [1, 2, 1], rows: [3, 1])
        XCTAssertEqual(weights.columnProportions, [0.25, 0.5, 0.25])
        XCTAssertEqual(weights.rowProportions, [0.75, 0.25])
    }
}
