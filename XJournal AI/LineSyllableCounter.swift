import Foundation
import UIKit

/// Per-newline syllable counts for the editor gutter. One number per lyric line, not per wrap.
nonisolated enum LineSyllableCounter: Sendable {
    private enum TokenKind {
        case letter, digit, other
    }

    private static func tokenKind(_ scalar: UnicodeScalar) -> TokenKind {
        if CharacterSet.decimalDigits.contains(scalar) { return .digit }
        if CharacterSet.letters.contains(scalar) || scalar == "'" || scalar == "’" { return .letter }
        return .other
    }

    static func counts(for text: String) -> [Int] {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        return lines.map { syllableCount(forLine: String($0)) }
    }

    static func lineHeight(for fontSize: CGFloat) -> CGFloat {
        EditorWritingMetrics.rowHeight(fontSize: fontSize)
    }

    /// Visual height of each newline row at `width`, so the gutter tracks wrapped bars.
    /// Always an integer multiple of the writing row height so counts stay
    /// in lockstep with TextEditor / UITextView line boxes (no per-row ceil drift).
    static func rowHeights(for text: String, width: CGFloat, fontSize: CGFloat) -> [CGFloat] {
        let font = EditorWritingMetrics.font(size: fontSize)
        let rowH = EditorWritingMetrics.rowHeight(fontSize: fontSize)
        let style = EditorWritingMetrics.paragraphStyle(fontSize: fontSize)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let constraint = CGSize(width: max(1, width), height: .greatestFiniteMagnitude)
        return lines.map { raw in
            let line = String(raw)
            guard !line.isEmpty else { return rowH }
            let rect = (line as NSString).boundingRect(
                with: constraint,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font, .paragraphStyle: style],
                context: nil
            )
            let visualLines = max(1, (rect.height / rowH).rounded())
            return visualLines * rowH
        }
    }

    static func utf16RangeForLine(_ index: Int, in text: String) -> NSRange? {
        let parts = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard index >= 0, index < parts.count else { return nil }
        var location = 0
        for (i, part) in parts.enumerated() {
            let length = (String(part) as NSString).length
            if i == index { return length == 0 ? nil : NSRange(location: location, length: length) }
            location += length + (i < parts.count - 1 ? 1 : 0)
        }
        return nil
    }

    static func syllableCount(forLine line: String) -> Int {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }
        var total = 0
        let tokenizer = trimmed.unicodeScalars
        var current = ""
        func flush() {
            let word = current.trimmingCharacters(in: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "'’")).inverted)
            if !word.isEmpty {
                total += Syllabifier.syllableCount(word: word)
            }
            current = ""
        }
        var lastKind: TokenKind = .other
        for scalar in tokenizer {
            let kind = tokenKind(scalar)
            if kind == .other {
                flush()
                lastKind = .other
                continue
            }
            if kind != lastKind && !current.isEmpty {
                flush()
            }
            current.unicodeScalars.append(scalar)
            lastKind = kind
        }
        flush()
        return total
    }
}

