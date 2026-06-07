//
// ContentView.CCV.10.swift
//
// This file contains JournalLibraryView and Page1Filter enum.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings, JournalDetailPlaceholderView, lightHaptic)
// - ContentView.CCV.11.swift (for JournalListView, JournalRowView, JournalEmptyStateView)
// - ContentView.CCV.12.swift (for ProfilePopoverView)
// - ContentView.CCV.13.swift (for NoteEditorView)
//
import SwiftUI
import SwiftData
import UIKit
import Combine

private extension View {
    /// Action-button icon frame: a fixed 36pt square on iPhone (the compact nav-bar
    /// pill); expands to fill evenly across the iPad header row when `distributed`.
    func actionIconFrame(_ distributed: Bool) -> some View {
        frame(width: distributed ? nil : 44, height: 36)
            .frame(maxWidth: distributed ? .infinity : nil)
    }
}

struct JournalLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    // CRITICAL: Use SortDescriptor to make Query lazy - only loads when actually accessed
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @AppStorage("didSeedInitialNotes") private var didSeedInitialNotes: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var selectedImportedItem: Item?
    
    // Loading state - track if we've attempted to load items
    // Start as true, but UI shows immediately (non-blocking)
    @State private var isInitialLoad = true

    // MARK: - PAGE 1.1 Profile Entry Point (Button Only)
    @State private var showProfile: Bool = false
    @State private var showReleaseNotes: Bool = false
    @State private var showSupportShop: Bool = false
    @State private var showAnalytics: Bool = false
    @State private var showAchievements: Bool = false
    @State private var showAchievementCelebration: Bool = false
    @State private var currentAchievement: Achievement? = nil

    // MARK: - PAGE 1.2: Bottom Search Bar (UI + logic)
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showSearchCancel: Bool = false

    // MARK: - PAGE 1.4: Filters & Folders (UI only) - Metadata Filters
    @State private var selectedFilter: Page1Filter? = nil
    @State private var selectedFolder: String? = nil
    @State private var selectedBPM: Int? = nil
    @State private var selectedScale: String? = nil
    @State private var selectedURL: String? = nil
    
    // MARK: - Sorting (Page 1.4)
    enum SortType {
        case byCreated
        case byModified
    }
    
    enum SortDirection {
        case newestFirst  // Most recent at top
        case oldestFirst  // Oldest at top
    }
    
    @State private var sortType: SortType = .byCreated
    @State private var sortDirection: SortDirection = .newestFirst
    
    // MARK: - Filter Caching (Performance Optimization)
    @State private var cachedFilteredItems: [Item]? = nil
    @State private var lastFilterHash: Int = 0
    @State private var lastItemsCount: Int = 0
    @State private var debouncedSearchText: String = ""
    @State private var searchDebounceTask: Task<Void, Never>?

    // MARK: - PAGE 1: Local Visibility Gate for Bottom Bar
    @State private var isOnPage1: Bool = true
    
    // MARK: - PAGE 1.3: Import from Notes
    @State private var showImportNotesInstructions: Bool = false
    
    // MARK: - Selection Mode
    @State private var isSelectionMode: Bool = false
    @State private var selectedItems: Set<PersistentIdentifier> = []
    @State private var showFolderSelection: Bool = false

    // iPad: drive the split-view sidebar visibility from our own toggle button
    // (the system sidebar-toggle is removed so all 6 header buttons share one row).
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    // The 5-button cluster (Page 1.1). Shared: iPhone shows it as a compact
    // nav-bar glass pill (distributed: false); iPad spreads it evenly full-width
    // across iPadSidebarHeader (distributed: true) so it reads as a top bar.
    private func page1ActionButtons(distributed: Bool = false, includeSidebarToggle: Bool = false) -> some View {
        HStack(spacing: distributed ? 2 : 4) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showAnalytics = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .actionIconFrame(distributed)
            }
            .accessibilityLabel("Analytics")
            .accessibilityHint("View writing statistics and insights")

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showProfile.toggle()
            } label: {
                Image(systemName: "person.crop.circle")
                    .actionIconFrame(distributed)
            }
            .accessibilityLabel("Profile")
            .accessibilityHint("Open profile settings")

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showReleaseNotes = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .actionIconFrame(distributed)
            }
            .accessibilityLabel("Release Notes")
            .accessibilityHint("View app updates and new features")

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showSupportShop = true
            } label: {
                Image(systemName: "bag")
                    .actionIconFrame(distributed)
            }
            .accessibilityLabel("Support & Shop")
            .accessibilityHint("Support the creators and view shop")

            Menu {
                Button {
                    prepareHapticForNewNote()
                    addItem()
                } label: {
                    Label("New Note", systemImage: "square.and.pencil")
                }
                Button {
                    showImportNotesInstructions = true
                } label: {
                    Label("Import from Notes", systemImage: "note.text")
                }
                Button {
                    prepareHapticForNewNote()
                    addItem()
                } label: {
                    Label("New Note (Record Audio)", systemImage: "waveform")
                }
                Divider()
                Button {
                    isSelectionMode = true
                } label: {
                    Label("Select", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "plus")
                    .actionIconFrame(distributed)
            }

            if includeSidebarToggle {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        columnVisibility = (columnVisibility == .detailOnly) ? .all : .detailOnly
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                        .actionIconFrame(distributed)
                }
                .accessibilityLabel("Toggle sidebar")
                .accessibilityHint("Show or hide the journal list")
            }
        }
        .foregroundStyle(Momentum.accent)
    }

    // PAGE 1 (iPad / regular width): stacked coral header — action buttons row,
    // large "Journal" title, then the filter pills.
    private var iPadSidebarHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            page1ActionButtons(distributed: true, includeSidebarToggle: true)
                .frame(maxWidth: .infinity)
                .glassEffect(in: Capsule())
                .overlay(GyroSpecularEdge(shape: Capsule(), lineWidth: 1.3)) // iOS 26-style tilt glint — matches the iPhone glass pill
                .padding(.horizontal, 16)

            Text("Penwork")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)

            page1FiltersView
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Group {
                // Show UI structure immediately - don't block on loading
                // Notes will appear progressively as they load
                if items.isEmpty && !isInitialLoad {
                    JournalEmptyStateView(onCreate: addItem)
                } else {
                    VStack(spacing: 0) {
                        if horizontalSizeClass == .regular && !isSelectionMode {
                            iPadSidebarHeader
                        } else {
                            page1FiltersView
                        }
                        // Show notes list immediately - it will populate as items load
                        // Use a subtle loading indicator only if truly needed
                        ZStack {
                        JournalListView(
                            items: filteredItems,
                            onDelete: deleteItems,
                            isOnPage1: $isOnPage1,
                            isSelectionMode: $isSelectionMode,
                            selectedItems: $selectedItems
                        )
                            
                            // Show minimal loading indicator only during initial load with no items
                            if isInitialLoad && items.isEmpty {
                                VStack {
                                    Spacer()
                                    ProgressView()
                                        .tint(.white.opacity(0.6))
                                        .scaleEffect(0.8)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                            }
                        }
                    }
                }
            }
            .background {
                AtmosphereGlow()
                    .overlay(alignment: .top) {
                        // Uniform full-width coral wash that reaches the very top edge
                        // and corners — the radial AtmosphereGlow alone falls off there,
                        // which left the top-left corner pale above the header buttons.
                        LinearGradient(
                            colors: [Momentum.accent.opacity(0.32), Momentum.accent.opacity(0.10), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .allowsHitTesting(false)
                    }
                    .ignoresSafeArea()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationTitle((horizontalSizeClass == .regular && !isSelectionMode) ? "" : (isSelectionMode ? "\(selectedItems.count) Selected" : "Penwork"))
            .toolbar {
                if isSelectionMode {
                    // Selection mode toolbar - show only selection controls
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isSelectionMode = false
                            selectedItems.removeAll()
                        } label: {
                            Text("Cancel")
                        }
                    }
                    
                    // Delete button (only show if items selected)
                    if !selectedItems.isEmpty {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(role: .destructive) {
                                deleteSelectedItems()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .accessibilityLabel("Delete Selected")
                            .accessibilityHint("Delete \(selectedItems.count) selected notes")
                        }
                        
                        // Folder button
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showFolderSelection = true
                            } label: {
                                Label("Folder", systemImage: "folder")
                            }
                            .accessibilityLabel("Move to Folder")
                            .accessibilityHint("Move selected notes to a folder")
                        }
                    }
                } else if horizontalSizeClass != .regular {
                    // iPhone (compact): the 5-button glass pill in the nav bar.
                    // On iPad the same cluster lives in iPadSidebarHeader.
                    // MARK: - PAGE 1.1
                    ToolbarItem(placement: .navigationBarTrailing) {
                        page1ActionButtons()
                            .glassEffect(in: Capsule())
                    }
                }
            }
            .toolbar(removing: .sidebarToggle)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isOnPage1 {
                    page1BottomBarWithCompose
                } else {
                    Color.clear
                        .frame(height: 0)
                        .allowsHitTesting(false)
                }
            }
            .navigationSplitViewColumnWidth(min: 320, ideal: 360, max: 420)
        } detail: {
            ZStack(alignment: .topLeading) {
                if let selectedItem = selectedImportedItem {
                    NoteEditorView(item: selectedItem)
                        .onAppear { isOnPage1 = false }
                        .onDisappear {
                            isOnPage1 = true
                            selectedImportedItem = nil
                        }
                } else {
                    JournalDetailPlaceholderView(onCreate: {
                        prepareHapticForNewNote()
                        addItem()
                    })
                }

                // When the sidebar is collapsed the header toggle is hidden with it,
                // so surface a re-show button here as the way back to the list.
                if columnVisibility == .detailOnly {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.25)) { columnVisibility = .all }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.title3)
                            .foregroundStyle(Momentum.accent)
                            .frame(width: 40, height: 40)
                            .glassEffect(in: Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 12)
                    .accessibilityLabel("Show journal list")
                    .transition(.opacity)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showProfile) {
            ProfilePopoverView()
                .presentationDetents([PresentationDetent.large])
                .presentationDragIndicator(Visibility.visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showProfile)) { _ in
            showProfile = true
        }
        .sheet(isPresented: $showReleaseNotes) {
            ReleaseNotesSheetView()
                .presentationDetents([PresentationDetent.large])
                .presentationDragIndicator(Visibility.visible)
        }
        .sheet(isPresented: $showSupportShop) {
            SupportShopSheetView()
                .presentationDetents([PresentationDetent.large])
                .presentationDragIndicator(Visibility.visible)
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsDashboardView()
                .presentationDetents([PresentationDetent.large])
                .presentationDragIndicator(Visibility.visible)
        }
        .overlay {
            if showAchievementCelebration, let achievement = currentAchievement {
                AchievementCelebrationView(achievement: achievement) {
                    showAchievementCelebration = false
                    currentAchievement = nil
                }
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .onAppear {
            StartupPerformanceTracker.shared.recordMilestone("journallibraryview_appear")
            
            // PRIORITY 1: Load notes immediately - no delay!
            // Access query right away so notes appear as fast as possible
            StartupPerformanceTracker.shared.recordMilestone("query_access_start")
            
            // Track when @Query property is first accessed
            // This helps identify if there's any delay in SwiftData query initialization
            StartupPerformanceTracker.shared.recordMilestone("query_property_accessed")
            
            // Force Query to load by accessing items immediately
            // @Query is lazy but accessing it triggers loading
            // This happens synchronously but SwiftData may do async work internally
            let itemsCount = items.count
            
            StartupPerformanceTracker.shared.recordMilestone("query_count_evaluated")
            
            // Track the actual count to verify query worked
            if itemsCount > 0 {
                StartupPerformanceTracker.shared.recordMilestone("query_has_items")
            } else {
                StartupPerformanceTracker.shared.recordMilestone("query_empty")
            }
            
            StartupPerformanceTracker.shared.recordMilestone("query_access_complete")
            
            // Mark initial load complete immediately after query access
            // UI will show notes progressively as they load
            isInitialLoad = false
            
            // PRIORITY 2: Defer ALL non-essential operations; run on MainActor so we can use items (not Sendable)
            Task { @MainActor in
                // Wait 3-5 seconds before doing heavy background work
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                StartupPerformanceTracker.shared.recordMilestone("background_ops_start")
                UserBehaviorTracker.shared.checkAchievementsWithItems(items: items)
                StartupPerformanceTracker.shared.recordMilestone("achievements_checked")
            }
            
            // Initialize debounced search text immediately (lightweight)
            debouncedSearchText = searchText
        }
        .onChange(of: items.count) { _, _ in
            // Defer achievement checking when items change - don't block UI
            if !isInitialLoad {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    UserBehaviorTracker.shared.checkAchievementsWithItems(items: items)
                }
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            // Debounce search text changes to avoid filtering on every keystroke
            searchDebounceTask?.cancel()
            searchDebounceTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                if !Task.isCancelled {
                    await MainActor.run {
                        debouncedSearchText = newValue
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AchievementUnlocked"))) { notification in
            // Show achievement celebration when unlocked
            if let achievements = notification.userInfo?["achievements"] as? [Achievement],
               let firstAchievement = achievements.first {
                showAchievementCelebration = true
                currentAchievement = firstAchievement
                
                // Schedule notification
                NotificationManager.shared.scheduleAchievementNotification(firstAchievement)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAchievements"))) { _ in
            showAchievements = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAnalytics"))) { _ in
            showAnalytics = true
        }
        .sheet(isPresented: $showImportNotesInstructions) {
            ImportNotesInstructionsView(
                modelContext: modelContext,
                onNoteCreated: { newItem in
                    // Dismiss sheet first, then navigate
                    showImportNotesInstructions = false
                    // Small delay to ensure sheet dismisses before navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedImportedItem = newItem
                    }
                }
            )
            .presentationDetents([PresentationDetent.large])
            .presentationDragIndicator(Visibility.visible)
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showFolderSelection) {
            FolderSelectionSheetView(
                selectedItems: selectedItems,
                items: items,
                onAssign: { folderName in
                    assignSelectedItemsToFolder(folderName)
                    showFolderSelection = false
                },
                onCancel: {
                    showFolderSelection = false
                }
            )
            .presentationDetents([PresentationDetent.medium])
            .presentationDragIndicator(Visibility.visible)
        }
        .task {
            let demoNotes: [(title: String, body: String)] = [
                (
                    "Night Cycle",
                    """
                    I write at night when the light goes low
                    The fight inside starts to show
                    I pace the room, slow and tight
                    Trying to rhyme my way through the night

                    The sight of dawn feels far away
                    I stay awake till break of day
                    My mind rewinds what I might say
                    Another line, another way
                    """
                ),
                (
                    "Time & Motion",
                    """
                    Every time I try to rhyme
                    I climb the thought inside my mind
                    The clock won't stop, it keeps its time
                    I chase the sound I left behind

                    I write the line, erase the line
                    Then trace the phrase till it aligns
                    Each verse a curse, each curse a sign
                    That all good words arrive in time
                    """
                ),
                (
                    "Street Echo",
                    """
                    I walk the block where echoes bounce
                    Each step I take, the rhythm counts
                    The sound around begins to mount
                    A beat, a breath, the right amount

                    I hear the streets repeat the tone
                    A cracked-up verse, a microphone
                    I speak in heat, but not alone
                    The city hums in flesh and bone
                    """
                )
            ]

            let existingTitles = Set(items.map { $0.title })

            for note in demoNotes where !existingTitles.contains(note.title) {
                modelContext.insert(
                    Item(
                        timestamp: Date(),
                        title: note.title,
                        body: note.body
                    )
                )
            }

            didSeedInitialNotes = true
        }
    }

    private func prepareHapticForNewNote() {
        HapticFeedbackManager.shared.play(.newNote)
    }

    private func addItem() {
        // SEGMENT 21: Create new note with immediate selection routing
            let nextIndex = (items.map { item in
                if let number = Int(item.title.replacingOccurrences(of: "Note ", with: "")) {
                    return number
                }
                return 0
            }.max() ?? 0) + 1
            let newItem = Item(
                timestamp: Date(),
                title: "Note \(nextIndex)",
                body: ""
            )
            modelContext.insert(newItem)
        
        // Save the context immediately to ensure the item is persisted
        do {
            try modelContext.save()
        } catch {
            print("Failed to save new item: \(error)")
        }
        
        // SEGMENT 21: Force the NavigationSplitView to jump to the detail view immediately
        // Setting selectedImportedItem triggers the detail closure to render NoteEditorView
            selectedImportedItem = newItem
        
        // Track note creation for achievements
        UserBehaviorTracker.shared.trackWritingActivity(wordsWritten: 0, noteCreated: true)
        
        // Check achievements with updated items
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UserBehaviorTracker.shared.checkAchievementsWithItems(items: items + [newItem])
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let filteredItems = self.filteredItems
            let itemToDelete = offsets.map { filteredItems[$0] }
            for item in itemToDelete {
                if let index = items.firstIndex(where: { $0.id == item.id}) {
                    modelContext.delete(items[index])
                }
            }
        }
    }
    
    // MARK: - Selection Mode Functions
    private func deleteSelectedItems() {
        withAnimation {
            let itemsToDelete = items.filter { selectedItems.contains($0.id) }
            for item in itemsToDelete {
                modelContext.delete(item)
            }
            selectedItems.removeAll()
            isSelectionMode = false
        }
    }
    
    private func assignSelectedItemsToFolder(_ folderName: String?) {
        withAnimation {
            let itemsToUpdate = items.filter { selectedItems.contains($0.id) }
            for item in itemsToUpdate {
                item.folder = folderName
            }
            selectedItems.removeAll()
            isSelectionMode = false
        }
    }

    private var filteredItems: [Item] {
        // CRITICAL: Return empty array during initial load to avoid blocking
        guard !isInitialLoad else { return [] }
        
        // Use debounced search text for filtering to avoid filtering on every keystroke
        let searchTextToUse = debouncedSearchText
        
        // Compute hash of filter state and sort order for change detection (performance optimization)
        var filterHasher = Hasher()
        filterHasher.combine(searchTextToUse)
        if let filter = selectedFilter {
            filterHasher.combine(filter.hashValue)
        } else {
            filterHasher.combine(0)
        }
        filterHasher.combine(selectedFolder)
        filterHasher.combine(selectedBPM)
        filterHasher.combine(selectedScale)
        filterHasher.combine(selectedURL)
        filterHasher.combine(sortType == .byCreated ? 1 : 2) // Include sort type in hash
        filterHasher.combine(sortDirection == .newestFirst ? 1 : 0) // Include sort direction in hash
        filterHasher.combine(items.count)
        let currentFilterHash = filterHasher.finalize()
        
        // Return cached result if filter state, sort order, and items count haven't changed
        if currentFilterHash == lastFilterHash,
           items.count == lastItemsCount,
           let cached = cachedFilteredItems {
            return cached
        }
        
        // Recompute filtered items (only when filter state or items actually changed)
        var base: [Item]

        if searchTextToUse.isEmpty {
            base = items
        } else {
            let q = searchTextToUse.lowercased()

            if q.hasPrefix("title:") {
                let t = q.replacingOccurrences(of: "title:", with: "").trimmingCharacters(in: .whitespaces)
                base = items.filter { $0.title.lowercased().contains(t) }
            } else if q.hasPrefix("body:") {
                let b = q.replacingOccurrences(of: "body:", with: "").trimmingCharacters(in: .whitespaces)
                base = items.filter { $0.body.lowercased().contains(b) }
            } else {
                base = items.filter {
                    $0.title.lowercased().contains(q) ||
                    $0.body.lowercased().contains(q)
                }
            }
        }

        // Apply metadata filters
        var filtered = base
        
        // Only apply filters if a filter type is active
        if let activeFilter = selectedFilter {
            // Apply active filter type: if a filter type is selected but no specific value,
            // show all items with that metadata type. Otherwise, filter by specific values.
            switch activeFilter {
            case .folders:
                if let folder = selectedFolder {
                    // Filter by specific folder
                    filtered = filtered.filter { $0.folder == folder }
                } else {
                    // Show all items that have a folder
                    filtered = filtered.filter { $0.folder != nil }
                }
            case .bpm:
                if let bpm = selectedBPM {
                    // Filter by specific BPM
                    filtered = filtered.filter { $0.bpm == bpm }
                } else {
                    // Show all items that have a BPM
                    filtered = filtered.filter { $0.bpm != nil }
                }
            case .scale:
                if let scale = selectedScale {
                    // Filter by specific scale
                    filtered = filtered.filter { $0.scale == scale }
                } else {
                    // Show all items that have a scale
                    filtered = filtered.filter { $0.scale != nil }
                }
            case .url:
                if let url = selectedURL {
                    // Filter by specific URL
                    filtered = filtered.filter { $0.urlAttachment == url }
                } else {
                    // Show all items that have a URL
                    filtered = filtered.filter { $0.urlAttachment != nil }
                }
            }
        }
        
        // Apply additional filters from other filter types if they have specific values selected
        // This allows combining multiple metadata filters
        if selectedFilter != .folders, let folder = selectedFolder {
            filtered = filtered.filter { $0.folder == folder }
        }
        
        if selectedFilter != .bpm, let bpm = selectedBPM {
            filtered = filtered.filter { $0.bpm == bpm }
        }
        
        if selectedFilter != .scale, let scale = selectedScale {
            filtered = filtered.filter { $0.scale == scale }
        }
        
        if selectedFilter != .url, let url = selectedURL {
            filtered = filtered.filter { $0.urlAttachment == url }
        }
        
        // Sort by selected type and direction
        let sorted = filtered.sorted { item1, item2 in
            let date1: Date
            let date2: Date
            
            switch sortType {
            case .byCreated:
                date1 = item1.timestamp
                date2 = item2.timestamp
            case .byModified:
                // Use modifiedDate if available, otherwise fall back to timestamp
                date1 = item1.modifiedDate ?? item1.timestamp
                date2 = item2.modifiedDate ?? item2.timestamp
            }
            
            switch sortDirection {
            case .newestFirst:
                return date1 > date2 // Newest at top
            case .oldestFirst:
                return date1 < date2 // Oldest at top
            }
        }
        
        // Cache the sorted results and update hash (performance optimization)
        // Schedule state update to avoid modifying during view update
        DispatchQueue.main.async { [currentFilterHash, sorted, itemsCount = items.count] in
            self.cachedFilteredItems = sorted
            self.lastFilterHash = currentFilterHash
            self.lastItemsCount = itemsCount
        }
        
        return sorted
    }

    // MARK: - PAGE 1.2 & 1.5: Unified iOS 26 Style Container
    private var page1BottomBarWithCompose: some View {
        HStack(spacing: 12) {
            // Search Bar Container (iOS 26 Style)
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)

                TextField("Search", text: $searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .font(.callout)
                    .onChange(of: isSearchFocused) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showSearchCancel = newValue
                        }
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Image(systemName: "mic.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Capsule().fill(Momentum.surfaceElevated.opacity(0.72))) // more opaque, less see-through
            .glassEffect(in: Capsule())
            .overlay(Capsule().stroke(isSearchFocused ? Momentum.accent : Color.clear,
                                      lineWidth: Momentum.lineThin))
            .overlay(GyroSpecularEdge(shape: Capsule(), lineWidth: 1.3)) // iOS 26-style tilt glint
            
            // Quick Compose Button (iOS 26 Style - Integrated)
            Button(action: {
                prepareHapticForNewNote()
                addItem()
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Momentum.accent)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Momentum.surfaceElevated.opacity(0.72))) // more opaque, less see-through
                    .glassEffect(in: Circle())
                    .overlay(GyroSpecularEdge(shape: Circle(), lineWidth: 1.3)) // iOS 26-style tilt glint
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .background(Color.clear)
        .chromeClamp()   // search field + compose live in a fixed 44pt bar — cap Dynamic Type growth
    }

    private var page1FiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Sort Button (Time Created)
                sortButton
                
                ForEach(Page1Filter.allCases) { filter in
                    filterPill(filter)
                }
            }
            .padding(.leading, 16) // Leading padding for first button
            .padding(.trailing, 16) // Trailing padding for last button
            .padding(.vertical, 8)
        }
        .chromeClamp()   // horizontally-scrolling chip bar — keep pills usable at large text
    }

    // MARK: - Sort Button (Menu)
    private var sortButton: some View {
        Menu {
            // Sort by Time Created
            Section("Time Created") {
                Button {
                    lightHaptic()
                    withAnimation {
                        sortType = .byCreated
                        sortDirection = .newestFirst
                        cachedFilteredItems = nil
                    }
                } label: {
                    HStack {
                        Text("Newest First")
                        if sortType == .byCreated && sortDirection == .newestFirst {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    lightHaptic()
                    withAnimation {
                        sortType = .byCreated
                        sortDirection = .oldestFirst
                        cachedFilteredItems = nil
                    }
                } label: {
                    HStack {
                        Text("Oldest First")
                        if sortType == .byCreated && sortDirection == .oldestFirst {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            // Sort by Last Modified
            Section("Last Modified") {
                Button {
                    lightHaptic()
                    withAnimation {
                        sortType = .byModified
                        sortDirection = .newestFirst
                        cachedFilteredItems = nil
                    }
                } label: {
                    HStack {
                        Text("Newest First")
                        if sortType == .byModified && sortDirection == .newestFirst {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    lightHaptic()
                    withAnimation {
                        sortType = .byModified
                        sortDirection = .oldestFirst
                        cachedFilteredItems = nil
                    }
                } label: {
                    HStack {
                        Text("Oldest First")
                        if sortType == .byModified && sortDirection == .oldestFirst {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: sortDirection == .newestFirst ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.callout.weight(.medium))
                Text(sortType == .byCreated ? "Created" : "Modified")
                    .font(.callout)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(.primary)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial) // glassmorphic — lets the coral wash show through
                    .overlay(Capsule().stroke(Momentum.hairline, lineWidth: Momentum.lineThin))
                    .overlay(GyroSpecularEdge(shape: Capsule(), lineWidth: 1.2)) // iOS 26-style tilt glint
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func filterPill(_ filter: Page1Filter) -> some View {
        Menu {
            // Show "Off" option to turn off the filter completely
            Button {
                // Turn off this filter
                if selectedFilter == filter {
                    selectedFilter = nil
                }
                clearFilterSelection(for: filter)
            } label: {
                HStack {
                    Text("Off")
                    if selectedFilter != filter {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            // Show "All [Filter]" option to show all items with that metadata type
            Button {
                selectedFilter = filter
                clearFilterSelection(for: filter)
            } label: {
                HStack {
                    Text("All \(filter.rawValue)")
                    if selectedFilter == filter && getSelectedValue(for: filter) == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            // Show unique values for this metadata type
            ForEach(getUniqueValues(for: filter), id: \.self) { value in
                Button {
                    selectedFilter = filter
                    setFilterSelection(for: filter, value: value)
                } label: {
                    HStack {
                        Text(displayValue(for: filter, value: value))
                        if isSelected(for: filter, value: value) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.callout.weight(.medium))
                Text(filter.rawValue)
                    .font(.callout)
                if hasActiveSelection(for: filter) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(selectedFilter == filter ? Momentum.accent : Momentum.contentSecondary)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial) // glassmorphic — lets the coral wash show through
                    .overlay(Capsule().stroke(selectedFilter == filter ? Momentum.accent : Momentum.hairline,
                                              lineWidth: Momentum.lineThin))
                    .overlay(GyroSpecularEdge(shape: Capsule(), lineWidth: 1.2)) // iOS 26-style tilt glint
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Filter Helper Functions
    
    // Cache unique filter values to avoid recalculation
    @State private var cachedUniqueValues: [Page1Filter: [AnyHashable]] = [:]
    @State private var lastUniqueValuesHash: Int = 0
    
    private func getUniqueValues(for filter: Page1Filter) -> [AnyHashable] {
        // Compute hash of items for change detection
        let itemsHash = items.count.hashValue
        
        // Return cached values if items haven't changed
        if itemsHash == lastUniqueValuesHash,
           let cached = cachedUniqueValues[filter] {
            return cached
        }
        
        // Recompute unique values
        let uniqueValues: [AnyHashable]
        switch filter {
        case .folders:
            uniqueValues = Array(Set(items.compactMap { $0.folder })).sorted()
        case .bpm:
            uniqueValues = Array(Set(items.compactMap { $0.bpm })).sorted()
        case .scale:
            uniqueValues = Array(Set(items.compactMap { $0.scale })).sorted()
        case .url:
            uniqueValues = Array(Set(items.compactMap { $0.urlAttachment })).sorted()
        }
        
        // Cache the unique values
        // Schedule state update to avoid modifying during view update
        DispatchQueue.main.async { [filter, uniqueValues, itemsHash] in
            self.cachedUniqueValues[filter] = uniqueValues
            if itemsHash != self.lastUniqueValuesHash {
            // Clear cache if items changed
                self.lastUniqueValuesHash = itemsHash
                self.cachedUniqueValues = [filter: uniqueValues]
            }
        }
        
        return uniqueValues
    }
    
    private func displayValue(for filter: Page1Filter, value: AnyHashable) -> String {
        switch filter {
        case .folders:
            return value as? String ?? ""
        case .bpm:
            if let bpm = value as? Int {
                return "\(bpm) BPM"
            }
            return ""
        case .scale:
            return value as? String ?? ""
        case .url:
            if let url = value as? String {
                // Show shortened URL
                return url.count > 30 ? String(url.prefix(30)) + "..." : url
            }
            return ""
        }
    }
    
    private func isSelected(for filter: Page1Filter, value: AnyHashable) -> Bool {
        switch filter {
        case .folders:
            return selectedFolder == (value as? String)
        case .bpm:
            return selectedBPM == (value as? Int)
        case .scale:
            return selectedScale == (value as? String)
        case .url:
            return selectedURL == (value as? String)
        }
    }
    
    private func hasActiveSelection(for filter: Page1Filter) -> Bool {
        switch filter {
        case .folders:
            return selectedFolder != nil
        case .bpm:
            return selectedBPM != nil
        case .scale:
            return selectedScale != nil
        case .url:
            return selectedURL != nil
        }
    }
    
    private func getSelectedValue(for filter: Page1Filter) -> AnyHashable? {
        switch filter {
        case .folders:
            return selectedFolder
        case .bpm:
            return selectedBPM
        case .scale:
            return selectedScale
        case .url:
            return selectedURL
        }
    }
    
    private func setFilterSelection(for filter: Page1Filter, value: AnyHashable) {
        switch filter {
        case .folders:
            selectedFolder = value as? String
        case .bpm:
            selectedBPM = value as? Int
        case .scale:
            selectedScale = value as? String
        case .url:
            selectedURL = value as? String
        }
    }
    
    private func clearFilterSelection(for filter: Page1Filter) {
        switch filter {
        case .folders:
            selectedFolder = nil
        case .bpm:
            selectedBPM = nil
        case .scale:
            selectedScale = nil
        case .url:
            selectedURL = nil
        }
    }
}

enum Page1Filter: String, CaseIterable, Identifiable {
    case folders = "Folders"
    case bpm = "BPM"
    case scale = "Scale"
    case url = "URL"

    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .folders: return "folder"
        case .bpm: return "metronome"
        case .scale: return "slider.horizontal.3"
        case .url: return "link"
        }
    }
}
