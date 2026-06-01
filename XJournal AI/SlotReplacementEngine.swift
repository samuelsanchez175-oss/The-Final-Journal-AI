import Foundation
import NaturalLanguage

// MARK: - PR 13: Slot Replacement Engine (Mode B)

struct SlotReplacementEngine {
    enum SlotType: String, Codable {
        case brand
        case price
        case object
        case action
        case location
    }
    
    struct Slot: Codable {
        let type: SlotType
        let originalText: String
        let range: Range<String.Index>
        
        // Codable conformance for Range<String.Index>
        enum CodingKeys: String, CodingKey {
            case type
            case originalText
            case rangeStart
            case rangeEnd
        }
        
        init(type: SlotType, originalText: String, range: Range<String.Index>) {
            self.type = type
            self.originalText = originalText
            self.range = range
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(SlotType.self, forKey: .type)
            originalText = try container.decode(String.self, forKey: .originalText)
            // Range decoding would need string-based approach - simplified for now
            _ = try container.decode(Int.self, forKey: .rangeStart)
            _ = try container.decode(Int.self, forKey: .rangeEnd)
            // Note: This is a simplified approach - in practice, you'd store offsets
            // Create a placeholder range using the originalText's bounds
            let textStart = originalText.startIndex
            let textEnd = originalText.endIndex
            self.range = textStart..<textEnd
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(originalText, forKey: .originalText)
            // Simplified encoding
            try container.encode(0, forKey: .rangeStart)
            try container.encode(0, forKey: .rangeEnd)
        }
    }
    
    // MARK: - Skeleton Extraction
    
    /// Extract skeleton structure and slots from a bar
    static func extractSkeleton(_ bar: String) -> (skeleton: String, slots: [Slot]) {
        var skeleton = bar
        var slots: [Slot] = []
        
        // Find all slots
        let allSlots = findSlots(in: bar)
        
        // Sort slots by position (reverse order to maintain indices when replacing)
        let sortedSlots = allSlots.sorted { $0.range.lowerBound > $1.range.lowerBound }
        
        // Replace slots with placeholders (working backwards to preserve indices)
        for slot in sortedSlots {
            let placeholder = "[\(slot.type.rawValue.uppercased())]"
            let start = bar.distance(from: bar.startIndex, to: slot.range.lowerBound)
            let end = bar.distance(from: bar.startIndex, to: slot.range.upperBound)
            
            // Replace in skeleton
            let startIdx = skeleton.index(skeleton.startIndex, offsetBy: start)
            let endIdx = skeleton.index(skeleton.startIndex, offsetBy: end)
            skeleton.replaceSubrange(startIdx..<endIdx, with: placeholder)
            
            slots.append(slot)
        }
        
        return (skeleton, slots.reversed())  // Return in original order
    }
    
    private static func findSlots(in text: String) -> [Slot] {
        var slots: [Slot] = []
        
        // Find brand slots (capitalized words that are likely brands)
        slots.append(contentsOf: findBrandSlots(in: text))
        
        // Find price slots
        slots.append(contentsOf: findPriceSlots(in: text))
        
        // Find object slots (common nouns)
        slots.append(contentsOf: findObjectSlots(in: text))
        
        // Find action slots (verbs)
        slots.append(contentsOf: findActionSlots(in: text))
        
        // Find location slots
        slots.append(contentsOf: findLocationSlots(in: text))
        
        return slots
    }
    
    private static func findBrandSlots(in text: String) -> [Slot] {
        var slots: [Slot] = []
        let commonBrands = ["Gucci", "Prada", "Versace", "Louis", "Vuitton", "Dior", "Chanel", "Balenciaga", "Fendi", "Hermes", "Rolex", "AP", "Richard", "Mille", "Chrome", "Heart"]
        
        for brand in commonBrands {
            if let range = text.range(of: brand, options: .caseInsensitive) {
                slots.append(Slot(type: .brand, originalText: String(text[range]), range: range))
            }
        }
        
        return slots
    }
    
