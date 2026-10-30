import SwiftUI
import UIKit
import Combine

/// Writing-surface UITextView whose insertion caret is thick and theme-colored.
/// Default iOS caret is 1pt and this overlay used to set `tintColor = .clear`,
/// so the blink line vanished into white lyric text.
private final class LyricCaretTextView: UITextView {
    override var canBecomeFirstResponder: Bool { isEditable }

    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        return rect
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isEditable, !isFirstResponder {
            _ = becomeFirstResponder()
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return LyricPlainText.fromPasteboard() != nil
        }
        if action == #selector(copy(_:)) || action == #selector(cut(_:)) {
            return selectedRange.length > 0
        }
        return super.canPerformAction(action, withSender: sender)
    }

    override func copy(_ sender: Any?) {
        _ = LyricPlainText.copySelection(from: self)
    }

    override func cut(_ sender: Any?) {
        guard LyricPlainText.copySelection(from: self) else { return }
        insertPlain("")
    }

    override func paste(_ sender: Any?) {
        guard let plain = LyricPlainText.fromPasteboard() else { return }
        insertPlain(plain)
    }

    /// `replace(_:withText:)` is one undoable edit. Undo puts the lyrics back
    /// to what they were before the paste.
    private func insertPlain(_ string: String) {
        guard let range = selectedTextRange else { return }
        let undo = undoManager
        undo?.beginUndoGrouping()
        replace(range, withText: string)
        undo?.endUndoGrouping()
    }
}

private enum LyricCaretStyle {
    static var color: UIColor { UIColor(Momentum.accent) }

    static func apply(to textView: UITextView) {
        textView.tintColor = color
        textView.tintAdjustmentMode = .normal
    }
}

// MARK: - Rhyme Highlight Text View
// File: ContentView.CCV.6.swift
// Dependencies: CCV.2 (RhymeColorPalette), CCV.3 (Highlight)
// Used by: ContentView.swift, NoteEditorView

