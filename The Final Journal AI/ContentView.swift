import SwiftUI
import SwiftData
import UIKit
import Combine
import NaturalLanguage
import AVFoundation
import Speech

// =======================================================
// PAGE MAP (ARCHITECTURAL)
// 🔒 LOCKED — DO NOT MODIFY
// Any structural changes here require explicit review.
// =======================================================
// Page 1    — Journal Library (Home / Notes List)
// Page 1.1  — Profile Entry Point (Top Right)
// Page 1.2  — Bottom Search Bar (Home)
// Page 1.3  — Import / Create Menu (Top Right)
// Page 1.4  — Filters & Folders (Home)
// Page 1.5  — Quick Compose Button (Bottom Right)
// Page 2    — Note Editor (Writing Surface)
// Page 3    — Keyboard Bottom Dynamic Island Toolbar
// Page 3.1  — Clip / Attach Menu (Files, Notes, Voice Memos)
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

// =======================================================
// MARK: - PAGE 1: Journal Library
// =======================================================

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedImportedItem: Item?

    var body: some View {
        JournalLibraryView()
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

    // =======================================================
    // MARK: - PAGE 1.1: Profile Entry Point (Button Only)
    // =======================================================
    @State private var showProfile: Bool = false
    // =======================================================
    // MARK: - PAGE 1.2: Bottom Search Bar (UI + logic)
    // =======================================================
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showSearchCancel: Bool = false
    // =======================================================
    // MARK: - PAGE 1.4: Filters & Folders (UI only)
    // =======================================================
    @State private var selectedFilter: Page1Filter = .all
    // =======================================================
    // MARK: - PAGE 1: Local Visibility Gate for Bottom Bar
    // =======================================================
    @State private var isOnPage1: Bool = true

    // =======================================================
    // MARK: - PAGE 1.2: Live Filtering (computed property)
    // =======================================================
    private var filteredItems: [Item] {
        var base: [Item]

        // Step 1: text-based filtering
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

        // Step 2: filter pills
        switch selectedFilter {
        case .all:
            return base
        case .recent:
            return base.sorted { $0.timestamp > $1.timestamp }
        case .drafts:
            return base.filter { $0.body.isEmpty }
        case .folders:
            return base // placeholder for future folder logic
        }
    }

    var body: some View {
        ZStack {
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
                .background(.ultraThinMaterial)
                .navigationTitle("Journal")
                .toolbar {
                    // ===================================================
                    // PAGE 1.1 — Profile Entry Point (Top Right)
                    // ===================================================
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showProfile.toggle()
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }
                    }

                    // ===================================================
                    // PAGE 1.3 — Import / Create Menu (Top Right)
                    // ===================================================
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                prepareHapticForNewNote()
                                addItem()
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
            } detail: {
                JournalDetailPlaceholderView()
            }

            // =======================================================
            // PAGE 1.2 — Bottom Search Bar
            // =======================================================
            if isOnPage1 {
                VStack {
                    Spacer()
                    page1BottomBar
                }
            }

            // =======================================================
            // PAGE 1.5 — Quick Compose Button (Bottom Right)
            // =======================================================
            if isOnPage1 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: addItem) {
                            Image(systemName: "square.and.pencil")
                                .font(.title2)
                                .padding(14)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .task {
            // Demo notes we want to guarantee exist (dev only)
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

            // Existing titles in the store
            let existingTitles = Set(items.map { $0.title })

            // Insert only missing demo notes
            for note in demoNotes where !existingTitles.contains(note.title) {
                modelContext.insert(
                    Item(
                        timestamp: Date(),
                        title: note.title,
                        body: note.body
                    )
                )
            }

            // Mark seeded (kept for future launch logic)
            didSeedInitialNotes = true
        }
    }

    // NEW: Trigger haptic feedback for "New Note"
    private func prepareHapticForNewNote() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func addItem() {
        withAnimation {
            let nextIndex = items.count + 1
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

    // =======================================================
    // MARK: - PAGE 1.2: Bottom Search Bar (UI + logic)
    // =======================================================
    private var page1BottomBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search (title:, body:)", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .onChange(of: isSearchFocused) { newValue in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showSearchCancel = newValue
                    }
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Image(systemName: "mic.fill")
                .foregroundStyle(.secondary)

            if showSearchCancel {
                Button {
                    searchText = ""
                    isSearchFocused = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.callout.weight(.semibold))
                        .padding(6)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(.primary.opacity(isSearchFocused ? 0.18 : 0.08))
                )
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
        .padding(.trailing, 72)
    }

    // =======================================================
    // MARK: - PAGE 1.4: Filters & Folders (Extracted View)
    // =======================================================
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
        Button {
            selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(.callout)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        if selectedFilter != filter {
                            Capsule().fill(Color.clear)
                        }
                    }
                    .overlay(
                        Capsule()
                            .strokeBorder(.primary.opacity(selectedFilter == filter ? 0.18 : 0.08))
                    )
                )
        }
        .buttonStyle(.plain)
    }
}

