# Vault Improvement Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build one idempotent Node pipeline that completes all 6 vault recommendations over the LLM-builder Obsidian vault in a single run — clean corrupted lyrics, dedup, backfill tone + tags, propagate BPM/scale, nominate a `signature` tier, and generate brand→attribute cards — dry-run report by default, `--apply` to write — then regenerate `ModelGCorpus.json`.

**Architecture:** The 6 operations are **pure functions** in `lib/vault-ops.mjs` (no I/O → fully unit-testable). `improve-vault.mjs` is the only thing that touches disk: it walks the vault, groups bar notes by song, runs every pass, and either writes a report (`--dry-run`, default) or applies changes (`--apply`). All writes are **idempotent** (re-running changes nothing) and **gated on a clean git tree** in the vault (or `--force`). Frontmatter is read/written with `gray-matter`; the canonical lyric stays the filename tail (existing convention). The exporter gains a `tier` field; the Swift `CorpusBar` gains `tier`.

**Tech Stack:** Node 18+ (ESM), `gray-matter` (already a dependency), `node:test`, `node:fs/promises`. No new deps.

**Scope honesty (read first):** Two of the six can't be 100% machine-completed; the pipeline does the automatable core of each and reports the residue for human judgment:
- **#2 Curate to ~2–4k:** *dedup* is fully automated (the big win). The "keep only the best" cut is done as a **reversible archive** (`--keep-top N` moves low-ranked uniques to `Archive/`, never deletes) so you review, not the script.
- **#6 BPM/scale to 100%:** *within-song propagation* is automated (fills most gaps, since bars cluster by song). Songs where **no** bar has a BPM are listed in the report for you to fill (needs external data the script can't invent).

---

## File Structure

| Path | Responsibility |
|---|---|
| `tools/modelg-corpus/lib/vault-ops.mjs` (create) | The 6 passes as pure functions + frontmatter/lyric helpers. No disk I/O. |
| `tools/modelg-corpus/vault-ops.test.mjs` (create) | `node:test` unit tests, one suite per pass. |
| `tools/modelg-corpus/improve-vault.mjs` (create) | CLI orchestrator: walk → group → run passes → report/apply. The only file that touches disk. |
| `tools/modelg-corpus/data/brand-attributes.seed.json` (create) | Seed list of brand→attribute pairs for pass #5 (you can extend). |
| `tools/modelg-corpus/lib/parsers.mjs` (modify) | `parseBar` reads `tier`; `buildCorpus` passes it through. |
| `XJournal AI/ModelG/Corpus/ModelGCorpusModels.swift` (modify) | Add `tier: String?` to `CorpusBar`. |
| `XJournal AI/ModelG/Corpus/ModelGCorpus.json` (regenerate) | Rebuilt from the improved vault. |

**Vault layout (confirmed):** root `~/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local`; bar notes under `4. Bar Notes/`; frontmatter has `artist, album, song, themes[], tags[], type: bar_note` (+ optional `bpm, scale, section, active_artist`); the canonical lyric is the filename tail after `" - "` (trailing ` N` = a variant, stripped).

---

## Conventions used by every pass

```js
// A "note" object the orchestrator builds per .md file and passes to the pure functions:
// {
//   relPath: "4. Bar Notes/Derek Fisher - You get ... 3.md",
//   fileName: "Derek Fisher - You get ... 3.md",
//   data: { artist, album, song, themes, tags, bpm, scale, tier, type, ... },  // gray-matter frontmatter
//   body: "# Contextual Lyric\n> ...",                                          // gray-matter content
//   lyric: "You get your wish, we got them sticks ...",                         // derived (filename tail, adlib/_N stripped)
//   norm:  "you get your wish we got them sticks ...",                          // normalized lyric (dedup key)
//   concepts: ["Sticks", "..."],                                               // [[wikilinks]] from body
// }
// A pass returns a PATCH: { data?: {...frontmatterChanges}, rename?: "new file name", archive?: true, reason: "..." }
// or null when it has nothing to change. The orchestrator merges patches and writes once.
```

The corpus tone vocabulary (what retrieval matches on) is fixed — **only assign tones from this set**:

```js
export const TONES = ["confident","luxurious","aspirational","aggressive","dominant",
  "gritty","defiant","celebratory","detached","paranoid","anxious","opportunistic","calculated"];
```

---

## Task 1: vault-ops scaffolding — lyric/norm derivation + frontmatter round-trip

**Files:**
- Create: `tools/modelg-corpus/lib/vault-ops.mjs`
- Create: `tools/modelg-corpus/vault-ops.test.mjs`

- [ ] **Step 1: Write the failing test**

