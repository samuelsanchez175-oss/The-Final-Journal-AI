//
// ContentView.CCV.12.swift
//
// This file contains ProfilePopoverView, FlowLayout, and related profile views.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings, KeychainHelper, lightHaptic)
// - Momentum/MomentumDesignSystem.swift (tokens, AtmosphereGlow, MomentumSectionHeader)
//
import SwiftUI
import SwiftData
import UIKit
import PhotosUI

// MARK: - User Personal Details

struct UserPersonalDetails: Codable {
    var locations: [String] = []
    var people: [String] = []
    var themes: [String] = []
    var interests: [String] = []
    var background: String = ""
}

// MARK: - Suggestion Defaults (Profile)

/// Profile defines suggestion defaults. Session-specific direction (tone, rhyme groups, intent) is set on the Model G control surface when you suggest lines.
struct SuggestionDefaultsSection: View {
    @AppStorage("suggestion_default_line_count") private var defaultLineCount: Int = 4
    @AppStorage("suggestion_safe_language") private var safeLanguage: Bool = true
    @AppStorage("suggestion_density") private var densityRaw: String = "moderate"

    private var density: SuggestionDensity {
        get { SuggestionDensity(rawValue: densityRaw) ?? .moderate }
        set { densityRaw = newValue.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentumSectionHeader(title: "Suggestion Defaults")
            Text("Defaults for new suggestions. Per-session direction is set on the Model G control surface when you generate.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Default line count")
                        .font(.subheadline)
                    Spacer()
                    Picker("", selection: $defaultLineCount) {
                        Text("2").tag(2)
                        Text("4").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 120)
                }
                Toggle("Safe language level", isOn: $safeLanguage)
                    .font(.subheadline)
                HStack {
                    Text("Density")
                        .font(.subheadline)
                    Spacer()
                    Picker("", selection: Binding(get: { density }, set: { newValue in
                        UserDefaults.standard.set(newValue.rawValue, forKey: "suggestion_density")
                    })) {
                        Text("Minimal").tag(SuggestionDensity.minimal)
                        Text("Moderate").tag(SuggestionDensity.moderate)
                        Text("Full").tag(SuggestionDensity.full)
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 140)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                            .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
                    )
            )
        }
    }
}

enum SuggestionDensity: String, CaseIterable {
    case minimal
    case moderate
    case full
}

// MARK: - Profile Tabs (concrete segmented control for the Profile page)

/// The three zones of the Profile page. Concrete (not a generic segmented control)
/// so the large view bodies in this file keep type-checking fast.
enum ProfileTab: String, CaseIterable, Identifiable {
    case you, ai, app
    var id: String { rawValue }
    var label: String {
        switch self {
        case .you: return "You"
        case .ai:  return "AI"
        case .app: return "App"
        }
    }
}

