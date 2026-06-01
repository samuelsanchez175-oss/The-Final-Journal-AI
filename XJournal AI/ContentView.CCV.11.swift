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

/// Body preview that limits to a fixed number of lines (SwiftUI Text lineLimit can be ignored in List).
private struct NotePreviewLabel: UIViewRepresentable {
    let text: String
    let font: UIFont
    let textColor: UIColor
    var maxWidth: CGFloat = 400
    var lineCount: Int = 3
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = lineCount
        label.lineBreakMode = .byTruncatingTail
        label.font = font
        label.textColor = textColor
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.preferredMaxLayoutWidth = maxWidth
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func updateUIView(_ label: UILabel, context: Context) {
        label.text = text
        label.font = font
        label.textColor = textColor
        label.preferredMaxLayoutWidth = maxWidth
        label.numberOfLines = lineCount
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
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowSeparator(.hidden, edges: .all)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(.plain)
        .contentMargins(.horizontal, 0, for: .scrollContent)
        .background(
            Rectangle()
                .fill(Momentum.surfaceElevated)                .ignoresSafeArea()
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
        GeometryReader { geo in
            let previewMaxWidth = max(0, geo.size.width - 72)
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
                            // Checkbox
                            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundStyle(isSelected ? Momentum.accent : Momentum.contentSecondary)
                            
                            // Content — title at top, then 3-line preview; spacer pushes block to top, divider at bottom
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(noteTitle)
                                        .font(.momentumCardTitle).foregroundStyle(Momentum.contentPrimary)
                                        .lineLimit(1)

                                    NotePreviewLabel(
                                        text: notePreview,
                                        font: .preferredFont(forTextStyle: .callout),
                                        textColor: .secondaryLabel,
                                        maxWidth: previewMaxWidth,
                                        lineCount: 3
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                Spacer(minLength: 0)
                                Divider()
                            }
                            .padding(.bottom, 14)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .frame(minHeight: 80)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(noteTitle)
                            .font(.momentumCardTitle).foregroundStyle(Momentum.contentPrimary)
                            .lineLimit(1)

                        NotePreviewLabel(
                            text: notePreview,
                            font: .preferredFont(forTextStyle: .callout),
                            textColor: .secondaryLabel,
                            maxWidth: previewMaxWidth,
                            lineCount: 3
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    Spacer(minLength: 0)
                    Divider()
                }
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .frame(minHeight: 80)
                .background(Color.clear)
                .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(minHeight: 88)
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
    }
    
    /// Update cached values if item has changed
    private func updateCacheIfNeeded() {
        // Check if item ID changed or if title/body changed (for same item)
        let titleChanged = cachedTitle != (item.title.isEmpty ? "Untitled Note" : item.title)
        let bodyChanged = {
            let newPreview = item.body.isEmpty ? Self.dateFormatter.string(from: item.timestamp) : item.body
            return cachedPreview != newPreview
        }()
        
        // Update cache if item ID changed or if title/body changed
        guard lastItemId != item.id || titleChanged || bodyChanged else { return }
        
        cachedTitle = item.title.isEmpty ? "Untitled Note" : item.title
        
        // Cache preview - format date only once using static formatter
        if item.body.isEmpty {
            cachedPreview = Self.dateFormatter.string(from: item.timestamp)
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
        // Fallback if cache not yet set - use static formatter
        if item.body.isEmpty {
            return Self.dateFormatter.string(from: item.timestamp)
        } else {
            return item.body
        }
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