```js
// tools/modelg-corpus/vault-ops.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { deriveLyric, normalizeText, TONES } from './lib/vault-ops.mjs';

test('deriveLyric takes the filename tail after " - ", strips adlib + trailing variant number', () => {
  const r = deriveLyric("Derek Fisher - You get them sticks and we gon' slide (We gon' slide) 3.md");
  assert.equal(r.lyric, "You get them sticks and we gon' slide");
  assert.equal(r.adlib, "We gon' slide");
});
test('deriveLyric handles no song prefix', () => {
  assert.equal(deriveLyric("Just a bare line.md").lyric, "Just a bare line");
});
test('normalizeText lowercases, drops parens + punctuation, collapses spaces', () => {
  assert.equal(normalizeText("You GET (yeah) them—sticks!"), "you get themsticks");
});
test('TONES is the corpus vocabulary', () => {
  assert.ok(TONES.includes('confident') && TONES.includes('paranoid'));
});
```

- [ ] **Step 2: Run it to verify it fails**

Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
Expected: FAIL — `Cannot find module './lib/vault-ops.mjs'`.

- [ ] **Step 3: Write the minimal implementation**

```js
// tools/modelg-corpus/lib/vault-ops.mjs
export const TONES = ["confident","luxurious","aspirational","aggressive","dominant",
  "gritty","defiant","celebratory","detached","paranoid","anxious","opportunistic","calculated"];

/** Canonical lyric = filename tail after " - "; strip ".md", trailing " N" variant, and a trailing (adlib). */
export function deriveLyric(fileName) {
  const base = fileName.replace(/\.md$/, '');
  const sep = base.indexOf(' - ');
  let full = (sep >= 0 ? base.slice(sep + 3) : base).replace(/[_ ]\d+$/, '').trim();
  let lyric = full, adlib = null;
  const am = full.match(/^(.*?)\s*\(([^)]+)\)\s*$/);
  if (am) { lyric = am[1].trim(); adlib = am[2].trim(); }
  return { lyric, adlib };
}

export function normalizeText(s) {
  return (s || '').toLowerCase()
    .replace(/\([^)]*\)/g, '')
    .replace(/[^a-z0-9 ]+/g, '')
    .replace(/\s+/g, ' ').trim();
}
```

- [ ] **Step 4: Run it to verify it passes**

Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): lyric/norm derivation + tone vocabulary"
```

---

## Task 2: Pass #1 — clean corrupted lyrics (recommendation #4)

**Files:** Modify `tools/modelg-corpus/lib/vault-ops.mjs`; Test `tools/modelg-corpus/vault-ops.test.mjs`

- [ ] **Step 1: Write the failing test**

```js
import { cleanCorruption } from './lib/vault-ops.mjs';
test('cleanCorruption strips URL/markdown bleed and proposes a rename', () => {
  const note = { fileName: "Song - She talkin bout licks](https---genius.com-123-x.md", lyric: "She talkin bout licks](https---genius.com-123-x" };
  const p = cleanCorruption(note);
  assert.equal(p.cleanLyric, "She talkin bout licks");
  assert.match(p.rename, /^Song - She talkin bout licks\.md$/);
});
test('cleanCorruption returns null for clean notes', () => {
  assert.equal(cleanCorruption({ fileName: "Song - Clean line.md", lyric: "Clean line" }), null);
});
```

- [ ] **Step 2: Run → FAIL** (`cleanCorruption is not a function`). Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`

- [ ] **Step 3: Implement**

```js
// append to lib/vault-ops.mjs
const CORRUPT_RE = /\s*\]?\(?\s*https?[:\-]|\]\(|genius[.\-]com/i;
/** Detect URL/markdown bleed in the lyric; return { cleanLyric, rename } or null. */
export function cleanCorruption(note) {
  const m = note.lyric.search(CORRUPT_RE);
  if (m < 0) return null;
  const cleanLyric = note.lyric.slice(0, m).replace(/[\s\]\[(]+$/, '').trim();
  if (!cleanLyric) return { drop: true, reason: 'corrupted with no recoverable lyric' };
  const song = note.fileName.includes(' - ') ? note.fileName.slice(0, note.fileName.indexOf(' - ')) : null;
  const rename = (song ? `${song} - ${cleanLyric}` : cleanLyric) + '.md';
  return { cleanLyric, rename, reason: 'stripped URL/markdown bleed' };
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): pass 1 - clean corrupted lyrics/filenames"
```

---

## Task 3: Pass #2 — dedup by norm, pick canonical (recommendation #2, automated half)

**Files:** Modify `lib/vault-ops.mjs`; Test same.

- [ ] **Step 1: Write the failing test**

