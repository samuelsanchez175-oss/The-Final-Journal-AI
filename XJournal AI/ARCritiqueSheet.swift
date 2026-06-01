import SwiftUI

// MARK: - Critic Sheet (same Human Critic as Rap Suggestions)

struct ARCritiqueSheet: View {
    let currentText: String
    let onDismiss: () -> Void
    @Binding var feedback: HumanCriticFeedback?
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onRetry: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if !currentText.isEmpty {
                        verseSection
                    }

                    HumanCriticSectionView(
                        feedback: feedback,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                        onRetry: onRetry
                    )
                    .padding(.horizontal)

                    if !isLoading,
                       errorMessage == nil,
                       feedback == nil,
                       !currentText.isEmpty {
                        emptyPrompt
                    }
                }
                .padding(.bottom, 40)
            }
            .background(
                Rectangle()
                    .fill(Momentum.surfaceElevated)
                    .ignoresSafeArea()
            )
            .navigationTitle("Critic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
            .task {
                if feedback == nil, !isLoading, errorMessage == nil, !currentText.isEmpty {
                    onRetry()
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Critic")
                .font(.title2.weight(.bold))

            Text("Thoughtful feedback on your draft—the same listener you get with AI suggestions.")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }

    private var verseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your text")
                .font(.headline)
                .padding(.horizontal)

            Text(currentText)
                .font(.body)
                .foregroundStyle(Momentum.contentPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                )
                .padding(.horizontal)
        }
    }

    private var emptyPrompt: some View {
        Text("Generate AI suggestions first for feedback tied to a continuation, or tap Try again for feedback on this draft alone.")
            .font(.caption)
            .foregroundStyle(Momentum.contentSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
}
