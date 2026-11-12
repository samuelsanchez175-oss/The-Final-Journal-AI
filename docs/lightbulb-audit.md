# Rhyme Groups lightbulb audit

Read-only pass of the editor magnifying glass and the Rhyme Groups lightbulb. Source opened under `XJournal AI/`. `docs/rhymes/` was not opened. No Swift, project, or data file was edited. No build, simulator, or phone.

The lightbulb and the hold-word "Suggest Rhymes" sheet are different controls. The lightbulb lives only in `RhymeGroupListView`. The sheet is `RhymeSuggestionView`, opened by holding a word.

## 1. Magnifying glass and the Rhyme Groups panel

Editor toolbar type: `DynamicIslandToolbarView` in `XJournal AI/ContentView.CCV.14.swift`. The note page that owns it is `NoteEditorView` in `XJournal AI/ContentView.CCV.13.swift`. The panel type is `RhymeGroupListView` in `XJournal AI/ContentView.CCV.15.swift`.

The magnifying glass is a plain button, SF Symbol `text.magnifyingglass`. Tap sets `showRhymeGroupsPopover = true` and starts the toolbar auto-collapse timer. Accessibility label is "Rhyme groups". Hint is "Shows each rhyme family and its color". While the popover is up, the icon uses `RhymeColorPalette.color(at: 4)`.

```797:815:XJournal AI/ContentView.CCV.14.swift
Button {
    HapticFeedbackManager.shared.lightTap()
    isEditorFocused = false
    showRhymeGroupsPopover = true
    startAutoCollapseTimer()
} label: {
    Image(systemName: "text.magnifyingglass")
        // ...
}
.accessibilityLabel("Rhyme groups")
.accessibilityHint("Shows each rhyme family and its color")
```

The same flag is also set from the eye popover row titled "Rhyme groups" (`ContentView.CCV.14.swift` 285–288). One popover serves both:

```304:310:XJournal AI/ContentView.CCV.14.swift
.popover(isPresented: $showRhymeGroupsPopover, arrowEdge: .bottom) {
    RhymeGroupListView(
        groups: rhymeGroups,
        currentText: currentText
    )
    .presentationCompactAdaptation(.popover)
}
```

`NoteEditorView.bottomToolbar` (`ContentView.CCV.13.swift` 1635–1641) passes `rhymeEngineState.groups(for: item.body)` and `item.body`.

A second magnifying glass, labeled "Groups", is `RapIslandToolbar.groupsButton` in `XJournal AI/RapIslandToolbar.swift` 65–82. That island sits on the Rap Suggestions screen. It opens the same `RhymeGroupListView`. The editor control is the one in `DynamicIslandToolbarView`.

Splash tour copy for this button is `SplashScreenID.toolbarMagnifyingGlass` (`SplashScreenManager.swift` 132, 154) and the blurb in `ContentView.CCV.13.swift` 3866–3870: "See every rhyme family in your verse and explore related words."

Panel chrome (`ContentView.CCV.15.swift`):

- Title button "Rhyme Groups" plus `arrow.up.arrow.down` toggles sort (`isSortReversed`).
- Lightbulb button toggles `showSuggestions`. Outline `lightbulb` when off, `lightbulb.fill` in blue when on. No accessibility label.
- Each row is `groupRowView`. Header is `groupHeaderTitle`: "End N" or "Internal N".
- Member words are the unique spellings, sorted A–Z, joined with ` · `, painted with `RhymeColorPalette.color(at: group.colorIndex)`.
- Empty list copy is "No rhymes found."
- Popover width is 85% of the screen up to 400 pt on compact, else 520. Max height is 60% of the screen up to 500.

```176:182:XJournal AI/ContentView.CCV.15.swift
private func groupHeaderTitle(index: Int, group: RhymeHighlighterEngine.RhymeGroup) -> String {
    let isInternal = group.rhymeType == .internalRhyme
    let kind = isInternal ? "Internal" : "End"
    let ordinal = orderedGroups.prefix(index + 1).filter {
        ($0.rhymeType == .internalRhyme) == isInternal
    }.count
    return "\(kind) \(ordinal)"
}
```

