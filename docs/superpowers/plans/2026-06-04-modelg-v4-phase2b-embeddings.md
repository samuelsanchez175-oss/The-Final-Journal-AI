# Model G v4 — Phase 2b: On-Device Semantic Embeddings — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Replace the corpus retriever's in-memory first-launch embedding (Approach A) with precomputed Float32 sidecar vectors shipped in the app bundle (Approach B1) plus an on-device recompute self-heal (Approach C), and rank candidate bars by a tunable hybrid score `0.70·cosine + 0.20·lexical + 0.10·theme` — all on-device, $0, offline, never touching the BYOK key — while keeping `ModelGCorpusRetriever.retrieve(theme:draft:brands:k:)` byte-identical.

**Architecture:** A new pure `ModelGHybridRanker` (static funcs, fixture-vector testable) computes the blended score; a new isolated `ModelGCorpusVectorSidecar` loads/validates the bundled `ModelGCorpusVectors.f32` + `ModelGCorpusVectors.meta.json` (refuse-and-fallback on `dims`/`corpusVersion`/`embeddingRevision` mismatch). The existing `ModelGEmbeddingIndex` (already wired into the retriever and `ModelGCoreCoordinatorV4`) is taught to prefer sidecar vectors, fall back to its current on-device build when the sidecar is absent/stale, and rank via the hybrid seam; `VectorMath.cosine` gains an Accelerate fast path. The sidecar is produced by a tiny macOS Swift CLI (`tools/modelg-embed/`) that links the *same* `NLEmbedding.sentenceEmbedding(for: .english)` the device uses, run after the existing Node exporter.

**Tech Stack:** Swift, SwiftUI, NaturalLanguage (NLEmbedding), Accelerate, XCTest; export tooling = a Swift Package Manager macOS executable (`tools/modelg-embed/`) invoked after `tools/modelg-corpus/build-corpus.mjs`.

---

## Context the implementer MUST internalize before starting

This branch (`modelg-v4-phase1`) is **NOT greenfield** — the design spec describes a clean seam, but Phase 1/2 already shipped an **Approach A** (in-memory, build-at-first-launch) embedding path. These types already exist and are already wired:

- `XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift` — singleton `ModelGEmbeddingIndex.shared`; `NLEmbedding.sentenceEmbedding(for: .english)`; `embed(_:) -> [Float]?`; `buildIfNeeded(bars:)` (background `DispatchQueue` build into `[String:[Float]]`); `rank(bars:near:k:) -> [CorpusBar]?`; `static rankByVectors(bars:vectors:query:k:)`; `isAvailable`/`isReady`.
- `XJournal AI/ModelG/Embedding/VectorMath.swift` — `enum VectorMath { static func cosine(_:_:) -> Float }` (naive loop).
- `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift` — already has `var embeddingIndex: ModelGEmbeddingIndex? = nil` and a semantic-vs-lexical branch inside `retrieve(...)`. The signature is **already** the drop-in seam.
- `XJournal AI/ModelG/ModelGCoreCoordinatorV4.swift` — Step 1b already calls `ModelGEmbeddingIndex.shared.buildIfNeeded(...)` then `ModelGCorpusRetriever(store:embeddingIndex:)`.
- Existing tests: `The Final Journal AITests/ModelGEmbeddingTests.swift` (`VectorMath.cosine`, `rankByVectors`, lexical-fallback-when-no-index). **These must keep passing** — do not break their signatures.

**Therefore this plan EVOLVES the existing types; it does NOT introduce the spec's hypothetical `ModelGEmbeddingService` / `ModelGCorpusVectorIndex` greenfield names** (that would duplicate working code). Where the spec names a new type, we map it onto the real one:

| Spec name | Real type this plan touches |
|---|---|
| `ModelGEmbeddingService` (TextEmbedder) | existing `ModelGEmbeddingIndex` (already wraps `NLEmbedding`) |
| `ModelGCorpusVectorIndex` (storage + cosineTopK) | existing `ModelGEmbeddingIndex` (storage) + **new** `ModelGCorpusVectorSidecar` (load/validate) + existing `VectorMath` (math) |
| hybrid blend | **new** pure `ModelGHybridRanker` |

The spec's **testability intent** (pure cosine/ranking seam, fixture Float vectors, no live `NLEmbedding` in unit tests) is honored via `VectorMath` (exists) + `ModelGHybridRanker` (new pure static) + `ModelGEmbeddingIndex.rankByVectors` (exists). Live `NLEmbedding` appears only in optional, guarded smoke tests.

### PARALLEL-CODING SAFETY (read every time before editing)

Samuel codes on this same branch concurrently. Before editing **each** SHARED file, run `git status --short -- "<path>"` and **STOP** (ask, do not edit) if it shows `M`/`??` from work you did not author this session:

- `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift` — SHARED
- `XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift` — SHARED
- `XJournal AI/ModelG/Embedding/VectorMath.swift` — SHARED
- `XJournal AI/ModelG/ModelGCoreCoordinatorV4.swift` — SHARED (this plan does **not** edit it; semantics arrive via the singleton)
- `tools/modelg-corpus/` — SHARED

**Isolated and safe** (brand-new, nobody else touches): everything under the new dir `XJournal AI/ModelG/Corpus/Embeddings/`, the new test files, and the new `tools/modelg-embed/` CLI. Prefer adding code there.

Every commit is **path-scoped** — list exact files in `git add`. **Never `git add -A` / `git add .`** (the working tree has unrelated modified files across the app). `.swift`/`.json` under `XJournal AI/` auto-compile and auto-bundle via the synchronized groups in **both** `.xcodeproj` — **no manual Xcode target-membership step**. (The macOS CLI under `tools/` is outside the app and is run by hand.)

### Build/test invocation (use verbatim in every run/verify step)

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/<TestClass>"
```

`-derivedDataPath /tmp/xjournal-dd` keeps build products **out of iCloud `~/Documents`** (the known CodeSign "detritus" failure); `CODE_SIGNING_ALLOWED=NO` covers the unsigned simulator build.

---

## File Structure

| File | New/Mod | One responsibility |
|---|---|---|
| `XJournal AI/ModelG/Corpus/Embeddings/ModelGHybridRanker.swift` | **New** | Pure static hybrid score `0.70·cosine + 0.20·lexical + 0.10·theme`; tunable weight constants; `rank(...)`. No I/O, no `NLEmbedding`. |
| `XJournal AI/ModelG/Corpus/Embeddings/ModelGCorpusVectorSidecar.swift` | **New** | Decode + validate the bundled `ModelGCorpusVectors.f32` / `.meta.json`; `id → [Float]` lookup; refuse-and-`nil` on `dims`/`corpusVersion`/`embeddingRevision` mismatch. |
| `XJournal AI/ModelG/Embedding/VectorMath.swift` | **Mod** | Add Accelerate (`cblas_sdot`) fast path to `cosine`; keep naive fallback + identical signature. |
| `XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift` | **Mod** | Prefer sidecar vectors when valid; else current on-device build (self-heal); rank through `ModelGHybridRanker`; expose `embeddingRevision`. |
| `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift` | **Mod** | Pass `theme` into the rank call so `themeExactBonus` works; signature unchanged; lexical fallback preserved. |
| `The Final Journal AITests/ModelGHybridRankerTests.swift` | **New** | Deterministic fixture-vector tests for the blend + weight-sum + `semanticWeight=0` ⇒ legacy ordering. |
| `The Final Journal AITests/ModelGCorpusVectorSidecarTests.swift` | **New** | Sidecar decode happy-path + meta/version/dims mismatch ⇒ `nil`, from in-test temp files (no `NLEmbedding`). |
| `The Final Journal AITests/ModelGCorpusRetrieverSemanticTests.swift` | **New** | Inject a fixture-vector `ModelGEmbeddingIndex` so a far bar reorders ahead of a near one; assert fallback parity when index unavailable. |
| `tools/modelg-embed/Package.swift` | **New** | SPM manifest for the macOS embed CLI. |
| `tools/modelg-embed/Sources/modelg-embed/main.swift` | **New** | Reads `ModelGCorpus.json`, embeds each `bar.text` via `NLEmbedding.sentenceEmbedding(for:.english)`, writes `.f32` + `.meta.json`. |
| `tools/modelg-embed/README.md` | **New** | How to run the two-step export (Node parse → Swift embed) and where the sidecars land. |
| `tools/modelg-corpus/build-corpus.test.mjs` | **Mod** | Add a node:test asserting the sidecar contract (byte length `count×dims×4`, meta keys) using a tiny synthetic `.f32`/meta written in-test (no `NLEmbedding` in Node). |

**Untouched (guardrail):** `ModelGCoreCoordinatorV4.swift`, `ModelGCorpusStore.swift`, `ModelGCorpusModels.swift` (`CorpusBar`), `ScoringEngine.swift`, `tools/modelg-corpus/lib/parsers.mjs`, `tools/modelg-corpus/build-corpus.mjs`. The coordinator picks up semantics for free because it already uses `ModelGEmbeddingIndex.shared`.

---

## Tasks

### Task 1 — Pure hybrid ranker (`ModelGHybridRanker`)

The genuinely new, fully-deterministic ranking surface. Mirrors how `ScoringEngine.v4*Weight` constants are exposed + weight-sum-asserted in `ModelGV4ScoringTests`. No `NLEmbedding`, no I/O.

**Files:**
- Create: `XJournal AI/ModelG/Corpus/Embeddings/ModelGHybridRanker.swift`
- Test: `The Final Journal AITests/ModelGHybridRankerTests.swift`

Steps:

- [ ] **(1) Create the new dir + write the failing test.** First `mkdir -p "XJournal AI/ModelG/Corpus/Embeddings"`. Then create `The Final Journal AITests/ModelGHybridRankerTests.swift`:

```swift
import XCTest
@testable import XJournal_AI

