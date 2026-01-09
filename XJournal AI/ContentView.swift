import SwiftUI
import SwiftData
import UIKit
import Combine
import NaturalLanguage
import AVFoundation
import Speech
import PhotosUI

// =======================================================
// PAGE MAP (ARCHITECTURAL)
// — LOCKED — DO NOT MODIFY
// Any structural changes here require explicit review.
// =======================================================
// Page 1    — Journal Library (Home / Notes List)
// Page 1.1  — Profile Entry Point (Top Right)
// Page 1.1.1 — Release Notes (Top Right, Segment 1 Sheet)
// Page 1.1.2 — Support / Shop (Top Right, Segment 1 Sheet)
// Page 1.2  — Bottom Search Bar (Home)
// Page 1.3  — Import / Create Menu (Top Right)
// Page 1.4  — Filters & Folders (Home)
// Page 1.5  — Quick Compose Button (Bottom Right)
// Page 2    — Note Editor (Writing Surface)
// Page 3    — Keyboard Bottrom Dynamic Island Toolbar
// Page 3.1  — Clip / Attach Menu (Files, Notes, Voice Memos)
// Page 3.1.1 — Keyboard Dynamic Toolbar Part 2 (Overlay)
// Page 3.2  — AI Assist Menu (Read‑Only Suggestions)
// Page 3.3  — Eye Toggle (Rhyme Group Visibility)
// NOTE: Eye toggle state is an internal implementation detail of Page 3.3,
// not a standalone page.
// Page 3.4  — Debug / Diagnostics Tool (Analysis Only)
// Page 3.4.1 — UIKit Overlay Test Flag (Debug Placeholder)
// Page 3.5  — Magnifying Glass (Rhyme Group List / Map)
// Page 5    — Rhyme Highlighter Engine (Base)
// Page 6    — Visual Highlight Overlay
// Page 7    — Phonetic Rhyme Engine (CMUDICT)
// Page 8    — Rhyme Categories (Perfect vs Near)
// Page 9    — Internal Rhymes & Position Awareness
// Page 10   — Rhyme Intelligence Panel
// Page 11   — Syllables & Stress Illumination
// Page 12   — Cadence & Flow Metrics
// =======================================================
// SEGMENTS (DESIGN / INTERACTION CONTRACTS)
// Segment 1 — Editorial Release Notes Sheet
// Notes-style release notes presented as a sheet with medium + large detents,
// dense editorial layout, and feature cards. Client-facing, readable, polished.
// Segment 2 — Menu-Anchored Glass Popovers
// Menu-driven, button-anchored liquid-glass popovers (non-sheet),
// matching Page 1.3 Import/Create behavior.
// Segment 3 — Focused Morphing
// UI elements expand / contract based on focus state (search, keyboard)
// with no layout drift — internal morphing only.
// Segment 4 — Micro-Compression on Touch
// Subtle press-in compression on touch-down,
// released on lift or expansion. Applied consistently across controls.
// Segment 5 — Keyboard-Aware Adaptive Glass Bars
// GlassEffectContainer-based toolbars that live above the keyboard,
// support collapse (+) and expand states,
// and never shift the underlying text surface.

// Segment 6 — Editorial Symbol Tiles
// Notes-style editorial symbol tiles used in release notes and announcements.
// Uses SF Symbols rendered inside soft glass cards instead of image assets.
// Ensures zero asset dependency, consistent loading, and system-native polish.
// Supports versioned feature cards with icon + text pairings.

// =======================================================
// MARK: - PAGE 1: Journal Library
// =======================================================
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedImportedItem: Item?

    var body: some View {
        JournalLibraryView(selectedImportedItem: $selectedImportedItem)
            .onOpenURL { url in
                guard url.scheme == "finaljournal",
                      url.host == "import"
                else { return }

                let defaults = UserDefaults(suiteName: "group.com.finaljournal.app")
                let source = defaults?.string(forKey: "importSource")

                // Import from Apple Notes
                if source == "notes",
                   let text = defaults?.string(forKey: "importedNoteText"),
                   !text.isEmpty {

                    let newItem = Item(
                        timestamp: Date(),
                        title: "Imported Note",
                        body: text
                    )

                    modelContext.insert(newItem)
                    selectedImportedItem = newItem

                    defaults?.removeObject(forKey: "importedNoteText")
                }

                // Import from Voice Memos
                if source == "voiceMemo",
                   let path = defaults?.string(forKey: "importedAudioPath") {

                    let newItem = Item(
                        timestamp: Date(),
                        title: "Voice Memo",
                        body: ""
                    )

                    newItem.audioPath = path
                    modelContext.insert(newItem)
                    selectedImportedItem = newItem

                    defaults?.removeObject(forKey: "importedAudioPath")
                }

                defaults?.removeObject(forKey: "importSource")
            }
    }
}

