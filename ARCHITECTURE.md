# The Final Journal AI - Component Architecture

## Overview
This document provides a complete understanding of the rhyme engine and core components that power the app's phonetic analysis capabilities.

---

## 🎯 Core Components

### 1. **CMUDICT Dictionary Store** (`FJCMUDICTStore` / `CMUDICTStore`)

**Purpose**: Provides phonetic data for words using the CMU Pronouncing Dictionary format.

**Location**: 
- `FJCMUDICTStore` in `ContentView.swift` (lines 1780-1836)
- `CMUDICTStore` in `CMUDICTStore.swift` (alternative implementation)

**Key Properties**:
- `phonemesByWord: [String: [String]]` - Dictionary mapping words to their phoneme sequences

**How It Works**:
1. On initialization, loads `cmudict.txt` from the app bundle
2. Parses each line: `WORD PHONEME1 PHONEME2 PHONEME3...`
3. Extracts the word (lowercased) and phoneme array
4. Skips comment lines (starting with `;;;`)
5. Falls back to a hardcoded dictionary if file loading fails

**Phoneme Format**:
- Phonemes are strings like `"AY1"`, `"N"`, `"T"`
- Numbers (0, 1, 2) indicate stress:
  - `0` = no stress (schwa/unstressed)
  - `1` = primary stress
  - `2` = secondary stress

**Example**:
```swift
"night": ["N", "AY1", "T"]  // N-sound, stressed AY vowel, T-sound
"light": ["L", "AY1", "T"]  // Same rhyme tail (AY1-T)
```

**Note**: There's a naming inconsistency - `FJCMUDICTStore` is used in the main engine, while `CMUDICTStore` is used in diagnostics. Both should be unified.

---

### 2. **Rhyme Highlighter Engine** (`RhymeHighlighterEngine`)

**Purpose**: The core algorithm that identifies rhyming words and groups them.

**Location**: `ContentView.swift` lines 1176-1286

#### 2.1 **PhoneticSignature**
```swift
struct PhoneticSignature {
    let stressedVowel: String  // The stressed vowel phoneme (e.g., "AY1")
    let coda: [String]         // Phonemes after the stressed vowel (e.g., ["T"])
}
```

**Purpose**: Extracts the "rhyme tail" - the stressed vowel and everything after it. This is what makes words rhyme.

**Example**:
- `"night"` → `PhoneticSignature(stressedVowel: "AY1", coda: ["T"])`
- `"light"` → `PhoneticSignature(stressedVowel: "AY1", coda: ["T"])`
- `"time"` → `PhoneticSignature(stressedVowel: "AY1", coda: ["M"])`

#### 2.2 **RhymeStrength** (Enum)
```swift
enum RhymeStrength: Double {
    case perfect = 1.0   // Exact match: same stressed vowel + same coda
    case near = 0.75     // Same stressed vowel, different coda
    case slant = 0.55    // Currently defined but not fully implemented
}
```

**Classification**:
- **Perfect Rhyme**: `"night"` and `"light"` (both AY1 + T)
- **Near Rhyme**: `"night"` and `"time"` (both AY1, but different codas)
- **Slant Rhyme**: Not currently implemented in scoring

#### 2.3 **RhymeGroup**
```swift
struct RhymeGroup: Identifiable {
    let id: UUID
    let key: String                          // The stressed vowel (used for grouping)
    let strength: RhymeStrength              // Perfect or Near
    let colorIndex: Int                      // Index into RhymeColorPalette
    let words: [RhymeGroupWord]              // All words in this rhyme group
}
```

#### 2.4 **RhymeGroupWord**
```swift
struct RhymeGroupWord: Identifiable {
    let id = UUID()
    let word: String                         // The word text
    let range: Range<String.Index>          // Its position in the source text
}
```

#### 2.5 **Core Algorithm: `computeGroups(text:)`**

**Step-by-Step Process**:

1. **Tokenization**: Uses `NLTokenizer` to split text into words with their ranges
   ```swift
   let tokenizer = NLTokenizer(unit: .word)
   tokenizer.string = text
   // Enumerates: [("night", range), ("light", range), ...]
   ```

2. **Phonetic Extraction**: For each word:
   - Look up phonemes in CMUDICT
   - Extract `PhoneticSignature` (stressed vowel + coda)
   - Skip words not found in dictionary

3. **Bucketing**: Group words by their stressed vowel
   ```swift
   buckets["AY1"] = [
       (RhymeGroupWord("night", range), signature),
       (RhymeGroupWord("light", range), signature),
       ...
   ]
   ```

4. **Group Creation**: For each bucket with 2+ words:
   - Determine strength (perfect if all match exactly, else near)
   - Assign color index based on hash of stressed vowel
   - Create `RhymeGroup` with all words

