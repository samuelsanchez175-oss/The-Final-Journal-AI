# ContentView CCV Files Build Verification

## File Dependencies Map

### CCV.1.swift (CMUDICTStore)
- **Imports**: Foundation
- **Defines**: `FJCMUDICTStore`, `getGlobalCMUDICTStore()`, `preloadGlobalCMUDICTStore()`
- **Dependencies**: None
- **Used by**: CCV.3, ContentView.swift

### CCV.2.swift (RhymeModels)
- **Imports**: SwiftUI, UIKit
- **Defines**: `RhymeColorPalette`, `GlassSettings`, `ScrollOffsetKey`, `JournalDetailPlaceholderView`, `lightHaptic()`
- **Dependencies**: None
- **Used by**: CCV.3, CCV.6, CCV.7, CCV.8, ContentView.swift

### CCV.3.swift (RhymeHighlighterEngine)
- **Imports**: Foundation, NaturalLanguage, UIKit
- **Defines**: `RhymeHighlighterEngine`, `Highlight`, `RhymeEngineState`
- **Dependencies**: CCV.1 (FJCMUDICTStore), CCV.2 (RhymeColorPalette)
- **Used by**: CCV.6, ContentView.swift

### CCV.4.swift (AudioPlayerManager)
- **Imports**: Foundation, AVFoundation, Combine
- **Defines**: `AudioPlayerManager`
- **Dependencies**: None
- **Used by**: ContentView.swift

### CCV.5.swift (KeyboardObserver)
- **Imports**: SwiftUI, Combine, UIKit
- **Defines**: `KeyboardObserver`
- **Dependencies**: None
- **Used by**: ContentView.swift

### CCV.6.swift (RhymeHighlightTextView)
- **Imports**: SwiftUI, UIKit
- **Defines**: `RhymeHighlightTextView`
- **Dependencies**: CCV.2 (RhymeColorPalette), CCV.3 (Highlight)
- **Used by**: ContentView.swift

### CCV.7.swift (GlassEffect)
- **Imports**: SwiftUI
- **Defines**: `GlassView`
- **Dependencies**: CCV.2 (GlassSettings)
- **Used by**: ContentView.swift

### CCV.8.swift (PopoverViews)
- **Imports**: SwiftUI, UIKit
- **Defines**: `BPMPopoverView`, `KeyPopoverView`, `ScalePopoverView`, `URLAttachmentPopoverView`, `FolderPopoverView`
- **Dependencies**: CCV.2 (GlassSettings)
- **Used by**: ContentView.swift

### CCV.9.swift (AuthViews)
- **Imports**: SwiftUI
- **Defines**: `SignInView`, `SignUpView`
- **Dependencies**: AccountManager.swift (external)
- **Used by**: ContentView.swift

## Build Order (Dependencies First)
1. CCV.1.swift (no dependencies)
2. CCV.2.swift (no dependencies)
3. CCV.4.swift (no dependencies)
4. CCV.5.swift (no dependencies)
5. CCV.3.swift (depends on CCV.1, CCV.2)
6. CCV.6.swift (depends on CCV.2, CCV.3)
7. CCV.7.swift (depends on CCV.2)
8. CCV.8.swift (depends on CCV.2)
9. CCV.9.swift (depends on AccountManager.swift)

## Verification Checklist
- [x] All files have correct imports
- [x] Highlight moved to CCV.3.swift (resolves circular dependency)
- [x] UIKit import added to CCV.3.swift (for UIColor/RhymeColorPalette)
- [x] UIKit import added to CCV.8.swift (for GlassSettings usage)
- [x] All cross-file references are valid
- [x] No circular dependencies remain

## Xcode Project Setup
Ensure all CCV files are added to the Xcode project target:
1. Open Xcode project
2. Select each ContentView.CCV.*.swift file
3. In File Inspector, verify "Target Membership" includes your app target
4. Build the project

## Common Issues
1. **Files not in target**: Add files to Xcode project target membership
2. **Compilation order**: Swift handles this automatically, but ensure all files are in same target
3. **Missing types**: Verify AccountManager.swift is in the project