struct JournalLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @AppStorage("didSeedInitialNotes") private var didSeedInitialNotes: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedImportedItem: Item?

    // MARK: - PAGE 1.1 Profile Entry Point (Button Only)
    @State private var showProfile: Bool = false
    @State private var showReleaseNotes: Bool = false
    @State private var showSupportShop: Bool = false

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

    // MARK: - PAGE 1: Local Visibility Gate for Bottom Bar
    @State private var isOnPage1: Bool = true
    
    // MARK: - PAGE 1.3: Import from Notes
    @State private var showImportNotesInstructions: Bool = false
    
    // MARK: - Selection Mode
    @State private var isSelectionMode: Bool = false
    @State private var selectedItems: Set<PersistentIdentifier> = []
    @State private var showFolderSelection: Bool = false

    var body: some View {
        NavigationSplitView {
            Group {
                if items.isEmpty {
                    JournalEmptyStateView(onCreate: addItem)
                } else {
                    VStack(spacing: 0) {
                        page1FiltersView
                        JournalListView(
                            items: filteredItems,
                            onDelete: deleteItems,
                            isOnPage1: $isOnPage1,
                            isSelectionMode: $isSelectionMode,
                            selectedItems: $selectedItems
                        )
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle(isSelectionMode ? "\(selectedItems.count) Selected" : "Journal")
            .toolbar {
                // MARK: - PAGE 1.1
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile.toggle()
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showReleaseNotes = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSupportShop = true
                    } label: {
                        Image(systemName: "bag")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelectionMode {
                        // Selection mode toolbar
                        HStack(spacing: 16) {
                            // Cancel button
                            Button {
                                isSelectionMode = false
                                selectedItems.removeAll()
                            } label: {
                                Text("Cancel")
                            }
                            
                            // Delete button (only show if items selected)
                            if !selectedItems.isEmpty {
                                Button(role: .destructive) {
                                    deleteSelectedItems()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(Color.red)
                                        )
                                        .foregroundStyle(.white)
                                }
                                
                                // Folder button
                                Button {
                                    showFolderSelection = true
                                } label: {
                                    Label("Folder", systemImage: "folder")
                                }
                            }
                        }
                    } else {
                        // Normal mode - show menu
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
                                // Audio recording is available in NoteEditorView
                                // This creates a new note where user can record
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
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isOnPage1 {
                    page1BottomBarWithCompose
                } else {
                    Color.clear
                        .frame(height: 0)
                        .allowsHitTesting(false)
                }
            }
        } detail: {
            if let selectedItem = selectedImportedItem {
                NoteEditorView(item: selectedItem)
                    .onAppear { isOnPage1 = false }
                    .onDisappear { 
                        isOnPage1 = true
                        selectedImportedItem = nil
                    }
            } else {
                JournalDetailPlaceholderView()
            }
        }
        .popover(isPresented: $showProfile, arrowEdge: .top) {
            ProfilePopoverView()
        }
        .sheet(isPresented: $showReleaseNotes) {
            ReleaseNotesSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSupportShop) {
            SupportShopSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
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
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
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
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func addItem() {
        withAnimation {
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
        // Compute hash of filter state and sort order for change detection (performance optimization)
        var filterHasher = Hasher()
        filterHasher.combine(searchText)
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

        if searchText.isEmpty {
            base = items
        } else {
            let q = searchText.lowercased()

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
        cachedFilteredItems = sorted
        lastFilterHash = currentFilterHash
        lastItemsCount = items.count
        
        return sorted
    }

    // MARK: - PAGE 1.2 & 1.5: Unified iOS 26 Style Container
    private var page1BottomBarWithCompose: some View {
        HStack(spacing: 12) {
            // Search Bar Container (iOS 26 Style)
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Search", text: $searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .font(.system(size: 16))
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
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Image(systemName: "mic.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        // Enhanced glassmorphism effect
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.15 : 0.25),
                                        Color.white.opacity(colorScheme == .dark ? 0.12 : 0.20),
                                        Color.white.opacity(colorScheme == .dark ? 0.15 : 0.25)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .blendMode(.overlay)
                            .clipShape(Capsule(style: .continuous))
                    )
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening * 1.5 : 0.05))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isSearchFocused ? 0.25 : 0.12),
                                        Color.white.opacity(isSearchFocused ? 0.20 : 0.10),
                                        Color.white.opacity(isSearchFocused ? 0.25 : 0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSearchFocused ? 1.5 : 0.5
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
            
            // Quick Compose Button (iOS 26 Style - Integrated)
            Button(action: {
                prepareHapticForNewNote()
                addItem()
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                // Enhanced glassmorphism effect
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(colorScheme == .dark ? 0.2 : 0.3),
                                                Color.white.opacity(colorScheme == .dark ? 0.15 : 0.22),
                                                Color.white.opacity(colorScheme == .dark ? 0.2 : 0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blendMode(.overlay)
                                    .clipShape(Circle())
                            )
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening * 1.5 : 0.05))
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.2),
                                                Color.white.opacity(0.15),
                                                Color.white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            .shadow(
                                color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                                radius: 8,
                                x: 0,
                                y: 2
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .background(Color.clear)
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
                    .font(.system(size: 12, weight: .medium))
                Text(sortType == .byCreated ? "Created" : "Modified")
                    .font(.callout)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(.primary)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .clipShape(Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(.primary.opacity(0.18))
                    )
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
                    .font(.system(size: 12, weight: .medium))
                Text(filter.rawValue)
                    .font(.callout)
                if hasActiveSelection(for: filter) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(selectedFilter == filter ? .primary : .secondary)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        .clipShape(Capsule(style: .continuous))

                    if selectedFilter != filter {
                        Capsule(style: .continuous).fill(Color.clear)
                    }
                }
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(.primary.opacity(selectedFilter == filter ? 0.18 : 0.08))
                )
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
        cachedUniqueValues[filter] = uniqueValues
        if itemsHash != lastUniqueValuesHash {
            // Clear cache if items changed
            lastUniqueValuesHash = itemsHash
            cachedUniqueValues = [filter: uniqueValues]
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

struct JournalListView: View {
    @Environment(\.colorScheme) private var colorScheme
    let items: [Item]
    let onDelete: (IndexSet) -> Void
    @Binding var isOnPage1: Bool
    @Binding var isSelectionMode: Bool
    @Binding var selectedItems: Set<PersistentIdentifier>

    var body: some View {
        List {
            ForEach(items) { item in
                JournalRowView(
                    item: item,
                    isOnPage1: $isOnPage1,
                    isSelectionMode: $isSelectionMode,
                    selectedItems: $selectedItems
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden, edges: .all)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(.plain)
        .contentMargins(.horizontal, 0, for: .scrollContent)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
    }
}

struct JournalRowView: View {
    let item: Item
    @Binding var isOnPage1: Bool
    @Binding var isSelectionMode: Bool
    @Binding var selectedItems: Set<PersistentIdentifier>
    
    // Cache computed properties to avoid recalculation on every view update
    @State private var cachedTitle: String?
    @State private var cachedPreview: String?
    @State private var lastItemId: PersistentIdentifier?
    
    private var isSelected: Bool {
        selectedItems.contains(item.id)
    }

    var body: some View {
        Group {
            if isSelectionMode {
                // Selection mode - show checkbox
                Button {
                    if isSelected {
                        selectedItems.remove(item.id)
                    } else {
                        selectedItems.insert(item.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        // Checkbox
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(isSelected ? .blue : .secondary)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(noteTitle)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(notePreview)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }
                            .padding(.vertical, 12)

                            Divider()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
            } else {
                // Normal mode - NavigationLink
                NavigationLink {
                    NoteEditorView(item: item)
                        .onAppear { isOnPage1 = false }
                        .onDisappear { isOnPage1 = true }
                } label: {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(noteTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(notePreview)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                .padding(.vertical, 12)

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
            .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            // Update cache when view appears if item changed
            updateCacheIfNeeded()
        }
        .onChange(of: item.id) { _, _ in
            // Update cache when item ID changes
            updateCacheIfNeeded()
        }
    }
    
    /// Update cached values if item has changed
    private func updateCacheIfNeeded() {
        // Only recalculate if item actually changed
        guard lastItemId != item.id else { return }
        
        cachedTitle = item.title.isEmpty ? "Untitled Note" : item.title
        
        // Cache preview - format date only once
        if item.body.isEmpty {
            cachedPreview = item.timestamp.formatted(
                Date.FormatStyle(date: .numeric, time: .standard)
            )
        } else {
            cachedPreview = item.body
        }
        
        lastItemId = item.id
    }

    private var noteTitle: String {
        if let cached = cachedTitle, lastItemId == item.id {
            return cached
        }
        // Fallback if cache not yet set
        return item.title.isEmpty ? "Untitled Note" : item.title
    }

    private var notePreview: String {
        if let cached = cachedPreview, lastItemId == item.id {
            return cached
        }
        // Fallback if cache not yet set
        if item.body.isEmpty {
            return item.timestamp.formatted(
                Date.FormatStyle(date: .numeric, time: .standard)
            )
        } else {
            return item.body
        }
    }
}

struct JournalEmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    let onCreate: () -> Void

    var body: some View {
        Button(action: onCreate) {
            VStack(spacing: 12) {
                Image(systemName: "note.text")
                    .font(.largeTitle)
                Text("No Notes Yet")
                    .font(.headline)
                Text("Tap + to start writing")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
    }
}

// MARK: - PAGE 1.1 Profile Entry Point (Static UI + Editable Fields, No Persistence)

struct ProfilePopoverView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("profile_name") private var storedName: String = ""
    @AppStorage("profile_email") private var storedEmail: String = ""
    @AppStorage("profile_phone") private var storedPhone: String = ""
    @AppStorage("profile_avatar_data") private var storedAvatarData: Data?

    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: Image?

    @State private var name: String
    @State private var email: String
    @State private var phone: String

    init() {
        _name = State(initialValue: UserDefaults.standard.string(forKey: "profile_name") ?? "")
        _email = State(initialValue: UserDefaults.standard.string(forKey: "profile_email") ?? "")
        _phone = State(initialValue: UserDefaults.standard.string(forKey: "profile_phone") ?? "")
    }

    private var isEmailValid: Bool {
        email.isEmpty || email.contains("@")
    }

    private var isPhoneValid: Bool {
        phone.isEmpty || phone.filter(\.isNumber).count >= 10
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        isEmailValid &&
        isPhoneValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 96, height: 96)

                        if let avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.top, 8)

            VStack(spacing: 14) {
                profileField(label: "Name", text: $name, placeholder: "Your name")
                profileField(
                    label: "Email",
                    text: $email,
                    placeholder: "you@email.com",
                    keyboard: .emailAddress,
                    isValid: isEmailValid,
                    helperText: isEmailValid ? nil : "Enter a valid email address"
                )
                profileField(
                    label: "Phone",
                    text: $phone,
                    placeholder: "+1 (000) 000‑0000",
                    keyboard: .phonePad,
                    isValid: isPhoneValid,
                    helperText: isPhoneValid ? nil : "Include area code"
                )
            }

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 14) {
                Text("API Settings")
                    .font(.headline)
                
                profileSecureField(
                    label: "OpenAI API Key",
                    text: Binding(
                        get: { KeychainHelper.shared.getAPIKey() ?? "" },
                        set: { newValue in
                            if !newValue.isEmpty {
                                try? KeychainHelper.shared.saveAPIKey(newValue)
                            } else {
                                try? KeychainHelper.shared.deleteAPIKey()
                            }
                        }
                    ),
                    placeholder: "sk-...",
                    helperText: "Get your key from platform.openai.com/api-keys"
                )
            }

            Divider().opacity(0.15)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your Invites")
                    .font(.headline)

                ShareLink(
                    item: URL(string: "https://finaljournal.app/invite")!,
                    subject: Text("Join me on The Final Journal AI"),
                    message: Text("Check out The Final Journal AI and join my creative journey!"),
                    preview: SharePreview("The Final Journal AI", image: Image(systemName: "sparkles"))
                ) {
                    Label("Share Invite Link", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }

            HStack {
                Spacer()

                Button {
                    storedName = name
                    storedEmail = email
                    storedPhone = phone

                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(minWidth: 88)
                        .padding(.vertical, 10)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.4)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        )
        .onAppear {
            if let data = storedAvatarData,
               let uiImage = UIImage(data: data) {
                avatarImage = Image(uiImage: uiImage)
            }
        }
        .onChange(of: selectedItem) { oldValue, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    avatarImage = Image(uiImage: uiImage)
                    if let jpegData = uiImage.jpegData(compressionQuality: 0.9) {
                        storedAvatarData = jpegData
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func profileSecureField(
        label: String,
        text: Binding<String>,
        placeholder: String,
        helperText: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            SecureField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )

            if let helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func profileField(
        label: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        isValid: Bool? = nil,
        helperText: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    (isValid == false ? Color.red.opacity(0.35) : Color.primary.opacity(0.08)),
                                    lineWidth: isValid == false ? 1.2 : 1
                                )
                        )
                )

            if let helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(isValid == false ? .red : .secondary)
            }
        }
    }
}

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item

    @State private var isRhymeOverlayVisible: Bool = false
    @State private var showRhymeDiagnostics: Bool = false
    @FocusState private var isEditorFocused: Bool
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var isToolbarExpanded: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @StateObject private var rhymeEngineState = RhymeEngineState()
    
    // Helper function to count trailing newlines
    private func countTrailingNewlines(in text: String) -> Int {
        var count = 0
        var index = text.endIndex
        while index > text.startIndex {
            let previousIndex = text.index(before: index)
            if text[previousIndex] == "\n" {
                count += 1
                index = previousIndex
            } else {
                break
            }
        }
        return count
    }
    
    // No longer using trailing newlines - using padding instead to avoid text splitting issues
    // This function is kept for compatibility but is no longer used
    private func ensureTrailingNewlines() {
        // Padding is handled by TextEditor's bottom padding instead
    }

    private var rhymeGroups: [RhymeHighlighterEngine.RhymeGroup] {
        rhymeEngineState.cachedGroups
    }

    private var computedHighlights: [Highlight] {
        // Use actual text for highlight calculations (no trailing newlines)
        let displayText = item.body
        var highlights = rhymeEngineState.cachedHighlights
        
        // Add context highlights for last 4 lines when generating suggestions
        if showContextHighlight {
            let contextHighlights = calculateContextHighlights(text: displayText)
            highlights.append(contentsOf: contextHighlights)
        }
        
        // Add AI-generated text highlights (blue color)
        let aiHighlights = calculateAITextHighlights(text: displayText)
        highlights.append(contentsOf: aiHighlights)
        
        return highlights
    }
    
    // MARK: - AI Text Highlights
    
    private func calculateAITextHighlights(text: String) -> [Highlight] {
        guard !text.isEmpty, !item.aiTextRanges.isEmpty else { return [] }
        
        var highlights: [Highlight] = []
        var validRanges: [String] = [] // Track valid ranges for cleanup
        
        for rangeString in item.aiTextRanges {
            let components = rangeString.split(separator: ":")
            guard components.count == 2,
                  let start = Int(components[0]),
                  let end = Int(components[1]),
                  start >= 0,
                  end <= text.count,
                  start < end else {
                // Range is invalid, skip it (will be cleaned up)
                continue
            }
            
            // Create range safely with bounds checking using limitedBy
            guard let startIndex = text.index(text.startIndex, offsetBy: start, limitedBy: text.endIndex),
                  let endIndex = text.index(text.startIndex, offsetBy: end, limitedBy: text.endIndex),
                  startIndex < endIndex else {
                continue
            }
            
            let range = startIndex..<endIndex
            
            // Use blue color (index 3) for AI-generated text
            highlights.append(Highlight(
                range: range,
                colorIndex: 3, // Blue color
                strength: .perfect,
                rhymeType: .endRhyme
            ))
            validRanges.append(rangeString) // Track valid ranges
        }
        
        // Clean up invalid ranges if any were removed
        if validRanges.count != item.aiTextRanges.count {
            item.aiTextRanges = validRanges
        }
        
        return highlights
    }
    
    // MARK: - Context Highlights (Last 4 lines for AI suggestions)
    
    private func calculateContextHighlights(text: String) -> [Highlight] {
        guard !text.isEmpty else { return [] }
        
        let lines = text.components(separatedBy: "\n")
        guard lines.count >= 1 else { return [] }
        
        // Get last 4 lines (or fewer if text has fewer lines)
        let last4Lines = Array(lines.suffix(4))
        var highlights: [Highlight] = []
        
        // Calculate ranges for each line
        var currentIndex = text.startIndex
        var lineIndex = 0
        
        // Find the starting index of the last 4 lines
        var linesSkipped = max(0, lines.count - 4)
        
        for (index, line) in lines.enumerated() {
            if index >= linesSkipped {
                // This is one of the last 4 lines
                let lineEndIndex = text.index(currentIndex, offsetBy: line.count, limitedBy: text.endIndex) ?? text.endIndex
                let lineRange = currentIndex..<lineEndIndex
                
                // Create highlight for entire line (including newline if not last line)
                let highlightRange: Range<String.Index>
                if index < lines.count - 1 {
                    // Include newline character
                    let newlineEnd = text.index(lineRange.upperBound, offsetBy: 1, limitedBy: text.endIndex) ?? text.endIndex
                    highlightRange = lineRange.lowerBound..<newlineEnd
                } else {
                    // Last line, no newline
                    highlightRange = lineRange
                }
                
                // Use blue background highlight (index 3 from RhymeColorPalette) and perfect strength
                // This is a background highlight, not foreground color
                highlights.append(Highlight(
                    range: highlightRange,
                    colorIndex: 3, // Blue color for background
                    strength: .perfect,
                    rhymeType: .endRhyme
                ))
            }
            
            // Move to next line
            if index < lines.count - 1 {
                // Skip to after the newline
                let nextLineStart = text.index(currentIndex, offsetBy: line.count + 1, limitedBy: text.endIndex) ?? text.endIndex
                currentIndex = nextLineStart
            }
        }
        
        return highlights
    }

    // MARK: - Metadata Popover States
    @State private var showBPMPopover: Bool = false
    @State private var showKeyPopover: Bool = false
    @State private var showScalePopover: Bool = false
    @State private var showURLPopover: Bool = false
    @State private var showFolderPopover: Bool = false
    @State private var showAudioRecorder: Bool = false
    @State private var showRapSuggestions: Bool = false
    @State private var isShowingRecalled: Bool = false
    @State private var showContextHighlight: Bool = false
    @StateObject private var rapSuggestionEngine = RapSuggestionEngine()
    @State private var slamAnimationText: String? = nil
    @State private var slamAnimationOffset: CGFloat = 0
    @State private var slamAnimationScale: CGFloat = 1.0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TextField("Title", text: $item.title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 680)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .scaleEffect(scrollOffset < -20 ? 0.94 : 1.0)
                    .opacity(scrollOffset < -20 ? 0.6 : 1.0)
                    .animation(.easeOut(duration: 0.2), value: scrollOffset)

                // MARK: - Metadata Pills Section
                metadataPillsView
                    .padding(.vertical, 8)

                Divider()
                    .frame(maxWidth: .infinity) // Extend divider to full width

                ScrollView(.vertical, showsIndicators: false) {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetKey.self,
                                        value: geo.frame(in: .named("editorScroll")).minY)
                    }
                    .frame(height: 0)
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $item.body)
                                .focused($isEditorFocused)
                                .font(.body)
                                .frame(maxWidth: 680)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 400) // Large bottom padding to create writing space without newlines
                                .frame(minHeight: 400, alignment: .top)
                                .scrollContentBackground(.hidden)
                                .textEditorStyle(.plain)
                                .foregroundStyle(isRhymeOverlayVisible ? .clear : .primary)
                                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion, constrain horizontal
                                .allowsHitTesting(!isRhymeOverlayVisible) // Disable interaction when overlay is visible
                                .scrollDismissesKeyboard(.never) // Prevent keyboard from dismissing on scroll
                                .onAppear {
                                    // Auto-focus TextEditor for new notes (empty body)
                                    if item.body.isEmpty {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isEditorFocused = true
                                        }
                                    }
                                }

                            // AI text is now only shown in the main overlay when eye toggle is on
                            // When eye toggle is off, AI text is just normal text in the TextEditor

                            // Always keep view in hierarchy - optimize by using opacity instead of conditional rendering
                            // This prevents view recreation on toggle, allowing cache reuse
                            // When eye toggle is on, show ALL text with highlights (not just highlights)
                            RhymeHighlightTextView(
                                text: item.body,
                                highlights: computedHighlights,
                                isVisible: isRhymeOverlayVisible,
                                showFullText: true, // Always show full text, not just highlights
                                horizontalPadding: 20, // Match TextEditor padding
                                isEditable: isRhymeOverlayVisible, // Make overlay editable when visible
                                onTextChange: { newText in
                                    // Sync changes from overlay back to item.body
                                    item.body = newText
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .leading) // Align to left edge, full width
                            .padding(.leading, 20) // Left padding only
                            .padding(.trailing, 20) // Right padding
                            .padding(.top, 8)
                            .padding(.bottom, 400) // Match TextEditor bottom padding for consistency
                            .opacity(isRhymeOverlayVisible ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.18), value: isRhymeOverlayVisible)
                            .allowsHitTesting(isRhymeOverlayVisible) // Allow interaction when overlay is visible
                            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion, constrain horizontal
                            .id("\(item.id)_\(isRhymeOverlayVisible)") // Force recreation when toggle changes to fix scrolling
                            
                            // Slam animation overlay (iMessage-style)
                            if let slamText = slamAnimationText {
                                Text(slamText)
                                    .font(.body)
                                    .foregroundStyle(.blue)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                    .frame(maxWidth: 680, alignment: .leading)
                                    .offset(y: slamAnimationOffset)
                                    .scaleEffect(slamAnimationScale)
                                    .opacity(slamAnimationScale < 1.0 ? 0.6 : 1.0)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        // MARK: - Audio Player (if audio exists)
                        if let audioPath = item.audioPath, !audioPath.isEmpty {
                            AudioPlayerView(audioPath: audioPath)
                                .padding(.top, 16)
                                .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Timestamp Metadata Bar (Bottom of Note)
                        noteTimestampBar
                            .padding(.top, 24)
                            .padding(.bottom, keyboardObserver.height > 0 ? 80 : 100) // Space above toolbar
                    }
                    .frame(maxWidth: 680) // Constrain to max width
                    .frame(maxWidth: .infinity) // But allow it to center
                }
                .coordinateSpace(name: "editorScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            DynamicIslandToolbarView(
                isExpanded: $isToolbarExpanded,
                isRhymeOverlayVisible: $isRhymeOverlayVisible,
                showDiagnostics: $showRhymeDiagnostics,
                rhymeGroups: rhymeGroups,
                currentText: item.body,
                highlights: computedHighlights,
                isEditorFocused: $isEditorFocused,
                keyboardHeight: $keyboardObserver.height,
                showAudioRecorder: $showAudioRecorder,
                showRapSuggestions: $showRapSuggestions,
                rapSuggestionEngine: rapSuggestionEngine,
                isShowingRecalled: $isShowingRecalled,
                showContextHighlight: $showContextHighlight
            )
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity) // Center the toolbar within safe area
            .padding(.bottom, keyboardObserver.height > 0 ? 6 : 14)
        }
        .sheet(isPresented: $showRapSuggestions) {
            RapSuggestionView(
                suggestions: isShowingRecalled ? rapSuggestionEngine.previousSuggestions : rapSuggestionEngine.suggestions,
                isLoading: rapSuggestionEngine.isLoading && !isShowingRecalled,
                loadingStep: isShowingRecalled ? nil : rapSuggestionEngine.loadingStep,
                error: isShowingRecalled ? nil : rapSuggestionEngine.error,
                onSelect: { suggestion in
                    insertRapSuggestion(suggestion, isAIGenerated: true)
                },
                onCopy: { suggestion in
                    copyRapSuggestionWithSlam(suggestion)
                },
                onDismiss: {
                    showRapSuggestions = false
                    isShowingRecalled = false
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        prepareHapticForNewNote()
                        createAndNavigateToNewNote()
                    } label: {
                        Label("New Note", systemImage: "square.and.pencil")
                    }

                    Button {
                        // TODO: Import from Apple Notes
                    } label: {
                        Label("Import from Notes", systemImage: "note.text")
                    }

                    Button {
                        openAudioRecorder()
                    } label: {
                        Label("Record Audio", systemImage: "waveform")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderView(item: item)
        }
        .onAppear {
            // Ensure text has 4 trailing newlines for writing space
            ensureTrailingNewlines()
            // Immediate analysis on appear (no debounce needed - user isn't typing yet)
            rhymeEngineState.updateIfNeeded(text: item.body)
        }
        .onChange(of: item.body) { oldValue, newValue in
            // Track modification date when body changes
            if oldValue != newValue && !newValue.isEmpty {
                item.modifiedDate = Date()
            }
            // Debounced analysis - waits 400ms after typing stops before analyzing
            // This reduces computation during active typing and improves performance
            rhymeEngineState.updateIfNeeded(text: newValue)
        }
        .onChange(of: item.title) { oldValue, newValue in
            // Track modification date when title changes
            if oldValue != newValue && !newValue.isEmpty {
                item.modifiedDate = Date()
            }
        }
        // MARK: - Metadata Popovers (Segment 2)
        .sheet(isPresented: $showBPMPopover) {
            BPMPopoverView(bpm: $item.bpm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .popover(isPresented: $showKeyPopover) {
            KeyPopoverView(key: $item.key)
        }
        .popover(isPresented: $showScalePopover) {
            ScalePopoverView(key: $item.key, scale: $item.scale)
        }
        .sheet(isPresented: $showURLPopover) {
            URLAttachmentPopoverView(url: $item.urlAttachment)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .popover(isPresented: $showFolderPopover) {
            FolderPopoverView(folder: $item.folder)
        }
    }
    
    // MARK: - Note Timestamp Metadata Bar
    private var noteTimestampBar: some View {
        VStack(spacing: 10) {
            // Created Date
            VStack(alignment: .leading, spacing: 4) {
                Text("Created")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(formatTimestamp(item.timestamp))
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Modified Date (if exists)
            if let modifiedDate = item.modifiedDate {
                VStack(alignment: .leading, spacing: 4) {
                    Text("modified")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(formatTimestamp(modifiedDate))
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 680)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity) // Center the bar
    }
    
    // MARK: - Timestamp Formatting Helper
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M - d - yyyy h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: date)
            .lowercased()
    }

    // MARK: - Metadata Pills View
    private var metadataPillsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // BPM Pill Menu
                bpmPillMenu
                
                // Key Pill Menu
                keyPillMenu
                
                // Scale Pill Menu
                scalePillMenu
                
                // URL Pill Menu
                urlPillMenu
                
                // Folder Pill Menu
                folderPillMenu
            }
            .padding(.leading, 16) // Leading padding for first pill
            .padding(.trailing, 16) // Trailing padding for last pill
        }
        .frame(maxWidth: .infinity) // Extend to full width
    }
    
    // MARK: - BPM Pill Menu
    private var bpmPillMenu: some View {
        Menu {
            // Quick Select BPM Values
            ForEach([60, 90, 120, 140, 160, 180, 200], id: \.self) { bpmValue in
                Button {
                    item.bpm = bpmValue
                } label: {
                    HStack {
                        Text("\(bpmValue) BPM")
                        Spacer()
                        if item.bpm == bpmValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            
            Divider()
            
            // Custom BPM (opens popover)
            Button {
                showBPMPopover = true
            } label: {
                Label("Custom BPM", systemImage: "slider.horizontal.3")
            }
            
            if item.bpm != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.bpm = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "metronome",
                label: item.bpm != nil ? "\(item.bpm!) BPM" : "BPM",
                isSet: item.bpm != nil
            )
        }
    }
    
    // MARK: - Key Pill Menu
    private var keyPillMenu: some View {
        Menu {
            // All Musical Keys
            ForEach(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"], id: \.self) { keyValue in
                Button {
                    item.key = keyValue
                } label: {
                    HStack {
                        Text(keyValue)
                        Spacer()
                        if item.key == keyValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            
            if item.key != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.key = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "music.note",
                label: item.key ?? "KEY",
                isSet: item.key != nil
            )
        }
    }
    
    // MARK: - Scale Pill Menu
    private var scalePillMenu: some View {
        Menu {
            // All Scales
            ForEach([
                "Chromatic",
                "Major",
                "Natural Minor",
                "Harmonic Minor",
                "Melodic Minor",
                "Ionian (Major)",
                "Dorian",
                "Phrygian",
                "Lydian",
                "Mixolydian",
                "Aeolian (Natural Minor)",
                "Locrian"
            ], id: \.self) { scaleValue in
                Button {
                    item.scale = scaleValue
                } label: {
                    HStack {
                        Text(scaleValue)
                        Spacer()
                        if item.scale == scaleValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
            
            if item.scale != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.scale = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "slider.horizontal.3",
                label: item.scale ?? "SCALE",
                isSet: item.scale != nil
            )
        }
    }
    
    // MARK: - URL Pill Menu
    private var urlPillMenu: some View {
        Menu {
            Button {
                showURLPopover = true
            } label: {
                Label("Set URL", systemImage: "link")
            }
            
            if item.urlAttachment != nil {
                Divider()
                
                if let url = item.urlAttachment, let urlObj = URL(string: url) {
                    ShareLink(item: urlObj) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                    }
                }
                
                Button(role: .destructive) {
                    item.urlAttachment = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "link",
                label: item.urlAttachment != nil ? "URL" : "URL",
                isSet: item.urlAttachment != nil
            )
        }
    }
    
    // MARK: - Folder Pill Menu
    private var folderPillMenu: some View {
        Menu {
            Button {
                showFolderPopover = true
            } label: {
                Label("Set Folder", systemImage: "folder")
            }
            
            if item.folder != nil {
                Divider()
                
                Button(role: .destructive) {
                    item.folder = nil
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            metadataPillLabel(
                icon: "folder",
                label: item.folder ?? "FOLDER",
                isSet: item.folder != nil
            )
        }
    }
    
    // MARK: - Metadata Pill Label Component
    @ViewBuilder
    private func metadataPillLabel(icon: String, label: String, isSet: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(isSet ? .primary : .secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(
                            isSet ? Color.primary.opacity(0.2) : Color.primary.opacity(0.1),
                            lineWidth: isSet ? 1 : 0.5
                        )
                )
        )
    }

    private func prepareHapticForNewNote() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func createAndNavigateToNewNote() {
        let descriptor = FetchDescriptor<Item>()
        let count = (try? modelContext.fetch(descriptor).count) ?? 0
        let nextIndex = count + 1

        let newItem = Item(
            timestamp: Date(),
            title: "Note \(nextIndex)",
            body: ""
        )
        modelContext.insert(newItem)

        dismiss()
    }
    
    // MARK: - Voice Memos Integration / Audio Recording
    private func openAudioRecorder() {
        lightHaptic()
        // Note: Audio recording will be handled in NoteEditorView via binding
    }
    
    // MARK: - Rap Suggestions
    private func insertRapSuggestion(_ suggestion: RapSuggestion, isAIGenerated: Bool = false) {
        // Set up slam animation
        slamAnimationText = suggestion.text
        slamAnimationOffset = -200 // Start above
        slamAnimationScale = 0.8
        
        let originalLength = item.body.count
        let prefix = item.body.isEmpty ? "" : "\n"
        
        // Animate slam effect
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            slamAnimationOffset = 0
            slamAnimationScale = 1.0
        }
        
        // Insert suggestion at the end of the body, with a newline if body is not empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.item.body.isEmpty {
                self.item.body = suggestion.text
            } else {
                self.item.body += prefix + suggestion.text
            }
            
            // Track AI-generated text range
            if isAIGenerated {
                let startIndex = originalLength + (self.item.body.isEmpty ? 0 : prefix.count)
                let endIndex = self.item.body.count
                let rangeString = "\(startIndex):\(endIndex)"
                self.item.aiTextRanges.append(rangeString)
            }
            
            // Update modification date
            self.item.modifiedDate = Date()
            
            // Re-enable focus and ensure cursor is at the end
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isEditorFocused = true
            }
        }
        
        // Clear animation after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                self.slamAnimationText = nil
                self.slamAnimationOffset = 0
                self.slamAnimationScale = 1.0
            }
        }
    }
    
    private func copyRapSuggestionWithSlam(_ suggestion: RapSuggestion) {
        // Set up slam animation
        slamAnimationText = suggestion.text
        slamAnimationOffset = -200 // Start above
        slamAnimationScale = 0.8
        
        // Animate slam effect
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            slamAnimationOffset = 0
            slamAnimationScale = 1.0
        }
        
        // Insert the text after animation starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            insertRapSuggestion(suggestion, isAIGenerated: true)
        }
        
        // Clear animation after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                slamAnimationText = nil
                slamAnimationOffset = 0
                slamAnimationScale = 1.0
            }
        }
    }
}