```js
import { dedupe } from './lib/vault-ops.mjs';
test('dedupe keeps one canonical per norm (prefer no trailing variant number), archives the rest', () => {
  const notes = [
    { fileName: "S - Line 3.md", norm: "line", data: {} },
    { fileName: "S - Line.md",   norm: "line", data: {} },
    { fileName: "S - Other.md",  norm: "other", data: {} },
  ];
  const { keep, archive } = dedupe(notes);
  assert.deepEqual(keep.map(n => n.fileName).sort(), ["S - Line.md", "S - Other.md"]);
  assert.deepEqual(archive.map(n => n.fileName), ["S - Line 3.md"]);
});
test('dedupe ignores empty norms (left untouched in keep)', () => {
  const { keep, archive } = dedupe([{ fileName: "x.md", norm: "", data: {} }]);
  assert.equal(keep.length, 1); assert.equal(archive.length, 0);
});
```

- [ ] **Step 2: Run → FAIL.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`

- [ ] **Step 3: Implement**

```js
// append to lib/vault-ops.mjs
/** Group by norm; canonical = the one whose filename has NO trailing " N" variant, else shortest name. */
export function dedupe(notes) {
  const byNorm = new Map();
  for (const n of notes) {
    if (!n.norm) continue;                 // empties handled elsewhere
    (byNorm.get(n.norm) ?? byNorm.set(n.norm, []).get(n.norm)).push(n);
  }
  const keep = [], archive = [];
  const empties = notes.filter(n => !n.norm);
  for (const group of byNorm.values()) {
    const ranked = [...group].sort((a, b) => {
      const av = /[_ ]\d+\.md$/.test(a.fileName) ? 1 : 0;
      const bv = /[_ ]\d+\.md$/.test(b.fileName) ? 1 : 0;
      return av - bv || a.fileName.length - b.fileName.length;
    });
    keep.push(ranked[0]);
    archive.push(...ranked.slice(1));
  }
  return { keep: [...keep, ...empties], archive };
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): pass 2 - dedupe by norm with canonical pick"
```

---

## Task 4: Pass #3 — backfill tone (recommendation #1, tone half)

**Files:** Modify `lib/vault-ops.mjs`; Test same.

Strategy (deterministic, in priority order): (a) keep existing valid tones; (b) inherit the majority tone of **other bars in the same song**; (c) keyword lexicon over lyric+concepts; (d) floor to `"confident"` so coverage hits 100%. Every inferred note is flagged for review.

- [ ] **Step 1: Write the failing test**

```js
import { inferTone } from './lib/vault-ops.mjs';
const lex = { luxurious: ["diamond","rolex","drip"], aggressive: ["stick","slide","glock"] };
test('inferTone keeps existing valid tones untouched', () => {
  assert.equal(inferTone({ data: { themes: ["confident"] }, lyric: "x", concepts: [] }, ["confident"], lex), null);
});
test('inferTone inherits the song majority tone', () => {
  const p = inferTone({ data: { themes: [] }, lyric: "nothing keyworded", concepts: [] }, ["aggressive","aggressive","confident"], lex);
  assert.deepEqual(p.data.themes, ["aggressive"]);
  assert.equal(p.inferred, true);
});
test('inferTone falls back to keyword lexicon then to confident floor', () => {
  assert.deepEqual(inferTone({ data: { themes: [] }, lyric: "got the stick on me", concepts: [] }, [], lex).data.themes, ["aggressive"]);
  assert.deepEqual(inferTone({ data: { themes: [] }, lyric: "plain words only", concepts: [] }, [], lex).data.themes, ["confident"]);
});
```

- [ ] **Step 2: Run → FAIL.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`

- [ ] **Step 3: Implement**

```js
// append to lib/vault-ops.mjs
const VALID_TONES = new Set(TONES);
/** songTones = themes from every OTHER bar in the same song (flat). lex = { tone: [keyword,...] }. */
export function inferTone(note, songTones, lex) {
  const have = (note.data.themes || []).filter(t => VALID_TONES.has(String(t).toLowerCase()));
  if (have.length) return null;                                  // (a) already toned
  const counts = {};
  for (const t of songTones) { const k = String(t).toLowerCase(); if (VALID_TONES.has(k)) counts[k] = (counts[k]||0)+1; }
  let pick = Object.entries(counts).sort((a,b)=>b[1]-a[1])[0]?.[0];   // (b) song majority
  if (!pick) {                                                       // (c) keyword lexicon
    const hay = (note.lyric + ' ' + (note.concepts||[]).join(' ')).toLowerCase();
    pick = Object.entries(lex).find(([, kws]) => kws.some(k => hay.includes(k)))?.[0];
  }
  if (!pick) pick = 'confident';                                    // (d) floor
  return { data: { themes: [pick] }, inferred: true, reason: `tone inferred (${pick})` };
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): pass 3 - backfill tone (song-majority -> lexicon -> floor)"
```

---

