import XCTest
@testable import WManager

final class ShortcutsStoreTests: XCTestCase {
    func testLoadDefaultsWhenMissing() {
        let defaults = makeUserDefaults(name: "ShortcutsStoreTests.missing")
        let state = ShortcutsStore.load(userDefaults: defaults)

        XCTAssertEqual(state.shortcuts[.toggleOverlay]?.keyCode, Int(KeyCode.t))
        XCTAssertEqual(state.shortcuts[.layout1]?.keyCode, Int(KeyCode.one))
    }

    func testSaveAndLoadRoundTrip() {
        let defaults = makeUserDefaults(name: "ShortcutsStoreTests.roundtrip")
        var state = ShortcutsStore.defaultState()
        state.shortcuts[.tileLeft] = ShortcutDefinition(
            keyCode: Int(KeyCode.a),
            modifiers: [.command, .option]
        )

        ShortcutsStore.save(state, userDefaults: defaults)
        let loaded = ShortcutsStore.load(userDefaults: defaults)

        XCTAssertEqual(loaded.shortcuts[.tileLeft], state.shortcuts[.tileLeft])
    }

    func testValidateDetectsConflicts() {
        var shortcuts = ShortcutsStore.defaultState().shortcuts
        shortcuts[.tileRight] = shortcuts[.tileLeft]

        let result = ShortcutsStore.validate(shortcuts)

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.conflicts.contains(.tileLeft))
        XCTAssertTrue(result.conflicts.contains(.tileRight))
    }

    func testValidateRequiresModifier() {
        var shortcuts = ShortcutsStore.defaultState().shortcuts
        shortcuts[.maximize] = ShortcutDefinition(keyCode: Int(KeyCode.upArrow), modifiers: [])

        let result = ShortcutsStore.validate(shortcuts)

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.missingModifiers.contains(.maximize))
    }

    private func makeUserDefaults(name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