struct DynamicIslandToolbarView: View {
    @Binding var isExpanded: Bool
    @Binding var isRhymeOverlayVisible: Bool
    @Binding var showDiagnostics: Bool
    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String
    let highlights: [Highlight]
    @FocusState.Binding var isEditorFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Binding var keyboardHeight: CGFloat
    @State private var showRhymeGroupsPopover: Bool = false
    @Binding var showAudioRecorder: Bool
    @Binding var showRapSuggestions: Bool
    @ObservedObject var rapSuggestionEngine: RapSuggestionEngine
    @Binding var isShowingRecalled: Bool
    @Binding var showContextHighlight: Bool
    @State private var rotationAngle: Double = 0
    
    // MARK: - Audio Recording
    private func openAudioRecorder() {
        lightHaptic()
        showAudioRecorder = true
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if !isExpanded {
                    Button {
                        lightHaptic()
                        isExpanded = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                                    .clipShape(Circle())
                            )
                    }
                } else {
                    HStack(spacing: 14) {
                        Button {
                            lightHaptic()
                            isExpanded = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }

                        Menu {
                            Button("Attach File") { }
                            Button("Import from Notes") { }
                            Button {
                                openAudioRecorder()
                            } label: {
                                Label("Record Audio", systemImage: "waveform")
                            }
                        } label: {
                            Image(systemName: "paperclip")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }

                        Menu {
                            Button {
                                lightHaptic()
                                isEditorFocused = false
                                isShowingRecalled = false // Clear recall flag when generating new suggestions
                                // Show context highlight for last 4 lines
                                showContextHighlight = true
                                Task {
                                    await rapSuggestionEngine.generateSuggestions(
                                        text: currentText,
                                        highlights: highlights
                                    )
                                    // Hide context highlight when generation completes
                                    showContextHighlight = false
                                    showRapSuggestions = true
                                }
                            } label: {
                                Label("Suggest Next Lines", systemImage: "sparkles")
                            }
                            
                            Button {
                                lightHaptic()
                                isEditorFocused = false
                                // Set flag to show previous suggestions (no AI call)
                                isShowingRecalled = true
                                showRapSuggestions = true
                            } label: {
                                Label("Recall Suggested Lines", systemImage: "clock.arrow.circlepath")
                            }
                            .disabled(rapSuggestionEngine.previousSuggestions.isEmpty)
                            
                            Button("Rewrite Line") { }
                            Button("Suggest Rhymes") { }
                            Button("Improve Flow") { }
                        } label: {
                            ZStack {
                                // Circular progress indicator (outer ring)
                                if rapSuggestionEngine.isLoading {
                                    Circle()
                                        .trim(from: 0, to: 0.75)
                                        .stroke(
                                            style: StrokeStyle(
                                                lineWidth: 3,
                                                lineCap: .round,
                                                lineJoin: .round
                                            )
                                        )
                                        .foregroundStyle(.blue)
                                        .frame(width: 44, height: 44)
                                        .rotationEffect(.degrees(rotationAngle))
                                }
                                
                                // Sparkles icon (centered)
                                Image(systemName: "sparkles")
                                    .font(.headline)
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .disabled(rapSuggestionEngine.isLoading)
                        .onChange(of: rapSuggestionEngine.isLoading) { oldValue, newValue in
                            if newValue {
                                // Start rotating animation
                                rotationAngle = 0
                                withAnimation(
                                    Animation.linear(duration: 1.0)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    rotationAngle = 360
                                }
                            } else {
                                // Stop animation and reset
                                rotationAngle = 0
                            }
                        }

                        Button {
                            lightHaptic()
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isRhymeOverlayVisible.toggle()
                            }
                        } label: {
                            Image(systemName: isRhymeOverlayVisible ? "eye.fill" : "eye")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }

                        Button {
                            lightHaptic()
                            // Dismiss keyboard when opening popover
                            isEditorFocused = false
                            showRhymeGroupsPopover = true
                        } label: {
                            Image(systemName: "text.magnifyingglass")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }
                        .popover(isPresented: $showRhymeGroupsPopover, arrowEdge: .bottom) {
                            RhymeGroupListView(
                                groups: rhymeGroups,
                                currentText: currentText
                            )
                            .presentationCompactAdaptation(.popover)
                        }
                        .onChange(of: showRhymeGroupsPopover) { _, isPresented in
                            // Ensure keyboard is dismissed when popover opens
                            if isPresented {
                                isEditorFocused = false
                            }
                        }

                        Spacer()

                        Button {
                            lightHaptic()
                            isEditorFocused.toggle()
                        } label: {
                            Image(systemName: isEditorFocused ? "keyboard.chevron.compact.down" : "keyboard")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .frame(height: 56)
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity) // Center the toolbar
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                            .clipShape(Capsule(style: .continuous))
                    )
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, keyboardHeight > 0 ? 6 : 12)
        }
    }
}

