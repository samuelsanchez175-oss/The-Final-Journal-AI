import XCTest

/// Opens the noun bank and saves shots of the chip buttons.
@MainActor
final class NounBankLookUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testNounChipsShowTheirPictures() throws {
        let app = openBlankEditor()
        XCTAssertTrue(app.buttons["Nouns"].waitForExistence(timeout: 4))
        app.buttons["Nouns"].tap()
        let bar = app.navigationBars["Nouns"]
        XCTAssertTrue(bar.waitForExistence(timeout: 8), "The noun bank did not open")
        expandSheet(app)
        saveShot("liquors")

        reveal(app, "People")
        app.buttons["People"].tap()
        reveal(app, "Characters")
        app.buttons["Characters"].tap()
        pause(0.6)
        saveShot("characters")

        reveal(app, "Religion & People")
        app.buttons["Religion & People"].tap()
        pause(0.6)
        saveShot("religion")

        search(app, "mosque", shot: "search-mosque")
        search(app, "homer", shot: "search-homer")
        search(app, "harley", shot: "search-harley")
        search(app, "xbox", shot: "search-xbox")

        XCTAssertTrue(chip(app, starting: "xbox").waitForExistence(timeout: 3), "Xbox did not show up in search")
    }

    private func search(_ app: XCUIApplication, _ text: String, shot: String) {
        let field = app.searchFields["Search all nouns"]
        XCTAssertTrue(field.waitForExistence(timeout: 4), "Search field is missing")
        if !field.isHittable {
            expandSheet(app)
        }
        field.tap()
        if field.buttons["Clear text"].exists {
            field.buttons["Clear text"].tap()
        }
        field.typeText(text)
        pause(0.8)
        saveShot(shot)
    }

    private func chip(_ app: XCUIApplication, starting name: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name)).firstMatch
    }

    private func reveal(_ app: XCUIApplication, _ name: String) {
        let button = app.buttons[name]
        var hops = 0
        while hops < 6 && !(button.exists && button.isHittable) {
            if app.buttons["Phrases"].exists && app.buttons["Phrases"].isHittable {
                app.buttons["Phrases"].swipeLeft()
            } else if app.buttons["Liquids"].exists {
                app.buttons["Liquids"].swipeLeft()
            } else {
                app.swipeLeft()
            }
            hops += 1
        }
    }

    private func expandSheet(_ app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18))
        start.press(forDuration: 0.05, thenDragTo: end)
        pause(0.4)
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

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let folder = URL(fileURLWithPath: "/tmp/pennwork-noun-shots", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? shot.pngRepresentation.write(to: folder.appendingPathComponent("\(name).png"))
    }

    private func pause(_ seconds: TimeInterval) {
        let exp = expectation(description: "pause")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { exp.fulfill() }
        wait(for: [exp], timeout: seconds + 2)
    }
}
