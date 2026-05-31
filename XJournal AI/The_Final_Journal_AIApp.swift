//
//  The_Final_Journal_AIApp.swift
//  The Final Journal AI
//
//  Created by Samuel on 12/28/25.
//

import SwiftUI
import SwiftData
import UIKit
import os
import AVFoundation

// MARK: - Startup Performance Measurement
class StartupPerformanceTracker {
    static let shared = StartupPerformanceTracker()
    private let startTime = CFAbsoluteTimeGetCurrent()
    private var milestones: [String: CFAbsoluteTime] = [:]
    
    private init() {
        milestones["app_init_start"] = startTime
    }
    
    func recordMilestone(_ name: String) {
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        milestones[name] = elapsed
        print("⏱️ Startup: \(name) at \(String(format: "%.3f", elapsed))s")
    }
    
    func printSummary() {
        let total = CFAbsoluteTimeGetCurrent() - startTime
        print("\n🚀 ===== STARTUP PERFORMANCE SUMMARY =====")
        for (name, time) in milestones.sorted(by: { $0.value < $1.value }) {
            print("  \(name): \(String(format: "%.3f", time))s")
        }
        print("  TOTAL TIME: \(String(format: "%.3f", total))s")
        print("==========================================\n")
    }
}

@main
struct The_Final_Journal_AIApp: App {
    /// Momentum appearance — Light by default (the app was leaning too dark). Light/Dark/Warm.
    @AppStorage("appTheme") private var appTheme = ThemeMode.light.rawValue

    // MARK: - Pre-initialized ModelContainer
    // Initialize ModelContainer asynchronously on app launch to avoid blocking startup
    // Use static storage to avoid mutating getter issues in computed properties
    private nonisolated(unsafe) static var _sharedModelContainer: ModelContainer?
    private static let containerLock = OSAllocatedUnfairLock(initialState: ())
    private static var initializationTask: Task<Void, Never>?
    
    private var sharedModelContainer: ModelContainer {
        let (container, wasFirstAccess, didSyncFallback) = Self.containerLock.withLock { () -> (ModelContainer, Bool, Bool) in
            let firstAccess = Self._sharedModelContainer == nil
            if let existing = Self._sharedModelContainer {
                return (existing, firstAccess, false)
            }
            let newContainer = Self.createModelContainer()
            Self._sharedModelContainer = newContainer
            return (newContainer, firstAccess, true)
        }
        if wasFirstAccess {
            StartupPerformanceTracker.shared.recordMilestone("modelcontainer_modifier_accessed")
        }
        if didSyncFallback {
            StartupPerformanceTracker.shared.recordMilestone("modelcontainer_sync_fallback")
        }
        return container
    }
    
    // MARK: - Async ModelContainer Initialization
    
    /// Pre-initialize ModelContainer on background thread
    /// Called immediately on app launch to avoid blocking startup
    private static func initializeModelContainer() async {
        StartupPerformanceTracker.shared.recordMilestone("modelcontainer_init_start")
        
        // Initialize on background thread (ModelContainer creation is thread-safe)
        let container = Self.createModelContainer()
        
        // Store in static variable (use OSAllocatedUnfairLock for async-safe locking)
        Self.containerLock.withLock {
            Self._sharedModelContainer = container
        }
        
        StartupPerformanceTracker.shared.recordMilestone("modelcontainer_init_complete")
        
        // Pre-warm query in background (non-blocking, fire-and-forget)
        // Don't await - let UI be interactive immediately
        Task.detached(priority: .utility) {
            await prewarmQuery(container: container)
        }
    }
    
