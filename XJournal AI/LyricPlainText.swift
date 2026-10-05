import UIKit
import UniformTypeIdentifiers

/// Lyric clipboard. Copy and paste stay plain text so rhyme washes and
/// rich Notes / Safari formatting never ride along. Line breaks stay.
nonisolated enum LyricPlainText {
    /// Notes, Genius, and Safari often use paragraph and line separators
    /// instead of `\n`. The editor stores one bar per `\n`.
    static func normalizeLineBreaks(_ raw: String) -> String {
        var text = raw.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")
        text = text.replacingOccurrences(of: "\u{2028}", with: "\n")
        text = text.replacingOccurrences(of: "\u{2029}", with: "\n")
        text = text.replacingOccurrences(of: "\u{0085}", with: "\n")
        return text
    }

    @MainActor
    static func fromPasteboard() -> String? {
        let board = UIPasteboard.general
        if let plain = board.string {
            let normalized = normalizeLineBreaks(plain)
            if !normalized.isEmpty { return normalized }
        }
        if let data = board.data(forPasteboardType: UTType.rtf.identifier),
           let rich = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
           ) {
            let normalized = normalizeLineBreaks(rich.string)
            if !normalized.isEmpty { return normalized }
        }
        if let html = board.data(forPasteboardType: UTType.html.identifier),
           let rich = try? NSAttributedString(
            data: html,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
           ) {
            let normalized = normalizeLineBreaks(rich.string)
            if !normalized.isEmpty { return normalized }
        }
        return nil
    }

    /// Puts only the selected lyric characters on the clipboard. No RTF,
    /// so background washes and underlines are not part of the copy.
    @MainActor
    static func copySelection(from textView: UITextView) -> Bool {
        let storage = (textView.text ?? "") as NSString
        let range = textView.selectedRange
        guard range.length > 0,
              range.location != NSNotFound,
              range.location + range.length <= storage.length else { return false }
        let plain = normalizeLineBreaks(storage.substring(with: range))
        guard !plain.isEmpty else { return false }
        // Local only: a general-clipboard write from the simulator can sit
        // for minutes trying to hand the text to the Mac, and the editor
        // never becomes idle after Copy.
        UIPasteboard.general.setItems(
            [[
                UTType.utf8PlainText.identifier: plain,
                UTType.plainText.identifier: plain
            ]],
            options: [.localOnly: true]
        )
        return true
    }

    /// The bar that contains `caret`, including its trailing newline when the
    /// bar has text. A caret parked after a final newline is the empty line
    /// that follows, so it does not take the previous bar.
    static func lineRange(in text: NSString, caret: Int) -> NSRange {
        let length = text.length
        guard length > 0 else { return NSRange(location: 0, length: 0) }
        let index = min(max(caret, 0), length)
        if index == length {
            let last = text.character(at: length - 1)
            if last == 0x000A || last == 0x000D || last == 0x2028 || last == 0x2029 {
                return NSRange(location: length, length: 0)
            }
        }
        let probe = min(index, length - 1)
        return text.lineRange(for: NSRange(location: probe, length: 0))
    }

    /// The word touching the caret. A caret on the gap after a word takes that
    /// word. Apostrophes stay inside the word (`don't`, `I’m`). Digits count.
    static func wordRange(in text: NSString, caret: Int) -> NSRange? {
        let length = text.length
        guard length > 0 else { return nil }
        let index = min(max(caret, 0), length)
        if index < length, let range = word(touching: index, in: text) {
            return range
        }
        if index > 0, let range = word(touching: index - 1, in: text) {
            return range
        }
        return nil
    }

    private static func word(touching index: Int, in text: NSString) -> NSRange? {
        guard index >= 0, index < text.length, isWordUnit(text.character(at: index)) else { return nil }
        var start = index
        while start > 0, isWordUnit(text.character(at: start - 1)) {
            start -= 1
        }
        var end = index + 1
        while end < text.length, isWordUnit(text.character(at: end)) {
            end += 1
        }
        var hasLetterOrDigit = false
        for unitIndex in start..<end {
            let unit = text.character(at: unitIndex)
            if unit != 0x27, unit != 0x2019,
               let scalar = UnicodeScalar(unit),
               CharacterSet.alphanumerics.contains(scalar) {
                hasLetterOrDigit = true
                break
            }
        }
        guard hasLetterOrDigit else { return nil }
        return NSRange(location: start, length: end - start)
    }

    private static func isWordUnit(_ unit: unichar) -> Bool {
        if unit == 0x27 || unit == 0x2019 { return true }
        guard let scalar = UnicodeScalar(unit) else { return false }
        return CharacterSet.alphanumerics.contains(scalar)
    }
}

/// One-tap cut, copy, paste, and selection for the writing surface.
/// Copy stays on `LyricPlainText.copySelection` (local clipboard only).
@MainActor
enum EditorClipboard {
    static var hasSelection: Bool {
        guard let editor = EditorWritingMetrics.activeTextView else { return false }
        let range = editor.selectedRange
        return range.length > 0 && range.location != NSNotFound
    }