    private static func findPriceSlots(in text: String) -> [Slot] {
        var slots: [Slot] = []
        let pricePattern = #"\$?\d+[KMB]?"#
        
        if let regex = try? NSRegularExpression(pattern: pricePattern, options: []) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    slots.append(Slot(type: .price, originalText: String(text[range]), range: range))
                }
            }
        }
        
        return slots
    }
    
    private static func findObjectSlots(in text: String) -> [Slot] {
        var slots: [Slot] = []
        let commonObjects = ["car", "chain", "watch", "whip", "trunk", "hood", "Porsche", "Lamborghini", "Ferrari", "jewelry", "ring", "necklace"]
        
        for object in commonObjects {
            if let range = text.range(of: object, options: .caseInsensitive) {
                // Check if not already a brand slot
                if !slots.contains(where: { $0.range.overlaps(range) }) {
                    slots.append(Slot(type: .object, originalText: String(text[range]), range: range))
                }
            }
        }
        
        return slots
    }
    
    private static func findActionSlots(in text: String) -> [Slot] {
        var slots: [Slot] = []
        let actionVerbs = ["buy", "spend", "cop", "drop", "pull", "push", "drive", "fly", "ride"]
        
        for verb in actionVerbs {
            if let range = text.range(of: verb, options: .caseInsensitive) {
                slots.append(Slot(type: .action, originalText: String(text[range]), range: range))
            }
        }
        
        return slots
    }
    
    private static func findLocationSlots(in text: String) -> [Slot] {
        var slots: [Slot] = []
        let locationIndicators = ["in", "at", "on", "to", "from"]
        let commonLocations = ["Atlanta", "Miami", "LA", "NYC", "spot", "place", "location"]
        
        // Use NLTokenizer to find location-like phrases
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let word = String(text[tokenRange]).lowercased()
            if commonLocations.contains(word) || locationIndicators.contains(word) {
                slots.append(Slot(type: .location, originalText: String(text[tokenRange]), range: tokenRange))
            }
            return true
        }
        
        return slots
    }
    
    // MARK: - Slot Refilling
    
    /// Refill slots in skeleton using lexicon and context
    static func refillSlots(
        skeleton: String,
        slots: [Slot],
        lexicon: [LexiconTerm],
        context: NarrativeAnalysis,
        policy: GeneratorPolicy
    ) -> String {
        var result = skeleton
        
        // Sort slots by position (reverse order for replacement)
        let sortedSlots = slots.sorted { slot1, slot2 in
            let start1 = result.distance(from: result.startIndex, to: slot1.range.lowerBound)
            let start2 = result.distance(from: result.startIndex, to: slot2.range.lowerBound)
            return start1 > start2
        }
        
        for slot in sortedSlots {
            let placeholder = "[\(slot.type.rawValue.uppercased())]"
            guard let placeholderRange = result.range(of: placeholder) else { continue }
            
            let replacement = selectReplacement(
                for: slot.type,
                original: slot.originalText,
                lexicon: lexicon,
                context: context,
                policy: policy
            )
            
            result.replaceSubrange(placeholderRange, with: replacement)
        }
        
        return result
    }
    
    private static func selectReplacement(
        for type: SlotType,
        original: String,
        lexicon: [LexiconTerm],
        context: NarrativeAnalysis,
        policy: GeneratorPolicy
    ) -> String {
        switch type {
        case .brand:
            // Use lexicon brands or context themes
            let brandTerms = lexicon.filter { term in
                term.category == .luxuryList || 
                term.category == .contextualSignal ||
                term.themePrimary?.contains("fashion") == true ||
                term.themePrimary?.contains("luxury") == true
            }
            if let brand = brandTerms.randomElement()?.term {
                return brand
            }
            // Fallback to common brands
            let commonBrands = ["Gucci", "Prada", "Versace", "Dior", "Chanel"]
            return commonBrands.randomElement() ?? original
            
        case .price:
            // Generate price based on context or use common patterns
            let prices = ["50K", "100K", "200K", "500K", "1M", "2M"]
            return prices.randomElement() ?? original
            
        case .object:
            // Use lexicon objects or context entities
            let objectTerms = lexicon.filter { term in
                term.category == .luxuryList ||
                term.category == .wealthAccess ||
                term.category == .acquisition ||
                term.themePrimary?.contains("wealth") == true ||
                term.themePrimary?.contains("luxury") == true
            }
            if let object = objectTerms.randomElement()?.term {
                return object
            }
            // Fallback to common objects
            let commonObjects = ["car", "chain", "watch", "whip"]
            return commonObjects.randomElement() ?? original
            
        case .action:
            // Use policy-allowed verb classes
            let allowedActions: [String]
            if policy.allowedVerbClasses.contains(.transaction) {
                allowedActions = ["buy", "spend", "cop", "drop"]
            } else if policy.allowedVerbClasses.contains(.motion) {
                allowedActions = ["pull", "push", "drive", "fly"]
            } else {
                allowedActions = ["buy", "spend", "cop", "drop", "pull", "push"]
            }
            return allowedActions.randomElement() ?? original
            
        case .location:
            // Use context locations or common places
            if let location = context.entities.first(where: { $0.type == .place })?.value {
                return location
            }
            let commonLocations = ["Atlanta", "Miami", "LA", "NYC"]
            return commonLocations.randomElement() ?? original
        }
    }
}
