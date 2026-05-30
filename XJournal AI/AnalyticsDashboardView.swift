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
    
    private var errorAnalyticsSection: some View {
        let errors = ErrorStorageManager.shared.getRecentErrors(limit: 100)
        let stats = ErrorStorageManager.shared.getErrorStats()
        
        return VStack(alignment: .leading, spacing: 16) {
            // Error Statistics
            VStack(alignment: .leading, spacing: 12) {
                Text("Error Statistics")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(stats.totalErrors)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.red)
                        Text("Total Errors")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(stats.recentErrorCount)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.orange)
                        Text("Last 24 Hours")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Errors by source
                if !stats.errorsBySource.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Errors by Source")
                            .font(.subheadline.weight(.medium))
                        
                        ForEach(Array(stats.errorsBySource.sorted(by: { $0.value > $1.value })), id: \.key) { source, count in
                            HStack {
                                Text(source)
                                    .font(.body)
                                Spacer()
                                Text("\(count)")
                                    .font(.body.weight(.medium))
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
            
            // Error List
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recent Errors")
                        .font(.headline)
                    
                    Spacer()
                    
                    if !errors.isEmpty {
                        Button {
                            ErrorStorageManager.shared.clearAllErrors()
                        } label: {
                            Text("Clear All")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                if errors.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                        Text("No Errors")
                            .font(.headline)
                        Text("All systems running smoothly!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(errors) { error in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(error.source)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(error.timestamp, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(error.message)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if let context = error.context {
                                    Text(context)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .italic()
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                            )
                        }
                    }
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
                        
                        // Show active improvements
                        let improvements = ModelImprovementPipeline.shared.getRecentImprovements()
                        if !improvements.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active AI Improvements")
                                    .font(.subheadline.weight(.medium))
                                
                                ForEach(Array(improvements.prefix(3).enumerated()), id: \.offset) { index, improvement in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Image(systemName: improvement.priority == .high ? "exclamationmark.triangle.fill" : improvement.priority == .medium ? "info.circle.fill" : "checkmark.circle.fill")
                                                .foregroundStyle(improvement.priority == .high ? .red : improvement.priority == .medium ? .orange : .green)
                                                .font(.caption)
                                            
                                            Text(improvement.area)
                                                .font(.caption.weight(.semibold))
                                            
                                            Spacer()
                                        }
                                        
                                        Text(improvement.suggestedChange)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                Text("Prompt Version: \(ModelImprovementPipeline.shared.getCurrentPromptVersion())")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
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
    
    @State private var selectedTab: AnalyticsTab = .overview
    
    enum AnalyticsTab: String, CaseIterable {
        case apiDebug = "API Debug"
        case overview = "Overview"
        case errors = "Errors"
        case network = "Network"
        case tokens = "Tokens"
        case jsonValidation = "JSON"
        case errorCorrelation = "Correlation"
        case whatsNew = "What's New"
        case social = "Social"
    }
    
    // MARK: - Network Performance Section
    
    private var networkPerformanceSection: some View {
        let stats = NetworkPerformanceMonitor.shared.getStats()
        let isDarkMode = colorScheme == .dark
        
        return VStack(alignment: .leading, spacing: 24) {
            Text("Network Performance")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 12)
            
            // Summary Cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Requests",
                    value: "\(stats.totalRequests)",
                    icon: "network",
                    color: .blue
                )
                
                StatCard(
                    title: "Success Rate",
                    value: String(format: "%.1f%%", stats.successRate * 100),
                    icon: "checkmark.circle.fill",
                    color: stats.successRate > 0.95 ? .green : stats.successRate > 0.8 ? .orange : .red
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg Latency",
                    value: String(format: "%.0fms", stats.averageLatency),
                    icon: "speedometer",
                    color: .purple
                )
                
                StatCard(
                    title: "P95 Latency",
                    value: String(format: "%.0fms", stats.p95Latency),
                    icon: "gauge.high",
                    color: .orange
                )
            }
            
            // Latency Distribution
            VStack(alignment: .leading, spacing: 12) {
                Text("Latency Metrics")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    StatRow(label: "Average", value: String(format: "%.0fms", stats.averageLatency), icon: "chart.bar.fill")
                    StatRow(label: "Median", value: String(format: "%.0fms", stats.medianLatency), icon: "chart.bar.fill")
                    StatRow(label: "P95", value: String(format: "%.0fms", stats.p95Latency), icon: "chart.bar.fill")
                    StatRow(label: "P99", value: String(format: "%.0fms", stats.p99Latency), icon: "chart.bar.fill")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(isDarkMode ? GlassSettings.darkening : 0))
                )
            }
            
            // Status Code Distribution
            if !stats.requestsByStatusCode.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status Codes")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(stats.requestsByStatusCode.sorted(by: { $0.value > $1.value })), id: \.key) { statusCode, count in
                            HStack {
                                Text("\(statusCode)")
                                    .font(.body)
                                Spacer()
                                Text("\(count)")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(isDarkMode ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
        .padding(24)
    }
    
    // MARK: - Token Usage Section
    
    private var tokenUsageSection: some View {
        let stats = TokenUsageTracker.shared.getStats()
        _ = TokenUsageTracker.shared.getDailyStats()
        _ = TokenUsageTracker.shared.getWeeklyStats()
        let isDarkMode = colorScheme == .dark
        
        return VStack(alignment: .leading, spacing: 24) {
            Text("Token Usage")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 12)
            
            // Summary Cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Tokens",
                    value: "\(stats.totalTokens)",
                    icon: "number",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Cost",
                    value: String(format: "$%.2f", stats.totalCost),
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg per Request",
                    value: "\(stats.averageTokensPerRequest)",
                    icon: "arrow.up.arrow.down",
                    color: .purple
                )
                
                StatCard(
                    title: "Requests",
                    value: "\(stats.requestCount)",
                    icon: "network",
                    color: .orange
                )
            }
            
            // Daily Stats (grouped by day)
            let dailyRecords = TokenUsageTracker.shared.getRecentRecords(limit: 100)
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: dailyRecords) { record in
                calendar.startOfDay(for: record.timestamp)
            }
            let sortedDays = groupedByDay.keys.sorted(by: >).prefix(7)
            
            if !sortedDays.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Usage")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(sortedDays), id: \.self) { day in
                            let dayRecords = groupedByDay[day] ?? []
                            let dayTokens = dayRecords.reduce(0) { $0 + $1.totalTokens }
                            let dayCost = dayRecords.reduce(0.0) { $0 + $1.estimatedCost }
                            
                            HStack {
                                Text(day, style: .date)
                                    .font(.body)
                                Spacer()
                                Text("\(dayTokens) tokens ($\(String(format: "%.2f", dayCost)))")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(isDarkMode ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
        .padding(24)
    }
    
    // MARK: - JSON Validation Section
    
    private var jsonValidationSection: some View {
        let stats = JSONValidationService.shared.getStats()
        let isDarkMode = colorScheme == .dark
        
        return VStack(alignment: .leading, spacing: 24) {
            Text("JSON Validation")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 12)
            
            // Summary Cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Validations",
                    value: "\(stats.totalValidations)",
                    icon: "checkmark.shield.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Success Rate",
                    value: String(format: "%.1f%%", stats.successRate * 100),
                    icon: "checkmark.circle.fill",
                    color: stats.successRate > 0.95 ? .green : stats.successRate > 0.8 ? .orange : .red
                )
            }
            
            // Validation Errors
            if !stats.recentErrors.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Validation Errors")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            JSONValidationService.shared.clearAllRecords()
                        }) {
                            Text("Clear")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(Array(stats.recentErrors.prefix(10).enumerated()), id: \.offset) { index, errorMessage in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(errorMessage)
                                    .font(.body)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(isDarkMode ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
        .padding(24)
    }
    
    // MARK: - Error Correlation Section
    
    private var errorCorrelationSection: some View {
        let analysis = ErrorCorrelationAnalyzer.shared.analyzeErrors()
        let isDarkMode = colorScheme == .dark
        
        return VStack(alignment: .leading, spacing: 24) {
            Text("Error Correlation")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 12)
            
            // Error Clusters
            if !analysis.errorClusters.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Error Clusters")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(analysis.errorClusters.prefix(10).enumerated()), id: \.offset) { index, cluster in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cluster.commonPattern)
                                    .font(.body.weight(.medium))
                                Text("Occurrences: \(cluster.frequency)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(isDarkMode ? GlassSettings.darkening : 0))
                    )
                }
            }
        }
        .padding(24)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Analytics Tab", selection: $selectedTab) {
                    ForEach(AnalyticsTab.allCases.filter({ tab in
                        #if DEBUG
                        return true
                        #else
                        return tab != .apiDebug   // hide debug inspector from release builds
                        #endif
                    }), id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .overview:
                            overviewCards
                            writingActivitySection
                            achievementsSection
                            mostUsedWordsSection
                            musicMetadataSection
                            feedbackAnalyticsSection
                        case .errors:
                            errorAnalyticsSection
                        case .whatsNew:
                            whatsNewSection
                        case .social:
                            socialSection
                        case .apiDebug:
                            #if DEBUG
                            APIDebugInspectorView()
                            #else
                            EmptyView()
                            #endif
                        case .network:
                            networkPerformanceSection
                        case .tokens:
                            tokenUsageSection
                        case .jsonValidation:
                            jsonValidationSection
                        case .errorCorrelation:
                            errorCorrelationSection
                        }
                    }
                    .padding()
                }
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
    
    // MARK: - What's New Section
    
    private var whatsNewSection: some View {
        ReleaseNotesContentView()
    }
    
    // MARK: - Social Section
    
    private var socialSection: some View {
        SocialFeedContentView()
    }
}