    static func menuElements(afterSelect: ((UITextView) -> Void)? = nil) -> [UIMenuElement] {
        let editor = EditorWritingMetrics.activeTextView
        let storage = (editor?.text ?? "") as NSString
        let selected = editor?.selectedRange ?? NSRange(location: NSNotFound, length: 0)
        let hasSelection = selected.location != NSNotFound && selected.length > 0
        let caret = selected.location == NSNotFound ? 0 : selected.location
        let line = LyricPlainText.lineRange(in: storage, caret: caret)
        let canTakeLine = hasSelection || line.length > 0

        func reveal() {
            guard let editor = EditorWritingMetrics.activeTextView else { return }
            afterSelect?(editor)
        }

        let cut = UIAction(title: hasSelection ? "Cut" : "Cut line", image: UIImage(systemName: "scissors")) { _ in
            Self.cut()
        }
        let copy = UIAction(title: hasSelection ? "Copy" : "Copy line", image: UIImage(systemName: "doc.on.doc")) { _ in
            Self.copy()
        }
        if !canTakeLine {
            cut.attributes = .disabled
            copy.attributes = .disabled
        }

        let paste = UIAction(title: "Paste", image: UIImage(systemName: "doc.on.clipboard")) { _ in
            Self.paste()
        }
        if LyricPlainText.fromPasteboard() == nil {
            paste.attributes = .disabled
        }

        let word = UIAction(title: "Select word", image: UIImage(systemName: "character.cursor.ibeam")) { _ in
            Self.selectWord()
            reveal()
        }
        if LyricPlainText.wordRange(in: storage, caret: caret) == nil {
            word.attributes = .disabled
        }

        let selectLine = UIAction(title: "Select line", image: UIImage(systemName: "text.alignleft")) { _ in
            Self.selectLine()
            reveal()
        }
        if line.length == 0 {
            selectLine.attributes = .disabled
        }

        let selectAll = UIAction(title: "Select All", image: UIImage(systemName: "doc.text")) { _ in
            Self.selectAll()
            reveal()
        }
        if storage.length == 0 || (hasSelection && selected.length >= storage.length && selected.location == 0) {
            selectAll.attributes = .disabled
        }

        let edits = UIMenu(options: .displayInline, children: [cut, copy, paste])
        let picks = UIMenu(options: .displayInline, children: [word, selectLine, selectAll])
        return [edits, picks]
    }

    static func selectWord() {
        guard let editor = EditorWritingMetrics.activeTextView else { return }
        let storage = (editor.text ?? "") as NSString
        guard let range = LyricPlainText.wordRange(in: storage, caret: caret(in: editor)) else { return }
        focus(editor)
        editor.selectedRange = range
        HapticFeedbackManager.shared.selection()
    }

    static func selectLine() {
        guard let editor = EditorWritingMetrics.activeTextView else { return }
        let storage = (editor.text ?? "") as NSString
        let range = LyricPlainText.lineRange(in: storage, caret: caret(in: editor))
        guard range.length > 0 else { return }
        focus(editor)
        editor.selectedRange = range
        HapticFeedbackManager.shared.selection()
    }

    static func selectAll() {
        guard let editor = EditorWritingMetrics.activeTextView else { return }
        let length = ((editor.text ?? "") as NSString).length
        guard length > 0 else { return }
        focus(editor)
        editor.selectedRange = NSRange(location: 0, length: length)
        HapticFeedbackManager.shared.selection()
    }

    static func copy() {
        guard let editor = EditorWritingMetrics.activeTextView else { return }
        focus(editor)
        guard prepareCopyRange(on: editor) else { return }
        guard LyricPlainText.copySelection(from: editor) else { return }
        HapticFeedbackManager.shared.selection()
    }

    static func cut() {
        guard let editor = EditorWritingMetrics.activeTextView else { return }
        focus(editor)
        guard prepareCopyRange(on: editor) else { return }
        editor.cut(nil)
        HapticFeedbackManager.shared.selection()
    }

    static func paste() {
        guard let editor = EditorWritingMetrics.activeTextView else { return }
        guard LyricPlainText.fromPasteboard() != nil else { return }
        focus(editor)
        editor.paste(nil)
        HapticFeedbackManager.shared.selection()
    }

    private static func prepareCopyRange(on editor: UITextView) -> Bool {
        if editor.selectedRange.length > 0 { return true }
        let storage = (editor.text ?? "") as NSString
        let line = LyricPlainText.lineRange(in: storage, caret: caret(in: editor))
        guard line.length > 0 else { return false }
        editor.selectedRange = line
        return true
    }

    private static func caret(in editor: UITextView) -> Int {
        let range = editor.selectedRange
        if range.location == NSNotFound { return 0 }
        return range.location
    }

    private static func focus(_ editor: UITextView) {
        if !editor.isFirstResponder {
            _ = editor.becomeFirstResponder()
        }
    }
}