## Task 5: Pass #4 — backfill tags (recommendation #1, tag half)

**Files:** Modify `lib/vault-ops.mjs`; Test same.

Tags are topical (retrieval matches them via `bars(tag:)`). Backfill priority: (a) keep existing; (b) map the note's `concepts` ([[wikilinks]]) to lowercased tag tokens; (c) union the song-sibling tags; (d) keyword lexicon. Never floor (a missing tag is acceptable; a missing tone is not).

- [ ] **Step 1: Write the failing test**

```js
import { inferTags } from './lib/vault-ops.mjs';
test('inferTags keeps existing tags untouched', () => {
  assert.equal(inferTags({ data: { tags: ["gun"] }, concepts: [], lyric: "" }, []), null);
});
test('inferTags derives from concepts and song siblings, deduped + lowercased', () => {
  const p = inferTags({ data: { tags: [] }, concepts: ["Glock 19","Money"], lyric: "" }, ["weapon","weapon"]);
  assert.deepEqual(p.data.tags.sort(), ["glock 19","money","weapon"]);
  assert.equal(p.inferred, true);
});
```

- [ ] **Step 2: Run → FAIL.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`

- [ ] **Step 3: Implement**

```js
// append to lib/vault-ops.mjs
export function inferTags(note, songTags) {
  if ((note.data.tags || []).length) return null;
  const out = new Set();
  for (const c of (note.concepts || [])) out.add(String(c).toLowerCase().trim());
  for (const t of (songTags || [])) out.add(String(t).toLowerCase().trim());
  out.delete('');
  if (!out.size) return null;
  return { data: { tags: [...out].sort() }, inferred: true, reason: 'tags from concepts/siblings' };
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): pass 4 - backfill tags from concepts/siblings"
```

---

## Task 6: Pass #5 — propagate BPM/scale within a song (recommendation #6, automated half)

**Files:** Modify `lib/vault-ops.mjs`; Test same.

- [ ] **Step 1: Write the failing test**

```js
import { songBpmScale, applyBpmScale } from './lib/vault-ops.mjs';
test('songBpmScale picks the most common bpm/scale present among a song\'s bars', () => {
  const bars = [{data:{bpm:120,scale:"E Minor"}},{data:{bpm:120}},{data:{}}];
  assert.deepEqual(songBpmScale(bars), { bpm: 120, scale: "E Minor" });
});
test('applyBpmScale fills only missing fields; null when nothing to add or nothing known', () => {
  assert.deepEqual(applyBpmScale({data:{}}, {bpm:120,scale:"E Minor"}).data, {bpm:120,scale:"E Minor"});
  assert.equal(applyBpmScale({data:{bpm:120,scale:"E Minor"}}, {bpm:120,scale:"E Minor"}), null);
  assert.equal(applyBpmScale({data:{}}, {bpm:null,scale:null}), null);
});
```

- [ ] **Step 2: Run → FAIL.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`

- [ ] **Step 3: Implement**

```js
// append to lib/vault-ops.mjs
function mode(xs) { const c={}; let best=null,bn=0; for (const x of xs){c[x]=(c[x]||0)+1; if(c[x]>bn){bn=c[x];best=x;}} return best; }
export function songBpmScale(bars) {
  const bpm = mode(bars.map(b => b.data.bpm).filter(v => typeof v === 'number'));
  const scale = mode(bars.map(b => b.data.scale).filter(Boolean));
  return { bpm: bpm ?? null, scale: scale ?? null };
}
export function applyBpmScale(note, known) {
  const data = {};
  if (note.data.bpm == null && known.bpm != null) data.bpm = known.bpm;
  if (note.data.scale == null && known.scale != null) data.scale = known.scale;
  return Object.keys(data).length ? { data, reason: 'bpm/scale from song siblings' } : null;
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): pass 5 - propagate bpm/scale within song"
```

---

## Task 7: Pass #6 — nominate `tier: signature` (recommendation #3)

**Files:** Modify `lib/vault-ops.mjs`; Test same.

Score each unique bar on "signature-ness"; the orchestrator marks the top fraction with `tier: signature`. Score = concept density + brand/jewelry presence + a length sweet-spot (6–14 words) − interjection penalty.

- [ ] **Step 1: Write the failing test**

```js
import { signatureScore } from './lib/vault-ops.mjs';
test('signatureScore rewards concept-dense, well-sized bars and punishes interjections', () => {
  const dense = { lyric: "Cross on the Chrome Heart, three K for the jeans", concepts: ["Chrome Hearts","Designer Jeans"], data:{tags:["jewelry"]} };
  const adlib = { lyric: "Ah", concepts: [], data:{tags:[]} };
  assert.ok(signatureScore(dense) > signatureScore(adlib));
  assert.ok(signatureScore(adlib) <= 0);
});
```

