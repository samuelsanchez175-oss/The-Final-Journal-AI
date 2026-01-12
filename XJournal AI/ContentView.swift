import SwiftUI
import SwiftData
import UIKit
import Combine
import NaturalLanguage
import AVFoundation
import Speech
import PhotosUI
import UniformTypeIdentifiers

// =======================================================
// PAGE MAP (ARCHITECTURAL)
// — LOCKED — DO NOT MODIFY
// Any structural changes here require explicit review.
// =======================================================
// Page 1    — Journal Library (Home / Notes List)
// Page 1.1  — Profile Entry Point (Top Right)
// Page 1.1.1 — Release Notes (Top Right, Segment 1 Sheet)
// Page 1.1.2 — Support / Shop (Top Right, Segment 1 Sheet)
// Page 1.2  — Bottom Search Bar (Home)
// Page 1.3  — Import / Create Menu (Top Right)
// Page 1.4  — Filters & Folders (Home)
// Page 1.5  — Quick Compose Button (Bottom Right)
// Page 2    — Note Editor (Writing Surface)
// Page 3    — Keyboard Bottrom eDynamic Island Toolbar
// Page 3.1  — Clip / Attach Menu (Files, Notes, Voice Memos)
// Page 3.1.1 — Keyboard Dynamic Toolbar Part 2 (Overlay)
// Page 3.2  — AI Assist Menu (Read‑Only Suggestions)
// Page 3.3  — Eye Toggle (Rhyme Group Visibility)
// NOTE: Eye toggle state is an internal implementation detail of Page 3.3,
// not a standalone page.
// Page 3.4  — Debug / Diagnostics Tool (Analysis Only)
// Page 3.4.1 — UIKit Overlay Test Flag (Debug Placeholder)
// Page 3.5  — Magnifying Glass (Rhyme Group List / Map)
// Page 5    — Rhyme Highlighter Engine (Base)
// Page 6    — Visual Highlight Overlay
// Page 7    — Phonetic Rhyme Engine (CMUDICT)
// Page 8    — Rhyme Categories (Perfect vs Near)
// Page 9    — Internal Rhymes & Position Awareness
// Page 10   — Rhyme Intelligence Panel
// Page 11   — Syllables & Stress Illumination
// Page 12   — Cadence & Flow Metrics
// =======================================================
// SEGMENTS (DESIGN / INTERACTION CONTRACTS)
// Segment 1 — Editorial Release Notes Sheet
// Notes-style release notes presented as a sheet with medium + large detents,
// dense editorial layout, and feature cards. Client-facing, readable, polished.
// Segment 2 — Menu-Anchored Glass Popovers
// Menu-driven, button-anchored liquid-glass popovers (non-sheet),
// matching Page 1.3 Import/Create behavior.
// Segment 3 — Focused Morphing
// UI elements expand / contract based on focus state (search, keyboard)
// with no layout drift — internal morphing only.
// Segment 4 — Micro-Compression on Touch
// Subtle press-in compression on touch-down,
// released on lift or expansion. Applied consistently across controls.
// Segment 5 — Keyboard-Aware Adaptive Glass Bars
// GlassEffectContainer-based toolbars that live above the keyboard,
// support collapse (+) and expand states,
// and never shift the underlying text surface.

// Segment 6 — Hardware Curvature Alignment
// .glassEffect(in: .rect(cornerRadius: .containerConcentric)) // [2, 20]
// Aligns glass effect corner radius with device-specific hardware curvature
// for seamless visual integration with device bezels.
// Segment 7 — Identity-Linked presentation
// Button("Open") { showDetail = true }
//     .matchedTransitionSource(id: "source", in: namespace) // [5, 6]
// .sheet(isPresented: $showDetail) {
//     DetailView()
//         .navigationTransition(.zoom(sourceID: "source", in: namespace)) // [5, 7]
// }
// Provides smooth zoom transitions between source and destination views
// using matched geometry effects for visual continuity.
// Segment 8 — Shared-Surface Grouping
// GlassEffectContainer(spacing: 24) { // Blends elements within 24pts [10, 11]
//     HStack {
//         Button(systemImage: "pencil") {}.buttonStyle(.glass)
//         Button(systemImage: "trash") {}.buttonStyle(.glass)
//     }
// }
// Groups related glass elements on a shared surface with controlled spacing
// for visual cohesion and element blending.
// Segment 9 — Semantic Tinting & Vibrancy
// Button("Primary Action") {}
//     .buttonStyle(.glassProminent)
//     .tint(.blue) // Used for CTA meaning [12, 21]
// Applies semantic color tinting to convey meaning and importance,
// particularly for call-to-action elements and primary actions.
// Segment 10 — Materialized Reveal
// if isMenuExpanded {
//     SecondaryControl()
//         .glassEffectTransition(.materialize) // Fade via light modulation [15, 22]
// }
// Implements fade-in transitions for secondary controls using light modulation
// for smooth materialization animations.
// Segment 11 — Floating Keyboard Island
// .safeAreaInset(edge: .bottom) {
//     KeyboardIslandView() // Component follows keyboard height [17, 18]
// }
// Creates a keyboard-adaptive component that follows keyboard height changes
// while maintaining visual consistency and avoiding layout disruption.
// Segment 12 — Editorial Symbol Tiles
// Notes-style editorial symbol tiles used in release notes and announcements.
// Uses SF Symbols rendered inside soft glass cards instead of image assets.
// Ensures zero asset dependency, consistent loading, and system-native polish.
// Supports versioned feature cards with icon + text pairings.

