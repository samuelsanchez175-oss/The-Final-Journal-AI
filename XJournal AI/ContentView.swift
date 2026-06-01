import SwiftUI
import SwiftData
import UIKit
import Combine
import NaturalLanguage
import AVFoundation
import Speech
import PhotosUI

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
// Page 3    — Keyboard Bottrom Dynamic Island Toolbar
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

// Segment 6 — Editorial Symbol Tiles
// Notes-style editorial symbol tiles used in release notes and announcements.
// Uses SF Symbols rendered inside soft glass cards instead of image assets.
// Ensures zero asset dependency, consistent loading, and system-native polish.
// Supports versioned feature cards with icon + text pairings.

// =======================================================
// MARK: - PAGE 1: Journal Library
// =======================================================
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedImportedItem: Item?

    var body: some View {
        JournalLibraryView(selectedImportedItem: $selectedImportedItem)
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