enum Page1Filter: String, CaseIterable, Identifiable {
    case all = "All"
    case recent = "Recent"
    case drafts = "Drafts"
    case folders = "Folders"

    var id: String { rawValue }
}

struct JournalListView: View {
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
        .background(.ultraThinMaterial)
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
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(noteTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(notePreview)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)

                Divider()
                    .padding(.leading, 16)
            }
            .background(Color.clear)
            .contentShape(Rectangle())
        }
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
        .background(.ultraThinMaterial)
    }
}

// =======================================================
// MARK: - Downstream Highlight Model
// =======================================================
struct Highlight: Equatable {
    enum Kind: Equatable {
        case perfect, near, `internal`
    }
    let word: String
    let range: Range<String.Index>
    let kind: Kind
}

// =======================================================
// MARK: - Shared Glass Popover Container (Page 3.4 & 3.5)
// =======================================================
struct GlassPopoverContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 6)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

// =======================================================
// MARK: - PAGE 2: Note Editor (Correctly Bound)
// =======================================================

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item

    @State private var isRhymeOverlayVisible: Bool = false
    // STEP 2 — UIKit Overlay Test Flag (TEMPORARY)
    @State private var testUIKitRhymeOverlay: Bool = false
    @State private var showRhymeDiagnostics: Bool = false
    @State private var showRhymePanel: Bool = false
    @FocusState private var isEditorFocused: Bool

    // STEP 1 — Track scroll offset
    @State private var scrollOffset: CGFloat = 0

    // PART 1 STEP 1 — Add inline diagnostics state
    @State private var activeDiagnostics: DiagnosticsMode? = nil
    enum DiagnosticsMode {
        case rhyme, cadence, stress
    }

    // =======================================================
    // Voice Memo Playback State
    // =======================================================
    @State private var isPlayingAudio: Bool = false
    @State private var audioPlayer: AVAudioPlayer?

    // =======================================================
    // Voice Memo Transcription State
    // =======================================================
    @State private var isTranscribing: Bool = false
    @State private var transcriptionError: String?

    private let rhymeHighlighter = RhymeHighlighterEngine()
    private let cadenceAnalyzer = CadenceAnalyzer()

    // New property to generate highlights from groups
    private var computedHighlights: [Highlight] {
        let text = item.body
        let groups = rhymeHighlighter.groups(in: text)
        var highlights: [Highlight] = []

        let dict = CMUDICTStore.shared.phonemesByWord
        func rhymeTail(for phonemes: [String]) -> [String] {
            guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else { return [] }
            return Array(phonemes[idx...])
        }

        for group in groups {
            let groupPhonemes = dict[group.words.first?.word ?? ""] ?? []
            let groupTail = rhymeTail(for: groupPhonemes)

            for wordInfo in group.words {
                let range = wordInfo.range
                let isLineEnding = (range.upperBound == text.endIndex) || (range.upperBound < text.endIndex && text[range.upperBound...].first?.isNewline ?? false)

                let wordPhonemes = dict[wordInfo.word] ?? []
                let wordTail = rhymeTail(for: wordPhonemes)

                let baseKind: Highlight.Kind = (wordTail == groupTail) ? .perfect : .near
                let finalKind: Highlight.Kind = isLineEnding ? baseKind : .internal

                highlights.append(
                    Highlight(
                        word: wordInfo.word,
                        range: range,
                        kind: finalKind
                    )
                )
            }
        }
        return highlights
    }

    private var cadenceMetrics: CadenceMetrics {
        cadenceAnalyzer.analyze(text: item.body, highlights: computedHighlights)
    }

    // =======================================================
    // Voice Memo Transcription Generation Helper
    // =======================================================
    private func generateTranscription() {
        guard let audioPath = item.audioPath else { return }

        isTranscribing = true
        transcriptionError = nil

        let recognizer = SFSpeechRecognizer()
        let url = URL(fileURLWithPath: audioPath)

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        recognizer?.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                isTranscribing = false

                if let error = error {
                    transcriptionError = error.localizedDescription
                    return
                }

                if let result = result, result.isFinal {
                    item.audioPath = item.audioPath // ensure mutation observed
                    item.transcription = result.bestTranscription.formattedString
                }
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Title Header Container
                VStack(spacing: 0) {
                    TextField("Title", text: $item.title)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 680)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        // STEP 4 — Animate the title based on scroll
                        .scaleEffect(scrollOffset < -20 ? 0.94 : 1.0)
                        .opacity(scrollOffset < -20 ? 0.6 : 1.0)
                        .animation(.easeOut(duration: 0.2), value: scrollOffset)

                    Divider()
                        .frame(maxWidth: 680)
                }

                ScrollView {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetKey.self,
                                        value: geo.frame(in: .named("editorScroll")).minY)
                    }
                    .frame(height: 0)
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            // --- BEGIN: PAGE 2 Editor Layout RESTORED ---
                            TextEditor(text: $item.body)
                                .focused($isEditorFocused)
                                .font(.body)
                                .frame(maxWidth: 680, alignment: .leading)
                                .padding(.leading, 25)   // +5pt alignment correction
                                .padding(.trailing, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                                .frame(minHeight: 400, alignment: .top)
                                // Remove the white TextEditor canvas (UIKit scroll background)
                                .scrollContentBackground(.hidden)
                                .textEditorStyle(.plain)
                                // PAGE 3.3 — Eye Toggle
                                // When overlay is ON, TextEditor must not render visible glyphs
                                .foregroundStyle(isRhymeOverlayVisible ? .clear : .primary)
                            // --- END: PAGE 2 Editor Layout RESTORED ---

                            // 🔒 PAGE 3.3 LOCK — UIKit Overlay
                            // The Eye button now renders a UITextView-based overlay
                            // to guarantee pixel-perfect alignment with the editor.
                            // SwiftUI overlay and offset hacks are intentionally removed.
                            if isRhymeOverlayVisible {
                                RhymeHighlightTextView(
                                    text: item.body,
                                    highlights: rhymeHighlights
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
                // STEP 3 — Name the coordinate space and listen for changes
                .coordinateSpace(name: "editorScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
            }

            // PART 1 STEP 4 — Render diagnostics inline near toolbar
            if let diagnostics = activeDiagnostics {
                GlassPopoverContainer {
                    VStack(spacing: 12) {
                        if diagnostics == .rhyme {
                            let highlights = computedHighlights
                            RhymeDiagnosticsView(
                                perfect: highlights.filter { $0.kind == .perfect }.count,
                                near: highlights.filter { $0.kind == .near }.count,
                                internalCount: highlights.filter { $0.kind == .`internal` }.count
                            )
                        }
                        if diagnostics == .cadence {
                            CadenceMetricsView(metrics: cadenceMetrics)
                        }
                        if diagnostics == .stress {
                            StressAnalysisInlineView(text: item.body)
                        }
                    }
                }
                .frame(maxWidth: 320)
                .padding(.top, 32)
            }

            // =======================================================
            // PAGE 3.5 — Magnifying Glass: Rhyme Group List Panel
            // (smaller, lighter, tap-away dismiss, deduped words)
            // FINAL: opens anchored above toolbar button (matches Page 3.4, 3.2)
            // =======================================================
            if showRhymePanel {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.15)) {
                                showRhymePanel = false
                            }
                        }

                    VStack {
                        Spacer()
                        GlassPopoverContainer {
                            RhymeGroupListView(
                                groups: rhymeHighlighter.groups(in: item.body)
                            )
                        }
                        .frame(width: 280)
                        .padding(.bottom, 88) // aligns above Page 3 toolbar
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Pass activeDiagnostics and set closures to toolbar for bug menu
            DynamicIslandToolbarView(
                isRhymeOverlayVisible: $isRhymeOverlayVisible,
                showDiagnostics: $showRhymeDiagnostics,
                showRhymePanel: $showRhymePanel,
                isEditorFocused: $isEditorFocused,
                activeDiagnostics: $activeDiagnostics,
                testUIKitRhymeOverlay: $testUIKitRhymeOverlay
            )
        }
        // ===================================================
        // PAGE 1.3 — Import / Create Menu (Editor)
        // ===================================================
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
        // PART 1 STEP 3 — Remove popover-based diagnostics
        // (popover for showRhymeDiagnostics removed)
        // .popover for showRhymePanel removed; replaced with inline floating panel below.
        .navigationBarTitleDisplayMode(.inline)
    }

    // PAGE 3.3 — Eye Toggle
    // NOTE: Visual grouping ONLY.
    // No rhyme classification logic allowed here.
    // Diagnostics own Perfect/Near/Internal semantics.
    private var rhymeHighlights: [Highlight] {
        guard isRhymeOverlayVisible else { return [] }

        let groups = rhymeHighlighter.groups(in: item.body)
        var output: [Highlight] = []

        let colors: [Highlight.Kind] = [.perfect, .near, .internal]
        var colorIndex = 0

        for group in groups {
            let kind = colors[colorIndex % colors.count]
            colorIndex += 1

            for word in group.words {
                output.append(
                    Highlight(
                        word: word.word,
                        range: word.range,
                        kind: kind
                    )
                )
            }
        }
        return output
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

        // Exit current editor so NavigationSplitView selects the new item
        dismiss()
    }
}

