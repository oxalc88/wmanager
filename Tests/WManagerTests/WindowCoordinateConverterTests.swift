import CoreGraphics
import XCTest
@testable import WManager

final class WindowCoordinateConverterTests: XCTestCase {
    func testAxFrameFlipsVerticalAxis() {
        let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
        let slots = Slot.frames(in: screen)

        let topLeft = slots[.topLeft]
        let bottomLeft = slots[.bottomLeft]
        XCTAssertNotNil(topLeft)
        XCTAssertNotNil(bottomLeft)
        guard let topLeft, let bottomLeft else { return }

        let axTopLeft = WindowCoordinateConverter.axFrame(fromCocoa: topLeft, in: screen)
        let axBottomLeft = WindowCoordinateConverter.axFrame(fromCocoa: bottomLeft, in: screen)

        let expectedTopLeftY = screen.maxY - topLeft.maxY
        let expectedBottomLeftY = screen.maxY - bottomLeft.maxY

        XCTAssertEqual(axTopLeft.origin.y, expectedTopLeftY, accuracy: 0.01)
        XCTAssertEqual(axBottomLeft.origin.y, expectedBottomLeftY, accuracy: 0.01)
    }
}