- [ ] **Step 2: Run → FAIL.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`

- [ ] **Step 3: Implement**

```js
// append to lib/vault-ops.mjs
export function signatureScore(note) {
  const words = (note.lyric || '').trim().split(/\s+/).filter(Boolean).length;
  if (words < 3) return -1;                                  // interjection
  const lenFit = words >= 6 && words <= 14 ? 1 : 0;
  const concepts = (note.concepts || []).length;
  const brandish = /jewel|wealth|car|designer|brand/i.test((note.data.tags || []).join(' ')) ? 1 : 0;
  return lenFit + Math.min(concepts, 4) * 0.5 + brandish;    // ~0..3.5
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs"
git commit -m "feat(vault-ops): pass 6 - signature-tier scoring"
```

---

## Task 8: Recommendation #5 — generate brand→attribute concept cards from a seed

**Files:** Create `tools/modelg-corpus/data/brand-attributes.seed.json`; Modify `lib/vault-ops.mjs`; Test same.

- [ ] **Step 1: Create the seed**

```json
// tools/modelg-corpus/data/brand-attributes.seed.json
[
  { "brand": "Designer Brands and Fashion", "attribute": "Chrome Hearts", "aliases": ["chrome heart"] },
  { "brand": "Designer Brands and Fashion", "attribute": "Rick Owens", "aliases": ["rick owens","ricks"] },
  { "brand": "Designer Brands and Fashion", "attribute": "Amiri", "aliases": ["amiri"] },
  { "brand": "Jewelry and Timepieces", "attribute": "Bustdown", "aliases": ["bustdown","busted down"] },
  { "brand": "Jewelry and Timepieces", "attribute": "VVS Diamonds", "aliases": ["vvs","vvs1"] },
  { "brand": "Jewelry and Timepieces", "attribute": "Cuban Link", "aliases": ["cuban","cuban link"] },
  { "brand": "Cars and Vehicles", "attribute": "Forgiatos", "aliases": ["forgi","forgiato"] },
  { "brand": "Cars and Vehicles", "attribute": "Hellcat", "aliases": ["hellcat","cat"] }
]
```

- [ ] **Step 2: Write the failing test**

```js
import { brandAttributeCard } from './lib/vault-ops.mjs';
test('brandAttributeCard renders an Obsidian Attribute note with a parent wikilink', () => {
  const { fileName, content } = brandAttributeCard({ brand: "Jewelry and Timepieces", attribute: "Bustdown", aliases: ["bustdown"] });
  assert.equal(fileName, "Bustdown.md");
  assert.match(content, /aliases:/);
  assert.match(content, /## Parent Concept\n\n\[\[Jewelry and Timepieces\]\]/);
});
```

- [ ] **Step 3: Run → FAIL,** then implement:

```js
// append to lib/vault-ops.mjs
export function brandAttributeCard({ brand, attribute, aliases = [] }) {
  const content = `---\ncategory: "Attribute"\naliases: [${aliases.map(a => JSON.stringify(a)).join(', ')}]\n---\n\n## Parent Concept\n\n[[${brand}]]\n`;
  return { fileName: `${attribute}.md`, content };
}
```

- [ ] **Step 4: Run → PASS.** Run: `cd "tools/modelg-corpus" && node --test vault-ops.test.mjs`
- [ ] **Step 5: Commit**

```bash
git add "tools/modelg-corpus/lib/vault-ops.mjs" "tools/modelg-corpus/vault-ops.test.mjs" "tools/modelg-corpus/data/brand-attributes.seed.json"
git commit -m "feat(vault-ops): pass 7 - brand->attribute card generation"
```

---

## Task 9: Orchestrator — `improve-vault.mjs` (dry-run report + `--apply`, git-safe)

**Files:** Create `tools/modelg-corpus/improve-vault.mjs`

- [ ] **Step 1: Implement the orchestrator**

```js
// tools/modelg-corpus/improve-vault.mjs
import { readFile, writeFile, readdir, rename, mkdir } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import matter from 'gray-matter';
import {
  deriveLyric, normalizeText, cleanCorruption, dedupe, inferTone, inferTags,
  songBpmScale, applyBpmScale, signatureScore, brandAttributeCard, TONES,
} from './lib/vault-ops.mjs';

const VAULT = process.argv[2];
const APPLY = process.argv.includes('--apply');
const FORCE = process.argv.includes('--force');
const KEEP_TOP = (process.argv.find(a => a.startsWith('--keep-top=')) || '').split('=')[1];
const SIG_FRACTION = 0.15;
if (!VAULT) { console.error('usage: node improve-vault.mjs <vaultDir> [--apply] [--keep-top=N] [--force]'); process.exit(1); }

const BARS_DIR = path.join(VAULT, '4. Bar Notes');
const CONCEPTS_DIR = path.join(VAULT, '5. Deep Concepts', 'Attributes');
const ARCHIVE_DIR = path.join(VAULT, 'Archive');
const TONE_LEX = {                       // keyword fallback for tone inference
  luxurious: ['diamond','rolex','drip','designer','vvs','birkin','foreign'],
  aggressive: ['stick','slide','glock','draco','opp','shoot','beam'],
  paranoid: ['paranoid','watch','snake','cross','fed','wire'],
  celebratory: ['party','pop','toast','champagne','win'],
  aspirational: ['dream','grind','came from','one day','make it'],
};

function gitClean(dir) {
  try { return execFileSync('git', ['-C', dir, 'status', '--porcelain'], { encoding: 'utf8' }).trim() === ''; }
  catch { return null; }  // not a git repo
}

async function loadBars() {
  const files = (await readdir(BARS_DIR)).filter(f => f.endsWith('.md'));
  const notes = [];
  for (const fileName of files) {
    const raw = await readFile(path.join(BARS_DIR, fileName), 'utf8');
    const { data, content } = matter(raw);
    const { lyric, adlib } = deriveLyric(fileName);
    const concepts = [...new Set([...content.matchAll(/\[\[([^\]|]+?)(?:\|[^\]]+)?\]\]/g)].map(m => m[1].trim()))];
    notes.push({ fileName, raw, data, body: content, lyric, adlib, norm: normalizeText(lyric), concepts, patch: { data: {} } });
  }
  return notes;
}

