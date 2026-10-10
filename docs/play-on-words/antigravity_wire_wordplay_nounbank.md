# Anti-Gravity job #4: wire confirmed wordplay flips into the Play on Words noun bank

You are running in your own chat. This file is your whole brief. Work on Samuel's Mac in this repo:

```
REPO="/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
```

Every path below is relative to `$REPO`, which is on git branch `model-you`. The working tree has about 418 uncommitted changes from other terminals. Do not stash, reset, check out, or commit them.

## 0. Samuel's rule (the point of this job)

When a flip is confirmed, its **green heard-as** becomes a chip in the Play on Words section. Examples: `Joe Biden`, `man chin`, `Michael Phelps`, `Xbox`.

- Every chip needs an image.
- If an image for that noun already exists in another section, **reuse that same asset**. The noun then lives in both places.
  - Do not copy the asset.
  - Do not move it.
  - Do not remove the noun from the other tab.
- If no image exists, create one in the bank's existing style (section 4).
- If you cannot do that cleanly, **queue it for Samuel**. Do not invent a different style.

## 1. Guardrails (read first; they apply all the time)

- **Do not touch:**
  - `BarHitsCatalog.sqlite`
  - `docs/play-on-words/live-board/` (the board server is running there)
  - `genius-clicks/`
  - `lane-claims/`
- **Do not touch running processes.** Leave the running jobs alone: `run_all_artists.py` (PID 99004) and the lane2 run. Also leave alone any developer.apple.com browser windows and Remote Access. Kill only processes you started.
- **No commit and no push.** Before any `git commit`, stop and ask for Samuel's go-ahead. Never push.
- **Pre-flight check before editing.** Do this before the first edit and again before each batch:
  ```bash
  cd "$REPO"
  find "XJournal AI" "The Final Journal AITests" docs/play-on-words -newermt "-10 minutes" \( -name '*.swift' -o -name 'Contents.json' -o -name 'picture-ledger.*' \) -print
  ps aux | grep -iE 'grok|antigravity|xcodebuild|swift-frontend' | grep -v grep
  ```
  Stop and report to Samuel if either of these is true:
  - Any target file (list in section 2) changed in the last 10 minutes.
  - Another agent or terminal (for example Grok session 01a10ee9, which owned the noun bank) is visibly editing these files.
- **Backups.** The tree is shared and dirty, so do not switch branches. Take commit-safe backups before every batch instead:
  ```bash
  TS=$(date +%Y%m%d_%H%M%S); B="docs/play-on-words/wiring-backups/$TS"; mkdir -p "$B"
  cp "XJournal AI/NounBankStore.swift" "XJournal AI/NounBankSections.swift" "XJournal AI/NounBankCatalog.swift" \
     "XJournal AI/NounMentionBrief.swift" "XJournal AI/NounBankMark.swift" "The Final Journal AITests/NounBankSheetTests.swift" "$B/"
  cp docs/play-on-words/picture-ledger.md docs/play-on-words/picture-ledger.tsv "$B/"
  ```
  Also record the names of any new imageset directories you create in that batch, so a revert can delete exactly those and nothing else.
- **Minimal, additive edits only:**
  - Never remove, rename or reorder existing chips, map keys, sentences, assets or tests.
  - Append new entries at the end of each list or map.
  - Locate files with `find . -name NounBankStore.swift`. If a path below is wrong, fix the path, not the file.

## 2. Code facts (verified read-only on 2026-10-09)

Swift sources are in `XJournal AI/`. The tests are in `The Final Journal AITests/NounBankSheetTests.swift`.