// =======================================================
// MARK: - Type Definitions (moved earlier for visibility)
// =======================================================
// NOTE: Components have been extracted to separate files:
// - CMUDICTStore.swift
// - RhymeModels.swift
// - RhymeHighlighterEngine.swift
// - AudioPlayerManager.swift
// - KeyboardObserver.swift
// - PopoverViews.swift
// - RhymeHighlightTextView.swift
// - GlassEffect.swift
// - AuthViews.swift

// MARK: - Remaining components below (to be extracted)
// NOTE: Extracted components are in ContentView.CCV.1 through CCV.9 files
// The following code has been removed and moved to separate files:
// - FJCMUDICTStore (CCV.1)
// - RhymeColorPalette, GlassSettings, ScrollOffsetKey, etc. (CCV.2)
// - RhymeHighlighterEngine, RhymeEngineState (CCV.3)
// - AudioPlayerManager (CCV.4)
// - KeyboardObserver (CCV.5)
// - RhymeHighlightTextView (CCV.6)
// - GlassView (CCV.7)
// - PopoverViews (CCV.8)
// - SignInView, SignUpView (CCV.9)

// MARK: - Remaining components start here

// =======================================================
// MARK: - PAGE 1: Journal Library
// =======================================================
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedImportedItem: Item?
    @State private var showHeroSplash: Bool = false

    var body: some View {
        JournalLibraryView(selectedImportedItem: $selectedImportedItem)
            .onAppear {
                // Pre-load CMUDICT dictionary asynchronously on app launch
                // This ensures dictionary is ready before first rhyme analysis
                FJCMUDICTStore.shared.preloadAsync()
                
                // Check if we should show hero splash screen
                showHeroSplash = !SplashScreenManager.shared.hasCompletedOnboarding
            }
            .overlay {
                // Hero Screen on First Launch
                if showHeroSplash {
                    HeroSplashView {
                        // Mark onboarding as complete when hero splash is dismissed
                        SplashScreenManager.shared.markOnboardingComplete()
                        showHeroSplash = false
                    }
                    .transition(.opacity)
                    .zIndex(1000)
                }
            }
            .onOpenURL { url in
                guard url.scheme == "finaljournal",
                      url.host == "import"
                else { return }

                let defaults = UserDefaults(suiteName: "group.com.finaljournal.app")
                let source = defaults?.string(forKey: "importSource")

                // Import from Apple Notes
                if source == "notes",
                   let text = defaults?.string(forKey: "importedNoteText"),
                   !text.isEmpty {

                    let newItem = Item(
                        timestamp: Date(),
                        title: "Imported Note",
                        body: text
                    )

                    modelContext.insert(newItem)
                    selectedImportedItem = newItem

                    defaults?.removeObject(forKey: "importedNoteText")
                }

                // Import from Voice Memos
                if source == "voiceMemo",
                   let path = defaults?.string(forKey: "importedAudioPath") {

                    let newItem = Item(
                        timestamp: Date(),
                        title: "Voice Memo",
                        body: ""
                    )

                    newItem.audioPath = path
                    modelContext.insert(newItem)
                    selectedImportedItem = newItem

                    defaults?.removeObject(forKey: "importedAudioPath")
                }

                defaults?.removeObject(forKey: "importSource")
            }
    }
}

// MARK: - Helper Functions

    private func profileField(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private func profileField(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default, isValid: Bool? = nil, helperText: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
            
            if let helperText = helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(isValid == false ? .red : .secondary)
            }
        }
    }
    
    private func profileSecureField(label: String, text: Binding<String>, placeholder: String, helperText: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            SecureField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
            
            if let helperText = helperText {
                Text(helperText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

// MARK: - Extracted Views
// The following views have been extracted to separate files:
// - JournalLibraryView -> ContentView.CCV.10.swift
// - JournalListView, JournalRowView, JournalEmptyStateView -> ContentView.CCV.11.swift
// - ProfilePopoverView, FlowLayout -> ContentView.CCV.12.swift
// - NoteEditorView -> ContentView.CCV.13.swift
// - DynamicIslandToolbarView -> ContentView.CCV.14.swift
// - RhymeGroupListView -> ContentView.CCV.15.swift