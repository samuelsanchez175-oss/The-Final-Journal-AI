import SwiftUI
import UIKit
import Combine

// MARK: - Rhyme Highlight Text View
// File: ContentView.CCV.6.swift
// Dependencies: CCV.2 (RhymeColorPalette), CCV.3 (Highlight)
// Used by: ContentView.swift, NoteEditorView

struct RhymeHighlightTextView: UIViewRepresentable {
    let text: String
    let highlights: [Highlight]
    let isVisible: Bool // Track visibility to skip unnecessary updates when hidden
    var showFullText: Bool = true // If true, show all text; if false, only show highlighted portions
    var horizontalPadding: CGFloat = 20 // Padding to match TextEditor
    var isEditable: Bool = false // Whether the text view is editable
    var onTextChange: ((String) -> Void)? = nil // Callback for text changes

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.onTextChange = onTextChange
        return coordinator
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.isEditable = isEditable
        // CRITICAL: Allow text selection even when not editable (for copying)
        // But ensure parent ScrollView can still scroll during selection
        textView.isSelectable = true // Always allow selection for copying
        // SEGMENT 20: CRITICAL - Disable internal scroll to force full height expansion
        // This prevents the text from being trapped in a small, non-rendering window
        textView.isScrollEnabled = false // CRITICAL: Forces full height expansion
        textView.isUserInteractionEnabled = true // Always allow interaction for selection/copying