function bySong(notes) {
  const m = new Map();
  for (const n of notes) { const s = n.data.song || '∅'; (m.get(s) ?? m.set(s, []).get(s)).push(n); }
  return m;
}

function mergePatch(note, p) {
  if (!p) return;
  if (p.data) Object.assign(note.patch.data, p.data);
  if (p.rename) note.patch.rename = p.rename;
  if (p.cleanLyric) note.patch.cleanLyric = p.cleanLyric;
  if (p.drop) note.patch.drop = true;
  if (p.archive) note.patch.archive = true;
  if (p.inferred) note.patch.inferred = true;
  (note.patch.reasons ??= []).push(p.reason);
}

const report = { scanned: 0, corrupted: 0, deduped: 0, tonedInferred: 0, taggedInferred: 0,
  bpmFilled: 0, signature: 0, brandCards: 0, songsMissingBpm: [], samples: [] };

let notes = await loadBars();
report.scanned = notes.length;

// Pass 1: corruption
for (const n of notes) { const p = cleanCorruption(n); if (p) { report.corrupted++; mergePatch(n, p); if (p.cleanLyric) n.norm = normalizeText(p.cleanLyric); } }

// Pass 2: dedupe
const { keep, archive } = dedupe(notes);
for (const n of archive) { report.deduped++; mergePatch(n, { archive: true, reason: 'duplicate norm' }); }
const live = keep;

// Group by song (for inference + bpm)
const songs = bySong(live);

// Pass 3 + 4 + 5: tone, tags, bpm
for (const [, bars] of songs) {
  const songTones = bars.flatMap(b => b.data.themes || []);
  const songTags = [...new Set(bars.flatMap(b => b.data.tags || []))];
  const known = songBpmScale(bars);
  if (known.bpm == null) report.songsMissingBpm.push(bars[0].data.song || '∅');
  for (const n of bars) {
    let p = inferTone(n, songTones.filter(t => !(n.data.themes||[]).includes(t)), TONE_LEX); if (p) { report.tonedInferred++; mergePatch(n, p); }
    p = inferTags(n, songTags); if (p) { report.taggedInferred++; mergePatch(n, p); }
    p = applyBpmScale(n, known); if (p) { report.bpmFilled++; mergePatch(n, p); }
  }
}

// Pass 6: signature tier — top fraction by score among live, non-archived
const scored = live.filter(n => !n.patch.archive).map(n => ({ n, s: signatureScore(n) })).sort((a,b)=>b.s-a.s);
const sigCount = Math.round(scored.length * SIG_FRACTION);
for (const { n } of scored.slice(0, sigCount)) { report.signature++; mergePatch(n, { data: { tier: 'signature' }, reason: 'signature tier' }); }

// Optional curation cut: archive the lowest-ranked uniques beyond --keep-top=N (reversible)
if (KEEP_TOP) {
  for (const { n } of scored.slice(Number(KEEP_TOP))) { if (!n.patch.archive) { report.deduped++; mergePatch(n, { archive: true, reason: 'below --keep-top cut' }); } }
}

// Pass 7: brand cards
const seed = JSON.parse(await readFile(new URL('./data/brand-attributes.seed.json', import.meta.url), 'utf8'));