Any `rhymeType` other than `.internalRhyme` is labeled "End". That includes assonance groups, which the engine stores as `.endRhyme` (`ContentView.CCV.3.swift` 1462–1470).

## 2. How groups are built from typed text

Engine: `nonisolated struct RhymeHighlighterEngine` in `XJournal AI/ContentView.CCV.3.swift`.

Pipeline when the eye’s Rhymes highlight is on:

1. `NoteEditorView.handleBodyChange` (`ContentView.CCV.13.swift` 1903–1904) calls `RhymeEngineState.updateIfNeeded`.
2. That waits 50 ms (`debounceDelay`, `ContentView.CCV.3.swift` 1642), then `RhymeHighlighterEngine.computeAll`.
3. `computeAll` → `computeGroups` → `groupsFromAnnotatedTokens` → `lockColorIndices`.
4. `armWritingTools` (`ContentView.CCV.13.swift` 247–264) also calls `refreshImmediately` and, off the main actor, `preloadGlobalCMUDICTStore()` plus `RhymeFinder.warmIndex()`.

### Tokenizing

`tokenizeWords(in:)` (414–424) uses `NLTokenizer(unit: .word)`, lowercases each token, merges bare digit runs that the tokenizer skipped (`mergeDigitTokens`), and appends the in-progress last word (`appendTrailingInProgressWord` / `trailingInProgressWord`) so a word still being typed can join.

`annotatedTokens` (569–618) drops tokens that fail `keepsRhymeToken` (196–199): the stopword set at 35–39 (`a`, `an`, `the`, `of`, `to`, … `yeah`, `got`), and any token shorter than 2 characters unless it is all digits. Digits are spelled with `spokenDigitWords` ("8" → "eight", "21" → "twenty one") and looked up as those words. Each kept token needs a `PhoneticSignature` from `phonemes(for:)` + `extractSignature`. Line index is a newline count before the range. `isLineEnd` comes from `lineEndTokenIndices` (1541–1556): the last kept token on each line.

### Phonemes

`phonemes(for:)` (218–238), in order:

1. Spelled-out digits.
2. If the word is in `lockedSlantEndFamily` (`militant`, `idiot`, `immigrant`, `commits`, `script`, `shit`), the slang table wins.
3. `getGlobalCMUDICTStore()` then `FJCMUDICTStore.shared.phonemesByWord`. Those two calls are the same dictionary.
4. `RapSlangPhonemes.phonemes(for:)`.
5. `RapSlangPhonemes.heuristicPhonemes(for:)` — letter-to-sound, words of 3+ letters only.
6. Locked slant family with no other hit returns `["IH1", "T"]`.
7. Otherwise the word is dropped and cannot start a group.

`dictionaryPhonemes` (670–683) is the stricter lookup used for syllable slices. It stops at the slang table and does not use the letter heuristic.

`extractSignature` (291–297) takes the last vowel whose stress digit is 1 or 2, plus the coda after it. A trailing unstressed vowel (the `IY0` in "crazy") is not the rime. No stressed vowel means no signature.

`PhoneticSignature.rimeKey` (46–49) is `VOWEL` or `VOWEL|CODA-CODA`, stress digits stripped.

### End versus internal

`groupsFromAnnotatedTokens` (1063–1211):