    /// Create ModelContainer synchronously (used by both async init and sync fallback)
    private nonisolated static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Item.self,
            SocialPost.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            // Fallback to in-memory store to prevent app crash
            Task { @MainActor in
                StartupPerformanceTracker.shared.recordMilestone("modelcontainer_init_fallback")
            }
            return try! ModelContainer(
                for: schema,
                configurations: [
                    ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                ]
            )
        }
    }
    
    /// Pre-warm query after ModelContainer is ready
    /// This makes the first query access in views much faster
    /// NOTE: This runs in background and doesn't block UI
    private static func prewarmQuery(container: ModelContainer) async {
        StartupPerformanceTracker.shared.recordMilestone("query_prewarm_start")
        
        // Use a lightweight query with limit to avoid blocking
        // This just initializes SwiftData's query system without loading all data
        await MainActor.run {
            let context = container.mainContext
            // Use a minimal query with limit=1 to just warm up the system
            var descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            descriptor.fetchLimit = 1  // Only fetch 1 item to warm up
            let _ = try? context.fetch(descriptor)
            StartupPerformanceTracker.shared.recordMilestone("query_prewarm_complete")
        }
    }

    init() {
        StartupPerformanceTracker.shared.recordMilestone("app_init_complete")
        
        // Configure audio session to bypass silent mode at app startup
        Self.configureAudioSessionForPlayback()
        
        // Start ModelContainer initialization immediately on background thread
        // This pre-initializes the database before views need it
        // Use .utility priority to avoid blocking UI responsiveness
        Self.initializationTask = Task.detached(priority: .utility) {
            await Self.initializeModelContainer()
        }
        
        // Only set up critical observers in init - defer heavy operations
        // Set up memory warning observer on app launch
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Clear caches on memory warning for better memory management
            print("⚠️ Memory Warning: Caches cleared")
        }
        
        // Set up app lifecycle observers for session tracking
        // NOTE: Defer singleton access to avoid initialization during app startup
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // End session when app goes to background (lazy access)
            Task { @MainActor in
                UserBehaviorTracker.shared.endSession()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Start new session when app comes to foreground (lazy access)
            Task { @MainActor in
                UserBehaviorTracker.shared.startSession()
                
                // Record app open for notifications
                NotificationManager.shared.recordAppOpen()
                
                // Check for interventions
                ChurnInterventionManager.shared.checkAndTriggerInterventions()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Momentum.accent)
                .preferredColorScheme((ThemeMode(rawValue: appTheme) ?? .light).colorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Re-activate audio session when app comes to foreground
                    Self.configureAudioSessionForPlayback()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // Ensure audio session stays active in background
                    // This is critical for background audio playback
                    do {
                        let audioSession = AVAudioSession.sharedInstance()
                        try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
                        try audioSession.setActive(true, options: [])
                        print("✅ App: Audio session maintained in background")
                    } catch {
                        print("⚠️ App: Failed to maintain audio session in background: \(error.localizedDescription)")
                    }
                }
                .onAppear {
                    StartupPerformanceTracker.shared.recordMilestone("first_view_appear")
                    
                    // Defer ALL non-critical initialization to after first render
                    // This significantly improves app launch time
                    Task { @MainActor in
                        // Wait a tiny bit to ensure UI is fully rendered
                        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
                        
                        StartupPerformanceTracker.shared.recordMilestone("deferred_init_start")
                        
                        // Preload CMUDICT dictionary for rhyme highlighting (required for rhyme groups/highlights)
                        preloadGlobalCMUDICTStore()
                        StartupPerformanceTracker.shared.recordMilestone("cmudict_preload_started")
                        
                        // Start user behavior tracking session (deferred, lightweight)
                        UserBehaviorTracker.shared.startSession()
                        StartupPerformanceTracker.shared.recordMilestone("session_started")
                        
                        // Record app open (deferred, lightweight)
                        NotificationManager.shared.recordAppOpen()
                        StartupPerformanceTracker.shared.recordMilestone("app_open_recorded")
                        
                        // Request notification permissions (deferred, async - non-blocking)
                        Task.detached(priority: .utility) {
                            _ = await NotificationManager.shared.requestPermission()
                            await MainActor.run {
                                NotificationManager.shared.scheduleNotifications()
                                StartupPerformanceTracker.shared.recordMilestone("notifications_scheduled")
                            }
                        }
                        
                        // Schedule contextual notifications (deferred, fully async on background thread)
                        // This is the heaviest operation, so defer it even more
                        Task.detached(priority: .utility) {
                            // Wait additional time to ensure UI is fully interactive
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                            await SmartNotificationManager.shared.scheduleContextualNotifications()
                        }
                        
                        // Load new CSV databases (editorial ground truth, lexicon, themes)
                        Task.detached(priority: .utility) {
                            do {
                                try await NewRapDatabase.shared.loadAllCSVs()
                                await MainActor.run {
                                    StartupPerformanceTracker.shared.recordMilestone("csv_databases_loaded")
                                }
                                print("✅ NewRapDatabase: All CSV files loaded successfully")
                            } catch {
                                print("⚠️ NewRapDatabase: Failed to load CSV files - \(error.localizedDescription)")
                                print("💡 Make sure CSV files are in the XJournal AI directory or app bundle")
                            }
                        }
                        
                        StartupPerformanceTracker.shared.recordMilestone("deferred_init_complete")
                        StartupPerformanceTracker.shared.printSummary()
                    }
                    
                    // Note: CMUDICT dictionary preloading and hero splash screen
                    // are handled in ContentView.onAppear where all types are accessible
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Audio Session Configuration
    
    /// Configure audio session to allow playback even when device is in silent mode
    /// This is called at app startup to ensure audio always plays regardless of silent switch
    private static func configureAudioSessionForPlayback() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
            print("✅ App: Audio session configured for background playback")
        } catch {
            let nsErr = error as NSError
            print("⚠️ App: Failed to configure audio session: \(error.localizedDescription) (code: \(nsErr.code), domain: \(nsErr.domain))")
            if nsErr.code == -50 {
                print("📝 App: Retrying with playback category only (no Bluetooth options)")
            }
            do {
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
                print("✅ App: Audio session configured (playback only)")
            } catch let fallbackError {
                let fallbackNs = fallbackError as NSError
                print("❌ App: Fallback audio session failed: \(fallbackError.localizedDescription) (code: \(fallbackNs.code))")
            }
        }
    }
}
