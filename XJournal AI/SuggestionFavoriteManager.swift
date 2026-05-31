import Foundation
import SwiftUI

// MARK: - Suggestion Favorite Manager
// NOTE: GlassSettings is defined in ContentView.swift and is accessible here
// Manages favorite suggestions for reuse

class SuggestionFavoriteManager {
    static let shared = SuggestionFavoriteManager()
    
    private let favoritesKey = "favorite_suggestions"
    private let maxFavorites = 100 // Limit favorites to prevent storage bloat
    
    private init() {}
    
    // MARK: - Manage Favorites
    
    func addFavorite(_ suggestion: RapSuggestion) {
        var favorites = loadFavorites()
        
        // Remove if already exists (to update)
        favorites.removeAll { $0.id == suggestion.id }
        
        // Add to beginning
        favorites.insert(suggestion, at: 0)
        
        // Limit count
        if favorites.count > maxFavorites {
            favorites = Array(favorites.prefix(maxFavorites))
        }
        
        saveFavorites(favorites)
    }
    
    func removeFavorite(_ suggestionId: UUID) {
        var favorites = loadFavorites()
        favorites.removeAll { $0.id == suggestionId }
        saveFavorites(favorites)
    }
    
    func isFavorite(_ suggestionId: UUID) -> Bool {
        let favorites = loadFavorites()
        return favorites.contains { $0.id == suggestionId }
    }
    
    func getFavoriteIds() -> Set<UUID> {
        let favorites = loadFavorites()
        return Set(favorites.map { $0.id })
    }
    
    func getFavorites() -> [RapSuggestion] {
        return loadFavorites()
    }
    
    // MARK: - Private Helpers
    
    private func loadFavorites() -> [RapSuggestion] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([RapSuggestion].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveFavorites(_ favorites: [RapSuggestion]) {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
}

// MARK: - Suggestion History View (Phase 1)

struct SuggestionHistoryView: View {
    let onDismiss: () -> Void
    let onSelect: (RapSuggestion) -> Void
    
    @State private var history: [RapSuggestion] = []
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundStyle(Momentum.contentSecondary)
                        Text("No History")
                            .font(.headline)
                        Text("Previous suggestions will appear here")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                } else {
                    List {
                        ForEach(history) { suggestion in
                            Button {
                                onSelect(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(suggestion.text)
                                        .font(.body)
                                        .lineLimit(3)
                                    
                                    if let confidence = suggestion.confidence as Double? {
                                        Text("Confidence: \(Int(confidence * 100))%")
                                            .font(.caption)
                                            .foregroundStyle(Momentum.contentSecondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Suggestion History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadHistory()
            }
        }
    }
    
    private func loadHistory() {
        // Load from RapSuggestionEngine's previous suggestions
        // This is a placeholder - in production, would load from persistent storage
        Task { @MainActor in
            history = []
        }
    }
}

// MARK: - Favorite Suggestions View (Phase 1)

struct FavoriteSuggestionsView: View {
    let favorites: [UUID]
    let onDismiss: () -> Void
    let onSelect: (RapSuggestion) -> Void
    
    @State private var favoriteSuggestions: [RapSuggestion] = []
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if favoriteSuggestions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "star")
                            .font(.system(size: 48))
                            .foregroundStyle(Momentum.contentSecondary)
                        Text("No Favorites")
                            .font(.headline)
                        Text("Tap the star icon on suggestions to save them")
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(favoriteSuggestions) { suggestion in
                            Button {
                                onSelect(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                            .font(.caption)
                                        Text(suggestion.text)
                                            .font(.body)
                                            .lineLimit(3)
                                    }
                                    
                                    if let confidence = suggestion.confidence as Double? {
                                        Text("Confidence: \(Int(confidence * 100))%")
                                            .font(.caption)
                                            .foregroundStyle(Momentum.contentSecondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let suggestion = favoriteSuggestions[index]
                                SuggestionFavoriteManager.shared.removeFavorite(suggestion.id)
                            }
                            loadFavorites()
                        }
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Favorite Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
        Task { @MainActor in
            self.favoriteSuggestions = SuggestionFavoriteManager.shared.getFavorites()
        }
    }
}