- **End.** Line-end tokens are bucketed by `endGroupKey(for:signature:isLineEnd: true)`. A bucket becomes `.endRhyme` when it has 2+ occurrences or 2+ distinct spellings (1081–1088). One lone end word does not open a group.
- **Internal, same bar.** Union-find joins every pair on the same line whose `rhymeScore` is non-nil, including assonance (1107–1122). The component takes the highest `keyRank` among member keys (1146–1156). End-family keys outrank a bare vowel.
- **Internal, joining an end family.** A mid-bar token whose off-end key already names an end group or an internal bucket is added as `.internalRhyme` (1163–1169).
- **Internal, same family across lines.** Leftover tokens that share an off-end key, 2+ times, become `.internalRhyme` (1172–1185). This is the `cheat` / `reach` path.
- **Cluster pass.** `appendEngineInternalGroups` (1216–1254) asks `RhymeClusterEngine.detect` (`FlowDNA/RhymeClusterEngine.swift`) for clusters with `type == "internal"` and adds any spans not already covered.
- **Assonance leftovers.** `appendAssonanceGroups` (1405–1473) groups still-free tokens that score `.assonance` on the same stressed vowel. Those groups are stored as `.endRhyme`, so the panel labels them "End".
- **Merge.** `mergeSharedFinalConsonant` (1318–1400) folds groups that share vowel + last consonant. If any piece was an end group, the merge stays `.endRhyme`.
- **Syllable slices.** `attachSyllableSlices` (976–1028) can paint a stressed inner syllable (`maintained` → `tained`) into an existing group, or seed a new `.internalRhyme` on a perfect syllable match.

`endGroupKey` (101–131) is the bucket id, and it is wider than the raw rime:

| Condition | Key |
| --- | --- |
| `blink` / `think` / `pink` / `link` / `sink` / `drink` / `ink` | raw `rhymeClassId` (kept out of the shit family) |
| locked slant list | `IH\|ALVSTOP` |
| trailing unstressed `IY` (`dummy` / `money`, `pretty` / `chelly`) | vowel family + `\|Y` (`IH-EH\|Y` or `AH\|Y`) |
| `IY` or `IH` ending T or CH (`cheat` / `reach`) | `IY\|TCH` or `IH\|TCH` |
| line-end IH/IY + T/D, or any line-end alveolar T/D | `IH\|ALVSTOP` |
| one P/B/K/G after stripping plural S/Z, no `NG` | `VOWEL\|STOP-PBGK` |
| everything else | `rhymeClassId` (`AY\|D`, or a bare vowel) |

`rhymeScore` (377–401): perfect = same stressed vowel and same coda; near = same vowel and similar coda, or the same vowel with a consonant tail (`girl` / `world`); slant = similar vowels (`AY`/`EY`, `OW`/`AW`/`AO`, …) with equal or similar codas; assonance = same vowel and consonant-only codas. `man` / `manage` stays dark because the extra vowel is a new syllable.

Colors are `colorIndex(forRhymeClass:)` (243–259): `OW` + `N` is palette index 2, the alveolar-stop class is index 1, otherwise djb2 of the key mod 6. `lockColorIndices` (1482–1492) writes that onto the group. Group `id` is a new `UUID` on every rebuild.

## 3. The lightbulb

Tap toggles `@State showSuggestions` (`ContentView.CCV.15.swift` 98–104). Nothing is fetched, cached, or written. The flag dies when the popover is dismissed.

While it is on, every row calls `findRhymeSuggestions(for:)` during `body`.

```185:239:XJournal AI/ContentView.CCV.15.swift
private func findRhymeSuggestions(for group: RhymeHighlighterEngine.RhymeGroup) -> [String] {
    let wordsInText = Set(
        RhymeHighlighterEngine.tokenizeWords(in: currentText).map { $0.0.lowercased() }
    )
    guard let firstWord = group.words.first,
          let phonemes = RhymeHighlighterEngine.phonemes(for: firstWord.word),
          let groupSignature = RhymeHighlighterEngine.extractSignature(from: phonemes) else {
        return []
    }
    let dict = FJCMUDICTStore.shared.phonemesByWord
    // perfect, then near; slant and assonance are dropped
    // break once perfectRhymes.count >= 7
    let allSuggestions = perfectRhymes + nearRhymes
    return Array(allSuggestions.prefix(7)).sorted()
}
```