5. **Filtering**: Only returns groups with multiple words (singles excluded)

#### 2.6 **Highlight Generation: `computeAll(text:)`**

Converts `RhymeGroup`s into `Highlight` objects for visual rendering:

```swift
static func computeAll(text: String) -> ([RhymeGroup], [Highlight]) {
    let groups = computeGroups(text: text)
    var highlights: [Highlight] = []
    for group in groups {
        for wordInfo in group.words {
            highlights.append(Highlight(
                range: wordInfo.range,
                colorIndex: group.colorIndex,
                strength: group.strength
            ))
        }
    }
    return (groups, highlights)
}
```

---

### 3. **Rhyme Engine State** (`RhymeEngineState`)

**Purpose**: Manages caching and async computation of rhyme analysis.

**Location**: `ContentView.swift` lines 1756-1778

**Key Features**:
- **Caching**: Only recomputes when text actually changes (uses hash)
- **Async Processing**: Runs computation off main thread
- **Reactive**: Publishes updates to `@Published` properties

**API**:
```swift
@MainActor
final class RhymeEngineState: ObservableObject {
    @Published var cachedGroups: [RhymeHighlighterEngine.RhymeGroup] = []
    @Published var cachedHighlights: [Highlight] = []
    
    func updateIfNeeded(text: String)  // Triggers recompute if needed
}
```

**Usage in NoteEditorView**:
```swift
@StateObject private var rhymeEngineState = RhymeEngineState()

// Triggers on text change
.onChange(of: item.body) {
    rhymeEngineState.updateIfNeeded(text: item.body)
}
```

---

### 4. **Highlight** (Data Structure)

**Purpose**: Represents a visual highlight for a word in the text.

**Location**: `ContentView.swift` line 1447

```swift
struct Highlight: Equatable {
    let range: Range<String.Index>              // Text range to highlight
    let colorIndex: Int                         // Index into RhymeColorPalette
    let strength: RhymeHighlighterEngine.RhymeStrength  // Perfect/Near/Slant
}
```

**Rendering**: Used by `RhymeHighlightTextView` to apply colored backgrounds to matching words.

---

### 5. **Rhyme Color Palette** (`RhymeColorPalette`)

**Purpose**: Provides consistent color coding for rhyme groups.

**Location**: `ContentView.swift` lines 1163-1172

```swift
enum RhymeColorPalette {
    static let colors: [UIColor] = [
        UIColor(red: 0.94, green: 0.76, blue: 0.20, alpha: 1),  // Yellow
        UIColor(red: 0.94, green: 0.45, blue: 0.35, alpha: 1),  // Coral
        UIColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1),  // Green
        UIColor(red: 0.45, green: 0.64, blue: 0.90, alpha: 1),  // Blue
        UIColor(red: 0.72, green: 0.56, blue: 0.90, alpha: 1),  // Purple
        UIColor(red: 0.90, green: 0.62, blue: 0.78, alpha: 1)   // Pink
    ]
}
```

**Color Assignment**: Each rhyme group gets a color index via:
```swift
let colorIndex = abs(key.hashValue) % RhymeColorPalette.colors.count
```

This ensures consistent coloring for the same stressed vowel across sessions.

---

### 6. **Rhyme Highlight Text View** (`RhymeHighlightTextView`)

**Purpose**: Renders highlighted text overlay showing rhyme groups.

**Location**: `ContentView.swift` lines 1378-1443

**Implementation**: Uses `UIViewRepresentable` to wrap a `UITextView` with attributed text.

**Key Features**:
- Non-editable, non-selectable overlay
- Matches exact font and layout of underlying `TextEditor`
- Applies background colors based on `Highlight` data
- Adjusts opacity based on rhyme strength and dark mode

**Opacity Logic**:
```swift
switch highlight.strength {
case .perfect:
    opacity = isDarkMode ? 0.55 : 0.30
case .near:
    opacity = isDarkMode ? 0.40 : 0.22
case .slant:
    opacity = isDarkMode ? 0.30 : 0.16
}
```

---

## 📊 Analysis Components

### 7. **Syllable Stress Analyzer** (`SyllableStressAnalyzer`)

**Purpose**: Analyzes syllable count and stress patterns in words.

**Location**: `ContentView.swift` lines 1290-1303

**Output**:
```swift
(syllables: Int, stresses: [Int])
// syllables: total syllable count
// stresses: indices of stressed syllables (where stress marker is "1")
```

**Example**:
- `"trying"`: `["T", "R", "AY1", "IH0", "NG"]` → `(syllables: 2, stresses: [0])`
  - First syllable stressed (AY1 has "1")

---

### 8. **Cadence Analyzer** (`CadenceAnalyzer`)

**Purpose**: Analyzes rhythm and flow across lines of poetry.

