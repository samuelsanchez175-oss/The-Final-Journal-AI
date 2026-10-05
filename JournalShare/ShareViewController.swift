import UIKit
import UniformTypeIdentifiers

/// Share sheet for Notes, Messages, Safari, text files, and audio.
/// Writes a note into the app group. The main app creates it on the next open.
final class ShareViewController: UIViewController {
    private let appGroupID = "group.com.finaljournal.app"
    private let queueKey = "pendingSharedNotes"

    private let titleField = UITextField()
    private let preview = UITextView()
    private let importButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    private var bodyText = ""
    private var audioRelative: String?
    private var didFinish = false

    private struct SharedNote: Codable {
        var title: String
        var body: String
        var audioFile: String?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildChrome()
        loadShare()
    }

    private func buildChrome() {
        let titleLabel = UILabel()
        titleLabel.text = "Import into XJournal AI"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true

        titleField.borderStyle = .roundedRect
        titleField.placeholder = "Note title"
        titleField.font = .preferredFont(forTextStyle: .body)
        titleField.adjustsFontForContentSizeCategory = true
        titleField.clearButtonMode = .whileEditing
        titleField.autocapitalizationType = .sentences
        titleField.accessibilityLabel = "Note title"

        preview.isEditable = false
        preview.isSelectable = true
        preview.font = .preferredFont(forTextStyle: .body)
        preview.adjustsFontForContentSizeCategory = true
        preview.backgroundColor = .secondarySystemBackground
        preview.layer.cornerRadius = 12
        preview.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        preview.text = "Reading the shared note…"
        preview.accessibilityLabel = "Note preview"

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.text = "Line breaks stay as they are."

        importButton.setTitle("Import", for: .normal)
        importButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        importButton.backgroundColor = .label
        importButton.setTitleColor(.systemBackground, for: .normal)
        importButton.layer.cornerRadius = 12
        importButton.isEnabled = false
        importButton.alpha = 0.4
        importButton.addTarget(self, action: #selector(importTapped), for: .touchUpInside)
        importButton.accessibilityLabel = "Import"
        importButton.accessibilityHint = "Saves this note in XJournal AI."

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.font = .preferredFont(forTextStyle: .body)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancel.accessibilityLabel = "Cancel"

        let stack = UIStackView(arrangedSubviews: [titleLabel, titleField, preview, statusLabel, importButton, cancel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            preview.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            importButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func loadShare() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            showEmpty("Nothing to import.")
            return
        }
        let providers = item.attachments ?? []
        let titleHint = item.attributedTitle?.string
        if let provider = providers.first(where: isTextProvider) {
            loadText(provider, titleHint: titleHint)
            return
        }
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.audio.identifier) }) {
            loadAudio(provider, titleHint: titleHint)
            return
        }
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            loadWebURL(provider, titleHint: titleHint, content: item.attributedContentText?.string)
            return
        }
        if let content = item.attributedContentText?.string, !content.isEmpty {
            applyText(content, titleHint: titleHint)
            return
        }
        showEmpty("This share has no text or audio.")
    }

    private func isTextProvider(_ provider: NSItemProvider) -> Bool {
        provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
            || provider.hasItemConformingToTypeIdentifier(UTType.rtf.identifier)
            || provider.hasItemConformingToTypeIdentifier(UTType.html.identifier)
            || provider.hasItemConformingToTypeIdentifier(UTType.text.identifier)
    }

    private func loadText(_ provider: NSItemProvider, titleHint: String?) {
        let types = [
            UTType.plainText.identifier,
            UTType.utf8PlainText.identifier,
            UTType.rtf.identifier,
            UTType.html.identifier,
            UTType.text.identifier
        ]
        let type = types.first { provider.hasItemConformingToTypeIdentifier($0) } ?? UTType.text.identifier
        let hint = titleHint
        provider.loadItem(forTypeIdentifier: type, options: nil) { [weak self] item, _ in
            let parsed = Self.parseTextItem(item, type: type)
            let controller = self
            Task { @MainActor in
                guard let controller else { return }
                if let parsed, !parsed.isEmpty {
                    controller.applyText(parsed, titleHint: hint)
                } else {
                    controller.showEmpty("Could not read that note.")
                }
            }
        }
    }

    private func loadWebURL(_ provider: NSItemProvider, titleHint: String?, content: String?) {
        let hint = titleHint
        let pageText = content
        provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] item, _ in
            let url = item as? URL
            let controller = self
            Task { @MainActor in
                guard let controller else { return }
                if let pageText, !pageText.isEmpty {
                    controller.applyText(pageText, titleHint: hint)
                    return
                }
                guard let url, !url.isFileURL else {
                    controller.showEmpty("Could not read that link.")
                    return
                }
                let host = url.host ?? "Link"
                controller.applyText(url.absoluteString, titleHint: hint ?? host)
            }
        }
    }

    private func loadAudio(_ provider: NSItemProvider, titleHint: String?) {
        let groupID = appGroupID
        let hint = titleHint
        provider.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil) { [weak self] item, _ in
            let copied = (item as? URL).flatMap { Self.copyAudio($0, appGroupID: groupID) }
            let filename = (item as? URL)?.deletingPathExtension().lastPathComponent
            let controller = self
            Task { @MainActor in
                guard let controller else { return }
                guard let copied else {
                    controller.showEmpty("Could not attach that audio.")
                    return
                }
                controller.audioRelative = copied
                controller.bodyText = ""
                controller.preview.text = "Audio will be attached to a new note."
                let fallback = (filename?.isEmpty == false) ? filename! : "Voice Memo"
                controller.fillTitle(hint ?? fallback)
                controller.enableImport()
                controller.statusLabel.text = "The recording is attached to this note."
            }
        }
    }

    nonisolated private static func parseTextItem(_ item: Any?, type: String) -> String? {
        if let text = item as? String { return text }
        if let attributed = item as? NSAttributedString { return attributed.string }
        if let url = item as? URL {
            if url.isFileURL {
                return try? String(contentsOf: url, encoding: .utf8)
            }
            return url.absoluteString
        }
        guard let data = item as? Data else { return nil }
        if type == UTType.rtf.identifier,
           let attributed = attributedString(data, documentType: .rtf) {
            return attributed.string
        }
        if type == UTType.html.identifier,
           let attributed = attributedString(data, documentType: .html) {
            return attributed.string
        }
        return String(data: data, encoding: .utf8)
    }

    nonisolated private static func attributedString(
        _ data: Data,
        documentType: NSAttributedString.DocumentType
    ) -> NSAttributedString? {
        try? NSAttributedString(
            data: data,
            options: [.documentType: documentType],
            documentAttributes: nil
        )
    }

    private func applyText(_ text: String, titleHint: String?) {
        bodyText = text
        preview.text = text
        let hint = titleHint?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        fillTitle(hint.isEmpty ? Self.firstLine(of: text) : hint)
        enableImport()
        statusLabel.text = "Line breaks stay as they are."
    }

    private func fillTitle(_ raw: String) {
        let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if line.isEmpty {
            titleField.text = "Imported Note"
            return
        }
        titleField.text = line.count <= 80 ? line : String(line.prefix(80))
    }

    nonisolated private static func firstLine(of text: String) -> String {
        let line = text.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Imported Note" : trimmed
    }

    private func enableImport() {
        importButton.isEnabled = true
        importButton.alpha = 1
    }

    private func showEmpty(_ message: String) {
        preview.text = message
        statusLabel.text = message
        importButton.isEnabled = false
        importButton.alpha = 0.4
    }

    nonisolated private static func copyAudio(_ url: URL, appGroupID: String) -> String? {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        let fileManager = FileManager.default
        guard let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        let folder = container.appendingPathComponent("SharedImports", isDirectory: true)
        do {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            let ext = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
            let name = UUID().uuidString + "." + ext
            let destination = folder.appendingPathComponent(name)
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.copyItem(at: url, to: destination)
            return "SharedImports/\(name)"
        } catch {
            return nil
        }
    }

    @objc private func importTapped() {
        let typed = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title = typed.isEmpty ? Self.firstLine(of: bodyText) : typed
        guard !bodyText.isEmpty || audioRelative != nil else { return }
        let note = SharedNote(title: title, body: bodyText, audioFile: audioRelative)
        enqueue(note)
        finishAndOpenHost()
    }

    @objc private func cancelTapped() {
        guard !didFinish else { return }
        didFinish = true
        extensionContext?.cancelRequest(withError: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
    }

    private func enqueue(_ note: SharedNote) {
        let defaults = UserDefaults(suiteName: appGroupID)
        var notes: [SharedNote] = []
        if let data = defaults?.data(forKey: queueKey),
           let existing = try? JSONDecoder().decode([SharedNote].self, from: data) {
            notes = existing
        }
        notes.append(note)
        if let data = try? JSONEncoder().encode(notes) {
            defaults?.set(data, forKey: queueKey)
        }
        defaults?.synchronize()
    }

    private func finishAndOpenHost() {
        guard !didFinish else { return }
        didFinish = true
        guard let url = URL(string: "finaljournal://import") else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        // Complete only after the open is attempted. Completing first can drop the URL,
        // so a running app would not see the note until the next cold launch.
        extensionContext?.open(url) { [weak self] _ in
            let controller = self
            Task { @MainActor in
                controller?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }
}
