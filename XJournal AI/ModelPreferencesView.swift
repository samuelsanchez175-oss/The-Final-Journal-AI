import SwiftUI

// MARK: - Model Preferences View

struct ModelPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedModel: SuggestionModel = .modelG
    @State private var modelGSettings = ModelSettings()
    @State private var modelGv3Settings = ModelSettings()
    @State private var originalityBias = ModelGEnvironment.originalityBias
    @State private var modelYSettings = ModelSettings()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Model Selector
                modelSelector
                
                Divider()
                
                // Settings Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedModel {
                        case .modelG:
                            modelGCoreToggle
                            if ModelGEnvironment.useModelGCore {
                                modelGv2Toggle
                            }
                            ModelSettingsForm(settings: $modelGSettings, modelName: "Model G")
                        case .modelGv3:
                            modelGv3Toggle
                            originalitySlider
                            Text("Model G v3 uses the upgraded prompt and scoring path. Tune voice and constraints independently from classic Model G.")
                                .font(.subheadline)
                                .foregroundStyle(Momentum.contentSecondary)
                            ModelSettingsForm(settings: $modelGv3Settings, modelName: "Model G v3")
                        case .modelY:
                            ModelSettingsForm(settings: $modelYSettings, modelName: "Model Y")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
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
            loadSettings()
        }
    }
    
    // MARK: - Model G Core Toggle

    private var modelGCoreToggle: some View {
        Toggle(isOn: Binding(
            get: { ModelGEnvironment.useModelGCore },
            set: { ModelGEnvironment.useModelGCore = $0 }
        )) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Model G Core v1.0")
                    .font(.subheadline.weight(.semibold))
                Text("Competitive bar generation, style branches, beat fingerprint. When off, uses legacy Model G batch generation.")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
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
            Text("Lower = lean on the culture & training lyrics (references, wordplay, familiar phrases). "
                 + "Higher = more novel. Mid is the sweet spot — fully original loses the voice.")
                .font(.caption).foregroundStyle(Momentum.contentSecondary)
        }
    }

    private var modelGv3Toggle: some View {
        Toggle(isOn: Binding(
            get: { ModelGEnvironment.useModelGv3 },
            set: { ModelGEnvironment.useModelGv3 = $0 }
        )) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Model G v3 (Planned single-call)")
                    .font(.subheadline.weight(.semibold))
                Text("Plans the verse, then writes the whole verse in one call (~3 API calls vs ~17). Theme + voice aware. Takes precedence over v2 when on.")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }

    private var modelGv2Toggle: some View {
        Toggle(isOn: Binding(
            get: { ModelGEnvironment.useModelGv2 },
            set: { ModelGEnvironment.useModelGv2 = $0 }
        )) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Model G v2 (Flow DNA)")
                    .font(.subheadline.weight(.semibold))
                Text("Flow DNA analysis: syllable stress, beat grid, rhyme clusters, cadence vector. Cross-test with v1.")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
    }

    // MARK: - Model Selector

    private var modelSelector: some View {
        HStack(spacing: 0) {
            ForEach(SuggestionModel.allCases, id: \.self) { model in
                Button {
                    withAnimation {
                        selectedModel = model
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: symbolName(for: model))
                            .font(.title2)
                        
                        Text(model.displayName)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        selectedModel == model
                            ? Color.blue.opacity(0.15)
                            : Color.clear
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial)
    }

    private func symbolName(for model: SuggestionModel) -> String {
        switch model {
        case .modelG: return "sparkles"
        case .modelY: return "sparkles.rectangle.stack"
        case .modelGv3: return "wand.and.stars"
        }
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        // Load Model G settings
        if let data = UserDefaults.standard.data(forKey: "modelG_settings"),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            modelGSettings = clampedSettings(decoded)
        } else {
            // Use defaults for Model G
            modelGSettings = clampedSettings(ModelSettings.defaultForModelG())
        }
        
        // Load Model G v3 settings
        if let data = UserDefaults.standard.data(forKey: "modelGv3_settings"),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            modelGv3Settings = clampedSettings(decoded)
        } else {
            modelGv3Settings = clampedSettings(ModelSettings.defaultForModelG())
        }

        // Load Model Y settings
        if let data = UserDefaults.standard.data(forKey: "modelY_settings"),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            modelYSettings = clampedSettings(decoded)
        } else {
            // Use defaults for Model Y
            modelYSettings = clampedSettings(ModelSettings.defaultForModelY())
        }
    }
    
    private func saveSettings() {
        modelGSettings = clampedSettings(modelGSettings)
        modelGv3Settings = clampedSettings(modelGv3Settings)
        modelYSettings = clampedSettings(modelYSettings)

        // Save Model G settings
        if let encoded = try? JSONEncoder().encode(modelGSettings) {
            UserDefaults.standard.set(encoded, forKey: "modelG_settings")
        }

        if let encoded = try? JSONEncoder().encode(modelGv3Settings) {
            UserDefaults.standard.set(encoded, forKey: "modelGv3_settings")
        }
        
        // Save Model Y settings
        if let encoded = try? JSONEncoder().encode(modelYSettings) {
            UserDefaults.standard.set(encoded, forKey: "modelY_settings")
        }
    }

    private func clampedSettings(_ settings: ModelSettings) -> ModelSettings {
        var clamped = settings
        clamped.silenceThreshold = min(max(clamped.silenceThreshold, 0.0), 0.8)
        clamped.registerWeight = min(max(clamped.registerWeight, 0.0), 1.0)
        return clamped
    }
}