| File | What matters |
|---|---|
| `NounBankStore.swift` | `enum NounBankCategory` has `case wordplay = "Play on Words"` (icon `quote.bubble`). `NounBankStore.words(for:)` has a `case .wordplay: return unique([...])` (~line 891) with **1,226** strings. This is the chip list. |
| `NounBankSections.swift` | `case .wordplay: return [NounChipSection(title: "Sound flips", words: [...])]` (~line 2069). This is **one** section whose words must equal `NounBankStore.words(for: .wordplay)` exactly. |
| `NounBankCatalog.swift` | `iconName(for:family:category:)` (~line 2386). Resolution order: guns/uzi, then `familyRoleIcons`, then **`wordplayPictureIcons[key]`** (only for `.wordplay`; the dict starts ~line 1685, keyed by `NounBankMark.normalize(chip)`, values `"noun-…"`), then `productIcons`, then a shared dict, then the fallback `"noun-" + family`. `mentionPartnerTable` (~line 237) maps a chip to its partner words. |
| `NounMentionBrief.swift` | `private static let wordplay: [String: String]` (~line 82) maps the normalized chip to a one-line sentence. `standing(word:category:)` falls back to "`X` says one word and means the one beside it." |
| `NounBankMark.swift` | `normalize()`: folds diacritics and case, deletes `’` `'` `.`, turns `-` and `/` into spaces, and collapses whitespace. `.wordplay` is in `wholeNameCategories`. Do not add wordplay heard-as words as family aliases: that would recolor other tabs. |
| Assets | `XJournal AI/Assets.xcassets/NounMarks/noun-<slug>.imageset/` holds 3,952 imagesets. Each has one 1024×1024 PNG and a `Contents.json` that lists only the 1x filename (copy the shape from `noun-a-bride.imageset/Contents.json`). |
| `docs/play-on-words/picture-ledger.md` / `.tsv` | The running ledger. The TSV header is: `heard partners kind hidden_sense picture_subject current_icon current_has_image chip_photo_is_picture reuse_icon action akorn_class partner_has_image partner_icon other_tabs sense_chip note spot_check`. Append only. |

Tests that constrain this job (`NounBankSheetTests.swift`):

- **`testPlayOnWordsStayOneSenseAndOffTheOtherTabs`** (~line 1400):
  - `XCTAssertEqual(words, [ ...1,226 literals... ])`. Append your new chips to this literal in the same order.
  - `for word in words { XCTAssertFalse(folded.contains(word.lowercased()), word) ... }`. This assert forbids a wordplay chip from appearing on any other tab, which **conflicts with Samuel's "both places" rule**. Fix it additively:
    ```swift
    // Heard-as chips may share a noun (and its picture) with another tab — Samuel's rule, job #4.
    let sharedHeardAs: Set<String> = [ /* lowercased new chips that also exist on another tab */ ]
    for word in words where !sharedHeardAs.contains(word.lowercased()) {
        XCTAssertFalse(folded.contains(word.lowercased()), word)
    }
    ```
    Keep the `icon.hasPrefix("noun-")` check for **all** words.
  - The `plays` dict must keep `Set(plays.keys) == Set(words)`, and every sentence must match `NounMentionBrief`. Add one entry per new chip.
- **~line 4895:** `play.count == 1` and `play[0].words == NounBankStore.words(for: .wordplay)`. Keep a single "Sound flips" section and append in the same order there too.
- Add one new test, `testWiredHeardAsChipsReuseExistingPictures`. For each reused chip, assert that `NounBankCatalog.iconName(for: chip, family: NounBankMark.normalize(chip), category: .wordplay) == "<that asset>"` and that `UIImage(named: asset) != nil`. If an asset-existence helper already exists in the test file (`NounMarkImage.uiImage(named:)` lives in Catalog), use that instead.

## 3. Input: confirmed flips only

Use only these three sources. Never use "possible" rows.

1. `docs/play-on-words/wordplay-highlights.jsonl`, rows where `list` does **not** start with `possible` (168 rows).
   - Fields: `artist, song, bar, setup_spans[{text,start,end}], play_spans[{text,start,end,heard}], heard_as, pair, note_excerpt, url`.
2. `docs/play-on-words/possible-wordplay-verify/verified.jsonl`, rows with `verdict == "CONFIRMED"`. This file may not exist yet; skip it if it is missing.
   - Fields: `id, artist, song, bar, verdict, reason_code, heard_as, setup_spans, play_spans, sources[{url,quote,kind}], sound_note, notes`.
3. `docs/play-on-words/*-candidates.jsonl`, rows with `signal_type == "sound_flip"` that were kept (no `reject_reason`) **and** have spans. Today there are none.

**Chip noun.** Take `heard_as`, drop any parenthetical, and trim. For example, `man chin (Quagmire's chin)` becomes `man chin`. When `heard_as` lists several nouns (`A, B`, `A + B`, `A / B`), make one chip per noun. All of those chips share the same source line.

