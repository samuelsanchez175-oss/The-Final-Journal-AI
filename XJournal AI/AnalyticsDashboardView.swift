import SwiftUI
import SwiftData

// MARK: - Analytics Dashboard View (Phase 6: Analytics Dashboard)

struct AnalyticsDashboardView: View {
    @Query private var items: [Item]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAllAchievements: Bool = false
    
    private var stats: AnalyticsManager.WritingStats {
        AnalyticsManager.shared.calculateStats(items: Array(items))
    }
    
    private var overviewCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Notes",
                    value: "\(stats.totalNotes)",
                    icon: "note.text",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Words",
                    value: "\(stats.totalWords)",
                    icon: "text.word.spacing",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg Words/Note",
                    value: String(format: "%.0f", stats.averageWordsPerNote),
                    icon: "chart.bar",
                    color: .orange
                )
                
                StatCard(
                    title: "Writing Streak",
                    value: "\(stats.writingStreak) days",
                    icon: "flame.fill",
                    color: .red
                )
            }
        }
    }
    
    private var writingActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Writing Activity")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatRow(
                    label: "Most Active Day",
                    value: stats.mostActiveDay,
                    icon: "calendar"
                )
                
                StatRow(
                    label: "Most Active Hour",
                    value: formatHour12(stats.mostActiveHour),
                    icon: "clock"
                )
                
                StatRow(
                    label: "Notes Per Day",
                    value: String(format: "%.1f", stats.notesPerDay),
                    icon: "chart.line.uptrend.xyaxis"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            )
        }
    }
    
    private var mostUsedWordsSection: some View {
        Group {
            if !stats.mostUsedWords.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Most Used Words")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(stats.mostUsedWords.prefix(5).enumerated()), id: \.offset) { index, word in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(word.word)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("\(word.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
    }
    
    private var musicMetadataSection: some View {
        Group {
            if stats.averageBPM != nil || stats.mostUsedKey != nil {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Music Metadata")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        if let avgBPM = stats.averageBPM {
                            StatRow(
                                label: "Average BPM",
                                value: String(format: "%.0f", avgBPM),
                                icon: "metronome"
                            )
                        }
                        
                        if let key = stats.mostUsedKey {
                            StatRow(
                                label: "Most Used Key",
                                value: key,
                                icon: "music.note"
                            )
                        }
                        
                        if let duration = stats.totalAudioDuration {
                            StatRow(
                                label: "Total Audio",
                                value: formatDuration(duration),
                                icon: "waveform"
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
    }
    
    private var feedbackAnalyticsSection: some View {
        let feedbackStats = SuggestionFeedbackManager.shared.getFeedbackStats()
        let categoryStats = SuggestionFeedbackManager.shared.getFeedbackStatsByCategory()
        let analysis = FeedbackAnalysisEngine.shared.analyzeFeedbackPatterns()
        
        return Group {
            if feedbackStats.totalFeedback > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Suggestion Feedback")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        // Overall stats
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(feedbackStats.totalFeedback)")
                                    .font(.title2.weight(.bold))
                                Text("Total Feedback")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "%.0f%%", feedbackStats.acceptanceRate * 100))
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(feedbackStats.acceptanceRate > 0.6 ? .green : feedbackStats.acceptanceRate > 0.4 ? .orange : .red)
                                Text("Acceptance Rate")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Category breakdown
                        if !categoryStats.categoryStats.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Feedback by Category")
                                    .font(.subheadline.weight(.medium))
                                
                                ForEach(Array(categoryStats.categoryStats.sorted(by: { ($0.value.liked + $0.value.disliked) > ($1.value.liked + $1.value.disliked) }).prefix(5)), id: \.key) { category, stats in
                                    let total = stats.liked + stats.disliked
                                    let acceptanceRate = total > 0 ? Double(stats.liked) / Double(total) : 0.0
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(category.displayName)
                                                .font(.caption)
                                            Spacer()
                                            Text("\(stats.liked)👍 \(stats.disliked)👎")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(height: 6)
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(acceptanceRate > 0.6 ? Color.green : acceptanceRate > 0.4 ? Color.orange : Color.red)
                                                    .frame(width: geometry.size.width * acceptanceRate, height: 6)
                                            }
                                        }
                                        .frame(height: 6)
                                    }
                                }
                            }
                        }
                        
                        // Trend indicator
                        let trend = analysis.trends.acceptanceRateTrend
                        Divider()
                        
                        HStack {
                            Image(systemName: trend == .improving ? "arrow.up.circle.fill" : trend == .declining ? "arrow.down.circle.fill" : "minus.circle.fill")
                                .foregroundStyle(trend == .improving ? .green : trend == .declining ? .red : .gray)
                            
                            Text(trend == .improving ? "Improving" : trend == .declining ? "Declining" : "Stable")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("Based on recent feedback")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showAllAchievements = true
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            
            let unlockedAchievements = AchievementSystem.shared.getUnlockedAchievements()
            let allAchievements = AchievementSystem.shared.getAllAchievements()
            let unlockedCount = unlockedAchievements.count
            let totalCount = allAchievements.count
            
            VStack(spacing: 16) {
                // Header stats
                VStack(spacing: 8) {
                    Text("\(unlockedCount) / \(totalCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.blue)
                    
                    Text("Achievements Unlocked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * (Double(unlockedCount) / Double(max(totalCount, 1))),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
                
                // Achievements grid
                if !allAchievements.isEmpty {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(allAchievements.prefix(9)) { achievement in
                            AchievementBadgeView(achievement: achievement, size: 80)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    overviewCards
                    writingActivitySection
                    achievementsSection
                    mostUsedWordsSection
                    musicMetadataSection
                    feedbackAnalyticsSection
                }
                .padding()
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showAllAchievements) {
            AchievementCollectionView()
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatHour12(_ hour24: Int) -> String {
        let hour = hour24 % 12
        let displayHour = hour == 0 ? 12 : hour
        let period = hour24 < 12 ? "AM" : "PM"
        return "\(displayHour):00 \(period)"
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.weight(.bold))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            Text(label)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body.weight(.medium))
        }
    }
}