Source of the words: `FJCMUDICTStore.shared.phonemesByWord` only. That is the bundled `cmudict.txt`. The scan does not read the slang table, the letter heuristic, an LLM, Datamuse, `BarHitsCatalog`, or `CatalogEndWordIndex`.

Seed: `group.words.first`, the first member appended while grouping (text order for an end bucket), then `phonemes(for:)` so a slang or heuristic pronunciation can seed the scan. The group's `key` is not used. A family keyed `IH|ALVSTOP` still suggests from whichever member was appended first.

Filter, in hash order of the dictionary:

- Skip words already in the note (`tokenizeWords`, so stopwords in the text are excluded too).
- Skip words already in this group.
- `RhymeHighlighterEngine.rhymeScore`: keep `.perfect` and `.near`. Drop `.slant` and `.assonance`.
- `word.capitalized` for display.
- Stop the scan once 7 perfects have been appended. Near rhymes seen before that stop are kept. The rest of the dictionary is never scored.
- `prefix(7)` takes perfects first, then nears. `.sorted()` then alphabetizes those 7, so the row does not show strength order.

There is no frequency rank, syllable rank, usable-headword filter, or artist rank. CMU noise keys such as `a(2)` stay eligible. The loader stores alternate pronunciations as their own keys (`a(2) EY1` is a real line in `cmudict.txt`).

Count shown: at most 7 per group.

Display (`ContentView.CCV.15.swift` 166–171): one blue `.callout` `Text`, words joined with ` · `, wrapping on. They are not buttons.

Tapping a suggestion does nothing. There is no gesture and no insert path on this view.

The hold-word sheet is the control that inserts. `NoteEditorView.presentRhymes` (`ContentView.CCV.13.swift` 3502–3515) calls `RhymeFinder.findRhymes(for:limit: 160)` and presents `RhymeSuggestionView`. `onSelect` calls `insertRhymeWord` (3543–3578), which replaces the held range or the last word of the last line. That sheet also calls Datamuse (`RhymeSuggestionView.loadExtras`, 260–268). The lightbulb never calls it.

## 4. The sort button

One toggle. No menu and no named modes.

`orderedGroups` (`ContentView.CCV.15.swift` 59–77):

- Default: end groups first (`typeRank` 0), internal groups after (`typeRank` 1). Inside a type, the group whose earliest word range starts first comes first.
- `isSortReversed == true`: that array is reversed.
- Header numbers are recomputed from the visible order. After a reverse, "End 1" is whichever end group landed at the top, not a stable id.

`isSortReversed` is `@State`. It is not `@AppStorage`. Closing the popover resets it.

The hit target is the whole "Rhyme Groups" row, title included, not only the icon (82–94).

## 5. Data and state

| Piece | Where | What it holds |
| --- | --- | --- |
| `RhymeEngineState` | `ContentView.CCV.3.swift` 1630. Owned by `@StateObject` on `NoteEditorView` (`ContentView.CCV.13.swift` 72) | `@Published cachedGroups`, `cachedHighlights`, `wordSignatureCache`, 50 ms debounce, generation counter so a late compute cannot overwrite a newer one |
| `RhymeGroupListView` | `ContentView.CCV.15.swift` 19–20 | `isSortReversed`, `showSuggestions`. Both local. No store |
| `FJCMUDICTStore.shared` | `FJCMUDICTStore.swift` | Process-wide phoneme map. `NSLock`. Load once |
| `RhymeFinder.cachedLookup` | `RhymeSuggestionView.swift` 339–362 | Perfect / near / slant maps for the hold-word sheet and Ghost. The lightbulb does not read them |
| Ghost dock | `ContentView.CCV.13.swift` 508–523 | `@AppStorage("ghost_bar_mode")`, `ghostPool`, `ghostRhymeKey`, `liveRhymeCache`. Separate from the lightbulb |