/// Flat editorial pill segmented control: white track + hairline, the selected segment
/// fills with the inverse (dark) surface. A coral dot flags a tab that needs attention.
struct MomentumProfileTabs: View {
    @Binding var selection: ProfileTab
    var attention: Set<ProfileTab> = []

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProfileTab.allCases) { tab in
                let isSelected = selection == tab
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    withAnimation(.easeOut(duration: 0.18)) { selection = tab }
                } label: {
                    HStack(spacing: 5) {
                        Text(tab.label)
                            .font(.system(size: 15, weight: .semibold))
                        if attention.contains(tab) && !isSelected {
                            Circle()
                                .fill(Momentum.accent)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .foregroundStyle(isSelected ? Momentum.onInverse : Momentum.contentSecondary)
                    .background(
                        Capsule(style: .continuous)
                            .fill(isSelected ? Momentum.inverseSurface : Color.clear)
                    )
                    .contentShape(Capsule(style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
            }
        }
        .padding(4)
        .background(
            Capsule(style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(Capsule(style: .continuous).stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
        )
    }
}

// MARK: - Profile Page (Momentum reskin + single top-right Save)

struct ProfilePopoverView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage("profile_name") private var storedName: String = ""
    @AppStorage("profile_email") private var storedEmail: String = ""
    @AppStorage("profile_phone") private var storedPhone: String = ""
    @AppStorage("profile_avatar_data") private var storedAvatarData: Data?

    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var showPersonalizationSheet: Bool = false
    @State private var showModelPreferences: Bool = false
    @State private var selectedTab: ProfileTab = .you
    @State private var didRouteInitialTab: Bool = false

    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var openAIKeyDraft: String = ""
    @State private var geniusKeyDraft: String = ""
    @AppStorage("transcription_backend") private var transcriptionBackend: String = "apple"
    @State private var showSaveConfirmation: Bool = false
    @State private var hasUnsavedChanges: Bool = false

    // App version info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    private func exportUserData() {
        // TODO: Implement data export (journal entries, profile, settings).
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        print("Export data functionality - to be implemented")
    }

    init() {
        // Initialize from @AppStorage values to ensure consistency
        let defaults = UserDefaults.standard
        _name = State(initialValue: defaults.string(forKey: "profile_name") ?? "")
        _email = State(initialValue: defaults.string(forKey: "profile_email") ?? "")
        _phone = State(initialValue: defaults.string(forKey: "profile_phone") ?? "")
    }

    private var isEmailValid: Bool {
        if email.isEmpty { return true } // Email is optional
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    private var isPhoneValid: Bool {
        if phone.isEmpty { return true } // Phone is optional
        let digitsOnly = phone.filter(\.isNumber)
        return digitsOnly.count == 10 || digitsOnly.count == 11
    }

    private func formatPhoneNumber(_ input: String) -> String {
        let digitsOnly = input.filter(\.isNumber)

        if digitsOnly.count == 10 {
            let areaCode = String(digitsOnly.prefix(3))
            let firstPart = String(digitsOnly.dropFirst(3).prefix(3))
            let lastPart = String(digitsOnly.dropFirst(6))
            return "(\(areaCode)) \(firstPart)-\(lastPart)"
        }

        if digitsOnly.count == 11 {
            let countryCode = String(digitsOnly.prefix(1))
            let areaCode = String(digitsOnly.dropFirst(1).prefix(3))
            let firstPart = String(digitsOnly.dropFirst(4).prefix(3))
            let lastPart = String(digitsOnly.dropFirst(7))
            return "+\(countryCode) (\(areaCode)) \(firstPart)-\(lastPart)"
        }

        return input
    }

    private func hasPersonalDetails() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "user_personal_details"),
           let details = try? JSONDecoder().decode(UserPersonalDetails.self, from: data) {
            return !details.locations.isEmpty ||
                   !details.people.isEmpty ||
                   !details.themes.isEmpty ||
                   !details.interests.isEmpty ||
                   !details.background.isEmpty
        }
        return false
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                profileContentSection
                    .padding(Momentum.edge)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .background(AtmosphereGlow())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { persist(thenDismiss: true) }
                        .fontWeight(.semibold)
                }
            }
            .overlay(alignment: .top) { saveConfirmationToast }
            .onAppear { loadOnAppear() }
            .onDisappear { if hasUnsavedChanges { persist() } }
            .onChange(of: selectedItem) { _, newItem in handleAvatarPick(newItem) }
            .onChange(of: openAIKeyDraft) { _, _ in hasUnsavedChanges = true }
            .onChange(of: geniusKeyDraft) { _, _ in hasUnsavedChanges = true }
        }
    }

    @ViewBuilder private var saveConfirmationToast: some View {
        if showSaveConfirmation {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Momentum.accent)
                Text("Saved")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Momentum.contentPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(Capsule().stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
            )
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: Actions

    private func loadOnAppear() {
        if let data = storedAvatarData, let uiImage = UIImage(data: data) {
            avatarImage = Image(uiImage: uiImage)
        }
        name = storedName
        email = storedEmail
        phone = storedPhone
        openAIKeyDraft = KeychainHelper.shared.getAPIKey() ?? ""
        geniusKeyDraft = KeychainHelper.shared.getGeniusAPIKey() ?? ""
        hasUnsavedChanges = false
        showSaveConfirmation = false

        // First open with no key → land on AI so setup isn't hidden behind a tab.
        if !didRouteInitialTab {
            didRouteInitialTab = true
            if openAIKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                selectedTab = .ai
            }
        }
    }

    private func handleAvatarPick(_ newItem: PhotosPickerItem?) {
        guard let newItem else { return }
        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    avatarImage = Image(uiImage: uiImage)
                    if let jpegData = uiImage.jpegData(compressionQuality: 0.9) {
                        storedAvatarData = jpegData
                        hasUnsavedChanges = true
                    }
                }
            }
        }
    }

    /// Persist all valid fields to storage.
    /// - thenDismiss: true when called from the Save button (adds haptic + toast + close).
    ///   false when called silently on swipe-dismiss via .onDisappear.
    private func persist(thenDismiss: Bool = false) {
        if !phone.isEmpty && isPhoneValid {
            phone = formatPhoneNumber(phone)
        }
        storedName = name
        if isEmailValid { storedEmail = email }   // skip invalid — keep last-saved value
        if isPhoneValid { storedPhone = phone }    // skip invalid — keep last-saved value

        let openAI = openAIKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if openAI.isEmpty { try? KeychainHelper.shared.deleteAPIKey() }
        else { try? KeychainHelper.shared.saveAPIKey(openAI) }

        let genius = geniusKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if genius.isEmpty { try? KeychainHelper.shared.deleteGeniusAPIKey() }
        else { try? KeychainHelper.shared.saveGeniusAPIKey(genius) }

        hasUnsavedChanges = false
        if thenDismiss {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation { showSaveConfirmation = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
        }
    }

    // MARK: Content

    // MARK: Content building blocks
    // Each tab is its own extracted `some View` property so the SwiftUI type-checker
    // stays within budget (this file has hit that ceiling before — see CCV.12 history).

    private var hasAPIKey: Bool {
        !openAIKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Pinned identity card above the tabs — avatar (tap to change) + live name/email.
    private var identityCard: some View {
        VStack(spacing: 10) {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    Circle()
                        .fill(Momentum.surfaceElevated)
                        .overlay(Circle().stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
                        .frame(width: 84, height: 84)

                    if let avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 84, height: 84)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Profile photo")

            Text(name.isEmpty ? "Your name" : name)
                .font(.momentumCardTitle)
                .foregroundStyle(name.isEmpty ? Momentum.contentSecondary : Momentum.contentPrimary)

            if !email.isEmpty {
                Text(email)
                    .font(.momentumMetadata)
                    .foregroundStyle(Momentum.contentSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    /// Short human-readable chips summarizing the saved personalization details.
    private func personalDetailsChips() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: "user_personal_details"),
              let d = try? JSONDecoder().decode(UserPersonalDetails.self, from: data) else {
            return []
        }
        func summarize(_ items: [String]) -> String {
            let head = items.prefix(2).joined(separator: ", ")
            return items.count > 2 ? "\(head) +\(items.count - 2)" : head
        }
        var chips: [String] = []
        if !d.locations.isEmpty { chips.append(summarize(d.locations)) }
        if !d.people.isEmpty    { chips.append("\(d.people.count) \(d.people.count == 1 ? "person" : "people")") }
        if !d.themes.isEmpty    { chips.append("\(d.themes.count) \(d.themes.count == 1 ? "theme" : "themes")") }
        if !d.interests.isEmpty { chips.append("\(d.interests.count) \(d.interests.count == 1 ? "interest" : "interests")") }
        if !d.background.isEmpty { chips.append("Background") }
        return chips
    }

    /// Tappable personalization card — previews what's filled, opens the editor sheet.
    private var personalizationCard: some View {
        Button {
            lightHaptic()
            showPersonalizationSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Your Personalization", systemImage: "person.text.rectangle")
                        .font(.momentumBody)
                        .foregroundStyle(Momentum.contentPrimary)
                    Spacer()
                    if hasPersonalDetails() {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Momentum.accent)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }

                let chips = personalDetailsChips()
                if chips.isEmpty {
                    Text("Add locations, people, themes, interests, and background so suggestions sound like you.")
                        .font(.momentumMetadata)
                        .foregroundStyle(Momentum.contentSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(spacing: 6) {
                        ForEach(chips, id: \.self) { chip in
                            Text(chip)
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .foregroundStyle(Momentum.contentSecondary)
                                .background(Capsule(style: .continuous).fill(Momentum.surface))
                                .overlay(Capsule(style: .continuous).stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .fill(Momentum.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                            .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Your Personalization")
        .accessibilityHint("Opens a form for locations, people, themes, interests, and background")
    }

    /// Nudge shown on the You tab when no AI key is set — jumps to the AI tab.
    private var connectKeyBanner: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.easeOut(duration: 0.18)) { selectedTab = .ai }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "key.horizontal.fill")
                    .foregroundStyle(Momentum.accent)
                Text("Connect a key to turn on AI suggestions")
                    .font(.momentumMetadata)
                    .foregroundStyle(Momentum.contentPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                    .fill(Momentum.accent.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                            .stroke(Momentum.accent.opacity(0.35), lineWidth: Momentum.lineThin)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Switches to the AI tab to add your API key")
    }

    // MARK: Content

    private var profileContentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            identityCard
            MomentumProfileTabs(selection: $selectedTab, attention: hasAPIKey ? [] : [.ai])
            tabContent
        }
        .sheet(isPresented: $showPersonalizationSheet) {
            UserPersonalizationSheet()
        }
        .sheet(isPresented: $showModelPreferences) {
            ModelPreferencesView()
        }
    }

    @ViewBuilder private var tabContent: some View {
        switch selectedTab {
        case .you: youTab
        case .ai:  aiTab
        case .app: appTab
        }
    }

    // MARK: You tab — personalization + account

    private var youTab: some View {
        VStack(alignment: .leading, spacing: 28) {
            if !hasAPIKey { connectKeyBanner }

            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Your Personalization")
                Text("Adds weight to generators so suggestions feel more personal to you.")
                    .font(.momentumMetadata)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                personalizationCard
            }

            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Account")
                VStack(spacing: 14) {
                    profileField(label: "Name", text: $name, placeholder: "Your name")
                        .onChange(of: name) { _, _ in hasUnsavedChanges = true }

                    Group {
                        let emailHelperText: String? = isEmailValid ? nil : "Enter a valid email (e.g. name@example.com)"
                        profileField(
                            label: "Email",
                            text: $email,
                            placeholder: "you@email.com",
                            keyboard: .emailAddress,
                            isValid: isEmailValid,
                            helperText: emailHelperText
                        )
                    }
                    .onChange(of: email) { _, _ in hasUnsavedChanges = true }

                    Group {
                        let phoneHelperText: String? = isPhoneValid ? nil : "Enter a 10-digit number"
                        profileField(
                            label: "Phone",
                            text: Binding(
                                get: { phone },
                                set: { newValue in
                                    phone = newValue
                                    hasUnsavedChanges = true
                                }
                            ),
                            placeholder: "(000) 000-0000",
                            keyboard: .phonePad,
                            isValid: isPhoneValid,
                            helperText: phoneHelperText
                        )
                    }
                }
            }
        }
    }

    // MARK: AI tab — connection + suggestion defaults + model

    private var aiTab: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Connection")
                Text("Required for AI suggestions. Genius is optional and improves rhyme ranking.")
                    .font(.momentumMetadata)
                    .foregroundStyle(Momentum.contentSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                APIKeyField(
                    label: "OpenAI or Gemini API Key",
                    placeholder: "sk-…  or  AIza…",
                    helperText: "Paste an OpenAI (sk-…) or Gemini (AIza…) key — Model G auto-detects. Tap Test to verify.",
                    detectProvider: true,
                    draft: $openAIKeyDraft
                )

                APIKeyField(
                    label: "Genius API Key (Optional)",
                    placeholder: "Enter Genius API key",
                    helperText: "Improves rhyme suggestions via song-lyrics data.",
                    fixedGetKeyURL: URL(string: "https://genius.com/api-clients"),
                    draft: $geniusKeyDraft
                )

                Label("Saved securely in your device Keychain.", systemImage: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
            }

            // Voice Transcription engine — Apple on-device vs OpenAI Whisper.
            transcriptionSection

            // Suggestion Defaults (carries its own MomentumSectionHeader)
            SuggestionDefaultsSection()

            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Model")
                Button {
                    lightHaptic()
                    showModelPreferences = true
                } label: {
                    navRow(title: "Model Preferences", systemImage: "brain.head.profile")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Model Preferences")
                .accessibilityHint("Customize Model G and Model Y, enable Model G Core v1.0")
            }
        }
    }

    /// Voice transcription engine picker. OpenAI Whisper is only selectable when an
    /// OpenAI (`sk-…`) key is present — Gemini keys can't run Whisper, so we lock to
    /// on-device Apple transcription and explain why.
    private var transcriptionSection: some View {
        let hasOpenAIKey = openAIKeyDraft
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .hasPrefix("sk-")
        return VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Voice Transcription")
            Picker("Transcription engine", selection: Binding(
                get: { hasOpenAIKey ? transcriptionBackend : "apple" },
                set: { transcriptionBackend = $0 }
            )) {
                Text("On-device (Apple)").tag("apple")
                Text("OpenAI Whisper").tag("whisper")
            }
            .pickerStyle(.segmented)
            .disabled(!hasOpenAIKey)
            .accessibilityHint(hasOpenAIKey
                ? "Choose how voice notes are transcribed"
                : "Add an OpenAI key to enable OpenAI Whisper")

            Text(hasOpenAIKey
                ? "On-device is private and free. OpenAI Whisper can be more accurate for music-heavy or noisy recordings and is billed to your OpenAI key."
                : "Add an OpenAI (sk-…) key above to enable OpenAI Whisper. Gemini keys don't support Whisper, so transcription stays on-device.")
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: App tab — notifications, preferences, data, about

    private var appTab: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Notifications")
                NotificationPreferencesView()
            }

            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Preferences")
                PreferencesInfoView()
                SignalLayerAdvancedModeToggle()
            }

            // Data (merged: Export + Reset Splash Screens)
            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "Data")
                Button {
                    lightHaptic()
                    exportUserData()
                } label: {
                    navRow(title: "Export Data", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Export Data")
                .accessibilityHint("Export your journal entries and profile data")

                Button {
                    SplashScreenManager.shared.resetAllSplashScreens()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    navRow(title: "Reset Splash Screens", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.plain)
            }

            // About (merged: Version/Build + Storage + Invite)
            VStack(alignment: .leading, spacing: 12) {
                MomentumSectionHeader(title: "About")

                VStack(alignment: .leading, spacing: 10) {
                    infoRow("Version", appVersion)
                    infoRow("Build", appBuild)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                                .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
                        )
                )

                StorageInfoView(modelContext: modelContext)

                ShareLink(
                    item: URL(string: "https://finaljournal.app/invite")!,
                    subject: Text("Join me on The Final Journal AI"),
                    message: Text("Check out The Final Journal AI and join my creative journey!"),
                    preview: SharePreview("The Final Journal AI", image: Image(systemName: "sparkles"))
                ) {
                    navRow(title: "Share Invite Link", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }
        }
    }
}

// MARK: - Usage Info Row (for Profile)
struct UsageInfoRow: View {
    let label: String
    let used: Int
    let limit: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
            Spacer()
            Text("\(used)/\(limit)")
                .font(.caption)
                .foregroundStyle(used >= limit ? .red : .primary)
        }
    }
}

