//
// APIDebugInspector.swift
//
// Debug tool to inspect what data is being sent to the OpenAI API
// for rap suggestion generation. Shows signal layer, constraints,
// lexicon, themes, registers, and all other components.
//

import Foundation
import SwiftUI
import Combine

class APIDebugInspector: ObservableObject {
    static let shared = APIDebugInspector()
    
    @Published var lastRequest: APIRequestDebugInfo?
    @Published var lastResponse: APIResponseDebugInfo?
    @Published var isEnabled: Bool = true // Set to false to disable logging
    
    private init() {}
    
    struct APIRequestDebugInfo {
        let timestamp: Date
        let model: String
        let systemMessage: String
        let userPrompt: String
        let fullText: String
        let narrativeAnalysis: NarrativeAnalysisSummary
        let signalLayer: SignalLayerSummary
        let constraints: ConstraintsSummary?
        let registers: RegistersSummary?
        let lexicon: LexiconSummary
        let metrics: MetricsSummary
        let settings: SettingsSummary
        let requestBodyJSON: String // Pretty-printed JSON
    }
    
    struct NarrativeAnalysisSummary {
        let primaryThemes: [String]
        let secondaryThemes: [String]
        let underlyingThemes: [String]?
        let emotionalTone: String
        let narrativePhase: String
        let perspective: String
        let voiceType: String?
        let topicTreatmentModes: String
        let contradictions: [String]
        let momentum: String?
        let contextualPlacement: String?
        let keyPhrases: [String]
        let storyElements: [String]
        let continuationNeeds: String
    }
    
    struct SignalLayerSummary {
        let signalProfile: String
        let signalMode: String
        let signalAxes: String
        let axisProfile: String?
    }
    
    struct ConstraintsSummary {
        let promptInstructions: String
        let blockedLanguagePatterns: [String]
        let requiredImplications: [String]
        let preferredOutcomes: [String]
        let reductionRules: [String]
    }
    
    struct RegistersSummary {
        let noRepair: Bool
        let isolation: Bool
        let vulnerability: Bool
        let refusal: Bool
        let closure: Bool
        let stabilization: Bool
    }
    
    struct LexiconSummary {
        let termCount: Int
        let terms: [String] // First 20 terms
        let categories: [String]
    }
    
    struct MetricsSummary {
        let fullText: String
        let syllableTarget: Int?
        let rhymeTarget: String?
        let rhymeScheme: String?
        let averageSyllables: Double
        let bpm: Int?
        let key: String?
        let scale: String?
    }
    
    struct SettingsSummary {
        let editorialProtection: String
        let implicationLevel: String
        let compressionLevel: String
        let authorityLevel: String
        let exposureLevel: String
        let silenceThreshold: Double
        let refusalFrequency: String
    }
    
    // MARK: - Response Debug Info
    
    struct APIResponseDebugInfo {
        let timestamp: Date
        let statusCode: Int
        let responseBodyJSON: String // Pretty-printed JSON
        let responseHeaders: [String: String]
        let duration: TimeInterval // milliseconds
        let responseSize: Int // bytes
        let inputTokens: Int?
        let outputTokens: Int?
        let totalTokens: Int?
        let parsingSuccess: Bool
        let parsingErrors: [String]
        let validationResult: JSONValidationService.ValidationResult?
    }
    
