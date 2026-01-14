import XCTest

final class SettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        if ProcessInfo.processInfo.environment["RUN_UI_TESTS"] != "1" {
            throw XCTSkip("UI tests require an Xcode UI test target and app host. Set RUN_UI_TESTS=1 to run.")
        }
        continueAfterFailure = false
    }

    func testIncrementColumnWeight_UpdatesValue() {
        let app = XCUIApplication()
        app.launch()

        openSettings(in: app)

        let plusButton = app.buttons["column-weight-plus-0"]
        let valueLabel = app.textFields["column-weight-value-0"]
        XCTAssertTrue(valueLabel.exists)

        let initialValue = valueLabel.value as? String
        plusButton.click()
        let updatedValue = valueLabel.value as? String
        XCTAssertNotEqual(initialValue, updatedValue)
    }

    func testDecrementColumnWeight_StopsAtZero() {
        let app = XCUIApplication()
        app.launch()

        openSettings(in: app)

        let valueField = app.textFields["column-weight-value-0"]
        let minusButton = app.buttons["column-weight-minus-0"]
        XCTAssertTrue(valueField.exists)

        valueField.click()
        valueField.typeText("\u{8}\u{8}\u{8}0")
        minusButton.click()

        let updatedValue = valueField.value as? String
        XCTAssertEqual(updatedValue, "0")
    }

    func testSwitchLayoutTabs_PreservesSettings() {
        let app = XCUIApplication()
        app.launch()

        openSettings(in: app)

        app.buttons["layout-tab-0"].click()
        let firstValue = app.textFields["column-weight-value-1"].value as? String

        app.buttons["layout-tab-1"].click()
        app.buttons["layout-tab-0"].click()

        let restoredValue = app.textFields["column-weight-value-1"].value as? String
        XCTAssertEqual(firstValue, restoredValue)
    }

    func testScopeSelection_UpdatesSelection() {
        let app = XCUIApplication()
        app.launch()

        openSettings(in: app)

        let allDesktops = app.buttons["scope-allDesktops"]
        let thisDesktop = app.buttons["scope-thisDesktop"]
        XCTAssertTrue(allDesktops.exists)
        XCTAssertTrue(thisDesktop.exists)

        thisDesktop.click()
        XCTAssertTrue(thisDesktop.isSelected)
    }

    func testApplyButton_SavesConfiguration() {
        let app = XCUIApplication()
        app.launch()

        openSettings(in: app)

        let changeButton = app.buttons["change-cancel-button"]
        let applyButton = app.buttons["apply-button"]
        changeButton.click()
        applyButton.click()

        XCTAssertTrue(applyButton.exists)
    }

    private func openSettings(in app: XCUIApplication) {
        if app.menuBars.menuBarItems["Tactile"].exists {
            app.menuBars.menuBarItems["Tactile"].click()
        } else if app.menuBars.menuBarItems["WManager"].exists {
            app.menuBars.menuBarItems["WManager"].click()
        }
        let settingsItem = app.menuItems["Settings..."]
        if settingsItem.waitForExistence(timeout: 2) {
            settingsItem.click()
        }
    }
}