report.samples = live.filter(n => n.patch.reasons?.length).slice(0, 20)
  .map(n => ({ file: n.fileName, changes: n.patch.reasons, data: n.patch.data, rename: n.patch.rename, archive: !!n.patch.archive }));

// ---- WRITE or REPORT ----
if (!APPLY) {
  await writeFile(path.join(VAULT, 'vault-improvement-report.json'), JSON.stringify(report, null, 2));
  console.log('DRY RUN — wrote vault-improvement-report.json\n', JSON.stringify({ ...report, samples: `${report.samples.length} samples`, songsMissingBpm: `${report.songsMissingBpm.length} songs` }, null, 2));
  process.exit(0);
}

const clean = gitClean(VAULT);
if (clean === false && !FORCE) { console.error('❌ vault git tree is dirty — commit/stash first or pass --force'); process.exit(2); }
if (clean === null) console.warn('⚠️ vault is not a git repo — make a backup before trusting --apply');

await mkdir(ARCHIVE_DIR, { recursive: true });
await mkdir(CONCEPTS_DIR, { recursive: true });

let written = 0;
for (const n of [...live, ...archive]) {
  const p = n.patch; if (!p.reasons?.length && !p.archive) continue;
  if (p.drop || p.archive) { await rename(path.join(BARS_DIR, n.fileName), path.join(ARCHIVE_DIR, n.fileName)); written++; continue; }
  const data = { ...n.data, ...p.data };
  const out = matter.stringify(n.body, data);
  const target = p.rename || n.fileName;
  await writeFile(path.join(BARS_DIR, target), out);
  if (p.rename && p.rename !== n.fileName) await rename(path.join(BARS_DIR, n.fileName), path.join(BARS_DIR, p.rename)).catch(()=>{});
  written++;
}
for (const s of seed) { const { fileName, content } = brandAttributeCard(s); await writeFile(path.join(CONCEPTS_DIR, fileName), content); report.brandCards++; }
console.log(`✅ applied ${written} note changes + ${report.brandCards} brand cards`);
await writeFile(path.join(VAULT, 'vault-improvement-report.json'), JSON.stringify(report, null, 2));
```

- [ ] **Step 2: Smoke-test the dry run against the real vault**

Run: `cd "tools/modelg-corpus" && node improve-vault.mjs "$HOME/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local"`
Expected: prints a summary (scanned ≈ 13192, corrupted ~100–300, deduped thousands, tonedInferred = the 452 + dupes, songsMissingBpm count) and writes `vault-improvement-report.json`. **No vault files changed.**

- [ ] **Step 3: Commit**

```bash
git add "tools/modelg-corpus/improve-vault.mjs"
git commit -m "feat(improve-vault): orchestrator with dry-run report + git-safe --apply"
```

---

## Task 10: Exporter `tier` support

**Files:** Modify `tools/modelg-corpus/lib/parsers.mjs`; Modify `XJournal AI/ModelG/Corpus/ModelGCorpusModels.swift`

- [ ] **Step 1: Add a failing exporter test** (in the existing `tools/modelg-corpus/build-corpus.test.mjs`)

```js
test('parseBar carries tier through from frontmatter', () => {
  const raw = '---\nsong: "S"\ntier: "signature"\nthemes: [confident]\n---\n# Contextual Lyric\n> x';
  const bar = parseBar('S - A signature line.md', raw);
  assert.equal(bar.tier, 'signature');
});
```

- [ ] **Step 2: Run → FAIL** (`bar.tier` undefined). Run: `cd "tools/modelg-corpus" && node --test build-corpus.test.mjs`

- [ ] **Step 3: Implement** — in `lib/parsers.mjs` `parseBar(...)` return object, add: `tier: data.tier ?? null,`

- [ ] **Step 4: Add `tier` to the Swift model** — in `XJournal AI/ModelG/Corpus/ModelGCorpusModels.swift`, `struct CorpusBar`, after `let scale: Int?`/`String?` line add:

```swift
    let tier: String?