    func logRequest(
        model: String,
        systemMessage: String,
        userPrompt: String,
        fullText: String,
        narrative: NarrativeAnalysis,
        signalProfile: SignalProfile?,
        signalMode: SignalMode?,
        signalAxes: SignalAxes?,
        axisProfile: AxisProfile?,
        constraints: ConstraintRules?,
        registers: RegisterProfile?,
        lexiconTerms: [LexiconTerm],
        metrics: RapMetrics,
        settings: ModelSettings,
        requestBody: [String: Any]
    ) {
        guard isEnabled else { return }
        
        // Format narrative analysis
        let narrativeSummary = NarrativeAnalysisSummary(
            primaryThemes: narrative.primaryThemes,
            secondaryThemes: narrative.secondaryThemes,
            underlyingThemes: narrative.underlyingThemes,
            emotionalTone: narrative.detectedTones.map(\.rawValue).joined(separator: ", "),
            narrativePhase: narrative.narrativePhase.rawValue,
            perspective: narrative.perspective.rawValue,
            voiceType: narrative.voiceType,
            topicTreatmentModes: formatTopicModes(narrative.topicTreatmentModes),
            contradictions: narrative.thematicContradictions ?? [],
            momentum: narrative.narrativeMomentum,
            contextualPlacement: narrative.contextualPlacement,
            keyPhrases: narrative.keyPhrases ?? [],
            storyElements: narrative.storyElements ?? [],
            continuationNeeds: narrative.continuationNeeds ?? "continue narrative progression"
        )
        
        // Format signal layer
        let signalSummary = SignalLayerSummary(
            signalProfile: formatSignalProfile(signalProfile),
            signalMode: signalMode?.description ?? "Unknown",
            signalAxes: formatSignalAxes(signalAxes),
            axisProfile: formatAxisProfile(axisProfile)
        )
        
        // Format constraints
        let constraintsSummary = constraints.map { (c: ConstraintRules) -> ConstraintsSummary in
            ConstraintsSummary(
                promptInstructions: c.promptInstructions,
                blockedLanguagePatterns: c.blockedLanguagePatterns,
                requiredImplications: c.requiredImplications,
                preferredOutcomes: c.preferredOutcomes,
                reductionRules: c.reductionRules
            )
        }
        
        // Format registers
        let registersSummary = registers.map { r in
            RegistersSummary(
                noRepair: r.register_noRepairPosition,
                isolation: r.register_isolationPosition,
                vulnerability: r.register_vulnerabilityPosition,
                refusal: r.register_refusalPosition,
                closure: r.register_closurePosition,
                stabilization: r.register_stabilizationPosition
            )
        }
        
        // Format lexicon
        let lexiconCategories = Set(lexiconTerms.map { $0.category.rawValue }).sorted()
        let lexiconSummary = LexiconSummary(
            termCount: lexiconTerms.count,
            terms: Array(lexiconTerms.prefix(20)).map { $0.term },
            categories: Array(lexiconCategories)
        )
        
        // Format metrics
        let metricsSummary = MetricsSummary(
            fullText: metrics.fullText,
            syllableTarget: metrics.syllableTarget,
            rhymeTarget: metrics.rhymeTarget,
            rhymeScheme: metrics.rhymeScheme,
            averageSyllables: metrics.averageSyllables,
            bpm: metrics.bpm,
            key: metrics.key,
            scale: metrics.scale
        )
        
        // Format settings
        let settingsSummary = SettingsSummary(
            editorialProtection: String(describing: settings.editorialProtection),
            implicationLevel: String(describing: settings.implicationLevel),
            compressionLevel: String(describing: settings.compressionLevel),
            authorityLevel: String(describing: settings.authorityLevel),
            exposureLevel: String(describing: settings.exposureLevel),
            silenceThreshold: settings.silenceThreshold,
            refusalFrequency: String(describing: settings.refusalFrequency)
        )
        
        // Format request body as JSON
        let requestBodyJSON: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: [.prettyPrinted, .sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            requestBodyJSON = jsonString
        } else {
            requestBodyJSON = "Failed to serialize request body"
        }
        
        let debugInfo = APIRequestDebugInfo(
            timestamp: Date(),
            model: model,
            systemMessage: systemMessage,
            userPrompt: userPrompt,
            fullText: fullText,
            narrativeAnalysis: narrativeSummary,
            signalLayer: signalSummary,
            constraints: constraintsSummary,
            registers: registersSummary,
            lexicon: lexiconSummary,
            metrics: metricsSummary,
            settings: settingsSummary,
            requestBodyJSON: requestBodyJSON
        )
        
        DispatchQueue.main.async {
            self.lastRequest = debugInfo
        }
        
        // Also print to console for immediate debugging
        print("\n🔍 API DEBUG INSPECTOR - Request Details:")
        print(String(repeating: "=", count: 80))
        print("Model: \(model)")
        print("Full Text Length: \(fullText.count) characters")
        print("Primary Themes: \(narrative.primaryThemes.joined(separator: ", "))")
        print("Signal Mode: \(signalMode?.description ?? "Unknown")")
        print("Constraints: \(constraints != nil ? "Present (\(constraints!.promptInstructions.count) chars)" : "None")")
        print("Registers: \(registers != nil ? "Present" : "None")")
        print("Lexicon Terms: \(lexiconTerms.count)")
        print("BPM: \(metrics.bpm?.description ?? "None")")
        print("Key: \(metrics.key ?? "None")")
        print("Scale: \(metrics.scale ?? "None")")
        print(String(repeating: "=", count: 80))
    }
    
