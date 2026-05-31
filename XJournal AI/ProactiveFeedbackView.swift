import SwiftUI

// MARK: - Proactive Feedback View
// Shows feedback prompt after user inserts a suggestion

struct ProactiveFeedbackView: View {
    let suggestion: RapSuggestion
    let context: String
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedFeedback: RapSuggestion.SuggestionFeedback? = nil
    @State private var showDetailedFeedback: Bool = false
    @State private var selectedCategories: Set<FeedbackCategory> = []
    @State private var feedbackText: String = ""
    @State private var qualityMetricFeedback: QualityMetricFeedback? = nil
    @State private var likedLineIndices: Set<Int> = []
    @State private var dislikedLineIndices: Set<Int> = []
    
    var body: some View {
        NavigationView {
            mainContent
                .background(backgroundView)
                .navigationTitle("Feedback")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Skip") {
                            onDismiss()
                        }
                    }
                }
                .sheet(isPresented: $showDetailedFeedback) {
                    detailedFeedbackSheet
                }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            headerSection
            quickFeedbackButtons
            skipButton
            Spacer()
        }
        .padding()
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "hand.thumbsup.fill")
                .font(.system(size: 48))
                .foregroundStyle(Momentum.accentCalm)

            Text("How did this suggestion work for you?")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Momentum.contentPrimary)
                .multilineTextAlignment(.center)

            Text("Your feedback helps improve future suggestions")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }
    
    private var quickFeedbackButtons: some View {
        HStack(spacing: 24) {
            likedButton
            dislikedButton
        }
        .padding(.horizontal)
    }
    
    private var likedButton: some View {
        Button {
            selectedFeedback = .liked
            recordQuickFeedback(.liked)
            onDismiss()
        } label: {
            feedbackButtonContent(
                icon: "hand.thumbsup.fill",
                text: "Liked it"
            )
        }
    }
    
    private var dislikedButton: some View {
        Button {
            selectedFeedback = .disliked
            showDetailedFeedback = true
        } label: {
            feedbackButtonContent(
                icon: "hand.thumbsdown.fill",
                text: "Needs work"
            )
        }
    }
    
    private func feedbackButtonContent(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
            Text(text)
                .font(.headline)
        }
        .foregroundStyle(Momentum.contentPrimary)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
        )
    }
    
    private var skipButton: some View {
        Button {
            onDismiss()
        } label: {
            Text("Maybe later")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .padding(.top, 8)
    }
    
    private var backgroundView: some View {
        AtmosphereGlow(calm: true)   // gentle blue accentCalm tone for the empathy/feedback prompt
    }
    
    @ViewBuilder
    private var detailedFeedbackSheet: some View {
        if selectedFeedback == .disliked {
            ContextualFeedbackView(
                suggestion: suggestion,
                contextText: context,
                selectedCategories: $selectedCategories,
                feedbackText: $feedbackText,
                qualityMetricFeedback: $qualityMetricFeedback,
                likedLineIndices: $likedLineIndices,
                dislikedLineIndices: $dislikedLineIndices,
                onSave: {
                    saveDetailedFeedback()
                },
                onDismiss: {
                    showDetailedFeedback = false
                    onDismiss()
                }
            )
        }
    }
    
    private func saveDetailedFeedback() {
        // Record detailed feedback
        SuggestionFeedbackManager.shared.recordEnhancedFeedback(
            suggestionId: suggestion.id,
            feedback: .disliked,
            suggestionText: suggestion.text,
            context: context,
            categories: Array(selectedCategories),
            specificIssues: feedbackText.isEmpty ? nil : [feedbackText],
            sessionId: UserBehaviorTracker.shared.sessionId
        )
        
        // Record quality metric feedback if provided
        if qualityMetricFeedback != nil {
            // Store quality metric corrections if needed
            // This could be used to improve future suggestions
        }
        
        showDetailedFeedback = false
        onDismiss()
    }
    
    private func recordQuickFeedback(_ feedback: RapSuggestion.SuggestionFeedback) {
        SuggestionFeedbackManager.shared.recordFeedback(
            suggestionId: suggestion.id,
            feedback: feedback,
            suggestionText: suggestion.text,
            context: context
        )
    }
}
