import UIKit
import UniformTypeIdentifiers
import XCTest

/// Copy, paste, and attach-audio checks for the note editor.
/// This target is not in the shared PennWork Studios scheme.
@MainActor
final class EditorPasteAudioUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLongPressShowsTheEditMenuAndPasteKeepsLineBreaksOnce() throws {
        let bars = (1...16).map { "bar \($0) stays on its own line" }
        UIPasteboard.general.items = [[
            UTType.utf8PlainText.identifier: bars.joined(separator: "\u{2028}")
        ]]

        let app = openBlankEditor()
        let body = app.textViews.firstMatch
        body.press(forDuration: 1.1)
        let paste = app.menuItems["Paste"]
        let pasteButton = app.buttons["Paste"]
        let menuShown = paste.waitForExistence(timeout: 4) || pasteButton.waitForExistence(timeout: 1)
        saveShot(XCUIScreen.main.screenshot(), "long-press-menu")
        XCTAssertTrue(menuShown, "Long-press did not bring up Paste. \(visibleControls(app))")
        if paste.exists {
            paste.tap()
        } else {
            pasteButton.tap()
        }
        pause(1.2)
        let value = (body.value as? String) ?? ""
        saveShot(XCUIScreen.main.screenshot(), "after-paste")
        XCTAssertTrue(value.contains("bar 1 stays on its own line"), "Paste dropped the first bar. Body was: \(value)")
        XCTAssertTrue(value.contains("bar 16 stays on its own line"), "Paste dropped the last bar. Body was: \(value)")
        XCTAssertEqual(value.components(separatedBy: "bar 1 stays on its own line").count - 1, 1, "The first bar was pasted more than once. Body was: \(value)")
        XCTAssertTrue(value.contains("\n") || value.contains("\u{2028}"), "Paste lost the line breaks. Body was: \(value)")
        let lines = value.components(separatedBy: .newlines).filter { $0.contains("stays on its own line") }
        XCTAssertEqual(lines.count, 16, "Expected 16 bars, got \(lines.count). Body was: \(value)")
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 2), "Undo is missing after paste")
        if undo.isEnabled {
            undo.tap()
        }
        pause(0.8)
        let undone = (body.value as? String) ?? ""
        XCTAssertFalse(undone.contains("bar 1 stays on its own line"), "Undo after paste did not restore the note. Body was: \(undone)")
    }

    func testCopyPutsOnlyTheLyricTextOnThePasteboard() throws {
        let app = openBlankEditor()
        let body = app.textViews.firstMatch
        body.tap()
        body.typeText("first bar only\nsecond bar only")
        pause(0.6)
        body.press(forDuration: 1.1)
        let selectAll = app.menuItems["Select All"].exists ? app.menuItems["Select All"] : app.buttons["Select All"]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 4), "Long-press did not offer Select All. \(visibleControls(app))")
        selectAll.tap()
        pause(0.4)
        let copy = app.menuItems["Copy"].exists ? app.menuItems["Copy"] : app.buttons["Copy"]
        XCTAssertTrue(copy.waitForExistence(timeout: 2), "Select All did not offer Copy")
        copy.tap()
        pause(0.4)
        let copied = UIPasteboard.general.string ?? ""
        XCTAssertTrue(copied.contains("first bar only"), "Copy missed the first bar. Clipboard was: \(copied)")
        XCTAssertTrue(copied.contains("second bar only"), "Copy missed the second bar. Clipboard was: \(copied)")
        XCTAssertNil(UIPasteboard.general.data(forPasteboardType: UTType.rtf.identifier), "Copy included rich text markup")
        XCTAssertFalse(copied.contains("Ghost"), "Copy included ghost text. Clipboard was: \(copied)")
    }

    func testAttachAudioOpensTheFilePickerWithoutWritingLyrics() throws {
        let app = openBlankEditor()
        let body = app.textViews.firstMatch
        let before = (body.value as? String) ?? ""
        let menu = app.buttons["Note menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 4), "The note menu is missing")
        menu.tap()
        let attach = app.buttons["Attach audio"]
        XCTAssertTrue(attach.waitForExistence(timeout: 3), "Attach audio is not in the note menu")
        attach.tap()
        let picker = documentPicker(app)
        saveShot(XCUIScreen.main.screenshot(), "attach-audio-picker")
        XCTAssertTrue(picker.waitForExistence(timeout: 8), "Attach audio did not open a file picker. \(visibleControls(app))")
        picker.tap()
        pause(0.5)
        let after = (body.value as? String) ?? ""
        XCTAssertEqual(after, before, "Opening attach audio changed the lyrics")
        XCTAssertFalse(app.otherElements["note-audio-bar"].exists, "A file picker cancel attached audio")
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
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pennwork-ui", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent("\(name).png"))
    }

    /// The file picker is sometimes the app's sheet and sometimes Files.
    private func documentPicker(_ app: XCUIApplication) -> XCUIElement {
        if app.buttons["Cancel"].waitForExistence(timeout: 2) {
            return app.buttons["Cancel"]
        }
        if app.buttons["Browse"].exists { return app.buttons["Browse"] }
        if app.staticTexts["Recents"].exists { return app.staticTexts["Recents"] }
        let bundles = [
            "com.apple.DocumentsApp",
            "com.apple.DocumentManagerUICore"
        ]
        for id in bundles {
            let other = XCUIApplication(bundleIdentifier: id)
            if other.buttons["Cancel"].exists { return other.buttons["Cancel"] }
            if other.buttons["Browse"].exists { return other.buttons["Browse"] }
            if other.staticTexts["Recents"].exists { return other.staticTexts["Recents"] }
        }
        return app.buttons["Cancel"]
    }

    private func visibleControls(_ app: XCUIApplication) -> String {
        let menus = app.menuItems.allElementsBoundByIndex.prefix(12).map(\.label)
        let buttons = app.buttons.allElementsBoundByIndex.prefix(12).map(\.label)
        return "Menus: \(menus). Buttons: \(buttons)."
    }

    private func pause(_ seconds: TimeInterval) {
        let exp = expectation(description: "pause")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { exp.fulfill() }
        wait(for: [exp], timeout: seconds + 2)
    }
}
