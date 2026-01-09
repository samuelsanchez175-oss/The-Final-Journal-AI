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
// Page 3    — Keyboard Bottom Dynamic Island Toolbar
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

    // MARK: - PAGE 1: Local Visibility Gate for Bottom Bar
    @State private var isOnPage1: Bool = true
    
    // MARK: - PAGE 1.3: Import from Notes
    @State private var showImportNotesInstructions: Bool = false

    var body: some View {
        NavigationSplitView {
            Group {
                if items.isEmpty {
                    JournalEmptyStateView(onCreate: addItem)
                } else {
                    VStack(spacing: 0) {
                        page1FiltersView
                        JournalListView(items: filteredItems, onDelete: deleteItems, isOnPage1: $isOnPage1)
                    }
                }
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Journal")
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
                            // TODO: Import from Voice Memos
                        } label: {
                            Label("Import from Voice Memos", systemImage: "waveform")
                        }
                    } label: {
                        Image(systemName: "plus")
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

    private var filteredItems: [Item] {
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
        
        return filtered
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
                ForEach(Page1Filter.allCases) { filter in
                    filterPill(filter)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
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
    private func getUniqueValues(for filter: Page1Filter) -> [AnyHashable] {
        switch filter {
        case .folders:
            return Array(Set(items.compactMap { $0.folder })).sorted()
        case .bpm:
            return Array(Set(items.compactMap { $0.bpm })).sorted()
        case .scale:
            return Array(Set(items.compactMap { $0.scale })).sorted()
        case .url:
            return Array(Set(items.compactMap { $0.urlAttachment })).sorted()
        }
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

    var body: some View {
        List {
            ForEach(items) { item in
                JournalRowView(item: item, isOnPage1: $isOnPage1)
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

    var body: some View {
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

    private var noteTitle: String {
        item.title.isEmpty ? "Untitled Note" : item.title
    }

    private var notePreview: String {
        item.body.isEmpty
            ? item.timestamp.formatted(
                Date.FormatStyle(date: .numeric, time: .standard)
            )
            : item.body
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

    private var rhymeGroups: [RhymeHighlighterEngine.RhymeGroup] {
        rhymeEngineState.cachedGroups
    }

    private var computedHighlights: [Highlight] {
        rhymeEngineState.cachedHighlights
    }

    // MARK: - Metadata Popover States
    @State private var showBPMPopover: Bool = false
    @State private var showKeyPopover: Bool = false
    @State private var showScalePopover: Bool = false
    @State private var showURLPopover: Bool = false
    @State private var showFolderPopover: Bool = false
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
                    .frame(maxWidth: 680)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                Divider()
                    .frame(maxWidth: 680)

                ScrollView {
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
                                .frame(maxWidth: 680, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                                .frame(minHeight: 400, alignment: .top)
                                .scrollContentBackground(.hidden)
                                .textEditorStyle(.plain)
                                .foregroundStyle(isRhymeOverlayVisible ? .clear : .primary)

                            if isRhymeOverlayVisible {
                                RhymeHighlightTextView(
                                    text: item.body,
                                    highlights: computedHighlights
                                )
                                .frame(maxWidth: 680, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                                .opacity(1)
                                .animation(.easeInOut(duration: 0.18), value: isRhymeOverlayVisible)
                                .allowsHitTesting(false)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                isEditorFocused: $isEditorFocused,
                keyboardHeight: $keyboardObserver.height
            )
            .frame(maxWidth: 680)
            .padding(.bottom, keyboardObserver.height > 0 ? 6 : 14)
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
                        // TODO: Import from Voice Memos
                    } label: {
                        Label("Import from Voice Memos", systemImage: "waveform")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            rhymeEngineState.updateIfNeeded(text: item.body)
        }
        .onChange(of: item.body) {
            rhymeEngineState.updateIfNeeded(text: item.body)
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
            .padding(.horizontal, 4)
        }
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
}

struct DynamicIslandToolbarView: View {
    @Binding var isExpanded: Bool
    @Binding var isRhymeOverlayVisible: Bool
    @Binding var showDiagnostics: Bool
    let rhymeGroups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String
    @FocusState.Binding var isEditorFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Binding var keyboardHeight: CGFloat
    @State private var showRhymeGroupsPopover: Bool = false

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
                            Button("Import from Voice Memos") { }
                        } label: {
                            Image(systemName: "paperclip")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }

                        Menu {
                            Button("Rewrite Line") { }
                            Button("Suggest Rhymes") { }
                            Button("Improve Flow") { }
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .foregroundStyle(.blue)
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

private func lightHaptic() {
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
            
            // Stop if we have enough perfect rhymes
            if perfectRhymes.count >= 3 {
                break
            }
        }
        
        // Return perfect rhymes first, then fill with near rhymes up to 3 total
        let allSuggestions = perfectRhymes + nearRhymes
        return Array(allSuggestions.prefix(3)).sorted()
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

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false

        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 20,
            bottom: 24,
            right: 20
        )
        textView.textContainer.lineFragmentPadding = 0

        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label

        textView.backgroundColor = .clear
        textView.tintColor = .clear

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let isDarkMode = uiView.traitCollection.userInterfaceStyle == .dark
        
        // Check if we can skip rebuild (change detection)
        let coordinator = context.coordinator
        let currentText = uiView.attributedText?.string ?? ""
        let highlightsChanged = coordinator.lastHighlights != highlights
        let textChanged = currentText != text
        let darkModeChanged = coordinator.lastDarkMode != isDarkMode
        
        // Skip rebuild if nothing changed
        if !textChanged && !highlightsChanged && !darkModeChanged {
            return
        }
        
        // Build attributed string
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label
            ]
        )

        for highlight in highlights {
            let nsRange = NSRange(highlight.range, in: text)

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

        uiView.attributedText = attributed
        
        // Update coordinator cache
        coordinator.lastText = text
        coordinator.lastHighlights = highlights
        coordinator.lastDarkMode = isDarkMode
    }
    
    class Coordinator {
        var lastText: String = ""
        var lastHighlights: [Highlight] = []
        var lastDarkMode: Bool = false
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

    func updateIfNeeded(text: String) {
        let hash = text.hashValue
        guard hash != lastTextHash else { return }
        lastTextHash = hash
        
        // Use incremental update if we have previous text
        if !lastText.isEmpty {
            computeIncrementalAsync(oldText: lastText, newText: text)
        } else {
            computeAsync(text: text)
        }
        
        lastText = text
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
    private init() { load() }
    private func load() {
        guard let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt"),
            let contents = try? String(contentsOf: url, encoding: .utf8) else {
            loadFallbackDictionary()
            return
        }
        parseDict(contents)
    }
    
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