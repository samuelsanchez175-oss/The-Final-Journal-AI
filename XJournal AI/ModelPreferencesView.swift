import SwiftUI

// MARK: - Model Preferences View

struct ModelPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedModel: SuggestionModel = .modelG
    @State private var modelGSettings = ModelSettings()
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
                        if selectedModel == .modelG {
                            ModelSettingsForm(settings: $modelGSettings, modelName: "Model G")
                        } else {
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
                        Image(systemName: model == .modelG ? "sparkles" : "sparkles.rectangle.stack")
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
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        // Load Model G settings
        if let data = UserDefaults.standard.data(forKey: "modelG_settings"),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            modelGSettings = decoded
        }
        
        // Load Model Y settings
        if let data = UserDefaults.standard.data(forKey: "modelY_settings"),
           let decoded = try? JSONDecoder().decode(ModelSettings.self, from: data) {
            modelYSettings = decoded
        }
    }
    
    private func saveSettings() {
        // Save Model G settings
        if let encoded = try? JSONEncoder().encode(modelGSettings) {
            UserDefaults.standard.set(encoded, forKey: "modelG_settings")
        }
        
        // Save Model Y settings
        if let encoded = try? JSONEncoder().encode(modelYSettings) {
            UserDefaults.standard.set(encoded, forKey: "modelY_settings")
        }
    }
}

// MARK: - Model Settings Form

struct ModelSettingsForm: View {
    @Binding var settings: ModelSettings
    let modelName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
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
            
            // Creativity & Originality Section
            creativityOriginalitySection
            
            Divider()
            
