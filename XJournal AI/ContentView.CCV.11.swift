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