struct VoiceMemoPlaybackView: View {
    let audioPath: String
    @Binding var isPlaying: Bool
    @Binding var audioPlayer: AVAudioPlayer?

    var body: some View {
        HStack(spacing: 12) {
            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Voice Memo")
                    .font(.callout.weight(.semibold))
                Text(fileName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "waveform")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var fileName: String {
        URL(fileURLWithPath: audioPath).lastPathComponent
    }

    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
        } else {
            do {
                let url = URL(fileURLWithPath: audioPath)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
            } catch {
                isPlaying = false
            }
        }
    }
}

struct VoiceMemoTranscriptionView: View {
    let text: String
    var onInsert: (() -> Void)? = nil

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Transcription")
                    .font(.callout.weight(.semibold))
                Spacer()

                if let onInsert {
                    Button("Insert") {
                        onInsert()
                    }
                    .font(.caption.weight(.semibold))
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(text)
                .font(.callout)
                .foregroundStyle(.primary)
                .lineLimit(isExpanded ? nil : 3)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// =======================================================
// MARK: - PAGE 3: Bottom Dynamic Island Toolbar (UI only)
// =======================================================
struct DynamicIslandToolbarView: View {
    @Binding var isRhymeOverlayVisible: Bool
    @Binding var showDiagnostics: Bool
    @Binding var showRhymePanel: Bool
    @FocusState.Binding var isEditorFocused: Bool
    @Binding var activeDiagnostics: NoteEditorView.DiagnosticsMode?

    // STEP 2 — UIKit Overlay Test Flag (TEMPORARY)
    @Binding var testUIKitRhymeOverlay: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Leading: keyboard dismiss
            Button {
                lightHaptic()
                isEditorFocused = false
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            // Paperclip — Menu
            Menu {
                Button("Attach File") { }
                Button("Import from Notes") { }
                Button("Import from Voice Memos") { }
            } label: {
                Image(systemName: "paperclip")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            // AI (blue) — Menu
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

            // Eye
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

            // Bug — Menu (Diagnostics)
            Menu {
                Button("Rhyme Diagnostics") {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        if activeDiagnostics == .rhyme {
                            activeDiagnostics = nil
                        } else {
                            activeDiagnostics = .rhyme
                        }
                    }
                }
                Button("Cadence Metrics") {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        if activeDiagnostics == .cadence {
                            activeDiagnostics = nil
                        } else {
                            activeDiagnostics = .cadence
                        }
                    }
                }
                Button("Stress Analysis") {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        if activeDiagnostics == .stress {
                            activeDiagnostics = nil
                        } else {
                            activeDiagnostics = .stress
                        }
                    }
                }
                Divider()

                // UIKit Overlay Test Flag (TEMPORARY) — visually present as a flag icon button
                Button {
                    testUIKitRhymeOverlay.toggle()
                } label: {
                    Label {
                        Text("UIKit Overlay Test Flag")
                    } icon: {
                        Image(systemName: testUIKitRhymeOverlay ? "flag.fill" : "flag")
                            .foregroundStyle(testUIKitRhymeOverlay ? .orange : .secondary)
                    }
                }
            } label: {
                Image(systemName: "ladybug")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            // Magnifier (manual glass popover trigger, no .popover)
            Button {
                lightHaptic()
                withAnimation(.easeInOut(duration: 0.15)) {
                    showRhymePanel.toggle()
                }
            } label: {
                Image(systemName: "text.magnifyingglass")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Trailing: keyboard toggle button
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
        .background(Capsule(style: .continuous).fill(.ultraThinMaterial))
        .padding(.horizontal, 16)
    }
}

private func lightHaptic() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
}

// =======================================================
// MARK: - PAGE 3.5: Rhyme Group List View (Polished Glass Card)
// =======================================================
struct RhymeGroupListView: View {
    let groups: [RhymeHighlighterEngine.RhymeGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Rhyme Groups")
                .font(.headline)
                .padding(.bottom, 6)
                .padding(.horizontal, 2)

            if groups.isEmpty {
                Text("No rhyme groups detected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                            if index > 0 {
                                Divider()
                                    .opacity(0.35)
                                    .padding(.vertical, 4)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Group \(index + 1)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 1)

                                let uniqueWords = Array(Set(group.words.map { $0.word })).sorted()
                                Text(uniqueWords.joined(separator: " · "))
                                    .font(.callout)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.bottom, 2)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 2)
                        }
                    }
                }
                .frame(maxHeight: 220) // caps height to ~6 groups
            }
        }
        .padding(13)
    }
}