**Keep per chip** in a bundled JSON file, `XJournal AI/WordplayFlips.json`: artist, song, bar, setup/play spans, and the Genius URL. Add it to the app target's Copy Bundle Resources. If the project uses file-system-synchronized groups, it is picked up automatically; confirm by building. Sketch:

```swift
struct WordplayEntry: Codable, Equatable, Sendable {
    struct Span: Codable, Equatable, Sendable { let text: String; let start: Int; let end: Int; let heard: String? }
    let chip: String          // green heard-as noun = chip text
    let artist: String
    let song: String
    let bar: String
    let setupSpans: [Span]    // blue
    let playSpans: [Span]     // yellow
    let heardAs: String       // full green heard_as as written
    let geniusURL: String
    let image: String         // "noun-…" asset actually used
    let imageDecision: String // reused | created
    let sourceLine: Int       // 1-based line in the source jsonl
}
enum WordplayFlips {
    static let all: [WordplayEntry] = {
        guard let url = Bundle.main.url(forResource: "WordplayFlips", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONDecoder().decode([WordplayEntry].self, from: data) else { return [] }
        return rows
    }()
    static func entry(for chip: String) -> WordplayEntry? {
        let k = NounBankMark.normalize(chip); return all.first { NounBankMark.normalize($0.chip) == k }
    }
}
```

`WordplayFlips.swift` is a new additive file. The chip list itself stays as literals in Store, Sections and Tests, so the existing tests keep passing.

## 4. Per-chip procedure

**Dedup first.** Write each skip to the wiring log with `decision: "skipped"` and a reason:

- `chip-exists`: `normalize(chip)` already equals an existing `.wordplay` word.
- `bar-already-wired`: the source bar is already covered by an existing wordplay chip. Use `docs/play-on-words/app-wordplay-format-gaps.jsonl`, which has `proposed.bar` per app chip from the audit's matching, and compare bars after lowercasing, stripping punctuation and apostrophes, and collapsing spaces. Also skip a repeat of the same chip and bar coming from two sources.

**Image decision** (record one per chip). Check in this order:

1. **Reuse.** Find an existing asset for the noun:
   - Look at `docs/play-on-words/confirmed-flips-image-match.json`, which was precomputed for the 168. Use `chip_nouns[].images`; `probable_image` needs a visual check.
   - Re-verify that the directory exists.
   - Also check:
     - `noun-<slug>`, where slug = normalize(noun) with spaces turned into `-`;
     - `noun-{celeb,artist,place,car,prod,char,nba,sport,drug,gun,money,plain,family}-<slug>`;
     - any `"<normalized noun>": "noun-…"` literal in `NounBankCatalog.swift`;
     - a family id in `NounBankMark` (`"noun-" + id`);
     - the ledger columns `reuse_icon` and `picture_subject`.
   - Open the PNG and confirm that it actually shows that noun. Example: `noun-xbox` is a pile of pills, so for the console sense of Xbox it is **not** a match, and you go to step 2.
   - If it matches, add `"<normalize(chip)>": "<asset>"` to the end of `wordplayPictureIcons`. Do not copy, rename or move the asset. If the noun also lives on another tab, leave it there and add it to `sharedHeardAs` in the test.
2. **Create** (same style only). The bank's photos are 1024×1024 PNG photos of real things: an object on black or a neutral ground, or a real location photo. People are real Wikipedia/Wikimedia portraits (Wikidata P18 / Openverse) and **never** AI-generated or invented faces.
   - Use the repo's own tools in `tools/`:
     - `fetch-people-noun-marks.py`
     - `fetch-person-portraits.py`
     - `fetch-brand-product-marks.py`
     - then `tight-crop-noun-marks.py` / `cover-crop-noun-marks.py` to square 1024
   - Some tools hard-code old roots (`The Final Journal AI.nosync`, `Desktop/pennworkstudios.nosync`). Pass the current paths; do not edit the tools.
   - Write the new `noun-<slug>.imageset/` with a 1x-only `Contents.json`, then map it in `wordplayPictureIcons`.
   - Keep the licence or source URL in the log.
   - `make-phrase-wordmarks.py` (B&W wordmarks) is used for the Phrases tab only. **Do not** use it for wordplay heard-as nouns unless Samuel says so.
