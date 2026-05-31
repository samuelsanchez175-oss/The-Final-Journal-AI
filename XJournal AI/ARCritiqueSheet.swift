import SwiftUI

// MARK: - A&R Critique Sheet (Phase 4: Advanced AI Features)

struct ARCritiqueSheet: View {
    let currentText: String
    let onDismiss: () -> Void
    let precomputedCritiques: [LineCritique]? // Optional pre-computed critiques from background analysis
    
    @State private var critiques: [LineCritique] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                        
                        Text("A&R Critique")
                            .font(.title2.weight(.bold))
                        
                        Text("Line-by-line analysis of your writing")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Loading State
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Analyzing text...")
                                .font(.caption)
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    // Text Display with Highlights
                    if !currentText.isEmpty && !isLoading {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Text")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ZStack(alignment: .topLeading) {
                                // Base text (read-only)
                                Text(currentText)
                                    .font(.body)
                                    .foregroundStyle(.clear) // Make invisible, just for layout
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                
                                // Highlight overlay
                                CritiqueHighlightView(
                                    text: currentText,
                                    critiques: critiques,
                                    isVisible: true
                                )
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Momentum.surfaceElevated)
                                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Critiques List
                    if !critiques.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Critiques")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(critiques.enumerated()), id: \.offset) { index, critique in
                                    critiqueCard(critique: critique)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                    } else if !isLoading && !currentText.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.green)
                            
                            Text("No Issues Found")
                                .font(.headline)
                            
                            Text("Your text passes A&R review. No critiques at this time.")
                                .font(.subheadline)
                                .foregroundStyle(Momentum.contentSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Momentum.surfaceElevated)
                                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(
                Rectangle()
                    .fill(Momentum.surfaceElevated)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("A&R Critique")
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
                // Use pre-computed critiques if available, otherwise analyze
                if let precomputed = precomputedCritiques, !precomputed.isEmpty {
                    critiques = precomputed
                    isLoading = false
                } else {
                    analyzeText()
                }
            }
        }
    }
    
    // MARK: - Analysis
    
    private func analyzeText() {
        guard !currentText.isEmpty else {
            errorMessage = "No text to analyze"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            // Generate critiques using ARCritiqueGenerator
            let generatedCritiques = ARCritiqueGenerator.shared.analyzeTextForCritiques(text: currentText)
            
            await MainActor.run {
                critiques = generatedCritiques
                isLoading = false
                
                if critiques.isEmpty {
                    // No critiques found - this is fine, just means text passed review
                }
            }
        }
    }
    
    // MARK: - Critique Card
    
    private func critiqueCard(critique: LineCritique) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Highlighted line text
            HStack {
                Image(systemName: critiqueIcon(for: critique.critiqueType))
                    .foregroundStyle(.green)
                    .font(.caption)
                
                Text(critique.lineText)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.green.opacity(0.2))
                    )
            }
            
            // Critique text
            Text(critique.critique)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .padding(.leading, 24) // Align with critique text
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    private func critiqueIcon(for type: CritiqueType) -> String {
        switch type {
        case .oversharing:
            return "exclamationmark.bubble.fill"
        case .narrativeProgression:
            return "arrow.right.circle.fill"
        case .emotionalLeakage:
            return "heart.slash.fill"
        case .defensiveFraming:
            return "shield.slash.fill"
        case .weakAuthority:
            return "arrow.down.circle.fill"
        case .informationRefusalViolation:
            return "eye.slash.fill"
        case .forbiddenVerb(_):
            return "xmark.circle.fill"
        case .clauseTooLong(_):
            return "text.badge.xmark"
        case .tooManyBrands(_):
            return "tag.slash.fill"
        case .missingPriceAnchor:
            return "dollarsign.circle.fill"
        }
    }
}
