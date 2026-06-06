//
//  StemsListView.swift
//  XJournal AI
//
//  Self-contained list of audio "stems" with a play/pause toggle per row.
//
//  Rewritten to remove the compile errors from a half-finished generated version:
//   • line 21 `$item.stemPaths` — needed `@Bindable` + a non-existent `Item.stemPaths`.
//     This view now owns its data (no `Item` dependency at all), so those errors cannot occur.
//   • line 32 `nowPlaying ?? <#default value#> == path` — an unfilled Xcode placeholder.
//     Replaced with `nowPlaying == path` (`Optional<String> == String` is valid Swift; no
//     unwrap and no placeholder needed).
//

import SwiftUI

struct StemsListView: View {
    @State private var stemPaths: [String]
    @State private var nowPlaying: String?
    @State private var newStemPath: String = ""

    /// Pass initial stem paths in, or use `StemsListView()` for an empty list.
    init(stemPaths: [String] = []) {
        _stemPaths = State(initialValue: stemPaths)
        _nowPlaying = State(initialValue: nil)
    }

    var body: some View {
        List {
            Section("Stems") {
                if stemPaths.isEmpty {
                    Text("No stems yet. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(stemPaths, id: \.self) { path in
                        HStack(spacing: 12) {
                            Button {
                                nowPlaying = (nowPlaying == path) ? nil : path
                            } label: {
                                Image(systemName: nowPlaying == path ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                            }
                            .buttonStyle(.plain)

                            Text(stemDisplayName(path))
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
        stemPaths.append(path)
        newStemPath = ""
    }

    private func deleteStems(at offsets: IndexSet) {
        for index in offsets where stemPaths[index] == nowPlaying {
            nowPlaying = nil
        }
        stemPaths.remove(atOffsets: offsets)
    }

    private func stemDisplayName(_ path: String) -> String {
        let name = URL(fileURLWithPath: path).lastPathComponent
        return name.isEmpty ? path : name
    }
}

#Preview {
    NavigationStack {
        StemsListView(stemPaths: ["/tmp/drums.wav", "/tmp/vocals.wav", "/tmp/bass.wav"])
    }
}
