import SwiftUI
import SwiftData

// =======================================================
// PAGE MAP (ARCHITECTURAL)
// =======================================================
// Page 1    — Journal Library (Home / Notes List)
// Page 1.1  — Profile Entry Point (Top Right)
// Page 1.2  — Bottom Search Bar (Home)
// Page 1.3  — Import / Create Menu (Top Right)
// Page 1.4  — Filters & Folders (Home)
// Page 1.5  — Quick Compose Button (Bottom Right)
// Page 2    — Note Editor (Writing Surface)
// Page 3    — Bottom Dynamic Island Toolbar
// Page 4    — Eye Toggle (Rhyme Visibility State)
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
    var body: some View {
        JournalLibraryView()
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
        ZStack(alignment: .bottom) {
            NavigationSplitView {
                Group {
                    if items.isEmpty {
                        JournalEmptyStateView(onCreate: addItem)
                    } else {
                        // =======================================================
                        // MARK: - PAGE 1.4: Filters & Folders (UI only)
                        // =======================================================
                        if isSearchFocused {
                            page1FiltersView
                                .transition(.opacity)
                        }
                        JournalListView(items: filteredItems, onDelete: deleteItems, isOnPage1: $isOnPage1)
                    }
                }
                .background(.ultraThinMaterial)
                .navigationTitle("Journal")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {

                        Button {
                            showProfile.toggle()
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }

                        Menu {
                            Button {
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
            .popover(isPresented: $showProfile, arrowEdge: .top) {
                VStack(spacing: 12) {
                    Text("Profile")
                        .font(.headline)

                    Text("Coming soon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(width: 220)
                .background(.ultraThinMaterial)
            }
            .task {
                guard !didSeedInitialNotes else { return }
                guard items.isEmpty else {
                    didSeedInitialNotes = true
                    return
                }

                for _ in 0..<5 {
                    let note = Item(timestamp: Date())
                    modelContext.insert(note)
                }

                didSeedInitialNotes = true
            }

            // =======================================================
            // MARK: - PAGE 1.5: Quick Compose Button (Bottom Right)
            // =======================================================
            if isOnPage1 {
                Button(action: addItem) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .padding(14)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }

            // =======================================================
            // MARK: - PAGE 1.2: Bottom Search Bar (UI + logic)
            // =======================================================
            if isOnPage1 {
                page1BottomBar
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 0)
                    }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
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
                .onChange(of: isSearchFocused) { focused in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showSearchCancel = focused
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
                    .listRowSeparator(.hidden)
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
        item.body.isEmpty ? item.timestamp.formatted(date: .numeric, time: .standard) : item.body
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
// MARK: - PAGE 2: Note Editor (Correctly Bound)
// =======================================================

struct NoteEditorView: View {
    @Bindable var item: Item

    @State private var isRhymeOverlayVisible: Bool = false
    @State private var showPerfectRhymes: Bool = true
    @State private var showNearRhymes: Bool = true
    @State private var showInternalRhymes: Bool = true
    @State private var showRhymeDiagnostics: Bool = false
    @State private var showRhymePanel: Bool = false

    private let rhymeHighlighter = RhymeHighlighterEngine()
    private let cadenceAnalyzer = CadenceAnalyzer()

    private var cadenceMetrics: CadenceMetrics {
        cadenceAnalyzer.analyze(text: item.body, highlights: rhymeHighlighter.highlights(in: item.body))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Title Header Container
                VStack(spacing: 0) {
                    TextField("Title", text: $item.title)
                        .font(.title2.weight(.semibold))
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                    
                    Divider()
                }
                .background(.ultraThinMaterial)

                // Body Editor
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $item.body)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                                .frame(minHeight: 400, alignment: .top)

                            if isRhymeOverlayVisible {
                                RhymeHighlightOverlayView(
                                    text: item.body,
                                    highlights: rhymeHighlights
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if isRhymeOverlayVisible {
                RhymeLegendView(showPerfect: $showPerfectRhymes, showNear: $showNearRhymes, showInternal: $showInternalRhymes)
                    .padding(.bottom, 72)
            }
            DynamicIslandToolbarView(isRhymeOverlayVisible: $isRhymeOverlayVisible, showDiagnostics: $showRhymeDiagnostics, showRhymePanel: $showRhymePanel)
                .padding(.bottom, 12)
        }
        .popover(isPresented: $showRhymeDiagnostics, arrowEdge: .bottom) {
            let highlights = rhymeHighlighter.highlights(in: item.body)
            RhymeDiagnosticsView(perfect: highlights.filter { $0.kind == .perfect }.count, near: highlights.filter { $0.kind == .near }.count, internalCount: highlights.filter { $0.kind == .`internal` }.count)
        }
        .popover(isPresented: $showRhymePanel, arrowEdge: .bottom) {
            RhymeIntelligencePanelView(highlights: rhymeHighlighter.highlights(in: item.body))
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(.ultraThinMaterial)
    }

    private var rhymeHighlights: [RhymeHighlighterEngine.Highlight] {
        guard isRhymeOverlayVisible else { return [] }
        return rhymeHighlighter.highlights(in: item.body).filter { h in
            switch h.kind {
            case .perfect: return showPerfectRhymes
            case .near: return showNearRhymes
            case .`internal`: return showInternalRhymes
            }
        }
    }
}

// =======================================================
// MARK: - PAGE 3: Bottom Dynamic Island Toolbar (UI only)
// =======================================================
struct DynamicIslandToolbarView: View {
    @Binding var isRhymeOverlayVisible: Bool
    @Binding var showDiagnostics: Bool
    @Binding var showRhymePanel: Bool

    var body: some View {
        HStack(spacing: 14) {
            toolbarButton("•")
            toolbarButton("📎")
            toolbarButton("AI")
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isRhymeOverlayVisible.toggle()
                }
            } label: {
                Image(systemName: isRhymeOverlayVisible ? "eye.fill" : "eye")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(isRhymeOverlayVisible ? .primary : .secondary)
            }

            Button { showDiagnostics.toggle() } label: {
                Image(systemName: "ladybug")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            Button { showRhymePanel.toggle() } label: {
                Image(systemName: "text.magnifyingglass")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            Spacer()
            toolbarButton("+")
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Capsule(style: .continuous).fill(.ultraThinMaterial))
        .padding(.horizontal)
    }

    private func toolbarButton(_ label: String) -> some View {
        Text(label)
            .font(.headline)
            .frame(width: 44, height: 44)
            .contentShape(Circle())
    }
}

// =======================================================
// MARK: - PAGE 5–9: Rhyme Intelligence Engine
// =======================================================
struct RhymeHighlighterEngine {
    struct Highlight {
        enum Kind {
            case perfect, near, `internal`
        }
        let word: String
        let range: Range<String.Index>
        let kind: Kind
        let syllableCount: Int?
        let stressedSyllables: [Int]
    }
    private let analyzer = SyllableStressAnalyzer()
    func highlights(in text: String) -> [Highlight] {
        let words = text.split { !$0.isLetter }.map { String($0).lowercased() }
        let dict = CMUDICTStore.shared.phonemesByWord
        func rhymeTail(for phonemes: [String]) -> [String] {
            guard let idx = phonemes.lastIndex(where: { $0.last?.isNumber == true }) else { return [] }
            return Array(phonemes[idx...])
        }
        var tails: [String: [[String]]] = [:]
        for word in words {
            guard let phonemes = dict[word] else { continue }
            let tail = rhymeTail(for: phonemes)
            guard !tail.isEmpty else { continue }
            tails[tail.joined(separator: "-"), default: []].append([word])
        }
        var results: [Highlight] = []
        for (_, wordGroups) in tails where wordGroups.count > 1 {
            for group in wordGroups {
                for word in group {
                    if let range = text.range(of: word, options: .caseInsensitive) {
                        let isLineEnding = range.upperBound == text.endIndex || (range.upperBound < text.endIndex && text[text.index(after: range.upperBound)...].hasPrefix("\n"))
                        let baseKind: Highlight.Kind = {
                            let phonemes = dict[word] ?? []
                            let tail = rhymeTail(for: phonemes)
                            if tail == rhymeTail(for: dict[group.first ?? ""] ?? []) { return .perfect } else { return .near }
                        }()
                        let kind: Highlight.Kind = isLineEnding ? baseKind : .`internal`
                        let analysis = analyzer.analyze(word: word)
                        results.append(Highlight(word: word, range: range, kind: kind, syllableCount: analysis.syllables, stressedSyllables: analysis.stresses))
                    }
                }
            }
        }
        return results
    }
}
final class CMUDICTStore {
    static let shared = CMUDICTStore()
    private(set) var phonemesByWord: [String: [String]] = [:]
    private init() { load() }
    private func load() {
        // Try to load from bundle first
        if let url = Bundle.main.url(forResource: "cmudict", withExtension: "txt"),
           let contents = try? String(contentsOf: url) {
            parseDict(contents)
        } else {
            // Fallback to a minimal built-in dictionary for common rhyming words
            loadFallbackDictionary()
        }
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
// MARK: - PAGE 8: Rhyme Categories (Legend & Filters)
// =======================================================
struct RhymeHighlightOverlayView: View {
    let text: String
    let highlights: [RhymeHighlighterEngine.Highlight]
    var body: some View {
        Text(attributedString)
            .font(.body)
            .padding(.horizontal, 12)
            .allowsHitTesting(false)
    }
    private var attributedString: AttributedString {
        var attributed = AttributedString(text)
        for highlight in highlights {
            if let range = Range(highlight.range, in: attributed) {
                switch highlight.kind {
                case .perfect: attributed[range].backgroundColor = .yellow.opacity(0.28)
                case .near: attributed[range].backgroundColor = .orange.opacity(0.22)
                case .`internal`: attributed[range].backgroundColor = .blue.opacity(0.20)
                }
            }
        }
        return attributed
    }
}
struct RhymeLegendView: View {
    @Binding var showPerfect: Bool
    @Binding var showNear: Bool
    @Binding var showInternal: Bool
    var body: some View {
        HStack(spacing: 12) {
            legendToggle(color: .yellow.opacity(0.28), label: "Perfect", isOn: $showPerfect)
            legendToggle(color: .orange.opacity(0.22), label: "Near", isOn: $showNear)
            legendToggle(color: .blue.opacity(0.20), label: "Internal", isOn: $showInternal)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
    }
    private func legendToggle(color: Color, label: String, isOn: Binding<Bool>) -> some View {
        Button { isOn.wrappedValue.toggle() } label: {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(label).font(.caption)
            }
            .opacity(isOn.wrappedValue ? 1 : 0.5)
        }
        .buttonStyle(.plain)
    }
}
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
    func analyze(text: String, highlights: [RhymeHighlighterEngine.Highlight]) -> CadenceMetrics {
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
    let highlights: [RhymeHighlighterEngine.Highlight]
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
            guard analysis.syllables > 0, let range = Range(h.range, in: attr) else { continue }
            if !analysis.stresses.isEmpty {
                attr[range].underlineStyle = .single
                attr[range].underlineColor = UIColor.label.withAlphaComponent(0.35)
            }
        }
        return attr
    }
}
struct RhymeIntelligencePanelView: View {
    let highlights: [RhymeHighlighterEngine.Highlight]
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
    private func panelSection(_ title: String, kind: RhymeHighlighterEngine.Highlight.Kind) -> some View {
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
struct JournalDetailPlaceholderView: View {
    var body: some View { VStack { Spacer(); Text("Select a note").foregroundStyle(.secondary); Spacer() } }
}
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