`groups(for:)` (1730–1731) returns `cachedGroups` and ignores the text argument. During the 50 ms debounce the panel can show the previous verse. `highlights(for:)` remaps spans across the in-flight edit. The group list does not.

`refreshImmediately` (1735–1741) returns without computing when `getGlobalCMUDICTStore()` is empty. `RhymeEngineState.init` observes `.cmudictDidFinishLoading` and retries (`retryIfNeededAfterDictionaryLoad`, 1683–1688). A memory warning clears `wordSignatureCache` only.

`@AppStorage` on the editor that touches rhyme paint, and none of them remember the bulb or the sort:

- `defaultRhymeOverlayVisible` — eye Rhymes (`EyeOverlayFilter.swift` 20)
- `editor_setup_and_punch_highlight`
- `editor_technique_highlight`
- `ghost_bar_mode` (`GhostMode.storageKey`)
- `barHits.opensFromHold`
- `toolbar_ai_last_suggestion_model` on the toolbar

Artist-aware pieces already in the editor, none of them feeding the lightbulb:

- **Blocks.** Toolbar label "Blocks" (`ContentView.CCV.14.swift` 629–643) opens `NounBankSheet`. The sheet has an artist pill (`fosArtist` / `FigurativeSpeech.artists`) and `NounArtistFilterSheet`. Choosing a chip calls `insertNounBankWord` (`ContentView.CCV.13.swift` 3518–3529), which inserts the word at the caret. That is the chip bank.
- **Bar Hits / Reminds me of.** `RemindsMeOfService` on the note. Catalog rows carry `artist`. `BarHitsCatalogStore.artistNames()`, `bars(forSong:artist:)`, and `popularEndWords(phoneticClass:)` exist. Ghost’s `freeRhymePool` uses the catalog. The lightbulb does not.
- **Free Ghost index.** `CatalogEndWordIndex` (`CatalogEndWordIndex.swift`) stores word, phones, rhyme class, `artistId`, song, wrap. Persisted as `CatalogEndWordIndex-v1.json`. Ghost reads `snapshotWords(matchingRhymeClass:)`. The lightbulb does not.
- **Vault.** `RemindsMeOfVault` (`RemindsMeOf/RemindsMeOfVault.swift`) is the growing CSV `reminds_me_of_vault.csv` in the app group. It feeds Reminds me of candidates. It is not a rhyme-suggestion source.
- `selectedArtistForStyleTransfer` is a `@State` string on `NoteEditorView` (`ContentView.CCV.13.swift` 523). This pass found no read of it.

Model G receives the current groups as `RhymeGroupSummary` (`ModelGControlSurfaceView.swift` 60–61, `DirectedGenerationParams.swift`) when the user generates. That is prompt context, not the lightbulb list.

## 6. Bundled rhyme and phonetic resources

Measured in this tree on this pass:

| Resource | Path | Size | Format | Who loads it |
| --- | --- | --- | --- | --- |
| CMU dictionary | `XJournal AI/cmudict.txt` | 3,618,488 bytes | 135,166 lines. `WORD PHONE PHONE…`. No comment header in this copy. 9,114 keys contain `(`, e.g. `a(2) EY1` | `FJCMUDICTStore.load`, lazy, background |
| Slang table | `XJournal AI/FlowDNA/RapSlangPhonemes.swift` | 5,198 bytes | 42 compiled keys. One key is `no cap`, which a word tokenizer will not look up | Linked into the binary. No file read |
| Letter heuristic | same file, `heuristicPhonemes` | — | On the fly | `phonemes(for:)` after CMU and slang miss |
| Style-profile slang JSON | `tools/style-profile/slang_phonemes.json` | 4,206 bytes | Tooling JSON | Not referenced by `FJCMUDICTStore` or the lightbulb |
| Flow-rule JSON | `docs/flow-rules/slant_rhyme_recompute.json` (8,464 bytes), `rhyme_anchor_recompute.json` (689 bytes) | — | Notes | Not loaded by the panel |
| Bar Hits sqlite | `tools/bar-hits-catalog/BarHitsCatalog.sqlite` | 563,433,472 bytes | SQLite `bars` with `artist`, `end_word`, `phonetic_class` | `BarHitsCatalogStore` looks for `BarHitsCatalog.sqlite.gz` in the app bundle. This pass found no `.sqlite` or `.gz` under `XJournal AI/RemindsMeOf/` |