    // MARK: - Response Logging
    
    func logResponse(
        statusCode: Int,
        responseBody: Data,
        responseHeaders: [String: String],
        duration: TimeInterval,
        inputTokens: Int? = nil,
        outputTokens: Int? = nil,
        totalTokens: Int? = nil,
        parsingSuccess: Bool,
        parsingErrors: [String] = [],
        validationResult: JSONValidationService.ValidationResult? = nil
    ) {
        guard isEnabled else { return }
        
        // Format response body as JSON
        let responseBodyJSON: String
        if let jsonObject = try? JSONSerialization.jsonObject(with: responseBody),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            responseBodyJSON = jsonString
        } else {
            responseBodyJSON = String(data: responseBody, encoding: .utf8) ?? "Unable to decode response body"
        }
        
        let responseInfo = APIResponseDebugInfo(
            timestamp: Date(),
            statusCode: statusCode,
            responseBodyJSON: responseBodyJSON,
            responseHeaders: responseHeaders,
            duration: duration * 1000, // Convert to milliseconds
            responseSize: responseBody.count,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            totalTokens: totalTokens,
            parsingSuccess: parsingSuccess,
            parsingErrors: parsingErrors,
            validationResult: validationResult
        )
        
        DispatchQueue.main.async {
            self.lastResponse = responseInfo
        }
        