/// Left-gutter tiles for per-bar syllable counts.
/// One visual line → one square, as tall as that writing row.
/// A wrap is N squares stacked (same width, height = N × row) so the button
/// fills the space the sentence actually takes.
nonisolated enum SyllableCountButtonMetrics: Sendable {
    static let gutterWidth: CGFloat = 56
    static let inset: CGFloat = 4
    static let verticalInset: CGFloat = 2
    /// Finger target. Drawn tiles follow the row; hits cannot go below this.
    static let minimumHitSide: CGFloat = 44
    static var innerWidth: CGFloat { gutterWidth - inset * 2 }

    static func squareSide(rowHeight: CGFloat) -> CGFloat {
        max(1, rowHeight)
    }

    static func visualLineCount(visualHeight: CGFloat, rowHeight: CGFloat) -> Int {
        max(1, Int((max(visualHeight, rowHeight) / max(rowHeight, 1)).rounded()))
    }

    static func width(forRowHeight rowHeight: CGFloat) -> CGFloat {
        squareSide(rowHeight: rowHeight) + inset * 2
    }
    /// Common wrap lengths. Tap one to aim every bar at that count.
    static let quickSelectCounts: [Int] = [6, 7, 8, 9, 10, 11, 12, 13, 14, 16]

    static func isExactCount(_ count: Int, min: Int?, max: Int?) -> Bool {
        min == count && max == count
    }

    static func pillLabel(min: Int?, max: Int?) -> String {
        if let lo = min, let hi = max {
            return lo == hi ? "\(lo) / bar" : "\(lo)–\(hi) / bar"
        }
        if let lo = min { return "≥\(lo) / bar" }
        if let hi = max { return "≤\(hi) / bar" }
        return "Bar length"
    }

    static func size(visualHeight: CGFloat, rowHeight: CGFloat) -> CGSize {
        let side = squareSide(rowHeight: rowHeight)
        let lines = CGFloat(visualLineCount(visualHeight: visualHeight, rowHeight: rowHeight))
        return CGSize(width: side, height: side * lines)
    }

    static func frame(originY: CGFloat, visualHeight: CGFloat, rowHeight: CGFloat) -> CGRect {
        let size = size(visualHeight: visualHeight, rowHeight: rowHeight)
        return CGRect(
            x: inset,
            y: originY + verticalInset,
            width: size.width,
            height: max(rowHeight - verticalInset * 2, size.height - verticalInset * 2)
        )
    }

    /// One writing row is a square. Two visual lines is a 1×2 rectangle of two squares.
    static func isSquareLike(visualHeight: CGFloat, rowHeight: CGFloat) -> Bool {
        visualLineCount(visualHeight: visualHeight, rowHeight: rowHeight) == 1
    }

    /// Finger target centered on the drawn tile, grown to at least 44×44.
    /// Stays in the gutter so the first letters of the bar stay tappable for writing.
    static func hitFrame(for visual: CGRect) -> CGRect {
        let width = max(minimumHitSide, visual.width)
        let height = max(minimumHitSide, visual.height)
        var frame = CGRect(
            x: visual.midX - width / 2,
            y: visual.midY - height / 2,
            width: width,
            height: height
        )
        let gutter = max(gutterWidth, visual.maxX + inset)
        if frame.maxX > gutter {
            frame.origin.x = gutter - frame.width
        }
        return frame
    }

    /// When 44pt hits overlap neighboring bars, the nearest tile center wins.
    static func nearestIndex(to point: CGPoint, visualFrames: [CGRect]) -> Int? {
        var best: (Int, CGFloat)?
        for (index, visual) in visualFrames.enumerated() {
            guard hitFrame(for: visual).contains(point) else { continue }
            let dx = visual.midX - point.x
            let dy = visual.midY - point.y
            let distance = dx * dx + dy * dy
            if best == nil || distance < best!.1 {
                best = (index, distance)
            }
        }
        return best?.0
    }
}

