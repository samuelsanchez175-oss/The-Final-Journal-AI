---
tags: [model-g, model-g-v4, rag, embeddings, retrieval, natural-language, on-device, phase-2b, design-spec]
project: XJournal AI
status: draft
updated: 2026-06-04
---

# Model G v4 — Phase 2b: On-Device Semantic Embeddings for Corpus Retrieval

## Overview / Goal

Phase 1+2 of Model G v4 shipped a **lexical** corpus retriever: `ModelGCorpusRetriever.retrieve(theme:draft:brands:k:)` filters the ~13,192-bar Gunna corpus by theme tag, then backfills with 4-char keyword-substring overlap against `CorpusBar.norm`, dedupes by `norm`, and returns top-k exemplars + brand-attr vocab. This is brittle: a draft about "stacking paper" never matches a bar that says "bands on bands" because they share no 4-char substring, even though they're the same idea.

**Goal:** Upgrade retrieval to **semantic similarity** — embed the user's draft/theme and the 13k bars into vectors, rank by cosine similarity, return the top-k *most semantically relevant* exemplars. Do it **on-device** via Apple's `NaturalLanguage` framework so retrieval is **$0, offline, and never spends the user's BYOK API key** (the key is generation-only). The `retrieve()` signature stays byte-identical — semantic ranking drops in behind the existing seam, with a clean lexical fallback when embeddings are unavailable.

### Non-goals
- No change to generation, scoring (`v4Breakdown`/`v4Total`), or candidate selection in `ModelGCoreCoordinatorV4`.
- No network embedding API (defeats the $0/offline/BYOK constraint).
- No retrain of any model — this is retrieval-augmentation, not training.
- No change to the Node corpus exporter's *parsing*; we only **add** an embedding step to it (Approach B/C).

### Grounding (files actually read)
- `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift` — the lexical retriever + seam (37 lines).
- `XJournal AI/ModelG/Corpus/ModelGCorpusStore.swift` — loads `ModelGCorpus.json` once, exposes `bars(theme:)`, `bars(matching:)`, `brandAttributes(brand:)`, `concept(named:)`.
- `XJournal AI/ModelG/Corpus/ModelGCorpusModels.swift` — `CorpusBar` fields: `id, text, adlib?, norm, artist?, …, themes[], tags[], bpm?, scale?, concepts[], context[]`.
- `XJournal AI/ModelG/ModelGCoreCoordinatorV4.swift` — the only production caller of `retrieve()` (Step 1b, `k: 6`).
- `XJournal AI/GroundTruthRetriever.swift` — **existing precedent**: already `import NaturalLanguage` + `Task.detached(priority: .utility)` off-main indexing in this codebase.
- `tools/modelg-corpus/{build-corpus.mjs, lib/parsers.mjs, package.json}` — Node/ESM exporter; `buildCorpus(files)` emits `{version:1, bars, concepts, brandAttributes, slang}` via `JSON.stringify` (no whitespace) to `ModelGCorpus.json`.
- `The Final Journal AITests/{ModelGCorpusRetrieverTests, ModelGCorpusStoreTests, GhostSuggestionEngineTests, ModelGV4ScoringTests}.swift` + `Fixtures/ModelGCorpus.fixture.json` — fixture-bundle test style to mirror.

### Verified facts that drive the design
- **Corpus size:** 13,192 bars; **avg `text` length ≈ 38.7 chars** (~7 words). Bars are *short* → favors sentence embeddings over long-doc schemes.
- **On-disk:** `ModelGCorpus.json` = **9,148,080 bytes (~8.7 MB)**, bundled in the app.
- **Deployment target:** iOS **26.x** (`IPHONEOS_DEPLOYMENT_TARGET = 26.0`/`26.2`). `NLEmbedding` (iOS 13+) and `NLContextualEmbedding` (iOS 17+) are both fully available; no back-deploy gymnastics needed. Fallback path is still specified for robustness (e.g. unit-test host, missing index, `nil` embedding).
- **Accelerate is already used** in the app (`AudioAnalysisService.swift`) → `vDSP`/`cblas_sdot` are available for fast cosine without new dependencies.
- `ModelGCorpusStore.shared = try? ModelGCorpusStore()` is `nil`-safe; the coordinator already treats the store as optional (`if let corpusStore = try? …`).

