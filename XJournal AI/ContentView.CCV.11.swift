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
    @Binding var selectedNoteID: PersistentIdentifier?

    private var listSelection: Binding<PersistentIdentifier?> {
        Binding(
            get: { isSelectionMode ? nil : selectedNoteID },
            set: { if !isSelectionMode { selectedNoteID = $0 } }
        )
    }

    var body: some View {
        List(selection: listSelection) {
            ForEach(items) { item in
                JournalRowView(
                    item: item,
                    isOnPage1: $isOnPage1,
                    isSelectionMode: $isSelectionMode,
                    selectedItems: $selectedItems
                )
                .tag(item.persistentModelID)
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
                rowContent
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .lineLimit(2)   // was 1 — allow scaled titles a second line before truncating

            // reservesSpace keeps empty-body notes the same height as full ones.
            Text(notePreview.isEmpty ? " " : notePreview)
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.footnote.weight(.semibold))   // scales with the .momentumMetadata date label
                    Text(lastModifiedText)
                        .font(.momentumMetadata)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(Momentum.contentSecondary)
                .frame(width: 146, alignment: .leading)   // fixed date column → chips align across rows

                metaChips   // chips begin at the same x on every row, right next to the date

                Spacer(minLength: 0)
            }
            .frame(minHeight: 18)
            // Dense metadata row (fixed-width date column + alignment-critical chips): clamp Dynamic
            // Type so the 146pt column and cross-row chip alignment survive large text sizes.
            .chromeClamp()

            Divider()
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Palette-tinted metadata chips (audio · BPM · key/scale · folder · link), shown to the
    /// right of the date. Renders only the fields this note actually has.
    @ViewBuilder
    private var metaChips: some View {
        HStack(spacing: 6) {
            if let path = item.audioPath, !path.trimmingCharacters(in: .whitespaces).isEmpty {
                metaChip("Audio", systemImage: "waveform")
                    .accessibilityLabel("Has audio attached")
            }
            if let bpm = item.bpm {
                metaChip("\(bpm)", systemImage: "metronome")
            }
            if let keyScale = keyScaleLabel {
                metaChip(keyScale, systemImage: "music.note")
            }
            if let folder = item.folder, !folder.trimmingCharacters(in: .whitespaces).isEmpty {
                metaChip(folder, systemImage: "folder")
            }
            if let url = item.urlAttachment, !url.trimmingCharacters(in: .whitespaces).isEmpty {
                metaChip("Link", systemImage: "link")
            }
        }
    }

    /// "C Minor" / "C" / "Minor" / nil from the note's key + scale.
    private var keyScaleLabel: String? {
        let trimmedKey = item.key?.trimmingCharacters(in: .whitespaces)
        let trimmedScale = item.scale?.trimmingCharacters(in: .whitespaces)
        let key = (trimmedKey?.isEmpty == false) ? trimmedKey : nil
        let scale = (trimmedScale?.isEmpty == false) ? trimmedScale : nil
        switch (key, scale) {
        case let (key?, scale?): return "\(key) \(scale)"
        case let (key?, nil):    return key
        case let (nil, scale?):  return scale
        default:                 return nil
        }
    }

    /// Small palette-coral pill (icon + label). Concrete + file-local per the Momentum rule.
    private func metaChip(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.caption2.weight(.semibold))   // was 9pt fixed — scales (clamped by the row's chromeClamp)
            Text(text)
                .font(.caption.weight(.medium))       // was 11pt fixed — scales (clamped by the row's chromeClamp)
                .lineLimit(1)
        }
        .foregroundStyle(Momentum.accent)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule(style: .continuous)
                .fill(Momentum.accent.opacity(0.12))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Momentum.accent.opacity(0.22), lineWidth: Momentum.lineThin)
                )
        )
    }

    private var noteTitle: String {
        item.title.isEmpty ? "Untitled Note" : item.title
    }

    private var notePreview: String {
        item.preview
    }

    private var lastModifiedText: String {
        Self.dateFormatter.string(from: item.modifiedDate ?? item.timestamp)
    }
}

struct JournalEmptyStateView: View {
    let onCreate: () -> Void

    var body: some View {
        ZStack {
            Momentum.surface
                .ignoresSafeArea()
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
