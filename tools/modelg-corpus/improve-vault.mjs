// One-pass vault improver. Dry-run by default (writes a report, changes nothing); --apply writes.
// usage: node improve-vault.mjs <vaultDir> [--apply] [--keep-top=N] [--cross-song-dedup] [--force]
import { readFile, writeFile, readdir, rename, mkdir } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import matter from 'gray-matter';
import {
  deriveLyric, normalizeText, cleanCorruption, dedupe, inferTone, inferTags,
  songBpmScale, applyBpmScale, signatureScore, brandAttributeCard,
} from './lib/vault-ops.mjs';

const VAULT = process.argv[2];
const APPLY = process.argv.includes('--apply');
const FORCE = process.argv.includes('--force');
const CROSS = process.argv.includes('--cross-song-dedup');
const KEEP_TOP = (process.argv.find(a => a.startsWith('--keep-top=')) || '').split('=')[1];
const SIG_FRACTION = 0.15;
if (!VAULT) { console.error('usage: node improve-vault.mjs <vaultDir> [--apply] [--keep-top=N] [--cross-song-dedup] [--force]'); process.exit(1); }

const BARS_DIR = path.join(VAULT, '4. Bar Notes');
const CONCEPTS_DIR = path.join(VAULT, '5. Deep Concepts', 'Attributes');
const ARCHIVE_DIR = path.join(VAULT, 'Archive');
const TONE_LEX = {
  luxurious: ['diamond', 'rolex', 'drip', 'designer', 'vvs', 'birkin', 'foreign', 'chanel', 'gucci'],
  aggressive: ['stick', 'slide', 'glock', 'draco', 'opp', 'shoot', 'beam', 'choppa'],
  paranoid: ['paranoid', 'watch', 'snake', 'cross', 'fed', 'wire', 'tap'],
  celebratory: ['party', 'pop', 'toast', 'champagne', 'win', 'celebrate'],
  aspirational: ['dream', 'grind', 'came from', 'one day', 'make it', 'hustle'],
};

function gitClean(dir) {
  try { return execFileSync('git', ['-C', dir, 'status', '--porcelain'], { encoding: 'utf8' }).trim() === ''; }
  catch { return null; }
}

async function loadBars() {
  const files = (await readdir(BARS_DIR)).filter(f => f.endsWith('.md'));
  const notes = [];
  for (const fileName of files) {
    const raw = await readFile(path.join(BARS_DIR, fileName), 'utf8');
    let parsed; try { parsed = matter(raw); } catch { parsed = { data: {}, content: raw }; }
    const { lyric, adlib } = deriveLyric(fileName);
    const concepts = [...new Set([...parsed.content.matchAll(/\[\[([^\]|]+?)(?:\|[^\]]+)?\]\]/g)].map(m => m[1].trim()))];
    notes.push({ fileName, data: parsed.data || {}, body: parsed.content, lyric, adlib, norm: normalizeText(lyric), concepts, patch: { data: {}, reasons: [] } });
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
  note.patch.reasons.push(p.reason);
}

const report = { vault: VAULT, mode: APPLY ? 'apply' : 'dry-run', scanned: 0, corrupted: 0,
  deduped: 0, tonedInferred: 0, taggedInferred: 0, bpmFilled: 0, signature: 0, brandCards: 0,
  curationCut: 0, songsMissingBpm: 0, songsMissingBpmList: [], samples: [] };

const notes = await loadBars();
report.scanned = notes.length;

// Pass 1: corruption
for (const n of notes) { const p = cleanCorruption(n); if (p) { report.corrupted++; mergePatch(n, p); if (p.cleanLyric) n.norm = normalizeText(p.cleanLyric); } }

// Pass 2: dedupe (conservative = same-song only, unless --cross-song-dedup)
const { keep, archive } = dedupe(notes, { crossSong: CROSS });
for (const n of archive) { report.deduped++; mergePatch(n, { archive: true, reason: 'duplicate (same song)' }); }
const live = keep.filter(n => !n.patch.drop);

