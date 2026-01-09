# Component Flow Diagram

## Visual Flow: User Types → Rhyme Highlights Appear

```
┌─────────────────────────────────────────────────────────────────┐
│                      NoteEditorView                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  TextEditor(text: $item.body)                             │  │
│  │         ↓                                                   │  │
│  │  User types "I write at night"                            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                      ↓                                           │
│  .onChange(of: item.body) {                                     │
│      rhymeEngineState.updateIfNeeded(text: item.body)           │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                  RhymeEngineState                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  1. Check hash: text.hashValue != lastTextHash?          │  │
│  │  2. If changed → Task.detached { computeAsync() }        │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│              RhymeHighlighterEngine.computeAll()                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Step 1: Tokenize Text                                    │  │
│  │    NLTokenizer → [("i", range), ("write", range),         │  │
│  │                    ("at", range), ("night", range)]        │  │
│  │                                                            │  │
│  │  Step 2: Lookup Phonemes                                  │  │
│  │    FJCMUDICTStore.shared.phonemesByWord:                  │  │
│  │    "write" → ["R", "AY1", "T"]                            │  │
│  │    "night" → ["N", "AY1", "T"]                            │  │
│  │                                                            │  │
│  │  Step 3: Extract Signatures                               │  │
│  │    "write" → PhoneticSignature(stressedVowel: "AY1",      │  │
│  │                                coda: ["T"])                │  │
│  │    "night" → PhoneticSignature(stressedVowel: "AY1",      │  │
│  │                                coda: ["T"])                │  │
│  │                                                            │  │
│  │  Step 4: Group by Stressed Vowel                          │  │
│  │    buckets["AY1"] = [                                     │  │
│  │      (RhymeGroupWord("write", range1), sig1),             │  │
│  │      (RhymeGroupWord("night", range2), sig2)              │  │
│  │    ]                                                       │  │
│  │                                                            │  │
│  │  Step 5: Create RhymeGroups                               │  │
│  │    RhymeGroup(                                            │  │
│  │      key: "AY1",                                          │  │
│  │      strength: .perfect,  // Both have AY1+T              │  │
│  │      colorIndex: 2,                                       │  │
│  │      words: [word1, word2]                                │  │
│  │    )                                                       │  │
│  │                                                            │  │
│  │  Step 6: Generate Highlights                              │  │
│  │    [Highlight(range1, colorIndex: 2, strength: .perfect),│  │
│  │     Highlight(range2, colorIndex: 2, strength: .perfect)] │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│              Back to Main Thread (MainActor)                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  rhymeEngineState.cachedGroups = groups                   │  │
│  │  rhymeEngineState.cachedHighlights = highlights           │  │
│  │                                                            │  │
│  │  @Published properties trigger SwiftUI updates            │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    UI Rendering                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  ZStack {                                                  │  │
│  │    TextEditor(text: $item.body)  // Base layer           │  │
│  │                                                            │  │
│  │    if isRhymeOverlayVisible {                             │  │
│  │      RhymeHighlightTextView(                               │  │
│  │        text: item.body,                                    │  │
│  │        highlights: computedHighlights  // ← Updated!      │  │
│  │      )                                                     │  │
│  │      // Overlay layer with colored backgrounds            │  │
│  │    }                                                       │  │
│  │  }                                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Visual Output                                 │
│                                                                  │
│  I write at night                                                │
│     └─┐      └──┐                                               │
│       │         │  ← Same color (green)                         │
│       │         │  ← Highlighted background                     │
│    [AY1-T]  [AY1-T] ← Same phonetic signature                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Detailed Component Interactions

### 1. Dictionary Lookup Flow

```
Word: "night"
  ↓
FJCMUDICTStore.shared.phonemesByWord["night"]
  ↓
["N", "AY1", "T"]
  ↓
extractSignature(phonemes: ["N", "AY1", "T"])
  ↓
PhoneticSignature(
  stressedVowel: "AY1",  // Last phoneme with number (stress marker)
  coda: ["T"]            // Everything after stressed vowel
)
```

### 2. Rhyme Matching Flow

```
"write": ["R", "AY1", "T"]  → Signature("AY1", ["T"])
"night":  ["N", "AY1", "T"]  → Signature("AY1", ["T"])
"light":  ["L", "AY1", "T"]  → Signature("AY1", ["T"])
"time":   ["T", "AY1", "M"]  → Signature("AY1", ["M"])

↓ Bucketing by stressedVowel

buckets["AY1"] = [
  (write, Signature("AY1", ["T"])),
  (night, Signature("AY1", ["T"])),
  (light, Signature("AY1", ["T"])),
  (time, Signature("AY1", ["M"]))
]

↓ Scoring

write vs night: same vowel + same coda → .perfect ✓
write vs light: same vowel + same coda → .perfect ✓
write vs time:  same vowel + diff coda → .near ✓

↓ Grouping

If all entries have same coda → .perfect group
If mixed codas → .near group

Result: Two groups
  Group 1: [write, night, light] - .perfect (all AY1+T)
  Group 2: [time] - excluded (only one word)
