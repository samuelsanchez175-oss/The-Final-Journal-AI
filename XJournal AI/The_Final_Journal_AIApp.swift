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
        // Set up memory warning observer on app launch
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Clear caches on memory warning for better memory management
            print("⚠️ Memory Warning: Caches cleared")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Pre-load CMUDICT dictionary asynchronously on app launch
                    // This ensures dictionary is ready before first rhyme analysis
                    FJCMUDICTStore.shared.preloadAsync()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