func lightHaptic() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
}

// MARK: - PAGE 3.5: Rhyme Group List View (Polished Glass Card)

struct RhymeGroupListView: View {
    let groups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isSortReversed = false
    @State private var showSuggestions = false
    
    // Device-aware sizing
    private var popoverWidth: CGFloat {
        // Get screen width from window scene (iOS 26+) or fallback to UIScreen
        let screenWidth: CGFloat
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            screenWidth = windowScene.screen.bounds.width
        } else {
            // Fallback for older iOS versions
            screenWidth = UIScreen.main.bounds.width
        }
        // iPhone sizing: use 85% of screen width, max 400pt
        // iPad sizing: use fixed width
        if horizontalSizeClass == .compact {
            // iPhone
            return min(screenWidth * 0.85, 400)
        } else {
            // iPad
            return 520
        }
    }
    
    private var popoverMaxHeight: CGFloat {
        // Get screen height from window scene (iOS 26+) or fallback to UIScreen
        let screenHeight: CGFloat
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            screenHeight = windowScene.screen.bounds.height
        } else {
            // Fallback for older iOS versions
            screenHeight = UIScreen.main.bounds.height
        }
        // Use 60% of screen height, max 500pt
        return min(screenHeight * 0.6, 500)
    }

    // Computed property to avoid complex expression in body
    private var orderedGroups: [RhymeHighlighterEngine.RhymeGroup] {
        let baseOrdered = groups.sorted { g1, g2 in
            guard
                let r1 = g1.words.map({ $0.range.lowerBound }).min(),
                let r2 = g2.words.map({ $0.range.lowerBound }).min()
            else { return false }
            return r1 < r2
        }
        return isSortReversed ? Array(baseOrdered.reversed()) : baseOrdered
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    isSortReversed.toggle()
                } label: {
                    HStack {
                        Text("Rhyme Groups")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    showSuggestions.toggle()
                } label: {
                    Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                        .font(.headline)
                        .foregroundStyle(showSuggestions ? .blue : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 6)


            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if orderedGroups.isEmpty {
                            Text("No rhymes found.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .id("top")
                        } else {
                            ForEach(Array(orderedGroups.enumerated()), id: \.element.id) { index, group in
                                groupRowView(index: index, group: group)
                                    .id(index == 0 ? "top" : group.id.uuidString)

                                if index < orderedGroups.count - 1 {
                                    Divider().opacity(0.25)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    // Scroll to top when view appears
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: popoverWidth)
        .frame(maxHeight: popoverMaxHeight)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
    }
    
    // Helper view builder to break up complex expression
    @ViewBuilder
    private func groupRowView(index: Int, group: RhymeHighlighterEngine.RhymeGroup) -> some View {
        let groupColor = Color(RhymeColorPalette.colors[group.colorIndex])
        let uniqueWords = Array(Set(group.words.map { $0.word })).sorted()
        let suggestions = showSuggestions ? findRhymeSuggestions(for: group) : []
        
        VStack(alignment: .leading, spacing: 8) {
            // Group header
            Text("Group \(index + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(groupColor)
            
            // Current words in group
            Text(uniqueWords.joined(separator: " · "))
                .font(.callout)
                .foregroundStyle(groupColor.opacity(0.8))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Suggestions section
            if showSuggestions && !suggestions.isEmpty {
                Text(suggestions.joined(separator: " · "))
                    .font(.callout)
                    .foregroundStyle(.blue)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // Find rhyming words that aren't in the current text
    private func findRhymeSuggestions(for group: RhymeHighlighterEngine.RhymeGroup) -> [String] {
        // Get all words currently in the text (lowercased)
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = currentText
        var wordsInText: Set<String> = []
        tokenizer.enumerateTokens(in: currentText.startIndex..<currentText.endIndex) { range, _ in
            wordsInText.insert(String(currentText[range]).lowercased())
            return true
        }
        
        // Get the phonetic signature from the first word in the group
        guard let firstWord = group.words.first,
              let phonemes = FJCMUDICTStore.shared.phonemesByWord[firstWord.word.lowercased()],
              let groupSignature = RhymeHighlighterEngine.extractSignature(from: phonemes) else {
            return []
        }
        
        // Find all words in CMUDICT that rhyme with this group
        let dict = FJCMUDICTStore.shared.phonemesByWord
        var perfectRhymes: [String] = []
        var nearRhymes: [String] = []
        
        for (word, wordPhonemes) in dict {
            // Skip if word is already in the text
            if wordsInText.contains(word.lowercased()) {
                continue
            }
            
            // Skip if word is already in this group
            if group.words.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                continue
            }
            
            // Check if it rhymes with the group
            guard let wordSignature = RhymeHighlighterEngine.extractSignature(from: wordPhonemes),
                  let strength = RhymeHighlighterEngine.rhymeScore(groupSignature, wordSignature) else {
                continue
            }
            
            // Prioritize perfect rhymes, then near rhymes (skip slant)
            let capitalizedWord = word.capitalized
            switch strength {
            case .perfect:
                perfectRhymes.append(capitalizedWord)
            case .near:
                nearRhymes.append(capitalizedWord)
            case .slant:
                continue
            }
            
            // Stop if we have enough perfect rhymes (7 for better suggestions)
            if perfectRhymes.count >= 7 {
                break
            }
        }
        
        // Return perfect rhymes first, then fill with near rhymes up to 7 total
        let allSuggestions = perfectRhymes + nearRhymes
        return Array(allSuggestions.prefix(7)).sorted() // Increased from 3 to 7 suggestions
    }
}

// MARK: - Rhyme Color Palette (Engine-Level)

enum RhymeColorPalette {
    static let colors: [UIColor] = [
        UIColor(red: 0.94, green: 0.76, blue: 0.20, alpha: 1),
        UIColor(red: 0.94, green: 0.45, blue: 0.35, alpha: 1),
        UIColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1),
        UIColor(red: 0.45, green: 0.64, blue: 0.90, alpha: 1),
        UIColor(red: 0.72, green: 0.56, blue: 0.90, alpha: 1),
        UIColor(red: 0.90, green: 0.62, blue: 0.78, alpha: 1)
    ]
}

// MARK: - PAGE 5–9: Rhyme Intelligence Engine (Scored)

struct RhymeHighlighterEngine {
    enum RhymeStrength: Double {
        case perfect = 1.0
        case near = 0.75
        case slant = 0.55
    }
    
    /// Distinguishes between different types of phonetic patterns
    enum RhymeType {
        case endRhyme      // Words at the end of lines that rhyme
        case internalRhyme // Words within the same line or nearby that rhyme
        case alliteration  // Words with same starting consonant sound(s)
        case assonance     // Words with same stressed vowel sound (but different codas)
    }

    struct PhoneticSignature {
        let stressedVowel: String
        let coda: [String]
    }

    struct RhymeGroup: Identifiable {
        let id: UUID
        let key: String
        let strength: RhymeStrength
        let colorIndex: Int
        let words: [RhymeGroupWord]
        let rhymeType: RhymeType // NEW: Classifies rhyme as end or internal
    }

    struct RhymeGroupWord: Identifiable {
        let id = UUID()
        let word: String
        let range: Range<String.Index>
        let lineIndex: Int
        let positionInLine: Int
        let isLineEnd: Bool
    }

    nonisolated static func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
        guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else {
            return nil
        }
        let vowel = phonemes[idx]
        let coda = Array(phonemes.dropFirst(idx + 1))
        return PhoneticSignature(stressedVowel: vowel, coda: coda)
    }
    
    /// Extracts the base vowel sound (without stress number) for similarity comparison
    private static func baseVowelSound(_ vowel: String) -> String {
        // Remove stress numbers (0, 1, 2) from the end
        return String(vowel.dropLast())
    }
    
    /// Checks if two vowels are similar enough for slant rhyme
    /// Groups similar-sounding vowels together
    private static func areVowelsSimilar(_ vowelA: String, _ vowelB: String) -> Bool {
        let baseA = baseVowelSound(vowelA)
        let baseB = baseVowelSound(vowelB)
        
        // Exact match (already handled by perfect/near, but included for completeness)
        if baseA == baseB {
            return true
        }
        
        // Define vowel similarity groups (common slant rhyme patterns)
        let similarVowelGroups: [Set<String>] = [
            // AY (night) and EY (day) - similar long I/A sounds
            ["AY", "EY"],
            // OW (show) and AW (saw) - similar O sounds
            ["OW", "AW", "AO"],
            // IY (see) and IH (sit) - similar I sounds
            ["IY", "IH"],
            // UW (too) and UH (put) - similar U sounds
            ["UW", "UH"],
            // AE (cat) and EH (bet) - similar short E/A sounds
            ["AE", "EH"],
            // ER (her) and AH (but) - similar R/neutral sounds
            ["ER", "AH"],
            // OY (boy) and OW (show) - similar O sounds
            ["OY", "OW"],
            // AY (night) and IH (sit) - sometimes similar in context
            ["AY", "IH"]
        ]
        
        // Check if both vowels are in the same similarity group
        for group in similarVowelGroups {
            if group.contains(baseA) && group.contains(baseB) {
                return true
            }
        }
        
        return false
    }
    
    /// Checks if two codas are similar (same length and similar endings)
    private static func areCodasSimilar(_ codaA: [String], _ codaB: [String]) -> Bool {
        // If codas are identical, that's handled by perfect rhyme
        if codaA == codaB {
            return true
        }
        
        // If one coda is empty and the other isn't, they're not similar
        if codaA.isEmpty != codaB.isEmpty {
            return false
        }
        
        // If both are empty, they're similar
        if codaA.isEmpty && codaB.isEmpty {
            return true
        }
        
        // Check if they have the same length and similar final phonemes
        if codaA.count == codaB.count {
            // If they share at least half of their phonemes, consider them similar
            let matchingCount = zip(codaA, codaB).filter { $0.0 == $0.1 }.count
            return Double(matchingCount) / Double(codaA.count) >= 0.5
        }
        
        // Check if the last phoneme matches (common slant rhyme pattern)
        if let lastA = codaA.last, let lastB = codaB.last {
            if lastA == lastB {
                return true
            }
        }
        
        return false
    }

    static func rhymeScore(_ a: PhoneticSignature, _ b: PhoneticSignature) -> RhymeStrength? {
        // Perfect rhyme: same stressed vowel + same coda
        if a.stressedVowel == b.stressedVowel && a.coda == b.coda {
            return .perfect
        }
        
        // Near rhyme: same stressed vowel, different coda
        if a.stressedVowel == b.stressedVowel {
            return .near
        }
        
        // Slant rhyme: similar vowels (with or without similar codas)
        if areVowelsSimilar(a.stressedVowel, b.stressedVowel) {
            // If codas are also similar, it's a stronger slant rhyme
            if areCodasSimilar(a.coda, b.coda) {
                return .slant
            }
            // Even with different codas, similar vowels can be slant rhymes
            // (e.g., "night" [AY1-T] and "day" [EY1] - similar vowels, different codas)
            return .slant
        }
        
        return nil
    }

    nonisolated static func computeGroups(text: String) -> [RhymeGroup] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        var tokens: [(String, Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append((String(text[range]).lowercased(), range))
            return true
        }

        let dict = FJCMUDICTStore.shared.phonemesByWord
        var buckets: [String: [(RhymeGroupWord, PhoneticSignature)]] = [:]

        for (word, range) in tokens {
            guard
                let phonemes = dict[word],
                let sig = extractSignature(from: phonemes)
            else { continue }

            buckets[sig.stressedVowel, default: []]
                .append((RhymeGroupWord(word: word, range: range, lineIndex: 0, positionInLine: 0, isLineEnd: false), sig))
        }

        var result: [RhymeGroup] = []
        var processedWords: Set<UUID> = []

        // First pass: Group by exact stressed vowel (perfect and near rhymes)
        for (key, entries) in buckets where entries.count > 1 {
            let signatures = entries.map { $0.1 }
            let base = signatures[0]

            let strength: RhymeStrength = entries.allSatisfy {
                rhymeScore(base, $0.1) == .perfect
            } ? .perfect : .near

            let colorIndex = abs(key.hashValue) % RhymeColorPalette.colors.count

            let words = entries.map { $0.0 }
            result.append(
                RhymeGroup(
                    id: UUID(),
                    key: key,
                    strength: strength,
                    colorIndex: colorIndex,
                    words: words,
                    rhymeType: .endRhyme // TODO: Implement proper classification
                )
            )
            
            // Mark these words as processed
            for word in words {
                processedWords.insert(word.id)
            }
        }

        // Second pass: Find slant rhymes across different vowel groups
        let allEntries = buckets.values.flatMap { $0 }
        
        for (wordA, sigA) in allEntries {
            // Skip if already processed in a perfect/near group
            if processedWords.contains(wordA.id) { continue }
            
            var slantGroup: [(RhymeGroupWord, PhoneticSignature)] = [(wordA, sigA)]
            
            for (wordB, sigB) in allEntries {
                if wordA.id == wordB.id { continue }
                if processedWords.contains(wordB.id) { continue }
                
                // Check for slant rhyme
                if let score = rhymeScore(sigA, sigB), score == .slant {
                    slantGroup.append((wordB, sigB))
                }
            }
            
            // Only create group if we found at least one slant rhyme match
            if slantGroup.count > 1 {
                let baseVowel = baseVowelSound(sigA.stressedVowel)
                let colorIndex = abs(baseVowel.hashValue) % RhymeColorPalette.colors.count
                
                result.append(
                    RhymeGroup(
                        id: UUID(),
                        key: "\(baseVowel)_slant",
                        strength: .slant,
                        colorIndex: colorIndex,
                        words: slantGroup.map { $0.0 },
                        rhymeType: .internalRhyme // TODO: Implement proper classification
                    )
                )
                
                // Mark all words in this slant group as processed
                for (word, _) in slantGroup {
                    processedWords.insert(word.id)
                }
            }
        }

        return result
    }

    /// Incremental version that uses cached signatures to avoid re-lookup
    nonisolated static func computeGroupsIncremental(
        text: String,
        signatureCache: [String: PhoneticSignature]
    ) -> ([RhymeGroup], [Highlight]) {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        var tokens: [(String, Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append((String(text[range]).lowercased(), range))
            return true
        }

        var buckets: [String: [(RhymeGroupWord, PhoneticSignature)]] = [:]

        // Use cached signatures instead of re-looking up
        for (word, range) in tokens {
            guard let sig = signatureCache[word] else { continue }

            buckets[sig.stressedVowel, default: []]
                .append((RhymeGroupWord(word: word, range: range, lineIndex: 0, positionInLine: 0, isLineEnd: false), sig))
        }

        var result: [RhymeGroup] = []
        var processedWords: Set<UUID> = []

        // First pass: Group by exact stressed vowel (perfect and near rhymes)
        for (key, entries) in buckets where entries.count > 1 {
            let signatures = entries.map { $0.1 }
            let base = signatures[0]

            let strength: RhymeStrength = entries.allSatisfy {
                rhymeScore(base, $0.1) == .perfect
            } ? .perfect : .near

            let colorIndex = abs(key.hashValue) % RhymeColorPalette.colors.count

            let words = entries.map { $0.0 }
            result.append(
                RhymeGroup(
                    id: UUID(),
                    key: key,
                    strength: strength,
                    colorIndex: colorIndex,
                    words: words,
                    rhymeType: .endRhyme // TODO: Implement proper classification
                )
            )
            
            // Mark these words as processed
            for word in words {
                processedWords.insert(word.id)
            }
        }

        // Second pass: Find slant rhymes across different vowel groups
        let allEntries = buckets.values.flatMap { $0 }
        
        for (wordA, sigA) in allEntries {
            // Skip if already processed in a perfect/near group
            if processedWords.contains(wordA.id) { continue }
            
            var slantGroup: [(RhymeGroupWord, PhoneticSignature)] = [(wordA, sigA)]
            
            for (wordB, sigB) in allEntries {
                if wordA.id == wordB.id { continue }
                if processedWords.contains(wordB.id) { continue }
                
                // Check for slant rhyme
                if let score = rhymeScore(sigA, sigB), score == .slant {
                    slantGroup.append((wordB, sigB))
                }
            }
            
            // Only create group if we found at least one slant rhyme match
            if slantGroup.count > 1 {
                let baseVowel = baseVowelSound(sigA.stressedVowel)
                let colorIndex = abs(baseVowel.hashValue) % RhymeColorPalette.colors.count
                
                result.append(
                    RhymeGroup(
                        id: UUID(),
                        key: "\(baseVowel)_slant",
                        strength: .slant,
                        colorIndex: colorIndex,
                        words: slantGroup.map { $0.0 },
                        rhymeType: .internalRhyme // TODO: Implement proper classification
                    )
                )
                
                // Mark all words in this slant group as processed
                for (word, _) in slantGroup {
                    processedWords.insert(word.id)
                }
            }
        }

        // Convert groups to highlights
        var highlights: [Highlight] = []
        for group in result {
            for wordInfo in group.words {
                highlights.append(Highlight(
                    range: wordInfo.range,
                    colorIndex: group.colorIndex,
                    strength: group.strength,
                    rhymeType: group.rhymeType
                ))
            }
        }

        return (result, highlights)
    }

    nonisolated static func computeAll(text: String) -> ([RhymeGroup], [Highlight]) {
        let groups = computeGroups(text: text)
        var highlights: [Highlight] = []
        for group in groups {
            for wordInfo in group.words {
                highlights.append(
                    Highlight(
                        range: wordInfo.range,
                        colorIndex: group.colorIndex,
                        strength: group.strength,
                        rhymeType: group.rhymeType
                    )
                )
            }
        }
        return (groups, highlights)
    }
}

// MARK: - PAGE 11: Syllable Stress Analyzer

struct SyllableStressAnalyzer {
    func analyze(word: String) -> (syllables: Int, stresses: [Int]) {
        guard let phonemes = FJCMUDICTStore.shared.phonemesByWord[word.lowercased()] else { return (0, []) }
        var syllableIndex = 0
        var stresses: [Int] = []
        for phone in phonemes {
            if let last = phone.last, last.isNumber {
                if last == "1" { stresses.append(syllableIndex) }
                syllableIndex += 1
            }
        }
        return (syllableIndex, stresses)
    }
}

// MARK: - PAGE 12: Cadence & Flow Metrics (Engine)

struct CadenceMetrics {
    struct LineMetrics {
        let lineIndex: Int, syllableCount: Int, stressCount: Int, rhymeCount: Int
    }
    let lines: [LineMetrics]
    var averageSyllables: Double {
        guard !lines.isEmpty else { return 0 }
        return Double(lines.map(\.syllableCount).reduce(0, +)) / Double(lines.count)
    }
    var syllableVariance: Double {
        let avg = averageSyllables
        return lines.map { pow(Double($0.syllableCount) - avg, 2) }.reduce(0, +) / Double(lines.count)
    }
}

// MARK: - PAGE 12: Cadence Analyzer

struct CadenceAnalyzer {
    private let syllableAnalyzer = SyllableStressAnalyzer()
    func analyze(text: String, highlights: [Highlight]) -> CadenceMetrics {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var results: [CadenceMetrics.LineMetrics] = []
        for (index, line) in lines.enumerated() {
            let words = line.split { !$0.isLetter }
            var syllables = 0, stresses = 0, rhymeCount = 0
            for wordSub in words {
                let word = String(wordSub).lowercased()
                let analysis = syllableAnalyzer.analyze(word: word)
                syllables += analysis.syllables
                stresses += analysis.stresses.count
            }
            rhymeCount = highlights.filter { highlight in
                let rangeText = text[highlight.range]
                return line.contains(rangeText)
            }.count
            results.append(CadenceMetrics.LineMetrics(lineIndex: index, syllableCount: syllables, stressCount: stresses, rhymeCount: rhymeCount))
        }
        return CadenceMetrics(lines: results)
    }
}

// MARK: - GLASS EFFECT

struct GlassView<S: Shape>: View {
    @Environment(\.colorScheme) private var colorScheme
    let shape: S
    var applyGloss: Bool = false

    var body: some View {
        let material = shape.fill(.ultraThinMaterial)
            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))

        if applyGloss {
            material
                .overlay(
                    LinearGradient(
                        colors: [.white.opacity(0.4 * (GlassSettings.gloss - 0.6)), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                    .clipShape(shape)
                )
        } else {
            material
        }
    }
}

// MARK: - PAGE 3.3 — FINAL OVERLAY IMPLEMENTATION

struct RhymeHighlightTextView: UIViewRepresentable {
    let text: String
    let highlights: [Highlight]
    let isVisible: Bool // Track visibility to skip unnecessary updates when hidden
    var showFullText: Bool = true // If true, show all text; if false, only show highlighted portions
    var horizontalPadding: CGFloat = 20 // Padding to match TextEditor
    var isEditable: Bool = false // Whether the text view is editable
    var onTextChange: ((String) -> Void)? = nil // Callback for text changes

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.onTextChange = onTextChange
        return coordinator
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.isEditable = isEditable
        textView.isSelectable = isEditable
        textView.isScrollEnabled = false // Never scroll - parent ScrollView handles scrolling
        textView.isUserInteractionEnabled = isEditable // Only allow interaction when editable

        // Match TextEditor's internal padding exactly
        // TextEditor has .padding(.horizontal, 20), so we need to account for that
        // The textContainerInset should be 0 since we're applying padding at the SwiftUI level
        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 0, // No inset - padding is handled at SwiftUI level
            bottom: 200, // Increased bottom padding to match TextEditor and provide more writing space
            right: 0 // No inset - padding is handled at SwiftUI level
        )
        textView.textContainer.lineFragmentPadding = 0
        
        // Ensure text aligns to left edge (not centered)
        textView.textAlignment = .left
        
        // CRITICAL: Enable text wrapping to prevent horizontal overflow
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0 // Unlimited lines
        // Container size is automatically managed when widthTracksTextView is true
        
        // Ensure text wraps within bounds - prevent horizontal scrolling
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Allow vertical expansion to show all content
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)

        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label

        textView.backgroundColor = .clear
        textView.tintColor = .clear
        
        // Set delegate for text changes when editable
        if isEditable {
            textView.delegate = context.coordinator
        }

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let coordinator = context.coordinator
        let isDarkMode = uiView.traitCollection.userInterfaceStyle == .dark
        
        // Update delegate and interaction settings
        uiView.delegate = isEditable ? coordinator : nil
        uiView.isEditable = isEditable
        uiView.isSelectable = isEditable
        uiView.isUserInteractionEnabled = isEditable
        coordinator.onTextChange = onTextChange
        
        // Early exit optimization: Skip all work if view is hidden
        // This prevents unnecessary hash calculations and attributed string work
        if !isVisible {
            // If we're hiding the view and it was previously visible, clear the text
            // This is a visual optimization - don't rebuild attributed string when hidden
            if coordinator.lastVisible {
                uiView.attributedText = nil
                coordinator.lastVisible = false
            }
            return
        }
        
        // Mark as visible for next comparison
        coordinator.lastVisible = true
        
        // Optimized change detection - use hash-based comparison for efficiency
        let textHash = text.hashValue
        
        // Calculate highlights hash efficiently - only hash the essential properties
        var highlightsHasher = Hasher()
        highlightsHasher.combine(highlights.count)
        for highlight in highlights {
            // Convert range to NSRange for stable hashing (handles String.Index properly)
            let nsRange = NSRange(highlight.range, in: text)
            highlightsHasher.combine(nsRange.location)
            highlightsHasher.combine(nsRange.length)
            highlightsHasher.combine(highlight.colorIndex)
            highlightsHasher.combine(highlight.strength)
            highlightsHasher.combine(highlight.rhymeType)
        }
        let highlightsHash = highlightsHasher.finalize()
        
        let textChanged = coordinator.lastTextHash != textHash
        let highlightsChanged = coordinator.lastHighlightsHash != highlightsHash
        let darkModeChanged = coordinator.lastDarkMode != isDarkMode
        
        // Skip rebuild if nothing changed - reuse cached attributed string
        if !textChanged && !highlightsChanged && !darkModeChanged {
            // Use cached attributed string if available and text matches
            if let cachedAttributed = coordinator.cachedAttributedString,
               cachedAttributed.string == text {
                // Only update if the attributed text is actually different
                if uiView.attributedText != cachedAttributed {
                    uiView.attributedText = cachedAttributed
                }
                return
            }
            // If we don't have a cache but nothing changed, we still need to build it once
        }
        
        // Build attributed string
        // For AI text overlay, use clear color so TextEditor text shows through
        // Only AI text ranges will have blue foreground color
        // Context highlights (last 4 lines) use background color
        let isAITextOverlay = highlights.contains { $0.colorIndex == 3 && !showFullText }
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: isAITextOverlay ? UIColor.clear : UIColor.label
            ]
        )

        for highlight in highlights {
            // Validate range is valid before converting to NSRange to prevent crashes
            guard highlight.range.lowerBound >= text.startIndex,
                  highlight.range.upperBound <= text.endIndex,
                  highlight.range.lowerBound <= highlight.range.upperBound else {
                continue // Skip invalid ranges
            }
            
            let nsRange = NSRange(highlight.range, in: text)
            
            // Validate NSRange is valid (not out of bounds)
            guard nsRange.location != NSNotFound,
                  nsRange.location + nsRange.length <= (text as NSString).length else {
                continue // Skip invalid NSRange
            }

            // Special handling for colorIndex 3 (blue):
            // - If showFullText is true, it's a context highlight (background)
            // - If showFullText is false, it's AI text (foreground)
            if highlight.colorIndex == 3 {
                if showFullText {
                    // Context highlight (last 4 lines): use blue background color with 40% opacity
                    let blueColor = RhymeColorPalette.colors[3]
                    let opacity: CGFloat = 0.4 // Fixed 40% opacity as requested
                    attributed.addAttribute(
                        .backgroundColor,
                        value: blueColor.withAlphaComponent(opacity),
                        range: nsRange
                    )
                } else {
                    // AI-generated text: use blue foreground color
                    let blueColor = UIColor.systemBlue
                    attributed.addAttribute(
                        .foregroundColor,
                        value: blueColor,
                        range: nsRange
                    )
                }
            } else {
                // Regular rhyme highlighting: use background color
                let baseColor = RhymeColorPalette.colors[highlight.colorIndex]

                let opacity: CGFloat
                switch highlight.strength {
                case .perfect:
                    opacity = isDarkMode ? 0.55 : 0.30
                case .near:
                    opacity = isDarkMode ? 0.40 : 0.22
                case .slant:
                    opacity = isDarkMode ? 0.30 : 0.16
                }

                attributed.addAttribute(
                    .backgroundColor,
                    value: baseColor.withAlphaComponent(opacity),
                    range: nsRange
                )
            }
        }

        // Only update attributed text if text actually changed (prevents infinite loop when editable)
        // When editable, text changes come from user input via delegate, not from this update
        if !isEditable || uiView.text != text {
            uiView.attributedText = attributed
        } else if isEditable {
            // When editable, preserve user's cursor position and only update highlights
            // Don't replace the entire attributed string as it resets cursor
            let currentText = uiView.text
            if currentText == text {
                // Text matches, just update highlights without replacing attributed string
                // This preserves cursor position
                return
            }
        }
        
        // Force text layout to ensure all content is rendered
        uiView.layoutIfNeeded()
        
        // Use async dispatch to ensure layout happens after the current update cycle
        // This fixes scrolling issues when overlay is first shown - the ScrollView needs
        // to see the correct size immediately, but layout might not be complete yet
        DispatchQueue.main.async {
            guard let layoutManager = uiView.textContainer.layoutManager else { return }
            
            layoutManager.ensureLayout(for: uiView.textContainer)
            
            // Calculate content height and ensure text container can display all content
            let usedRect = layoutManager.usedRect(for: uiView.textContainer)
            let contentHeight = usedRect.height + uiView.textContainerInset.top + uiView.textContainerInset.bottom + 400 // Match TextEditor bottom padding
            
            // Always update size to ensure it's correct - don't check if it's already correct
            // This fixes scrolling issues where size calculation happens before layout is complete
            if contentHeight > 0 {
                let currentSize = uiView.textContainer.size
                let requiredHeight = max(contentHeight, usedRect.height + uiView.textContainerInset.top + uiView.textContainerInset.bottom + 400)
                
                // Always update size to ensure ScrollView sees the correct content height
                uiView.textContainer.size = CGSize(
                    width: currentSize.width > 0 ? currentSize.width : (uiView.bounds.width > 0 ? uiView.bounds.width : 680),
                    height: requiredHeight
                )
                
                // Force layout again after updating size
                layoutManager.ensureLayout(for: uiView.textContainer)
                
                // Invalidate intrinsic content size to ensure UITextView expands to show all content
                uiView.invalidateIntrinsicContentSize()
                
                // Force parent view hierarchy to update layout so ScrollView recognizes the new size
                uiView.superview?.setNeedsLayout()
                uiView.superview?.layoutIfNeeded()
            }
        }
        
        // Also invalidate immediately for synchronous updates
        uiView.invalidateIntrinsicContentSize()
        
        // Cache the attributed string and update coordinator cache
        coordinator.cachedAttributedString = attributed.copy() as? NSAttributedString
        coordinator.lastTextHash = textHash
        coordinator.lastHighlightsHash = highlightsHash
        coordinator.lastDarkMode = isDarkMode
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var lastTextHash: Int = 0
        var lastHighlightsHash: Int = 0
        var lastDarkMode: Bool = false
        var lastVisible: Bool = false // Track visibility state
        var cachedAttributedString: NSAttributedString? = nil
        var onTextChange: ((String) -> Void)? = nil
        
        func textViewDidChange(_ textView: UITextView) {
            onTextChange?(textView.text)
        }
    }
}