            // Content Generation Section
            contentGenerationSection
        }
    }
    
    // MARK: - Priority Section
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Priority & Focus")
                .font(.headline)
            
            QuestionView(
                question: "What should be the highest priority?",
                options: [
                    "Balanced approach (all aspects equally important)",
                    "Musical flow & rhythm (flow is everything)",
                    "Thematic depth & narrative (story is everything)",
                    "Voice consistency (match user's voice strictly)"
                ],
                selectedIndex: Binding(
                    get: { settings.priorityFocus.rawValue },
                    set: { settings.priorityFocus = PriorityFocus(rawValue: $0) ?? .balanced }
                )
            )
        }
    }
    
    // MARK: - Thematic Complexity Section
    
    private var thematicComplexitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thematic Complexity")
                .font(.headline)
            
            QuestionView(
                question: "How should the model handle thematic contradictions/ironies?",
                options: [
                    "Preserve contradictions strictly (maintain tension)",
                    "Detect but allow smooth transitions when appropriate",
                    "Prioritize coherence over contradictions"
                ],
                selectedIndex: Binding(
                    get: { settings.contradictionHandling.rawValue },
                    set: { settings.contradictionHandling = ContradictionHandling(rawValue: $0) ?? .preserve }
                )
            )
            
            QuestionView(
                question: "How should surface themes vs underlying themes be handled?",
                options: [
                    "Maintain both layers strictly (preserve depth)",
                    "Match whatever mode the current verse is in",
                    "Allow intentional transitions between surface and depth"
                ],
                selectedIndex: Binding(
                    get: { settings.thematicLayering.rawValue },
                    set: { settings.thematicLayering = ThematicLayering(rawValue: $0) ?? .maintainBoth }
                )
            )
        }
    }
    
    // MARK: - Musical Constraints Section
    
    private var musicalConstraintsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Musical Constraints")
                .font(.headline)
            
            QuestionView(
                question: "How strict should musical constraints be?",
                options: [
                    "Very strict (musical flow is critical)",
                    "Moderate (balance flow with content)",
                    "Flexible (allow creative freedom)"
                ],
                selectedIndex: Binding(
                    get: { settings.musicalStrictness.rawValue },
                    set: { settings.musicalStrictness = MusicalStrictness(rawValue: $0) ?? .moderate }
                )
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Musical Constraints Weight")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("\(Int(settings.musicalWeight * 100))%")
                        .font(.headline)
                        .frame(width: 60)
                    
                    Slider(value: $settings.musicalWeight, in: 0.1...0.5, step: 0.05)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Voice & Style Section
    
    private var voiceStyleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voice & Style")
                .font(.headline)
            
            QuestionView(
                question: "How should defensive vs vulnerable voice be handled?",
                options: [
                    "Strictly match (defensive stays defensive)",
                    "Allow transitions when narratively appropriate",
                    "Detect but let AI decide based on narrative needs"
                ],
                selectedIndex: Binding(
                    get: { settings.voiceMatching.rawValue },
                    set: { settings.voiceMatching = VoiceMatching(rawValue: $0) ?? .strictMatch }
                )
            )
            
            QuestionView(
                question: "How should topic treatment modes be handled?",
                options: [
                    "Strictly match detected mode",
                    "Detect but allow mode shifts if narratively appropriate",
                    "Treat all topics the same way"
                ],
                selectedIndex: Binding(
                    get: { settings.topicModeHandling.rawValue },
                    set: { settings.topicModeHandling = TopicModeHandling(rawValue: $0) ?? .strictMatch }
                )
            )
        }
    }
    
    // MARK: - Output Style & Tone Section
    
    private var outputStyleToneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Output Style & Tone")
                .font(.headline)
            
            QuestionView(
                question: "What aggressiveness level should the output have?",
                options: [
                    "Calm (subtle, restrained)",
                    "Moderate (balanced intensity)",
                    "Aggressive (high energy, bold)"
                ],
                selectedIndex: Binding(
                    get: { settings.aggressivenessLevel.rawValue },
                    set: { settings.aggressivenessLevel = AggressivenessLevel(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "What formality level should the language use?",
                options: [
                    "Street slang (casual, authentic)",
                    "Mixed (varied register)",
                    "Formal (polished, refined)"
                ],
                selectedIndex: Binding(
                    get: { settings.formalityPreference.rawValue },
                    set: { settings.formalityPreference = FormalityPreference(rawValue: $0) ?? .mixed }
                )
            )
            
            QuestionView(
                question: "What energy level should the output have?",
                options: [
                    "Low (contemplative, mellow)",
                    "Medium (balanced energy)",
                    "High (intense, dynamic)"
                ],
                selectedIndex: Binding(
                    get: { settings.energyLevelPreference.rawValue },
                    set: { settings.energyLevelPreference = EnergyLevelPreference(rawValue: $0) ?? .medium }
                )
            )
            
            QuestionView(
                question: "How much metaphor and figurative language?",
                options: [
                    "Minimal (direct, literal)",
                    "Moderate (balanced imagery)",
                    "Heavy (rich metaphors, symbolism)"
                ],
                selectedIndex: Binding(
                    get: { settings.metaphorDensity.rawValue },
                    set: { settings.metaphorDensity = MetaphorDensity(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Narrative Approach Section
    
    private var narrativeApproachSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Narrative Approach")
                .font(.headline)
            
            QuestionView(
                question: "How should the story progress?",
                options: [
                    "Linear (chronological, straightforward)",
                    "Moderate (some variation)",
                    "Non-linear (experimental, abstract)"
                ],
                selectedIndex: Binding(
                    get: { settings.storyProgressionStyle.rawValue },
                    set: { settings.storyProgressionStyle = StoryProgressionStyle(rawValue: $0) ?? .linear }
                )
            )
            
            QuestionView(
                question: "How deep should character development be?",
                options: [
                    "Surface (simple, direct)",
                    "Moderate (some depth)",
                    "Deep (complex, layered)"
                ],
                selectedIndex: Binding(
                    get: { settings.characterDevelopmentDepth.rawValue },
                    set: { settings.characterDevelopmentDepth = CharacterDevelopmentDepth(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "What emotional range should be explored?",
                options: [
                    "Narrow (focused emotions)",
                    "Moderate (varied emotions)",
                    "Wide (full emotional spectrum)"
                ],
                selectedIndex: Binding(
                    get: { settings.emotionalRange.rawValue },
                    set: { settings.emotionalRange = EmotionalRange(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How should narratives resolve?",
                options: [
                    "Open-ended (ambiguous, thought-provoking)",
                    "Balanced (some closure)",
                    "Conclusive (clear resolution)"
                ],
                selectedIndex: Binding(
                    get: { settings.resolutionPreference.rawValue },
                    set: { settings.resolutionPreference = ResolutionPreference(rawValue: $0) ?? .balanced }
                )
            )
        }
    }
    
    // MARK: - Musical Preferences Section
    
    private var musicalPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Musical Preferences")
                .font(.headline)
            
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
            Text("Content Boundaries")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Topic Restrictions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
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
                question: "How sensitive should cultural context be?",
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
    
    // MARK: - Creativity & Originality Section
    
    private var creativityOriginalitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Creativity & Originality")
                .font(.headline)
            
            QuestionView(
                question: "Balance between adaptation and originality?",
                options: [
                    "Adaptation (draw from existing lyrics)",
                    "Balanced (mix of both)",
                    "Originality (create fresh content)"
                ],
                selectedIndex: Binding(
                    get: { settings.adaptationOriginalityBalance.rawValue },
                    set: { settings.adaptationOriginalityBalance = AdaptationOriginalityBalance(rawValue: $0) ?? .balanced }
                )
            )
            
            QuestionView(
                question: "How often should references appear?",
                options: [
                    "Rare (minimal references)",
                    "Moderate (occasional references)",
                    "Frequent (many references)"
                ],
                selectedIndex: Binding(
                    get: { settings.referenceFrequency.rawValue },
                    set: { settings.referenceFrequency = ReferenceFrequency(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How experimental should language be?",
                options: [
                    "Conservative (traditional language)",
                    "Moderate (some experimentation)",
                    "Experimental (innovative, creative)"
                ],
                selectedIndex: Binding(
                    get: { settings.experimentalLanguageTolerance.rawValue },
                    set: { settings.experimentalLanguageTolerance = ExperimentalLanguageTolerance(rawValue: $0) ?? .moderate }
                )
            )
            
            QuestionView(
                question: "How much genre blending should occur?",
                options: [
                    "Pure (stay within rap genre)",
                    "Moderate (some blending)",
                    "Blended (cross-genre elements)"
                ],
                selectedIndex: Binding(
                    get: { settings.genreBlendingPreference.rawValue },
                    set: { settings.genreBlendingPreference = GenreBlendingPreference(rawValue: $0) ?? .moderate }
                )
            )
        }
    }
    
    // MARK: - Content Generation Section
    
    private var contentGenerationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Content Generation")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Candidate Selection vs Free Generation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("\(Int(settings.candidateSelectionRatio * 100))% Candidates")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int((1 - settings.candidateSelectionRatio) * 100))% Free")
                        .font(.caption)
                }
                
                Slider(value: $settings.candidateSelectionRatio, in: 0.5...0.9, step: 0.1)
            }
            .padding(.vertical, 8)
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
                .foregroundStyle(.secondary)
            
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
                                    .foregroundStyle(.secondary)
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
    var priorityFocus: PriorityFocus = .balanced
    var contradictionHandling: ContradictionHandling = .detectAllow
    var thematicLayering: ThematicLayering = .maintainBoth
    var musicalStrictness: MusicalStrictness = .moderate
    var musicalWeight: Double = 0.17
    var voiceMatching: VoiceMatching = .strictMatch
    var topicModeHandling: TopicModeHandling = .detectAllow
    var candidateSelectionRatio: Double = 0.7
    
    // Output Style & Tone
    var aggressivenessLevel: AggressivenessLevel = .moderate
    var formalityPreference: FormalityPreference = .mixed
    var energyLevelPreference: EnergyLevelPreference = .medium
    var metaphorDensity: MetaphorDensity = .moderate
    
    // Narrative Approach
    var storyProgressionStyle: StoryProgressionStyle = .linear
    var characterDevelopmentDepth: CharacterDevelopmentDepth = .moderate
    var emotionalRange: EmotionalRange = .moderate
    var resolutionPreference: ResolutionPreference = .balanced
    
    // Musical Preferences
    var flowDensity: FlowDensity = .moderate
    var rhymeComplexity: RhymeComplexity = .moderate
    var syllableVarianceTolerance: SyllableVarianceTolerance = .moderate
    var beatSyncPreference: BeatSyncPreference = .moderate
    
    // Content Boundaries
    var topicRestrictions: String = ""
    var languageRestrictions: LanguageRestrictions = .moderate
    var referenceStyle: ReferenceStyle = .balanced
    var culturalContextSensitivity: CulturalContextSensitivity = .moderate
    
    // Creativity & Originality
    var adaptationOriginalityBalance: AdaptationOriginalityBalance = .balanced
    var referenceFrequency: ReferenceFrequency = .moderate
    var experimentalLanguageTolerance: ExperimentalLanguageTolerance = .moderate
    var genreBlendingPreference: GenreBlendingPreference = .moderate
}

enum PriorityFocus: Int, Codable {
    case balanced = 0
    case musicalFlow = 1
    case thematicDepth = 2
    case voiceConsistency = 3
}

enum ContradictionHandling: Int, Codable {
    case preserve = 0
    case detectAllow = 1
    case prioritizeCoherence = 2
}

enum ThematicLayering: Int, Codable {
    case maintainBoth = 0
    case matchCurrent = 1
    case allowTransitions = 2
}

enum MusicalStrictness: Int, Codable {
    case veryStrict = 0
    case moderate = 1
    case flexible = 2
}

enum VoiceMatching: Int, Codable {
    case strictMatch = 0
    case allowTransitions = 1
    case detectOnly = 2
}

enum TopicModeHandling: Int, Codable {
    case strictMatch = 0
    case detectAllow = 1
    case treatSame = 2
}

// MARK: - Output Style & Tone Enums

enum AggressivenessLevel: Int, Codable {
    case calm = 0
    case moderate = 1
    case aggressive = 2
}

enum FormalityPreference: Int, Codable {
    case streetSlang = 0
    case mixed = 1
    case formal = 2
}

enum EnergyLevelPreference: Int, Codable {
    case low = 0
    case medium = 1
    case high = 2
}

enum MetaphorDensity: Int, Codable {
    case minimal = 0
    case moderate = 1
    case heavy = 2
}

// MARK: - Narrative Approach Enums

enum StoryProgressionStyle: Int, Codable {
    case linear = 0
    case moderate = 1
    case nonLinear = 2
}

enum CharacterDevelopmentDepth: Int, Codable {
    case surface = 0
    case moderate = 1
    case deep = 2
}

enum EmotionalRange: Int, Codable {
    case narrow = 0
    case moderate = 1
    case wide = 2
}

enum ResolutionPreference: Int, Codable {
    case openEnded = 0
    case balanced = 1
    case conclusive = 2
}

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

// MARK: - Creativity & Originality Enums

enum AdaptationOriginalityBalance: Int, Codable {
    case adaptation = 0
    case balanced = 1
    case originality = 2
}

enum ReferenceFrequency: Int, Codable {
    case rare = 0
    case moderate = 1
    case frequent = 2
}

enum ExperimentalLanguageTolerance: Int, Codable {
    case conservative = 0
    case moderate = 1
    case experimental = 2
}

enum GenreBlendingPreference: Int, Codable {
    case pure = 0
    case moderate = 1
    case blended = 2
}
