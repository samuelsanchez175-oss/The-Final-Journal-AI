//
//  The_Final_Journal_AIApp.swift
//  The Final Journal AI
//
//  Created by Samuel on 12/28/25.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct The_Final_Journal_AIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            SocialPost.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Fallback to in-memory store to prevent app crash
            return try! ModelContainer(
                for: schema,
                configurations: [
                    ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                ]
            )
        }
    }()

    init() {
        // Request notification permissions on first launch
        Task {
            _ = await NotificationManager.shared.requestPermission()
            NotificationManager.shared.scheduleNotifications()
        }
        
        // Record app open
        NotificationManager.shared.recordAppOpen()
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
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // End session when app goes to background
            UserBehaviorTracker.shared.endSession()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Start new session when app comes to foreground
            UserBehaviorTracker.shared.startSession()
            
            // Record app open for notifications
            NotificationManager.shared.recordAppOpen()
            
            // Check for interventions
            ChurnInterventionManager.shared.checkAndTriggerInterventions()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Start user behavior tracking session
                    UserBehaviorTracker.shared.startSession()
                    
                    // Schedule contextual notifications
                    SmartNotificationManager.shared.scheduleContextualNotifications()
                    
                    // Note: CMUDICT dictionary preloading and hero splash screen
                    // are handled in ContentView.onAppear where all types are accessible
                    
                    // Load rap lyrics database asynchronously on app launch
                    Task {
                        do {
                            try await RapLyricsDatabase.shared.loadFromAppGroup()
                        } catch {
                            print("⚠️ Failed to load rap lyrics database: \(error.localizedDescription)")
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
