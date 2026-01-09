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
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - PAGE 1.1 Profile Entry Point (Button Only)
    @State private var showProfile: Bool = false
    @State private var showReleaseNotes: Bool = false
    @State private var showSupportShop: Bool = false

    // MARK: - PAGE 1.2: Bottom Search Bar (UI + logic)
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showSearchCancel: Bool = false

    // MARK: - PAGE 1.4: Filters & Folders (UI only)
    @State private var selectedFilter: Page1Filter = .all

    // MARK: - PAGE 1: Local Visibility Gate for Bottom Bar
    @State private var isOnPage1: Bool = true

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

            if isOnPage1 {
                VStack {
                    Spacer()
                    page1BottomBar
                }
            }

            if isOnPage1 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: addItem) {
                            Image(systemName: "square.and.pencil")
                                .font(.title2)
                                .padding(14)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                                        .clipShape(Circle())
                                )
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
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

        switch selectedFilter {
        case .all:
            return base
        case .recent:
            return base.sorted { $0.timestamp > $1.timestamp }
        case .drafts:
            return base.filter { $0.body.isEmpty }
        case .folders:
            return base
        }
    }

    private var page1BottomBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search (title:, body:)", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(.plain)
                .submitLabel(.search)
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
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                                .clipShape(Circle())
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(.primary.opacity(isSearchFocused ? 0.18 : 0.08))
                )
                .clipShape(Capsule(style: .continuous))
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
        .padding(.trailing, 72)
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
        Button {
            selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(.callout)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
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
}

enum Page1Filter: String, CaseIterable, Identifiable {
    case all = "All"
    case recent = "Recent"
    case drafts = "Drafts"
    case folders = "Folders"

    var id: String { rawValue }
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
        .onChange(of: selectedItem) { newItem in
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
    @FocusState.Binding var isEditorFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Binding var keyboardHeight: CGFloat

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

                        Menu {
                            RhymeGroupListView(
                                groups: rhymeGroups
                            )
                        } label: {
                            Image(systemName: "text.magnifyingglass")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                        }
                        .menuStyle(.borderlessButton)

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
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSortReversed = false

    var body: some View {
        let baseOrderedGroups = groups.sorted { g1, g2 in
            guard
                let r1 = g1.words.map({ $0.range.lowerBound }).min(),
                let r2 = g2.words.map({ $0.range.lowerBound }).min()
            else { return false }
            return r1 < r2
        }
        
        let orderedGroups = isSortReversed ? Array(baseOrderedGroups.reversed()) : baseOrderedGroups

        VStack(alignment: .leading, spacing: 10) {
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
                                let groupColor = Color(RhymeColorPalette.colors[group.colorIndex])
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Group \(index + 1)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(groupColor)
                                    
                                    let uniqueWords = Array(Set(group.words.map { $0.word })).sorted()
                                    Text(uniqueWords.joined(separator: " · "))
                                        .font(.callout)
                                        .foregroundStyle(groupColor.opacity(0.8))
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
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
        .frame(minWidth: 480, idealWidth: 520)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
        )
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
    }

    struct RhymeGroupWord: Identifiable {
        let id = UUID()
        let word: String
        let range: Range<String.Index>
    }

    static func extractSignature(from phonemes: [String]) -> PhoneticSignature? {
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

    static func computeGroups(text: String) -> [RhymeGroup] {
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
                .append((RhymeGroupWord(word: word, range: range), sig))
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
                    words: words
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
                        words: slantGroup.map { $0.0 }
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

    static func computeAll(text: String) -> ([RhymeGroup], [Highlight]) {
        let groups = computeGroups(text: text)
        var highlights: [Highlight] = []
        for group in groups {
            for wordInfo in group.words {
                highlights.append(
                    Highlight(
                        range: wordInfo.range,
                        colorIndex: group.colorIndex,
                        strength: group.strength
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
    }
}

// MARK: - PAGE 11: Syllable Stress Analyzer

struct Highlight: Equatable {
    let range: Range<String.Index>
    let colorIndex: Int
    let strength: RhymeHighlighterEngine.RhymeStrength
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
                    symbolName: "sparkles.rectangle.stack",
                    version: "1.1.0",
                    title: "Writing Intelligence Update",
                    description: "Smarter rhyme awareness and clearer creative feedback.",
                    bullets: [
                        "Group‑based rhyme coloring",
                        "Magnifying‑glass rhyme map",
                        "Keyboard‑aware adaptive glass bars",
                        "Improved dark‑mode contrast"
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

    func updateIfNeeded(text: String) {
        let hash = text.hashValue
        guard hash != lastTextHash else { return }
        lastTextHash = hash
        computeAsync(text: text)
    }

    private func computeAsync(text: String) {
        Task.detached(priority: .userInitiated) {
            let (groups, highlights) = RhymeHighlighterEngine.computeAll(text: text)
            await MainActor.run {
                self.cachedGroups = groups
                self.cachedHighlights = highlights
            }
        }
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