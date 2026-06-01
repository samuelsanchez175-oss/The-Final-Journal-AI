//
//  ImportNotesInstructionsView.swift
//  The Final Journal AI
//
//  Extracted from ContentView.swift
//

import SwiftUI
import SwiftData

// MARK: - Import Notes Instructions Sheet
// NOTE: GlassSettings is defined in ContentView.swift

struct ImportNotesInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    let modelContext: ModelContext
    let onNoteCreated: (Item) -> Void
    
    @State private var hasOpenedNotes: Bool = false
    @State private var importedText: String = ""
    @State private var noteTitle: String = "Imported Note"
    @State private var showWelcomeBack: Bool = false
    
    var body: some View {
        Group {
            if showWelcomeBack {
                welcomeBackView
            } else {
                instructionsView
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // When app becomes active again, check clipboard
            if newPhase == .active && hasOpenedNotes {
                checkClipboardAndShowWelcomeBack()
            }
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "note.text")
                .font(.system(size: 64))
                .foregroundStyle(Momentum.contentSecondary)
                .padding(.bottom, 8)
            
            // Title
            Text("Import from Notes")
                .font(.title.weight(.bold))
            
            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                instructionStep(
                    number: "1",
                    text: "Tap the button below to open the Notes app"
                )
                
                instructionStep(
                    number: "2",
                    text: "Find and copy the note you want to import"
                )
                
                instructionStep(
                    number: "3",
                    text: "Return to this app - your copied text will be ready to import"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Open Notes Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                openNotesApp()
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                    Text("Open Notes App")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .accessibilityLabel("Open Notes App")
            .accessibilityHint("Opens the Notes app so you can copy text to import")
            
            // Cancel Button
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.callout)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .padding(.bottom, 20)
            .accessibilityLabel("Cancel")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(Momentum.surfaceElevated)                .ignoresSafeArea()
        )
    }
    
    private var welcomeBackView: some View {
        VStack(spacing: 24) {
            // Welcome Back Header
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                
                Text("Welcome Back!")
                    .font(.title.weight(.bold))
                
                Text("Your text is ready to import")
                    .font(.callout)
                    .foregroundStyle(Momentum.contentSecondary)
            }
            .padding(.top, 40)
            
            // Text Editor
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Note")
                    .font(.headline)
                    .padding(.horizontal, 20)
                
                TextEditor(text: $importedText)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .scrollContentBackground(.hidden)
                    .textEditorStyle(.plain)
                    .frame(minHeight: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Momentum.surfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Done Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                createAndOpenNote()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("Done")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.accentColor)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .disabled(importedText.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(importedText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            .accessibilityLabel("Done")
            .accessibilityHint("Creates a new note with the imported text")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(Momentum.surfaceElevated)                .ignoresSafeArea()
        )
    }
    
    @ViewBuilder
    private func instructionStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                )
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
    
    private func openNotesApp() {
        hasOpenedNotes = true
        
        // Open Notes app using URL scheme
        if let notesURL = URL(string: "mobilenotes://") {
            UIApplication.shared.open(notesURL) { success in
                if !success {
                    // Fallback: Try to open Settings or show alert
                    // For now, just mark as opened
                }
            }
        }
    }
    
    private func checkClipboardAndShowWelcomeBack() {
        // Check clipboard for text
        if let pasteboardText = UIPasteboard.general.string, !pasteboardText.isEmpty {
            importedText = pasteboardText
            
            // Try to extract title from first line
            let lines = pasteboardText.components(separatedBy: .newlines)
            if let firstLine = lines.first, !firstLine.isEmpty, firstLine.count < 50 {
                noteTitle = firstLine.trimmingCharacters(in: .whitespaces)
            }
            
            // Show welcome back screen
            showWelcomeBack = true
        }
    }
    
    private func createAndOpenNote() {
        let trimmedText = importedText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        
        let newItem = Item(
            timestamp: Date(),
            title: noteTitle.trimmingCharacters(in: .whitespaces).isEmpty ? "Imported Note" : noteTitle,
            body: trimmedText
        )
        
        modelContext.insert(newItem)
        
        // Clear pasteboard after import
        UIPasteboard.general.string = ""
        
        // Callback to navigate to the new note
        onNoteCreated(newItem)
    }
}