---

## Architecture & Components

```
                    ┌─────────────────────────────────────────┐
                    │  ModelGCoreCoordinatorV4 (UNCHANGED)     │
                    │  Step 1b: retriever.retrieve(theme:…k:6) │
                    └───────────────────┬─────────────────────┘
                                        │  identical signature
                    ┌───────────────────▼─────────────────────┐
                    │  ModelGCorpusRetriever (MODIFIED)        │
                    │  retrieve(theme,draft,brands,k):         │
                    │   1. candidate pool = theme bars         │
                    │      (∪ keyword bars if thin)            │
                    │   2. if semantic available:              │
                    │        rank pool by hybridScore ↓        │
                    │      else: legacy lexical order          │
                    │   3. dedupe by norm, take k              │
                    │   4. vocab = brand attributes (UNCHANGED)│
                    └──────┬─────────────────────┬─────────────┘
                           │ query vec           │ bar vecs (lookup by id)
              ┌────────────▼──────────┐  ┌────────▼───────────────────────┐
              │ ModelGEmbeddingService│  │ ModelGCorpusVectorIndex        │
              │  - NLEmbedding.        │  │  - [String:[Float]] id→vec     │
              │    sentenceEmbedding   │  │    OR contiguous Float32 blob  │
              │  - embed(String)->     │  │    + id order array            │
              │    [Float]? (L2-norm)  │  │  - cosineTopK(query,pool,k)    │
              │  - cached singleton     │  │  - loaded from sidecar/bundle  │
              └───────────┬───────────┘  └────────────────────────────────┘
                          │ Apple NaturalLanguage (on-device, $0, offline)
                          ▼
                 NLEmbedding.sentenceEmbedding(for: .english)
```