        // Print to console
        print("\n📥 API DEBUG INSPECTOR - Response Details:")
        print(String(repeating: "=", count: 80))
        print("Status Code: \(statusCode)")
        print("Duration: \(String(format: "%.2f", duration * 1000))ms")
        print("Response Size: \(responseBody.count) bytes")
        if let inputTokens = inputTokens, let outputTokens = outputTokens {
            print("Tokens: \(inputTokens + outputTokens) total (\(inputTokens) in, \(outputTokens) out)")
        }
        print("Parsing Success: \(parsingSuccess)")
        if !parsingErrors.isEmpty {
            print("Parsing Errors: \(parsingErrors.joined(separator: "; "))")
        }
         if let validation = validationResult {
             let validationStatus = validation.isValid ? "✅ Valid" : "❌ Invalid (\(validation.errors.count) errors)"
             print("Validation: \(validationStatus)")
         }
        print(String(repeating: "=", count: 80))
    }
    
    // MARK: - Formatting Helpers
    
    private func formatTopicModes(_ modes: TopicTreatmentModes?) -> String {
        guard let modes = modes else { return "Not detected" }
        var parts: [String] = []
        if let women = modes.women, women != "not-present" {
            parts.append("Women: \(women)")
        }
        if let wealth = modes.wealth {
            parts.append("Wealth: \(wealth)")
        }
        if let success = modes.success {
            parts.append("Success: \(success)")
        }
        return parts.isEmpty ? "Not detected" : parts.joined(separator: ", ")
    }
    
    private func formatSignalProfile(_ profile: SignalProfile?) -> String {
        guard let profile = profile else { return "Not available" }
        // SignalProfile doesn't have numeric properties - return weak signal info instead
        var parts: [String] = []
        if let themes = profile.themeCandidates, !themes.isEmpty {
            parts.append("Themes: \(themes.joined(separator: ", "))")
        }
        if let emotions = profile.emotionalCues, !emotions.isEmpty {
            let emotionStrings = emotions.map { emotion in
                if let intensity = emotion.intensity {
                    return "\(emotion.emotion): \(String(format: "%.2f", intensity))"
                } else {
                    return emotion.emotion
                }
            }
            parts.append("Emotions: \(emotionStrings.joined(separator: ", "))")
        }
        if let perspective = profile.perspectiveHint {
            parts.append("Perspective: \(perspective.rawValue)")
        }
        if let entities = profile.entityHints, !entities.isEmpty {
            let entityStrings = entities.map { "\($0.type.rawValue): \($0.value)" }
            parts.append("Entities: \(entityStrings.joined(separator: ", "))")
        }
        return parts.isEmpty ? "No weak signals detected" : parts.joined(separator: "\n        ")
    }
    
    private func formatSignalAxes(_ axes: SignalAxes?) -> String {
        guard let axes = axes else { return "Not available" }
        return """
        Exposure Risk: \(axes.exposureRisk.rawValue)
        Authority Posture: \(axes.authorityPosture.rawValue)
        Social Action: \(axes.socialAction.rawValue)
        Audience Scope: \(axes.audienceScope.rawValue)
        """
    }
    
    private func formatAxisProfile(_ profile: AxisProfile?) -> String? {
        guard let profile = profile else { return nil }
        return """
        Exposure Guarding: \(String(format: "%.2f", profile.exposure_guarding))
        Dominance/Vulnerability: \(String(format: "%.2f", profile.dominance_vulnerability))
        Authority Aspiration: \(String(format: "%.2f", profile.authority_aspiration))
        Literal/Symbolic: \(String(format: "%.2f", profile.literal_symbolic))
        Cultural Specificity: \(String(format: "%.2f", profile.cultural_specificity))
        Social Function: \(String(format: "%.2f", profile.social_function))
        """
    }
}

// MARK: - Debug View

struct APIDebugInspectorView: View {
    @ObservedObject private var inspector = APIDebugInspector.shared
    @State private var selectedSection: DebugSection = .overview
    
