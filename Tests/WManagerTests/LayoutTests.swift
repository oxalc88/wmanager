import CoreGraphics
import XCTest
@testable import WManager

final class LayoutTests: XCTestCase {
    func testTileFramesHalfAndMax() {
        let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)

        let expectedMax = CGRect(x: 8, y: 8, width: 1184, height: 784)
        assertRectEqual(TileFrames.maximized(in: screen), expectedMax)

        let expectedLeft = CGRect(x: 8, y: 8, width: 588, height: 784)
        let expectedRight = CGRect(x: 604, y: 8, width: 588, height: 784)
        assertRectEqual(TileFrames.halfLeft(in: screen), expectedLeft)
        assertRectEqual(TileFrames.halfRight(in: screen), expectedRight)
    }

    func testSlotFramesLayout() {
        let frame = CGRect(x: 0, y: 0, width: 1200, height: 800)
        let layout = LayoutPreset.defaultPreset()
        let frames = LayoutEngine.frames(in: frame, layout: layout)

        let expectedTopLeft = CGRect(x: 8, y: 404, width: 389.33, height: 388)
        let expectedTopCenter = CGRect(x: 405.33, y: 404, width: 389.33, height: 388)
        let expectedTopRight = CGRect(x: 802.67, y: 404, width: 389.33, height: 388)
        let expectedBottomLeft = CGRect(x: 8, y: 8, width: 389.33, height: 388)
        let expectedBottomCenter = CGRect(x: 405.33, y: 8, width: 389.33, height: 388)
        let expectedBottomRight = CGRect(x: 802.67, y: 8, width: 389.33, height: 388)

        assertRectEqual(frames[GridCell.cell(row: 0, column: 0)!], expectedTopLeft)
        assertRectEqual(frames[GridCell.cell(row: 0, column: 1)!], expectedTopCenter)
        assertRectEqual(frames[GridCell.cell(row: 0, column: 2)!], expectedTopRight)
        assertRectEqual(frames[GridCell.cell(row: 1, column: 0)!], expectedBottomLeft)
        assertRectEqual(frames[GridCell.cell(row: 1, column: 1)!], expectedBottomCenter)
        assertRectEqual(frames[GridCell.cell(row: 1, column: 2)!], expectedBottomRight)
    }
}

private func assertRectEqual(_ actual: CGRect?, _ expected: CGRect, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertNotNil(actual, file: file, line: line)
    guard let actual else { return }

    XCTAssertEqual(actual.origin.x, expected.origin.x, accuracy: 0.01, file: file, line: line)
    XCTAssertEqual(actual.origin.y, expected.origin.y, accuracy: 0.01, file: file, line: line)
    XCTAssertEqual(actual.size.width, expected.size.width, accuracy: 0.01, file: file, line: line)
    XCTAssertEqual(actual.size.height, expected.size.height, accuracy: 0.01, file: file, line: line)
}