### New types
1. **`ModelGEmbeddingService`** (`XJournal AI/ModelG/Corpus/ModelGEmbeddingService.swift`)
   - Wraps `NLEmbedding`. Lazily loads `NLEmbedding.sentenceEmbedding(for: .english)` once (it's expensive to construct), stores it in a singleton.
   - `func embed(_ text: String) -> [Float]?` → returns an **L2-normalized** `[Float]` vector, or `nil` if the embedding model is unavailable or the string yields no vector (empty/all-OOV). Normalizing at embed time turns cosine into a plain dot product downstream.
   - `var isAvailable: Bool` → `true` iff the `NLEmbedding` loaded.
   - Pure value transform; **no I/O, no network, no Keychain** → cheaply unit-testable and provably BYOK-free.

2. **`ModelGCorpusVectorIndex`** (`XJournal AI/ModelG/Corpus/ModelGCorpusVectorIndex.swift`)
   - Holds the 13k precomputed bar vectors. Two storage shapes considered (see Approaches); recommended shape = **`ids: [String]` + one contiguous `[Float]` (or `Data` of Float32) of `count × dims`**, plus a `[String: Int]` id→row map for pool lookups.
   - `func cosineTopK(query: [Float], over rows: [Int], k: Int) -> [(id: String, score: Float)]` — ranks only the *candidate pool rows* (not all 13k) by dot product (vectors pre-normalized), returns top-k. Off-main responsibility lives in the retriever's caller path (already `Task`-based in the coordinator) — the index method itself is synchronous and pure.
   - `static func load(from:)` — decodes the sidecar (Approach B) or computes-then-caches (Approach C).

3. **(Approach B only) Exporter embedding step** in `tools/modelg-corpus/` — a Node script that, after `buildCorpus`, computes a vector per bar and writes a **sidecar** `ModelGCorpusVectors.f32` (raw little-endian Float32) + a tiny `ModelGCorpusVectors.meta.json` (`{version, dims, count, idOrder}`). See Approach B for the cross-toolchain caveat.

### Modified
- **`ModelGCorpusRetriever`** — gains an optional `embeddingService` + `vectorIndex` (both default-injected from singletons, default-`nil`-safe), and a private `rank(pool:draft:theme:)` that blends semantic + lexical. `retrieve(...)` signature unchanged.
- **`ModelGCorpusStore`** (optional, Approach C) — could own lazy vector construction so the index shares the store's lifecycle. Recommended: keep the index a sibling, not a store member, to avoid bloating the store's `init` and to keep `shared` cheap.

### Unchanged (explicitly)
- `ModelGCoreCoordinatorV4`, `ScoringEngine`, `CorpusBar`, the brand-vocab path, the Node *parser* (`lib/parsers.mjs`).

---

## Data Flow

### Query time (per generation, called once with `k: 6`)
1. Coordinator builds the candidate **pool** exactly as today: `store.bars(theme:)` ∪ (keyword bars if pool < k). *(We keep theme filtering as a coarse pre-filter — see Decision 4.)*
2. Retriever embeds the **query** = a join of `theme` (if any) + `draft` via `ModelGEmbeddingService.embed(...)`. One embed call. ~sub-ms to low-ms.
3. For each pooled bar, look up its **precomputed** vector by `id` in `ModelGCorpusVectorIndex`. (Bars in the pool with no vector — e.g. empty `norm` — are skipped for the semantic term and fall back to their lexical rank.)
4. Compute `hybridScore` per pooled bar (Decision 4). Sort descending.
5. Dedupe by `norm`, take `k`. Brand vocab unchanged.
6. **Fallback:** if `embed(query) == nil` OR the vector index is unavailable, skip steps 2–4 and use the **legacy lexical order** (today's behavior) verbatim.

### Build time (Approach B — recommended)
1. `node build-corpus.mjs <vault>` → `ModelGCorpus.json` (today, unchanged).
2. New `node embed-corpus.mjs` → reads bars, computes a vector per `bar.norm`, writes `ModelGCorpusVectors.f32` + `.meta.json` sidecars next to the JSON. **Caveat below.**

### First-launch (Approach C — fallback/alternative)
1. App boots; a `.utility` background `Task` (mirroring `GroundTruthRetriever.loadAndIndex`) embeds all 13k `norm` strings, writes the Float32 blob to Application Support, flips an `isIndexed` flag.
2. Until indexing completes, `retrieve()` uses the lexical fallback — never blocks generation.

---

## Approaches & Tradeoffs

We separate **two orthogonal axes**: *(1) where bar vectors are computed/stored* and *(2) what embedding source produces them*. Decisions 1–4 below resolve each axis. The three "Approaches" bundle the storage axis (the consequential bundle-size/latency tradeoff); the embedding-source axis is settled in Decision 1.

### Approach A — On-device, compute-at-first-launch, **in-memory only** (no persisted index)
Embed all 13k bars in a background `Task` at first launch; keep vectors in RAM for the session; recompute next launch.
- **Bundle impact:** **0 bytes** added. App ships only the existing JSON.
- **Storage on disk:** 0 (nothing persisted).
- **First-load latency:** Embedding 13,192 short strings with `sentenceEmbedding`. Sentence embeddings are fast (hashed n-gram lookup, not a transformer); realistic throughput is thousands/sec on-device → **~1–4 s** one-time, off-main. Generation works (lexical fallback) during this window.
- **RAM:** 13,192 × dims × 4 B. At **512 dims ≈ 27 MB**; at 300 dims ≈ 15.8 MB. Acceptable but not free.
- **Cons:** Pays the embed cost **every** launch; no determinism guarantee across OS versions if Apple updates the embedding model.

### Approach B — **Precompute at export**, ship a **Float32 sidecar** in the bundle  ✅ *recommended*
Compute bar vectors once at corpus-build time, ship them as a binary sidecar; app `mmap`/loads them.
- **Bundle impact:** sidecar size = `13,192 × dims × 4 B`. **512 dims ≈ 27.0 MB**, **300 dims ≈ 15.8 MB**, **128 dims ≈ 6.8 MB**. (Compresses well in the App Store IPA; on-disk decompressed is the figure above.)
- **First-load latency:** decode/`mmap` a flat Float32 blob → **tens of ms**, no per-string embedding at runtime. Query needs only **one** embed call (the draft).
- **Storage on disk:** the sidecar (same as bundle figure); no extra runtime cache.
- **Determinism:** vectors are frozen at build time → ranking is **reproducible** and testable against golden values.
- **THE caveat (must resolve):** the *bundled* sidecar must be produced by the **same embedding model** the device uses at query time, or query↔bar vectors live in different spaces and cosine is meaningless. **Node has no `NLEmbedding`.** Two clean ways to honor this:
  - **B1 (recommended):** generate the sidecar with a **tiny macOS Swift CLI** (`tools/modelg-embed/`) that links `NaturalLanguage` and uses the *same* `NLEmbedding.sentenceEmbedding(for:.english)` API. Run it as a build/export step after the Node exporter. Guarantees identical vector space. Add a `modelIdentifier`/OS-version stamp to `.meta.json`; at load, if the device's embedding `revision` differs from the stamp, **ignore the sidecar and fall back to Approach C/A** (recompute on device). This makes B *self-healing*.
  - **B2:** use a third-party static embedding whose weights we control (e.g. ship a small GloVe/word2vec table) and run the *same* averaging math in Node and Swift. Works offline and is fully deterministic, but means we **don't** use `NLEmbedding` and must vendor a weights file — more bundle weight and code. Rejected unless B1's revision-mismatch fallback proves flaky in practice.
- **Cons:** adds a Swift build tool (B1); bundle grows by the sidecar; needs the meta-version guard.

### Approach C — On-device, compute-at-first-launch, **persist to disk cache**
Like A, but write the Float32 blob to Application Support after first index; subsequent launches `mmap` the cache.
- **Bundle impact:** 0 bytes.
- **First-load latency:** ~1–4 s **once ever** (first launch); **tens of ms** every launch after (cache hit).
- **Storage on disk:** the cached blob (15–27 MB) in Application Support (not iCloud-synced — keep it out of `~/Documents` per the known iCloud "detritus"/" 2" issues).
- **Determinism:** vectors match the *device's* model exactly (no cross-toolchain risk), but differ across devices/OS versions → harder to write golden-value tests (mitigated by fixture-vector injection — see Testing).
- **Cons:** first-launch CPU/thermal cost on user's device; cache invalidation needed when corpus `version` bumps (store `version` in the cache header).

### Recommendation
**Approach B1** as the primary, **with Approach C as the built-in fallback** when the sidecar's embedding-revision stamp doesn't match the device. This gives: **0 runtime indexing cost**, **tens-of-ms load**, **deterministic golden tests**, *and* graceful self-healing on the rare OS where Apple changed the embedding model. It costs one small macOS Swift CLI and ~16–27 MB of bundle (dims-dependent — see Decision 1/2 for the dims pick that bounds this).

| | A (RAM-only) | **B1 (export sidecar)** ✅ | C (disk cache) |
|---|---|---|---|
| Bundle add | 0 | 16–27 MB | 0 |
| First launch | ~1–4 s | ~tens ms | ~1–4 s (once) |
| Later launches | ~1–4 s each | ~tens ms | ~tens ms |
| Deterministic tests | ✗ | ✅ | ✗ (needs fixtures) |
| Cross-toolchain risk | none | **needs revision guard** | none |
| Vector space match | exact | exact *if guard ok* | exact |

---

## Decisions (resolved)

### Decision 1 — Embedding source, dimensionality, OOV/empty fallback  → **`NLEmbedding.sentenceEmbedding(for: .english)`**
- **Source:** **sentence embeddings**, not averaged word vectors. Rationale: bars average **~7 words / 38.7 chars** — true sentences. `NLEmbedding.sentenceEmbedding` is purpose-built for short phrases, handles tokenization/OOV internally, and returns a single fixed-length vector per string with one call (`vector(for:)`). Averaging `NLEmbedding.wordEmbedding` word vectors is the fallback-of-the-fallback: more code, must hand-handle OOV/empty, and loses word-order signal. Apple's newer `NLContextualEmbedding` (iOS 17+, transformer, higher quality, multilingual) is **available** on our iOS 26 target but is heavier per-call and produces **per-token** outputs we'd have to pool ourselves; defer it to a possible Phase 2c quality bump — sentence embeddings are the right cost/quality point for a 13k-bar cosine search.
- **Dimensionality:** **whatever `sentenceEmbedding.dimension` reports — read it at runtime, do not hardcode** (Apple's English sentence-embedding has historically been 512-d; treat 512 as the planning number for sizing but store the actual `dimension` in `.meta.json` and assert query/bar dims match before searching). The Float32 byte budgets above use 512 (≈27 MB) as the conservative upper bound; if a smaller model ships, the sidecar shrinks for free.
- **Empty / OOV / unavailable fallback (three distinct cases):**
  1. `NLEmbedding.sentenceEmbedding(for: .english)` returns `nil` (model unavailable on this build/host, e.g. some unit-test hosts) → `isAvailable == false` → retriever uses **lexical fallback**.
  2. `embedding.vector(for: text)` returns `nil` or an empty/all-zero vector for a given string (empty `norm`, all-OOV slang) → `embed` returns `nil`; for the **query** this triggers lexical fallback; for a **pooled bar** it's skipped from the semantic term (keeps its lexical rank).
  3. Normalize defensively: if the L2 norm is ~0, return `nil` rather than dividing.

### Decision 2 — Indexing 13k bars: precompute vs on-device  → **precompute at export (B1), with on-device cache (C) as fallback**
Resolved by Approaches above. Concrete sizing for the bundle/cache (Float32, 4 B/elt):
- 512 dims → 13,192 × 512 × 4 = **27,017,216 B ≈ 27.0 MB**
- 300 dims → **15.8 MB** ·  256 dims → **13.5 MB** ·  128 dims → **6.8 MB**

App already ships an 8.7 MB JSON; +16–27 MB roughly triples the Model-G data footprint but is well within App Store limits and is a **one-time** static cost with no runtime penalty. If bundle size becomes a concern, prefer dimensionality reduction baked at export (PCA to 256) over switching to Approach C — but only if a smaller `NLEmbedding` dimension isn't already the case. Store `count`, `dims`, `corpusVersion`, and `embeddingRevision` in `.meta.json`; refuse-and-fallback on any mismatch.

### Decision 3 — Query-time ranking: brute-force vs approximate, threading, latency target  → **brute-force cosine over the candidate POOL, off-main, < 30 ms**
- **Brute-force, not ANN.** We do **not** scan all 13k per query — the existing theme/keyword pre-filter already collapses the pool to tens–low-hundreds of bars before ranking. Cosine over ≤~300 pre-normalized 512-d vectors is a handful of `cblas_sdot`/`vDSP_dotpr` calls — **microseconds**. ANN indexes (HNSW/IVF) are unjustified complexity at this scale and pool size.
  - *If* we ever drop the theme pre-filter and rank the **full 13k** (Decision 4's "pure semantic" variant), brute-force is still fine: 13,192 × 512 dot products ≈ 6.75M FLOPs/2 ≈ low-**single-digit ms** with Accelerate. So even the worst case clears the target.
- **Threading:** the **one query embed call + the cosine pass must run off the main thread.** The coordinator already calls `retrieve()` from an `async` context inside `generateRecord`; ensure the embed+rank work is on a background executor (wrap in `Task.detached(priority: .userInitiated)` or call from the existing `await` path — *not* the main actor). `NLEmbedding` is thread-safe for `vector(for:)` after construction. Pattern precedent: `GroundTruthRetriever` uses `Task.detached(priority: .utility)`.
- **Latency target:** **end-to-end semantic ranking < 30 ms** at query time (dominated by the single embed call; cosine is sub-ms). This is invisible next to the multi-second LLM generation calls that follow. Hard ceiling: if ranking somehow exceeds ~150 ms (cold model load), the first call may pay model-construction cost once — warm the singleton at app launch (alongside other Model-G warmup) to hide it.

### Decision 4 — Hybrid vs pure semantic  → **HYBRID: theme pre-filter (keep) → semantic primary + lexical tiebreak; brand vocab unchanged**
Replacing everything with pure cosine throws away cheap, high-precision signal (exact theme tags, brand attributes). Recommended concrete blend:
1. **Theme filter = coarse recall pre-filter (KEEP).** `store.bars(theme:)` ∪ keyword-backfill builds the candidate pool exactly as today. This bounds the cosine pass and preserves the curated theme taxonomy. *(Optional refinement: if the pool is still < k after keyword backfill, widen to a small global semantic search over all 13k — brute-force is cheap enough per Decision 3 — so semantic can *rescue* recall when tags miss.)*
2. **Rank within the pool by a blended score:**

   `hybridScore(bar) = 0.70 · cosine(queryVec, barVec)  +  0.20 · lexicalOverlap(draft, bar.norm)  +  0.10 · themeExactBonus(bar)`

   - `cosine` ∈ [−1,1] → clamp/shift to [0,1]; it's the dot product since vectors are L2-normalized.
   - `lexicalOverlap` = today's keyword-substring signal, normalized to [0,1] (rewards literal must-keep phrasing — keeps the retriever honest when the user uses exact corpus slang).
   - `themeExactBonus` = 1.0 if the bar carries the requested theme tag, else 0 (rewards curated tags).
   - **Weights are tunable constants** (`semanticWeight`/`lexicalWeight`/`themeWeight`), defined in one place and unit-asserted to sum to 1.0 — mirroring how `ScoringEngine.v4HouseWeight/v4AutoWeight/v4UserWeight` are already exposed and tested in `ModelGV4ScoringTests`. Default 0.70/0.20/0.10 leans semantic while keeping lexical/theme as guardrails.
3. **Brand-attr vocab path: UNCHANGED.** `brands.flatMap { store.brandAttributes(brand:) }` is exact-match metadata, not free text — semantics add nothing. Return it as today.
4. **Dedupe by `norm` stays** (post-ranking), so semantic near-duplicates with identical normalized text still collapse.

This is a strict superset of today's behavior: with `semanticWeight = 0`, `hybridScore` reduces to the legacy lexical+theme ordering — making the change safely A/B-gateable behind the existing `useModelGv4`/an embeddings sub-flag.

---

## `retrieve()` Integration & Fallback

**Signature is untouched** — true drop-in:

```swift
func retrieve(theme: String?, draft: String, brands: [String], k: Int) -> Result
```

Behavior change is internal:
1. Build `pool` exactly as today (theme ∪ keyword backfill).
2. `guard let embeddingService, embeddingService.isAvailable,
         let vectorIndex,
         let qVec = embeddingService.embed(queryString(theme, draft))
   else { /* LEGACY PATH: existing dedupe-first-k ordering */ }`
3. Rank `pool` by `hybridScore` using `vectorIndex` lookups (bars missing a vector keep lexical-only score).
4. Dedupe by `norm`, take `k`.
5. `vocab` = brand attributes (unchanged). Return `Result(exemplars:, vocab:)`.

**Dependency injection for the seam + tests:** add `init(store:embeddingService:vectorIndex:)` with `embeddingService` and `vectorIndex` defaulting to shared singletons (or `nil`). Existing call sites — `ModelGCoreCoordinatorV4` (`ModelGCorpusRetriever(store: corpusStore)`) and `GhostSuggestionEngine` (`ModelGCorpusRetriever(store: $0)`) — **compile unchanged** because the new params are defaulted. The coordinator picks up semantics for free once the singletons resolve.

**Fallback matrix (all paths return a valid `Result`, never crash):**
| Condition | Behavior |
|---|---|
| `NLEmbedding` unavailable (`isAvailable == false`) | legacy lexical ordering |
| query embeds to `nil` (empty/all-OOV draft) | legacy lexical ordering |
| vector index missing/failed to load | legacy lexical ordering |
| sidecar `embeddingRevision` ≠ device revision | ignore sidecar → on-device recompute (C); until ready, legacy |
| a pooled bar has no vector | that bar scored lexical-only; others still semantic |
| pool empty | return empty exemplars + vocab (as today) |

This preserves the existing `try? ModelGCorpusStore()` nil-safety philosophy end-to-end.

---

## Testing Strategy

Mirror the existing fixture-bundle, deterministic, no-network style (`ModelGCorpusRetrieverTests`, `ModelGV4ScoringTests`, `GhostSuggestionEngineTests`). **Key trick: never call live `NLEmbedding` in unit tests** (its output is opaque/non-deterministic across OS) — inject **fixture vectors** through a protocol seam, exactly like `GhostSuggestionEngine` injects an optional retriever.

1. **Protocol-ize the embedding seam.** Define `protocol TextEmbedder { var isAvailable: Bool { get }; func embed(_ s: String) -> [Float]? }`; `ModelGEmbeddingService` conforms. Tests inject a `StubEmbedder` returning hand-authored unit vectors → cosine is fully determined.
2. **`ModelGCorpusVectorIndexTests` (deterministic cosine):** build an index from a handful of known vectors; assert `cosineTopK` returns the right ids in the right order, honors `k`, and that **pre-normalized dot == expected cosine** (e.g. orthogonal → 0, identical → 1, opposite → −1). Pattern mirror: `GhostSuggestionEngineTests.testRankedRhymesPerfectBeforeSlantDeterministic` (golden ordering from a fixed lexicon).
3. **`ModelGCorpusRetrieverSemanticTests`:** load the existing `ModelGCorpus.fixture.json` store, inject a `StubEmbedder` + a fixture `ModelGCorpusVectorIndex` whose vectors make `b2` strictly closer to the query than `b1`; assert `retrieve(...)` returns `b2` first — proving semantics reorder vs the lexical default. Add a case where the stub reports `isAvailable=false` and assert output **exactly equals** the legacy lexical result (fallback parity). Reuse the `Bundle(for: …)` + `resource: "ModelGCorpus.fixture"` loader already in the suite.
4. **Weight-sum guard:** mirror `testV4CompositeUsesConfiguredWeights` — assert `semanticWeight + lexicalWeight + themeWeight == 1.0` (accuracy 0.001) and that `semanticWeight = 0` reproduces legacy ordering on a fixture.
5. **Normalization unit test:** `embed` output (when stubbed to a raw vector) is L2-norm 1.0 ± 1e-5; zero-vector input → `nil`.
6. **Meta/version guard test:** a `.meta.json` with mismatched `dims` or `embeddingRevision` → index load returns `nil` (→ retriever falls back), asserted without touching `NLEmbedding`.
7. **(Approach B1) Exporter test:** extend `tools/modelg-corpus`'s `node --test` suite (cf. `build-corpus.test.mjs`) to assert the embed step writes a Float32 blob of exactly `count × dims × 4` bytes with a matching `.meta.json`. The *vector values* are validated in Swift against the device model, not in Node.
8. **Live smoke (separate, not in the deterministic unit run):** one `testRealEmbeddingProducesNonNilVector` guarded so it no-ops when `NLEmbedding.sentenceEmbedding(for:.english) == nil` — mirrors `testRealBundledCorpusLoads` / the cmudict-optional guard in `GhostSuggestionEngineTests`.

---

## Open Questions for Samuel

1. **(Most important) Are we OK adding ~16–27 MB to the app bundle for the precomputed vector sidecar (Approach B1), or is a 0-byte-bundle / first-launch-compute (Approach C) strongly preferred for download size?** This is the one decision that changes the deliverables (a macOS Swift embed CLI + bundled binary vs. on-device indexing code) and the testing story (golden vectors vs. fixture-only). Everything else follows from it.
2. Confirm `NLEmbedding.sentenceEmbedding(for: .english).dimension` on the current SDK (512 assumed for sizing) — and whether you want me to evaluate `NLContextualEmbedding` quality for a Phase 2c bump.
3. Should the optional **global semantic rescue** (widen to all-13k cosine when theme tags return < k) ship in 2b, or stay theme-gated for v1 to keep behavior conservative?
4. Gate semantics behind a dedicated sub-flag (e.g. `useModelGv4Embeddings`) under `useModelGv4`, or fold straight into the v4 path? A sub-flag makes the 0.70/0.20/0.10 blend A/B-tunable in the field.
5. Where should the on-device cache (Approach C / B1-fallback) live — Application Support is the plan (explicitly **not** `~/Documents`/iCloud, per the known "detritus"/" 2" issue). Confirm.

---

## File Structure / Task Outline

**New files**
- `XJournal AI/ModelG/Corpus/ModelGEmbeddingService.swift` — `TextEmbedder` impl over `NLEmbedding.sentenceEmbedding`; singleton; `embed(_:) -> [Float]?` (L2-normalized); `isAvailable`. *(both .xcodeproj synchronized groups auto-compile new files — no manual target add.)*
- `XJournal AI/ModelG/Corpus/ModelGCorpusVectorIndex.swift` — id↔row map + contiguous Float32 store; `cosineTopK`; `load(from:)`; meta/version guard + recompute-fallback.
- `The Final Journal AITests/ModelGCorpusVectorIndexTests.swift` — deterministic cosine/top-k.
- `The Final Journal AITests/ModelGCorpusRetrieverSemanticTests.swift` — stub-embedder reorder + fallback-parity.
- *(Approach B1)* `tools/modelg-embed/` — small macOS Swift CLI linking `NaturalLanguage`, emits `ModelGCorpusVectors.f32` + `ModelGCorpusVectors.meta.json`.
- *(Approach B1)* `tools/modelg-corpus/embed-corpus.mjs` *or* fold the invocation into the build pipeline/README so export = parse-then-embed.

**Changed files**
- `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift` — add defaulted `embeddingService`/`vectorIndex` init params + private `rank(...)` hybrid blend + tunable weight constants; `retrieve(...)` signature unchanged; lexical fallback preserved.
- *(Approach B1)* App bundle resources — add the `.f32` + `.meta.json` sidecars (and ensure they're copied into the app target like `ModelGCorpus.json`).
- *(optional)* `The Final Journal AITests/Fixtures/` — add a tiny fixture vector set / `ModelGCorpusVectors.fixture.*` if golden-vector tests are wanted.

**Untouched (guardrail)**
- `ModelGCoreCoordinatorV4.swift`, `ScoringEngine.swift`, `ModelGCorpusModels.swift` (`CorpusBar`), `ModelGCorpusStore.swift` (unless we choose to host the index there — not recommended), `tools/modelg-corpus/lib/parsers.mjs`.

### Suggested sequencing
1. `ModelGEmbeddingService` + `TextEmbedder` protocol + its unit tests.
2. `ModelGCorpusVectorIndex` + cosine/top-k unit tests (pure, fixture vectors).
3. Retriever hybrid blend behind defaulted params + semantic/fallback tests (lexical parity proven).
4. Resolve Open Q1 → build the export sidecar path (B1) **or** the first-launch cache path (C).
5. Wire the singletons so `ModelGCoreCoordinatorV4` picks up semantics with no call-site change; warm the `NLEmbedding` singleton at launch.
