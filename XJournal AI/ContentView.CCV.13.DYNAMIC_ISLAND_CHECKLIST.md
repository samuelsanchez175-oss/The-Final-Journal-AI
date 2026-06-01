# DynamicIslandToolbarView Extraction Checklist
## ContentView.CCV.13.swift

### 📋 Pre-Extraction Analysis
- **Location**: ContentView.swift, lines 5966-7107
- **Approximate Size**: ~1,141 lines
- **Dependencies**: 
  - ContentView.CCV.1.swift (CMUDICTStore)
  - ContentView.CCV.2.swift (RhymeModels, GlassSettings)
  - ContentView.CCV.3.swift (RhymeHighlighterEngine)
  - ContentView.CCV.5.swift (KeyboardObserver)
  - ContentView.CCV.6.swift (RhymeHighlightTextView)
  - ContentView.CCV.7.swift (GlassView)

### ✅ Extraction Steps

#### Step 1: Extract Preference Keys
- [ ] Extract `ToolbarFramePreferenceKey` (lines 5968-5973)
  - [ ] Verify PreferenceKey protocol conformance
  - [ ] Include reduce function
  
- [ ] Extract `ButtonFramePreferenceKey` (lines 5975-5980)
  - [ ] Verify PreferenceKey protocol conformance
  - [ ] Include reduce function with merge logic

#### Step 2: Extract Main Struct Definition
- [ ] Extract `DynamicIslandToolbarView` struct declaration (line 5982)
- [ ] Extract all `@Binding` properties:
  - [ ] `isExpanded`
  - [ ] `isRhymeOverlayVisible`
  - [ ] `showDiagnostics`
  - [ ] `keyboardHeight`
  - [ ] `showAudioRecorder`
  - [ ] `showRapSuggestions`
  - [ ] `isShowingRecalled`
  - [ ] `showContextHighlight`
  - [ ] `showAudioImporter`
  - [ ] `showImportNotesInstructions`
  - [ ] `isRewritingLine`
  - [ ] `isImprovingFlow`
  - [ ] `rewriteLineLoadingStep`
  - [ ] `improveFlowLoadingStep`
  - [ ] `showPaywall`
  - [ ] `paywallFeature`
  - [ ] `showAIErrorToast`
  - [ ] `aiErrorMessage`
  - [ ] `showStyleTransferSheet`
  - [ ] `showThemeExpansionSheet`
  - [ ] `showExportSheet`
  - [ ] `isEditorFocused` (FocusState.Binding)

- [ ] Extract all `let` properties:
  - [ ] `rhymeGroups`
  - [ ] `currentText`
  - [ ] `highlights`
  - [ ] `rapSuggestionEngine` (ObservedObject)
  - [ ] `onRewriteLine` closure
  - [ ] `onSuggestRhymes` closure
  - [ ] `onImproveFlow` closure
  - [ ] `onUndo` closure
  - [ ] `onRedo` closure
  - [ ] `onInsertRapSuggestion` closure
  - [ ] `canUndo`
  - [ ] `canRedo`
  - [ ] `insertRapSuggestion` closure
  - [ ] `extractThemes` closure
  - [ ] `showAIError` closure
  - [ ] `item`

- [ ] Extract all `@State` properties:
  - [ ] `showRhymeGroupsPopover`
  - [ ] `rotationAngle`
  - [ ] `showAISparkleSplash`
  - [ ] `autoCollapseTimer`
  - [ ] `buttonPressStates`
  - [ ] `dragOffset`
  - [ ] `isDragging`
  - [ ] `buttonAppearanceDelay`

- [ ] Extract all `@Environment` properties:
  - [ ] `colorScheme`
  - [ ] `accessibilityReduceMotion`

- [ ] Extract `@ObservedObject` properties:
  - [ ] `splashManager` (SplashScreenManager.shared)

#### Step 3: Extract Computed Properties
- [ ] Extract `wordCount` computed property (lines 6050-6052)
- [ ] Extract `rhymeCount` computed property (lines 6054-6056)
- [ ] Extract `isAILoading` computed property (lines 6058-6060)

#### Step 4: Extract Helper Functions
- [ ] Extract `openAudioRecorder()` function (lines 6063-6066)
- [ ] Extract `startAutoCollapseTimer()` function (lines 6069-6089)
- [ ] Extract `cancelAutoCollapseTimer()` function (lines 6091-6094)
- [ ] Extract `enhancedButton()` function (lines 6101-6156)
  - [ ] Include `HapticStyle` enum (lines 6158-6160)
  - [ ] Include all haptic feedback cases
  - [ ] Include button press state management
  - [ ] Include scale effect animations
  - [ ] Include glow overlay logic

