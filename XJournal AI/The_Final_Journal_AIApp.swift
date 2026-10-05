//
//  The_Final_Journal_AIApp.swift
//  The Final Journal AI
//
//  Created by Samuel on 12/28/25.
//

import SwiftUI
import SwiftData
import UIKit

/// Cold-start clock. `t0` is captured when this type is first touched (App.init).
private enum LaunchClock {
    static let t0 = CFAbsoluteTimeGetCurrent()

    static func log(_ event: String) {
        let sinceInitMs = (CFAbsoluteTimeGetCurrent() - t0) * 1000
        let processMs = ProcessInfo.processInfo.systemUptime * 1000
        print(String(
            format: "⏱️ launch: %@ — +%.0fms from App.init, %.0fms process uptime",
            event,
            sinceInitMs,
            processMs
        ))
    }
}

@main
struct The_Final_Journal_AIApp: App {
    /// Momentum appearance — Light by default (the app was leaning too dark). Light/Dark/Warm.
    @AppStorage("appTheme") private var appTheme = ThemeMode.light.rawValue

    /// First-run onboarding gate. UserDefaults only — don't spin SplashScreenManager at App.init.
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "has_completed_onboarding")

    /// Home intro coachmark is off — launch goes straight to the journal list.
    @State private var showHomeIntro: Bool = false

    /// Created off the main thread after the first SwiftUI frame. Nil until then.
    @State private var container: ModelContainer?

    /// Create ModelContainer (disk, with in-memory fallback). Call off the main thread.
    nonisolated static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Item.self,
            SocialPost.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            return try! ModelContainer(
                for: schema,
                configurations: [
                    ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                ]
            )
        }
    }

    init() {
        // Lightweight only — no ModelContainer, audio session, splash singleton, CSV, or CMUDICT.
        _ = LaunchClock.t0
        LaunchClock.log("App.init")
        ModelGEnvironment.applyV3OnlyProductDefaultsIfNeeded()
        AppNavigation.pendingProfileTab = nil
        AppNavigation.pendingOpenModelPreferences = false
    }

    var body: some Scene {
        WindowGroup {
            AppLaunchRoot(
                appTheme: appTheme,
                showOnboarding: $showOnboarding,
                showHomeIntro: $showHomeIntro,
                container: $container
            )
        }
    }
}

// MARK: - First paint, then SwiftData

private struct AppLaunchRoot: View {
    let appTheme: String
    @Binding var showOnboarding: Bool
    @Binding var showHomeIntro: Bool
    @Binding var container: ModelContainer?

    var body: some View {
        Group {
            if let container {
                ContentView()
                    .modelContainer(container)
            } else {
                HomeLaunchShell()
            }
        }
        .tint(Momentum.accent)
        .preferredColorScheme((ThemeMode(rawValue: appTheme) ?? .light).colorScheme)
        .task {
            guard container == nil else { return }
            LaunchClock.log("first frame")
            let built = await Task.detached(priority: .userInitiated) {
                The_Final_Journal_AIApp.createModelContainer()
            }.value
            LaunchClock.log("container ready")
            container = built
        }
        .overlay {
            if showOnboarding {
                OnboardingWelcomeFlow {
                    SplashScreenManager.shared.markOnboardingComplete()
                    SplashScreenManager.shared.dismissSplash(.homeOverview)
                    showHomeIntro = false
                    withAnimation(.easeInOut(duration: 0.45)) { showOnboarding = false }
                }
                .transition(.opacity)
            }
        }
    }
}

/// First SwiftUI frame: same coral wash + large product title as home, no spinner, no void.
private struct HomeLaunchShell: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            AtmosphereGlow()
            Text(Momentum.appName)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
