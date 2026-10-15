import SwiftUI

/// Shows the Sparkler mimic verses inside Penwork and can ask the Mac helper for a new one.
struct SparklerSimSheet: View {
    let onUse: (RapSuggestion) -> Void
    let onDismiss: () -> Void

    @State private var board: SparklerBoard?
    @State private var levelID = "story"
    @State private var loadError: String?
    @State private var writeError: String?
    @State private var isLoading = false
    @State private var isWriting = false
    @Environment(\.dismiss) private var dismiss

    private var level: SparklerLevel? {
        board?.levels.first { $0.id == levelID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && board == nil {
                    ProgressView("Loading verses")
                } else if let loadError, board == nil {
                    ContentUnavailableView {
                        Label("Sparkler helper is not running", systemImage: "sparkles")
                    } description: {
                        Text(loadError)
                    } actions: {
                        Button("Try again") { Task { await reload() } }
                    }
                } else {
                    verseList
                }
            }
            .navigationTitle("Sparkler simulation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
        .task { await reload() }
    }

    private var verseList: some View {
        List {
            Section {
                Picker("Verse kind", selection: $levelID) {
                    Text("Story spine").tag("story")
                    Text("Inner rhyme").tag("inner")
                    Text("Double meanings").tag("double")
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                if let hint = level?.hint {
                    Text(hint)
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                }
                Button {
                    Task { await writeNewVerse() }
                } label: {
                    HStack {
                        if isWriting { ProgressView() }
                        Text(isWriting ? "Writing a verse" : "Write a new verse")
                    }
                }
                .disabled(isWriting)
                if let writeError {
                    Text(writeError)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                } else if let message = board?.run.message, !message.isEmpty {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                }
            }
            ForEach(level?.verses ?? []) { verse in
                Section(verse.title) {
                    Text(verse.lines.joined(separator: "\n"))
                        .font(.body)
                    if !plainNote(verse.note).isEmpty {
                        Text(plainNote(verse.note))
                            .font(.subheadline)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    Button("Use this verse") {
                        onUse(verse.suggestion(kind: level?.title ?? "Sparkler"))
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
        .refreshable { await reload() }
    }

    private func plainNote(_ note: String) -> String {
        if note.hasPrefix("ad-lib rate 0%") {
            return "No ad-libs in this verse. Songs from this stretch use them on about 4 lines in 10."
        }
        return note
    }

    private func reload() async {
        if board == nil { isLoading = true }
        defer { isLoading = false }
        do {
            board = try await SparklerClient.fetchBoard()
            loadError = nil
            isWriting = board?.run.state == "running"
        } catch {
            if board == nil {
                loadError = "Start the Sparkler helper on this Mac, keep the phone on the same Wi-Fi, then try again."
            }
        }
    }

    private func writeNewVerse() async {
        isWriting = true
        writeError = nil
        do {
            let run = try await SparklerClient.startRun(level: levelID)
            if var current = board {
                current.run = run
                board = current
            }
            for _ in 0..<80 {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .seconds(3))
                await reload()
                if board?.run.state != "running" { break }
            }
        } catch {
            writeError = "The helper did not start a new verse. The verses already on this screen are still here."
        }
        isWriting = board?.run.state == "running"
    }
}

private struct SparklerClient {
    static let base: URL = {
        #if targetEnvironment(simulator)
        return URL(string: "http://127.0.0.1:8766")!
        #else
        return URL(string: "http://Samuels-MacBook-Pro-3.local:8766")!
        #endif
    }()

    static func fetchBoard() async throws -> SparklerBoard {
        let (data, response) = try await URLSession.shared.data(from: base.appendingPathComponent("verses"))
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(SparklerBoard.self, from: data)
    }

    static func startRun(level: String) async throws -> SparklerRun {
        var request = URLRequest(url: base.appendingPathComponent("run"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["level": level])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(SparklerRunEnvelope.self, from: data).run
    }
}

struct SparklerBoard: Decodable {
    var levels: [SparklerLevel]
    var run: SparklerRun
}

struct SparklerLevel: Decodable, Identifiable {
    var id: String
    var title: String
    var hint: String
    var verses: [SparklerVerse]
}

struct SparklerVerse: Decodable, Identifiable {
    var seed: Int?
    var take: Int
    var title: String
    var lines: [String]
    var note: String
    var origin: String
    var level: String

    var id: String { "\(level)-\(origin)-\(seed ?? 0)-\(take)" }

    func suggestion(kind: String) -> RapSuggestion {
        RapSuggestion(
            id: UUID(),
            text: lines.joined(separator: "\n"),
            confidence: 0.7,
            source: "Gunna",
            reasoning: "Sparkler \(kind), seed \(seed ?? 0), take \(take)",
            themes: ["mimic"]
        )
    }
}

struct SparklerRun: Decodable {
    var state: String
    var level: String?
    var message: String
    var seed: Int?
}

private struct SparklerRunEnvelope: Decodable {
    var run: SparklerRun
}