// =======================================================
// MARK: - PAGE 5–9: Rhyme Intelligence Engine
// =======================================================
struct RhymeHighlighterEngine {
    // MARK: - Rhyme Group Models (Group-based output)
    struct RhymeGroup: Identifiable {
        let id: UUID
        let rhymeTailKey: String
        let words: [RhymeGroupWord]
    }

    struct RhymeGroupWord: Identifiable {
        let id = UUID()
        let word: String
        let range: Range<String.Index>
    }

    /// Returns rhyme groups found in the text, grouped by rhyme tail.
    func groups(in text: String) -> [RhymeGroup] {
        var wordRanges: [(String, Range<String.Index>)] = []
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            wordRanges.append((String(text[range]).lowercased(), range))
            return true
        }

        let dict = CMUDICTStore.shared.phonemesByWord
        func rhymeTailKey(for phonemes: [String]) -> String? {
            guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else { return nil }
            return phonemes[idx...].joined(separator: "-")
        }

        var groupsByTail: [String: [RhymeGroupWord]] = [:]

        for (word, range) in wordRanges {
            guard let phonemes = dict[word],
                  let tailKey = rhymeTailKey(for: phonemes)
            else { continue }

            groupsByTail[tailKey, default: []].append(
                RhymeGroupWord(word: word, range: range)
            )
        }