3. **Queue.** Use this when no free real photo is found, the subject is abstract (for example `paralyzed`, `respect the game`), or the noun is in a class the ledger keeps unwired (guns, drugs, sexual products, brand marks with no free photo). Append the chip to `docs/play-on-words/wordplay-image-queue.md` with: noun, bar, artist/song, suggested picture subject, and why. **A queued chip is not wired yet.** Leave it out of Store, Sections and Tests until it has an image.

**Wire each chip** with reused or created images, all appended at the end:

- `NounBankStore` `.wordplay` list
- `NounBankSections` "Sound flips" words, in the same order
- `wordplayPictureIcons`
- `NounMentionBrief.wordplay`: one plain sentence in the house voice, e.g. `"Man chin is mansion. Quagmire sets it up."`
- `mentionPartnerTable`: the setup word(s) as partners
- the test `words` literal plus the `plays` dict
- `WordplayFlips.json`

**Logs** (append only):

- `docs/play-on-words/picture-ledger.tsv` and a dated section in `picture-ledger.md` (same style as the existing "Plain objects" section). Use `spot_check` = `wired` for reused or created, and `held` for queued.
- `docs/play-on-words/wordplay-wiring-log.jsonl`, one line per chip, including skips:
  ```json
  {"ts":"2026-10-09T01:30:00-04:00","batch":1,"noun":"Joe Biden","sections":["Play on Words","(also) celebs"],"image":"noun-celeb-biden","decision":"reused","source":"wordplay-highlights.jsonl","source_line":7,"artist":"NoCap","song":"…","bar":"…","url":"https://genius.com/…","note":""}
  ```
  `decision` is one of `reused | created | queued | skipped`.

## 5. Batches of ~20 with build and test

1. Run the pre-flight check from section 1, then take the backups.
2. Wire about 20 chips in source order.
3. Build and test. The schemes come from `xcodebuild -list`. Run that again yourself first; on 2026-10-09 it showed scheme `PennWork Studios` and test target `The Final Journal AITests` in `PennWork Studios.xcodeproj`, `The Final Journal AI.xcodeproj` and `XJournal AI.xcodeproj`. Use the project whose scheme runs that test target.
   ```bash
   xcodebuild -project "PennWork Studios.xcodeproj" -scheme "PennWork Studios" \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
     -only-testing:"The Final Journal AITests/NounBankSheetTests" test 2>&1 | tee "docs/play-on-words/wiring-backups/$TS/test.log" | tail -40
   ```
   The Mac runs at a high load average; allow 20+ minutes.
4. **On failure:** stop, then revert this batch only.
   - Copy the 6 Swift files and 2 ledger files back from `$B`.
   - Delete only the imageset directories created in this batch.
   - Drop this batch's lines from `WordplayFlips.json`.
   - Append `"decision":"reverted"` lines to the wiring log; do not delete lines.
   - Then report to Samuel. Do not continue to the next batch.
5. On success, log the batch result and continue.

## 6. Stop point: report to Samuel

Stop after all batches, or at the first failure. Report:

- Chips wired, broken down into images **reused**, **created** and **queued**, with the reused asset names.
- Test results per batch (pass/fail, test count, duration).
- The skipped list with reasons (`chip-exists` / `bar-already-wired`).
- The queued list (`wordplay-image-queue.md`).
- The files touched, and the backup folder(s).
- Then ask: "OK to commit these to `model-you`?" Do not commit until Samuel says yes. Never push.

## Read-only pre-count for the 168 confirmed rows (2026-10-09)

Source: `docs/play-on-words/confirmed-flips-image-match.json`.

- The 168 rows contain 192 chip nouns (21 rows have more than one noun).
- **Already covered (skip):** 21 rows. 19 bars are already wired as a wordplay chip (e.g. Quagmire, Marcus/Marriott her, Akorn, Eggo, Jack son); in 2 more the noun text is already a chip (Titans, Space Jam).
- **To wire: 147 rows.**
  - 30 have an existing image for every noun, so they are reuse candidates (e.g. Joe Biden → `noun-celeb-biden`, Michael Phelps → `noun-celeb-phelps`, Philadelphia → `noun-place-philly`, Uncle Phil → `noun-celeb-uncle-phil`).
  - 4 have an image for some of their nouns.
  - 113 need a new image.
- Probable matches to check by eye: DeRozan → `noun-nba-derozan`, Bill Cosby → `noun-celeb-cosby`, James Harden → `noun-celeb-harden`. `noun-xbox` shows pills, so it is the wrong sense for the console.