CMU load (`FJCMUDICTStore.swift` 45–95): first `phonemesByWord` access or `preloadGlobalCMUDICTStore()` starts one `DispatchQueue.global(qos: .userInitiated)` job. Lines split on the first space. Word is lowercased. The first line for a key wins, so `WORD` and `WORD(2)` are different keys and the `(2)` spelling is kept. `reserveCapacity(140_000)`. On finish it posts `.cmudictDidFinishLoading` on the main queue. The getter returns the current map immediately, which is empty until the job finishes.

`RhymeFinder.warmIndex` (`RhymeSuggestionView.swift` 328–362) builds three maps over that dictionary the first time writing tools arm. The lightbulb’s scan does not use the maps. It walks the raw dictionary again.

`BarHitsCatalogStore.phoneticClass(for:)` (123–130) is a different key: CMU phones from the primary-stress vowel (`suffix "1"` only) through the end, space-joined. That is not `RhymeGroup.key`.

`docs/rhymes/` was not opened.

## 7. Where a new suggestion source plugs in

There is no suggestion protocol. The only lightbulb call site is:

`RhymeGroupListView.findRhymeSuggestions(for:)`

`XJournal AI/ContentView.CCV.15.swift` 186–240.

That function is the seam. A Dictionary / All artists / one artist switch belongs behind it. The view already has the group, the note text, and the place the blue line is drawn (166–171). Callers of the popover (`DynamicIslandToolbarView`, `RapIslandToolbar`) would stay as they are.

What would have to change, and nothing else on the panel:

- Replace the body of `findRhymeSuggestions` with a source value (Dictionary, All artists, one artist). Dictionary should keep using `RhymeHighlighterEngine.phonemes` / `extractSignature` / `rhymeScore` if the blue line is supposed to match today’s perfect-then-near rule.
- Prefer `group.key` as the lookup into per-artist JSON (`sound key → words + example bars`). Also resolve each member through `endGroupKey` / `rimeKey`, because the panel’s key is often `IH|ALVSTOP`, `IY|TCH`, `AH|Y`, or `IH|STOP-PBGK`, not the raw CMU rime of every member.
- Pass the excluded set the function already builds (`wordsInText` plus `group.words`).
- Keep the cap in one place. Today it is 7, then an alphabetical sort.
- The blue line is not tappable. Showing an example bar, or inserting a word, needs a row control. `insertRhymeWord` on `NoteEditorView` is the existing insert, and it replaces a held word. The lightbulb has no held range.
- `@State` for the source, or a new `@AppStorage` key if the choice should survive dismissing the popover. No key exists today.
- Do not hang this on `GhostSuggestionEngine.freeRhymePool` (`GhostSuggestionEngine.swift` 560–602). That pool is the ghost dock: last end word of the line, `BarHitsCatalogStore.phoneticClass`, then `CatalogEndWordIndex`, then `RhymeFinder`. Different key, different screen, different rank (catalog landings, then short usable CMU headwords, slant included).
- Do not hang it on `RhymeFinder.rankedRhymeWords` without deciding the mismatch. That index (`RhymeSuggestionView.swift` 323–395) treats any same stressed vowel as near and any same base vowel as slant, drops keys that fail `isUsableRhymeHeadword`, and sorts short words first. The lightbulb’s `rhymeScore` is stricter and skips slant.

`RhymeFinder.warmIndex` is the existing place a Dictionary source can avoid a main-thread walk. An artist source wants its own map from sound key to words, built once when the JSON is chosen, not inside `body`.