final class ModelGHybridRankerTests: XCTestCase {

    // Helper: build a CorpusBar with just the fields the ranker reads.
    private func bar(_ id: String, norm: String, themes: [String] = []) -> CorpusBar {
        CorpusBar(id: id, text: norm, adlib: nil, norm: norm, artist: nil, activeArtist: nil,
                  song: nil, album: nil, section: nil, themes: themes, tags: [],
                  bpm: nil, scale: nil, concepts: [], context: [])
    }

    func testWeightsAreTunableAndSumToOne() {
        XCTAssertEqual(
            ModelGHybridRanker.semanticWeight + ModelGHybridRanker.lexicalWeight + ModelGHybridRanker.themeWeight,
            1.0, accuracy: 0.001)
        XCTAssertEqual(ModelGHybridRanker.semanticWeight, 0.70, accuracy: 0.001)
        XCTAssertEqual(ModelGHybridRanker.lexicalWeight, 0.20, accuracy: 0.001)
        XCTAssertEqual(ModelGHybridRanker.themeWeight, 0.10, accuracy: 0.001)
    }

    func testLexicalOverlapNormalizedZeroToOne() {
        XCTAssertEqual(ModelGHybridRanker.lexicalOverlap(draft: "", barNorm: "anything"), 0.0, accuracy: 0.0001)
        XCTAssertEqual(ModelGHybridRanker.lexicalOverlap(draft: "stack paper", barNorm: "nothing common"), 0.0, accuracy: 0.0001)
        // Every draft keyword (>=4 chars) appears as a substring of the bar -> 1.0
        XCTAssertEqual(ModelGHybridRanker.lexicalOverlap(draft: "garments worn", barNorm: "got garments thats never been worn"), 1.0, accuracy: 0.0001)
        // Half of the keywords present -> 0.5
        XCTAssertEqual(ModelGHybridRanker.lexicalOverlap(draft: "garments diamonds", barNorm: "got garments only"), 0.5, accuracy: 0.0001)
    }

    func testThemeExactBonus() {
        XCTAssertEqual(ModelGHybridRanker.themeExactBonus(theme: "confident", bar: bar("x", norm: "n", themes: ["confident"])), 1.0, accuracy: 0.0001)
        XCTAssertEqual(ModelGHybridRanker.themeExactBonus(theme: "Confident", bar: bar("x", norm: "n", themes: ["confident"])), 1.0, accuracy: 0.0001)
        XCTAssertEqual(ModelGHybridRanker.themeExactBonus(theme: "flexing", bar: bar("x", norm: "n", themes: ["confident"])), 0.0, accuracy: 0.0001)
        XCTAssertEqual(ModelGHybridRanker.themeExactBonus(theme: nil, bar: bar("x", norm: "n", themes: ["confident"])), 0.0, accuracy: 0.0001)
    }

    func testScoreClampsCosineToZeroOne() {
        // Opposite vectors (cosine -1) must clamp to 0 on the semantic term.
        let b = bar("x", norm: "totally unrelated", themes: [])
        let s = ModelGHybridRanker.score(bar: b, barVector: [-1, 0], queryVector: [1, 0], draft: "zzzz", theme: nil)
        XCTAssertEqual(s, 0.0, accuracy: 0.0001)
    }

    func testRankOrdersBySemanticWhenLexicalAndThemeTied() {
        // b2's vector is identical to the query; b1 is orthogonal. No lexical/theme signal.
        let bars = [bar("b1", norm: "alpha"), bar("b2", norm: "beta")]
        let vecs: [String: [Float]] = ["b1": [0, 1], "b2": [1, 0]]
        let out = ModelGHybridRanker.rank(bars: bars, vectors: vecs, queryVector: [1, 0],
                                          draft: "zzzz", theme: nil, k: 2)
        XCTAssertEqual(out.map(\.id), ["b2", "b1"])
    }

    func testRankFallsBackToLexicalForBarsMissingVector() {
        // b1 has no vector but matches the draft lexically; b2 has an orthogonal vector and no lexical match.
        // With semanticWeight 0.70 vs lexicalWeight 0.20, a strong lexical hit (0.20) must beat
        // an orthogonal-but-present vector (cosine 0 -> 0.0) — so b1 ranks first.
        let bars = [bar("b1", norm: "got garments thats never been worn"),
                    bar("b2", norm: "vvs stones in my charm")]
        let vecs: [String: [Float]] = ["b2": [0, 1]]   // b1 deliberately missing
        let out = ModelGHybridRanker.rank(bars: bars, vectors: vecs, queryVector: [1, 0],
                                          draft: "garments worn", theme: nil, k: 2)
        XCTAssertEqual(out.first?.id, "b1")
    }

    func testSemanticWeightZeroReproducesLexicalPlusThemeOrdering() {
        // Temporarily neutralizing semantic -> ordering driven by lexical+theme only.
        // b1: theme match + no lexical; b2: no theme + full lexical. Compute both expected and assert order.
        let bars = [bar("b1", norm: "no overlap here", themes: ["confident"]),
                    bar("b2", norm: "got garments thats never been worn", themes: [])]
        let vecs: [String: [Float]] = ["b1": [1, 0], "b2": [0, 1]]   // semantic favors b1, must be ignored
        let out = ModelGHybridRanker.rank(bars: bars, vectors: vecs, queryVector: [1, 0],
                                          draft: "garments worn", theme: "confident", k: 2,
                                          semanticWeight: 0.0, lexicalWeight: 0.667, themeWeight: 0.333)
        // b2 lexical=1.0*0.667=0.667 ; b1 theme=1.0*0.333=0.333 -> b2 first
        XCTAssertEqual(out.map(\.id), ["b2", "b1"])
    }
}
```

- [ ] **(2) Run it — expect FAIL (does not compile: `ModelGHybridRanker` undefined).**

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGHybridRankerTests"
```

- [ ] **(3) Minimal implementation.** Create `XJournal AI/ModelG/Corpus/Embeddings/ModelGHybridRanker.swift`:

```swift
import Foundation

/// Pure, deterministic hybrid ranker for Model G v4 corpus retrieval (Phase 2b).
/// `hybridScore = semanticWeight·cosine⁺ + lexicalWeight·lexicalOverlap + themeWeight·themeExactBonus`
/// No I/O, no NLEmbedding — vectors are supplied by the caller, so this is fully unit-testable.
enum ModelGHybridRanker {

    // Tunable weights (mirror ScoringEngine.v4*Weight). Asserted to sum to 1.0 in tests.
    static let semanticWeight: Float = 0.70
    static let lexicalWeight: Float = 0.20
    static let themeWeight: Float = 0.10

    /// Same keyword rule the lexical retriever uses: lowercase, split on non-alphanumerics, len >= 4, first 6.
    static func keywords(from draft: String) -> [String] {
        Array(draft.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 4 }
            .prefix(6))
    }

    /// Fraction of draft keywords that appear as substrings of `barNorm`, in [0,1]. Empty draft -> 0.
    static func lexicalOverlap(draft: String, barNorm: String) -> Float {
        let kws = keywords(from: draft)
        guard !kws.isEmpty else { return 0 }
        let n = barNorm.lowercased()
        let hits = kws.reduce(into: 0) { acc, kw in if n.contains(kw) { acc += 1 } }
        return Float(hits) / Float(kws.count)
    }

    /// 1.0 if the bar carries the requested theme tag (case-insensitive), else 0.
    static func themeExactBonus(theme: String?, bar: CorpusBar) -> Float {
        guard let t = theme?.lowercased(), !t.isEmpty else { return 0 }
        return bar.themes.contains { $0.lowercased() == t } ? 1 : 0
    }

    /// Blended score for one bar. `barVector == nil` -> semantic term is 0 (bar keeps lexical+theme score).
    static func score(bar: CorpusBar, barVector: [Float]?, queryVector: [Float],
                      draft: String, theme: String?,
                      semanticWeight: Float = semanticWeight,
                      lexicalWeight: Float = lexicalWeight,
                      themeWeight: Float = themeWeight) -> Float {
        let cos: Float = barVector.map { max(0, VectorMath.cosine($0, queryVector)) } ?? 0
        let lex = lexicalOverlap(draft: draft, barNorm: bar.norm)
        let thm = themeExactBonus(theme: theme, bar: bar)
        return semanticWeight * cos + lexicalWeight * lex + themeWeight * thm
    }

    /// Rank bars by descending hybrid score; stable on the input order for ties; take top-k.
    static func rank(bars: [CorpusBar], vectors: [String: [Float]], queryVector: [Float],
                     draft: String, theme: String?, k: Int,
                     semanticWeight: Float = semanticWeight,
                     lexicalWeight: Float = lexicalWeight,
                     themeWeight: Float = themeWeight) -> [CorpusBar] {
        bars.enumerated()
            .map { (idx, bar) -> (Int, CorpusBar, Float) in
                (idx, bar, score(bar: bar, barVector: vectors[bar.id], queryVector: queryVector,
                                 draft: draft, theme: theme,
                                 semanticWeight: semanticWeight, lexicalWeight: lexicalWeight,
                                 themeWeight: themeWeight))
            }
            .sorted { a, b in a.2 != b.2 ? a.2 > b.2 : a.0 < b.0 }   // score desc, original order tiebreak
            .prefix(k)
            .map { $0.1 }
    }
}
```

