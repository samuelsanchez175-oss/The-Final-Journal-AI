//
// ContentView.CCV.12.swift
//
// This file contains ProfilePopoverView, FlowLayout, and related profile views.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings)
// - AccountManager.swift (external) - DISABLED: Not needed (no Supabase/authentication)
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

// MARK: - PAGE 1.1 Profile Entry Point (Static UI + Editable Fields, No Persistence)

struct ProfilePopoverView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage("profile_name") private var storedName: String = ""
    @AppStorage("profile_email") private var storedEmail: String = ""
    @AppStorage("profile_phone") private var storedPhone: String = ""
    @AppStorage("profile_avatar_data") private var storedAvatarData: Data?

    // DISABLED: AccountManager removed - no authentication/Supabase needed
    // @StateObject private var accountManager = AccountManager.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var showModelPreferences: Bool = false
    @State private var showPersonalizationSheet: Bool = false
    @State private var showPaywall: Bool = false
    @State private var paywallFeature: String = "Premium Features"
    @State private var showSubscriptionManagement: Bool = false
    @State private var showCouponRedemption: Bool = false
    @State private var showSignIn: Bool = false
    @State private var showSignUp: Bool = false

    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var showSaveConfirmation: Bool = false
    @State private var hasUnsavedChanges: Bool = false
    
    // App version info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    // Export user data
    private func exportUserData() {
        // TODO: Implement data export functionality
        // This should export all journal entries, profile data, and settings
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // For now, just show a placeholder
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
        // Proper email regex validation
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    private var isPhoneValid: Bool {
        if phone.isEmpty { return true } // Phone is optional
        // Remove all non-digit characters for validation
        let digitsOnly = phone.filter(\.isNumber)
        // Valid if 10 digits (US format) or 11 digits (with country code)
        return digitsOnly.count == 10 || digitsOnly.count == 11
    }
    
    private func formatPhoneNumber(_ input: String) -> String {
        // Remove all non-digit characters
        let digitsOnly = input.filter(\.isNumber)
        
        // Format as (XXX) XXX-XXXX for 10 digits
        if digitsOnly.count == 10 {
            let areaCode = String(digitsOnly.prefix(3))
            let firstPart = String(digitsOnly.dropFirst(3).prefix(3))
            let lastPart = String(digitsOnly.dropFirst(6))
            return "(\(areaCode)) \(firstPart)-\(lastPart)"
        }
        
        // Format as +X (XXX) XXX-XXXX for 11 digits
        if digitsOnly.count == 11 {
            let countryCode = String(digitsOnly.prefix(1))
            let areaCode = String(digitsOnly.dropFirst(1).prefix(3))
            let firstPart = String(digitsOnly.dropFirst(4).prefix(3))
            let lastPart = String(digitsOnly.dropFirst(7))
            return "+\(countryCode) (\(areaCode)) \(firstPart)-\(lastPart)"
        }
        
        // Return as-is if not 10 or 11 digits (user still typing)
        return input
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        isEmailValid &&
        isPhoneValid
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Account Status Section
                accountStatusSection
                
                // DISABLED: Authentication disabled - always show profile content (no sign-in required)
                profileContentSection
                
                /*
                if accountManager.isSignedIn {
                    // Signed in - show profile content
                    profileContentSection
                } else {
                    // Not signed in - show sign-in prompt
                    signInPromptSection
                }
                */
            }
            .padding(20)
            .padding(.top, 20) // Extra top padding to prevent cutoff
        }
        .frame(maxWidth: .infinity)
        // DISABLED: Authentication disabled - no sign-in/sign-up sheets
        /*
        .sheet(isPresented: $showSignIn) {
            SignInView(onDismiss: { showSignIn = false })
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(onDismiss: { showSignUp = false })
        }
        */
    }
    
    // MARK: - Account Status Section
    
    // MARK: - Account Status Section (DISABLED - Authentication disabled)
    private var accountStatusSection: some View {
        EmptyView() // DISABLED: No authentication needed
        /*
        VStack(alignment: .leading, spacing: 12) {
            if accountManager.isSignedIn, let user = accountManager.currentUser {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Signed in as \(user.email)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        Task {
                            try? await accountManager.signOut()
                        }
                    } label: {
                        Text("Sign Out")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("Not signed in")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        */
    }
    
    // MARK: - Sign In Prompt Section
    
    private var signInPromptSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sign in to sync your data")
                .font(.headline)
            
            Text("Create an account or sign in to sync your configurations, preferences, and data across devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Button {
                    showSignUp = true
                } label: {
                    Text("Create Account")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                        .foregroundStyle(.white)
                }
                
                Button {
                    showSignIn = true
                } label: {
                    Text("Sign In")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Profile Content Section
    
    private var profileContentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 96, height: 96)

                        if let avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.top, 8)

            VStack(spacing: 14) {
                profileField(label: "Name", text: $name, placeholder: "Your name")
                    .onChange(of: name) { _, _ in
                        hasUnsavedChanges = true
                    }
                
                // Email field with simplified helper text
                Group {
                    let emailHelperText: String? = {
                        if !isEmailValid {
                            return "Enter a valid email address (e.g., name@example.com)"
                        } else if !email.isEmpty {
                            return "Valid email format"
                        } else {
                            return nil
                        }
                    }()
                    
                    profileField(
                        label: "Email",
                        text: $email,
                        placeholder: "you@email.com",
                        keyboard: .emailAddress,
                        isValid: isEmailValid,
                        helperText: emailHelperText
                    )
                }
                .onChange(of: email) { _, _ in
                    hasUnsavedChanges = true
                }
                
                // Phone field with simplified helper text
                Group {
                    let phoneHelperText: String? = {
                        if !isPhoneValid {
                            return "Enter 10-digit phone number (e.g., (555) 123-4567)"
                        } else if !phone.isEmpty {
                            return "Valid phone number"
                        } else {
                            return nil
                        }
                    }()
                    
                    profileField(
                        label: "Phone",
                        text: Binding(
                            get: { phone },
                            set: { newValue in
                                // Allow user to type freely, format on blur
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

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 14) {
                Text("Personal Details")
                    .font(.headline)
                
                Text("Inputting your personal details can influence the lyrics produced via generators. It adds weight to the generator to make suggestions more personal and tailored to your experiences.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showPersonalizationSheet = true
                } label: {
                    HStack {
                        Label("Add Personal Details", systemImage: "person.text.rectangle")
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if hasPersonalDetails() {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Personal Details")
                .accessibilityHint("Opens a form to add locations, people, themes, interests, and background information")
            }
            .sheet(isPresented: $showPersonalizationSheet) {
                UserPersonalizationSheet()
            }

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 14) {
                Text("API Settings")
                    .font(.headline)
                
                Text("Enter your API key to enable AI-powered features. You can find your API key at platform.openai.com/api-keys for OpenAI, or in the Google Cloud Console for Google AI services.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                profileSecureField(
                    label: "OpenAI API Key",
                    text: Binding(
                        get: { KeychainHelper.shared.getAPIKey() ?? "" },
                        set: { newValue in
                            if !newValue.isEmpty {
                                try? KeychainHelper.shared.saveAPIKey(newValue)
                            } else {
                                try? KeychainHelper.shared.deleteAPIKey()
                            }
                        }
                    ),
                    placeholder: "sk-...",
                    helperText: "Get your key from platform.openai.com/api-keys"
                )
            }

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 14) {
                Text("Model Preferences")
                    .font(.headline)
                
                Text("Configure Model G and Model Y to customize how AI suggestions are generated. Model G provides creative and artistic suggestions, while Model Y offers more technical and structured outputs. Adjust settings to match your writing style.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showModelPreferences = true
                } label: {
                    HStack {
                        Label("Configure Model G & Model Y", systemImage: "slider.horizontal.3")
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Configure Model G and Model Y")
                .accessibilityHint("Opens settings to configure AI model preferences for suggestions")
            }
            .sheet(isPresented: $showModelPreferences) {
                ModelPreferencesView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(
                    featureName: paywallFeature,
                    onDismiss: {
                        showPaywall = false
                    },
                    onSubscribe: {
                        // TODO: Implement StoreKit subscription
                        // For now, set premium status for testing
                        UsageTracker.shared.setPremiumStatus(true)
                        showPaywall = false
                    }
                )
            }

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 14) {
                Text("Splash Screens")
                    .font(.headline)
                
                Button {
                    SplashScreenManager.shared.resetAllSplashScreens()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    HStack {
                        Label("Reset All Splash Screens", systemImage: "arrow.counterclockwise")
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
            }

            Divider().opacity(0.15)

            // MARK: - Subscription Status Section (DISABLED - Subscriptions not needed)
            // DISABLED: Subscription features turned off
            /*
            VStack(alignment: .leading, spacing: 14) {
                Text("Subscription")
                    .font(.headline)
                
                SubscriptionStatusView()
                
                // Manage Subscription Button
                if SubscriptionManager.shared.subscriptionStatus == .subscribed {
                    Button {
                        showSubscriptionManagement = true
                    } label: {
                        HStack {
                            Label("Manage Subscription", systemImage: "gearshape")
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                // Redeem Coupon Code Button
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showCouponRedemption = true
                } label: {
                    HStack {
                        Label("Redeem Coupon Code", systemImage: "ticket.fill")
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Redeem Coupon Code")
                .accessibilityHint("Enter a promotional code to unlock premium features")
            }
            .sheet(isPresented: $showSubscriptionManagement) {
                SubscriptionManagementView()
            }
            .sheet(isPresented: $showCouponRedemption) {
                CouponRedemptionView()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSubscriptionManagement"))) { _ in
                showSubscriptionManagement = true
            }
            */

            Divider().opacity(0.15)
            
            // MARK: - Data Sync Section (DISABLED - Authentication disabled)
            // DISABLED: Cloud sync disabled - no authentication needed
            /*
            if accountManager.isSignedIn {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Data Sync")
                        .font(.headline)
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        Task {
                            do {
                                try await accountManager.syncUserData()
                                await MainActor.run {
                                    showSaveConfirmation = true
                                }
                            } catch {
                                await MainActor.run {
                                    accountManager.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Sync to Cloud", systemImage: "icloud.and.arrow.up")
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if accountManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(accountManager.isLoading)
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        Task {
                            do {
                                try await accountManager.loadUserData()
                                await MainActor.run {
                                    showSaveConfirmation = true
                                    // Reload profile fields
                                    name = UserDefaults.standard.string(forKey: "profile_name") ?? ""
                                    email = UserDefaults.standard.string(forKey: "profile_email") ?? ""
                                    phone = UserDefaults.standard.string(forKey: "profile_phone") ?? ""
                                }
                            } catch {
                                await MainActor.run {
                                    accountManager.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Load from Cloud", systemImage: "icloud.and.arrow.down")
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if accountManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(accountManager.isLoading)
                }
                
                Divider().opacity(0.15)
            }
            */

            // MARK: - Account Management Section
            VStack(alignment: .leading, spacing: 14) {
                Text("Account")
                    .font(.headline)
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    // Export data functionality
                    exportUserData()
                } label: {
                    HStack {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Export Data")
                .accessibilityHint("Export your journal entries and profile data")
                
                // Analytics Dashboard removed - now in top toolbar
                // Achievements moved to Analytics tab
            }

            Divider().opacity(0.15)

            // MARK: - App Information Section
            VStack(alignment: .leading, spacing: 14) {
                Text("About")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Version")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(appVersion)
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                    
                    HStack {
                        Text("Build")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(appBuild)
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }

            Divider().opacity(0.15)

            // MARK: - Storage & Data Section
            VStack(alignment: .leading, spacing: 14) {
                Text("Storage")
                    .font(.headline)
                
                StorageInfoView(modelContext: modelContext)
            }

            Divider().opacity(0.15)

            // MARK: - Notifications Section
            VStack(alignment: .leading, spacing: 14) {
                Text("Notifications")
                    .font(.headline)
                
                NotificationPreferencesView()
            }

            Divider().opacity(0.15)

            // MARK: - Preferences Section
            VStack(alignment: .leading, spacing: 14) {
                Text("Preferences")
                    .font(.headline)
                
                PreferencesInfoView()
            }

            Divider().opacity(0.15)

            // MARK: - Privacy & Security Section
            VStack(alignment: .leading, spacing: 14) {
                Text("Privacy & Security")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("API Key Security")
                                .font(.caption.weight(.medium))
                            Text("Stored securely in Keychain")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
            }

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your Invites")
                    .font(.headline)

                ShareLink(
                    item: URL(string: "https://finaljournal.app/invite")!,
                    subject: Text("Join me on The Final Journal AI"),
                    message: Text("Check out The Final Journal AI and join my creative journey!"),
                    preview: SharePreview("The Final Journal AI", image: Image(systemName: "sparkles"))
                ) {
                    Label("Share Invite Link", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }

            HStack {
                Button {
                    // Cancel - discard changes
                    name = storedName
                    email = storedEmail
                    phone = storedPhone
                    hasUnsavedChanges = false
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 70)
                        .padding(.vertical, 10)
                }
                
                Spacer()

                Button {
                    // Format phone number before saving
                    if !phone.isEmpty && isPhoneValid {
                        phone = formatPhoneNumber(phone)
                    }
                    
                    // Save to @AppStorage
                    storedName = name
                    storedEmail = email
                    storedPhone = phone
                    hasUnsavedChanges = false

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showSaveConfirmation = true
                    
                    // DISABLED: Cloud sync disabled - no authentication needed
                    // Sync to cloud if signed in
                    // if accountManager.isSignedIn {
                    //     Task {
                    //         try? await accountManager.syncUserData()
                    //     }
                    // }
                    
                    // Dismiss after showing confirmation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(minWidth: 88)
                        .padding(.vertical, 10)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.4)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.top, 8)
            .overlay(alignment: .top) {
                if showSaveConfirmation {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Profile saved")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            // DISABLED: AccountManager error messages disabled - no authentication needed
            /*
            // Show error message if any
            if let errorMessage = accountManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
            */
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
        .onAppear {
            // Load avatar from storage
            if let data = storedAvatarData,
               let uiImage = UIImage(data: data) {
                avatarImage = Image(uiImage: uiImage)
            }
            
            // Sync state with @AppStorage on appear
            name = storedName
            email = storedEmail
            phone = storedPhone
            hasUnsavedChanges = false
        }
        .onChange(of: selectedItem) { oldValue, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                    avatarImage = Image(uiImage: uiImage)
                    if let jpegData = uiImage.jpegData(compressionQuality: 0.9) {
                        storedAvatarData = jpegData
                            hasUnsavedChanges = true // Avatar change counts as unsaved
                        }
                    }
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
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("", isOn: $defaultRhymeOverlayVisible)
                    .labelsHidden()
            }
            
            if defaultBPM > 0 {
                HStack {
                    Text("Default BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                .fill(.ultraThinMaterial)
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
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(totalNotes)")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            
            HStack {
                Text("Audio Files")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
                .fill(.ultraThinMaterial)
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
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $personalDetails.background)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                            )
                            .overlay(
                                Group {
                                    if personalDetails.background.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Tell us about yourself...")
                                                    .foregroundStyle(.secondary)
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
                .foregroundStyle(.secondary)
            
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
                                .fill(.ultraThinMaterial)
                                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
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
                    .fill(.ultraThinMaterial)
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
                        .fill(.ultraThinMaterial)
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
    @ViewBuilder
    func profileSecureField(
        label: String,
        text: Binding<String>,
        placeholder: String,
        helperText: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            SecureField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )

            if let helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    (isValid == false ? Color.red.opacity(0.35) : Color.primary.opacity(0.08)),
                                    lineWidth: isValid == false ? 1.2 : 1
                                )
                        )
                )

            if let helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(isValid == false ? .red : .secondary)
            }
        }
    }
}