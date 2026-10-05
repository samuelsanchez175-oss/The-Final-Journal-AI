import UIKit
import XCTest

/// Drives the iPhone 17 simulator for the Bar Hits dismiss work and the share sheet.
/// This target is not in the shared PennWork Studios scheme.
@MainActor
final class BarHitsShareUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCloseClearsTheBarHighlight() throws {
        let app = openEditor(line: "ice so loud they blink", forceHoldOn: true)
        openBarHitsByHold(app)
        let openYellow = holdYellowCount(XCUIScreen.main.screenshot())
        saveShot(XCUIScreen.main.screenshot(), "highlight-while-open")
        barHitsCancel(app).tap()
        pause(0.8)
        let closed = XCUIScreen.main.screenshot()
        saveShot(closed, "highlight-after-cancel")
        let closedYellow = holdYellowCount(closed)
        print("BARHITS close openYellow=\(openYellow) closedYellow=\(closedYellow)")
        XCTAssertFalse(barHitsCancel(app).exists, "Bar Hits stayed open after Cancel")
        XCTAssertLessThan(closedYellow, 80, "The bar stayed yellow after Bar Hits closed (\(closedYellow) yellow samples)")
    }

    func testSwipeAwayWhileLoadingLetsYouType() throws {
        let app = openEditor(line: "ice so loud they blink", forceHoldOn: true)
        openBarHitsByHold(app)
        let cancel = barHitsCancel(app)
        let start = cancel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 8))
        let end = cancel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 30))
        start.press(forDuration: 0.05, thenDragTo: end)
        pause(0.4)
        saveShot(XCUIScreen.main.screenshot(), "after-swipe")
        if barHitsCancel(app).exists {
            // The list may have grabbed the drag. A second drag from the title row dismisses the sheet.
            let title = app.buttons.matching(NSPredicate(format: "label == 'Bar hits'")).element(boundBy: 0)
            if title.exists {
                let from = title.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 2))
                let to = title.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 18))
                from.press(forDuration: 0.05, thenDragTo: to)
                pause(0.4)
            }
        }
        XCTAssertFalse(barHitsCancel(app).waitForExistence(timeout: 1), "Swiping Bar Hits away left it open")
        pause(3)
        saveShot(XCUIScreen.main.screenshot(), "three-seconds-after-swipe")
        XCTAssertFalse(barHitsCancel(app).exists, "Bar Hits popped back after the swipe")
        let body = app.textViews.firstMatch
        XCTAssertTrue(body.waitForExistence(timeout: 3))
        body.tap()
        body.typeText(" more")
        pause(0.5)
        XCTAssertFalse(barHitsCancel(app).exists, "Typing brought Bar Hits back")
        let value = (body.value as? String) ?? ""
        XCTAssertTrue(value.contains("more"), "Could not type after dismissing Bar Hits. Body was: \(value)")
    }

    func testHoldToggleStopsAutomaticBarHits() throws {
        let app = openEditor(line: "ice so loud they blink")
        app.buttons["Expand toolbar"].tap()
        let on = app.buttons["Bar Hits opens when you hold"]
        let off = app.buttons["Bar Hits stays closed until you tap it"]
        revealToolbarControl(on.exists ? on : off, in: app)
        if on.exists {
            on.tap()
        }
        XCTAssertTrue(off.waitForExistence(timeout: 2), "The hold toggle did not turn off")
        saveShot(XCUIScreen.main.screenshot(), "toggle-off")
        let syllable = syllableButton(app)
        syllable.press(forDuration: 0.45)
        pause(0.6)
        XCTAssertFalse(barHitsCancel(app).exists, "Holding a syllable count opened Bar Hits while the toggle was off")
        let command = app.buttons["Bar hits"]
        revealToolbarControl(command, in: app)
        command.tap()
        XCTAssertTrue(barHitsCancel(app).waitForExistence(timeout: 5), "The Bar Hits button did not open the sheet")
        barHitsCancel(app).tap()
        // Leave the switch on so the next run matches the app default.
        if off.exists {
            off.tap()
        }
    }

    func testShareFromNotesImportsTheLines() throws {
        try shareText(
            from: "com.apple.mobilenotes",
            name: "notes",
            body: "Shared from Notes\nsecond line stays put\n",
            prepare: { notes in
                self.dismissSystemAlerts()
                let composeLabels = ["New Note", "Compose", "New note"]
                var opened = false
                for label in composeLabels where notes.buttons[label].waitForExistence(timeout: 2) {
                    notes.buttons[label].tap()
                    opened = true
                    break
                }
                if !opened, notes.buttons["square.and.pencil"].exists {
                    notes.buttons["square.and.pencil"].tap()
                    opened = true
                }
                XCTAssertTrue(opened, "Could not start a note in Notes")
                let field = notes.textViews.firstMatch
                XCTAssertTrue(field.waitForExistence(timeout: 5))
                field.tap()
                field.typeText("Shared from Notes\nsecond line stays put")
            }
        )
    }

    func testShareFromSafariShowsXJournal() throws {
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()
        dismissSystemAlerts()
        let address = safari.textFields["Address"].exists
            ? safari.textFields["Address"]
            : safari.textFields["TabBarItemTitle"].exists
                ? safari.textFields["TabBarItemTitle"]
                : safari.textFields.firstMatch
        if address.waitForExistence(timeout: 6) {
            address.tap()
            address.typeText("https://example.com\n")
            pause(2)
        }
        try openShareSheet(safari, name: "safari")
        saveShot(XCUIScreen.main.screenshot(), "safari-share-sheet")
        let found = revealXJournal(safari)
        if found {
            safari.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'XJournal'")).firstMatch.tap()
            let importButton = safari.buttons["Import"]
            XCTAssertTrue(importButton.waitForExistence(timeout: 8), "Safari share did not open the import sheet")
            saveShot(XCUIScreen.main.screenshot(), "safari-import-sheet")
        }
        XCTAssertTrue(found, "XJournal AI was not in the Safari share sheet")
    }

    func testShareFromMessagesShowsXJournal() throws {
        let messages = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")
        messages.launch()
        dismissSystemAlerts()
        saveShot(XCUIScreen.main.screenshot(), "messages-launch")
        // A sent bubble can be shared. An empty inbox has nothing to share.
        let bubble = messages.cells.firstMatch
        if bubble.waitForExistence(timeout: 4) {
            bubble.press(forDuration: 1.0)
            let share = messages.buttons["Share"].exists ? messages.buttons["Share"] : messages.buttons["Share Message"]
            if share.waitForExistence(timeout: 3) {
                share.tap()
                let found = revealXJournal(messages)
                saveShot(XCUIScreen.main.screenshot(), "messages-share-sheet")
                XCTAssertTrue(found, "XJournal AI was not in the Messages share sheet")
                return
            }
        }
        saveHierarchy(messages, "messages-no-share")
        XCTFail("Messages had no message to share, so the share sheet could not be opened")
    }

    // MARK: - Editor

    private func openEditor(line: String, forceHoldOn: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-has_completed_onboarding", "YES"]
        if forceHoldOn {
            app.launchArguments += ["-barHits.opensFromHold", "YES"]
        }
        app.launch()
        dismissSystemAlerts()
        if app.buttons["Continue"].waitForExistence(timeout: 2) {
            app.buttons["Continue"].tap()
            if app.buttons["Skip for now"].waitForExistence(timeout: 3) {
                app.buttons["Skip for now"].tap()
            }
        }
        createNote(app)
        let title = app.textFields["Title"]
        XCTAssertTrue(title.waitForExistence(timeout: 12), "The editor did not open")
        let body = app.textViews.firstMatch
        XCTAssertTrue(body.waitForExistence(timeout: 5))
        body.tap()
        body.typeText(line)
        pause(0.8)
        return app
    }

    private func createNote(_ app: XCUIApplication) {
        if app.buttons["New Note"].waitForExistence(timeout: 6) {
            app.buttons["New Note"].tap()
            return
        }
        if app.buttons["square.and.pencil"].exists {
            app.buttons["square.and.pencil"].tap()
            return
        }
        if app.buttons["plus"].exists {
            app.buttons["plus"].tap()
            if app.buttons["New Note"].waitForExistence(timeout: 2) {
                app.buttons["New Note"].tap()
                return
            }
            if app.menuItems["New Note"].exists {
                app.menuItems["New Note"].tap()
                return
            }
        }
        saveHierarchy(app, "could-not-create-note")
        XCTFail("Could not find New Note")
    }

    private func openBarHitsByHold(_ app: XCUIApplication) {
        let syllable = syllableButton(app)
        XCTAssertTrue(syllable.waitForExistence(timeout: 6), "No syllable count button appeared")
        syllable.press(forDuration: 0.45)
        XCTAssertTrue(barHitsCancel(app).waitForExistence(timeout: 5), "Holding the syllable count did not open Bar Hits")
    }

    private func syllableButton(_ app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'syllables. Hold'")).firstMatch
    }

    private func barHitsCancel(_ app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(format: "label == 'Cancel' AND hint BEGINSWITH 'Closes Bar Hits'")
        ).firstMatch
    }

    private func revealToolbarControl(_ control: XCUIElement, in app: XCUIApplication) {
        if control.exists, control.isHittable { return }
        let anchor = app.buttons["Close toolbar"]
        for _ in 0..<8 {
            if control.exists, control.isHittable { return }
            guard anchor.exists else { break }
            let from = anchor.coordinate(withNormalizedOffset: CGVector(dx: 6, dy: 0.5))
            let to = anchor.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5))
            from.press(forDuration: 0.02, thenDragTo: to)
            pause(0.3)
        }
    }

    // MARK: - Share sheet

    private func shareText(from bundle: String, name: String, body: String, prepare: (XCUIApplication) -> Void) throws {
        let other = XCUIApplication(bundleIdentifier: bundle)
        other.launch()
        prepare(other)
        try openShareSheet(other, name: name)
        saveShot(XCUIScreen.main.screenshot(), "\(name)-share-sheet")
        XCTAssertTrue(revealXJournal(other), "XJournal AI was not in the \(name) share sheet")
        other.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'XJournal'")).firstMatch.tap()
        let title = other.textFields["Note title"]
        XCTAssertTrue(title.waitForExistence(timeout: 8), "The import sheet did not show a note title")
        let preview = other.textViews["Note preview"]
        let shown = ((preview.value as? String) ?? preview.label)
        XCTAssertTrue(shown.contains("second line stays put") || shown.contains(body.prefix(12)), "Preview lost the shared text: \(shown)")
        other.buttons["Import"].tap()
        pause(2)
        let host = XCUIApplication(bundleIdentifier: "TEAMDB.The-Final-Journal-AI")
        host.activate()
        pause(2)
        saveShot(XCUIScreen.main.screenshot(), "\(name)-after-import")
        let hostBody = host.textViews.firstMatch
        let imported = host.staticTexts["Shared from Notes"].exists
            || ((hostBody.value as? String) ?? "").contains("second line stays put")
        XCTAssertTrue(imported, "The imported note was not open with its line breaks")
    }

    private func openShareSheet(_ app: XCUIApplication, name: String) throws {
        let labels = ["Share", "Share Note", "Share Message", "Share Page"]
        for label in labels where app.buttons[label].waitForExistence(timeout: 2) {
            app.buttons[label].tap()
            pause(1)
            return
        }
        // Notes sometimes tucks Share under the more menu.
        if app.buttons["More"].exists {
            app.buttons["More"].tap()
            if app.buttons["Share"].waitForExistence(timeout: 2) {
                app.buttons["Share"].tap()
                pause(1)
                return
            }
        }
        saveHierarchy(app, "\(name)-no-share-button")
        XCTFail("No Share button in \(name)")
    }

    private func revealXJournal(_ app: XCUIApplication) -> Bool {
        let query = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'XJournal'"))
        if query.firstMatch.waitForExistence(timeout: 3) { return true }
        for _ in 0..<4 {
            app.swipeUp()
            if query.firstMatch.waitForExistence(timeout: 1) { return true }
            if app.collectionViews.firstMatch.exists {
                app.collectionViews.firstMatch.swipeLeft()
            }
            if query.firstMatch.waitForExistence(timeout: 1) { return true }
        }
        saveHierarchy(app, "share-sheet-missing-xjournal")
        return false
    }

    // MARK: - Evidence

    private func holdYellowCount(_ shot: XCUIScreenshot) -> Int {
        guard let image = UIImage(data: shot.pngRepresentation), let cg = image.cgImage else { return -1 }
        let cropHeight = max(1, cg.height / 2)
        guard let cropped = cg.cropping(to: CGRect(x: 0, y: 0, width: cg.width, height: cropHeight)) else { return -1 }
        let width = cropped.width
        let height = cropped.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drew = pixels.withUnsafeMutableBytes { raw -> Bool in
            guard let context = CGContext(
                data: raw.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drew else { return -1 }
        var count = 0
        var index = 0
        while index + 3 < pixels.count {
            let red = Int(pixels[index])
            let green = Int(pixels[index + 1])
            let blue = Int(pixels[index + 2])
            if red > 220, green > 180, blue < 170, green > blue + 30 {
                count += 1
            }
            index += 16
        }
        return count
    }

    private func saveShot(_ shot: XCUIScreenshot, _ name: String) {
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pennwork-ui", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("\(name).png")
        try? shot.pngRepresentation.write(to: url)
        print("BARHITS shot \(url.path)")
    }

    private func saveHierarchy(_ app: XCUIApplication, _ name: String) {
        saveShot(XCUIScreen.main.screenshot(), name)
        let text = app.debugDescription
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pennwork-ui", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("\(name).txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
        print("BARHITS hierarchy \(url.path)\n\(text.prefix(2000))")
    }

    private func dismissSystemAlerts() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons["Don’t Allow"]
        if allow.waitForExistence(timeout: 1) {
            allow.tap()
        } else if springboard.buttons["Don't Allow"].exists {
            springboard.buttons["Don't Allow"].tap()
        } else if springboard.buttons["Not Now"].exists {
            springboard.buttons["Not Now"].tap()
        }
    }

    private func pause(_ seconds: TimeInterval) {
        let waiter = expectation(description: "pause")
        waiter.isInverted = true
        wait(for: [waiter], timeout: seconds)
    }
}
