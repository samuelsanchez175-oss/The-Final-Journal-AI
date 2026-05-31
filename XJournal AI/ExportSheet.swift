import SwiftUI
import UniformTypeIdentifiers

// MARK: - Export Sheet (Phase 5: Export Functionality)

struct ExportSheet: View {
    let item: Item
    let onDismiss: () -> Void
    
    @State private var exportFormat: ExportFormat = .pdf
    @State private var isExporting: Bool = false
    @State private var exportError: String?
    @State private var exportedURL: URLWrapper?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF"
        case word = "Word (RTF)"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .word: return "doc.text.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    
                    Text("Export Note")
                        .font(.title2.weight(.bold))
                    
                    Text("Choose a format to export your note")
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Format Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Format")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Button {
                                exportFormat = format
                            } label: {
                                HStack {
                                    Image(systemName: format.icon)
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                        .frame(width: 44)
                                    
                                    Text(format.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    if exportFormat == format {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(
                                                    exportFormat == format ? Color.blue : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Export Button
                Button {
                    Task {
                        await exportNote()
                    }
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isExporting ? "Exporting..." : "Export Note")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isExporting ? Color.gray : Color.blue)
                    )
                }
                .disabled(isExporting)
                .padding(.horizontal)
                
                // Error Message
                if let error = exportError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.black.opacity(colorScheme == .dark ? GlassSettings.darkening : 0))
                    .ignoresSafeArea()
            )
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
            .sheet(item: $exportedURL) { urlWrapper in
                ShareSheet(items: [urlWrapper.url])
            }
        }
    }
    
    private func exportNote() async {
        isExporting = true
        exportError = nil
        
        let url: URL?
        
        switch exportFormat {
        case .pdf:
            url = ExportManager.shared.exportToPDF(item: item)
        case .word:
            url = ExportManager.shared.exportToWord(item: item)
        }
        
        await MainActor.run {
            if let url = url {
                exportedURL = URLWrapper(url: url)
            } else {
                exportError = "Failed to export note"
            }
            isExporting = false
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - URL Wrapper for Identifiable

struct URLWrapper: Identifiable {
    let id: String
    let url: URL
    
    init(url: URL) {
        self.url = url
        self.id = url.absoluteString
    }
}