// MARK: - PAGE 11: Syllable Stress Analyzer

struct Highlight: Equatable {
    let range: Range<String.Index>
    let colorIndex: Int
    let strength: RhymeHighlighterEngine.RhymeStrength
    let rhymeType: RhymeHighlighterEngine.RhymeType
}

// MARK: - PAGE 1.1.1: Release Notes Sheet (Segment 1)

struct ReleaseNotesSheetView: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What’s New")
                        .font(.largeTitle.weight(.bold))

                    Text("The Final Journal AI")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 12)

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
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
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

// MARK: - PAGE 1.1.2: Support / Shop Sheet (Segment 1)

struct SupportShopSheetView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @State private var showThankYou: Bool = false
    @State private var lastActionTitle: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Support the Creators")
                        .font(.largeTitle.weight(.bold))

                    Text("Your support helps keep The Final Journal AI independent, thoughtful, and evolving.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 12)

                sectionHeader("Follow & Support")

                supportRow(
                    title: "X (Twitter)",
                    subtitle: "Follow updates and design progress",
                    symbol: "xmark"
                ) {
                    lastActionTitle = "X (Twitter)"
                    showThankYou = true
                    openURL(URL(string: "https://twitter.com")!)
                }

                supportRow(
                    title: "Instagram",
                    subtitle: "Visual updates and behind-the-scenes",
                    symbol: "camera"
                ) {
                    lastActionTitle = "Instagram"
                    showThankYou = true
                    openURL(URL(string: "https://instagram.com")!)
                }

                supportRow(
                    title: "Patreon",
                    subtitle: "Directly support ongoing development",
                    symbol: "heart.fill"
                ) {
                    lastActionTitle = "Patreon"
                    showThankYou = true
                    openURL(URL(string: "https://patreon.com")!)
                }

                supportRow(
                    title: "Facebook",
                    subtitle: "Community updates and announcements",
                    symbol: "person.2.fill"
                ) {
                    lastActionTitle = "Facebook"
                    showThankYou = true
                    openURL(URL(string: "https://facebook.com")!)
                }

                sectionHeader("Affiliate Support")

                Text(
                    "Some links may be affiliate links. Purchases made through these links help support development at no extra cost to you."
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                supportRow(
                    title: "Amazon",
                    subtitle: "Support via affiliate purchases",
                    symbol: "cart.fill"
                ) {
                    lastActionTitle = "Amazon"
                    showThankYou = true
                    openURL(URL(string: "https://amazon.com")!)
                }

                if showThankYou {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)

                        Text("Thank you for supporting The Final Journal AI via \(lastActionTitle).")
                            .font(.callout)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showThankYou = false
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
        .animation(.easeInOut(duration: 0.2), value: showThankYou)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .padding(.top, 12)
    }

    @ViewBuilder
    private func supportRow(
        title: String,
        subtitle: String,
        symbol: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))

                    Image(systemName: symbol)
                        .font(.system(size: 28, weight: .semibold))
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            )
        }
        .buttonStyle(.plain)
    }
}