// MARK: - Model Settings Form

struct ModelSettingsForm: View {
    @Binding var settings: ModelSettings
    let modelName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Intro: what these settings control
            Text("These options control how \(modelName) suggests bars: voice, tone, restraint, and when it returns no suggestion.")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
                .padding(.bottom, 8)
            
            // Priority Section
            prioritySection
            
            Divider()
            
            // Thematic Complexity Section
            thematicComplexitySection
            
            Divider()
            
            // Musical Constraints Section
            musicalConstraintsSection
            
            Divider()
            
            // Voice & Style Section
            voiceStyleSection
            
            Divider()
            
            // Output Style & Tone Section
            outputStyleToneSection
            
            Divider()
            
            // Narrative Approach Section
            narrativeApproachSection
            
            Divider()
            
            // Musical Preferences Section
            musicalPreferencesSection
            
            Divider()
            
            // Content Boundaries Section
            contentBoundariesSection
            
            Divider()
            
            // Content Generation Section
            contentGenerationSection
        }
    }
    
    // MARK: - Editorial Authority & Risk Section
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "What to protect", affects: "Which aspect of your voice the AI prioritizes when it refuses or adjusts suggestions.")
            
            QuestionView(
                question: "What should the system protect?",
                options: [
                    "Authority (maintain earned voice, refuse weak suggestions)",
                    "Exposure (guard against over-sharing, prefer implication)",
                    "Cultural specificity (preserve authentic references)",
                    "Narrative integrity (maintain story coherence above all)"
                ],
                selectedIndex: Binding(
                    get: { settings.editorialProtection.rawValue },
                    set: { settings.editorialProtection = EditorialProtection(rawValue: $0) ?? .authority }
                )
            )
        }
    }
    
    // MARK: - Implication & Compression Section
    
    private var thematicComplexitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Show vs tell", affects: "How much the bars spell things out vs. leave things implied.")
            
            QuestionView(
                question: "How much should be implied without explanation?",
                options: [
                    "Heavy implication (show aftermath, not events)",
                    "Moderate implication (balance shown and told)",
                    "Explicit (explain when necessary)"
                ],
                selectedIndex: Binding(
                    get: { settings.implicationLevel.rawValue },
                    set: { settings.implicationLevel = ImplicationLevel(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How should compression work?",
                options: [
                    "High compression (silence where appropriate)",
                    "Moderate compression (selective silence)",
                    "Low compression (fill gaps, explain)"
                ],
                selectedIndex: Binding(
                    get: { settings.compressionLevel.rawValue },
                    set: { settings.compressionLevel = CompressionLevel(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Register Constraints Section
    
    private var musicalConstraintsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Formality & word choice", affects: "How formal or street the bars sound and how consistent that tone stays.")
            
            QuestionView(
                question: "What register constraints should apply?",
                options: [
                    "Strict register (maintain linguistic register consistently)",
                    "Moderate register (allow register shifts when narratively strong)",
                    "Flexible register (register follows narrative needs)"
                ],
                selectedIndex: Binding(
                    get: { settings.registerStrictness.rawValue },
                    set: { settings.registerStrictness = RegisterStrictness(rawValue: $0) ?? .moderate }
                )
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Register Enforcement Weight")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
                Text("How strongly the chosen register is enforced in every line.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                HStack {
                    Text("\(Int(settings.registerWeight * 100))%")
                        .font(.headline)
                        .frame(width: 60)
                    
                    Slider(value: $settings.registerWeight, in: 0.1...0.5, step: 0.05)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Authority & Dominance Section
    
    private var voiceStyleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Confidence of the voice", affects: "How sure and commanding the bars sound vs. tentative or exploratory.")
            
            QuestionView(
                question: "How much authority should statements carry?",
                options: [
                    "High authority (final, earned statements)",
                    "Moderate authority (confident but open)",
                    "Low authority (tentative, exploratory)"
                ],
                selectedIndex: Binding(
                    get: { settings.authorityLevel.rawValue },
                    set: { settings.authorityLevel = AuthorityLevel(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How much dominance should the voice assert?",
                options: [
                    "High dominance (assertive, commanding)",
                    "Moderate dominance (confident but not overbearing)",
                    "Low dominance (collaborative, yielding)"
                ],
                selectedIndex: Binding(
                    get: { settings.dominanceLevel.rawValue },
                    set: { settings.dominanceLevel = DominanceLevel(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Exposure & Cultural Specificity Section
    
    private var outputStyleToneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal vs guarded, niche vs universal", affects: "How much the bars share, how specific the references are, and how bold or safe the choices are.")
            
            QuestionView(
                question: "How much exposure can this voice afford?",
                options: [
                    "Low exposure (guarded, minimal sharing)",
                    "Moderate exposure (selective sharing)",
                    "High exposure (open, revealing)"
                ],
                selectedIndex: Binding(
                    get: { settings.exposureLevel.rawValue },
                    set: { settings.exposureLevel = ExposureLevel(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How culturally specific should references be?",
                options: [
                    "High specificity (assume shared understanding)",
                    "Moderate specificity (some explanation)",
                    "Low specificity (universal, explained)"
                ],
                selectedIndex: Binding(
                    get: { settings.culturalSpecificity.rawValue },
                    set: { settings.culturalSpecificity = CulturalSpecificity(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How much risk can this voice afford?",
                options: [
                    "Low risk (conservative, safe choices)",
                    "Moderate risk (calculated risks)",
                    "High risk (experimental, bold choices)"
                ],
                selectedIndex: Binding(
                    get: { settings.riskTolerance.rawValue },
                    set: { settings.riskTolerance = RiskTolerance(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How symbolic should language be?",
                options: [
                    "High symbolism (fluid, abstract language)",
                    "Moderate symbolism (mix of concrete and abstract)",
                    "Low symbolism (concrete, literal language)"
                ],
                selectedIndex: Binding(
                    get: { settings.symbolismLevel.rawValue },
                    set: { settings.symbolismLevel = SymbolismLevel(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Finality & Restraint Section
    
    private var narrativeApproachSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Decisiveness & when to stay silent", affects: "How conclusive the bars feel, how minimal the wording is, and how often the AI returns no suggestion.")
            
            QuestionView(
                question: "How final should statements feel?",
                options: [
                    "High finality (conclusive, definitive)",
                    "Moderate finality (confident but open-ended)",
                    "Low finality (exploratory, provisional)"
                ],
                selectedIndex: Binding(
                    get: { settings.finalityLevel.rawValue },
                    set: { settings.finalityLevel = FinalityLevel(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How much restraint should be exercised?",
                options: [
                    "High restraint (minimal, essential only)",
                    "Moderate restraint (selective expression)",
                    "Low restraint (full expression)"
                ],
                selectedIndex: Binding(
                    get: { settings.restraintLevel.rawValue },
                    set: { settings.restraintLevel = RestraintLevel(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How much should posture shifts be allowed?",
                options: [
                    "No shifts (maintain consistent posture)",
                    "Moderate shifts (allow when narratively strong)",
                    "Flexible shifts (posture follows narrative)"
                ],
                selectedIndex: Binding(
                    get: { settings.postureShiftTolerance.rawValue },
                    set: { settings.postureShiftTolerance = PostureShiftTolerance(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "When should the system refuse to generate?",
                options: [
                    "Frequent refusal (silence when uncertain)",
                    "Moderate refusal (refuse when clearly misaligned)",
                    "Rare refusal (generate even when uncertain)"
                ],
                selectedIndex: Binding(
                    get: { settings.refusalFrequency.rawValue },
                    set: { settings.refusalFrequency = RefusalFrequency(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Musical Preferences Section
    
    private var musicalPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Flow, rhyme & beat", affects: "Density of syllables, rhyme complexity, and how tightly bars lock to the beat.")
            
            QuestionView(
                question: "How dense should the flow be?",
                options: [
                    "Sparse (breathing room, pauses)",
                    "Moderate (balanced density)",
                    "Dense (packed, rapid-fire)"
                ],
                selectedIndex: Binding(
                    get: { settings.flowDensity.rawValue },
                    set: { settings.flowDensity = FlowDensity(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How complex should rhymes be?",
                options: [
                    "Simple (basic, straightforward rhymes)",
                    "Moderate (varied rhyme patterns)",
                    "Complex (multi-syllable, intricate)"
                ],
                selectedIndex: Binding(
                    get: { settings.rhymeComplexity.rawValue },
                    set: { settings.rhymeComplexity = RhymeComplexity(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How strict should syllable variance be?",
                options: [
                    "Strict (consistent syllable counts)",
                    "Moderate (some variation allowed)",
                    "Flexible (creative freedom)"
                ],
                selectedIndex: Binding(
                    get: { settings.syllableVarianceTolerance.rawValue },
                    set: { settings.syllableVarianceTolerance = SyllableVarianceTolerance(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How tight should beat synchronization be?",
                options: [
                    "Loose (flexible timing)",
                    "Moderate (balanced sync)",
                    "Tight (precise beat alignment)"
                ],
                selectedIndex: Binding(
                    get: { settings.beatSyncPreference.rawValue },
                    set: { settings.beatSyncPreference = BeatSyncPreference(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Content Boundaries Section
    
    private var contentBoundariesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Topics, explicitness & references", affects: "What to avoid, how explicit language can be, and how personal or abstract references are.")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Topic Restrictions")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
                
                TextField("Topics to avoid (comma-separated)", text: $settings.topicRestrictions, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            .padding(.vertical, 8)
            
            QuestionView(
                question: "How should explicit content be handled?",
                options: [
                    "None (no restrictions)",
                    "Moderate (some filtering)",
                    "Strict (avoid explicit content)"
                ],
                selectedIndex: Binding(
                    get: { settings.languageRestrictions.rawValue },
                    set: { settings.languageRestrictions = LanguageRestrictions(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "What reference style should be used?",
                options: [
                    "Abstract (metaphorical, universal)",
                    "Balanced (mix of personal and abstract)",
                    "Personal (specific, concrete references)"
                ],
                selectedIndex: Binding(
                    get: { settings.referenceStyle.rawValue },
                    set: { settings.referenceStyle = ReferenceStyle(rawValue: $0) ?? .balanced }
                )
            )
            
            QuestionView(
                question: "How much shared understanding should be assumed?",
                options: [
                    "Low (universal themes)",
                    "Moderate (some cultural awareness)",
                    "High (deep cultural context)"
                ],
                selectedIndex: Binding(
                    get: { settings.culturalContextSensitivity.rawValue },
                    set: { settings.culturalContextSensitivity = CulturalContextSensitivity(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Content Generation Section
    
    private var contentGenerationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "When to return no suggestion", affects: "If the AI’s confidence is below this level, it returns nothing instead of a weak bar.")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Silence Threshold")
                    .font(.subheadline)
                    .foregroundStyle(Momentum.contentSecondary)
                Text("Left = suggest more often (even when unsure). Right = only suggest when confident.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                HStack {
                    Text("Suggest more")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("Refuse more")
                        .font(.caption)
                }
                
                HStack {
                    Text("\(String(format: "%.1f", settings.silenceThreshold))")
                        .font(.headline)
                        .frame(width: 60)
                    
                    Slider(value: $settings.silenceThreshold, in: 0.0...0.8, step: 0.1)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Section Header with "Affects" subtitle

private struct SectionHeader: View {
    let title: String
    let affects: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text("Affects: \(affects)")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
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
                .fill(.ultraThinMaterial)
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
