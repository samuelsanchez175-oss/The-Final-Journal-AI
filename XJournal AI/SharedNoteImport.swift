import Foundation
import SwiftData

/// Notes the share extension leaves in the app group. The app creates them on
/// the next open, and again when a `finaljournal://import` URL arrives.
enum SharedNoteImport {
    static let suiteName = "group.com.finaljournal.app"
    static let queueKey = "pendingSharedNotes"

    struct Note: Codable, Equatable, Sendable {
        var title: String
        var body: String
        var audioFile: String?
    }

    /// Inserts every pending share and returns the last note so the library can open it.
    @MainActor
    static func drain(into context: ModelContext) -> Item? {
        let defaults = UserDefaults(suiteName: suiteName)
        var notes = decode(defaults?.data(forKey: queueKey))

        if let legacy = defaults?.string(forKey: "importedNoteText"), !legacy.isEmpty {
            let hinted = defaults?.string(forKey: "importedNoteTitle") ?? ""
            notes.append(Note(title: hinted, body: legacy, audioFile: nil))
        }
        if defaults?.string(forKey: "importSource") == "voiceMemo",
           let path = defaults?.string(forKey: "importedAudioPath"), !path.isEmpty {
            notes.append(Note(title: "Voice Memo", body: "", audioFile: path))
        }

        defaults?.removeObject(forKey: queueKey)
        defaults?.removeObject(forKey: "importedNoteText")
        defaults?.removeObject(forKey: "importedNoteTitle")
        defaults?.removeObject(forKey: "importedAudioPath")
        defaults?.removeObject(forKey: "importSource")

        guard !notes.isEmpty else { return nil }

        var last: Item?
        for note in notes {
            let item = Item(
                timestamp: Date(),
                title: displayTitle(note.title, body: note.body, audioFile: note.audioFile),
                body: note.body
            )
            if let audio = resolveAudio(note.audioFile) {
                item.audioPath = audio
            }
            context.insert(item)
            last = item
        }
        try? context.save()
        return last
    }

    static func displayTitle(_ raw: String, body: String, audioFile: String?) -> String {
        let typed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if !typed.isEmpty {
            return clip(typed)
        }
        let first = body.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
        let line = first.trimmingCharacters(in: .whitespacesAndNewlines)
        if !line.isEmpty {
            return clip(line)
        }
        if audioFile != nil {
            return "Voice Memo"
        }
        return "Imported Note"
    }

    private static func clip(_ line: String) -> String {
        if line.count <= 80 { return line }
        return String(line.prefix(80))
    }

    private static func decode(_ data: Data?) -> [Note] {
        guard let data, !data.isEmpty else { return [] }
        return (try? JSONDecoder().decode([Note].self, from: data)) ?? []
    }

    /// Copies a shared recording into Documents so the note keeps it.
    private static func resolveAudio(_ name: String?) -> String? {
        guard let name, !name.isEmpty else { return nil }
        let fileManager = FileManager.default
        let source: URL
        if name.hasPrefix("/") {
            source = URL(fileURLWithPath: name)
        } else if let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: suiteName) {
            source = container.appendingPathComponent(name)
        } else {
            return nil
        }
        guard fileManager.fileExists(atPath: source.path) else { return nil }
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return source.path
        }
        let folder = documents.appendingPathComponent("SharedImports", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appendingPathComponent(source.lastPathComponent)
        if fileManager.fileExists(atPath: destination.path) {
            return destination.path
        }
        do {
            try fileManager.copyItem(at: source, to: destination)
            return destination.path
        } catch {
            return source.path
        }
    }
}