```

(Swift `Codable` with an optional decodes a missing key as `nil`, so old JSON still loads.)

- [ ] **Step 5: Run → PASS** + Swift unit bundle still green.

Run: `cd "tools/modelg-corpus" && node --test build-corpus.test.mjs`
Run: `xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests/ModelGCorpusStoreTests"`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add "tools/modelg-corpus/lib/parsers.mjs" "tools/modelg-corpus/build-corpus.test.mjs" "XJournal AI/ModelG/Corpus/ModelGCorpusModels.swift"
git commit -m "feat(corpus): carry signature tier through exporter + Swift model"
```

---

## Task 11: Execute end-to-end — improve the vault, regenerate the corpus, verify

**Files:** none (operational). Vault is **backed up first**.

- [ ] **Step 1: Back up the vault** (the `--apply` writes to your notes)

```bash
cd "$HOME/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local"
git rev-parse --is-inside-work-tree 2>/dev/null && git add -A && git commit -m "pre-improve snapshot" || cp -R "../LLM builder local" "../LLM builder local.backup-$(date +%s)"
```

- [ ] **Step 2: Dry run, then read the report with the user**

Run: `cd "/Users/samuel/Documents/The Final Journal AI/tools/modelg-corpus" && node improve-vault.mjs "$HOME/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local"`
Review `vault-improvement-report.json` (`samples`, `songsMissingBpm`). **Decide `--keep-top` (or skip curation) with the user before applying.**

- [ ] **Step 3: Apply**

Run: `node improve-vault.mjs "$HOME/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local" --apply`
Expected: `✅ applied N note changes + 8 brand cards`.

- [ ] **Step 4: Regenerate the corpus**

Run: `cd "/Users/samuel/Documents/The Final Journal AI/tools/modelg-corpus" && node build-corpus.mjs "$HOME/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local"`
Expected: prints `bars=… concepts=… brandAttributes=… slang=…` and `bpm coverage: …` (now much higher) → writes `XJournal AI/ModelG/Corpus/ModelGCorpus.json`.

- [ ] **Step 5: Verify the win** (every bar toned; bpm coverage up; tier present; brand attrs up)

```bash
cd "/Users/samuel/Documents/The Final Journal AI"
python3 -c "import json;d=json.load(open('XJournal AI/ModelG/Corpus/ModelGCorpus.json'));b=d['bars'];print('bars',len(b));print('toned %',round(100*sum(1 for x in b if x['themes'])/len(b),1));print('bpm %',round(100*sum(1 for x in b if x.get('bpm') is not None)/len(b),1));print('signature',sum(1 for x in b if x.get('tier')=='signature'));print('brandAttributes',len(d['brandAttributes']))"
```
Expected: `toned %` ≈ 100, `bpm %` well above 61, `signature` ≈ 15% of bars, `brandAttributes` ≥ 8 more than before.

- [ ] **Step 6: Confirm the app still builds with the new corpus + Swift unit bundle green**

Run: `xcodebuild test -project "XJournal AI.xcodeproj" -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/xjournal-dd CODE_SIGNING_ALLOWED=NO -only-testing:"The Final Journal AITests"`
Expected: `** TEST SUCCEEDED **`.

- [ ] **Step 7: Commit the regenerated corpus**

```bash
git add "XJournal AI/ModelG/Corpus/ModelGCorpus.json"
git commit -m "data(modelg-corpus): regenerate from improved vault (100% toned, bpm-propagated, signature-tiered)"
```

---

## Self-Review

**Spec coverage (the 6):**
1. Tag + tone every bar → Task 4 (tone, 100% via floor) + Task 5 (tags). ✓
2. Curate/dedup → Task 3 (dedup, auto) + Task 9 `--keep-top` (reversible curation). ✓ (judgment cut surfaced, not forced)
3. `tier: signature` → Task 7 (score) + Task 9 (mark top 15%) + Task 10 (exporter+model). ✓
4. Fix corrupted filenames → Task 2. ✓
5. Expand brand→attributes → Task 8 (cards) + Task 9 (write) + seed file. ✓
6. BPM/scale → Task 6 (within-song propagation, auto) + report `songsMissingBpm` (residue). ✓

**Placeholder scan:** every pure pass has real code + tests; orchestrator is complete; the only deliberately-human steps are the `--keep-top` decision (Task 11 Step 2) and external BPM for `songsMissingBpm` (reported, not faked). No TBDs.

**Type consistency:** patches use `{ data, rename, cleanLyric, drop, archive, inferred, reason }` everywhere; `mergePatch` consumes exactly those; `TONES`/`VALID_TONES` shared; `deriveLyric`/`normalizeText` used by both orchestrator and tests.

**Safety:** dry-run default; `--apply` blocks on a dirty vault git tree (or `--force`); archive is a move (reversible); Swift `tier` optional so old JSON still decodes; vault backup is Task 11 Step 1.

---

## Honest limits (tell the user before --apply)
- **Tone inference is approximate** (song-majority → keyword → "confident" floor). It guarantees 100% retrieval coverage but some floored tones will be generic; the report flags every `inferred` one for spot-review.
- **Curation is opt-in** (`--keep-top`) and reversible (Archive/), never an auto-delete.
- **BPM** is filled only where a song already has it somewhere; songs with none are listed, not invented.
- **One turn = build the pipeline + dry-run + apply + regenerate**; the *review* of inferred tones / the `--keep-top` number is a 5-minute human checkpoint inside that turn.