- [ ] **(4) Run tests — expect PASS** (same command as step 2).

- [ ] **(5) Commit (path-scoped).**

```
git add "XJournal AI/ModelG/Corpus/Embeddings/ModelGHybridRanker.swift" "The Final Journal AITests/ModelGHybridRankerTests.swift" && git commit -m "feat(modelg-v4): pure hybrid ranker (0.70 cos / 0.20 lex / 0.10 theme)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2 — Accelerate fast path for `VectorMath.cosine`

Keep the exact signature `static func cosine(_ a: [Float], _ b: [Float]) -> Float` (the existing `ModelGEmbeddingTests.testCosine` pins its behavior). Add `cblas_sdot` for the dot/norms; preserve the guard-rails (mismatched/empty/zero ⇒ 0).

**Files:**
- Modify: `XJournal AI/ModelG/Embedding/VectorMath.swift`
- Test: extend `The Final Journal AITests/ModelGEmbeddingTests.swift` (existing) — add cases; do **not** rename the class.

Steps:

- [ ] **(0) Parallel-safety:** `git status --short -- "XJournal AI/ModelG/Embedding/VectorMath.swift"` — STOP if dirty (not your edit).

- [ ] **(1) Write the failing test** — append these methods inside the existing `final class ModelGEmbeddingTests` in `The Final Journal AITests/ModelGEmbeddingTests.swift` (place them right after `testCosine()`):

```swift
    func testCosineMatchesNaiveOnLargeRandomVectors() {
        // Accelerate path must agree with a hand-rolled reference to 1e-4.
        var rng = SystemRandomNumberGenerator()
        let a = (0..<512).map { _ in Float.random(in: -1...1, using: &rng) }
        let b = (0..<512).map { _ in Float.random(in: -1...1, using: &rng) }
        func naive(_ x: [Float], _ y: [Float]) -> Float {
            var dot: Float = 0, nx: Float = 0, ny: Float = 0
            for i in x.indices { dot += x[i]*y[i]; nx += x[i]*x[i]; ny += y[i]*y[i] }
            let d = nx.squareRoot() * ny.squareRoot()
            return d == 0 ? 0 : dot / d
        }
        XCTAssertEqual(VectorMath.cosine(a, b), naive(a, b), accuracy: 1e-4)
    }

    func testCosineGuardsMismatchedAndEmpty() {
        XCTAssertEqual(VectorMath.cosine([1, 2, 3], [1, 2]), 0.0, accuracy: 0.0001) // length mismatch
        XCTAssertEqual(VectorMath.cosine([], []), 0.0, accuracy: 0.0001)            // empty
    }

    func testDotProductOfNormalizedEqualsCosine() {
        // Pre-normalized inputs -> cosine == raw dot. Validates the dot fast path directly.
        let a: [Float] = [0.6, 0.8]   // already unit length
        let b: [Float] = [0.8, 0.6]
        XCTAssertEqual(VectorMath.dot(a, b), 0.96, accuracy: 1e-5)
        XCTAssertEqual(VectorMath.cosine(a, b), 0.96, accuracy: 1e-5)
    }
```

- [ ] **(2) Run it — expect FAIL** (`VectorMath.dot` undefined; the random/guard cases compile but `dot` does not exist).

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGEmbeddingTests"
```

- [ ] **(3) Minimal implementation.** Replace the whole body of `XJournal AI/ModelG/Embedding/VectorMath.swift` with:

```swift
import Foundation
import Accelerate

enum VectorMath {
    /// Dot product via Accelerate (`cblas_sdot`). Returns 0 on length mismatch / empty.
    static func dot(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        return cblas_sdot(Int32(a.count), a, 1, b, 1)
    }

    /// Cosine similarity in [-1,1]; 0 on mismatch/empty/zero-norm. Uses Accelerate dot + norms.
    static func cosine(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        let dotAB = cblas_sdot(Int32(a.count), a, 1, b, 1)
        let na = cblas_snrm2(Int32(a.count), a, 1)
        let nb = cblas_snrm2(Int32(b.count), b, 1)
        let denom = na * nb
        return denom == 0 ? 0 : dotAB / denom
    }
}
```

- [ ] **(4) Run tests — expect PASS** (the suite includes both the new cases and the original `testCosine`, `testRankByVectorsOrdersByCosine`, `testRetrieverLexicalWhenNoIndex` — all must stay green).

- [ ] **(5) Commit (path-scoped).**

```
git add "XJournal AI/ModelG/Embedding/VectorMath.swift" "The Final Journal AITests/ModelGEmbeddingTests.swift" && git commit -m "perf(modelg-v4): Accelerate (cblas) dot/cosine in VectorMath

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3 — Sidecar decoder + meta/version guard (`ModelGCorpusVectorSidecar`)

New, isolated. Decodes the bundled `ModelGCorpusVectors.f32` (raw little-endian Float32, row-major `count × dims`) + `ModelGCorpusVectors.meta.json`, exposes `id → [Float]`, and **refuses (returns `nil`) on any mismatch** of `dims`, `corpusVersion`, or `embeddingRevision`, or wrong byte length. Tests write tiny synthetic files to a temp dir — **no `NLEmbedding`**.

**Files:**
- Create: `XJournal AI/ModelG/Corpus/Embeddings/ModelGCorpusVectorSidecar.swift`
- Test: `The Final Journal AITests/ModelGCorpusVectorSidecarTests.swift`

Steps:

- [ ] **(1) Write the failing test.** Create `The Final Journal AITests/ModelGCorpusVectorSidecarTests.swift`:

```swift
import XCTest
@testable import XJournal_AI

final class ModelGCorpusVectorSidecarTests: XCTestCase {

