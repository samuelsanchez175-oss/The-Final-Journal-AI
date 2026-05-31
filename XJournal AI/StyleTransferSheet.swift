import SwiftUI

// MARK: - Style Transfer Sheet (Phase 4: Advanced AI Features)

struct StyleTransferSheet: View {
    let currentText: String
    let onSelect: (RapSuggestion) -> Void
    let onDismiss: () -> Void
    
    @State private var artistName: String = ""
    @State private var suggestions: [RapSuggestion] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var signalAxes: SignalAxes?
    @State private var signalProfile: SignalProfile?
    @State private var isAnalyzingAxes: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.purple)
                    
                    Text("Style Transfer")
                        .font(.title2.weight(.bold))
                    
                    Text("Rewrite your lyrics in the style of any artist")
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                    
                    // Signal Axes Display
                    if let axes = signalAxes {
                        signalAxesSection(axes: axes)
                            .padding(.horizontal)
                    } else if isAnalyzingAxes {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Analyzing text...")
                                .font(.caption)
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                        .padding(.horizontal)
                    }
                
                // Artist Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Artist Name")
                        .font(.headline)
                    
                    TextField("e.g., Kendrick Lamar, Eminem, Drake", text: $artistName)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                }
                .padding(.horizontal)
                
                // Generate Button
                Button {
                    Task {
                        await generateStyleTransfer()
                    }
                } label: {
                    VStack(spacing: 8) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isLoading ? "Generating..." : "Generate Style Transfer")
                            .font(.headline)
                            .foregroundStyle(.white)
                        }
                        
                        if isLoading && signalAxes != nil {
                            Text("Preserving text characteristics...")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isLoading || artistName.isEmpty ? Color.gray : Color.purple)
                    )
                }
                .disabled(isLoading || artistName.isEmpty)
                .padding(.horizontal)
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                // Suggestions
                if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggestions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                        VStack(spacing: 16) {
                            ForEach(suggestions) { suggestion in
                                Button {
                                    onSelect(suggestion)
                                    dismiss()
                                    onDismiss()
                                } label: {
                                        VStack(alignment: .leading, spacing: 12) {
                                        Text(suggestion.text)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                            HStack(spacing: 12) {
                                        if let source = suggestion.source {
                                                    Label(source, systemImage: "paintbrush.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(.purple)
                                                }
                                                
                                                if signalAxes != nil {
                                                    Label("Characteristics preserved", systemImage: "checkmark.shield.fill")
                                                .font(.caption)
                                                        .foregroundStyle(.green)
                                                }
                                                
                                                Spacer()
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Momentum.surfaceElevated)
                                                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
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
            .navigationTitle("Style Transfer")
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
                // Analyze text for signal axes when sheet appears
                analyzeTextForAxes()
            }
        }
    }
    
    private func generateStyleTransfer() async {
        guard !artistName.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await RapSuggestionAPI.shared.generateStyleTransfer(
                text: currentText,
                targetArtist: artistName,
                context: nil,
                signalAxes: signalAxes
            )
            
            await MainActor.run {
                suggestions = results
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - Signal Axes Analysis
    
    private func analyzeTextForAxes() {
        guard !currentText.isEmpty else { return }
        
        isAnalyzingAxes = true
        
        Task {
            // Analyze text to get signal metrics and profile
            let metrics = SignalIngest.shared.analyzeBehavior(text: currentText)
            let profile = SignalIngest.shared.extractSignalProfile(text: currentText)
            
            // Resolve signal mode from metrics
            let mode = SignalModeResolver.shared.resolveMode(from: metrics)
            
            // Calculate signal axes
            let axes = SignalAxes.calibrateAxes(metrics: metrics, mode: mode)
            
            await MainActor.run {
                self.signalProfile = profile
                self.signalAxes = axes
                self.isAnalyzingAxes = false
            }
        }
    }
    
    // MARK: - Signal Axes UI
    
    private func signalAxesSection(axes: SignalAxes) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundStyle(.purple)
                Text("Text Analysis")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 10) {
                axisRow(
                    title: "Exposure Risk",
                    value: axes.exposureRisk.rawValue.capitalized,
                    color: exposureRiskColor(axes.exposureRisk),
                    icon: "eye.fill",
                    description: exposureRiskDescription(axes.exposureRisk)
                )
                
                Divider()
                    .opacity(0.2)
                
                axisRow(
                    title: "Authority Posture",
                    value: axes.authorityPosture.rawValue.capitalized,
                    color: authorityPostureColor(axes.authorityPosture),
                    icon: "crown.fill",
                    description: authorityPostureDescription(axes.authorityPosture)
                )
                
                Divider()
                    .opacity(0.2)
                
                axisRow(
                    title: "Social Action",
                    value: axes.socialAction.rawValue.capitalized,
                    color: .blue,
                    icon: "person.2.fill",
                    description: socialActionDescription(axes.socialAction)
                )
                
                Divider()
                    .opacity(0.2)
                
                axisRow(
                    title: "Audience Scope",
                    value: axes.audienceScope.rawValue.capitalized,
                    color: .orange,
                    icon: "person.3.fill",
                    description: audienceScopeDescription(axes.audienceScope)
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            )
            
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text("These characteristics will be preserved in the style transfer")
                    .font(.caption2)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }
    
    private func axisRow(title: String, value: String, color: Color, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
            }
            
            Text(description)
                .font(.caption2)
                .foregroundStyle(Momentum.contentSecondary)
                .padding(.leading, 32)
        }
    }
    
    private func exposureRiskDescription(_ risk: ExposureRisk) -> String {
        switch risk {
        case .low: return "Minimal personal exposure or vulnerability"
        case .medium: return "Moderate level of revelation or guardedness"
        case .high: return "High degree of personal exposure or vulnerability"
        }
    }
    
    private func authorityPostureDescription(_ posture: AuthorityPosture) -> String {
        switch posture {
        case .unstable: return "Uncertain or shifting position strength"
        case .emerging: return "Developing confidence and authority"
        case .established: return "Strong, confident position"
        }
    }
    
    private func socialActionDescription(_ action: SocialAction) -> String {
        switch action {
        case .confess: return "Admitting or revealing something personal"
        case .distance: return "Creating space or separation"
        case .assert: return "Making a strong statement or claim"
        case .withdraw: return "Pulling back or retreating"
        case .warn: return "Issuing a caution or threat"
        case .flex: return "Showing off or demonstrating strength"
        }
    }
    
    private func audienceScopeDescription(_ scope: AudienceScope) -> String {
        switch scope {
        case .selfOnly: return "Intended for personal reflection"
        case .innerCircle: return "Meant for close, trusted audience"
        case .`public`: return "Directed at broader public audience"
        }
    }
    
    private func exposureRiskColor(_ risk: ExposureRisk) -> Color {
        switch risk {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    private func authorityPostureColor(_ posture: AuthorityPosture) -> Color {
        switch posture {
        case .unstable: return .orange
        case .emerging: return .yellow
        case .established: return .green
        }
    }
}