// MARK: - Preferences Info View
struct PreferencesInfoView: View {
    @AppStorage("defaultRhymeOverlayVisible") private var defaultRhymeOverlayVisible: Bool = false
    @AppStorage("defaultBPM") private var defaultBPM: Int = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Default Rhyme Overlay")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                Spacer()
                Toggle("", isOn: $defaultRhymeOverlayVisible)
                    .labelsHidden()
            }

            if defaultBPM > 0 {
                HStack {
                    Text("Default BPM")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                    Spacer()
                    Text("\(defaultBPM)")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
}

// MARK: - Signal Layer Advanced Mode Toggle

struct SignalLayerAdvancedModeToggle: View {
    @AppStorage("signal_advanced_mode_enabled") private var isAdvancedModeEnabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Signal Layer Advanced Mode")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)

                Spacer()

                Toggle("", isOn: $isAdvancedModeEnabled)
                    .labelsHidden()
                    .onChange(of: isAdvancedModeEnabled) { _, newValue in
                        SignalAdvancedExposure.shared.setAdvancedModeEnabled(newValue)
                    }
            }

            Text("Show Signal Mode, Axes, and technical details in suggestion cards")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
    }
}

// MARK: - Storage Info View
struct StorageInfoView: View {
    let modelContext: ModelContext
    @State private var totalNotes: Int = 0
    @State private var audioFilesSize: Int64 = 0
    @Environment(\.colorScheme) private var colorScheme

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func calculateStorage() {
        Task {
            let descriptor = FetchDescriptor<Item>()
            if let items = try? modelContext.fetch(descriptor) {
                await MainActor.run {
                    totalNotes = items.count

                    var totalSize: Int64 = 0
                    let fileManager = FileManager.default

                    for item in items {
                        if let audioPath = item.audioPath {
                            if let attributes = try? fileManager.attributesOfItem(atPath: audioPath),
                               let size = attributes[.size] as? Int64 {
                                totalSize += size
                            }
                        }
                    }

                    audioFilesSize = totalSize
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total Notes")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                Spacer()
                Text("\(totalNotes)")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            HStack {
                Text("Audio Files")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                Spacer()
                Text(formatBytes(audioFilesSize))
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Momentum.surfaceElevated)
        )
        .onAppear {
            calculateStorage()
        }
    }
}

// MARK: - User Personalization Sheet

struct UserPersonalizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var personalDetails = UserPersonalDetails()
    @State private var locationInput: String = ""
    @State private var peopleInput: String = ""
    @State private var themesInput: String = ""
    @State private var interestsInput: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Locations Section
                    tagInputSection(
                        title: "Locations",
                        description: "Places important to you (e.g., Brooklyn, LA, hometown)",
                        input: $locationInput,
                        tags: $personalDetails.locations,
                        placeholder: "Enter location and press return"
                    )

                    Divider()

                    // People Section
                    tagInputSection(
                        title: "People",
                        description: "Important people in your life (names or relationships)",
                        input: $peopleInput,
                        tags: $personalDetails.people,
                        placeholder: "Enter name and press return"
                    )

                    Divider()

                    // Themes Section
                    tagInputSection(
                        title: "Themes",
                        description: "Themes you want to explore (e.g., success, struggle, love)",
                        input: $themesInput,
                        tags: $personalDetails.themes,
                        placeholder: "Enter theme and press return"
                    )

                    Divider()

                    // Interests Section
                    tagInputSection(
                        title: "Interests",
                        description: "Your interests and passions",
                        input: $interestsInput,
                        tags: $personalDetails.interests,
                        placeholder: "Enter interest and press return"
                    )

                    Divider()

                    // Background Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Background & Context")
                            .font(.headline)

                        Text("Share any context about yourself that could personalize your AI suggestions")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)

