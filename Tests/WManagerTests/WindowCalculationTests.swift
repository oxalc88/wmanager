import XCTest
@testable import WManager

final class WindowCalculationTests: XCTestCase {
    func testWindowFramesReflectGridWeights_ActiveCellsHaveFrames() {
        let frame = CGRect(x: 0, y: 0, width: 1200, height: 800)
        let weights = GridWeight(columns: [2, 1, 0], rows: [1, 1])
        let layout = weights.asLayoutPreset()

        let frames = LayoutEngine.frames(in: frame, layout: layout)
        let activeCells = LayoutEngine.activeCells(for: layout)
        XCTAssertFalse(activeCells.isEmpty)
        XCTAssertTrue(activeCells.allSatisfy { frames[$0] != nil })
    }

    func testLayoutRoundTrip_SaveReloadKeepsPreset() {
        let defaults = UserDefaults(suiteName: "WindowCalculationTests.\(UUID().uuidString)")
        var state = LayoutStore.defaultState()
        let config = LayoutConfig(weights: GridWeight(columns: [1, 0, 1, 0], rows: [1, 0, 0]), scope: .allDesktops)
        LayoutStore.updateLayoutConfig(config, index: 0, scope: .allDesktops, spaceID: nil, in: &state)
        LayoutStore.save(state, userDefaults: defaults!)

        let reloaded = LayoutStore.load(userDefaults: defaults!)
        let loaded = LayoutStore.layoutConfig(reloaded, index: 0, scope: .allDesktops, spaceID: nil)
        XCTAssertEqual(loaded.weights, config.weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows))
    }
}