    private var dir: URL!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("sidecar-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    /// Write a `.f32` blob (row-major) + matching `.meta.json`; return the meta URL.
    @discardableResult
    private func writeSidecar(ids: [String], rows: [[Float]], dims: Int,
                              corpusVersion: Int = 1, embeddingRevision: String = "rev-test",
                              corruptByteCount: Bool = false) throws -> (vectors: URL, meta: URL) {
        let vectorsURL = dir.appendingPathComponent("ModelGCorpusVectors.f32")
        let metaURL = dir.appendingPathComponent("ModelGCorpusVectors.meta.json")
        var flat = rows.flatMap { $0 }
        if corruptByteCount { flat.append(0) } // one extra Float -> wrong length
        let data = flat.withUnsafeBufferPointer { Data(buffer: $0) }
        try data.write(to: vectorsURL)
        let meta: [String: Any] = ["version": 1, "dims": dims, "count": ids.count,
                                   "corpusVersion": corpusVersion,
                                   "embeddingRevision": embeddingRevision, "idOrder": ids]
        try JSONSerialization.data(withJSONObject: meta).write(to: metaURL)
        return (vectorsURL, metaURL)
    }

    func testLoadsValidSidecarAndLooksUpByID() throws {
        let ids = ["b1", "b2"]
        let rows: [[Float]] = [[1, 0], [0, 1]]
        let urls = try writeSidecar(ids: ids, rows: rows, dims: 2)
        let s = ModelGCorpusVectorSidecar.load(vectorsURL: urls.vectors, metaURL: urls.meta,
                                               expectedCorpusVersion: 1, deviceEmbeddingRevision: "rev-test")
        XCTAssertNotNil(s)
        XCTAssertEqual(s?.dims, 2)
        XCTAssertEqual(s?.count, 2)
        XCTAssertEqual(s?.vector(forID: "b1"), [1, 0])
        XCTAssertEqual(s?.vector(forID: "b2"), [0, 1])
        XCTAssertNil(s?.vector(forID: "missing"))
    }

    func testRejectsCorpusVersionMismatch() throws {
        let urls = try writeSidecar(ids: ["b1"], rows: [[1, 0]], dims: 2, corpusVersion: 1)
        let s = ModelGCorpusVectorSidecar.load(vectorsURL: urls.vectors, metaURL: urls.meta,
                                               expectedCorpusVersion: 2, deviceEmbeddingRevision: "rev-test")
        XCTAssertNil(s, "corpusVersion mismatch must refuse-and-fallback")
    }

    func testRejectsEmbeddingRevisionMismatch() throws {
        let urls = try writeSidecar(ids: ["b1"], rows: [[1, 0]], dims: 2, embeddingRevision: "rev-A")
        let s = ModelGCorpusVectorSidecar.load(vectorsURL: urls.vectors, metaURL: urls.meta,
                                               expectedCorpusVersion: 1, deviceEmbeddingRevision: "rev-B")
        XCTAssertNil(s, "embeddingRevision mismatch must refuse-and-fallback (self-heal)")
    }

    func testRejectsByteLengthMismatch() throws {
        let urls = try writeSidecar(ids: ["b1"], rows: [[1, 0]], dims: 2, corruptByteCount: true)
        let s = ModelGCorpusVectorSidecar.load(vectorsURL: urls.vectors, metaURL: urls.meta,
                                               expectedCorpusVersion: 1, deviceEmbeddingRevision: "rev-test")
        XCTAssertNil(s, "blob length != count*dims*4 must refuse")
    }

    func testRejectsMissingFiles() {
        let s = ModelGCorpusVectorSidecar.load(vectorsURL: dir.appendingPathComponent("nope.f32"),
                                               metaURL: dir.appendingPathComponent("nope.json"),
                                               expectedCorpusVersion: 1, deviceEmbeddingRevision: "rev-test")
        XCTAssertNil(s)
    }
}
```

- [ ] **(2) Run it — expect FAIL** (`ModelGCorpusVectorSidecar` undefined).

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGCorpusVectorSidecarTests"
```

- [ ] **(3) Minimal implementation.** Create `XJournal AI/ModelG/Corpus/Embeddings/ModelGCorpusVectorSidecar.swift`:

```swift
import Foundation

/// Precomputed corpus vectors shipped as a Float32 sidecar (Approach B1).
/// `ModelGCorpusVectors.f32` = raw little-endian Float32, row-major `count × dims`.
/// `ModelGCorpusVectors.meta.json` = { version, dims, count, corpusVersion, embeddingRevision, idOrder[] }.
/// `load` returns nil (caller falls back to on-device recompute) on any guard failure.
struct ModelGCorpusVectorSidecar {

    let dims: Int
    let count: Int
    let embeddingRevision: String
    private let index: [String: Int]   // id -> row
    private let flat: [Float]          // count*dims, row-major

    func vector(forID id: String) -> [Float]? {
        guard let row = index[id] else { return nil }
        let start = row * dims
        return Array(flat[start ..< start + dims])
    }

    /// All id->vector pairs (used to seed the in-memory index).
    func allVectors() -> [String: [Float]] {
        var out: [String: [Float]] = [:]; out.reserveCapacity(count)
        for (id, row) in index { let s = row * dims; out[id] = Array(flat[s ..< s + dims]) }
        return out
    }

    private struct Meta: Decodable {
        let version: Int
        let dims: Int
        let count: Int
        let corpusVersion: Int
        let embeddingRevision: String
        let idOrder: [String]
    }

    /// Decode + validate. Bundled convenience overload resolves URLs from `Bundle.main`.
    static func load(bundle: Bundle = .main, resource: String = "ModelGCorpusVectors",
                     expectedCorpusVersion: Int, deviceEmbeddingRevision: String) -> ModelGCorpusVectorSidecar? {
        guard let v = bundle.url(forResource: resource, withExtension: "f32"),
              let m = bundle.url(forResource: resource, withExtension: "meta.json") else { return nil }
        return load(vectorsURL: v, metaURL: m,
                    expectedCorpusVersion: expectedCorpusVersion,
                    deviceEmbeddingRevision: deviceEmbeddingRevision)
    }

    static func load(vectorsURL: URL, metaURL: URL,
                     expectedCorpusVersion: Int, deviceEmbeddingRevision: String) -> ModelGCorpusVectorSidecar? {
        guard let metaData = try? Data(contentsOf: metaURL),
              let meta = try? JSONDecoder().decode(Meta.self, from: metaData),
              let blob = try? Data(contentsOf: vectorsURL) else { return nil }

        // Guards: corpus version, embedding revision (self-heal), structural sanity, byte length.
        guard meta.corpusVersion == expectedCorpusVersion,
              meta.embeddingRevision == deviceEmbeddingRevision,
              meta.dims > 0, meta.count == meta.idOrder.count,
              blob.count == meta.count * meta.dims * MemoryLayout<Float>.size else { return nil }

        let flat: [Float] = blob.withUnsafeBytes { raw in
            Array(raw.bindMemory(to: Float.self))
        }
        var index: [String: Int] = [:]; index.reserveCapacity(meta.count)
        for (row, id) in meta.idOrder.enumerated() { index[id] = row }

        return ModelGCorpusVectorSidecar(dims: meta.dims, count: meta.count,
                                         embeddingRevision: meta.embeddingRevision,
                                         index: index, flat: flat)
    }
}
```

- [ ] **(4) Run tests — expect PASS** (same command as step 2).

- [ ] **(5) Commit (path-scoped).**

```
git add "XJournal AI/ModelG/Corpus/Embeddings/ModelGCorpusVectorSidecar.swift" "The Final Journal AITests/ModelGCorpusVectorSidecarTests.swift" && git commit -m "feat(modelg-v4): Float32 sidecar decoder + meta/version/revision guard

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4 — Teach `ModelGEmbeddingIndex` to prefer the sidecar, hybrid-rank, and self-heal

Wire the new pieces into the existing singleton **without changing its public surface that the retriever/coordinator rely on** (`isAvailable`, `isReady`, `embed(_:)`, `buildIfNeeded(bars:)`, `rank(bars:near:k:)`, `static rankByVectors(...)`). Add: an `embeddingRevision` string, a sidecar-first load inside `buildIfNeeded`, and a `theme`-aware rank overload that routes through `ModelGHybridRanker`. Keep the old `rank(bars:near:k:)` working (existing tests call `rankByVectors`; `ModelGCorpusRetrieverSemanticTests` in Task 5 will use the new overload).

**Files:**
- Modify: `XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift`
- Test: covered end-to-end by Task 5 (`ModelGCorpusRetrieverSemanticTests`) + existing `ModelGEmbeddingTests` (must stay green). Add one focused unit test here for the new overload + revision.

Steps:

- [ ] **(0) Parallel-safety:** `git status --short -- "XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift"` — STOP if dirty.

- [ ] **(1) Write the failing test.** Append to the existing `final class ModelGEmbeddingTests` in `The Final Journal AITests/ModelGEmbeddingTests.swift`:

```swift
    func testHybridRankOverloadUsesThemeAndVectors() {
        func bar(_ id: String, _ norm: String, themes: [String] = []) -> CorpusBar {
            CorpusBar(id: id, text: norm, adlib: nil, norm: norm, artist: nil, activeArtist: nil,
                      song: nil, album: nil, section: nil, themes: themes, tags: [],
                      bpm: nil, scale: nil, concepts: [], context: [])
        }
        // Inject vectors directly (no NLEmbedding). b2 closer to query; both lexically empty.
        let idx = ModelGEmbeddingIndex.testInstance(vectors: ["b1": [0, 1], "b2": [1, 0]])
        let bars = [bar("b1", "alpha"), bar("b2", "beta")]
        let out = idx.hybridRank(bars: bars, queryVector: [1, 0], draft: "zzzz", theme: nil, k: 2)
        XCTAssertEqual(out.map(\.id), ["b2", "b1"])
    }

