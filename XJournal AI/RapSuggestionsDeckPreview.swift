//
//  RapSuggestionsDeckPreview.swift
//  XJournal AI
//
//  DEBUG-only Xcode-canvas harness for the new Rap Suggestions deck — lets us SEE the
//  deck + island + freshness flash + stack (stress) + rhyme toggle with sample lyrics,
//  without wiring anything into RapSuggestionView. Not shipped.
//

#if DEBUG
import SwiftUI

private struct RapSuggestionsDeckPreviewHarness: View {
    @State private var index = 0
    @State private var stackOn = false
    @State private var rhymeOn = false

    var body: some View {
        ZStack(alignment: .bottom) {
            RapDeckView(
                generations: Self.sampleGenerations,
                index: $index,
                stackOn: stackOn,
                rhymeOn: rhymeOn
            )
            RapIslandToolbar(
                rhymeOn: $rhymeOn,
                stackOn: $stackOn,
                rhymeGroups: [],
                currentText: Self.sampleGenerations.first?.suggestions.first?.text ?? ""
            )
            .padding(.bottom, 14)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private static func suggestion(_ text: String, moments: [Int]? = nil) -> RapSuggestion {
        RapSuggestion(
            id: UUID(), text: text, confidence: 0.9, source: nil, reasoning: nil,
            themes: ["luxury", "flex"], rhymeStrength: 0.8, flowMatch: 0.7, styleMatch: 0.75,
            userFeedback: nil, signalStrength: 0.8, signalNote: nil, arCritique: nil,
            modelGMomentLineIndices: moments
        )
    }

    static let sampleGenerations: [Generation] = [
        Generation(
            id: UUID(),
            suggestions: [suggestion(
                """
                In the club, got that fire, every time I'm performin'
                Backend just landed, all hundreds, the money keep comin'
                Birkin bag full of dead presidents, that's what I'm haulin'
                Red Bottoms on the floor, Chinchilla, that's how I'm flossin'
                """,
                moments: [1]
            )],
            critic: nil, createdAt: Date(), isFavorite: false, isFresh: true
        ),
        Generation(
            id: UUID(),
            suggestions: [suggestion(
                """
                Private terminal, first class, no ordinary walkin'
                Got the Kelly Bag next, another runway piece I'm coppin'
                Circle small, big moves, ain't no stoppin'
                """
            )],
            critic: nil, createdAt: Date(), isFavorite: false, isFresh: false
        ),
    ]
}

#Preview("Rap Suggestions deck") {
    RapSuggestionsDeckPreviewHarness()
}
#endif
