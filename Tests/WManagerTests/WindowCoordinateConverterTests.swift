import CoreGraphics
import XCTest
@testable import WManager

final class WindowCoordinateConverterTests: XCTestCase {
    func testAxFrameFlipsVerticalAxis() {
        let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
        let layout = LayoutPreset.defaultPreset()
        let frames = LayoutEngine.frames(in: screen, layout: layout)

        let topLeft = frames[GridCell.cell(row: 0, column: 0)!]
        let lowerLeft = frames[GridCell.cell(row: 1, column: 0)!]
        XCTAssertNotNil(topLeft)
        XCTAssertNotNil(lowerLeft)
        guard let topLeft, let lowerLeft else { return }

        let axTopLeft = WindowCoordinateConverter.axFrame(fromCocoa: topLeft, in: screen)
        let axLowerLeft = WindowCoordinateConverter.axFrame(fromCocoa: lowerLeft, in: screen)

        let expectedTopLeftY = screen.maxY - topLeft.maxY
        let expectedLowerLeftY = screen.maxY - lowerLeft.maxY

        XCTAssertEqual(axTopLeft.origin.y, expectedTopLeftY, accuracy: 0.01)
        XCTAssertEqual(axLowerLeft.origin.y, expectedLowerLeftY, accuracy: 0.01)
    }
}