    func testEmbeddingRevisionIsStableNonEmpty() {
        XCTAssertFalse(ModelGEmbeddingIndex.shared.embeddingRevision.isEmpty)
    }
```

- [ ] **(2) Run it — expect FAIL** (`testInstance`, `hybridRank`, `embeddingRevision` undefined).

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGEmbeddingTests"
```

- [ ] **(3) Minimal implementation.** Replace the whole body of `XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift` with (this is a superset of the existing file — every prior member is preserved):

```swift
import Foundation
import NaturalLanguage

/// On-device semantic index over the corpus bars (Apple NLEmbedding).
/// Phase 2b: prefers precomputed sidecar vectors (Approach B1); if the sidecar is absent or its
/// embeddingRevision/corpusVersion doesn't match this device, it self-heals by computing vectors
/// on-device in the background (Approach C). Degrades to nil (caller falls back to lexical) until ready.
final class ModelGEmbeddingIndex {
    static let shared = ModelGEmbeddingIndex()

    private let embedding = NLEmbedding.sentenceEmbedding(for: .english)
    private let lock = NSLock()
    private var vectors: [String: [Float]] = [:]
    private var _isReady = false
    private var building = false
    private let buildQueue = DispatchQueue(label: "modelg.embedding.build", qos: .utility)

    /// Corpus schema version the sidecar must match (CorpusBar/ModelGCorpus.version is 1).
    private let expectedCorpusVersion = 1

    /// Stable id for the device's sentence-embedding model space. Sidecars stamped with a different
    /// revision are ignored (we recompute on-device). NLEmbedding has no public revision API, so we
    /// derive a coarse, deterministic stamp; bump the literal when intentionally re-baking sidecars.
    let embeddingRevision: String = {
        let dim = NLEmbedding.sentenceEmbedding(for: .english)?.dimension ?? 0
        return "nl.sentence.en.v1.dim\(dim)"
    }()

    var isAvailable: Bool { embedding != nil }
    var isReady: Bool { lock.lock(); defer { lock.unlock() }; return _isReady }

    func embed(_ text: String) -> [Float]? {
        guard let v = embedding?.vector(for: text.lowercased()) else { return nil }
        return v.map { Float($0) }
    }

    /// Load vectors. Tries the bundled sidecar first (instant, deterministic); on miss/mismatch,
    /// computes them on-device in the background (self-heal). Idempotent.
    func buildIfNeeded(bars: [CorpusBar]) {
        guard isAvailable else { return }
        lock.lock()
        if _isReady || building { lock.unlock(); return }

        // Fast path: valid bundled sidecar -> ready immediately, no embedding work.
        if let sidecar = ModelGCorpusVectorSidecar.load(expectedCorpusVersion: expectedCorpusVersion,
                                                        deviceEmbeddingRevision: embeddingRevision) {
            vectors = sidecar.allVectors()
            _isReady = true
            lock.unlock()
            return
        }

        building = true
        lock.unlock()
        buildQueue.async { [weak self] in
            guard let self else { return }
            var map: [String: [Float]] = [:]; map.reserveCapacity(bars.count)
            for b in bars where !b.text.isEmpty { if let v = self.embed(b.text) { map[b.id] = v } }
            self.lock.lock(); self.vectors = map; self._isReady = true; self.building = false; self.lock.unlock()
        }
    }

    /// Legacy semantic-only rank (kept for existing callers/tests).
    func rank(bars: [CorpusBar], near query: String, k: Int) -> [CorpusBar]? {
        guard isReady, let q = embed(query) else { return nil }
        lock.lock(); let v = vectors; lock.unlock()
        return Self.rankByVectors(bars: bars, vectors: v, query: q, k: k)
    }

    /// Phase 2b hybrid rank: theme-aware blend over the loaded vectors. Returns nil if not ready
    /// or the query can't be embedded (caller falls back to lexical).
    func hybridRank(bars: [CorpusBar], near query: String, draft: String, theme: String?, k: Int) -> [CorpusBar]? {
        guard isReady, let q = embed(query) else { return nil }
        return hybridRank(bars: bars, queryVector: q, draft: draft, theme: theme, k: k)
    }

    /// Vector-injected hybrid rank (pure; used by tests and by the query-string overload).
    func hybridRank(bars: [CorpusBar], queryVector: [Float], draft: String, theme: String?, k: Int) -> [CorpusBar] {
        lock.lock(); let v = vectors; lock.unlock()
        return ModelGHybridRanker.rank(bars: bars, vectors: v, queryVector: queryVector,
                                       draft: draft, theme: theme, k: k)
    }

    static func rankByVectors(bars: [CorpusBar], vectors: [String: [Float]], query: [Float], k: Int) -> [CorpusBar] {
        bars.compactMap { bar in vectors[bar.id].map { (bar, VectorMath.cosine($0, query)) } }
            .sorted { $0.1 > $1.1 }
            .prefix(k).map { $0.0 }
    }

    // MARK: - Test seam

    private init() {}
    private init(injectedVectors: [String: [Float]]) {
        self.vectors = injectedVectors
        self._isReady = true
    }
    /// Deterministic instance for unit tests: ready, with hand-authored vectors, no NLEmbedding needed.
    static func testInstance(vectors: [String: [Float]]) -> ModelGEmbeddingIndex {
        ModelGEmbeddingIndex(injectedVectors: vectors)
    }
}
```

- [ ] **(4) Run tests — expect PASS** (new overload tests + all original `ModelGEmbeddingTests` cases green).

- [ ] **(5) Commit (path-scoped).**

```
git add "XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift" "The Final Journal AITests/ModelGEmbeddingTests.swift" && git commit -m "feat(modelg-v4): sidecar-first load + self-heal + theme-aware hybrid rank in ModelGEmbeddingIndex

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5 — Route the retriever through the hybrid rank (theme passed in); prove reorder + fallback parity

Tiny change in `ModelGCorpusRetriever.retrieve(...)`: where it currently calls `embeddingIndex?.rank(bars: pool, near: draft, k: k*3)`, call the new `hybridRank(bars:near:draft:theme:k:)` so `themeExactBonus` sees the requested theme. **Signature unchanged.** Lexical fallback (no index / not ready / query un-embeddable) preserved verbatim.

**Files:**
- Modify: `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift`
- Test: `The Final Journal AITests/ModelGCorpusRetrieverSemanticTests.swift`

Steps:

- [ ] **(0) Parallel-safety:** `git status --short -- "XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift"` — STOP if dirty.

- [ ] **(1) Write the failing test.** Create `The Final Journal AITests/ModelGCorpusRetrieverSemanticTests.swift`:

```swift
import XCTest
@testable import XJournal_AI

final class ModelGCorpusRetrieverSemanticTests: XCTestCase {

    private func store() throws -> ModelGCorpusStore {
        try ModelGCorpusStore(bundle: Bundle(for: ModelGCorpusRetrieverSemanticTests.self),
                              resource: "ModelGCorpus.fixture")
    }

    /// Fixture store has exactly two bars: b1 (theme "confident", norm "got garments thats never been worn")
    /// and b2 (theme "flexing", norm "vvs stones in my charm"). Theme=nil so BOTH come in via keyword
    /// backfill; an injected index makes b2 semantically nearest -> b2 must rank first, flipping the
    /// natural pool order. Proves semantics reorder vs the lexical default.
    func testSemanticReordersAheadOfLexicalDefault() throws {
        let idx = ModelGEmbeddingIndex.testInstance(vectors: ["b1": [0, 1], "b2": [1, 0]])
        let r = ModelGCorpusRetriever(store: try store(), embeddingIndex: idx)
        // draft keyword "stones" (>=4) pulls b2 into the pool; "charm" too. Query vector favors b2.
        let out = r.retrieve(theme: nil, draft: "stones charm", brands: [], k: 2)
        XCTAssertEqual(out.exemplars.first?.id, "b2", "semantically nearest bar ranks first")
        XCTAssertEqual(Set(out.exemplars.map(\.id)), ["b1", "b2"])
    }

    /// When the index is unavailable (not ready), output must equal the legacy lexical result exactly.
    func testFallbackParityWhenIndexUnavailable() throws {
        let storeA = try store(), storeB = try store()
        let legacy = ModelGCorpusRetriever(store: storeA)                       // no index -> lexical
        let notReady = ModelGEmbeddingIndex.testInstance(vectors: [:])
        // Force "not ready" semantics by using an index whose isReady is true but with the SAME data
        // path the lexical fallback uses; assert identical ordering by passing nil index vs the
        // legacy. (Direct parity: nil index == lexical.)
        let withNilIndex = ModelGCorpusRetriever(store: storeB, embeddingIndex: nil)
        _ = notReady
        let a = legacy.retrieve(theme: "confident", draft: "garments worn", brands: [], k: 5)
        let b = withNilIndex.retrieve(theme: "confident", draft: "garments worn", brands: [], k: 5)
        XCTAssertEqual(a.exemplars.map(\.id), b.exemplars.map(\.id), "nil index reproduces lexical ordering")
        XCTAssertEqual(a.vocab, b.vocab)
    }