## 8. Risks

- **Main-thread scan.** `findRhymeSuggestions` runs inside `body`. For each visible group it walks `phonemesByWord` until it has seen 7 perfects. A rare rime walks all 135,166 entries. Several groups do that several times per keystroke while the popover is open, because `cachedGroups` is replaced (new UUIDs) on every debounced analysis.
- **Unbounded near list.** Near matches are appended with no cap until the 7th perfect. A common vowel can allocate a very large `[String]` and then throw it away at `prefix(7)`.
- **Hash order is the rank.** Which 7 perfects appear depends on dictionary iteration. Later perfects are dropped. `.sorted()` only alphabetizes the survivors.
- **CMU noise.** `WORD(2)` and dotted headwords are not filtered here. `RhymeFinder.isUsableRhymeHeadword` (307–312) exists and is unused by this function.
- **Seed is one word, not the family key.** Suggestions can disagree with the bucket (`IH|ALVSTOP`, feminine `|Y`). If `group.words.first` is a syllable slice such as `tained`, `phonemes(for:)` may miss CMU and fall through to the letter heuristic, then the scan rhymes against that guess.
- **Memory.** The phoneme map is the whole file resident (`reserveCapacity(140_000)`). `RhymeFinder.warmIndex`, already started when the eye arms, keeps a second copy of usable headwords in three buckets. An all-artist rhyme-family JSON loaded the same way would sit beside both.
- **App size.** `cmudict.txt` is 3.6 MB in the synchronized `XJournal AI` folder, so it ships in the bundle. The 563 MB Bar Hits sqlite is under `tools/` and was not in `XJournal AI/RemindsMeOf/` on this pass. Artist JSON should stay lazy and per artist. Loading every artist at launch would dwarf CMU.
- **Threading.** The CMU job is correct (one background load, lock, main-queue notification). The lightbulb scan is not moved off the main actor. `phonemesByWord` returns the empty map if the caller arrives before the job finishes. The panel does not observe `.cmudictDidFinishLoading` itself. It only refreshes if `cachedGroups` changes.
- **Stale groups.** `groups(for:)` does not remap. Fast typing can show the previous families for up to the 50 ms debounce, longer if `refreshImmediately` bailed on an empty dictionary.
- **Label fragility.** Assonance leftovers are `.endRhyme`, so they read as "End". Reversing the sort renumbers End and Internal from the top.
- **Identity churn.** Every `computeAll` mints new group UUIDs. `ForEach` row identity changes while the popover is open.
- **Suggestions are not actions.** The splash blurb says the button explores related words. The blue line cannot be tapped, and nothing records that the bulb was used (`UsageTracker.suggestRhymes` is the other feature).

## Recommended integration seam

Put the new source behind `RhymeGroupListView.findRhymeSuggestions(for:)` in `XJournal AI/ContentView.CCV.15.swift` (line 186). Add a small type there, for example a function or protocol `suggestions(for group: RhymeHighlighterEngine.RhymeGroup, excluding: Set<String>, limit: Int) -> [String]`, with three implementations selected by a local state value: Dictionary, All artists, one artist. Dictionary reads the CMU map the function already holds, scored with `RhymeHighlighterEngine.rhymeScore`, capped before the near-array grows, and filtered with the usable-headword rule that `RhymeFinder.isUsableRhymeHeadword` already states. All artists and one artist look up `group.key`, and fall back to each member’s `endGroupKey` / `rimeKey`, in the per-artist JSON (sound key → words + example bars). Build that map once when the artist changes. Leave `DynamicIslandToolbarView`, `RapIslandToolbar`, `GhostSuggestionEngine.freeRhymePool`, and `RhymeFinder.rankedRhymeWords` unwired until the blue line is supposed to match the ghost dock or the hold-word sheet. Insert-on-tap is a separate change: the row is a `Text` today, and `NoteEditorView.insertRhymeWord` expects a held range the lightbulb does not have.
