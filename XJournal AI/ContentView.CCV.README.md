# ContentView Split Files (CCV Numbering System)

This document explains the ContentView.swift file split and the CCV numbering system used to organize the extracted components.

## File Organization

The original `ContentView.swift` (8,489 lines) has been split into numbered files for easier processing and token management:

### Foundational Components

- **ContentView.CCV.1.swift** - CMUDICT Dictionary Store
  - `FJCMUDICTStore` class
  - Global accessor functions (`getGlobalCMUDICTStore`, `preloadGlobalCMUDICTStore`)

- **ContentView.CCV.2.swift** - Rhyme Models & Types
  - `RhymeColorPalette` enum
  - `GlassSettings` enum
  - `ScrollOffsetKey` PreferenceKey
  - `JournalDetailPlaceholderView`
  - `Highlight` struct
  - `lightHaptic()` helper function

- **ContentView.CCV.3.swift** - Rhyme Highlighter Engine
  - `RhymeHighlighterEngine` struct with all rhyme detection logic
  - `RhymeEngineState` class (ObservableObject)

### Manager Classes

- **ContentView.CCV.4.swift** - Audio Player Manager
  - `AudioPlayerManager` class

- **ContentView.CCV.5.swift** - Keyboard Observer
  - `KeyboardObserver` class

### View Components

- **ContentView.CCV.6.swift** - Rhyme Highlight Text View
  - `RhymeHighlightTextView` (UIViewRepresentable)

- **ContentView.CCV.7.swift** - Glass Effect
  - `GlassView` component

- **ContentView.CCV.8.swift** - Popover Views
  - `BPMPopoverView`
  - `KeyPopoverView`
  - `ScalePopoverView`
  - `URLAttachmentPopoverView`
  - `FolderPopoverView`

- **ContentView.CCV.9.swift** - Authentication Views
  - `SignInView`
  - `SignUpView`

### Main File

- **ContentView.swift** - Main entry point (still contains large views)
  - `ContentView` struct (main entry)
  - `JournalLibraryView` (Page 1)
  - `NoteEditorView` (Page 2)
  - `DynamicIslandToolbarView` (Page 3)
  - Other large view components (to be extracted in future)

## Usage

All files use standard Swift imports and can be processed independently. The numbering system (CCV.1 through CCV.9) makes it easy to:
- Process files in order
- Identify which component is in which file
- Manage token limits when processing individual files

## Dependencies

Files depend on each other in this order:
1. CCV.1 (CMUDICTStore) - No dependencies
2. CCV.2 (RhymeModels) - No dependencies
3. CCV.3 (RhymeHighlighterEngine) - Depends on CCV.1, CCV.2
4. CCV.4-9 - Depend on CCV.1-3 and each other as needed

## Notes

- All extracted files compile without errors
- The main `ContentView.swift` still contains large views that can be extracted later
- Files are numbered sequentially for easy reference
- CCV prefix stands for "ContentView" to maintain file grouping