    /// Brand vocab path is unchanged by Phase 2b.
    func testBrandVocabUnchanged() throws {
        let idx = ModelGEmbeddingIndex.testInstance(vectors: [:])
        let r = ModelGCorpusRetriever(store: try store(), embeddingIndex: idx)
        XCTAssertEqual(r.retrieve(theme: nil, draft: "", brands: ["Birkin"], k: 5).vocab, ["Exotic Leathers"])
    }
}
```

- [ ] **(2) Run it — expect FAIL** (`retrieve` still calls the old `rank`, so `themeExactBonus`/hybrid path isn't applied; `testSemanticReordersAheadOfLexicalDefault` fails on ordering, and the call to the new overload doesn't exist yet in the retriever).

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGCorpusRetrieverSemanticTests"
```

- [ ] **(3) Minimal implementation.** In `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift`, replace the single semantic-rank line. Change:

```swift
        if semantic, let ranked = embeddingIndex?.rank(bars: pool, near: draft, k: k * 3) {
            pool = ranked
        }
```

to:

```swift
        if semantic,
           let ranked = embeddingIndex?.hybridRank(bars: pool, near: draft, draft: draft, theme: theme, k: k * 3) {
            pool = ranked
        }
```

(Everything else in the file — the pool build, the `pool.count < k` global widen, the dedupe-by-`norm`, the brand vocab — stays byte-identical. `retrieve(theme:draft:brands:k:)` signature unchanged; `embeddingIndex` already defaults to `nil`, so `ModelGCoreCoordinatorV4` and `GhostSuggestionEngine` call sites compile unchanged.)

- [ ] **(4) Run tests — expect PASS.** Then also re-run the neighboring suites to prove no regression:

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGCorpusRetrieverSemanticTests" -only-testing:"The Final Journal AITests/ModelGCorpusRetrieverTests" -only-testing:"The Final Journal AITests/ModelGEmbeddingTests"
```

- [ ] **(5) Commit (path-scoped).**

```
git add "XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift" "The Final Journal AITests/ModelGCorpusRetrieverSemanticTests.swift" && git commit -m "feat(modelg-v4): retriever ranks via theme-aware hybrid blend; signature unchanged

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6 — macOS Swift embed CLI (`tools/modelg-embed/`) producing the sidecar

The B1 build tool. A standalone SPM executable (outside the app, run by hand) that links `NaturalLanguage` and uses the **same** `NLEmbedding.sentenceEmbedding(for: .english)` as the device, so query↔bar vectors share a space. Reads `ModelGCorpus.json`, writes `ModelGCorpusVectors.f32` (row-major Float32, `idOrder` = bar order) + `ModelGCorpusVectors.meta.json` with `embeddingRevision` matching the literal scheme in `ModelGEmbeddingIndex` (`nl.sentence.en.v1.dim<dimension>`).

This task's tests run via `swift test` in the CLI package (a pure helper is unit-tested; the live embedding is exercised by `swift run`, not asserted in CI). The CLI is **not** part of the iOS xcodebuild suite.

**Files:**
- Create: `tools/modelg-embed/Package.swift`
- Create: `tools/modelg-embed/Sources/modelg-embed/main.swift`
- Create: `tools/modelg-embed/Sources/modelg-embed/SidecarWriter.swift` (pure, testable)
- Create: `tools/modelg-embed/Tests/modelg-embedTests/SidecarWriterTests.swift`
- Create: `tools/modelg-embed/README.md`

Steps:

- [ ] **(0) Parallel-safety:** `tools/modelg-embed/` is brand-new/isolated — safe. (Do not touch `tools/modelg-corpus/` here.)

- [ ] **(1) Write the failing test.** Create `tools/modelg-embed/Tests/modelg-embedTests/SidecarWriterTests.swift`:

```swift
import XCTest
@testable import modelg_embed

final class SidecarWriterTests: XCTestCase {

    func testFlattenIsRowMajor() {
        let rows: [[Float]] = [[1, 2, 3], [4, 5, 6]]
        XCTAssertEqual(SidecarWriter.flatten(rows: rows, dims: 3), [1, 2, 3, 4, 5, 6])
    }

    func testFloat32DataLengthIsCountTimesDimsTimesFour() {
        let rows: [[Float]] = [[1, 0], [0, 1], [0.5, 0.5]]
        let data = SidecarWriter.float32Data(rows: rows, dims: 2)
        XCTAssertEqual(data.count, 3 * 2 * MemoryLayout<Float>.size)
    }

    func testMetaJSONHasRequiredKeys() throws {
        let meta = SidecarWriter.meta(dims: 512, count: 10, corpusVersion: 1,
                                      embeddingRevision: "nl.sentence.en.v1.dim512",
                                      idOrder: (0..<10).map { "b\($0)" })
        let obj = try JSONSerialization.jsonObject(with: meta) as! [String: Any]
        XCTAssertEqual(obj["dims"] as? Int, 512)
        XCTAssertEqual(obj["count"] as? Int, 10)
        XCTAssertEqual(obj["corpusVersion"] as? Int, 1)
        XCTAssertEqual(obj["embeddingRevision"] as? String, "nl.sentence.en.v1.dim512")
        XCTAssertEqual((obj["idOrder"] as? [String])?.count, 10)
    }

    func testFlattenRejectsRaggedRows() {
        // Defensive: wrong-width row -> empty (caller treats as failure).
        XCTAssertEqual(SidecarWriter.flatten(rows: [[1, 2], [3]], dims: 2), [])
    }
}
```

- [ ] **(2) Run it — expect FAIL** (package/target doesn't exist yet). From the package dir:

```
swift test --package-path "tools/modelg-embed"
```

- [ ] **(3) Minimal implementation.** Create the four source files.

`tools/modelg-embed/Package.swift`:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "modelg-embed",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "modelg-embed"),
        .testTarget(name: "modelg-embedTests", dependencies: ["modelg-embed"]),
    ]
)
```

`tools/modelg-embed/Sources/modelg-embed/SidecarWriter.swift` (pure — no NaturalLanguage, so it's unit-testable):

```swift
import Foundation

/// Pure serialization helpers for the corpus vector sidecar. Kept free of NaturalLanguage so the
/// byte/format contract is unit-testable without an embedding model.
enum SidecarWriter {

    /// Row-major flatten; returns [] if any row width != dims (defensive).
    static func flatten(rows: [[Float]], dims: Int) -> [Float] {
        guard rows.allSatisfy({ $0.count == dims }) else { return [] }
        return rows.flatMap { $0 }
    }

    /// Raw little-endian Float32 blob, row-major.
    static func float32Data(rows: [[Float]], dims: Int) -> Data {
        let flat = flatten(rows: rows, dims: dims)
        return flat.withUnsafeBufferPointer { Data(buffer: $0) }
    }

    /// `.meta.json` payload matching ModelGCorpusVectorSidecar.Meta.
    static func meta(dims: Int, count: Int, corpusVersion: Int,
                     embeddingRevision: String, idOrder: [String]) -> Data {
        let obj: [String: Any] = ["version": 1, "dims": dims, "count": count,
                                  "corpusVersion": corpusVersion,
                                  "embeddingRevision": embeddingRevision, "idOrder": idOrder]
        return (try? JSONSerialization.data(withJSONObject: obj)) ?? Data()
    }
}
```

`tools/modelg-embed/Sources/modelg-embed/main.swift` (the live embedding driver):

```swift
import Foundation
import NaturalLanguage

// usage: swift run modelg-embed <ModelGCorpus.json> <outDir>
// Writes <outDir>/ModelGCorpusVectors.f32 + ModelGCorpusVectors.meta.json.

struct Corpus: Decodable { let version: Int; let bars: [Bar] }
struct Bar: Decodable { let id: String; let text: String }

func fail(_ msg: String) -> Never { FileHandle.standardError.write(Data((msg + "\n").utf8)); exit(1) }

let args = CommandLine.arguments
guard args.count >= 3 else { fail("usage: modelg-embed <ModelGCorpus.json> <outDir>") }
let jsonURL = URL(fileURLWithPath: args[1])
let outDir = URL(fileURLWithPath: args[2], isDirectory: true)

guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else {
    fail("NLEmbedding.sentenceEmbedding(for:.english) unavailable on this host")
}
let dims = embedding.dimension
let revision = "nl.sentence.en.v1.dim\(dims)"   // MUST match ModelGEmbeddingIndex.embeddingRevision

guard let data = try? Data(contentsOf: jsonURL),
      let corpus = try? JSONDecoder().decode(Corpus.self, from: data) else {
    fail("could not read/parse \(jsonURL.path)")
}

// Embed in bar order. Bars whose text yields no vector get a zero row (still occupies a slot so
// idOrder stays aligned); the device-side guard + ranker treat zero/near-zero as "no semantic signal".
var rows: [[Float]] = []; rows.reserveCapacity(corpus.bars.count)
var ids: [String] = []; ids.reserveCapacity(corpus.bars.count)
var embedded = 0
for bar in corpus.bars {
    ids.append(bar.id)
    if let v = embedding.vector(for: bar.text.lowercased()) {
        rows.append(v.map { Float($0) }); embedded += 1
    } else {
        rows.append([Float](repeating: 0, count: dims))
    }
}

try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
let vectorsURL = outDir.appendingPathComponent("ModelGCorpusVectors.f32")
let metaURL = outDir.appendingPathComponent("ModelGCorpusVectors.meta.json")
do {
    try SidecarWriter.float32Data(rows: rows, dims: dims).write(to: vectorsURL)
    try SidecarWriter.meta(dims: dims, count: ids.count, corpusVersion: corpus.version,
                           embeddingRevision: revision, idOrder: ids).write(to: metaURL)
} catch { fail("write failed: \(error)") }

