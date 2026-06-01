//
// ContentView.CCV.11.swift
//
// This file contains JournalListView, JournalRowView, and JournalEmptyStateView.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings)
// - ContentView.CCV.13.swift (for NoteEditorView)
//
import SwiftUI
import SwiftData
import Combine
import UIKit

// Body preview now uses a native SwiftUI Text with .lineLimit(3). The old
// UILabel-backed NotePreviewLabel + GeometryReader width hack were removed to
// fix uneven row heights and title/preview misalignment (native Text wraps to
// the real available width and aligns with the title).

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
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowSeparator(.hidden, edges: .all)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(.plain)
        .contentMargins(.horizontal, 0, for: .scrollContent)
        .scrollContentBackground(.hidden)
        // Opaque surface so the note list reads as its own section, distinct from
        // the coral header above it (the coral wash washing through it didn't read well).
        .background(
            Rectangle()
                .fill(Momentum.surfaceElevated)
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
    @State private var cachedDate: String?
    @State private var lastItemId: PersistentIdentifier?
    
    // Static date formatter for better performance
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
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
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                            .font(.title3)
                            .foregroundStyle(isSelected ? Momentum.accent : Momentum.contentSecondary)
                            .padding(.top, 1)
                        rowContent
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
                    rowContent
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            // Update cache when view appears if item changed
            updateCacheIfNeeded()
        }
        .onChange(of: item.id) { _, _ in
            // Update cache when item ID changes
            updateCacheIfNeeded()
        }
        .onChange(of: item.title) { _, _ in
            // Update cache when title changes
            updateCacheIfNeeded()
        }
        .onChange(of: item.body) { _, _ in
            // Update cache when body changes (affects preview)
            updateCacheIfNeeded()
        }
        .onChange(of: item.modifiedDate) { _, _ in
            // Update cache when the last-modified date changes
            updateCacheIfNeeded()
        }
    }
    
    /// Shared row content — identical structure for every note so all rows share
    /// the same design language and the same height: title, a fixed 2-line
    /// preview area (reserves space even when the body is empty), and the
    /// last-modified date/time. One hairline divider closes the card.
    private var rowContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(noteTitle)
                .font(.momentumCardTitle)
                .foregroundStyle(Momentum.contentPrimary)
                .lineLimit(1)

            // reservesSpace keeps empty-body notes the same height as full ones.
            Text(notePreview.isEmpty ? " " : notePreview)
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 5) {
                Image(systemName: "clock")
                    .font(.system(size: 11, weight: .semibold))
                Text(lastModifiedText)
                    .font(.momentumMetadata)
            }
            .foregroundStyle(Momentum.contentSecondary)

            Divider()
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Update cached values if item has changed
    private func updateCacheIfNeeded() {
        let newTitle = item.title.isEmpty ? "Untitled Note" : item.title
        let newPreview = item.body
        let newDate = Self.dateFormatter.string(from: item.modifiedDate ?? item.timestamp)

        guard lastItemId != item.id
                || cachedTitle != newTitle
                || cachedPreview != newPreview
                || cachedDate != newDate else { return }

        cachedTitle = newTitle
        cachedPreview = newPreview
        cachedDate = newDate
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
        return item.body
    }

    /// Last-modified (falls back to created) date/time, formatted short.
    private var lastModifiedText: String {
        if let cached = cachedDate, lastItemId == item.id {
            return cached
        }
        return Self.dateFormatter.string(from: item.modifiedDate ?? item.timestamp)
    }
}

struct JournalEmptyStateView: View {
    let onCreate: () -> Void

    var body: some View {
        ZStack {
            AtmosphereGlow()
            VStack(spacing: 22) {
                // HeroGraphic — thin-border concentric line-art circles (Momentum signature)
                ZStack {
                    Circle().stroke(Momentum.contentPrimary.opacity(0.15), lineWidth: Momentum.lineThin)
                        .frame(width: 136, height: 136)
                    Circle().stroke(Momentum.contentPrimary.opacity(0.3), lineWidth: Momentum.lineThin)
                        .frame(width: 94, height: 94)
                    Circle().stroke(Momentum.accent, lineWidth: Momentum.lineThick)
                        .frame(width: 54, height: 54)
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Momentum.contentPrimary)
                }
                // EmpathyCopyBlock
                VStack(spacing: 8) {
                    Text("Start your first verse")
                        .font(.momentumHero(28))
                        .foregroundStyle(Momentum.contentPrimary)
                        .multilineTextAlignment(.center)
                    Text("Write a journal entry — Model G turns it into bars.")
                        .font(.momentumBody)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                }
                // PrimaryActionButton (square)
                Button(action: onCreate) {
                    HStack(spacing: 8) { Text("New Note"); Image(systemName: "arrow.right") }
                }
                .buttonStyle(MomentumSquareButtonStyle(fill: .inverse))
            }
            .padding(Momentum.edge)
        }
    }
}