        // SEGMENT 19: Unified Padding - Match TextEditor's internal padding exactly
        // TextEditor has .padding(.horizontal, 20), so we need to account for that
        // The textContainerInset should be 0 since we're applying padding at the SwiftUI level
        // Bottom padding is now applied at ZStack level, so set to 0 here
        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 0, // No inset - padding is handled at SwiftUI level
            bottom: 0, // SEGMENT 19: Padding moved to ZStack level for consistency
            right: 0 // No inset - padding is handled at SwiftUI level
        )
        textView.textContainer.lineFragmentPadding = 0
        
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

        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label

        textView.backgroundColor = .clear
        textView.tintColor = .clear
        
        // Set delegate for text changes when editable
        if isEditable {
            textView.delegate = context.coordinator
        }
        
        // CRITICAL: Configure gesture recognizers after view is added to hierarchy
        // This allows parent ScrollView to scroll even when text is selected
        DispatchQueue.main.async {
            self.configureScrollGestureRecognizers(for: textView)
        }

        return textView
    }
    
    // CRITICAL: Helper function to configure gesture recognizers for parent scrolling
    private func configureScrollGestureRecognizers(for textView: UITextView) {
        // Find the parent ScrollView
        var parentView = textView.superview
        while parentView != nil {
            if let scrollView = parentView as? UIScrollView {
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

    func updateUIView(_ uiView: UITextView, context: Context) {
        let coordinator = context.coordinator
        let isDarkMode = uiView.traitCollection.userInterfaceStyle == .dark
        
        // SEGMENT 20: Scroll Gravity Locking - Disable internal scrolling
        // This ensures the UITextView remains a static-height element that grows with content
        // rather than a scrollable box, preventing "jump" behavior on focus
        uiView.isScrollEnabled = false
        
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
        
        // CRITICAL: Allow parent ScrollView to scroll even when text is selected
        // Configure gesture recognizers to allow parent scrolling during text selection
        // This must be done asynchronously to ensure the view hierarchy is set up
        DispatchQueue.main.async {
            self.configureScrollGestureRecognizers(for: uiView)
        }
        
        coordinator.onTextChange = onTextChange
        
        // CRITICAL: Track visibility changes - Segment 19: Total Content Capture
        let _ = coordinator.lastVisible != isVisible
        
        // Early exit optimization: Skip all work if view is hidden
        // This prevents unnecessary hash calculations and attributed string work
        if !isVisible {
            // If we're hiding the view and it was previously visible, clear the text
            // This is a visual optimization - don't rebuild attributed string when hidden
            if coordinator.lastVisible {
                uiView.attributedText = nil
                coordinator.lastVisible = false
            }
            // CRITICAL: Update layout asynchronously without affecting scroll position
            // Use a delayed update to prevent scroll jumps when toggling
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uiView.invalidateIntrinsicContentSize()
                // Don't force immediate layout - let it happen naturally to preserve scroll position
            }
            return
        }
        
        // SEGMENT 19: Total Content Capture - Step 1: MAXIMIZE BUFFER
        // Set temporary massive height to force total calculation BEFORE processing text
        let textEditorContentWidth: CGFloat = 640 // 680 - 40 (20 left + 20 right padding)
        let textWidth = uiView.bounds.width > 0 && uiView.bounds.width <= textEditorContentWidth ? uiView.bounds.width : textEditorContentWidth
        uiView.textContainer.size = CGSize(width: textWidth, height: .greatestFiniteMagnitude)
        
        // Mark as visible for next comparison
        coordinator.lastVisible = true
        
        // Optimized change detection - use hash-based comparison for efficiency
        let textHash = text.hashValue
        
        // Calculate highlights hash efficiently - only hash the essential properties
        var highlightsHasher = Hasher()
        highlightsHasher.combine(highlights.count)
        for highlight in highlights {
            // Convert range to NSRange for stable hashing (handles String.Index properly)
            let nsRange = NSRange(highlight.range, in: text)
            highlightsHasher.combine(nsRange.location)
            highlightsHasher.combine(nsRange.length)
            highlightsHasher.combine(highlight.colorIndex)
            highlightsHasher.combine(highlight.strength)
            highlightsHasher.combine(highlight.rhymeType)
        }
        let highlightsHash = highlightsHasher.finalize()
        
        let textChanged = coordinator.lastTextHash != textHash
        let highlightsChanged = coordinator.lastHighlightsHash != highlightsHash
        let darkModeChanged = coordinator.lastDarkMode != isDarkMode
        
        // Skip rebuild if nothing changed - reuse cached attributed string
        if !textChanged && !highlightsChanged && !darkModeChanged {
            // Use cached attributed string if available and text matches
            if let cachedAttributed = coordinator.cachedAttributedString,
               cachedAttributed.string == text {
                // Only update if the attributed text is actually different
                if uiView.attributedText != cachedAttributed {
                    uiView.attributedText = cachedAttributed
                }
                return
            }
            // If we don't have a cache but nothing changed, we still need to build it once
        }
        
        // Build attributed string
        // For AI text overlay, use clear color so TextEditor text shows through
        // Only AI text ranges will have blue foreground color
        // Context highlights (last 4 lines) use background color
        let isAITextOverlay = highlights.contains { $0.colorIndex == 3 && !showFullText }
        
        // CRITICAL: Ensure foreground color is explicitly set for all text
        // Use system label color that adapts to light/dark mode
        let baseTextColor = UIColor.label
        
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: isAITextOverlay ? UIColor.clear : baseTextColor
            ]
        )

        for highlight in highlights {
            // Validate range is valid before converting to NSRange to prevent crashes
            guard highlight.range.lowerBound >= text.startIndex,
                  highlight.range.upperBound <= text.endIndex,
                  highlight.range.lowerBound <= highlight.range.upperBound else {
                continue // Skip invalid ranges
            }
            
            let nsRange = NSRange(highlight.range, in: text)
            
            // Validate NSRange is valid (not out of bounds)
            guard nsRange.location != NSNotFound,
                  nsRange.location + nsRange.length <= (text as NSString).length else {
                continue // Skip invalid NSRange
            }

            // Special handling for colorIndex 3 (blue):
            // - If showFullText is true, it's a context highlight (background)
            // - If showFullText is false, it's AI text (foreground)
            if highlight.colorIndex == 3 {
                if showFullText {
                    // Context highlight (last 4 lines): use blue background color with 40% opacity
                    let blueColor = RhymeColorPalette.colors[3]
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
                let baseColor = RhymeColorPalette.colors[highlight.colorIndex]

                let opacity: CGFloat
                switch highlight.strength {
                case .perfect:
                    opacity = isDarkMode ? 0.55 : 0.30
                case .near:
                    opacity = isDarkMode ? 0.40 : 0.22
                case .slant:
                    opacity = isDarkMode ? 0.30 : 0.16
                }

                // Apply background color while preserving foreground color
                attributed.addAttribute(
                    .backgroundColor,
                    value: baseColor.withAlphaComponent(opacity),
                    range: nsRange
                )
                
                // CRITICAL: Explicitly maintain foreground color for highlighted text
                // Always set it to ensure it's not lost when applying background colors
                attributed.addAttribute(
                    .foregroundColor,
                    value: baseTextColor,
                    range: nsRange
                )
            }
        }

        // CRITICAL: Ensure text color is set on the UITextView itself as fallback
        // This prevents text from appearing black if attributed string color is lost
        // Update this every time to handle dark mode changes
        uiView.textColor = baseTextColor
        
        // CRITICAL: After applying all highlights, ensure every character has explicit foreground color
        // This fixes the issue where some text appears black at the end
        attributed.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: attributed.length), options: []) { value, range, _ in
            if value == nil {
                // If any range doesn't have foreground color, set it explicitly
                attributed.addAttribute(.foregroundColor, value: baseTextColor, range: range)
            }
        }
        
        // SEGMENT 19: Total Content Capture - Step 2: SYNCHRONOUS CALCULATION
        // Set attributed text and force engine to process all 700+ words synchronously
        // Only update attributed text if text actually changed (prevents infinite loop when editable)
        // When editable, text changes come from user input via delegate, not from this update
        if !isEditable || uiView.text != text {
            uiView.attributedText = attributed
        } else if isEditable {
            // When editable, preserve user's cursor position and only update highlights
            // Don't replace the entire attributed string as it resets cursor
            let currentText = uiView.text
            if currentText == text {
                // Text matches, just update highlights without replacing attributed string
                // This preserves cursor position
                // But still need to calculate layout for size
            }
        }
        
        // SEGMENT 19: Step 2 continued - Force synchronous layout calculation
        // This MUST happen synchronously to ensure usedRect includes ALL text
        guard let layoutManager = uiView.textContainer.layoutManager else { return }
        layoutManager.ensureLayout(for: uiView.textContainer)
        
        // SEGMENT 19: Total Content Capture - Step 3: PRECISION SIZING
        // Calculate actual used rectangle plus safety margin
        // SEGMENT 20: Increased buffer to 150pt to match ZStack padding and prevent jump on focus
        let usedRect = layoutManager.usedRect(for: uiView.textContainer)
        let writingSpaceBuffer: CGFloat = 150 // Safety margin - increased to prevent jump when cursor activates
        let finalHeight = usedRect.height + uiView.textContainerInset.top + uiView.textContainerInset.bottom + writingSpaceBuffer
        
        // SEGMENT 20: Total Content Capture - Step 4: INVALIDATION
        // Re-lock scroll gravity by invalidating intrinsic size immediately
        // This ensures the parent ScrollView doesn't assume a height of zero
        // and the text remains visible and stable during focus
        DispatchQueue.main.async {
            uiView.textContainer.size = CGSize(width: textWidth, height: finalHeight)
            // SEGMENT 20: Invalidate intrinsic size to re-lock scroll gravity
            uiView.invalidateIntrinsicContentSize() // Re-locks scroll gravity
            uiView.superview?.setNeedsLayout()
        }
            
        // Note: Layout invalidation is handled in Step 4 above
        
        // Cache the attributed string and update coordinator cache
        coordinator.cachedAttributedString = attributed.copy() as? NSAttributedString
        coordinator.lastTextHash = textHash
        coordinator.lastHighlightsHash = highlightsHash
        coordinator.lastDarkMode = isDarkMode
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var lastTextHash: Int = 0
        var lastHighlightsHash: Int = 0
        var lastDarkMode: Bool = false
        var lastVisible: Bool = false // Track visibility state
        var cachedAttributedString: NSAttributedString? = nil
        var onTextChange: ((String) -> Void)? = nil
        
        func textViewDidChange(_ textView: UITextView) {
            onTextChange?(textView.text)
        }
        
        // SEGMENT 20: Prevent automatic scroll-to-cursor when text view gains focus
        // This prevents the jump to bottom behavior when cursor activates
        func textViewDidBeginEditing(_ textView: UITextView) {
            // Prevent automatic scrolling by ensuring scroll is disabled
            textView.isScrollEnabled = false
            // Don't allow UITextView to scroll the cursor into view
            // The parent ScrollView handles all scrolling
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            // SEGMENT 20: Prevent automatic scroll-to-cursor on selection change
            // Keep scroll disabled to prevent jump behavior
            textView.isScrollEnabled = false
        }
    }
}
