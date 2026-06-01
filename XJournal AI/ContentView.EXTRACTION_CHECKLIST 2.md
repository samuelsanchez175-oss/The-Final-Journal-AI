# ContentView.swift Extraction Checklist

## ✅ Completed Extractions

- [x] **ContentView.CCV.1.swift** - CMUDICT Dictionary Store
- [x] **ContentView.CCV.2.swift** - Rhyme Models & Types
- [x] **ContentView.CCV.3.swift** - Rhyme Highlighter Engine
- [x] **ContentView.CCV.4.swift** - Audio Player Manager
- [x] **ContentView.CCV.5.swift** - Keyboard Observer
- [x] **ContentView.CCV.6.swift** - Rhyme Highlight Text View
- [x] **ContentView.CCV.7.swift** - Glass Effect
- [x] **ContentView.CCV.8.swift** - Popover Views
- [x] **ContentView.CCV.9.swift** - Authentication Views

## 🔄 Remaining Extractions

### Page 1: Journal Library Components
- [ ] **ContentView.CCV.10.swift** - JournalLibraryView
  - [ ] Extract `JournalLibraryView` struct (starts line 1608)
  - [ ] Extract `Page1Filter` enum (line 2653)
  - [ ] Extract `JournalListView` struct (line 2671)
  - [ ] Extract `JournalRowView` struct (line 2705)
  - [ ] Extract `JournalEmptyStateView` struct (line 2840)
  - [ ] Include all helper functions and computed properties
  - [ ] Verify imports: SwiftUI, SwiftData, UIKit, Combine
  - [ ] Test compilation

### Page 1.1: Profile Components
- [ ] **ContentView.CCV.11.swift** - Profile Views
  - [ ] Extract `ProfilePopoverView` struct (line 2879)
  - [ ] Extract `UserPersonalDetails` struct (line 2869)
  - [ ] Extract `UsageInfoRow` struct (line 3829)
  - [ ] Extract `PreferencesInfoView` struct (line 3848)
  - [ ] Extract `StorageInfoView` struct (line 3886)
  - [ ] Extract `UserPersonalizationSheet` struct (line 3960)
  - [ ] Extract `FlowLayout` Layout struct (line 4153)
  - [ ] Extract `ProfilePopoverView` extension helpers (line 4207)
  - [ ] Verify imports and dependencies
  - [ ] Test compilation

### Page 2: Note Editor
- [ ] **ContentView.CCV.12.swift** - NoteEditorView
  - [ ] Extract `NoteEditorView` struct (line 4283)
  - [ ] Include all state variables and computed properties
  - [ ] Include all helper functions (AI text highlights, context highlights, etc.)
  - [ ] Include undo/redo history management
  - [ ] Include rap suggestion integration
  - [ ] Verify imports: SwiftUI, SwiftData, NaturalLanguage, AVFoundation, Speech, PhotosUI
  - [ ] Test compilation

### Page 3: Dynamic Island Toolbar ⭐
- [ ] **ContentView.CCV.13.swift** - DynamicIslandToolbarView (See detailed checklist below)
  - [ ] Extract `ToolbarFramePreferenceKey` (line 5968)
  - [ ] Extract `ButtonFramePreferenceKey` (line 5975)
  - [ ] Extract `DynamicIslandToolbarView` struct (line 5982)
  - [ ] Include all state variables
  - [ ] Include all computed properties
  - [ ] Include all helper functions
  - [ ] Include all view components (collapsed/expanded states)
  - [ ] Verify imports and dependencies
  - [ ] Test compilation

### Page 3.5: Rhyme Group List
- [ ] **ContentView.CCV.14.swift** - RhymeGroupListView
  - [ ] Extract `RhymeGroupListView` struct (line 7113)
  - [ ] Include all helper functions
  - [ ] Include device-aware sizing logic
  - [ ] Verify imports
  - [ ] Test compilation

### Audio Components
- [ ] **ContentView.CCV.15.swift** - Audio Views
  - [ ] Extract `AudioPlayerView` struct (line 7398)
  - [ ] Extract `WaveformView` struct (line 7508)
  - [ ] Extract `TimestampedTranscriptView` struct (line 7575)
  - [ ] Extract `AudioDetailSheet` struct (line 7625)
  - [ ] Extract `FindInTranscriptView` struct (line 7929)
  - [ ] Verify imports: SwiftUI, AVFoundation
  - [ ] Test compilation

### Supporting Views
- [ ] **ContentView.CCV.16.swift** - Supporting Views
  - [ ] Extract `FolderSelectionSheetView` struct (line 8105)
  - [ ] Extract any remaining utility views
  - [ ] Verify imports
  - [ ] Test compilation

### Final Cleanup
- [ ] Remove all extracted components from ContentView.swift
- [ ] Update ContentView.swift imports to reference CCV files
- [ ] Verify ContentView.swift compiles with minimal code
- [ ] Update ContentView.CCV.README.md with final file list
- [ ] Run full project compilation test
- [ ] Verify no duplicate definitions

## Notes

- Each extracted file should be numbered sequentially (CCV.10, CCV.11, etc.)
- All files should include necessary imports
- Test compilation after each extraction
- Maintain original functionality and dependencies
