import XCTest
@testable import WManager

final class LayoutStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "LayoutStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        if let suiteName {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testSaveLoadConfiguration_RoundTrip() {
        var state = LayoutStore.defaultState()
        let config = LayoutConfig(
            weights: GridWeight(columns: [1, 1, 0, 0], rows: [1, 0, 0]),
            scope: .allDesktops
        )
        LayoutStore.updateLayoutConfig(config, index: 1, scope: .allDesktops, spaceID: nil, in: &state)
        LayoutStore.setActiveLayoutIndex(1, scope: .allDesktops, spaceID: nil, in: &state)
        LayoutStore.save(state, userDefaults: defaults)

        let reloaded = LayoutStore.load(userDefaults: defaults)
        let loaded = LayoutStore.layoutConfig(reloaded, index: 1, scope: .allDesktops, spaceID: nil)
        XCTAssertEqual(loaded.weights, config.weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows))
        XCTAssertEqual(LayoutStore.activeLayoutIndex(reloaded, scope: .allDesktops, spaceID: nil), 1)
    }

    func testLoadConfiguration_CorruptedDataUsesDefaults() {
        defaults.set(Data([0x00, 0x01, 0x02]), forKey: "layout.store")
        let state = LayoutStore.load(userDefaults: defaults)
        let loaded = LayoutStore.layoutConfig(state, index: 0, scope: .allDesktops, spaceID: nil)
        let expected = GridWeight.default().normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows)
        XCTAssertEqual(loaded.weights, expected)
    }

    func testSwitchBetweenLayoutPresets_PersistsEachSlot() {
        var state = LayoutStore.defaultState()
        let first = LayoutConfig(weights: GridWeight(columns: [1, 0, 0, 0], rows: [1, 0, 0]), scope: .allDesktops)
        let second = LayoutConfig(weights: GridWeight(columns: [0, 1, 0, 0], rows: [1, 0, 0]), scope: .allDesktops)
        let third = LayoutConfig(weights: GridWeight(columns: [0, 0, 1, 0], rows: [1, 0, 0]), scope: .allDesktops)
        let fourth = LayoutConfig(weights: GridWeight(columns: [0, 0, 0, 1], rows: [1, 0, 0]), scope: .allDesktops)

        LayoutStore.updateLayoutConfig(first, index: 0, scope: .allDesktops, spaceID: nil, in: &state)
        LayoutStore.updateLayoutConfig(second, index: 1, scope: .allDesktops, spaceID: nil, in: &state)
        LayoutStore.updateLayoutConfig(third, index: 2, scope: .allDesktops, spaceID: nil, in: &state)
        LayoutStore.updateLayoutConfig(fourth, index: 3, scope: .allDesktops, spaceID: nil, in: &state)

        XCTAssertEqual(LayoutStore.layoutConfig(state, index: 0, scope: .allDesktops, spaceID: nil).weights, first.weights)
        XCTAssertEqual(LayoutStore.layoutConfig(state, index: 1, scope: .allDesktops, spaceID: nil).weights, second.weights)
        XCTAssertEqual(LayoutStore.layoutConfig(state, index: 2, scope: .allDesktops, spaceID: nil).weights, third.weights)
        XCTAssertEqual(LayoutStore.layoutConfig(state, index: 3, scope: .allDesktops, spaceID: nil).weights, fourth.weights)
    }

    func testScopePersistence_AllDesktopsVsThisDesktop() {
        var state = LayoutStore.defaultState()
        let spaceID = CGSSpaceID(42)
        let config = LayoutConfig(weights: GridWeight(columns: [2, 1, 0, 0], rows: [1, 1, 0]), scope: .thisDesktop)
        LayoutStore.updateLayoutConfig(config, index: 0, scope: .thisDesktop, spaceID: spaceID, in: &state)
        LayoutStore.save(state, userDefaults: defaults)

        let reloaded = LayoutStore.load(userDefaults: defaults)
        let perDesktop = LayoutStore.layoutConfig(reloaded, index: 0, scope: .thisDesktop, spaceID: spaceID)
        XCTAssertEqual(perDesktop.weights, config.weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows))
    }
}