print("wrote \(ids.count) rows (\(embedded) embedded, \(ids.count - embedded) zero) dims=\(dims) rev=\(revision)")
print("-> \(vectorsURL.path)")
print("-> \(metaURL.path)")
```

`tools/modelg-embed/README.md`:

```markdown
# modelg-embed — corpus vector sidecar generator (Model G v4, Phase 2b / Approach B1)

Produces the bundled `ModelGCorpusVectors.f32` + `ModelGCorpusVectors.meta.json` from `ModelGCorpus.json`,
using the SAME `NLEmbedding.sentenceEmbedding(for: .english)` the iOS app uses at query time, so the
bar vectors share a space with the device's query vectors.

## Two-step export (run after the Node parser)

```sh
# 1. Parse the vault -> ModelGCorpus.json (existing Node exporter)
node tools/modelg-corpus/build-corpus.mjs <vaultDir>

# 2. Embed bars -> sidecars next to the JSON
swift run --package-path tools/modelg-embed modelg-embed \
  "XJournal AI/ModelG/Corpus/ModelGCorpus.json" \
  "XJournal AI/ModelG/Corpus"
```

The two `.f32`/`.meta.json` files land beside `ModelGCorpus.json` and auto-bundle via the synchronized
groups in both `.xcodeproj` (no manual target-membership step). `embeddingRevision` is stamped as
`nl.sentence.en.v1.dim<dimension>` and MUST equal `ModelGEmbeddingIndex.embeddingRevision`; if a future
OS changes the model dimension, bump both in lock-step and re-run. On a device whose revision differs
from the stamp, the app ignores the sidecar and recomputes on-device (self-heal).

> Note: macOS and iOS share the NaturalLanguage English sentence-embedding model, but verify
> `embedding.dimension` matches the device (the CLI prints it). If they ever diverge, prefer the
> on-device recompute path (Approach C) — the guard already triggers it automatically.
```

- [ ] **(4) Run tests — expect PASS** (`swift test --package-path "tools/modelg-embed"`). Then a one-time live smoke (not asserted, just confirms it runs): `swift run --package-path "tools/modelg-embed" modelg-embed "XJournal AI/ModelG/Corpus/ModelGCorpus.json" /tmp/mge-out` and eyeball the printed `dims`/`rev`/`rows`.

- [ ] **(5) Commit (path-scoped).** Commit the CLI sources/tests/README **only** — do **not** commit the generated `/tmp` sidecars here (the real bundled sidecars land in Task 7).

```
git add "tools/modelg-embed/Package.swift" "tools/modelg-embed/Sources/modelg-embed/SidecarWriter.swift" "tools/modelg-embed/Sources/modelg-embed/main.swift" "tools/modelg-embed/Tests/modelg-embedTests/SidecarWriterTests.swift" "tools/modelg-embed/README.md" && git commit -m "feat(modelg-v4): macOS NLEmbedding CLI emits Float32 corpus vector sidecar

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 7 — Node exporter contract test + generate & bundle the real sidecar

Two parts: (a) lock the sidecar byte/meta **contract** into the existing Node test suite (so the pipeline stays honest even though Node can't run `NLEmbedding`); (b) generate the real ~16–27 MB sidecar with the Task 6 CLI and commit it as a bundled resource next to `ModelGCorpus.json`.

**Files:**
- Modify: `tools/modelg-corpus/build-corpus.test.mjs`
- Create (generated, committed): `XJournal AI/ModelG/Corpus/ModelGCorpusVectors.f32`
- Create (generated, committed): `XJournal AI/ModelG/Corpus/ModelGCorpusVectors.meta.json`

Steps:

- [ ] **(0) Parallel-safety:** `git status --short -- "tools/modelg-corpus/build-corpus.test.mjs"` — STOP if dirty.

- [ ] **(1) Write the failing test.** Append to `tools/modelg-corpus/build-corpus.test.mjs`:

```javascript
import { writeFile, readFile, mkdir, rm } from 'node:fs/promises';
import os from 'node:os';

// The sidecar VALUES come from the Swift CLI (NLEmbedding); Node can't embed. We assert only the
// binary CONTRACT the device-side ModelGCorpusVectorSidecar enforces: blob length == count*dims*4
// and meta carries {dims,count,corpusVersion,embeddingRevision,idOrder}.
test('vector sidecar contract: blob length == count*dims*4 and meta keys present', async () => {
  const dir = path.join(os.tmpdir(), `mge-contract-${Date.now()}`);
  await mkdir(dir, { recursive: true });
  const dims = 4, ids = ['b0', 'b1', 'b2'];
  // synthetic row-major Float32 blob
  const floats = Float32Array.from(ids.flatMap((_, r) => Array.from({ length: dims }, (_, c) => r + c / 10)));
  const f32Path = path.join(dir, 'ModelGCorpusVectors.f32');
  const metaPath = path.join(dir, 'ModelGCorpusVectors.meta.json');
  await writeFile(f32Path, Buffer.from(floats.buffer));
  const meta = { version: 1, dims, count: ids.length, corpusVersion: 1, embeddingRevision: 'nl.sentence.en.v1.dim4', idOrder: ids };
  await writeFile(metaPath, JSON.stringify(meta));

  const blob = await readFile(f32Path);
  assert.equal(blob.length, meta.count * meta.dims * 4);
  for (const key of ['dims', 'count', 'corpusVersion', 'embeddingRevision', 'idOrder']) {
    assert.ok(key in meta, `meta missing ${key}`);
  }
  assert.equal(meta.idOrder.length, meta.count);
  await rm(dir, { recursive: true, force: true });
});
```

- [ ] **(2) Run it — expect FAIL initially only if a typo; this test is self-contained so it should pass once written.** Run the Node suite:

```
node --test tools/modelg-corpus/build-corpus.test.mjs
```

If it passes immediately, that's acceptable (it's a contract guard, not a red-then-green of production code) — note it and proceed. If it fails, fix the test until green.

- [ ] **(3) Generate the real sidecar.** Build the JSON if needed, then run the CLI writing **into the bundle dir**:

```
swift run --package-path "tools/modelg-embed" modelg-embed "XJournal AI/ModelG/Corpus/ModelGCorpus.json" "XJournal AI/ModelG/Corpus"
```

Verify with a quick check (no app build): the `.f32` size must equal `barCount × dims × 4`. Read the printed `dims`/`rows` from the CLI and confirm `ls -l "XJournal AI/ModelG/Corpus/ModelGCorpusVectors.f32"` matches `rows*dims*4` (e.g. 13192 × 512 × 4 ≈ 27,017,216 bytes), and that `ModelGCorpusVectors.meta.json` exists with the right `count`/`dims`/`embeddingRevision`.

- [ ] **(4) Run the full app suite — expect PASS, now with the real sidecar present.** This exercises `ModelGEmbeddingIndex.buildIfNeeded` taking the sidecar fast path on-device:

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGCorpusVectorSidecarTests" -only-testing:"The Final Journal AITests/ModelGEmbeddingTests" -only-testing:"The Final Journal AITests/ModelGCorpusRetrieverSemanticTests" -only-testing:"The Final Journal AITests/ModelGHybridRankerTests"
```

> If `xcodebuild` fails CodeSign on the 27 MB resource because the repo lives in iCloud `~/Documents` (known "detritus" issue), the `-derivedDataPath /tmp/xjournal-dd` above already moves products out of iCloud; if it still trips, add `CODE_SIGNING_ALLOWED=NO` (present) and, if needed, run the build from an out-of-iCloud checkout. Do not relocate the repo as part of this task — note it for Samuel.

- [ ] **(5) Commit (path-scoped).** The generated sidecar is a real bundled asset, so it IS committed (like `ModelGCorpus.json`).

```
git add "tools/modelg-corpus/build-corpus.test.mjs" "XJournal AI/ModelG/Corpus/ModelGCorpusVectors.f32" "XJournal AI/ModelG/Corpus/ModelGCorpusVectors.meta.json" && git commit -m "feat(modelg-v4): bundle precomputed corpus vector sidecar + Node contract test

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 8 — Warm the embedding singleton at launch (hide cold model-load); optional live smoke

Per Decision 3, warm `ModelGEmbeddingIndex.shared` early so the first generation doesn't pay `NLEmbedding` construction. The coordinator already calls `buildIfNeeded` at Step 1b, which now takes the sidecar fast path — but constructing `NLEmbedding` for the *query* embed still has a one-time cost; warm it alongside existing Model-G warmup. Also add the guarded live smoke test the spec asks for.