```

### 3. Color Assignment Flow

```
RhymeGroup(key: "AY1", ...)
  ↓
colorIndex = abs("AY1".hashValue) % 6
  ↓
Example: hashValue % 6 = 2
  ↓
RhymeColorPalette.colors[2]
  ↓
UIColor(red: 0.48, green: 0.78, blue: 0.64) // Green
  ↓
All words in this group get green highlight
```

### 4. Highlight Rendering Flow

```
Highlight(
  range: Range<String.Index> (position of "night" in text),
  colorIndex: 2,
  strength: .perfect
)
  ↓
RhymeHighlightTextView.updateUIView()
  ↓
NSMutableAttributedString with background color
  ↓
baseColor = RhymeColorPalette.colors[2]  // Green
opacity = isDarkMode ? 0.55 : 0.30  // Based on .perfect strength
  ↓
attributed.addAttribute(
  .backgroundColor,
  value: green.withAlphaComponent(0.30),
  range: NSRange(...)
)
  ↓
UITextView displays colored background overlay
```

---

## Component Dependency Graph

```
NoteEditorView
  ├── RhymeEngineState (manages state)
  │     └── RhymeHighlighterEngine (computes rhymes)
  │           ├── FJCMUDICTStore (provides phonemes)
  │           ├── NLTokenizer (tokenizes text)
  │           └── PhoneticSignature (extracts rhyme patterns)
  │
  ├── RhymeHighlightTextView (renders highlights)
  │     └── Highlight (data for each word)
  │           └── RhymeColorPalette (color assignment)
  │
  └── DynamicIslandToolbarView
        ├── RhymeGroupListView (shows rhyme groups)
        └── Eye toggle (controls overlay visibility)

Supporting Components:
  ├── SyllableStressAnalyzer
  │     └── FJCMUDICTStore
  │
  ├── CadenceAnalyzer
  │     └── SyllableStressAnalyzer
  │
  └── RhymeDiagnosticsPanelView
        └── CMUDICTStore (⚠️ naming inconsistency)
```

---

## Key Algorithms

### extractSignature Algorithm

```
Input: phonemes = ["N", "AY1", "T"]

1. Find last index where phoneme ends with number (stress marker)
   idx = 1  (AY1 has "1" at end)

2. Extract stressed vowel
   vowel = phonemes[idx] = "AY1"

3. Extract coda (everything after stressed vowel)
   coda = Array(phonemes.dropFirst(idx + 1))
        = Array(["N", "AY1", "T"].dropFirst(2))
        = ["T"]

4. Return PhoneticSignature(stressedVowel: "AY1", coda: ["T"])
```

### rhymeScore Algorithm

```
Input: sigA = PhoneticSignature("AY1", ["T"])
       sigB = PhoneticSignature("AY1", ["M"])

1. Check if perfect match
   if sigA.stressedVowel == sigB.stressedVowel && 
      sigA.coda == sigB.coda:
      return .perfect
   
   → "AY1" == "AY1" ✓ but ["T"] != ["M"] ✗
   
2. Check if near match
   if sigA.stressedVowel == sigB.stressedVowel:
      return .near
   
   → "AY1" == "AY1" ✓
   → return .near

Result: .near (same stressed vowel, different coda)
```

### computeGroups Algorithm

```
Input: text = "I write at night"

1. Tokenize: [("i", r1), ("write", r2), ("at", r3), ("night", r4)]

2. For each token:
   "write" → phonemes: ["R", "AY1", "T"]
           → signature: ("AY1", ["T"])
           → bucket["AY1"].append((word, sig))
   
   "night" → phonemes: ["N", "AY1", "T"]
           → signature: ("AY1", ["T"])
           → bucket["AY1"].append((word, sig))
   
   ("i", "at" skipped - not in dictionary or no signature)

3. Resulting buckets:
   buckets = {
     "AY1": [
       (RhymeGroupWord("write", r2), Signature("AY1", ["T"])),
       (RhymeGroupWord("night", r4), Signature("AY1", ["T"]))
     ]
   }

4. For each bucket with count > 1:
   - key = "AY1"
   - entries = [write, night]
   - Check if all entries have same coda
     → ["T"] == ["T"] ✓
   - strength = .perfect (all match)
   - colorIndex = abs("AY1".hashValue) % 6 = 2
   - Create RhymeGroup(key: "AY1", strength: .perfect, 
                       colorIndex: 2, words: [write, night])

5. Return: [RhymeGroup(...)]
```

---

## Performance Considerations

### Current Implementation
- ✅ Async computation (off main thread)
- ✅ Hash-based caching (only recomputes on change)
- ❌ Full text re-analysis on every change
- ❌ No incremental updates

### Optimization Opportunities
1. **Incremental Analysis**: Only re-analyze changed words
2. **Word-Level Caching**: Cache phonetic signatures per word
3. **Debouncing**: Wait for pause in typing before analysis
4. **Background Preloading**: Preload common words at startup
