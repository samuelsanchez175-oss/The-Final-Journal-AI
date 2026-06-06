import SwiftUI
import SwiftData

// MARK: - Analytics Dashboard View (Phase 6: Analytics Dashboard)

struct AnalyticsDashboardView: View {
    @Query private var items: [Item]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                    color: .yellow
                )
                
                StatCard(
                    title: "Total Words",
                    value: "\(stats.totalWords)",
                    icon: "text.word.spacing",
                    color: .orange
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg Words/Note",
                    value: String(format: "%.0f", stats.averageWordsPerNote),
                    icon: "chart.bar",
                    color: .green
                )
                
                StatCard(
                    title: "Writing Streak",
                    value: stats.writingStreak == 1 ? "1 day" : "\(stats.writingStreak) days",
                    icon: "flame.fill",
                    color: .red
                )
            }
        }
    }
    
    private var writingActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Writing Activity")
            
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
            .background(SoftGlowCardBackground(color: .blue, glowStrength: 0.20))
        }
    }
    
    private var mostUsedWordsSection: some View {
        Group {
            if !stats.mostUsedWords.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    MomentumSectionHeader(title: "Most Used Words")
                    
                    VStack(spacing: 8) {
                        ForEach(Array(stats.mostUsedWords.prefix(5).enumerated()), id: \.offset) { index, word in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundStyle(Momentum.contentSecondary)
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(word.word)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("\(word.count)")
                                    .font(.caption)
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(SoftGlowCardBackground(color: Color(red: 0.13, green: 0.23, blue: 0.52), glowStrength: 0.28))
                }
            }
        }
    }
    
    private var musicMetadataSection: some View {
        Group {
            if stats.averageBPM != nil || stats.mostUsedKey != nil {
                VStack(alignment: .leading, spacing: 12) {
                    MomentumSectionHeader(title: "Music Metadata")
                    
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
                            .fill(Momentum.surfaceElevated)
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
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(stats.recentErrorCount)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.orange)
                        Text("Last 24 Hours")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
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
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Momentum.surfaceElevated)
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
                            .foregroundStyle(Momentum.contentSecondary)
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
                                        .foregroundStyle(Momentum.contentSecondary)
                                    
                                    Spacer()
                                    
                                    Text(error.timestamp, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(Momentum.contentSecondary)
                                }
                                
                                Text(error.message)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if let context = error.context {
                                    Text(context)
                                        .font(.caption)
                                        .foregroundStyle(Momentum.contentSecondary)
                                        .italic()
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Momentum.surfaceElevated)
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
                    MomentumSectionHeader(title: "AI Suggestion Feedback")
                    
                    VStack(spacing: 12) {
                        // Overall stats
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(feedbackStats.totalFeedback)")
                                    .font(.title2.weight(.bold))
                                Text("Total Feedback")
                                    .font(.caption)
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "%.0f%%", feedbackStats.acceptanceRate * 100))
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(feedbackStats.acceptanceRate > 0.6 ? .green : feedbackStats.acceptanceRate > 0.4 ? .orange : .red)
                                Text("Acceptance Rate")
                                    .font(.caption)
                                    .foregroundStyle(Momentum.contentSecondary)
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
                                                .foregroundStyle(Momentum.contentSecondary)
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
                                .foregroundStyle(Momentum.contentSecondary)
                            
                            Spacer()
                            
                            Text("Based on recent feedback")
                                .font(.caption2)
                                .foregroundStyle(Momentum.contentSecondary)
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
                                            .foregroundStyle(Momentum.contentSecondary)
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
                            .fill(Momentum.surfaceElevated)
                    )
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentumSectionHeader(title: "Achievements") {
                Button {
                    showAllAchievements = true
                } label: {
                    Text("View All")
                        .font(.momentumMetadata.weight(.semibold))
                        .foregroundStyle(Momentum.accent)
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
                        .foregroundStyle(Momentum.accent)
                    
                    Text("Achievements Unlocked")
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Momentum.hairline)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Momentum.accent)
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
            .background(SoftGlowCardBackground(color: Color(red: 0.13, green: 0.23, blue: 0.52), glowStrength: 0.28))
        }
    }
    
    @State private var selectedTab: AnalyticsTab = .overview
    @State private var lastDiagnosticTab: AnalyticsTab = .errors   // remembers which diagnostic to reopen

    enum AnalyticsTab: String, CaseIterable {
        case apiDebug = "API Debug"
        case modelGScores = "Lyric Scores"
        case overview = "Overview"
        case errors = "Errors"
        case network = "Network"
        case tokens = "Tokens"
        case jsonValidation = "JSON"
        case errorCorrelation = "Correlation"
    }

    // MARK: - Momentum tab bar (pills + grouped diagnostics)

    /// User-facing sections shown as primary pills.
    private var primarySections: [AnalyticsTab] {
        [.overview, .modelGScores]
    }

    /// Developer/telemetry views, folded behind the "Diagnostics" group pill.
    private var diagnosticTabs: [AnalyticsTab] {
        var tabs: [AnalyticsTab] = [.errors, .network, .tokens, .jsonValidation, .errorCorrelation]
        #if DEBUG
        tabs.append(.apiDebug)   // debug inspector stays DEBUG-only
        #endif
        return tabs
    }

    private var isDiagnosticActive: Bool { diagnosticTabs.contains(selectedTab) }

    private var chipAnimation: Animation? { reduceMotion ? nil : .easeOut(duration: 0.18) }

    private func chipIcon(for tab: AnalyticsTab) -> String {
        switch tab {
        case .overview:         return "square.grid.2x2.fill"
        case .modelGScores:     return "music.note"
        case .errors:           return "exclamationmark.triangle.fill"
        case .network:          return "dot.radiowaves.left.and.right"
        case .tokens:           return "number"
        case .jsonValidation:   return "curlybraces"
        case .errorCorrelation: return "point.3.connected.trianglepath.dotted"
        case .apiDebug:         return "ladybug.fill"
        }
    }

    /// Replaces the cramped `.segmented` picker: a scrollable row of Momentum pills,
    /// with the six diagnostics tabs revealed in a second row only when active.
    private var analyticsChipBar: some View {
        VStack(spacing: 10) {
            // Primary sections — user-facing first, Diagnostics group last.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(primarySections, id: \.self) { tab in
                        MomentumChip(
                            title: tab.rawValue,
                            systemImage: chipIcon(for: tab),
                            active: selectedTab == tab
                        ) {
                            withAnimation(chipAnimation) { selectedTab = tab }
                        }
                    }
                    MomentumChip(
                        title: "Diagnostics",
                        systemImage: "wrench.and.screwdriver.fill",
                        active: isDiagnosticActive
                    ) {
                        guard !isDiagnosticActive else { return }
                        withAnimation(chipAnimation) { selectedTab = lastDiagnosticTab }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Diagnostics sub-row — present only while a diagnostic view is open.
            if isDiagnosticActive {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(diagnosticTabs, id: \.self) { tab in
                            MomentumChip(
                                title: tab.rawValue,
                                systemImage: chipIcon(for: tab),
                                active: selectedTab == tab
                            ) {
                                withAnimation(chipAnimation) {
                                    selectedTab = tab
                                    lastDiagnosticTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Network Performance Section
    
    private var networkPerformanceSection: some View {
        let stats = NetworkPerformanceMonitor.shared.getStats()
        
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
                        .fill(Momentum.surfaceElevated)
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
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Momentum.surfaceElevated)                    )
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
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Momentum.surfaceElevated)                    )
                }
            }
        }
        .padding(24)
    }
    
    // MARK: - JSON Validation Section
    
    private var jsonValidationSection: some View {
        let stats = JSONValidationService.shared.getStats()
        
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
                            .fill(Momentum.surfaceElevated)                    )
                }
            }
        }
        .padding(24)
    }
    
    // MARK: - Error Correlation Section
    
    private var errorCorrelationSection: some View {
        let analysis = ErrorCorrelationAnalyzer.shared.analyzeErrors()
        
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
                                    .foregroundStyle(Momentum.contentSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Momentum.surfaceElevated)                    )
                }
            }
        }
        .padding(24)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector — Momentum pill bar (replaces the cramped .segmented picker)
                analyticsChipBar
                
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
                        case .apiDebug:
                            #if DEBUG
                            APIDebugInspectorView()
                            #else
                            EmptyView()
                            #endif
                        case .modelGScores:
                            VerseLedgerTrendView()
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
            .background(AtmosphereGlow())
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

