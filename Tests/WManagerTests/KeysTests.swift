import XCTest
@testable import WManager

final class KeysTests: XCTestCase {
    func testLabelKnownKeys() {
        XCTAssertEqual(KeyCode.label(for: KeyCode.leftArrow), "Left")
        XCTAssertEqual(KeyCode.label(for: KeyCode.upArrow), "Up")
        XCTAssertEqual(KeyCode.label(for: KeyCode.one), "1")
        XCTAssertEqual(KeyCode.label(for: KeyCode.t), "T")
    }

    func testLabelUnknownKeyFallsBack() {
        let label = KeyCode.label(for: CGKeyCode(201))
        XCTAssertEqual(label, "Key 201")
    }

    func testModifierKeyDetection() {
        XCTAssertTrue(KeyCode.isModifierKey(KeyCode.leftShift))
        XCTAssertTrue(KeyCode.isModifierKey(KeyCode.rightCommand))
        XCTAssertFalse(KeyCode.isModifierKey(KeyCode.a))
    }
}
