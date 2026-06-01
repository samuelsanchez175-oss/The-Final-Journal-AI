import SwiftUI
import UIKit

// MARK: - BPM Popover View
// File: ContentView.CCV.8.swift
// Dependencies: CCV.2 (GlassSettings)
// Used by: ContentView.swift, NoteEditorView

struct BPMPopoverView: View {
    @Binding var bpm: Int?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BPM")
                .font(.headline)
            
            // BPM Slider
            VStack(spacing: 8) {
                HStack {
                    Text("60")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                    Spacer()
                    if let bpm = bpm {
                        Text("\(bpm)")
                            .font(.title3.weight(.semibold))
                    } else {
                        Text("—")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                    Spacer()
                    Text("220")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(bpm ?? 120) },
                        set: { bpm = Int($0) }
                    ),
                    in: 60...220,
                    step: 1
                )
            }
            
            // Quick Select Buttons
            HStack(spacing: 8) {
                ForEach([60, 90, 120, 140, 160, 180, 200], id: \.self) { value in
                    Button {
                        bpm = value
                    } label: {
                        Text("\(value)")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(bpm == value ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: 12) {
                // Clear Button
                Button {
                    bpm = nil
                } label: {
                    Text("Clear")
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Done Button with Checkmark
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Momentum.surfaceElevated)                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
    }
}

// MARK: - Key Popover View

struct KeyPopoverView: View {
    @Binding var key: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private let musicalKeys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Musical Key")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(musicalKeys, id: \.self) { keyValue in
                    Button {
                        key = keyValue
                    } label: {
                        Text(keyValue)
                            .font(.callout.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(key == keyValue ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button {
                key = nil
            } label: {
                Text("Clear")
                    .font(.callout)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Momentum.surfaceElevated)                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
    }
}

// MARK: - Scale Popover View

struct ScalePopoverView: View {
    @Binding var key: String?
    @Binding var scale: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private let scales = [
        "Chromatic",
        "Major",
        "Natural Minor",
        "Harmonic Minor",
        "Melodic Minor",
        "Ionian (Major)",
        "Dorian",
        "Phrygian",
        "Lydian",
        "Mixolydian",
        "Aeolian (Natural Minor)",
        "Locrian"
    ]
    
    var body: some View {
        ScrollView {
            contentView
        }
        .padding(20)
        .frame(width: 340)
        .frame(maxHeight: 400)
        .background(backgroundView)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scale")
                .font(.headline)
            
            keyStatusView
            
            ForEach(scales, id: \.self) { scaleValue in
                scaleButton(for: scaleValue)
            }
            
            clearButton
        }
    }
    
    @ViewBuilder
    private var keyStatusView: some View {
        if key == nil {
            Text("Select Key First")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        } else {
            Text("Key: \(key ?? "")")
                .font(.caption)
                .foregroundStyle(Momentum.contentSecondary)
        }
    }
    
    private func scaleButton(for scaleValue: String) -> some View {
        Button {
            scale = scaleValue
        } label: {
            HStack {
                Text(scaleValue)
                    .font(.callout)
                Spacer()
                if scale == scaleValue {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.semibold))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(scaleButtonBackground(isSelected: scale == scaleValue))
        }
        .buttonStyle(.plain)
    }
    
    private func scaleButtonBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    }
    
    private var clearButton: some View {
        Button {
            scale = nil
        } label: {
            Text("Clear")
                .font(.callout)
                .foregroundStyle(Momentum.contentSecondary)
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Momentum.surfaceElevated)
            .overlay(
                LinearGradient(
                    colors: [
                        .white.opacity((GlassSettings.gloss - 0.6) / 3),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.overlay)
            )
    }
}

// MARK: - URL Attachment Popover View

struct URLAttachmentPopoverView: View {
    @Binding var url: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var urlText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("URL Attachment")
                .font(.headline)
            
            // Glassmorphic Text Field
            TextField("Enter URL (YouTube, etc.)", text: $urlText)
                .focused($isTextFieldFocused)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Momentum.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(isTextFieldFocused ? 0.2 : 0.1),
                                            .white.opacity(isTextFieldFocused ? 0.15 : 0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isTextFieldFocused ? 1 : 0.5
                                )
                        )
                )
                .onAppear {
                    urlText = url ?? ""
                }
            
            // URL Preview (if valid)
            if !urlText.isEmpty, let urlObj = URL(string: urlText), urlObj.scheme != nil {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                    Text(urlText)
                        .font(.caption)
                        .foregroundStyle(Momentum.contentSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(0.1))
                )
            }
            
            HStack(spacing: 12) {
                // Clear Button
                Button {
                    url = nil
                    urlText = ""
                } label: {
                    Text("Clear")
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Done Button with Checkmark
                Button {
                    url = urlText.isEmpty ? nil : urlText
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Momentum.surfaceElevated)                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .white.opacity((GlassSettings.gloss - 0.6) / 4),
                            .white.opacity((GlassSettings.gloss - 0.6) / 3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                )
        )
    }
}

// MARK: - Folder Popover View

struct FolderPopoverView: View {
    @Binding var folder: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var folderName: String = ""
    @State private var existingFolders: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Folder")
                .font(.headline)
            
            TextField("Folder Name", text: $folderName)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.words)
                .onAppear {
                    folderName = folder ?? ""
                    // TODO: Load existing folders from all items
                }
            
            // Existing Folders (if any)
            if !existingFolders.isEmpty {
                Text("Existing Folders")
                    .font(.caption)
                    .foregroundStyle(Momentum.contentSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(existingFolders, id: \.self) { existingFolder in
                            Button {
                                folderName = existingFolder
                            } label: {
                                Text(existingFolder)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(Color.accentColor.opacity(0.2))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    folder = folderName.isEmpty ? nil : folderName
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.accentColor.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    folder = nil
                    folderName = ""
                    dismiss()
                } label: {
                    Text("Clear")
                        .font(.callout)
                        .foregroundStyle(Momentum.contentSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Momentum.surfaceElevated)                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity((GlassSettings.gloss - 0.6) / 3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                )
        )
    }
}