struct JournalDetailPlaceholderView: View {
    var body: some View {
        Color.clear
    }
}

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var cancellable: AnyCancellable?
    private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }

    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }

    init() {
        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .subscribe(on: DispatchQueue.main)
            .assign(to: \.height, on: self)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - GLASS EFFECT

enum GlassSettings {
    static let darkening: Double = 0.12
    static let gloss: Double = 1.0
}

@MainActor
final class RhymeEngineState: ObservableObject {
    @Published var cachedGroups: [RhymeHighlighterEngine.RhymeGroup] = []
    @Published var cachedHighlights: [Highlight] = []
    private var lastTextHash: Int?
    private var lastText: String = ""
    
    // Word-level caching: cache phonetic signatures by word text
    private var wordSignatureCache: [String: RhymeHighlighterEngine.PhoneticSignature] = [:]
    
    // Debounce state for typing delay
    private var debounceTask: Task<Void, Never>? = nil
    private let debounceDelay: TimeInterval = 0.4 // 400ms delay after typing stops
    
    init() {
        // Set up memory warning observer to clear caches when needed
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.clearCaches()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Clear caches on memory warning (performance optimization)
    private func clearCaches() {
        // Clear word signature cache (can be rebuilt as needed)
        wordSignatureCache.removeAll(keepingCapacity: false)
        print("⚠️ RhymeEngineState: Caches cleared due to memory warning")
    }

    func updateIfNeeded(text: String) {
        let hash = text.hashValue
        
        // Skip if text hasn't actually changed (hash check is fast, prevents unnecessary debounce setup)
        guard hash != lastTextHash else { return }
        
        // Cancel any pending debounced analysis (user typed again)
        debounceTask?.cancel()
        
        // Store the text we want to analyze (capture current state for the debounced task)
        let textToAnalyze = text
        let previousText = lastText
        
        // Create new debounced task that will analyze after user stops typing
        debounceTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            // Wait for user to stop typing (debounce delay: 400ms)
            // This prevents analysis during active typing
            try? await Task.sleep(nanoseconds: UInt64(self.debounceDelay * 1_000_000_000))
            
            // Check if task was cancelled (user typed again during delay)
            guard !Task.isCancelled else { return }
            
            // Verify the text we captured still hasn't been analyzed
            // (hash might have changed if another update occurred, but that's handled by the guard above)
            let currentHash = textToAnalyze.hashValue
            guard currentHash != self.lastTextHash else { return }
            
            // Update hash before analysis to prevent duplicate calls
            self.lastTextHash = currentHash
            
            // Use incremental update if we have previous text (more efficient)
            if !previousText.isEmpty {
                self.computeIncrementalAsync(oldText: previousText, newText: textToAnalyze)
            } else {
                self.computeAsync(text: textToAnalyze)
            }
            
            self.lastText = textToAnalyze
        }
    }

    private func computeAsync(text: String) {
        Task.detached(priority: .userInitiated) {
            let (groups, highlights) = RhymeHighlighterEngine.computeAll(text: text)
            
            // Cache word signatures for future incremental updates
            let dict = FJCMUDICTStore.shared.phonemesByWord
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            var localSignatures: [String: RhymeHighlighterEngine.PhoneticSignature] = [:]
            
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
                let word = String(text[range]).lowercased()
                if let phonemes = dict[word],
                   let sig = RhymeHighlighterEngine.extractSignature(from: phonemes) {
                    localSignatures[word] = sig
                }
                return true
            }
            
            let finalSignatures = localSignatures
            await MainActor.run {
                self.cachedGroups = groups
                self.cachedHighlights = highlights
                self.wordSignatureCache = finalSignatures
            }
        }
    }
    
    private func computeIncrementalAsync(oldText: String, newText: String) {
        // Capture current cache before entering detached task
        let currentCache = wordSignatureCache
        
        Task.detached(priority: .userInitiated) {
            // Tokenize both texts to find differences (synchronous operation)
            func tokenize(_ text: String) -> [(word: String, range: Range<String.Index>)] {
                let tokenizer = NLTokenizer(unit: .word)
                tokenizer.string = text
                var tokens: [(word: String, range: Range<String.Index>)] = []
                tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
                    tokens.append((word: String(text[range]).lowercased(), range: range))
                    return true
                }
                return tokens
            }
            
            let oldTokens = tokenize(oldText)
            let newTokens = tokenize(newText)
            
            // Find new words (words in new text but not in old text)
            let oldWords = Set(oldTokens.map { $0.word })
            let newWords = newTokens.filter { !oldWords.contains($0.word) }
            
            // If significant change (>30% new words), do full recompute
            let changeRatio = Double(newWords.count) / Double(max(newTokens.count, 1))
            if changeRatio > 0.3 || Double(newTokens.count) < Double(oldTokens.count) * 0.7 {
                // Too much changed, do full recompute
                let (groups, highlights) = RhymeHighlighterEngine.computeAll(text: newText)
                let signatures = await self.buildSignatureCache(text: newText)
                await MainActor.run {
                    self.cachedGroups = groups
                    self.cachedHighlights = highlights
                    self.wordSignatureCache = signatures
                }
                return
            }
            
            // Incremental: only analyze new words, then rebuild groups
            let dict = FJCMUDICTStore.shared.phonemesByWord
            var localUpdatedCache = currentCache
            
            // Analyze only new words
            for token in newWords {
                if let phonemes = dict[token.word],
                   let sig = RhymeHighlighterEngine.extractSignature(from: phonemes) {
                    localUpdatedCache[token.word] = sig
                }
            }
            
            // Rebuild groups using cached + new signatures
            let finalCache = localUpdatedCache
            let (groups, highlights) = RhymeHighlighterEngine.computeGroupsIncremental(
                text: newText,
                signatureCache: finalCache
            )
            
            await MainActor.run {
                self.cachedGroups = groups
                self.cachedHighlights = highlights
                self.wordSignatureCache = finalCache
            }
        }
    }
    
    private func tokenizeText(_ text: String) -> [(word: String, range: Range<String.Index>)] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var tokens: [(word: String, range: Range<String.Index>)] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append((word: String(text[range]).lowercased(), range: range))
            return true
        }
        return tokens
    }
    
    private func buildSignatureCache(text: String) async -> [String: RhymeHighlighterEngine.PhoneticSignature] {
        let dict = FJCMUDICTStore.shared.phonemesByWord
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var signatures: [String: RhymeHighlighterEngine.PhoneticSignature] = [:]
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let word = String(text[range]).lowercased()
            if let phonemes = dict[word],
               let sig = RhymeHighlighterEngine.extractSignature(from: phonemes) {
                signatures[word] = sig
            }
            return true
        }
        
        return signatures
    }
}

