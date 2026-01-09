//
//  The_Final_Journal_AIApp.swift
//  The Final Journal AI
//
//  Created by Samuel on 12/28/25.
//

import SwiftUI
import SwiftData

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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