    enum DebugSection: String, CaseIterable {
        case overview = "Overview"
        case narrative = "Narrative"
        case signalLayer = "Signal Layer"
        case constraints = "Constraints"
        case registers = "Registers"
        case lexicon = "Lexicon"
        case metrics = "Metrics"
        case settings = "Settings"
        case requestJSON = "Request JSON"
        case response = "Response"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let request = inspector.lastRequest {
                VStack(spacing: 0) {
                    Picker("Section", selection: $selectedSection) {
                        ForEach(DebugSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    List {
                        switch selectedSection {
                        case .overview:
                            overviewSection(request: request)
                        case .narrative:
                            narrativeSection(request: request)
                        case .signalLayer:
                            signalLayerSection(request: request)
                        case .constraints:
                            constraintsSection(request: request)
                        case .registers:
                            registersSection(request: request)
                        case .lexicon:
                            lexiconSection(request: request)
                        case .metrics:
                            metricsSection(request: request)
                        case .settings:
                            settingsSection(request: request)
                        case .requestJSON:
                            requestJSONSection(request: request)
                        case .response:
                            if let response = inspector.lastResponse {
                                responseSection(response: response)
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "arrow.down.circle")
                                        .font(.system(size: 48))
                                        .foregroundStyle(.secondary)
                                    
                                    Text("No Response Logged")
                                        .font(.headline)
                                    
                                    Text("Response will appear here after the API call completes.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("No API Request Logged")
                        .font(.headline)
                    
                    Text("Generate suggestions using the AI sparkle button to see what data is being sent to the API.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Section Views
    
    private func overviewSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("Request Info") {
                LabeledContent("Model", value: request.model)
                LabeledContent("Timestamp", value: request.timestamp.formatted())
                LabeledContent("Full Text Length", value: "\(request.fullText.count) characters")
            }
            
            Section("Narrative Analysis") {
                LabeledContent("Primary Themes", value: "\(request.narrativeAnalysis.primaryThemes.count)")
                LabeledContent("Secondary Themes", value: "\(request.narrativeAnalysis.secondaryThemes.count)")
                LabeledContent("Emotional Tone", value: request.narrativeAnalysis.emotionalTone)
                LabeledContent("Narrative Phase", value: request.narrativeAnalysis.narrativePhase)
            }
            
            Section("Signal Layer") {
                LabeledContent("Signal Mode", value: request.signalLayer.signalMode)
                LabeledContent("Constraints", value: request.constraints != nil ? "Present" : "None")
                LabeledContent("Registers", value: request.registers != nil ? "Present" : "None")
            }
            
            Section("Lexicon & Metrics") {
                LabeledContent("Lexicon Terms", value: "\(request.lexicon.termCount)")
                LabeledContent("BPM", value: request.metrics.bpm?.description ?? "None")
                LabeledContent("Key", value: request.metrics.key ?? "None")
                LabeledContent("Scale", value: request.metrics.scale ?? "None")
            }
        }
    }
    
    private func narrativeSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("Themes") {
                if !request.narrativeAnalysis.primaryThemes.isEmpty {
                    DisclosureGroup("Primary Themes (\(request.narrativeAnalysis.primaryThemes.count))") {
                        ForEach(request.narrativeAnalysis.primaryThemes, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                }
                
                if !request.narrativeAnalysis.secondaryThemes.isEmpty {
                    DisclosureGroup("Secondary Themes (\(request.narrativeAnalysis.secondaryThemes.count))") {
                        ForEach(request.narrativeAnalysis.secondaryThemes, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                }
                
                if let underlying = request.narrativeAnalysis.underlyingThemes, !underlying.isEmpty {
                    DisclosureGroup("Underlying Themes (\(underlying.count))") {
                        ForEach(underlying, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                }
            }
            
            Section("Analysis") {
                LabeledContent("Emotional Tone", value: request.narrativeAnalysis.emotionalTone)
                LabeledContent("Narrative Phase", value: request.narrativeAnalysis.narrativePhase)
                LabeledContent("Perspective", value: request.narrativeAnalysis.perspective)
                if let voiceType = request.narrativeAnalysis.voiceType {
                    LabeledContent("Voice Type", value: voiceType)
                }
            }
            
            Section("Topic Treatment") {
                Text(request.narrativeAnalysis.topicTreatmentModes)
            }
            
            Section("Momentum & Context") {
                if let momentum = request.narrativeAnalysis.momentum {
                    LabeledContent("Momentum", value: momentum)
                }
                if let placement = request.narrativeAnalysis.contextualPlacement {
                    LabeledContent("Contextual Placement", value: placement)
                }
            }
            
            Section("Key Phrases & Elements") {
                if !request.narrativeAnalysis.keyPhrases.isEmpty {
                    DisclosureGroup("Key Phrases") {
                        ForEach(request.narrativeAnalysis.keyPhrases, id: \.self) { phrase in
                            Text(phrase)
                        }
                    }
                }
                
                if !request.narrativeAnalysis.storyElements.isEmpty {
                    DisclosureGroup("Story Elements") {
                        ForEach(request.narrativeAnalysis.storyElements, id: \.self) { element in
                            Text(element)
                        }
                    }
                }
            }
        }
    }
    
    private func signalLayerSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("Signal Profile") {
                Text(request.signalLayer.signalProfile)
                    .font(.system(.body, design: .monospaced))
            }
            
            Section("Signal Mode") {
                Text(request.signalLayer.signalMode)
            }
            
            Section("Signal Axes") {
                Text(request.signalLayer.signalAxes)
                    .font(.system(.body, design: .monospaced))
            }
            
            if let axisProfile = request.signalLayer.axisProfile {
                Section("Axis Profile") {
                    Text(axisProfile)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
    }
    
    private func constraintsSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            if let constraints = request.constraints {
                Section("Prompt Instructions") {
                    ScrollView {
                        Text(constraints.promptInstructions)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                }
                
                if !constraints.blockedLanguagePatterns.isEmpty {
                    Section("Blocked Language Patterns") {
                        ForEach(constraints.blockedLanguagePatterns, id: \.self) { pattern in
                            Text(pattern)
                        }
                    }
                }
                
                if !constraints.requiredImplications.isEmpty {
                    Section("Required Implications") {
                        ForEach(constraints.requiredImplications, id: \.self) { implication in
                            Text(implication)
                        }
                    }
                }
                
                if !constraints.preferredOutcomes.isEmpty {
                    Section("Preferred Outcomes") {
                        ForEach(constraints.preferredOutcomes, id: \.self) { outcome in
                            Text(outcome)
                        }
                    }
                }
                
                if !constraints.reductionRules.isEmpty {
                    Section("Reduction Rules") {
                        ForEach(constraints.reductionRules, id: \.self) { rule in
                            Text(rule)
                        }
                    }
                }
            } else {
                Section {
                    Text("No constraints applied")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func registersSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            if let registers = request.registers {
                Section("Register Positions") {
                    if registers.noRepair {
                        Label("No Repair Position", systemImage: "checkmark.circle.fill")
                    }
                    if registers.isolation {
                        Label("Isolation Position", systemImage: "checkmark.circle.fill")
                    }
                    if registers.vulnerability {
                        Label("Vulnerability Position", systemImage: "checkmark.circle.fill")
                    }
                    if registers.refusal {
                        Label("Refusal Position", systemImage: "checkmark.circle.fill")
                    }
                    if registers.closure {
                        Label("Closure Position", systemImage: "checkmark.circle.fill")
                    }
                    if registers.stabilization {
                        Label("Stabilization Position", systemImage: "checkmark.circle.fill")
                    }
                }
            } else {
                Section {
                    Text("No registers detected")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func lexiconSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("Summary") {
                LabeledContent("Total Terms", value: "\(request.lexicon.termCount)")
                LabeledContent("Categories", value: "\(request.lexicon.categories.count)")
            }
            
            Section("Categories") {
                ForEach(request.lexicon.categories, id: \.self) { category in
                    Text(category)
                }
            }
            
            Section("Sample Terms (first 20)") {
                ForEach(request.lexicon.terms, id: \.self) { term in
                    Text(term)
                }
            }
        }
    }
    
    private func metricsSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("Text Metrics") {
                LabeledContent("Full Text Length", value: "\(request.metrics.fullText.count) characters")
                LabeledContent("Average Syllables", value: String(format: "%.1f", request.metrics.averageSyllables))
            }
            
            Section("Musical Constraints") {
                if let syllableTarget = request.metrics.syllableTarget {
                    LabeledContent("Syllable Target", value: "\(syllableTarget)")
                }
                if let rhymeTarget = request.metrics.rhymeTarget {
                    LabeledContent("Rhyme Target", value: rhymeTarget)
                }
                if let rhymeScheme = request.metrics.rhymeScheme {
                    LabeledContent("Rhyme Scheme", value: rhymeScheme)
                }
            }
            
            Section("Musical Metadata") {
                LabeledContent("BPM", value: request.metrics.bpm?.description ?? "None")
                LabeledContent("Key", value: request.metrics.key ?? "None")
                LabeledContent("Scale", value: request.metrics.scale ?? "None")
            }
        }
    }
    
    private func settingsSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("Editorial Settings") {
                LabeledContent("Editorial Protection", value: request.settings.editorialProtection)
                LabeledContent("Implication Level", value: request.settings.implicationLevel)
                LabeledContent("Compression Level", value: request.settings.compressionLevel)
            }
            
            Section("Authority & Exposure") {
                LabeledContent("Authority Level", value: request.settings.authorityLevel)
                LabeledContent("Exposure Level", value: request.settings.exposureLevel)
            }
            
            Section("Silence & Refusal") {
                LabeledContent("Silence Threshold", value: String(format: "%.2f", request.settings.silenceThreshold))
                LabeledContent("Refusal Frequency", value: request.settings.refusalFrequency)
            }
        }
    }
    
    private func requestJSONSection(request: APIDebugInspector.APIRequestDebugInfo) -> some View {
        Group {
            Section("System Message") {
                ScrollView {
                    Text(request.systemMessage)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .frame(minHeight: 200, maxHeight: 400)
            }
            
            Section("User Prompt") {
                ScrollView {
                    Text(request.userPrompt)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .frame(minHeight: 200, maxHeight: 400)
            }
            
            Section("Full Request JSON") {
                ScrollView {
                    Text(request.requestBodyJSON)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .frame(minHeight: 200, maxHeight: 500)
            }
        }
    }
    
    private func responseSection(response: APIDebugInspector.APIResponseDebugInfo) -> some View {
        Group {
            Section("Response Info") {
                LabeledContent("Status Code", value: "\(response.statusCode)")
                LabeledContent("Duration", value: "\(String(format: "%.2f", response.duration))ms")
                LabeledContent("Response Size", value: "\(response.responseSize) bytes")
                if let totalTokens = response.totalTokens {
                    LabeledContent("Total Tokens", value: "\(totalTokens)")
                }
                if let inputTokens = response.inputTokens, let outputTokens = response.outputTokens {
                    LabeledContent("Input Tokens", value: "\(inputTokens)")
                    LabeledContent("Output Tokens", value: "\(outputTokens)")
                }
                LabeledContent("Parsing Success", value: response.parsingSuccess ? "✅ Yes" : "❌ No")
            }
            
            if !response.parsingErrors.isEmpty {
                Section("Parsing Errors") {
                    ForEach(response.parsingErrors, id: \.self) { error in
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if let validation = response.validationResult {
                Section("JSON Validation") {
                    LabeledContent("Valid", value: validation.isValid ? "✅ Yes" : "❌ No")
                    LabeledContent("Errors", value: "\(validation.errors.count)")
                    LabeledContent("Warnings", value: "\(validation.warnings.count)")
                    
                    if !validation.errors.isEmpty {
                        DisclosureGroup("Validation Errors") {
                            ForEach(Array(validation.errors.enumerated()), id: \.offset) { index, error in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Field: \(error.field)")
                                        .font(.caption.weight(.semibold))
                                    Text(error.message)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    
                    if !validation.warnings.isEmpty {
                        DisclosureGroup("Validation Warnings") {
                            ForEach(Array(validation.warnings.enumerated()), id: \.offset) { index, warning in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Field: \(warning.field)")
                                        .font(.caption.weight(.semibold))
                                    Text(warning.message)
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }
            
            if !response.responseHeaders.isEmpty {
                Section("Response Headers") {
                    ForEach(Array(response.responseHeaders.keys.sorted()), id: \.self) { key in
                        LabeledContent(key, value: response.responseHeaders[key] ?? "")
                    }
                }
            }
            
            Section("Response Body JSON") {
                ScrollView {
                    Text(response.responseBodyJSON)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 400)
            }
        }
    }
}