final class FJCMUDICTStore {
    static let shared = FJCMUDICTStore()
    private(set) var phonemesByWord: [String: [String]] = [:]
    private let loadingQueue = DispatchQueue(label: "com.finaljournal.cmudict.loading", qos: .userInitiated)
    private var isLoading = false
    private var isLoaded = false
    private let loadingLock = NSLock()
    
    // Thread-safe loading state check
    private var isDictionaryLoaded: Bool {
        loadingLock.lock()
        defer { loadingLock.unlock() }
        return isLoaded
    }
    
    private init() {
        // Load fallback dictionary immediately for basic functionality
        loadFallbackDictionary()
        // Start async loading of full dictionary
        preloadAsync()
    }
    
    /// Pre-loads the full dictionary asynchronously on a background thread
    /// This is called on app launch to ensure dictionary is ready before first use
    func preloadAsync() {
        loadingLock.lock()
        let shouldLoad = !isLoaded && !isLoading
        if shouldLoad {
            isLoading = true
        }
        loadingLock.unlock()
        
        guard shouldLoad else { return }
        
        Task.detached(priority: .userInitiated) {
            await self.loadAsync()
        }
    }
    
    /// Asynchronously loads the full dictionary on a background thread
    private func loadAsync() async {
        // Load dictionary file and parse on background thread
        let dictionary: [String: [String]]? = await Task.detached(priority: .userInitiated) { () -> [String: [String]]? in
            guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt") else {
                print("⚠️ CMUDICT: Dictionary file not found")
                return nil
            }
            
            guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
                print("⚠️ CMUDICT: Failed to read dictionary file")
                return nil
            }
            
            // Parse dictionary on background thread
            var parsedDict: [String: [String]] = [:]
            for line in contents.split(separator: "\n") {
                guard !line.hasPrefix(";;;") else { continue }
                let parts = line.split(separator: " ")
                guard parts.count > 1 else { continue }
                let word = String(parts[0]).lowercased()
                let phones = parts.dropFirst().map(String.init)
                parsedDict[word] = phones
            }
            
            return parsedDict
        }.value
        
        // Update dictionary on main thread (thread-safe)
        await MainActor.run {
            if let dict = dictionary {
                self.phonemesByWord = dict
                
                self.loadingLock.lock()
                self.isLoaded = true
                self.isLoading = false
                self.loadingLock.unlock()
                
                print("✅ CMUDICT: Full dictionary loaded successfully (\(dict.count) words)")
            } else {
                self.loadingLock.lock()
                self.isLoading = false
                self.loadingLock.unlock()
                print("⚠️ CMUDICT: Failed to load full dictionary, using fallback")
            }
        }
    }
    
    /// Synchronous load method (kept for backwards compatibility, but should use preloadAsync)
    private func load() {
        guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt"),
            let contents = try? String(contentsOf: url, encoding: .utf8) else {
            loadFallbackDictionary()
            return
        }
        parseDict(contents)
    }
    
    /// Parse dictionary contents (used by both sync and async loading)
    private func parseDict(_ contents: String) {
        for line in contents.split(separator: "\n") {
            guard !line.hasPrefix(";;;") else { continue }
            let parts = line.split(separator: " ")
            guard parts.count > 1 else { continue }
            let word = String(parts[0]).lowercased()
            let phones = parts.dropFirst().map(String.init)
            phonemesByWord[word] = phones
        }
    }
    
    /// Get phonemes for a word (thread-safe access)
    /// Falls back to empty array if dictionary not yet loaded
    func getPhonemes(for word: String) -> [String]? {
        loadingLock.lock()
        defer { loadingLock.unlock() }
        return phonemesByWord[word.lowercased()]
    }
    
    private func loadFallbackDictionary() {
        // Minimal fallback dictionary with common words
        phonemesByWord = [
            "love": ["L", "AH1", "V"],
            "dove": ["D", "AH1", "V"],
            "above": ["AH0", "B", "AH1", "V"],
            "shove": ["SH", "AH1", "V"],
            "cat": ["K", "AE1", "T"],
            "hat": ["HH", "AE1", "T"],
            "bat": ["B", "AE1", "T"],
            "rat": ["R", "AE1", "T"],
            "mat": ["M", "AE1", "T"],
            "sat": ["S", "AE1", "T"],
            "day": ["D", "EY1"],
            "way": ["W", "EY1"],
            "say": ["S", "EY1"],
            "pay": ["P", "EY1"],
            "play": ["P", "L", "EY1"],
            "stay": ["S", "T", "EY1"],
            "night": ["N", "AY1", "T"],
            "light": ["L", "AY1", "T"],
            "fight": ["F", "AY1", "T"],
            "right": ["R", "AY1", "T"],
            "sight": ["S", "AY1", "T"],
            "bright": ["B", "R", "AY1", "T"],
            "time": ["T", "AY1", "M"],
            "rhyme": ["R", "AY1", "M"],
            "climb": ["K", "L", "AY1", "M"],
            "chime": ["CH", "AY1", "M"],
            "sublime": ["S", "AH0", "B", "L", "AY1", "M"]
        ]
    }
}

// MARK: - PAGE 2: Metadata Popovers (Segment 2)

// MARK: - BPM Popover
struct BPMPopoverView: View {
    @Binding var bpm: Int?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BPM")
                .font(.headline)
            
