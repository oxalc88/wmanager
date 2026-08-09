import XCTest
@testable import WManager

final class DesktopManagerTests: XCTestCase {

    func testUserSpaceIDsFiltersUserSpacesOnly() {
        let displayEntry: [String: Any] = [
            "Spaces": [
                ["ManagedSpaceID": NSNumber(value: 1), "type": NSNumber(value: 0)],
                ["ManagedSpaceID": NSNumber(value: 2), "type": NSNumber(value: 0)],
                ["ManagedSpaceID": NSNumber(value: 3), "type": NSNumber(value: 4)],
                ["ManagedSpaceID": NSNumber(value: 4), "type": NSNumber(value: 0)],
            ]
        ]
        let ids = DesktopManager.userSpaceIDs(from: displayEntry)
        XCTAssertEqual(ids, [1, 2, 4])
    }

    func testUserSpaceIDsReturnsEmptyForNoSpaces() {
        let displayEntry: [String: Any] = [:]
        let ids = DesktopManager.userSpaceIDs(from: displayEntry)
        XCTAssertTrue(ids.isEmpty)
    }

    func testUserSpaceIDsReturnsEmptyWhenAllFullscreen() {
        let displayEntry: [String: Any] = [
            "Spaces": [
                ["ManagedSpaceID": NSNumber(value: 10), "type": NSNumber(value: 4)],
                ["ManagedSpaceID": NSNumber(value: 11), "type": NSNumber(value: 4)],
            ]
        ]
        let ids = DesktopManager.userSpaceIDs(from: displayEntry)
        XCTAssertTrue(ids.isEmpty)
    }

    func testUserSpaceIDsPreservesOrder() {
        let displayEntry: [String: Any] = [
            "Spaces": [
                ["ManagedSpaceID": NSNumber(value: 42), "type": NSNumber(value: 0)],
                ["ManagedSpaceID": NSNumber(value: 7), "type": NSNumber(value: 0)],
                ["ManagedSpaceID": NSNumber(value: 99), "type": NSNumber(value: 0)],
            ]
        ]
        let ids = DesktopManager.userSpaceIDs(from: displayEntry)
        XCTAssertEqual(ids, [42, 7, 99])
    }
}