                        TextEditor(text: $personalDetails.background)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Momentum.surfaceElevated)
                            )
                            .overlay(
                                Group {
                                    if personalDetails.background.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Tell us about yourself...")
                                                    .foregroundStyle(Momentum.contentSecondary)
                                                    .padding(.leading, 12)
                                                    .padding(.top, 16)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )
                    }
                }
                .padding(20)
            }
            .navigationTitle("Personal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePersonalDetails()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadPersonalDetails()
        }
    }

    @ViewBuilder
    private func tagInputSection(
        title: String,
        description: String,
        input: Binding<String>,
        tags: Binding<[String]>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)

            // Tags Display
            if !tags.wrappedValue.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(tags.wrappedValue.enumerated()), id: \.offset) { index, tag in
                        HStack(spacing: 6) {
                            Text(tag)
                                .font(.subheadline)

                            Button {
                                tags.wrappedValue.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Momentum.surfaceElevated)
                        )
                    }
                }
            }

            // Input Field
            TextField(placeholder, text: input)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addTag(from: input, to: tags)
                }
        }
    }

    private func addTag(from input: Binding<String>, to tags: Binding<[String]>) {
        let trimmed = input.wrappedValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.wrappedValue.contains(trimmed) {
            tags.wrappedValue.append(trimmed)
            input.wrappedValue = ""
        }
    }

    private func loadPersonalDetails() {
        if let data = UserDefaults.standard.data(forKey: "user_personal_details"),
           let decoded = try? JSONDecoder().decode(UserPersonalDetails.self, from: data) {
            personalDetails = decoded
        }
    }

    private func savePersonalDetails() {
        if let encoded = try? JSONEncoder().encode(personalDetails) {
            UserDefaults.standard.set(encoded, forKey: "user_personal_details")
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? .infinity,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Notification Preferences View

struct NotificationPreferencesView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var preferences: NotificationPreferences = NotificationManager.shared.getPreferences()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Permission status
            HStack {
                Image(systemName: notificationManager.authorizationStatus == .authorized ? "bell.fill" : "bell.slash.fill")
                    .foregroundStyle(notificationManager.authorizationStatus == .authorized ? .green : .orange)

                Text(notificationManager.authorizationStatus == .authorized ? "Notifications Enabled" : "Notifications Disabled")
                    .font(.subheadline)

                Spacer()

                if notificationManager.authorizationStatus != .authorized {
                    Button("Enable") {
                        Task {
                            _ = await notificationManager.requestPermission()
                            notificationManager.scheduleNotifications()
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Momentum.surfaceElevated)
            )

            if notificationManager.authorizationStatus == .authorized {
                VStack(spacing: 12) {
                    Toggle(isOn: $preferences.dailyReminders) {
                        Label("Daily Writing Reminders", systemImage: "sunrise.fill")
                            .font(.body)
                    }
                    .onChange(of: preferences.dailyReminders) { _, _ in
                        NotificationManager.shared.savePreferences(preferences)
                    }

                    Toggle(isOn: $preferences.streakReminders) {
                        Label("Streak Reminders", systemImage: "flame.fill")
                            .font(.body)
                    }
                    .onChange(of: preferences.streakReminders) { _, _ in
                        NotificationManager.shared.savePreferences(preferences)
                    }

                    Toggle(isOn: $preferences.achievementNotifications) {
                        Label("Achievement Notifications", systemImage: "trophy.fill")
                            .font(.body)
                    }
                    .onChange(of: preferences.achievementNotifications) { _, _ in
                        NotificationManager.shared.savePreferences(preferences)
                    }

                    Toggle(isOn: $preferences.weeklySummary) {
                        Label("Weekly Summary", systemImage: "chart.bar.fill")
                            .font(.body)
                    }
                    .onChange(of: preferences.weeklySummary) { _, _ in
                        NotificationManager.shared.savePreferences(preferences)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                )
            }
        }
        .onAppear {
            preferences = NotificationManager.shared.getPreferences()
        }
    }
}

// MARK: - Profile Helper Functions
extension ProfilePopoverView {
    /// Standard tappable row: leading label, optional trailing check, chevron — on a flat Momentum card.
    @ViewBuilder
    func navRow(title: String, systemImage: String, trailingCheck: Bool = false) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.momentumBody)
                .foregroundStyle(Momentum.contentPrimary)

            Spacer()

            if trailingCheck {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Momentum.accent)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                .fill(Momentum.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .stroke(Momentum.hairline, lineWidth: Momentum.lineThin)
                )
        )
        .contentShape(Rectangle())
    }

    /// Label / value metadata row (version, build, …).
    @ViewBuilder
    func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
            Spacer()
            Text(value)
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentPrimary)
        }
    }

    @ViewBuilder
    func profileField(
        label: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        isValid: Bool? = nil,
        helperText: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.plain)
                .foregroundStyle(Momentum.contentPrimary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous)
                                .strokeBorder(
                                    (isValid == false ? Color.red.opacity(0.45) : Momentum.hairline),
                                    lineWidth: isValid == false ? 1.2 : Momentum.lineThin
                                )
                        )
                )

            if let helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(isValid == false ? .red : Momentum.contentSecondary)
            }
        }
    }
}