        return groupsByTail
            .filter { $0.value.count > 1 }
            .map { tailKey, words in
                RhymeGroup(
                    id: UUID(),
                    rhymeTailKey: tailKey,
                    words: words
                )
            }
    }
}

final class CMUDICTStore {
    static let shared = CMUDICTStore()
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

// =======================================================
// 🔒 PAGE 3.3 — FINAL OVERLAY IMPLEMENTATION
// UIKit UITextView-based overlay.
// Legacy SwiftUI overlay removed intentionally.
// Do not reintroduce SwiftUI Text overlays here.
// =======================================================
struct RhymeHighlightTextView: UIViewRepresentable {
    let text: String
    let highlights: [Highlight]

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        // Interaction (paint-only)
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false

        // Geometry — must mirror Page 2
        textView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 20,
            bottom: 24,
            right: 20
        )
        textView.textContainer.lineFragmentPadding = 0

        // Typography — match system TextEditor
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label

        // Appearance
        textView.backgroundColor = .clear
        textView.tintColor = .clear

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label
            ]
        )

        let isDarkMode = uiView.traitCollection.userInterfaceStyle == .dark

        for highlight in highlights {
            let nsRange = NSRange(highlight.range, in: text)

            let color: UIColor
            switch highlight.kind {
            case .perfect:
                color = isDarkMode
                    ? UIColor.systemYellow.withAlphaComponent(0.55)
                    : UIColor.systemYellow.withAlphaComponent(0.28)

            case .near:
                color = isDarkMode
                    ? UIColor.systemOrange.withAlphaComponent(0.45)
                    : UIColor.systemOrange.withAlphaComponent(0.22)

            case .internal:
                color = isDarkMode
                    ? UIColor.systemBlue.withAlphaComponent(0.40)
                    : UIColor.systemBlue.withAlphaComponent(0.20)
            }

            attributed.addAttribute(
                .backgroundColor,
                value: color,
                range: nsRange
            )
        }

        uiView.attributedText = attributed
    }
}