/// Shared writing-surface type: one row height, one paragraph style, one container inset
/// for TextEditor, rhyme overlay, and the syllable gutter so they cannot drift on focus.
nonisolated enum EditorWritingMetrics: Sendable {
    static let extraLineSpacing: CGFloat = 8
    static let lineFragmentPadding: CGFloat = 5
    static let gutterNumberSize: CGFloat = 13
    /// Extra drop so the count sits with the lyric, not above it.
    static let gutterNumberDrop: CGFloat = 3

    /// In-app stepper size, scaled by iOS text size so both controls move together.
    static func resolvedPointSize(_ base: CGFloat) -> CGFloat {
        UIFontMetrics(forTextStyle: .body).scaledValue(for: base)
    }

    static func extraSpacing(fontSize: CGFloat) -> CGFloat {
        max(4, (fontSize * 0.28).rounded())
    }

    static func gutterNumberSize(for fontSize: CGFloat) -> CGFloat {
        max(11, min(18, (fontSize * 0.76).rounded()))
    }

    static func font(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size)
    }

    static func rowHeight(fontSize: CGFloat) -> CGFloat {
        font(size: fontSize).lineHeight + extraSpacing(fontSize: fontSize)
    }

    static func paragraphStyle(fontSize: CGFloat) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        let rowH = rowHeight(fontSize: fontSize)
        style.minimumLineHeight = rowH
        style.maximumLineHeight = rowH
        style.lineSpacing = 0
        return style
    }

    static func gutterBaselineOffset(fontSize: CGFloat) -> CGFloat {
        let body = font(size: fontSize)
        let gutter = UIFont.systemFont(ofSize: gutterNumberSize(for: fontSize), weight: .semibold)
        return body.ascender - gutter.ascender + gutterNumberDrop
    }

    /// Height of each newline row in `textView` coordinates, wraps included.
    /// One-line bars are one writing row; a bar that takes two visual lines is two rows tall.
    @MainActor
    static func newlineFragmentHeights(in textView: UITextView) -> [CGFloat] {
        let origins = newlineFragmentOrigins(in: textView)
        let fontSize = textView.font?.pointSize ?? 17
        let rowH = rowHeight(fontSize: fontSize)
        guard !origins.isEmpty else { return [] }

        let layout = textView.layoutManager
        layout.ensureLayout(for: textView.textContainer)
        let insetY = textView.textContainerInset.top
        let extra = layout.extraLineFragmentRect
        let endY: CGFloat
        if extra.height > 1, extra.minY > 1 {
            endY = extra.maxY + insetY
        } else if layout.numberOfGlyphs > 0 {
            let last = layout.numberOfGlyphs - 1
            endY = layout.lineFragmentRect(forGlyphAt: last, effectiveRange: nil).maxY + insetY
        } else {
            endY = origins[origins.count - 1] + rowH
        }

        return origins.indices.map { i in
            let next = (i + 1 < origins.count) ? origins[i + 1] : endY
            let raw = next - origins[i]
            return raw.isFinite && raw > 0 ? max(rowH, raw) : rowH
        }
    }

    static func typingAttributes(fontSize: CGFloat, color: UIColor) -> [NSAttributedString.Key: Any] {
        [
            .font: font(size: fontSize),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle(fontSize: fontSize)
        ]
    }

    static let lyricOverlayTag = 0x4C595243

    /// The live writing `UITextView` (shared editor mop). Used for system undo/redo.
    @MainActor
    static weak var activeTextView: UITextView?

    /// `lineFragmentRect(forGlyphAt:)` raises NSRangeException (Xcode breakpoint) when the
    /// glyph index is NSNotFound or past `numberOfGlyphs` — common on Enter before layout catches up.
    @MainActor
    private static func fragmentY(
        layout: NSLayoutManager,
        characterIndex: Int,
        nsLength: Int,
        insetY: CGFloat,
        extra: CGRect,
        useMaxY: Bool
    ) -> CGFloat {
        let glyphCount = layout.numberOfGlyphs
        guard glyphCount > 0, nsLength > 0 else {
            return extra.height > 0 ? extra.minY + insetY : insetY
        }
        let clamped = min(max(0, characterIndex), nsLength - 1)
        let glyph = layout.glyphIndexForCharacter(at: clamped)
        guard glyph >= 0, glyph < glyphCount, glyph != NSNotFound else {
            return extra.height > 0 ? extra.minY + insetY : insetY
        }
        let rect = layout.lineFragmentRect(forGlyphAt: glyph, effectiveRange: nil)
        return (useMaxY ? rect.maxY : rect.minY) + insetY
    }

    /// Y origin (in `textView` bounds) of the first visual fragment of each newline.
    /// Wrapped continuations do not get their own origin — Enter starts the next one.
    @MainActor
    static func newlineFragmentOrigins(in textView: UITextView) -> [CGFloat] {
        let ns = (textView.text ?? "") as NSString
        let layout = textView.layoutManager
        let container = textView.textContainer
        layout.ensureLayout(for: container)
        let insetY = textView.textContainerInset.top

        var starts: [Int] = [0]
        var search = 0
        while search < ns.length {
            let found = ns.range(of: "\n", options: [], range: NSRange(location: search, length: ns.length - search))
            if found.location == NSNotFound { break }
            search = found.location + 1
            starts.append(search)
        }

        return starts.map { start in
            if ns.length == 0 || start >= ns.length {
                let extra = layout.extraLineFragmentRect
                if extra.height > 0 {
                    return extra.minY + insetY
                }
                if ns.length == 0 {
                    return insetY
                }
                return fragmentY(
                    layout: layout,
                    characterIndex: ns.length - 1,
                    nsLength: ns.length,
                    insetY: insetY,
                    extra: extra,
                    useMaxY: true
                )
            }
            return fragmentY(
                layout: layout,
                characterIndex: start,
                nsLength: ns.length,
                insetY: insetY,
                extra: layout.extraLineFragmentRect,
                useMaxY: false
            )
        }
    }

    /// Y of a hairline sitting under each visual row (wraps included), in text-view coordinates.
    /// Uses the bottom of the line box so the rule lives in the extra spacing, not through glyphs.
    @MainActor
    static func visualLineUnderlineYs(in textView: UITextView) -> [CGFloat] {
        let layout = textView.layoutManager
        let container = textView.textContainer
        layout.ensureLayout(for: container)
        let insetY = textView.textContainerInset.top
        let hairline: CGFloat = 1
        var ys: [CGFloat] = []

        func appendUnderline(for rect: CGRect) {
            guard rect.height > 1, rect.maxY.isFinite else { return }
            let y = rect.maxY + insetY - hairline
            if let last = ys.last, abs(last - y) < 0.75 { return }
            ys.append(y)
        }

        let glyphCount = layout.numberOfGlyphs
        if glyphCount > 0 {
            layout.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: glyphCount)) { rect, _, _, _, _ in
                appendUnderline(for: rect)
            }
        }
        let extra = layout.extraLineFragmentRect
        // Only the caret's trailing blank row — never a phantom rule at y=0 on top of lyrics.
        if extra.height > 1, extra.minY > 1 {
            appendUnderline(for: extra)
        }
        return ys
    }

    /// Lock a writing UITextView so unfocused and focused layout stay identical.
    @MainActor
    static func lock(_ textView: UITextView, fontSize: CGFloat, restyleStorage: Bool) {
        let writingFont = font(size: fontSize)
        let style = paragraphStyle(fontSize: fontSize)
        let rowH = rowHeight(fontSize: fontSize)

        if textView.textContainer.lineFragmentPadding != lineFragmentPadding {
            textView.textContainer.lineFragmentPadding = lineFragmentPadding
        }
        if textView.textContainerInset != .zero {
            textView.textContainerInset = .zero
        }
        if textView.contentInset != .zero {
            textView.contentInset = .zero
        }
        textView.contentInsetAdjustmentBehavior = .never
        textView.isScrollEnabled = false
        textView.adjustsFontForContentSizeCategory = false
        if textView.font?.pointSize != fontSize {
            textView.font = writingFont
        }

        var typing = textView.typingAttributes
        typing[.font] = writingFont
        typing[.paragraphStyle] = style
        textView.typingAttributes = typing

        guard restyleStorage else { return }
        let length = textView.textStorage.length
        guard length > 0 else { return }
        let current = textView.textStorage.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        if current?.minimumLineHeight != rowH {
            let full = NSRange(location: 0, length: length)
            textView.textStorage.addAttribute(.paragraphStyle, value: style, range: full)
            textView.textStorage.addAttribute(.font, value: writingFont, range: full)
        }
    }
}
