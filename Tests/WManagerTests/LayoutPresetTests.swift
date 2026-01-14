import XCTest
@testable import WManager

final class LayoutPresetTests: XCTestCase {
    func testDefaultPresetMatchesExpectedWeights() {
        let preset = LayoutPreset.defaultPreset()
        XCTAssertEqual(preset.columnWeights, [1, 1, 1, 0])
        XCTAssertEqual(preset.rowWeights, [1, 1, 0])
    }

    func testNormalizeClampsAndPads() {
        let normalized = LayoutPreset.normalize([9, -1], maxCount: 4)
        XCTAssertEqual(normalized, [5, 0, 0, 0])
    }

    func testInitNormalizesToMaxCounts() {
        let preset = LayoutPreset(columnWeights: [1, 1, 1, 1, 1], rowWeights: [2])
        XCTAssertEqual(preset.columnWeights.count, GridCell.maxColumns)
        XCTAssertEqual(preset.rowWeights.count, GridCell.maxRows)
        XCTAssertEqual(preset.rowWeights, [2, 0, 0])
    }
}