// 🔒 PAGE 3.3 LOCK — Dark Mode & Typography
// UITextView overlay must always use system font + UIColor.label.
// Highlight contrast is mode-aware. Do not override colors elsewhere.
// =======================================================
// MARK: - PAGE 11: Syllable Stress Analyzer
// =======================================================
struct SyllableStressAnalyzer {
    func analyze(word: String) -> (syllables: Int, stresses: [Int]) {
        guard let phonemes = CMUDICTStore.shared.phonemesByWord[word.lowercased()] else { return (0, []) }
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

// =======================================================
// MARK: - PAGE 12: Cadence & Flow Metrics (Engine)
// =======================================================
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

// =======================================================
// MARK: - PAGE 12: Cadence Analyzer
// =======================================================
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
            rhymeCount = highlights.filter { line.contains($0.word) }.count
            results.append(CadenceMetrics.LineMetrics(lineIndex: index, syllableCount: syllables, stressCount: stresses, rhymeCount: rhymeCount))
        }
        return CadenceMetrics(lines: results)
    }
}

// =======================================================
// MARK: - PAGE 11: Syllable Stress Overlay View
// =======================================================
struct SyllableStressOverlayView: View {
    let text: String
    let highlights: [Highlight]
    private let analyzer = SyllableStressAnalyzer()
    var body: some View {
        Text(attributed)
            .font(.body)
            .padding(.horizontal, 12)
            .allowsHitTesting(false)
    }
    private var attributed: AttributedString {
        var attr = AttributedString(text)
        for h in highlights {
            let analysis = analyzer.analyze(word: h.word)
            guard
                analysis.syllables > 0,
                let lower = AttributedString.Index(h.range.lowerBound, within: attr),
                let upper = AttributedString.Index(h.range.upperBound, within: attr)
            else { continue }
            let range = lower..<upper
            if !analysis.stresses.isEmpty {
                attr[range].underlineStyle = .single
                attr[range].underlineColor = UIColor.label.withAlphaComponent(0.35)
            }
        }
        return attr
    }
}
struct RhymeIntelligencePanelView: View {
    let highlights: [Highlight]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                panelSection("Perfect Rhymes", kind: .perfect)
                panelSection("Near Rhymes", kind: .near)
                panelSection("Internal Rhymes", kind: .`internal`)
            }
            .padding()
        }
        .frame(width: 320)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    private func panelSection(_ title: String, kind: Highlight.Kind) -> some View {
        let words = highlights.filter { $0.kind == kind }.map { $0.word }.sorted()
        return VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if words.isEmpty {
                Text("None detected").font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(words, id: \.self) { word in Text(word).font(.callout) }
            }
        }
    }
}
// =======================================================
// MARK: - PAGE 9: Rhyme Diagnostics View
// =======================================================
struct RhymeDiagnosticsView: View {
    let perfect: Int, near: Int, internalCount: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rhyme Diagnostics").font(.headline)
            diagnosticsRow("Perfect", count: perfect)
            diagnosticsRow("Near", count: near)
            diagnosticsRow("Internal", count: internalCount)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 240)
    }
    private func diagnosticsRow(_ label: String, count: Int) -> some View {
        HStack { Text(label); Spacer(); Text("\(count)").fontWeight(.semibold) }.font(.caption)
    }
}

struct CadenceMetricsView: View {
    let metrics: CadenceMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cadence Metrics").font(.headline)
            diagnosticsRow("Avg Syllables / Line", value: String(format: "%.2f", metrics.averageSyllables))
            diagnosticsRow("Syllable Variance", value: String(format: "%.2f", metrics.syllableVariance))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 240)
    }

    private func diagnosticsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .font(.caption)
    }
}

struct StressAnalysisInlineView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stress Analysis").font(.headline)
            Text("Coming soon...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 240)
    }
}

struct JournalDetailPlaceholderView: View {
    var body: some View { VStack { Spacer(); Text("Select a note").foregroundStyle(.secondary); Spacer() } }
}

// =======================================================
// MARK: - Shared: Keyboard Observer (for Toolbar Docking)
// =======================================================
final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var observers: [NSObjectProtocol] = []

    init() {
        let center = NotificationCenter.default

        observers.append(
            center.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard
                    let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else { return }
                self?.height = frame.height
            }
        )

        observers.append(
            center.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.height = 0
            }
        )
    }

    deinit {
        let center = NotificationCenter.default
        observers.forEach { center.removeObserver($0) }
        observers.removeAll()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}