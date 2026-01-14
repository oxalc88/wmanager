import Cocoa
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

    func testModifierDisplayPartsOrder() {
        let modifiers: ShortcutModifiers = [.shift, .command, .option]
        XCTAssertEqual(modifiers.displayParts, ["Cmd", "Opt", "Shift"])
    }

    func testModifierMatchingRespectsAdditionalKeys() {
        let modifiers: ShortcutModifiers = [.command, .option]
        let flags: CGEventFlags = [.maskCommand, .maskAlternate, .maskShift]
        XCTAssertFalse(modifiers.matches(flags: flags, allowAdditional: false))
        XCTAssertTrue(modifiers.matches(flags: flags, allowAdditional: true))
    }

    func testModifierFlagsConversionFromNSEvent() {
        let modifiers = ShortcutModifiers.from(NSEvent.ModifierFlags([.command, .shift]))
        XCTAssertEqual(modifiers, [.command, .shift])
    }

    func testShortcutDisplayStringUsesLabels() {
        let shortcut = ShortcutDefinition(keyCode: Int(KeyCode.t), modifiers: [.command, .option])
        XCTAssertEqual(shortcut.displayString, "Cmd+Opt+T")
    }

    func testLayoutIndexMatchesShortcut() {
        let state = ShortcutsStore.defaultState()
        let exactIndex = state.layoutIndex(for: KeyCode.one, flags: [.maskControl, .maskShift], allowAdditional: false)
        XCTAssertEqual(exactIndex, 0)

        let extraIndex = state.layoutIndex(
            for: KeyCode.one,
            flags: [.maskControl, .maskShift, .maskAlternate],
            allowAdditional: true
        )
        XCTAssertEqual(extraIndex, 0)

        let blockedIndex = state.layoutIndex(
            for: KeyCode.one,
            flags: [.maskControl, .maskShift, .maskAlternate],
            allowAdditional: false
        )
        XCTAssertNil(blockedIndex)
    }

    func testLoadNormalizesMissingShortcuts() throws {
        let defaults = makeUserDefaults(name: "ShortcutsStoreTests.partial")
        let partial = ShortcutsState(shortcuts: [
            .toggleOverlay: ShortcutDefinition(keyCode: Int(KeyCode.t), modifiers: [.command])
        ])
        let data = try JSONEncoder().encode(partial)
        defaults.set(data, forKey: "WManager.shortcuts")

        let loaded = ShortcutsStore.load(userDefaults: defaults)
        XCTAssertNotNil(loaded.shortcuts[.tileLeft])
        XCTAssertNotNil(loaded.shortcuts[.layout4])
    }

    func testValidateRejectsInvalidKeys() {
        var shortcuts = ShortcutsStore.defaultState().shortcuts
        shortcuts[.toggleOverlay] = ShortcutDefinition(keyCode: Int(KeyCode.escape), modifiers: [.command])

        let result = ShortcutsStore.validate(shortcuts)

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.invalidKeys.contains(.toggleOverlay))
        XCTAssertEqual(result.message, "Shortcuts cannot use Escape/Return or modifier-only keys.")
    }

    func testValidationMessagePrefersMissingModifiers() {
        var shortcuts = ShortcutsStore.defaultState().shortcuts
        shortcuts[.tileLeft] = ShortcutDefinition(keyCode: Int(KeyCode.escape), modifiers: [])

        let result = ShortcutsStore.validate(shortcuts)

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.missingModifiers.contains(.tileLeft))
        XCTAssertTrue(result.invalidKeys.contains(.tileLeft))
        XCTAssertEqual(result.message, "Shortcuts must include at least one modifier key.")
    }

    private func makeUserDefaults(name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
