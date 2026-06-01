import SwiftUI

// MARK: - Model Preferences View

struct ModelPreferencesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var modelGv3Settings = ModelSettings()
    @State private var originalityBias = ModelGEnvironment.originalityBias

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    originalitySlider
                    ModelSettingsForm(settings: $modelGv3Settings)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Model Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            ModelGEnvironment.applyV3OnlyProductDefaultsIfNeeded()
            loadSettings()
        }
    }

    private var originalitySlider: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Originality").font(.subheadline.weight(.semibold))
                Spacer()
                Text(originalityBias < 0.34 ? "Inspired" : (originalityBias < 0.67 ? "Balanced" : "Novel"))
                    .font(.caption).foregroundStyle(Momentum.contentSecondary)
            }
            Slider(value: Binding(
                get: { originalityBias },
                set: { originalityBias = $0; ModelGEnvironment.originalityBias = $0 }
            ), in: 0...1)
            Text("Lower leans on culture and familiar phrasing; higher is more novel. Mid is usually the sweet spot.")
                .font(.caption).foregroundStyle(Momentum.contentSecondary)
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "modelGv3_settings"),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            modelGv3Settings = clampedSettings(decoded)
        } else {
            modelGv3Settings = clampedSettings(ModelSettings.defaultForModelG())
        }
    }

    private func saveSettings() {
        modelGv3Settings = clampedSettings(modelGv3Settings)
        if let encoded = try? JSONEncoder().encode(modelGv3Settings) {
            UserDefaults.standard.set(encoded, forKey: "modelGv3_settings")
        }
    }

    private func clampedSettings(_ settings: ModelSettings) -> ModelSettings {
        var clamped = settings
        clamped.silenceThreshold = min(max(clamped.silenceThreshold, 0.0), 0.8)
        clamped.registerWeight = min(max(clamped.registerWeight, 0.0), 1.0)
        ModelSettingsUIMapping.syncRefusalFromSilence(&clamped)
        return clamped
    }
}

// MARK: - Merged UI mapping (one control → multiple stored fields; prompts unchanged)

enum ModelSettingsUIMapping {
    static func showVsTellIndex(implication: ImplicationLevel, compression: CompressionLevel) -> Int {
        if implication == .heavy && compression == .high { return 0 }
        if implication == .explicit && compression == .low { return 2 }
        return 1
    }

    static func applyShowVsTell(index: Int, to settings: inout ModelSettings) {
        switch index {
        case 0:
            settings.implicationLevel = .heavy
            settings.compressionLevel = .high
        case 2:
            settings.implicationLevel = .explicit
            settings.compressionLevel = .low
        default:
            settings.implicationLevel = .moderate
            settings.compressionLevel = .moderate
        }
    }

    static func applyFormality(index: Int, to settings: inout ModelSettings) {
        settings.registerStrictness = RegisterStrictness(rawValue: index) ?? .moderate
        switch index {
        case 0: settings.registerWeight = 0.35
        case 2: settings.registerWeight = 0.12
        default: settings.registerWeight = 0.20
        }
    }

    static func confidenceClusterIndex(
        authority: AuthorityLevel,
        dominance: DominanceLevel,
        finality: FinalityLevel
    ) -> Int {
        if authority == .high && dominance == .high && finality == .high { return 0 }
        if authority == .low && dominance == .low && finality == .low { return 2 }
        if authority == .low || finality == .low { return 2 }
        if authority == .high && finality == .high { return 0 }
        return 1
    }

    static func applyConfidenceCluster(index: Int, to settings: inout ModelSettings) {
        switch index {
        case 0:
            settings.authorityLevel = .high
            settings.dominanceLevel = .high
            settings.finalityLevel = .high
        case 2:
            settings.authorityLevel = .low
            settings.dominanceLevel = .low
            settings.finalityLevel = .low
        default:
            settings.authorityLevel = .moderate
            settings.dominanceLevel = .moderate
            settings.finalityLevel = .moderate
        }
    }

