import SwiftUI
import SwiftData

struct FolderSelectionSheetView: View {
    let selectedItems: Set<PersistentIdentifier>
    let items: [Item]
    let onAssign: (String?) -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var newFolderName: String = ""
    @State private var selectedFolder: String? = nil
    @State private var existingFolders: [String] = []
    
    // Get existing folders from items
    private var availableFolders: [String] {
        let folderSet = Set(items.compactMap { $0.folder })
        return Array(folderSet).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                
                if !availableFolders.isEmpty {
                    existingFoldersSection
                }
                
                if !availableFolders.isEmpty && newFolderName.isEmpty {
                    Divider()
                        .padding(.horizontal)
                }
                
                createNewFolderSection
                
                Spacer()
                
                actionButtonsSection
            }
            .background(Color(uiColor: .systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onAssign(selectedFolder)
                        dismiss()
                    }
                    .disabled(selectedFolder == nil)
                }
            }
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assign to Folder")
                .font(.title2.weight(.bold))
            
            Text("Selected items: \(selectedItems.count)")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var existingFoldersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Existing Folders")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(availableFolders, id: \.self) { folder in
                    folderButton(for: folder)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func folderButton(for folder: String) -> some View {
        Button {
            selectedFolder = folder
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                Text(folder)
                Spacer()
                if selectedFolder == folder {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if selectedFolder == folder {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor.opacity(0.1))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.accentColor.opacity(selectedFolder == folder ? 1 : 0), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var createNewFolderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create New Folder")
                .font(.headline)
            
            HStack(spacing: 12) {
                TextField("Folder name", text: $newFolderName)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                if !newFolderName.isEmpty {
                    Button {
                        selectedFolder = newFolderName
                    } label: {
                        Text("Select")
                            .font(.callout.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button {
                onCancel()
                dismiss()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            
            Button {
                onAssign(selectedFolder)
                dismiss()
            } label: {
                Text("Assign")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedFolder == nil)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}