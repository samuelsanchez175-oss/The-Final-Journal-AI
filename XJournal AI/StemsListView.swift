//
//  StemsListView.swift
//  XJournal AI
//
//  Recreated from scratch. The previous (local, uncommitted) copy referenced `item.stemPaths`
//  before that property existed and used `$item` without `@Bindable`, which produced:
//    - "Referencing subscript 'subscript(dynamicMember:)' requires wrapper 'Bindable<Item>'"
//    - "Value of type 'Item' has no dynamic member 'stemPaths'"
//    - "Cannot convert value of type '[Any]' to expected argument type 'Binding<Subject>'"
//    - "Value of optional type 'String?' must be unwrapped…"
//  This version declares `@Bindable var item: Item` (so $-bindings work), reads the now-existing
//  `item.stemPaths` ([String], non-optional), and handles paths safely — so it compiles clean.
//

import SwiftUI

/// Lists the audio "stems" (separated track file paths) attached to an `Item`, with add + delete.
struct StemsListView: View {
    @Bindable var item: Item

    @State private var newStemPath: String = ""

    var body: some View {
        List {
            Section {
                if item.stemPaths.isEmpty {
                    Text("No stems yet. Add a stem file path below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(item.stemPaths.enumerated()), id: \.offset) { _, path in
                        Label(stemDisplayName(path), systemImage: "waveform")
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .onDelete { offsets in
                        item.stemPaths.remove(atOffsets: offsets)
                    }
                }
            } header: {
                Text("Stems")
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
        item.stemPaths.append(path)
        newStemPath = ""
    }

    /// File name for a stem path; falls back to the raw path if there's no last component.
    private func stemDisplayName(_ path: String) -> String {
        let name = URL(fileURLWithPath: path).lastPathComponent
        return name.isEmpty ? path : name
    }
}