            // BPM Slider
            VStack(spacing: 8) {
                HStack {
                    Text("60")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let bpm = bpm {
                        Text("\(bpm)")
                            .font(.title3.weight(.semibold))
                    } else {
                        Text("—")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("220")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(bpm ?? 120) },
                        set: { bpm = Int($0) }
                    ),
                    in: 60...220,
                    step: 1
                )
            }
            
            // Quick Select Buttons
            HStack(spacing: 8) {
                ForEach([60, 90, 120, 140, 160, 180, 200], id: \.self) { value in
                    Button {
                        bpm = value
                    } label: {
                        Text("\(value)")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(bpm == value ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: 12) {
                // Clear Button
                Button {
                    bpm = nil
                } label: {
                    Text("Clear")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Done Button with Checkmark
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
    }
}

// MARK: - Key Popover
struct KeyPopoverView: View {
    @Binding var key: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private let musicalKeys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Musical Key")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(musicalKeys, id: \.self) { keyValue in
                    Button {
                        key = keyValue
                    } label: {
                        Text(keyValue)
                            .font(.callout.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(key == keyValue ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button {
                key = nil
            } label: {
                Text("Clear")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
    }
}

// MARK: - Scale Popover
struct ScalePopoverView: View {
    @Binding var key: String?
    @Binding var scale: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private let scales = [
        "Chromatic",
        "Major",
        "Natural Minor",
        "Harmonic Minor",
        "Melodic Minor",
        "Ionian (Major)",
        "Dorian",
        "Phrygian",
        "Lydian",
        "Mixolydian",
        "Aeolian (Natural Minor)",
        "Locrian"
    ]
    
    var body: some View {
        ScrollView {
            contentView
        }
        .padding(20)
        .frame(width: 340)
        .frame(maxHeight: 400)
        .background(backgroundView)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scale")
                .font(.headline)
            
            keyStatusView
            
            ForEach(scales, id: \.self) { scaleValue in
                scaleButton(for: scaleValue)
            }
            
            clearButton
        }
    }
    
    @ViewBuilder
    private var keyStatusView: some View {
        if key == nil {
            Text("Select Key First")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            Text("Key: \(key ?? "")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func scaleButton(for scaleValue: String) -> some View {
        Button {
            scale = scaleValue
        } label: {
            HStack {
                Text(scaleValue)
                    .font(.callout)
                Spacer()
                if scale == scaleValue {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.semibold))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(scaleButtonBackground(isSelected: scale == scaleValue))
        }
        .buttonStyle(.plain)
    }
    
    private func scaleButtonBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    }
    
    private var clearButton: some View {
        Button {
            scale = nil
        } label: {
            Text("Clear")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            .overlay(
                LinearGradient(
                    colors: [
                        .white.opacity((GlassSettings.gloss - 0.6) / 3),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.overlay)
            )
    }
}

// MARK: - URL Attachment Popover
struct URLAttachmentPopoverView: View {
    @Binding var url: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var urlText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("URL Attachment")
                .font(.headline)
            
            // Glassmorphic Text Field
            TextField("Enter URL (YouTube, etc.)", text: $urlText)
                .focused($isTextFieldFocused)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(isTextFieldFocused ? 0.2 : 0.1),
                                            .white.opacity(isTextFieldFocused ? 0.15 : 0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isTextFieldFocused ? 1 : 0.5
                                )
                        )
                )
                .onAppear {
                    urlText = url ?? ""
                }
            
            // URL Preview (if valid)
            if !urlText.isEmpty, let urlObj = URL(string: urlText), urlObj.scheme != nil {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(urlText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(0.1))
                )
            }
            
            HStack(spacing: 12) {
                // Clear Button
                Button {
                    url = nil
                    urlText = ""
                } label: {
                    Text("Clear")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Done Button with Checkmark
                Button {
                    url = urlText.isEmpty ? nil : urlText
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 340)
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

// MARK: - Folder Popover
struct FolderPopoverView: View {
    @Binding var folder: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var folderName: String = ""
    @State private var existingFolders: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Folder")
                .font(.headline)
            
            TextField("Folder Name", text: $folderName)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.words)
                .onAppear {
                    folderName = folder ?? ""
                    // TODO: Load existing folders from all items
                }
            
            // Existing Folders (if any)
            if !existingFolders.isEmpty {
                Text("Existing Folders")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(existingFolders, id: \.self) { existingFolder in
                            Button {
                                folderName = existingFolder
                            } label: {
                                Text(existingFolder)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(Color.accentColor.opacity(0.2))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    folder = folderName.isEmpty ? nil : folderName
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.accentColor.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    folder = nil
                    folderName = ""
                    dismiss()
                } label: {
                    Text("Clear")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
    }
}

// MARK: - PAGE 1.3: Import Notes Instructions Sheet
struct ImportNotesInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    let modelContext: ModelContext
    let onNoteCreated: (Item) -> Void
    
    @State private var hasOpenedNotes: Bool = false
    @State private var importedText: String = ""
    @State private var noteTitle: String = "Imported Note"
    @State private var showWelcomeBack: Bool = false
    
    var body: some View {
        Group {
            if showWelcomeBack {
                welcomeBackView
            } else {
                instructionsView
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // When app becomes active again, check clipboard
            if newPhase == .active && hasOpenedNotes {
                checkClipboardAndShowWelcomeBack()
            }
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "note.text")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            // Title
            Text("Import from Notes")
                .font(.title.weight(.bold))
            
            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                instructionStep(
                    number: "1",
                    text: "Tap the button below to open the Notes app"
                )
                
                instructionStep(
                    number: "2",
                    text: "Find and copy the note you want to import"
                )
                
                instructionStep(
                    number: "3",
                    text: "Return to this app - your copied text will be ready to import"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Open Notes Button
            Button {
                openNotesApp()
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                    Text("Open Notes App")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            
            // Cancel Button
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
    }
    
    private var welcomeBackView: some View {
        VStack(spacing: 24) {
            // Welcome Back Header
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                
                Text("Welcome Back!")
                    .font(.title.weight(.bold))
                
                Text("Your text is ready to import")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            // Text Editor
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Note")
                    .font(.headline)
                    .padding(.horizontal, 20)
                
                TextEditor(text: $importedText)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .scrollContentBackground(.hidden)
                    .textEditorStyle(.plain)
                    .frame(minHeight: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Done Button
            Button {
                createAndOpenNote()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("Done")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .disabled(importedText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .ignoresSafeArea()
        )
    }
    
    @ViewBuilder
    private func instructionStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                )
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
    
    private func openNotesApp() {
        hasOpenedNotes = true
        
        // Open Notes app using URL scheme
        if let notesURL = URL(string: "mobilenotes://") {
            UIApplication.shared.open(notesURL) { success in
                if !success {
                    // Fallback: Try to open Settings or show alert
                    // For now, just mark as opened
                }
            }
        }
    }
    
    private func checkClipboardAndShowWelcomeBack() {
        // Check clipboard for text
        if let pasteboardText = UIPasteboard.general.string, !pasteboardText.isEmpty {
            importedText = pasteboardText
            
            // Try to extract title from first line
            let lines = pasteboardText.components(separatedBy: .newlines)
            if let firstLine = lines.first, !firstLine.isEmpty, firstLine.count < 50 {
                noteTitle = firstLine.trimmingCharacters(in: .whitespaces)
            }
            
            // Show welcome back screen
            showWelcomeBack = true
        }
    }
    
    private func createAndOpenNote() {
        let trimmedText = importedText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        
        let newItem = Item(
            timestamp: Date(),
            title: noteTitle.trimmingCharacters(in: .whitespaces).isEmpty ? "Imported Note" : noteTitle,
            body: trimmedText
        )
        
        modelContext.insert(newItem)
        
        // Clear pasteboard after import
        UIPasteboard.general.string = ""
        
        // Callback to navigate to the new note
        onNoteCreated(newItem)
    }
}

// MARK: - Audio Player Component (iOS 26 Style)
struct AudioPlayerView: View {
    let audioPath: String
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Waveform and Playback Controls
            HStack(spacing: 12) {
                // Play/Pause Button
                Button {
                    if isPlaying {
                        audioPlayer.pause()
                    } else {
                        audioPlayer.play()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                }
                
                // Waveform and Time Display
                VStack(alignment: .leading, spacing: 6) {
                    // Waveform visualization (iOS 26 style - static bars for now)
                    HStack(spacing: 2) {
                        ForEach(0..<40, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(.blue.opacity(0.6))
                                .frame(width: 3, height: CGFloat(8 + (index % 3) * 4))
                        }
                    }
                    .frame(height: 24)
                    
                    // Time Display
                    HStack {
                        Text(formatTime(currentTime))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(formatTime(duration))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Progress Slider
            Slider(value: Binding(
                get: { isDragging ? dragValue : (duration > 0 ? currentTime / duration : 0) },
                set: { newValue in
                    dragValue = newValue
                    isDragging = true
                }
            ), in: 0...1) { editing in
                if !editing {
                    let newTime = dragValue * duration
                    audioPlayer.seek(to: newTime)
                    isDragging = false
                }
            }
            .tint(.blue)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
                )
        )
        .onAppear {
            audioPlayer.loadAudio(from: audioPath)
        }
        .onReceive(audioPlayer.$isPlaying) { playing in
            isPlaying = playing
        }
        .onReceive(audioPlayer.$currentTime) { time in
            if !isDragging {
                currentTime = time
            }
        }
        .onReceive(audioPlayer.$duration) { dur in
            duration = dur
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Player Manager
class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    func loadAudio(from path: String) {
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe duration
        playerItem.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                self.duration = CMTimeGetSeconds(playerItem.asset.duration)
            }
        }
        
        // Observe time updates
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
        }
        
        // Observe playback status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
            self?.currentTime = 0
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
        currentTime = time
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Audio Recorder View (iOS 26 Style)
struct AudioRecorderView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var recorder = AudioRecorderManager()
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            recorderContentView
                .padding(24)
                .background(backgroundView)
                .navigationTitle("Record Audio")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            requestMicrophonePermission()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private var recorderContentView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            recordButton
            
            timeDisplay
            
            if recorder.isRecording {
                waveformView
            }
            
            Spacer()
            
            infoText
        }
    }
    
    private var recordButton: some View {
        Button {
            if recorder.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(recorder.isRecording ? Color.red : Color.blue)
                    .frame(width: 100, height: 100)
                
                Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var timeDisplay: some View {
        if recorder.isRecording {
            Text(formatTime(recordingTime))
                .font(.title.monospacedDigit())
                .foregroundStyle(.primary)
        } else {
            Text("Tap to Record")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    private var waveformView: some View {
        HStack(spacing: 3) {
            ForEach(0..<40, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.blue.opacity(0.7))
                    .frame(width: 4, height: waveformHeight(for: index))
            }
        }
        .frame(height: 32)
        .animation(.linear(duration: 0.1).repeatForever(autoreverses: true), value: recordingTime)
    }
    
    private func waveformHeight(for index: Int) -> CGFloat {
        CGFloat(8 + (sin(Double(index) * 0.5 + recordingTime * 2) + 1) * 16)
    }
    
    private var infoText: some View {
        Text("Audio will be saved to this note")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    
    private var backgroundView: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
            .ignoresSafeArea()
    }
    
    private func startRecording() {
        requestMicrophonePermission { granted in
            if granted {
                let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(UUID().uuidString).m4a")
                recorder.startRecording(to: audioFilename.path)
                
                recordingTime = 0
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    recordingTime += 0.1
                }
            }
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        if let audioPath = recorder.stopRecording() {
            item.audioPath = audioPath
            dismiss()
        }
    }
    
    private func cleanup() {
        timer?.invalidate()
        if recorder.isRecording {
            stopRecording()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, milliseconds)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func requestMicrophonePermission(completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        }
    }
}

// MARK: - Audio Recorder Manager
class AudioRecorderManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    @Published var isRecording = false
    
    func startRecording(to path: String) {
        let url = URL(fileURLWithPath: path)
        recordingURL = url
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
            isRecording = false
        }
    }
    
    func stopRecording() -> String? {
        guard let recorder = audioRecorder, isRecording else { return nil }
        
        recorder.stop()
        isRecording = false
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        return recordingURL?.path
    }
}

// MARK: - Folder Selection Sheet
struct FolderSelectionSheetView: View {
    let selectedItems: Set<PersistentIdentifier>
    let items: [Item]
    let onAssign: (String?) -> Void
    let onCancel: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var newFolderName: String = ""
    @State private var showNewFolderField: Bool = false
    
    private var existingFolders: [String] {
        Array(Set(items.compactMap { $0.folder })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Assign to Folder")
                        .font(.headline)
                    Text("\(selectedItems.count) note\(selectedItems.count == 1 ? "" : "s") selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Folder list
                List {
                    // "None" option (remove from folder)
                    Button {
                        onAssign(nil)
                    } label: {
                        HStack {
                            Image(systemName: "folder.badge.minus")
                                .foregroundStyle(.secondary)
                            Text("None (Remove from folder)")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    
                    // Existing folders
                    ForEach(existingFolders, id: \.self) { folder in
                        Button {
                            onAssign(folder)
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(.blue)
                                Text(folder)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // New folder option
                    if showNewFolderField {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.badge.plus")
                                .foregroundStyle(.blue)
                            TextField("Folder name", text: $newFolderName)
                                .textFieldStyle(.plain)
                            Button {
                                if !newFolderName.isEmpty {
                                    onAssign(newFolderName)
                                }
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                            .disabled(newFolderName.isEmpty)
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button {
                            showNewFolderField = true
                        } label: {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                    .foregroundStyle(.blue)
                                Text("New Folder")
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}
