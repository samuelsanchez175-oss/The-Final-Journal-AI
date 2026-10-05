import SwiftUI

/// Tappable Bar hits error. Token errors open a Genius Client Access Token field,
/// check it, then save and dismiss if it works.
struct RemindsMeOfErrorCard: View {
    let issue: RemindsMeOfSearchIssue
    var onRetry: () -> Void
    var onTokenSaved: () -> Void

    @State private var isExpanded = false
    @State private var token = ""
    @State private var phase: Phase = .idle
    @State private var failCopy: String?

    private enum Phase: Equatable {
        case idle
        case checking
        case failed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeOut(duration: 0.18)) { isExpanded.toggle() }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: issue.showsTokenField ? "key.fill" : "exclamationmark.circle")
                        .foregroundStyle(Momentum.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(issue.headline)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Momentum.contentPrimary)
                            .multilineTextAlignment(.leading)
                        if !isExpanded {
                            Text(issue.tapPrompt)
                                .font(.caption)
                                .foregroundStyle(Momentum.contentSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Spacer(minLength: 8)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(issue.headline)
            .accessibilityHint(issue.tapPrompt)
            .accessibilityAddTraits(.isButton)

            if isExpanded {
                expandedBody
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    @ViewBuilder
    private var expandedBody: some View {
        Text(issue.detail)
            .font(.caption)
            .foregroundStyle(Momentum.contentSecondary)
            .fixedSize(horizontal: false, vertical: true)

        if issue.showsTokenField {
            HStack(spacing: 14) {
                Link("Genius API docs", destination: GeniusReferenceClient.developersURL)
                Link("Create a Genius API client", destination: GeniusReferenceClient.newAPIClientURL)
            }
            .font(.caption.weight(.semibold))

            SecureField("Paste the Client Access Token", text: $token)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(fieldBackground)
                .accessibilityLabel("Genius client access token")
                .accessibilityHint("Paste the Client Access Token from the Genius developer page.")

            if let failCopy {
                Text(failCopy)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: saveToken) {
                HStack {
                    if phase == .checking {
                        ProgressView().tint(Momentum.onInverse)
                        Text("Checking…")
                    } else {
                        Text("Save token")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
            .disabled(phase == .checking || token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityHint("Checks the token, then saves it on this iPhone if it works.")
        } else {
            Button("Try again", action: onRetry)
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
        }
    }

    private func saveToken() {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if let wrong = APIKeyValidator.wrongFieldMessage(for: trimmed, kind: .genius) {
            failCopy = wrong
            phase = .failed
            return
        }
        guard APIKeyValidator.looksReady(trimmed, kind: .genius) else {
            failCopy = "That doesn't look like a Genius Client Access Token yet."
            phase = .failed
            return
        }
        failCopy = nil
        phase = .checking
        Task {
            let ok = await APIKeyValidator.validate(trimmed, kind: .genius)
            await MainActor.run {
                guard ok else {
                    phase = .failed
                    failCopy = "That token didn't work. Open Create a Genius API client, copy a new Client Access Token, and try again."
                    return
                }
                do {
                    try KeychainHelper.shared.saveGeniusAPIKey(trimmed)
                    phase = .idle
                    token = ""
                    isExpanded = false
                    onTokenSaved()
                } catch {
                    phase = .failed
                    failCopy = "Couldn't save the token on this iPhone. Try again."
                }
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
            .fill(Momentum.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
            .fill(Momentum.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
    }
}