**Location**: `ContentView.swift` lines 1324-1346

**Output - `CadenceMetrics`**:
```swift
struct CadenceMetrics {
    struct LineMetrics {
        let lineIndex: Int
        let syllableCount: Int
        let stressCount: Int
        let rhymeCount: Int
    }
    let lines: [LineMetrics]
    
    var averageSyllables: Double      // Mean syllables per line
    var syllableVariance: Double      // Variance (rhythm consistency)
}
```

**How It Works**:
1. Splits text into lines
2. For each line:
   - Analyzes each word for syllables and stresses
   - Counts how many words are part of rhyme groups
3. Computes aggregate metrics (average, variance)

**Use Cases**:
- Detecting inconsistent meter
- Identifying rhythmic patterns
- Measuring flow quality

---

### 9. **Rhyme Diagnostics Panel** (`RhymeDiagnosticsPanelView`)

**Purpose**: UI component showing detailed phonetic breakdown of a word.

**Location**: `RhymeDiagnosticsPanelView.swift`

**Features**:
- Displays word being analyzed
- Shows all phonemes in visual capsules
- Computes and displays "rhyme tail" (stressed vowel + coda)

**Current Issue**: Uses `CMUDICTStore.shared` instead of `FJCMUDICTStore.shared` (inconsistency)

---

## 🔄 Data Flow

### Complete Flow: User Types → Highlights Appear

1. **User Types in `NoteEditorView`**
   ```swift
   TextEditor(text: $item.body)
   ```

2. **Text Change Detected**
   ```swift
   .onChange(of: item.body) {
       rhymeEngineState.updateIfNeeded(text: item.body)
   }
   ```

3. **RhymeEngineState Checks Hash**
   - If text hash unchanged → skip
   - If changed → trigger async computation

4. **Async Computation** (off main thread)
   ```swift
   Task.detached {
       let (groups, highlights) = RhymeHighlighterEngine.computeAll(text: text)
       await MainActor.run {
           self.cachedGroups = groups
           self.cachedHighlights = highlights
       }
   }
   ```

5. **RhymeHighlighterEngine.computeAll()**
   - Tokenizes text
   - Looks up phonemes for each word
   - Extracts phonetic signatures
   - Groups words by stressed vowel
   - Generates highlights

6. **UI Updates** (on main thread)
   - `cachedHighlights` published
   - `RhymeHighlightTextView` receives new highlights
   - Overlay re-renders with colored backgrounds

7. **User Toggles Eye Icon**
   ```swift
   isRhymeOverlayVisible.toggle()
   ```
   - Shows/hides the highlight overlay

---

## 🎨 Visual System

### Highlight Rendering

**Perfect Rhyme Example**: "night", "light", "tight", "fight"
- All get same color (e.g., yellow)
- Same opacity (stronger)
- Highlighted as user types

**Near Rhyme Example**: "night" (AY1-T) and "time" (AY1-M)
- Same color (same stressed vowel)
- Lower opacity
- Grouped together in rhyme list

---

## ⚠️ Known Issues / Inconsistencies

1. **Dictionary Store Naming**:
   - `FJCMUDICTStore` used in main engine (`ContentView.swift`)
   - `CMUDICTStore` used in diagnostics (`RhymeDiagnosticsPanelView.swift`)
   - **Recommendation**: Unify to one implementation

2. **Slant Rhyme**:
   - Enum case exists but not implemented in scoring
   - Currently only returns `nil` or `.perfect`/`.near`

3. **Missing Words**:
   - Words not in CMUDICT are silently skipped
   - No user feedback for unknown words

4. **Performance**:
   - Full text re-analyzed on every change
   - Could be optimized with incremental updates

---

## 🚀 Future Enhancement Opportunities

1. **Enhanced Slant Rhyme Detection**: Implement phonetic distance algorithms
2. **Incremental Analysis**: Only recompute changed sections
3. **User Dictionary**: Allow adding custom pronunciations
4. **Rhyme Suggestions**: Suggest words that rhyme with selected word
5. **Meter Analysis**: Detect iambic pentameter, trochaic, etc.
6. **Rhyme Scheme Detection**: Identify ABAB, AABB, etc.
7. **Performance Metrics**: Cache phonetic signatures, preload common words

---

## 📝 Summary

The rhyme engine is a sophisticated phonetic analysis system that:

1. **Loads** the CMU Pronouncing Dictionary
2. **Tokenizes** user text into words
3. **Extracts** phonetic signatures (stressed vowel + coda)
4. **Groups** words by rhyming patterns
5. **Visualizes** groups with color-coded highlights
6. **Provides** detailed analysis tools (syllables, cadence, diagnostics)

All components work together to provide real-time, visual feedback about the rhyme structure of poetry and verse as the user writes.
