import XCTest

/// Beat Info hides the tempo, key, scale, and bar-length pills until it is tapped.
@MainActor
final class BeatInfoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testBeatInfoHidesThePillsUntilOpened() throws {
        let app = openBlankEditor()
        let title = app.textFields["Title"]
        let body = app.textViews.firstMatch
        XCTAssertTrue(app.buttons["Beat Info"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["BPM"].exists, "Tempo pill is showing before Beat Info is tapped")
        XCTAssertFalse(app.buttons["Bar length"].exists, "Bar length is showing before Beat Info is tapped")
        let gap = body.frame.minY - title.frame.maxY
        saveShot(XCUIScreen.main.screenshot(), "beat-info-hidden")
        XCTAssertLessThan(gap, 90, "Lyrics should start under the title. Gap was \(gap)")

        app.buttons["Beat Info"].tap()
        XCTAssertTrue(app.buttons["BPM"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Key"].exists)
        XCTAssertTrue(app.buttons["Scale"].exists)
        XCTAssertTrue(app.buttons["Bar length"].exists)
        saveShot(XCUIScreen.main.screenshot(), "beat-info-open")
        if !app.buttons["Bar length"].isHittable {
            app.buttons["Key"].swipeLeft()
        }
        XCTAssertTrue(app.buttons["Bar length"].isHittable, "Bar length is cut off and the row did not scroll")

        pause(4.8)
        saveShot(XCUIScreen.main.screenshot(), "beat-info-autohide")
        XCTAssertFalse(app.buttons["BPM"].exists, "The pills stayed up with no interaction")
    }

    func testBPMPickerKeepsTheRowOpenUntilItCloses() throws {
        let app = openBlankEditor()
        app.buttons["Beat Info"].tap()
        XCTAssertTrue(app.buttons["BPM"].waitForExistence(timeout: 2))
        app.buttons["BPM"].tap()
        XCTAssertTrue(app.buttons["Custom BPM"].waitForExistence(timeout: 2), "The tempo picker did not open")
        pause(4.8)
        saveShot(XCUIScreen.main.screenshot(), "beat-info-picker-open")
        XCTAssertTrue(app.buttons["BPM"].exists, "The row hid while the tempo picker was open")
        XCTAssertTrue(app.buttons["Custom BPM"].exists, "The tempo picker closed on its own")

        app.textFields["Title"].tap()
        pause(0.6)
        XCTAssertTrue(app.buttons["BPM"].exists, "The row closed the moment the picker closed")
        pause(4.8)
        XCTAssertFalse(app.buttons["BPM"].exists, "The row stayed up after the picker closed")
    }

    func testTapInTheLyricsClosesTheRow() throws {
        let app = openBlankEditor()
        app.buttons["Beat Info"].tap()
        XCTAssertTrue(app.buttons["BPM"].waitForExistence(timeout: 2))
        app.textViews.firstMatch.tap()
        pause(0.8)
        saveShot(XCUIScreen.main.screenshot(), "beat-info-lyrics-tap")
        XCTAssertFalse(app.buttons["BPM"].exists, "Tapping the lyrics left the pills open")
    }

    func testCollapsedIconShowsADotWhenTempoIsSet() throws {
        let app = openBlankEditor()
        let beatInfo = app.buttons["Beat Info"]
        XCTAssertTrue(beatInfo.waitForExistence(timeout: 3))
        XCTAssertNotEqual(beatInfo.value as? String, "Tempo or key is set")
        beatInfo.tap()
        XCTAssertTrue(app.buttons["BPM"].waitForExistence(timeout: 2))
        app.buttons["BPM"].tap()
        let ninety = app.buttons["90 BPM"]
        XCTAssertTrue(ninety.waitForExistence(timeout: 2))
        ninety.tap()
        pause(0.4)
        if app.buttons["BPM"].exists {
            beatInfo.tap()
        }
        pause(0.5)
        saveShot(XCUIScreen.main.screenshot(), "beat-info-dot")
        XCTAssertFalse(app.buttons["BPM"].exists, "The pills stayed open after Beat Info was tapped again")
        XCTAssertEqual(beatInfo.value as? String, "Tempo or key is set", "Beat Info has no dot after a tempo is set")
    }

    private func openBlankEditor() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-has_completed_onboarding", "YES"]
        app.launch()
        if app.buttons["Continue"].waitForExistence(timeout: 2) {
            app.buttons["Continue"].tap()
            if app.buttons["Skip for now"].waitForExistence(timeout: 3) {
                app.buttons["Skip for now"].tap()
            }
        }
        if app.buttons["New Note"].waitForExistence(timeout: 6) {
            app.buttons["New Note"].tap()
        } else if app.buttons["square.and.pencil"].exists {
            app.buttons["square.and.pencil"].tap()
        }
        let title = app.textFields["Title"]
        XCTAssertTrue(title.waitForExistence(timeout: 12), "The editor did not open")
        XCTAssertTrue(app.textViews.firstMatch.waitForExistence(timeout: 5))
        return app
    }

    private func saveShot(_ screenshot: XCUIScreenshot, _ name: String) {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func pause(_ seconds: TimeInterval) {
        let exp = expectation(description: "pause")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { exp.fulfill() }
        wait(for: [exp], timeout: seconds + 2)
    }
}
