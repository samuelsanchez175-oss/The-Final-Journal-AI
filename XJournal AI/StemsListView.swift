//
//  StemsListView.swift
//  XJournal AI
//
//  Self-contained list of audio "stems" with a play/pause toggle per row.
//
//  Self-contained on purpose: it owns its data (no `Item`/`@Bindable` dependency), which removes
//  the cross-file compile fragility that previously broke the build, and uses stable per-row UUIDs
//  so duplicate paths stay independent. To persist edits, wire it to a model where it's presented
//  (e.g. pass `item.stemPaths` in and add a save callback) — see Item.stemPaths.
//

import SwiftUI

struct StemsListView: View {
    private struct Stem: Identifiable {
        let id = UUID()
        var path: String
    }

    @State private var stems: [Stem]
    @State private var playingID: UUID?
    @State private var newStemPath: String = ""

    /// Pass initial stem paths in, or use `StemsListView()` for an empty list.
    init(stemPaths: [String] = []) {
        _stems = State(initialValue: stemPaths.map { Stem(path: $0) })
        _playingID = State(initialValue: nil)
    }

    var body: some View {
        List {
            Section("Stems") {
                if stems.isEmpty {
                    Text("No stems yet. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(stems) { stem in
                        HStack(spacing: 12) {
                            Button {
                                playingID = (playingID == stem.id) ? nil : stem.id
                            } label: {
                                Image(systemName: playingID == stem.id ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                            }
                            .buttonStyle(.plain)

                            Text(stemDisplayName(stem.path))
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteStems)
                }
            }

            Section {
                HStack {
                    TextField("Add stem path", text: $newStemPath)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Add", action: addStem)
                        .disabled(trimmedNewPath.isEmpty)
                }
            }
        }
        .navigationTitle("Stems")
        .toolbar { EditButton() }
    }

    private var trimmedNewPath: String {
        newStemPath.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addStem() {
        let path = trimmedNewPath
        guard !path.isEmpty else { return }
        stems.append(Stem(path: path))
        newStemPath = ""
    }

    private func deleteStems(at offsets: IndexSet) {
        for index in offsets where stems[index].id == playingID {
            playingID = nil
        }
        stems.remove(atOffsets: offsets)
    }

    private func stemDisplayName(_ path: String) -> String {
        let name = URL(fileURLWithPath: path).lastPathComponent
        return name.isEmpty ? path : name
    }
}

#Preview {
    NavigationStack {
        StemsListView(stemPaths: ["/tmp/drums.wav", "/tmp/vocals.wav", "/tmp/drums.wav"])
    }
}