struct RhymeHighlightTextView: UIViewRepresentable {
    let text: String
    let highlights: [Highlight]
    let isVisible: Bool // Track visibility to skip unnecessary updates when hidden
    /// Green setup / red punch on a paused bar. Alternate eye-button filter — not stacked on rhymes.
    var showBreathWash: Bool = false
    var showFullText: Bool = true // If true, show all text; if false, only show highlighted portions
    var horizontalPadding: CGFloat = 20 // Padding to match TextEditor
    var isEditable: Bool = false // Whether the text view is editable
    var onTextChange: ((String) -> Void)? = nil // Callback for text changes
    @Binding var dynamicHeight: CGFloat // Height binding to update SwiftUI frame
    var availableWidth: CGFloat // Real SwiftUI width from GeometryReader (not bounds.width)
    var fontSize: CGFloat = 17 // Writing-area font size; kept in lockstep with the TextEditor.
    var paintEpoch: Int = 0
    var isFocused: Binding<Bool> = .constant(false)
    var onWordTap: ((String, NSRange) -> Void)? = nil
    var onWordHoldPreview: ((String, NSRange) -> Void)? = nil
    var onWordHoldBegan: ((String, NSRange) -> Void)? = nil
    var onWordHoldEnded: ((String, NSRange) -> Void)? = nil
    var onWordHoldCancelled: (() -> Void)? = nil
    var onSelectionChange: (() -> Void)? = nil
    var onEditorDrop: (([NSItemProvider]) -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.onTextChange = onTextChange
        coordinator.isFocused = isFocused
        coordinator.onWordTap = onWordTap
        coordinator.onWordHoldPreview = onWordHoldPreview
        coordinator.onWordHoldBegan = onWordHoldBegan
        coordinator.onWordHoldEnded = onWordHoldEnded
        coordinator.onWordHoldCancelled = onWordHoldCancelled
        coordinator.onSelectionChange = onSelectionChange
        coordinator.onEditorDrop = onEditorDrop
        return coordinator
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = LyricCaretTextView()

        textView.isEditable = isEditable
        // CRITICAL: Allow text selection even when not editable (for copying)
        // But ensure parent ScrollView can still scroll during selection
        textView.isSelectable = true // Always allow selection for copying
        // SEGMENT 20: CRITICAL - Disable internal scroll to force full height expansion
        // This prevents the text from being trapped in a small, non-rendering window
        textView.isScrollEnabled = false // CRITICAL: Forces full height expansion
        textView.isUserInteractionEnabled = true // Always allow interaction for selection/copying

        textView.tag = EditorWritingMetrics.lyricOverlayTag
        EditorWritingMetrics.activeTextView = textView
        EditorWritingMetrics.lock(textView, fontSize: fontSize, restyleStorage: false)
        
        // Ensure text aligns to left edge (not centered)
        textView.textAlignment = .left
        
        // CRITICAL: Enable text wrapping to prevent horizontal overflow
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0 // Unlimited lines
        // Container size is automatically managed when widthTracksTextView is true
        
        // Ensure text wraps within bounds - prevent horizontal scrolling
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        // SEGMENT 20: Lock Vertical Rigidity - Required compression resistance
        // By forcing the text container to report a required vertical priority,
        // you ensure that the text surface remains the "star of the show" and does not
        // wrap or shorten when the keyboard island appears
        textView.setContentCompressionResistancePriority(.required, for: .vertical) // Resists compression (1000)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical) // Allows expansion (defaultLow hugging)

        textView.font = EditorWritingMetrics.font(size: fontSize)
        textView.adjustsFontForContentSizeCategory = false
        textView.textColor = .label
        textView.typingAttributes = EditorWritingMetrics.typingAttributes(fontSize: fontSize, color: .label)

        textView.backgroundColor = .clear
        LyricCaretStyle.apply(to: textView)
        
        // Set delegate for text changes when editable
        if isEditable {
            textView.delegate = context.coordinator
        }

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleWordTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delaysTouchesBegan = false
        tap.delaysTouchesEnded = false
        tap.delegate = context.coordinator
        textView.addGestureRecognizer(tap)
        // Backup for the clipboard button. The menu opens when the finger
        // lifts, so the press ending does not dismiss it.
        let hold = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleWordHold(_:)))
        hold.minimumPressDuration = 0.45
        hold.allowableMovement = 64
        hold.cancelsTouchesInView = false
        hold.delaysTouchesBegan = false
        hold.delaysTouchesEnded = false
        hold.delegate = context.coordinator
        textView.addGestureRecognizer(hold)
        let editMenu = UIEditMenuInteraction(delegate: context.coordinator)
        textView.addInteraction(editMenu)
        context.coordinator.editMenuInteraction = editMenu
        context.coordinator.tapRecognizer = tap
        context.coordinator.holdRecognizer = hold
        textView.textDropDelegate = context.coordinator
        textView.addInteraction(UIDropInteraction(delegate: context.coordinator))
        
        // CRITICAL: Configure gesture recognizers after view is added to hierarchy
        // This allows parent ScrollView to scroll even when text is selected
        DispatchQueue.main.async {
            self.configureScrollGestureRecognizers(for: textView)
        }

        return textView
    }

    static func dismantleUIView(_ uiView: UITextView, coordinator: Coordinator) {
        if EditorWritingMetrics.activeTextView === uiView {
            EditorWritingMetrics.activeTextView = nil
        }
    }
    
    // CRITICAL: Helper function to configure gesture recognizers for parent scrolling
    private func configureScrollGestureRecognizers(for textView: UITextView) {
        // Find the parent ScrollView
        var parentView = textView.superview
        while parentView != nil {
            if let scrollView = parentView as? UIScrollView {
                scrollView.delaysContentTouches = false
                // Configure UITextView's pan gesture to work with parent ScrollView
                for gesture in textView.gestureRecognizers ?? [] {
                    if let panGesture = gesture as? UIPanGestureRecognizer {
                        // Make UITextView's pan gesture require parent ScrollView's pan to fail
                        // This allows parent scrolling to take priority
                        panGesture.require(toFail: scrollView.panGestureRecognizer)
                        // Don't cancel touches in view to allow parent to handle them
                        panGesture.cancelsTouchesInView = false
                    }
                }
                break
            }
            parentView = parentView?.superview
        }
    }

    /// Highlight repaints must not become undo steps, or Undo after a paste
    /// restores the colored string instead of the lyrics from before the paste.
    /// `enableUndoRegistration` throws if registration is already on, and a
    /// storage replace can turn it back on itself.
    private func replaceStoragePreservingUndo(_ textView: UITextView, with attributed: NSAttributedString) {
        guard textView.window != nil, let undo = textView.undoManager else {
            textView.textStorage.setAttributedString(attributed)
            return
        }
        let shouldRestore = undo.isUndoRegistrationEnabled
        if shouldRestore {
            undo.disableUndoRegistration()
        }
        textView.textStorage.setAttributedString(attributed)
        if shouldRestore, undo.isUndoRegistrationEnabled == false {
            undo.enableUndoRegistration()
        }
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let coordinator = context.coordinator
        let isDarkMode = uiView.traitCollection.userInterfaceStyle == .dark
        
        // Preserve scroll position and selection to avoid "jump"
        let oldOffset = uiView.contentOffset
        let oldSelected = uiView.selectedRange
        syncFocus(uiView)
        
        // SEGMENT 20: Scroll Gravity Locking - Disable internal scrolling
        // This ensures the UITextView remains a static-height element that grows with content
        // rather than a scrollable box, preventing "jump" behavior on focus
        uiView.isScrollEnabled = false
        EditorWritingMetrics.activeTextView = uiView
        let fontChanged = coordinator.lastFontSize != fontSize
        EditorWritingMetrics.lock(uiView, fontSize: fontSize, restyleStorage: fontChanged)
        
        // SEGMENT 20: Vertical Rigidity - Set required compression resistance
        // This locks the vertical height calculation, preventing "respiration" that causes viewport shift
        // when the cursor activates
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        // Update delegate and interaction settings
        uiView.delegate = isEditable ? coordinator : nil
        uiView.isEditable = isEditable
        // CRITICAL: Always allow text selection for copying, even when not editable
        uiView.isSelectable = true
        uiView.isUserInteractionEnabled = true // Always allow interaction for selection/copying
        
        if !coordinator.didConfigureParentScroll {
            coordinator.didConfigureParentScroll = true
            DispatchQueue.main.async {
                self.configureScrollGestureRecognizers(for: uiView)
            }
        }
        
        coordinator.onTextChange = onTextChange
        coordinator.isFocused = isFocused
        coordinator.onWordTap = onWordTap
        coordinator.onWordHoldPreview = onWordHoldPreview
        coordinator.onWordHoldBegan = onWordHoldBegan
        coordinator.onWordHoldEnded = onWordHoldEnded
        coordinator.onWordHoldCancelled = onWordHoldCancelled
        coordinator.onSelectionChange = onSelectionChange
        coordinator.onEditorDrop = onEditorDrop
        if coordinator.editMenuInteraction == nil {
            let editMenu = UIEditMenuInteraction(delegate: coordinator)
            uiView.addInteraction(editMenu)
            coordinator.editMenuInteraction = editMenu
        }
        coordinator.claimEditMenuLongPress(on: uiView)
        
        let visibilityChanged = coordinator.lastVisible != isVisible
        let breathChanged = coordinator.lastBreathWash != showBreathWash
        let hasHoldPulse = highlights.contains {
            $0.rhymeType == .holdPulseYellow || $0.rhymeType == .holdPulseGreen
        }
        let paintHighlights = isVisible || showBreathWash || hasHoldPulse

        // Paint off and no hold pulse: still the editor (plain text). Tap-to-rhyme stays alive.
        if !paintHighlights {
            uiView.isEditable = isEditable
            uiView.delegate = isEditable ? coordinator : nil
            uiView.textColor = .label
            if fontChanged || uiView.text != text {
                UIView.performWithoutAnimation {
                    let selected = uiView.selectedRange
                    replaceStoragePreservingUndo(
                        uiView,
                        with: NSAttributedString(
                            string: text,
                            attributes: EditorWritingMetrics.typingAttributes(fontSize: fontSize, color: .label)
                        )
                    )
                    let maxLoc = (text as NSString).length
                    if selected.location >= 0, selected.location + selected.length <= maxLoc {
                        uiView.selectedRange = selected
                    }
                }
            }
            coordinator.lastVisible = false
            coordinator.lastBreathWash = false
            coordinator.lastFontSize = fontSize
            DispatchQueue.main.async {
                let w = max(10, self.availableWidth)
                let size = uiView.sizeThatFits(CGSize(width: w, height: .greatestFiniteMagnitude))
                if abs(self.dynamicHeight - size.height) > 0.5 {
                    self.dynamicHeight = size.height
                }
            }
            return
        }

        coordinator.lastVisible = isVisible
        coordinator.lastBreathWash = showBreathWash
        
        // fontChanged was computed before lock() so we don't miss size changes
        // that lock() already wrote onto uiView.font.

        // Optimized change detection - use hash-based comparison for efficiency
        let textHash = text.hashValue
        
        // Calculate highlights hash efficiently - only hash the essential properties
        var highlightsHasher = Hasher()
        highlightsHasher.combine(highlights.count)
        for highlight in highlights {
            highlightsHasher.combine(highlight.utf16.location)
            highlightsHasher.combine(highlight.utf16.length)
            highlightsHasher.combine(highlight.colorIndex)
            if let heat = highlight.heat { highlightsHasher.combine(Double(heat)) }
            highlightsHasher.combine(highlight.strength)
            highlightsHasher.combine(highlight.rhymeType)
        }
        let highlightsHash = highlightsHasher.finalize()
        
        let textChanged = coordinator.lastTextHash != textHash
        let highlightsChanged = coordinator.lastHighlightsHash != highlightsHash
        let darkModeChanged = coordinator.lastDarkMode != isDarkMode
        let paintEpochChanged = coordinator.lastPaintEpoch != paintEpoch
        let pulseOnly = !textChanged && !fontChanged && !visibilityChanged && !breathChanged && !darkModeChanged && !paintEpochChanged && highlightsChanged

        // Finger-down yellow: paint pulse on the last stable string. Skip a full rhyme rebuild
        // and skip height measurement so the editor does not jump.
        if pulseOnly, let stable = coordinator.stableAttributedString, stable.string == text {
            let painted = NSMutableAttributedString(attributedString: stable)
            applyHoldPulse(to: painted, highlights: highlights, text: text, isDarkMode: isDarkMode, baseTextColor: UIColor.label)
            UIView.performWithoutAnimation {
                let selected = uiView.selectedRange
                replaceStoragePreservingUndo(uiView, with: painted)
                let maxLoc = painted.length
                if selected.location >= 0, selected.location + selected.length <= maxLoc {
                    uiView.selectedRange = selected
                }
                uiView.contentOffset = oldOffset
            }
            coordinator.cachedAttributedString = painted
            coordinator.lastHighlightsHash = highlightsHash
            return
        }

        // Skip rebuild if nothing changed - reuse cached attributed string
        if !textChanged && !highlightsChanged && !darkModeChanged && !fontChanged && !paintEpochChanged && !visibilityChanged && !breathChanged {
            // Use cached attributed string if available and text matches
            if let cachedAttributed = coordinator.cachedAttributedString,
               cachedAttributed.string == text {
                // Only update if the attributed text is actually different
                if uiView.attributedText != cachedAttributed {
                    replaceStoragePreservingUndo(uiView, with: cachedAttributed)
                }
                return
            }
            // If we don't have a cache but nothing changed, we still need to build it once
        }
        
        // Build attributed string with consistent font and paragraph style
        // Always use the same base font and paragraph style regardless of highlight state
        let baseFont = EditorWritingMetrics.font(size: fontSize)
        let paragraph = EditorWritingMetrics.paragraphStyle(fontSize: fontSize)
        
        // CRITICAL: Ensure foreground color is explicitly set for all text
        // Use system label color that adapts to light/dark mode
        let baseTextColor = UIColor.label
        
        // For AI text overlay, use clear color so TextEditor text shows through
        // Only AI text ranges will have blue foreground color
        // Context highlights (last 4 lines) use background color
        let isAITextOverlay = isVisible && highlights.contains { $0.colorIndex == 3 && !showFullText }
        
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: baseFont,
                .foregroundColor: isAITextOverlay ? UIColor.clear : baseTextColor,
                .paragraphStyle: paragraph
            ]
        )

        if showBreathWash {
            paintBreathWashes(on: attributed, text: text, isDarkMode: isDarkMode)
        }

        // Rhyme colors follow the eye. Hold-pulse yellow/green is applied after, on top.
        // End rhymes paint first so overlapping internals skip already-washed ranges.
        if isVisible {
            let paintHighlights = highlights.filter { $0.rhymeType != .internalRhyme }
                + highlights.filter { $0.rhymeType == .internalRhyme }
            var paintedUTF16 = IndexSet()
            for highlight in paintHighlights {
                if highlight.rhymeType == .holdPulseYellow || highlight.rhymeType == .holdPulseGreen {
                    continue
                }
                let nsRange = highlight.utf16
                guard nsRange.location != NSNotFound,
                      nsRange.length > 0,
                      nsRange.location + nsRange.length <= attributed.length else {
                    continue
                }

                if let heat = highlight.heat {
                    let wash = CraftHeatPalette.uiColor(heat)
                    let opacity: CGFloat = isDarkMode ? 0.62 : 0.42
                    attributed.addAttribute(
                        .backgroundColor,
                        value: wash.withAlphaComponent(opacity),
                        range: nsRange
                    )
                    attributed.addAttribute(.foregroundColor, value: baseTextColor, range: nsRange)
                    continue
                }

                if highlight.rhymeType == .geniusEcho {
                    let green = UIColor.systemGreen
                    let opacity: CGFloat = isDarkMode ? 0.42 : 0.28
                    attributed.addAttribute(
                        .backgroundColor,
                        value: green.withAlphaComponent(opacity),
                        range: nsRange
                    )
                    attributed.addAttribute(.foregroundColor, value: baseTextColor, range: nsRange)
                    continue
                }

                // Special handling for colorIndex 3 (blue):
                // - If showFullText is true, it's a context highlight (background)
                // - If showFullText is false, it's AI text (foreground)
                if highlight.colorIndex == 3 {
                    if showFullText {
                        // Context highlight (last 4 lines): use blue background color with 40% opacity
                        let blueColor = RhymeColorPalette.color(at: 3)
                        let opacity: CGFloat = 0.4 // Fixed 40% opacity as requested
                        attributed.addAttribute(
                            .backgroundColor,
                            value: blueColor.withAlphaComponent(opacity),
                            range: nsRange
                        )
                    } else {
                        // AI-generated text: use blue foreground color
                        let blueColor = UIColor.systemBlue
                        attributed.addAttribute(
                            .foregroundColor,
                            value: blueColor,
                            range: nsRange
                        )
                    }
                } else {
                    // Regular rhyme highlighting: use background color
                    // CRITICAL: Ensure foreground color is maintained when applying background
                    let isInternal = highlight.rhymeType == .internalRhyme
                    let utf16Range = nsRange.location..<(nsRange.location + nsRange.length)
                    if isInternal, paintedUTF16.intersects(integersIn: utf16Range) {
                        continue
                    }
                    let baseColor = RhymeColorPalette.color(at: highlight.colorIndex)

                    let endOpacity: CGFloat
                    switch highlight.strength {
                    case .perfect:
                        endOpacity = isDarkMode ? 0.55 : 0.30
                    case .near:
                        endOpacity = isDarkMode ? 0.40 : 0.22
                    case .slant:
                        endOpacity = isDarkMode ? 0.30 : 0.16
                    case .assonance:
                        endOpacity = isDarkMode ? 0.20 : 0.11
                    }
                    // Internals: same family color, ~60% of the end-rhyme wash, plus underline.
                    let opacity = isInternal ? endOpacity * 0.60 : endOpacity

                    // Apply background color while preserving foreground color
                    attributed.addAttribute(
                        .backgroundColor,
                        value: baseColor.withAlphaComponent(opacity),
                        range: nsRange
                    )
                    if isInternal {
                        attributed.addAttribute(
                            .underlineStyle,
                            value: NSUnderlineStyle.single.rawValue,
                            range: nsRange
                        )
                        attributed.addAttribute(
                            .underlineColor,
                            value: baseColor,
                            range: nsRange
                        )
                    }
                    paintedUTF16.insert(integersIn: utf16Range)
                    
                    // CRITICAL: Explicitly maintain foreground color for highlighted text
                    // Always set it to ensure it's not lost when applying background colors
                    attributed.addAttribute(
                        .foregroundColor,
                        value: baseTextColor,
                        range: nsRange
                    )
                }
            }
        }

        coordinator.stableAttributedString = attributed.copy() as? NSAttributedString
        applyHoldPulse(
            to: attributed,
            highlights: highlights,
            text: text,
            isDarkMode: isDarkMode,
            baseTextColor: baseTextColor
        )

        // CRITICAL: Ensure text color is set on the UITextView itself as fallback
        // This prevents text from appearing black if attributed string color is lost
        // Update this every time to handle dark mode changes
        uiView.textColor = baseTextColor
        LyricCaretStyle.apply(to: uiView)
        
        // CRITICAL: After applying all highlights, ensure every character has explicit foreground color
        // This fixes the issue where some text appears black at the end
        attributed.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: attributed.length), options: []) { value, range, _ in
            if value == nil {
                // If any range doesn't have foreground color, set it explicitly
                attributed.addAttribute(.foregroundColor, value: baseTextColor, range: range)
            }
        }
        
        // Update in-place (reduces layout thrash vs replacing the view)
        // Preserve scroll position and selection, use performWithoutAnimation to prevent layout thrash
        UIView.performWithoutAnimation {
            let selected = uiView.selectedRange
            // Always paint highlight changes (hold yellow/green). Skipping this while
            // editable left the pulse invisible until some later text change.
            replaceStoragePreservingUndo(uiView, with: attributed)
            let maxLoc = attributed.length
            if selected.location >= 0, selected.location + selected.length <= maxLoc {
                uiView.selectedRange = selected
            } else {
                uiView.selectedRange = oldSelected.location + oldSelected.length <= maxLoc ? oldSelected : NSRange(location: maxLoc, length: 0)
            }
            uiView.contentOffset = oldOffset
            uiView.layoutIfNeeded()
        }
        
        // Recompute height using the current width from GeometryReader
        // Force layout before measuring to ensure wrapping is finalized
        DispatchQueue.main.async {
            // Use availableWidth from GeometryReader (not bounds.width which can be 0 on first layout)
            let w = max(10, self.availableWidth)
            
            // Force layout before measuring
            guard let layoutManager = uiView.textContainer.layoutManager else { return }
            layoutManager.ensureLayout(for: uiView.textContainer)
            
            // Compute height using sizeThatFits with the stable width
            let size = uiView.sizeThatFits(CGSize(width: w, height: .greatestFiniteMagnitude))
            
            // Only update if the difference is significant (> 0.5pt) to avoid infinite update loops
            if abs(self.dynamicHeight - size.height) > 0.5 {
                self.dynamicHeight = size.height
            }
        }
        
        // Cache the attributed string and update coordinator cache
        coordinator.cachedAttributedString = attributed.copy() as? NSAttributedString
        coordinator.lastTextHash = textHash
        coordinator.lastHighlightsHash = highlightsHash
        coordinator.lastDarkMode = isDarkMode
        coordinator.lastPaintEpoch = paintEpoch
        coordinator.lastHighlightCount = highlights.count
        coordinator.lastFontSize = fontSize
    }

    private func syncFocus(_ uiView: UITextView) {
        // Only pull focus ON. Resigning here races with tap-to-edit and kills the keyboard.
        guard isFocused.wrappedValue, !uiView.isFirstResponder else { return }
        DispatchQueue.main.async {
            guard self.isFocused.wrappedValue, !uiView.isFirstResponder else { return }
            uiView.becomeFirstResponder()
        }
    }

    private func paintBreathWashes(
        on attributed: NSMutableAttributedString,
        text: String,
        isDarkMode: Bool
    ) {
        let setupFill = UIColor.systemGreen.withAlphaComponent(isDarkMode ? 0.28 : 0.18)
        let punchFill = UIColor.systemRed.withAlphaComponent(isDarkMode ? 0.28 : 0.16)
        for span in LyricClause.washes(in: text) {
            let range = span.utf16
            guard range.location != NSNotFound,
                  range.length > 0,
                  range.location + range.length <= attributed.length else { continue }
            let fill = span.wash == .setup ? setupFill : punchFill
            attributed.addAttribute(.backgroundColor, value: fill, range: range)
        }
    }

    private func applyHoldPulse(
        to attributed: NSMutableAttributedString,
        highlights: [Highlight],
        text: String,
        isDarkMode: Bool,
        baseTextColor: UIColor
    ) {
        for highlight in highlights {
            guard highlight.rhymeType == .holdPulseYellow || highlight.rhymeType == .holdPulseGreen else { continue }
            let nsRange = highlight.utf16
            guard nsRange.location != NSNotFound,
                  nsRange.length > 0,
                  nsRange.location + nsRange.length <= attributed.length else { continue }
            if highlight.rhymeType == .holdPulseGreen {
                attributed.addAttribute(
                    .backgroundColor,
                    value: UIColor.systemGreen.withAlphaComponent(isDarkMode ? 0.62 : 0.50),
                    range: nsRange
                )
            } else {
                attributed.addAttribute(
                    .backgroundColor,
                    value: UIColor.systemYellow.withAlphaComponent(isDarkMode ? 0.65 : 0.52),
                    range: nsRange
                )
            }
            attributed.addAttribute(.foregroundColor, value: baseTextColor, range: nsRange)
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate, UITextDropDelegate, UIDropInteractionDelegate, UIEditMenuInteractionDelegate {
        var lastTextHash: Int = 0
        var lastHighlightsHash: Int = 0
        var lastDarkMode: Bool = false
        var lastVisible: Bool = false // Track visibility state
        var lastBreathWash: Bool = false
        var lastHighlightCount: Int = 0
        var lastPaintEpoch: Int = 0
        var lastFontSize: CGFloat = 0
        var didConfigureParentScroll = false
        var cachedAttributedString: NSAttributedString? = nil
        var stableAttributedString: NSAttributedString? = nil
        var onTextChange: ((String) -> Void)? = nil
        var isFocused: Binding<Bool> = .constant(false)
        var onWordTap: ((String, NSRange) -> Void)? = nil
        var onWordHoldPreview: ((String, NSRange) -> Void)? = nil
        var onWordHoldBegan: ((String, NSRange) -> Void)? = nil
        var onWordHoldEnded: ((String, NSRange) -> Void)? = nil
        var onWordHoldCancelled: (() -> Void)? = nil
        var onSelectionChange: (() -> Void)? = nil
        var onEditorDrop: (([NSItemProvider]) -> Void)?
        weak var editMenuInteraction: UIEditMenuInteraction?
        var lastReportedSelection: NSRange?
        weak var tapRecognizer: UITapGestureRecognizer?
        weak var holdRecognizer: UILongPressGestureRecognizer?
        var holdMenuPoint: CGPoint?
        private var claimedEditMenuPresses: Set<ObjectIdentifier> = []

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        /// Other long-presses on the text view wait. If this press succeeds,
        /// they do not run, so the edit menu is the long-press.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            gestureRecognizer === holdRecognizer
                && otherGestureRecognizer !== holdRecognizer
                && otherGestureRecognizer is UILongPressGestureRecognizer
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard gestureRecognizer === tapRecognizer,
                  let textView = gestureRecognizer.view as? UITextView else {
                return true
            }
            return Self.word(at: touch.location(in: textView), in: textView) != nil
        }

        /// UITextView adds its own long-press after this view is on screen.
        /// That press has to wait, or it swallows Copy / Paste / Select All.
        func claimEditMenuLongPress(on textView: UITextView) {
            guard let hold = holdRecognizer else { return }
            for case let other as UILongPressGestureRecognizer in textView.gestureRecognizers ?? [] {
                guard other !== hold else { continue }
                let id = ObjectIdentifier(other)
                guard claimedEditMenuPresses.insert(id).inserted else { continue }
                other.require(toFail: hold)
            }
        }

        /// Long-press anywhere presents Copy / Paste / Select All. The writing
        /// surface does not scroll, so UITextView never shows that menu itself.
        /// The menu opens when the finger lifts, so the press ending does not dismiss it.
        @objc func handleWordHold(_ gesture: UILongPressGestureRecognizer) {
            guard let textView = gesture.view as? UITextView else { return }
            if gesture.state == .began {
                let point = gesture.location(in: textView)
                holdMenuPoint = point
                if !textView.isFirstResponder {
                    _ = textView.becomeFirstResponder()
                    isFocused.wrappedValue = true
                }
                if textView.selectedRange.length == 0,
                   let position = textView.closestPosition(to: point),
                   let caret = textView.textRange(from: position, to: position) {
                    textView.selectedTextRange = caret
                }
                return
            }
            guard gesture.state == .ended else { return }
            let point = holdMenuPoint ?? gesture.location(in: textView)
            holdMenuPoint = nil
            presentEditMenu(on: textView, at: point)
        }

        private func presentEditMenu(on textView: UITextView, at point: CGPoint) {
            DispatchQueue.main.async { [weak self, weak textView] in
                guard let self, let textView, textView.window != nil else { return }
                if !textView.isFirstResponder {
                    _ = textView.becomeFirstResponder()
                }
                let config = UIEditMenuConfiguration(identifier: nil, sourcePoint: point)
                self.editMenuInteraction?.presentEditMenu(with: config)
            }
        }

        func editMenuInteraction(
            _ interaction: UIEditMenuInteraction,
            menuFor configuration: UIEditMenuConfiguration,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu? {
            guard let textView = interaction.view as? UITextView else {
                return UIMenu(children: suggestedActions)
            }
            let storage = (textView.text ?? "") as NSString
            let selected = textView.selectedRange
            let hasSelection = selected.length > 0
                && selected.location != NSNotFound
                && selected.location + selected.length <= storage.length
            var actions: [UIMenuElement] = []
            if hasSelection {
                actions.append(UIAction(title: "Cut") { [weak textView] _ in
                    textView?.cut(nil)
                })
                actions.append(UIAction(title: "Copy") { [weak textView] _ in
                    textView?.copy(nil)
                })
            } else if storage.length > 0 {
                actions.append(UIAction(title: "Cut line") { _ in
                    EditorClipboard.cut()
                })
                actions.append(UIAction(title: "Copy line") { _ in
                    EditorClipboard.copy()
                })
            }
            if LyricPlainText.fromPasteboard() != nil {
                actions.append(UIAction(title: "Paste") { [weak textView] _ in
                    textView?.paste(nil)
                })
            }
            let caret = selected.location == NSNotFound ? 0 : selected.location
            if LyricPlainText.wordRange(in: storage, caret: caret) != nil {
                actions.append(UIAction(title: "Select word") { [weak self, weak textView] _ in
                    EditorClipboard.selectWord()
                    guard let textView else { return }
                    self?.presentEditMenu(on: textView, at: CGPoint(x: textView.bounds.midX, y: 28))
                })
            }
            if LyricPlainText.lineRange(in: storage, caret: caret).length > 0 {
                actions.append(UIAction(title: "Select line") { [weak self, weak textView] _ in
                    EditorClipboard.selectLine()
                    guard let textView else { return }
                    self?.presentEditMenu(on: textView, at: CGPoint(x: textView.bounds.midX, y: 28))
                })
            }
            // Title stays "Select All": EditorPasteAudioUITests looks for that item, then Copy.
            if storage.length > 0, selected.length < storage.length {
                actions.append(UIAction(title: "Select All") { [weak self, weak textView] _ in
                    guard let textView else { return }
                    textView.selectAll(nil)
                    self?.presentEditMenu(on: textView, at: CGPoint(x: textView.bounds.midX, y: 28))
                })
            }
            if actions.isEmpty, !suggestedActions.isEmpty {
                return UIMenu(children: suggestedActions)
            }
            return UIMenu(children: actions)
        }

        /// Only the glyph the finger is actually on — `closestPosition` was snapping to
        /// neighboring words and making every gap a rhyme target.
        static func word(at point: CGPoint, in textView: UITextView) -> (word: String, range: NSRange)? {
            let layout = textView.layoutManager
            let container = textView.textContainer
            let glyphRange = layout.glyphRange(for: container)
            guard glyphRange.length > 0 else { return nil }

            let location = CGPoint(
                x: point.x - textView.textContainerInset.left,
                y: point.y - textView.textContainerInset.top
            )
            var fraction: CGFloat = 0
            let glyphIndex = layout.glyphIndex(for: location, in: container, fractionOfDistanceThroughGlyph: &fraction)
            guard glyphIndex != NSNotFound,
                  glyphIndex >= glyphRange.location,
                  glyphIndex < NSMaxRange(glyphRange) else { return nil }
            let glyphRect = layout.boundingRect(
                forGlyphRange: NSRange(location: glyphIndex, length: 1),
                in: container
            )
            guard glyphRect.insetBy(dx: -3, dy: -3).contains(location) else { return nil }

            let charIndex = layout.characterIndexForGlyph(at: glyphIndex)
            let ns = (textView.text ?? "") as NSString
            guard charIndex != NSNotFound, charIndex >= 0, charIndex < ns.length else { return nil }
            let unit = ns.substring(with: NSRange(location: charIndex, length: 1))
            if unit.rangeOfCharacter(from: .whitespacesAndNewlines) != nil { return nil }

            let forward = UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)
            let backward = UITextDirection(rawValue: UITextStorageDirection.backward.rawValue)
            guard let pos = textView.position(from: textView.beginningOfDocument, offset: charIndex),
                  let range = textView.tokenizer.rangeEnclosingPosition(pos, with: .word, inDirection: forward)
                    ?? textView.tokenizer.rangeEnclosingPosition(pos, with: .word, inDirection: backward),
                  let word = textView.text(in: range)
            else { return nil }
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
            guard cleaned.count >= 2 else { return nil }
            let start = textView.offset(from: textView.beginningOfDocument, to: range.start)
            let length = textView.offset(from: range.start, to: range.end)
            return (word, NSRange(location: start, length: length))
        }

        @objc func handleWordTap(_ gesture: UITapGestureRecognizer) {
            guard let textView = gesture.view as? UITextView else { return }
            if textView.isEditable, !textView.isFirstResponder {
                textView.becomeFirstResponder()
                isFocused.wrappedValue = true
            }
            guard let hit = Self.word(at: gesture.location(in: textView), in: textView) else { return }
            onWordTap?(hit.word, hit.range)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            onTextChange?(textView.text)
        }
        
        // SEGMENT 20: Prevent automatic scroll-to-cursor when text view gains focus
        // This prevents the jump to bottom behavior when cursor activates
        func textViewDidBeginEditing(_ textView: UITextView) {
            // Prevent automatic scrolling by ensuring scroll is disabled
            textView.isScrollEnabled = false
            if !isFocused.wrappedValue {
                isFocused.wrappedValue = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            textView.isScrollEnabled = false
            if isFocused.wrappedValue {
                isFocused.wrappedValue = false
            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            // SEGMENT 20: Prevent automatic scroll-to-cursor on selection change
            // Keep scroll disabled to prevent jump behavior
            textView.isScrollEnabled = false
            let range = textView.selectedRange
            let changed = lastReportedSelection.map {
                $0.location != range.location || $0.length != range.length
            } ?? true
            lastReportedSelection = range
            guard textView.isFirstResponder, changed else { return }
            onSelectionChange?()
        }

        func textDroppableView(_ textDroppableView: UIView & UITextDroppable, proposalForDrop drop: UITextDropRequest) -> UITextDropProposal {
            UITextDropProposal(operation: .cancel)
        }

        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            true
        }

        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            UIDropProposal(operation: .copy)
        }

        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            onEditorDrop?(session.items.map(\.itemProvider))
        }
    }
}
