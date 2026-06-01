import SwiftUI
import UIKit

// MARK: - Critique Highlight Text View
// Similar to RhymeHighlightTextView but for critique highlights (green)

struct CritiqueHighlightView: UIViewRepresentable {
    let text: String
    let critiques: [LineCritique]
    let isVisible: Bool
    var horizontalPadding: CGFloat = 20
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        
        // Match TextEditor padding
        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 0,
            bottom: 0,
            right: 0
        )
        textView.textContainer.lineFragmentPadding = 0
        
        textView.textAlignment = .left
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.tintColor = .clear
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let coordinator = context.coordinator
        let isDarkMode = uiView.traitCollection.userInterfaceStyle == .dark
        
        uiView.isScrollEnabled = false
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        coordinator.onTextChange = nil
        
        // Early exit if not visible
        if !isVisible {
            if coordinator.lastVisible {
                uiView.attributedText = nil
                coordinator.lastVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uiView.invalidateIntrinsicContentSize()
            }
            return
        }
        
        coordinator.lastVisible = true
        
        // Optimized change detection
        let textHash = text.hashValue
        
        var critiquesHasher = Hasher()
        critiquesHasher.combine(critiques.count)
        for critique in critiques {
            let nsRange = NSRange(critique.lineRange, in: text)
            critiquesHasher.combine(nsRange.location)
            critiquesHasher.combine(nsRange.length)
            critiquesHasher.combine(critique.critique)
        }
        let critiquesHash = critiquesHasher.finalize()
        
        let textChanged = coordinator.lastTextHash != textHash
        let critiquesChanged = coordinator.lastCritiquesHash != critiquesHash
        let darkModeChanged = coordinator.lastDarkMode != isDarkMode
        
        // Skip rebuild if nothing changed
        if !textChanged && !critiquesChanged && !darkModeChanged {
            if let cachedAttributed = coordinator.cachedAttributedString,
               cachedAttributed.string == text {
                if uiView.attributedText != cachedAttributed {
                    uiView.attributedText = cachedAttributed
                    DispatchQueue.main.async {
                        uiView.invalidateIntrinsicContentSize()
                    }
                }
                coordinator.lastDarkMode = isDarkMode
                return
            }
        }
        
        // Build attributed string with green highlights
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: text.count))
        
        // Apply green highlights for each critique
        for critique in critiques {
            let nsRange = NSRange(critique.lineRange, in: text)
            if nsRange.location != NSNotFound && nsRange.location + nsRange.length <= text.count {
                // Green background highlight
                let greenColor = UIColor.systemGreen.withAlphaComponent(0.3)
                attributedString.addAttribute(.backgroundColor, value: greenColor, range: nsRange)
            }
        }
        
        uiView.attributedText = attributedString
        
        // Cache the attributed string
        coordinator.cachedAttributedString = attributedString
        coordinator.lastTextHash = textHash
        coordinator.lastCritiquesHash = critiquesHash
        coordinator.lastDarkMode = isDarkMode
        
        DispatchQueue.main.async {
            uiView.invalidateIntrinsicContentSize()
        }
    }
    
    class Coordinator {
        var onTextChange: ((String) -> Void)?
        var lastTextHash: Int?
        var lastCritiquesHash: Int?
        var lastDarkMode: Bool = false
        var lastVisible: Bool = false
        var cachedAttributedString: NSMutableAttributedString?
    }
}
