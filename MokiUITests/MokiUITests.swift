import XCTest

final class MokiUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMilestoneThreePetRoomLaunchesWithCareControls() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.staticTexts["pet-room.title"].waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.buttons["action.feed"].exists)
        XCTAssertTrue(app.buttons["action.play"].exists)
        XCTAssertTrue(app.buttons["action.care"].exists)
        XCTAssertTrue(app.buttons["action.sleep"].exists)
        XCTAssertTrue(
            app.descendants(matching: .any)["moki.placeholder"].exists
        )
    }

    func testCareActionProducesVisibleFeedback() throws {
        let app = XCUIApplication()
        app.launch()

        let feedButton = app.buttons["action.feed"]
        XCTAssertTrue(feedButton.waitForExistence(timeout: 5))
        feedButton.tap()

        let feedback = app.descendants(matching: .any)["pet.feedback"]
        XCTAssertTrue(feedback.waitForExistence(timeout: 1))
    }
}