#### Step 5: Extract View Components
- [ ] Extract `collapsedStateView` computed property (lines 6163-6180+)
  - [ ] Include expand button
  - [ ] Include accessibility labels
  - [ ] Include long press gesture
  - [ ] Include drag gesture
  
- [ ] Extract `expandedStateView` computed property
  - [ ] Include toolbar container
  - [ ] Include all toolbar buttons
  - [ ] Include button groups
  - [ ] Include loading indicators
  - [ ] Include error states

- [ ] Extract `collapsedButtonContent` computed property
  - [ ] Include word count display
  - [ ] Include rhyme count display
  - [ ] Include AI loading indicator
  - [ ] Include icon and styling

- [ ] Extract all toolbar button views:
  - [ ] Audio recorder button
  - [ ] Rhyme overlay toggle button
  - [ ] AI assist button
  - [ ] Rewrite line button
  - [ ] Suggest rhymes button
  - [ ] Improve flow button
  - [ ] Undo/Redo buttons
  - [ ] Rhyme groups popover button
  - [ ] Diagnostics button
  - [ ] Export button
  - [ ] Style transfer button
  - [ ] Theme expansion button

- [ ] Extract `toolbarButtons` computed property
  - [ ] Include all button groups
  - [ ] Include spacing and layout
  - [ ] Include conditional rendering

#### Step 6: Extract Body Implementation
- [ ] Extract main `body` computed property
  - [ ] Include collapsed/expanded state switching
  - [ ] Include animations
  - [ ] Include keyboard height handling
  - [ ] Include glass effect styling
  - [ ] Include popover presentations
  - [ ] Include sheet presentations
  - [ ] Include onAppear/onDisappear handlers

#### Step 7: Extract Supporting Views
- [ ] Extract any nested view structs
- [ ] Extract any helper view builders
- [ ] Extract any custom modifiers

#### Step 8: Verify Imports
- [ ] Add `import SwiftUI`
- [ ] Add `import UIKit` (if needed for UIApplication, etc.)
- [ ] Add `import Combine` (if needed for Timer)
- [ ] Verify all dependencies are accessible

#### Step 9: Test Compilation
- [ ] Create ContentView.CCV.13.swift file
- [ ] Copy all extracted code
- [ ] Verify no compilation errors
- [ ] Check for missing imports
- [ ] Verify all dependencies resolve correctly

#### Step 10: Update ContentView.swift
- [ ] Remove extracted code from ContentView.swift
- [ ] Add import statement if needed (Swift automatically resolves)
- [ ] Verify ContentView.swift still compiles
- [ ] Test that DynamicIslandToolbarView is accessible

### 🔍 Key Components to Verify

#### State Management
- [ ] All `@Binding` properties properly connected
- [ ] All `@State` properties initialized correctly
- [ ] Timer cleanup in `onDisappear` (structs can't have deinit)

#### Animations
- [ ] Expand/collapse animations work
- [ ] Button press animations work
- [ ] Accessibility reduce motion respected
- [ ] Spring animations configured correctly

#### Interactions
- [ ] All button actions connected
- [ ] Haptic feedback working
- [ ] Long press gestures working
- [ ] Drag gestures working
- [ ] Popover presentations working
- [ ] Sheet presentations working

#### Dependencies
- [ ] RapSuggestionEngine integration
- [ ] HapticFeedbackManager integration
- [ ] SplashScreenManager integration
- [ ] KeyboardObserver integration
- [ ] All CCV file dependencies resolved

### 📝 Notes

- **Timer Management**: Structs cannot have `deinit`, so timer cleanup must be in `onDisappear`
- **Binding Updates**: Some state updates may need `DispatchQueue.main.async` for proper timing
- **Accessibility**: Ensure all buttons have proper accessibility labels and hints
- **Performance**: Button press states use dictionary for efficient lookups
- **Animations**: Respect `accessibilityReduceMotion` for better accessibility

### 🎯 Success Criteria

- [ ] File compiles without errors
- [ ] All functionality preserved
- [ ] No duplicate definitions
- [ ] All dependencies resolved
- [ ] ContentView.swift updated and compiles
- [ ] File size is manageable (< 20KB if possible)

### 📊 Estimated File Size
- **Current**: ~1,141 lines
- **Target**: Split into manageable chunks if needed
- **Consider**: Further splitting if file exceeds 1,500 lines