    static func refusalFrequency(forSilenceThreshold threshold: Double) -> RefusalFrequency {
        if threshold >= 0.55 { return .frequent }
        if threshold <= 0.35 { return .rare }
        return .moderate
    }

    static func syncRefusalFromSilence(_ settings: inout ModelSettings) {
        settings.refusalFrequency = refusalFrequency(forSilenceThreshold: settings.silenceThreshold)
    }
}

// MARK: - Model Settings Form

struct ModelSettingsForm: View {
    @Binding var settings: ModelSettings
    @State private var isAdvancedExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            voiceSection
            boundariesSection
            flowSection
            advancedSection
        }
    }

    // MARK: - Voice (default)

    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Voice",
                subtitle: "What the AI protects and how bars sound."
            )

            QuestionView(
                question: "What should the system protect?",
                options: [
                    "Authority — earned voice, refuse weak lines",
                    "Exposure — guard oversharing, prefer implication",
                    "Cultural specificity — keep authentic references",
                    "Narrative integrity — story coherence first"
                ],
                selectedIndex: Binding(
                    get: { settings.editorialProtection.rawValue },
                    set: { settings.editorialProtection = EditorialProtection(rawValue: $0) ?? .authority }
                )
            )

            QuestionView(
                question: "How open should the voice be?",
                options: [
                    "Guarded — minimal sharing",
                    "Balanced — selective sharing",
                    "Open — more revealing"
                ],
                selectedIndex: Binding(
                    get: { settings.exposureLevel.rawValue },
                    set: { settings.exposureLevel = ExposureLevel(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "How bold should choices be?",
                options: [
                    "Safe — conservative choices",
                    "Balanced — calculated risks",
                    "Bold — experimental choices"
                ],
                selectedIndex: Binding(
                    get: { settings.riskTolerance.rawValue },
                    set: { settings.riskTolerance = RiskTolerance(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Show vs tell",
                options: [
                    "Mostly implied — subtext and gaps",
                    "Balanced — mix shown and told",
                    "More explained — spell it out when needed"
                ],
                selectedIndex: Binding(
                    get: {
                        ModelSettingsUIMapping.showVsTellIndex(
                            implication: settings.implicationLevel,
                            compression: settings.compressionLevel
                        )
                    },
                    set: { index in
                        ModelSettingsUIMapping.applyShowVsTell(index: index, to: &settings)
                    }
                )
            )
        }
    }

    // MARK: - Boundaries (default)

    private var boundariesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Boundaries",
                subtitle: "Topics to avoid and language limits."
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Topics to avoid")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)

                TextField("Comma-separated, e.g. drugs, violence", text: $settings.topicRestrictions, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Momentum.surfaceElevated)
            )

            QuestionView(
                question: "Explicit language",
                options: [
                    "Allow all",
                    "Some filtering",
                    "Avoid explicit content"
                ],
                selectedIndex: Binding(
                    get: { settings.languageRestrictions.rawValue },
                    set: { settings.languageRestrictions = LanguageRestrictions(rawValue: $0) ?? .moderate }
                )
            )
        }
    }

    // MARK: - Flow (default)

    private var flowSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Flow",
                subtitle: "When the AI offers a suggestion vs. stays quiet."
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Confidence to suggest")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)

                HStack {
                    Text("Suggest more")
                        .font(.caption)
                    Spacer()
                    Text("Only when confident")
                        .font(.caption)
                }
                .foregroundStyle(Momentum.contentSecondary)

                HStack {
                    Text(String(format: "%.1f", settings.silenceThreshold))
                        .font(.headline)
                        .frame(width: 44)

                    Slider(
                        value: Binding(
                            get: { settings.silenceThreshold },
                            set: { newValue in
                                settings.silenceThreshold = newValue
                                settings.refusalFrequency = ModelSettingsUIMapping.refusalFrequency(
                                    forSilenceThreshold: newValue
                                )
                            }
                        ),
                        in: 0.0...0.8,
                        step: 0.1
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Momentum.surfaceElevated)
            )
        }
    }

    // MARK: - Advanced (all remaining wired fields)

    private var advancedSection: some View {
        DisclosureGroup(isExpanded: $isAdvancedExpanded) {
            VStack(alignment: .leading, spacing: 20) {
                advancedFormalitySection
                advancedConfidenceSection
                advancedToneSection
                advancedNarrativeSection
                advancedMusicalSection
            }
            .padding(.top, 8)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Advanced")
                    .font(.headline)
                Text("Formality, confidence, rhythm, references, and fine-tuning.")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }

    private var advancedFormalitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            QuestionView(
                question: "Formality",
                options: [
                    "Street-locked — same register, strongly enforced",
                    "Balanced — shifts when the bar needs it",
                    "Flexible — register follows the story"
                ],
                selectedIndex: Binding(
                    get: { settings.registerStrictness.rawValue },
                    set: { index in
                        ModelSettingsUIMapping.applyFormality(index: index, to: &settings)
                    }
                )
            )
        }
    }

    private var advancedConfidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            QuestionView(
                question: "Confidence of the voice",
                options: [
                    "Commanding — final, assertive bars",
                    "Balanced — confident but open",
                    "Exploratory — tentative, provisional"
                ],
                selectedIndex: Binding(
                    get: {
                        ModelSettingsUIMapping.confidenceClusterIndex(
                            authority: settings.authorityLevel,
                            dominance: settings.dominanceLevel,
                            finality: settings.finalityLevel
                        )
                    },
                    set: { index in
                        ModelSettingsUIMapping.applyConfidenceCluster(index: index, to: &settings)
                    }
                )
            )
        }
    }

    private var advancedToneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tone & references")
                .font(.subheadline.weight(.semibold))

            QuestionView(
                question: "Cultural specificity",
                options: [
                    "High — assume shared context",
                    "Moderate — some explanation",
                    "Low — universal, explained"
                ],
                selectedIndex: Binding(
                    get: { settings.culturalSpecificity.rawValue },
                    set: { settings.culturalSpecificity = CulturalSpecificity(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Symbolism",
                options: [
                    "High — abstract, fluid language",
                    "Moderate — mix concrete and abstract",
                    "Low — concrete, literal"
                ],
                selectedIndex: Binding(
                    get: { settings.symbolismLevel.rawValue },
                    set: { settings.symbolismLevel = SymbolismLevel(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Reference style",
                options: [
                    "Abstract — metaphorical, universal",
                    "Balanced — personal and abstract",
                    "Personal — specific, concrete"
                ],
                selectedIndex: Binding(
                    get: { settings.referenceStyle.rawValue },
                    set: { settings.referenceStyle = ReferenceStyle(rawValue: $0) ?? .balanced }
                )
            )
        }
    }

    private var advancedNarrativeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Narrative & restraint")
                .font(.subheadline.weight(.semibold))

            QuestionView(
                question: "Restraint",
                options: [
                    "High — minimal, essential only",
                    "Moderate — selective expression",
                    "Low — full expression"
                ],
                selectedIndex: Binding(
                    get: { settings.restraintLevel.rawValue },
                    set: { settings.restraintLevel = RestraintLevel(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Posture shifts",
                options: [
                    "None — consistent posture",
                    "Moderate — when narratively strong",
                    "Flexible — follows narrative"
                ],
                selectedIndex: Binding(
                    get: { settings.postureShiftTolerance.rawValue },
                    set: { settings.postureShiftTolerance = PostureShiftTolerance(rawValue: $0) ?? .moderate }
                )
            )
        }
    }

    private var advancedMusicalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rhyme & beat")
                .font(.subheadline.weight(.semibold))

            QuestionView(
                question: "Flow density",
                options: [
                    "Sparse — breathing room",
                    "Moderate — balanced",
                    "Dense — rapid-fire"
                ],
                selectedIndex: Binding(
                    get: { settings.flowDensity.rawValue },
                    set: { settings.flowDensity = FlowDensity(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Rhyme complexity",
                options: [
                    "Simple — straightforward rhymes",
                    "Moderate — varied patterns",
                    "Complex — multi-syllable, intricate"
                ],
                selectedIndex: Binding(
                    get: { settings.rhymeComplexity.rawValue },
                    set: { settings.rhymeComplexity = RhymeComplexity(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Syllable consistency",
                options: [
                    "Strict — consistent counts",
                    "Moderate — some variation",
                    "Flexible — creative freedom"
                ],
                selectedIndex: Binding(
                    get: { settings.syllableVarianceTolerance.rawValue },
                    set: { settings.syllableVarianceTolerance = SyllableVarianceTolerance(rawValue: $0) ?? .moderate }
                )
            )

            QuestionView(
                question: "Beat sync",
                options: [
                    "Loose — flexible timing",
                    "Moderate — balanced",
                    "Tight — precise on beat"
                ],
                selectedIndex: Binding(
                    get: { settings.beatSyncPreference.rawValue },
                    set: { settings.beatSyncPreference = BeatSyncPreference(rawValue: $0) ?? .moderate }
                )
            )
        }
    }

}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }
}

// MARK: - Question View

struct QuestionView: View {
    let question: String
    let options: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
            
            VStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button {
                        selectedIndex = index
                    } label: {
                        HStack {
                            Text(option)
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if selectedIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedIndex == index ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
}

// MARK: - Model Settings Data Structure

struct ModelSettings: Codable {
    // Editorial Authority & Risk
    var editorialProtection: EditorialProtection = .authority
    var implicationLevel: ImplicationLevel = .moderate
    var compressionLevel: CompressionLevel = .moderate
    var registerStrictness: RegisterStrictness = .moderate
    var registerWeight: Double = 0.17
    
    // Authority & Dominance
    var authorityLevel: AuthorityLevel = .moderate
    var dominanceLevel: DominanceLevel = .moderate
    
    // Exposure & Cultural Specificity
    var exposureLevel: ExposureLevel = .moderate
    var culturalSpecificity: CulturalSpecificity = .moderate
    var riskTolerance: RiskTolerance = .moderate
    var symbolismLevel: SymbolismLevel = .moderate
    
    // Finality & Restraint
    var finalityLevel: FinalityLevel = .moderate
    var restraintLevel: RestraintLevel = .moderate
    var postureShiftTolerance: PostureShiftTolerance = .moderate
    var refusalFrequency: RefusalFrequency = .moderate
    
    // Silence Threshold
    var silenceThreshold: Double = 0.5
    
    // Musical Preferences (kept as-is)
    var flowDensity: FlowDensity = .moderate
    var rhymeComplexity: RhymeComplexity = .moderate
    var syllableVarianceTolerance: SyllableVarianceTolerance = .moderate
    var beatSyncPreference: BeatSyncPreference = .moderate
    
    // Content Boundaries
    var topicRestrictions: String = ""
    var languageRestrictions: LanguageRestrictions = .moderate
    var referenceStyle: ReferenceStyle = .balanced
    var culturalContextSensitivity: CulturalContextSensitivity = .moderate
    
    // MARK: - Initializers
    
    init() {
        // Default initializer - all properties use their default values
    }
    
    // MARK: - Default Presets
    
    static func defaultForModelG() -> ModelSettings {
        var settings = ModelSettings()
        settings.editorialProtection = .authority
        settings.implicationLevel = .heavy
        settings.compressionLevel = .high
        settings.registerStrictness = .strict
        settings.authorityLevel = .high
        settings.dominanceLevel = .moderate
        settings.exposureLevel = .low
        settings.culturalSpecificity = .high
        settings.riskTolerance = .low
        settings.symbolismLevel = .moderate
        settings.finalityLevel = .high
        settings.restraintLevel = .high
        settings.postureShiftTolerance = .noShifts
        settings.refusalFrequency = .frequent
        settings.silenceThreshold = 0.7
        return settings
    }
    
    static func defaultForModelY() -> ModelSettings {
        var settings = ModelSettings()
        settings.editorialProtection = .culturalSpecificity
        settings.implicationLevel = .moderate
        settings.compressionLevel = .moderate
        settings.registerStrictness = .flexible
        settings.authorityLevel = .moderate
        settings.dominanceLevel = .high
        settings.exposureLevel = .moderate
        settings.culturalSpecificity = .high
        settings.riskTolerance = .high
        settings.symbolismLevel = .high
        settings.finalityLevel = .moderate
        settings.restraintLevel = .moderate
        settings.postureShiftTolerance = .flexible
        settings.refusalFrequency = .moderate
        settings.silenceThreshold = 0.4
        return settings
    }
    
    // MARK: - Backward Compatibility (for migration)
    
    enum CodingKeys: String, CodingKey {
        // New keys
        case editorialProtection, implicationLevel, compressionLevel
        case registerStrictness, registerWeight
        case authorityLevel, dominanceLevel
        case exposureLevel, culturalSpecificity, riskTolerance, symbolismLevel
        case finalityLevel, restraintLevel, postureShiftTolerance, refusalFrequency
        case silenceThreshold
        case flowDensity, rhymeComplexity, syllableVarianceTolerance, beatSyncPreference
        case topicRestrictions, languageRestrictions, referenceStyle, culturalContextSensitivity
        
        // Old keys (for migration)
        case priorityFocus, contradictionHandling, thematicLayering
        case musicalStrictness, musicalWeight
        case voiceMatching, topicModeHandling, candidateSelectionRatio
        case aggressivenessLevel, formalityPreference, energyLevelPreference, metaphorDensity
        case storyProgressionStyle, characterDevelopmentDepth, emotionalRange, resolutionPreference
        case adaptationOriginalityBalance, referenceFrequency, experimentalLanguageTolerance, genreBlendingPreference
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try new keys first, fall back to old keys for migration
        if let value = try? container.decode(EditorialProtection.self, forKey: .editorialProtection) {
            self.editorialProtection = value
        } else if let oldValue = try? container.decode(Int.self, forKey: .priorityFocus) {
            // Map old PriorityFocus to new EditorialProtection
            switch oldValue {
            case 0: self.editorialProtection = .authority // balanced -> authority
            case 1: self.editorialProtection = .narrativeIntegrity // musicalFlow -> narrativeIntegrity
            case 2: self.editorialProtection = .narrativeIntegrity // thematicDepth -> narrativeIntegrity
            case 3: self.editorialProtection = .authority // voiceConsistency -> authority
            default: self.editorialProtection = .authority
            }
        } else {
            self.editorialProtection = .authority
        }
        
        // Similar migration for other fields...
        // For brevity, I'll implement key migrations and use defaults for others
        self.implicationLevel = (try? container.decode(ImplicationLevel.self, forKey: .implicationLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .contradictionHandling)).map { ImplicationLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.compressionLevel = (try? container.decode(CompressionLevel.self, forKey: .compressionLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .thematicLayering)).map { CompressionLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.registerStrictness = (try? container.decode(RegisterStrictness.self, forKey: .registerStrictness)) ?? 
            ((try? container.decode(Int.self, forKey: .musicalStrictness)).map { RegisterStrictness(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.registerWeight = (try? container.decode(Double.self, forKey: .registerWeight)) ?? 
            (try? container.decode(Double.self, forKey: .musicalWeight)) ?? 0.17
        
        self.authorityLevel = (try? container.decode(AuthorityLevel.self, forKey: .authorityLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .voiceMatching)).map { AuthorityLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.dominanceLevel = (try? container.decode(DominanceLevel.self, forKey: .dominanceLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .topicModeHandling)).map { DominanceLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.exposureLevel = (try? container.decode(ExposureLevel.self, forKey: .exposureLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .aggressivenessLevel)).map { ExposureLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.culturalSpecificity = (try? container.decode(CulturalSpecificity.self, forKey: .culturalSpecificity)) ?? 
            ((try? container.decode(Int.self, forKey: .formalityPreference)).map { CulturalSpecificity(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.riskTolerance = (try? container.decode(RiskTolerance.self, forKey: .riskTolerance)) ?? 
            ((try? container.decode(Int.self, forKey: .energyLevelPreference)).map { RiskTolerance(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.symbolismLevel = (try? container.decode(SymbolismLevel.self, forKey: .symbolismLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .metaphorDensity)).map { SymbolismLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.finalityLevel = (try? container.decode(FinalityLevel.self, forKey: .finalityLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .storyProgressionStyle)).map { FinalityLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.restraintLevel = (try? container.decode(RestraintLevel.self, forKey: .restraintLevel)) ?? 
            ((try? container.decode(Int.self, forKey: .characterDevelopmentDepth)).map { RestraintLevel(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.postureShiftTolerance = (try? container.decode(PostureShiftTolerance.self, forKey: .postureShiftTolerance)) ?? 
            ((try? container.decode(Int.self, forKey: .emotionalRange)).map { PostureShiftTolerance(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.refusalFrequency = (try? container.decode(RefusalFrequency.self, forKey: .refusalFrequency)) ?? 
            ((try? container.decode(Int.self, forKey: .resolutionPreference)).map { RefusalFrequency(rawValue: $0) ?? .moderate }) ?? .moderate
        
        self.silenceThreshold = (try? container.decode(Double.self, forKey: .silenceThreshold)) ?? 
            ((try? container.decode(Double.self, forKey: .candidateSelectionRatio)).map { 1.0 - $0 }) ?? 0.5
        
        // Keep existing fields
        self.flowDensity = (try? container.decode(FlowDensity.self, forKey: .flowDensity)) ?? .moderate
        self.rhymeComplexity = (try? container.decode(RhymeComplexity.self, forKey: .rhymeComplexity)) ?? .moderate
        self.syllableVarianceTolerance = (try? container.decode(SyllableVarianceTolerance.self, forKey: .syllableVarianceTolerance)) ?? .moderate
        self.beatSyncPreference = (try? container.decode(BeatSyncPreference.self, forKey: .beatSyncPreference)) ?? .moderate
        self.topicRestrictions = (try? container.decode(String.self, forKey: .topicRestrictions)) ?? ""
        self.languageRestrictions = (try? container.decode(LanguageRestrictions.self, forKey: .languageRestrictions)) ?? .moderate
        self.referenceStyle = (try? container.decode(ReferenceStyle.self, forKey: .referenceStyle)) ?? .balanced
        self.culturalContextSensitivity = (try? container.decode(CulturalContextSensitivity.self, forKey: .culturalContextSensitivity)) ?? .moderate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode new keys only
        try container.encode(editorialProtection, forKey: .editorialProtection)
        try container.encode(implicationLevel, forKey: .implicationLevel)
        try container.encode(compressionLevel, forKey: .compressionLevel)
        try container.encode(registerStrictness, forKey: .registerStrictness)
        try container.encode(registerWeight, forKey: .registerWeight)
        try container.encode(authorityLevel, forKey: .authorityLevel)
        try container.encode(dominanceLevel, forKey: .dominanceLevel)
        try container.encode(exposureLevel, forKey: .exposureLevel)
        try container.encode(culturalSpecificity, forKey: .culturalSpecificity)
        try container.encode(riskTolerance, forKey: .riskTolerance)
        try container.encode(symbolismLevel, forKey: .symbolismLevel)
        try container.encode(finalityLevel, forKey: .finalityLevel)
        try container.encode(restraintLevel, forKey: .restraintLevel)
        try container.encode(postureShiftTolerance, forKey: .postureShiftTolerance)
        try container.encode(refusalFrequency, forKey: .refusalFrequency)
        try container.encode(silenceThreshold, forKey: .silenceThreshold)
        try container.encode(flowDensity, forKey: .flowDensity)
        try container.encode(rhymeComplexity, forKey: .rhymeComplexity)
        try container.encode(syllableVarianceTolerance, forKey: .syllableVarianceTolerance)
        try container.encode(beatSyncPreference, forKey: .beatSyncPreference)
        try container.encode(topicRestrictions, forKey: .topicRestrictions)
        try container.encode(languageRestrictions, forKey: .languageRestrictions)
        try container.encode(referenceStyle, forKey: .referenceStyle)
        try container.encode(culturalContextSensitivity, forKey: .culturalContextSensitivity)
    }
}

// MARK: - Editorial Intelligence Enums

enum EditorialProtection: Int, Codable {
    case authority = 0
    case exposure = 1
    case culturalSpecificity = 2
    case narrativeIntegrity = 3
}

enum ImplicationLevel: Int, Codable {
    case heavy = 0
    case moderate = 1
    case explicit = 2
}

enum CompressionLevel: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum RegisterStrictness: Int, Codable {
    case strict = 0
    case moderate = 1
    case flexible = 2
}

enum AuthorityLevel: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum DominanceLevel: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum ExposureLevel: Int, Codable {
    case low = 0
    case moderate = 1
    case high = 2
}

enum CulturalSpecificity: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum RiskTolerance: Int, Codable {
    case low = 0
    case moderate = 1
    case high = 2
}

enum SymbolismLevel: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum FinalityLevel: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum RestraintLevel: Int, Codable {
    case high = 0
    case moderate = 1
    case low = 2
}

enum PostureShiftTolerance: Int, Codable {
    case noShifts = 0
    case moderate = 1
    case flexible = 2
}

enum RefusalFrequency: Int, Codable {
    case frequent = 0
    case moderate = 1
    case rare = 2
}

// MARK: - Deprecated Enums (for backward compatibility)

@available(*, deprecated, renamed: "EditorialProtection")
typealias PriorityFocus = EditorialProtection

@available(*, deprecated, renamed: "ImplicationLevel")
typealias ContradictionHandling = ImplicationLevel

@available(*, deprecated, renamed: "CompressionLevel")
typealias ThematicLayering = CompressionLevel

@available(*, deprecated, renamed: "RegisterStrictness")
typealias MusicalStrictness = RegisterStrictness

@available(*, deprecated, renamed: "AuthorityLevel")
typealias VoiceMatching = AuthorityLevel

@available(*, deprecated, renamed: "DominanceLevel")
typealias TopicModeHandling = DominanceLevel

@available(*, deprecated, renamed: "ExposureLevel")
typealias AggressivenessLevel = ExposureLevel

@available(*, deprecated, renamed: "CulturalSpecificity")
typealias FormalityPreference = CulturalSpecificity

@available(*, deprecated, renamed: "RiskTolerance")
typealias EnergyLevelPreference = RiskTolerance

@available(*, deprecated, renamed: "SymbolismLevel")
typealias MetaphorDensity = SymbolismLevel

@available(*, deprecated, renamed: "FinalityLevel")
typealias StoryProgressionStyle = FinalityLevel

@available(*, deprecated, renamed: "RestraintLevel")
typealias CharacterDevelopmentDepth = RestraintLevel

@available(*, deprecated, renamed: "PostureShiftTolerance")
typealias EmotionalRange = PostureShiftTolerance

@available(*, deprecated, renamed: "RefusalFrequency")
typealias ResolutionPreference = RefusalFrequency

// MARK: - Musical Preferences Enums

enum FlowDensity: Int, Codable {
    case sparse = 0
    case moderate = 1
    case dense = 2
}

enum RhymeComplexity: Int, Codable {
    case simple = 0
    case moderate = 1
    case complex = 2
}

enum SyllableVarianceTolerance: Int, Codable {
    case strict = 0
    case moderate = 1
    case flexible = 2
}

enum BeatSyncPreference: Int, Codable {
    case loose = 0
    case moderate = 1
    case tight = 2
}

// MARK: - Content Boundaries Enums

enum LanguageRestrictions: Int, Codable {
    case none = 0
    case moderate = 1
    case strict = 2
}

enum ReferenceStyle: Int, Codable {
    case abstract = 0
    case balanced = 1
    case personal = 2
}

enum CulturalContextSensitivity: Int, Codable {
    case low = 0
    case moderate = 1
    case high = 2
}