// MARK: - Soft Glow Card Background

/// A soft, atmospheric color glow (à la the coral AtmosphereGlow) blooming up from
/// the bottom of an opaque card — replaces the flat top→bottom gradient fill that
/// read like a hard color band.
struct SoftGlowCardBackground: View {
    let color: Color
    var cornerRadius: CGFloat = 16
    var glowStrength: Double = 0.32
    var center: UnitPoint = UnitPoint(x: 0.5, y: 1.18)
    var endRadius: CGFloat = 260

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return shape
            .fill(Momentum.surfaceElevated)
            .overlay {
                RadialGradient(
                    gradient: Gradient(colors: [
                        color.opacity(glowStrength),
                        color.opacity(glowStrength * 0.4),
                        color.opacity(0)
                    ]),
                    center: center,
                    startRadius: 0,
                    endRadius: endRadius
                )
                .blur(radius: 22)
            }
            .clipShape(shape)
            .overlay(
                shape.strokeBorder(Momentum.hairline, lineWidth: Momentum.lineThin)
            )
    }
}

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
                .font(.momentumHero(26))
                .foregroundStyle(Momentum.contentPrimary)

            Text(title)
                .font(.momentumMetadata)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(SoftGlowCardBackground(color: color, cornerRadius: Momentum.corner))
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
                .foregroundStyle(Momentum.accent)
                .frame(width: 24)

            Text(label)
                .font(.momentumBody)
                .foregroundStyle(Momentum.contentPrimary)

            Spacer()

            Text(value)
                .font(.momentumBody.weight(.medium))
                .foregroundStyle(Momentum.contentPrimary)
        }
    }
}