// MARK: - Release Notes Content View (for Analytics Dashboard)

struct ReleaseNotesContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's New")
                    .font(.largeTitle.weight(.bold))
                
                Text("The Final Journal AI")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)
            
            featureCard(
                symbolName: "waveform.path",
                version: "1.4.0",
                title: "Audio Intelligence & Analytics",
                description: "Advanced audio transcription, interactive playback, and comprehensive analytics dashboard.",
                bullets: [
                    "High-fidelity on-device audio transcription with timestamped segments",
                    "Interactive audio detail sheet with synchronized text highlighting",
                    "Audio waveform visualization and playback controls",
                    "Comprehensive analytics dashboard with multiple tabs",
                    "Error tracking and storage with detailed analytics",
                    "Social feed integration for tips and guides",
                    "Improved AI suggestion reliability with robust JSON parsing",
                    "Real-time title editing with instant library updates"
                ]
            )
            
            featureCard(
                symbolName: "sparkles.rectangle.stack",
                version: "1.3.0",
                title: "Onboarding & Enhanced AI Tools",
                description: "Welcome new users with guided tours and powerful new writing assistance features.",
                bullets: [
                    "Interactive onboarding: Hero screen and toolbar tutorials",
                    "Rewrite Line: AI suggests single-line replacements matching rhyme and syllables",
                    "Suggest Rhymes: Find 8 rhyming words for your last word",
                    "Improve Flow: Focus on maintaining rhyme scheme patterns",
                    "Model Preferences: Customize Model G, Model G Core, and Model Y behaviors",
                    "Undo/Redo: Easily revert or restore your changes",
                    "Audio Import: Import audio files with automatic transcription"
                ]
            )
            
            featureCard(
                symbolName: "tray.and.arrow.down",
                version: "1.2.0",
                title: "Metadata & Import Update",
                description: "Enhanced note organization and seamless import workflows.",
                bullets: [
                    "Metadata system: BPM, Key, Scale, URL, and Folder tags",
                    "Import from Notes with guided workflow",
                    "Welcome Back screen for imported content",
                    "Metadata-based filtering (Folders, BPM, Scale, URL)",
                    "iOS 26 style glassmorphic containers"
                ]
            )
            
            featureCard(
                symbolName: "sparkles.rectangle.stack",
                version: "1.1.0",
                title: "Writing Intelligence Update",
                description: "Smarter rhyme awareness and clearer creative feedback.",
                bullets: [
                    "Group‑based rhyme coloring",
                    "Magnifying‑glass rhyme map with suggestions",
                    "Slant rhyme detection",
                    "Keyboard‑aware adaptive glass bars",
                    "Improved dark‑mode contrast"
                ]
            )
            
            featureCard(
                symbolName: "gauge.high",
                version: "1.1.1",
                title: "Performance Enhancements",
                description: "Faster, smoother rhyme analysis and rendering.",
                bullets: [
                    "Incremental rhyme analysis for stability",
                    "Attributed string caching to prevent rebuilds",
                    "Optimized eye toggle performance",
                    "Reduced CPU usage during text editing"
                ]
            )
            
            featureCard(
                symbolName: "checkmark.seal",
                version: "1.0.5",
                title: "Stability & Polish",
                description: "Smoother interactions and visual refinement.",
                bullets: [
                    "Navigation stability improvements",
                    "Cleaner editor alignment",
                    "Performance optimizations"
                ]
            )
        }
        .padding(24)
    }
    
    @ViewBuilder
    private func featureCard(
        symbolName: String,
        version: String,
        title: String,
        description: String,
        bullets: [String]
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity((GlassSettings.gloss - 0.6) / 3),
                                .white.opacity((GlassSettings.gloss - 0.6) / 4),
                                .white.opacity((GlassSettings.gloss - 0.6) / 3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .blendMode(.overlay)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    )
                
                Image(systemName: symbolName)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(width: 120, height: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Version \(version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .font(.title3.weight(.semibold))
                
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(bullets, id: \.self) { bullet in
                        Text("• \(bullet)")
                            .font(.callout)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .white.opacity((GlassSettings.gloss - 0.6) / 4),
                            .white.opacity((GlassSettings.gloss - 0.6) / 3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                )
        )
    }
}

// MARK: - Social Feed Content View (for Analytics Dashboard)

struct SocialFeedContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SocialPost.order, order: .forward)]) private var posts: [SocialPost]
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPostIndex: Int = 0
    @AppStorage("didSeedSocialPosts") private var didSeedSocialPosts: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Social")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 12)
            
            Group {
                if posts.isEmpty {
                    emptyStateView
                } else {
                    TabView(selection: $currentPostIndex) {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            SocialPostCardView(post: post)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(height: 600)
                    .onAppear {
                        // Reset to first post when view appears
                        if !posts.isEmpty && currentPostIndex >= posts.count {
                            currentPostIndex = 0
                        }
                    }
                }
            }
        }
        .padding(24)
        .task {
            if !didSeedSocialPosts {
                seedSocialPosts()
                didSeedSocialPosts = true
            }
        }
    }
    
    private func seedSocialPosts() {
        let samplePosts: [SocialPost] = [
            SocialPost(
                title: "Microphone Leveling Basics",
                caption: """
                Getting the right input level is crucial for clean recordings. Here's how to properly level your microphone:
                
                1. **Set your gain to -12dB to -6dB** - This leaves headroom and prevents clipping
                2. **Speak or sing at your normal volume** - Don't adjust your performance, adjust the gain
                3. **Watch the meters** - Aim for peaks around -6dB, average around -12dB
                4. **Test with your loudest passage** - Make sure you don't clip during dynamic moments
                
                Remember: It's better to record a bit quiet and boost later than to clip and lose audio quality forever.
                """,
                images: ["microphone", "setup"],
                category: "Microphone Setup",
                order: 1
            ),
            SocialPost(
                title: "First-Time Logic Pro Setup",
                caption: """
                New to Logic Pro? Here's your quick start guide:
                
                **Initial Setup:**
                1. Open Logic Pro and create a new project
                2. Select "Empty Project" or "Voice" template
                3. Choose your audio interface in Preferences > Audio
                4. Set your buffer size to 128 or 256 for recording (lower latency)
                
                **For Recording Vocals:**
                - Create an Audio Track (Track > New Audio Track)
                - Select your input (the microphone channel on your interface)
                - Enable Record Enable (R button) and Monitoring
                - Press Record and start performing
                
                **Pro Tip:** Use the built-in metronome (⌘U) to keep time, even for free-form poetry readings.
                """,
                images: ["logic", "setup"],
                category: "Logic Pro",
                order: 2
            ),
            SocialPost(
                title: "ProTools First Steps",
                caption: """
                Getting started with ProTools? Here's what you need to know:
                
                **Creating Your First Session:**
                1. File > New Session
                2. Choose your sample rate (48kHz is standard)
                3. Select your I/O settings (your audio interface)
                4. Create a new track: Track > New > Audio Track
                
                **Recording Setup:**
                - Set your track input to match your microphone
                - Enable Input Monitoring (speaker icon)
                - Arm the track for recording (red button)
                - Press Spacebar or F12 to record
                
                **Essential Shortcuts:**
                - Spacebar: Play/Stop
                - F12: Record
                - ⌘S: Save (do this often!)
                - ⌘Z: Undo
                
                ProTools has a learning curve, but once you master the basics, it's incredibly powerful for vocal recording and editing.
                """,
                images: ["protools", "setup"],
                category: "ProTools",
                order: 3
            ),
            SocialPost(
                title: "Sound Card Configuration",
                caption: """
                Your audio interface (sound card) is the bridge between your microphone and your DAW. Here's how to configure it properly:
                
                **Driver Settings:**
                - Use ASIO drivers on Windows (lowest latency)
                - Use Core Audio on Mac (built-in, works great)
                - Set buffer size: 128-256 for recording, 512-1024 for mixing
                
                **Input Levels:**
                - Use the gain knobs on your interface, not just software
                - Most interfaces have LED meters - watch for clipping (red)
                - Phantom power (48V) for condenser microphones only
                
                **Common Issues:**
                - No sound? Check your interface is selected in DAW preferences
                - Latency? Lower your buffer size (if your computer can handle it)
                - Clicks/pops? Increase buffer size or check sample rate mismatch
                
                **Recommended Settings:**
                - Sample Rate: 48kHz (standard for most work)
                - Bit Depth: 24-bit (gives you more headroom)
                - Buffer: 128-256 samples for recording
                """,
                images: ["soundcard", "audio"],
                category: "Sound Cards",
                order: 4
            ),
            SocialPost(
                title: "Microphone Types for Poets & Writers",
                caption: """
                Choosing the right microphone depends on your voice and recording space:
                
                **Condenser Microphones:**
                - Best for: Clear, detailed vocals, quiet spaces
                - Examples: Audio-Technica AT2020, Rode NT1-A
                - Need: Phantom power (48V) from your interface
                - Great for: Poetry readings, spoken word, clear vocals
                
                **Dynamic Microphones:**
                - Best for: Noisy environments, powerful voices
                - Examples: Shure SM58, SM7B
                - Need: More gain (louder preamp)
                - Great for: Rap, energetic performances, live feel
                
                **USB Microphones:**
                - Best for: Quick setup, beginners, podcasting
                - Examples: Blue Yeti, Audio-Technica ATR2100x
                - Need: Just plug in and go
                - Great for: Getting started quickly, simple setups
                
                **Pro Tip:** Start with what you have. A well-positioned, properly leveled cheap mic beats an expensive mic used poorly.
                """,
                images: ["microphone", "audio"],
                category: "Microphone Setup",
                order: 5
            ),
            SocialPost(
                title: "Recording Best Practices",
                caption: """
                Follow these tips for professional-sounding recordings:
                
                **Room Setup:**
                - Record in a quiet space (turn off AC, close windows)
                - Use soft surfaces to reduce echo (blankets, curtains)
                - Position mic 6-12 inches from your mouth
                - Use a pop filter to reduce plosives (P, B sounds)
                
                **Performance Tips:**
                - Warm up your voice before recording
                - Stay hydrated (water, not coffee before recording)
                - Take breaks between takes
                - Record multiple takes - you can comp the best parts
                
                **Technical:**
                - Record at 24-bit, 48kHz minimum
                - Leave headroom (don't peak above -6dB)
                - Use headphones to monitor (prevents feedback)
                - Save your project frequently (⌘S / Ctrl+S)
                
                **Editing:**
                - Remove breaths if they're distracting
                - Use fades to smooth transitions
                - Normalize or compress lightly for consistency
                - Export at the same sample rate you recorded
                """,
                images: ["audio", "setup"],
                category: "Audio Recording",
                order: 6
            )
        ]
        
        for post in samplePosts {
            modelContext.insert(post)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to seed social posts: \(error.localizedDescription)")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Posts Yet")
                .font(.title2.weight(.semibold))
            
            Text("Check back soon for curated tips and guides for writers and poets using Logic Pro, ProTools, and audio equipment.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 400)
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