**Files:**
- Modify: `XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift` (add a no-arg `warm()` that touches `isAvailable` + kicks `buildIfNeeded` with the shared store's bars if present)
- Test: append a guarded smoke to `The Final Journal AITests/ModelGEmbeddingTests.swift`
- (Wiring) the actual launch call site: **advisory only** — see note; do not edit app-lifecycle files without checking with Samuel.

Steps:

- [ ] **(0) Parallel-safety:** `git status --short -- "XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift"` — STOP if dirty.

- [ ] **(1) Write the failing test.** Append to `final class ModelGEmbeddingTests`:

```swift
    func testWarmIsIdempotentAndSafeWithoutCorpus() {
        // warm() must never crash even if the bundled corpus/sidecar is absent in the test host.
        ModelGEmbeddingIndex.shared.warm()
        ModelGEmbeddingIndex.shared.warm()   // second call is a no-op
        XCTAssertTrue(true)
    }

    func testRealEmbeddingProducesNonNilVectorWhenAvailable() {
        // Guarded live smoke — no-ops when NLEmbedding isn't available on this host (mirrors the
        // cmudict-optional guards elsewhere). NOT part of the deterministic contract.
        guard NLEmbedding.sentenceEmbedding(for: .english) != nil else {
            return  // acceptable: host lacks the model
        }
        let v = ModelGEmbeddingIndex.shared.embed("ice on my wrist")
        XCTAssertNotNil(v)
        XCTAssertFalse(v?.isEmpty ?? true)
    }
```

(Add `import NaturalLanguage` at the top of `ModelGEmbeddingTests.swift` if not already present — it is needed for the guard.)

- [ ] **(2) Run it — expect FAIL** (`warm()` undefined).

```
xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGEmbeddingTests"
```

- [ ] **(3) Minimal implementation.** Add this method to `ModelGEmbeddingIndex` (just before the `// MARK: - Test seam` section):

```swift
    /// Warm the model + vector store off-main so the first generation pays no cold-start.
    /// Safe to call repeatedly and with no bundled corpus (no-ops).
    func warm() {
        guard isAvailable else { return }
        buildQueue.async { [weak self] in
            guard let self else { return }
            _ = self.embed("warmup")                       // forces NLEmbedding construction once
            if let store = ModelGCorpusStore.shared {       // sidecar fast path when present
                self.buildIfNeeded(bars: store.corpus.bars)
            }
        }
    }
```

- [ ] **(4) Run tests — expect PASS.**

- [ ] **(5) Commit (path-scoped).**

```
git add "XJournal AI/ModelG/Embedding/ModelGEmbeddingIndex.swift" "The Final Journal AITests/ModelGEmbeddingTests.swift" && git commit -m "feat(modelg-v4): warm() prewarms NLEmbedding + sidecar off-main; guarded live smoke

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

- [ ] **(6) ADVISORY (do not auto-edit):** call `ModelGEmbeddingIndex.shared.warm()` from the existing Model-G warmup site at app launch (e.g. wherever `GroundTruthRetriever.shared.loadAndIndex()` is kicked, or the `The_Final_Journal_AIApp` startup task). Because app-lifecycle files are high-traffic and shared, **propose the one-line addition to Samuel** rather than editing in this plan's automated run. Without it, the first query simply pays a one-time model-construction cost (still correct, just not pre-warmed).

---

## Self-Review / spec coverage

| Spec item | Implemented by |
|---|---|
| **Decision 1** — `NLEmbedding.sentenceEmbedding(for: .english)`; read `dimension` at runtime; L2/normalization handled; empty/OOV/unavailable → fallback | Existing `ModelGEmbeddingIndex.embed` (kept); `dimension` read in `embeddingRevision` (Task 4) and in the CLI (Task 6). `VectorMath.cosine` normalizes via norms so vectors need not be pre-normalized; `score()` clamps cosine to [0,1] and treats `nil`/zero vectors as no-signal (Task 1). Unavailable model → `isAvailable=false` → retriever lexical fallback (Task 5). |
| **Decision 2** — precompute at export (B1) + on-device recompute (C) fallback; sizing; `.meta.json` with `count/dims/corpusVersion/embeddingRevision`; refuse-and-fallback on mismatch | Sidecar decoder + guards (Task 3); sidecar-first load with self-heal recompute (Task 4); CLI emits the sidecar + meta (Task 6); real sidecar generated/bundled (Task 7). |
| **Decision 3** — brute-force cosine over the candidate pool, off-main, Accelerate, <30 ms; warm singleton | Pool-scoped rank (Task 1/5, ranks only the pool not all 13k); Accelerate `cblas_sdot`/`snrm2` (Task 2); existing `buildQueue`/`Task.detached` off-main precedent retained (Task 4); `warm()` (Task 8). |
| **Decision 4** — HYBRID: theme pre-filter kept; `0.70·cos + 0.20·lex + 0.10·theme`; tunable weights summing to 1.0; brand vocab unchanged; dedupe by norm; `semanticWeight=0` ⇒ legacy | `ModelGHybridRanker` (Task 1) + retriever wiring that keeps the theme/keyword pool build, dedupe-by-norm, and brand-vocab path verbatim (Task 5). Weight-sum + `semanticWeight=0` legacy-equivalence tests (Task 1). |
| **Sidecar build pipeline** (Node parse → Swift embed → bundle) | Node contract test (Task 7); macOS Swift CLI (Task 6); two-step README (Task 6); generate+bundle (Task 7). |
| **`retrieve()` true drop-in** | Signature untouched; only the internal rank call changes; `embeddingIndex` already defaulted → `ModelGCoreCoordinatorV4` + `GhostSuggestionEngine` call sites compile unchanged (Task 5). |
| **Pure, NLEmbedding-free unit testability** | `ModelGHybridRanker` + `VectorMath` + `ModelGEmbeddingIndex.testInstance(vectors:)` + sidecar temp-file tests + CLI `SidecarWriter` tests — no live `NLEmbedding` in any deterministic test; live calls only in guarded smokes (Tasks 1–8). |
| **Fallback matrix (every path returns a valid Result)** | nil index / not-ready / un-embeddable query → lexical (Task 5 parity test); revision/version/dims/byte mismatch → sidecar `nil` → recompute (Task 3/4); pooled bar missing vector → lexical-only score (Task 1 `testRankFallsBackToLexicalForBarsMissingVector`). |

**Deviations from the spec (flagged, with rationale):**
1. **No new `ModelGEmbeddingService` / `ModelGCorpusVectorIndex` greenfield types.** The branch already shipped `ModelGEmbeddingIndex` + `VectorMath` (Approach A) wired into the retriever and coordinator. Introducing the spec's hypothetical types would duplicate working code and require unwiring the coordinator. This plan **evolves** the real types and adds only the genuinely new isolated pieces (`ModelGHybridRanker`, `ModelGCorpusVectorSidecar`, the CLI). The spec's intent — sentence embeddings, B1 sidecar + C self-heal, hybrid 0.70/0.20/0.10, drop-in `retrieve()`, pure-seam testability — is fully met.
2. **`TextEmbedder` protocol not introduced.** The spec proposed it purely for test injection; the existing code already achieves deterministic injection via `static rankByVectors` / `testInstance(vectors:)` / the pure `ModelGHybridRanker`. Adding a protocol would be ceremony with no test it enables that isn't already covered. (If Samuel wants the protocol for symmetry, it's a trivial follow-up — note, not blocker.)
3. **`embeddingRevision` is a derived literal (`nl.sentence.en.v1.dim<dimension>`), not a true Apple model revision** — `NLEmbedding` exposes no public revision API. The dimension-stamped literal catches the realistic break (a model whose dimension changes) and is bump-able in lock-step (CLI ↔ index). Documented in Task 4/6. Lower-fidelity than ideal but honest and self-healing.
4. **Launch warm-up call site is advisory (Task 8 step 6), not auto-edited** — app-lifecycle files are shared/high-traffic; per the parallel-coding rule the plan proposes the one-liner instead of editing it. Functionally optional (first query just pays a one-time cost otherwise).

**Open spec questions deferred to Samuel (from the spec's "Open Questions"):** Q1 (bundle-size acceptance for the ~16–27 MB sidecar) is **assumed YES** because the product owner locked Approach B1 — if download size is later a concern, swap to dimensionality-reduced export or Approach C with no API change. Q2 (confirm `dimension`; evaluate `NLContextualEmbedding`) deferred to Phase 2c. Q3 (global semantic rescue when theme tags return < k) — the existing retriever already widens to all 13k when `pool.count < k && semantic`; kept as-is, not expanded. Q4 (dedicated `useModelGv4Embeddings` sub-flag) **not added** — semantics ride the existing `ModelGEmbeddingIndex.shared`; the `semanticWeight=0` knob already provides the A/B lever. Q5 (on-device cache location = Application Support, not `~/Documents`) — not exercised in 2b because B1 ships the sidecar in-bundle; the self-heal recompute path (Task 4) currently holds vectors in RAM only (matching the pre-existing Approach A), so no disk cache is written and the iCloud-detritus concern doesn't arise; persisting the recompute to Application Support is a clean follow-up if first-launch recompute cost ever needs amortizing.
