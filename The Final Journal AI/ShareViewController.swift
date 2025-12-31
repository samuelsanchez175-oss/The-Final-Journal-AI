import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

final class ShareViewController: SLComposeServiceViewController {

    private let appGroupID = "group.com.finaljournal.app"

    override func isContentValid() -> Bool {
        true
    }

    override func didSelectPost() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments
        else {
            complete()
            return
        }

        for provider in attachments {

            // MARK: Notes / Text
            if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] item, _ in
                    if let text = item as? String {
                        self?.storeTextAndReturn(text)
                    } else if let url = item as? URL,
                              let text = try? String(contentsOf: url) {
                        self?.storeTextAndReturn(text)
                    } else {
                        self?.complete()
                    }
                }
                return
            }

            // MARK: Voice Memos / Audio
            if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil) { [weak self] item, _ in
                    if let url = item as? URL {
                        self?.storeAudioAndReturn(url)
                    } else {
                        self?.complete()
                    }
                }
                return
            }
        }

        complete()
    }

    // MARK: - Storage

    private func storeTextAndReturn(_ text: String) {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(text, forKey: "importedNoteText")
        defaults?.set("notes", forKey: "importSource")

        DispatchQueue.main.async {
            self.openHostApp()
            self.complete()
        }
    }

    private func storeAudioAndReturn(_ url: URL) {
        let fileManager = FileManager.default
        guard let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            complete()
            return
        }

        let destination = containerURL.appendingPathComponent(url.lastPathComponent)
        try? fileManager.removeItem(at: destination)
        try? fileManager.copyItem(at: url, to: destination)

        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(destination.path, forKey: "importedAudioPath")
        defaults?.set("voiceMemo", forKey: "importSource")

        DispatchQueue.main.async {
            self.openHostApp()
            self.complete()
        }
    }

    // MARK: - Return to App

    private func openHostApp() {
        guard let url = URL(string: "finaljournal://import") else { return }

        var responder: UIResponder? = self
        while responder != nil {
            if let app = responder as? UIApplication {
                app.open(url)
                break
            }
            responder = responder?.next
        }
    }

    private func complete() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
