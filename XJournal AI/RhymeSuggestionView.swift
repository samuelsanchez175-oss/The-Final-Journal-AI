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
    guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
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
    static func findRhymes(for word: String, limit: Int = 8) -> [RhymeSuggestion] {
        guard let phonemes = getCMUDICTPhonemes(for: word),
              let targetSignature = extractSignature(from: phonemes) else {
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
            
            guard let wordSignature = extractSignature(from: wordPhonemes),
                  let strength = rhymeScore(targetSignature, wordSignature) else {
                continue
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


