import Foundation

/// Phase 1 You-tab contract: only ask what a catalog cannot fill.
/// Cards this phase are answers + identity. Titles are not bars.
nonisolated enum ArtistOnboardingContract {
    static let allowedPendingTitles: Set<String> = [
        "Name",
        "Who you're talking to",
        "Don't write like this anymore",
        "Leave out",
        ArtistIdentityIngest.cityTitle,
        ArtistIdentityIngest.bottleTitle,
        ArtistIdentityIngest.loveTitle,
        ArtistIdentityIngest.topicsTitle,
        ArtistIdentityIngest.writerTitle
    ]

    static let forbiddenPendingTitles: Set<String> = [
        "Catalog pocket",
        "Home stance",
        "Punch stays punch"
    ]

    static func neverUseTerms(from leaveOut: String) -> [String] {
        leaveOut
            .split { ",\n;".contains($0) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func isTitlePersonaClaim(_ card: ArtistBrainCard) -> Bool {
        forbiddenPendingTitles.contains(card.title)
            || card.source == "catalog" && card.title == "Catalog pocket"
    }
}