// Passes 3/4/5: tone, tags, bpm — grouped by song
for (const [song, bars] of bySong(live)) {
  const known = songBpmScale(bars);
  if (known.bpm == null) { report.songsMissingBpm++; if (report.songsMissingBpmList.length < 50) report.songsMissingBpmList.push(song); }
  const songTags = [...new Set(bars.flatMap(b => b.data.tags || []))];
  for (const n of bars) {
    const sibTones = bars.filter(b => b !== n).flatMap(b => b.data.themes || []);
    let p = inferTone(n, sibTones, TONE_LEX); if (p) { report.tonedInferred++; mergePatch(n, p); }
    p = inferTags(n, songTags); if (p) { report.taggedInferred++; mergePatch(n, p); }
    p = applyBpmScale(n, known); if (p) { report.bpmFilled++; mergePatch(n, p); }
  }
}

// Pass 6: signature tier — top fraction by score among live
const scored = live.map(n => ({ n, s: signatureScore(n) })).sort((a, b) => b.s - a.s);
const sigCount = Math.round(scored.length * SIG_FRACTION);
for (const { n } of scored.slice(0, sigCount)) { report.signature++; mergePatch(n, { data: { tier: 'signature' }, reason: 'signature tier' }); }

// Optional reversible curation cut (only when --keep-top given)
if (KEEP_TOP) {
  for (const { n } of scored.slice(Number(KEEP_TOP))) { if (!n.patch.archive) { report.curationCut++; mergePatch(n, { archive: true, reason: 'below --keep-top cut' }); } }
}

report.samples = live.filter(n => n.patch.reasons.length).slice(0, 25)
  .map(n => ({ file: n.fileName, changes: n.patch.reasons, add: n.patch.data, rename: n.patch.rename || null, archive: !!n.patch.archive }));

const seed = JSON.parse(await readFile(new URL('./data/brand-attributes.seed.json', import.meta.url), 'utf8'));
report.brandCards = seed.length;

function printSummary() {
  const { samples, songsMissingBpmList, ...counts } = report;
  console.log(JSON.stringify(counts, null, 2));
}

if (!APPLY) {
  await writeFile(path.join(VAULT, 'vault-improvement-report.json'), JSON.stringify(report, null, 2));
  console.log('DRY RUN — wrote vault-improvement-report.json (nothing changed)');
  printSummary();
  process.exit(0);
}

// ---- APPLY ----
const clean = gitClean(VAULT);
if (clean === false && !FORCE) { console.error('❌ vault git tree is dirty — commit/stash first or pass --force'); process.exit(2); }
if (clean === null) console.warn('⚠️ vault is not a git repo — ensure you made a backup');

await mkdir(ARCHIVE_DIR, { recursive: true });
await mkdir(CONCEPTS_DIR, { recursive: true });

let written = 0, moved = 0;
for (const n of [...live, ...archive]) {
  const p = n.patch;
  if (p.drop || p.archive) { await rename(path.join(BARS_DIR, n.fileName), path.join(ARCHIVE_DIR, n.fileName)).catch(() => {}); moved++; continue; }
  if (!p.reasons.length) continue;
  const data = { ...n.data, ...p.data };
  const out = matter.stringify(n.body, data);
  if (p.rename && p.rename !== n.fileName) {
    await writeFile(path.join(BARS_DIR, p.rename), out);
    await rename(path.join(BARS_DIR, n.fileName), path.join(ARCHIVE_DIR, n.fileName)).catch(() => {});
  } else {
    await writeFile(path.join(BARS_DIR, n.fileName), out);
  }
  written++;
}
for (const s of seed) { const { fileName, content } = brandAttributeCard(s); await writeFile(path.join(CONCEPTS_DIR, fileName), content); }
await writeFile(path.join(VAULT, 'vault-improvement-report.json'), JSON.stringify(report, null, 2));
console.log(`✅ applied — ${written} notes rewritten, ${moved} moved to Archive/, ${seed.length} brand cards`);
printSummary();
