import SwiftUI
import Foundation
import NaturalLanguage

// MARK: - Local Type Definitions (to avoid type resolution issues)

private enum RhymeStrength: Double {
    case perfect = 1.0
    case near = 0.75
    case slant = 0.55
}

private struct PhoneticSignature {
    let stressedVowel: String
    let coda: [String]
}

private func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
    // Anchor on the last STRESSED vowel (CMUDICT stress marker 1 or 2), not the last vowel.
    // CMUDICT marks EVERY vowel with a stress digit (0/1/2), so the last digit-bearing phoneme is
    // often an unstressed final vowel — e.g. "crazy" K R EY1 Z IY0 → IY0 with an empty coda —
    // which over-loosens rhyme matching to bare assonance ("-y" endings). Fall back to the last
    // vowel of any stress only when none is stressed.
    // (Mirrors GhostSuggestionEngine.phoneticSignature, fixed in 558937e.)
    let stressed = phonemes.lastIndex { $0.last == "1" || $0.last == "2" }
    guard let idx = stressed ?? phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
        return nil
    }
    let vowel = phonemes[idx]
    let coda = Array(phonemes.dropFirst(idx + 1))
    return PhoneticSignature(stressedVowel: vowel, coda: coda)
}

private func rhymeScore(_ a: PhoneticSignature, _ b: PhoneticSignature) -> RhymeStrength? {
    if a.stressedVowel == b.stressedVowel && a.coda == b.coda {
        return .perfect
    }
    if a.stressedVowel == b.stressedVowel {
        return .near
    }
    // Check for slant rhyme (similar vowels)
    let baseA = String(a.stressedVowel.dropLast())
    let baseB = String(b.stressedVowel.dropLast())
    if baseA == baseB {
        return .slant
    }
    return nil
}

private func getCMUDICTPhonemes(for word: String) -> [String]? {
    return getGlobalCMUDICTStore()[word.lowercased()]
}

// MARK: - Rhyme Suggestion View (for last word)

struct RhymeSuggestionView: View {
    let rhymes: [RhymeSuggestion]
    let targetWord: String
    let onSelect: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rhymes for:")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                        
                        Text(targetWord.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Rhyme suggestions
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(rhymes) { rhyme in
                            rhymeCard(rhyme)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Suggest Rhymes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func rhymeCard(_ rhyme: RhymeSuggestion) -> some View {
        Button {
            onSelect(rhyme.word)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(rhyme.word)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    // Strength indicator
                    Circle()
                        .fill(strengthColor(rhyme.strength))
                        .frame(width: 8, height: 8)
                    
                    Text(strengthLabel(rhyme.strength))
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Momentum.surfaceElevated)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func strengthColor(_ strength: RhymeStrength) -> Color {
        switch strength {
        case .perfect:
            return .green
        case .near:
            return .blue
        case .slant:
            return .orange
        }
    }
    
    private func strengthLabel(_ strength: RhymeStrength) -> String {
        switch strength {
        case .perfect:
            return "Perfect"
        case .near:
            return "Near"
        case .slant:
            return "Slant"
        }
    }
}

// MARK: - Rhyme Suggestion

struct RhymeSuggestion: Identifiable {
    let id = UUID()
    let word: String
    fileprivate let strength: RhymeStrength
}

// MARK: - Rhyme Finder Helper

class RhymeFinder {
    /// Rhyme tier over raw CMUDICT phoneme arrays — the single rhyme classifier used by
    /// `findRhymes` and exercised directly (CMUDICT-independent) by tests.
    /// 3 = perfect (same stressed vowel + coda), 2 = near (same stressed vowel, different coda),
    /// 1 = slant (same base vowel), 0 = no rhyme.
    static func rhymeTier(_ a: [String], _ b: [String]) -> Int {
        guard let sigA = extractSignature(from: a),
              let sigB = extractSignature(from: b),
              let strength = rhymeScore(sigA, sigB) else {
            return 0
        }
        switch strength {
        case .perfect: return 3
        case .near:    return 2
        case .slant:   return 1
        }
    }

    static func findRhymes(for word: String, limit: Int = 8) -> [RhymeSuggestion] {
        guard let phonemes = getCMUDICTPhonemes(for: word),
              extractSignature(from: phonemes) != nil else {
            return []
        }

        let dict = getGlobalCMUDICTStore()
        var perfectRhymes: [RhymeSuggestion] = []
        var nearRhymes: [RhymeSuggestion] = []
        var slantRhymes: [RhymeSuggestion] = []

        for (dictWord, wordPhonemes) in dict {
            // Skip the same word
            if dictWord.lowercased() == word.lowercased() {
                continue
            }

            let strength: RhymeStrength
            switch RhymeFinder.rhymeTier(phonemes, wordPhonemes) {
            case 3:  strength = .perfect
            case 2:  strength = .near
            case 1:  strength = .slant
            default: continue
            }

            let suggestion = RhymeSuggestion(
                word: dictWord.capitalized,
                strength: strength
            )

            switch strength {
            case .perfect:
                perfectRhymes.append(suggestion)
            case .near:
                nearRhymes.append(suggestion)
            case .slant:
                slantRhymes.append(suggestion)
            }

            // Stop if we have enough perfect rhymes
            if perfectRhymes.count >= limit {
                break
            }
        }
        
        // Return perfect rhymes first, then near, then slant up to limit
        let allRhymes = perfectRhymes + nearRhymes + slantRhymes
        return Array(allRhymes.prefix(limit))
    }
}


