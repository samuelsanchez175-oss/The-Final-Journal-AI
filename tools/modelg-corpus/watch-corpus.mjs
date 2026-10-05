import chokidar from 'chokidar';
import { readFile, writeFile, rename, readdir, mkdir } from 'node:fs/promises';
import path from 'node:path';
import { parseBar, parseConcept, parseSlang } from './lib/parsers.mjs';

const VAULT = process.argv[2] ?? '/Users/samuel/Desktop/CLAUDE WORLD/LLM builder local/LLM builder local';
const OUT = process.argv[3] ?? path.resolve('../../XJournal AI/ModelG/Corpus/ModelGCorpus.json');

// Only these folders feed the corpus. Watching them directly (instead of the whole
// vault) skips Archive/ and other noise — fewer OS watchers, no wasted rebuilds.
const CORPUS_DIRS = ['4. Bar Notes', '5. Deep Concepts', '1. Slang & Lexicon'];
const DEBOUNCE_MS = 250;

function classify(rel) {
  if (rel.includes('4. Bar Notes/')) return 'bar';
  if (rel.includes('5. Deep Concepts/')) return 'concept';
  if (rel.includes('1. Slang & Lexicon/')) return 'slang';
  return null;
}

function parseOne(kind, rel, name, raw) {
  if (kind === 'bar') return parseBar(name, raw);        // parseBar keys id off the basename
  if (kind === 'concept') return parseConcept(rel, raw); // parseConcept keys category off the relPath
  return parseSlang(rel, raw);
}

// rel -> { kind, parsed }. Parsing happens once per file; edits re-parse only that file.
const cache = new Map();

async function walk(dir) {
  const out = [];
  for (const e of await readdir(dir, { withFileTypes: true })) {
    if (e.name.startsWith('.')) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...await walk(full));
    else if (e.name.endsWith('.md')) out.push(full);
  }
  return out;
}

// Assemble the corpus from cached parsed objects — no disk I/O, no re-parsing.
// Mirrors buildCorpus() in lib/parsers.mjs.
function assemble() {
  const bars = [], concepts = [], slang = [];
  for (const { kind, parsed } of cache.values()) {
    if (kind === 'bar') bars.push(parsed);
    else if (kind === 'concept') concepts.push(parsed);
    else slang.push(parsed);
  }
  const brandAttributes = [];
  for (const c of concepts) {
    if (c.category === 'Attribute') for (const p of c.parents) brandAttributes.push({ brand: p, attribute: c.name });
  }
  return { version: 1, bars, concepts, brandAttributes, slang };
}

let lastJson = null;
async function writeCorpus(reason) {
  const corpus = assemble();
  const json = JSON.stringify(corpus);
  const stamp = new Date().toLocaleTimeString();
  if (json === lastJson) { console.log(`[${stamp}] ${reason} — no corpus change, write skipped`); return; }
  lastJson = json;
  await mkdir(path.dirname(OUT), { recursive: true });
  // Write-then-rename so the app never reads a half-written file.
  const tmp = `${OUT}.tmp`;
  await writeFile(tmp, json);
  await rename(tmp, OUT);
  const withBpm = corpus.bars.filter(b => b.bpm != null).length;
  console.log(`[${stamp}] ${reason}`);
  console.log(`  bars=${corpus.bars.length} concepts=${corpus.concepts.length} brandAttributes=${corpus.brandAttributes.length} slang=${corpus.slang.length}`);
  console.log(`  bpm coverage: ${withBpm}/${corpus.bars.length}  ->  ${OUT}`);
}

// --- initial build: read + parse every corpus file once, in parallel ---
const watchDirs = [];
const allFiles = [];
for (const d of CORPUS_DIRS) {
  const abs = path.join(VAULT, d);
  try { allFiles.push(...await walk(abs)); watchDirs.push(abs); }
  catch { console.warn(`  (missing) ${d} — skipped`); }
}
// Read in parallel, but insert into the cache in walk order so the output is
// byte-identical to build-corpus.mjs (assemble() preserves insertion order).
const parsed = await Promise.all(allFiles.map(async (full) => {
  const rel = path.relative(VAULT, full);
  const kind = classify(rel);
  if (!kind) return null;
  return { rel, entry: { kind, parsed: parseOne(kind, rel, path.basename(full), await readFile(full, 'utf8')) } };
}));
for (const p of parsed) if (p) cache.set(p.rel, p.entry);
await writeCorpus('initial build');

// --- incremental updates ---
const pending = new Map(); // absPath -> event ('add' | 'change' | 'unlink')
let timer = null;
function schedule(event, filePath) {
  if (!filePath.endsWith('.md')) return;
  if (!classify(path.relative(VAULT, filePath))) return; // ignore edits that can't affect the corpus
  pending.set(filePath, event);
  clearTimeout(timer);
  timer = setTimeout(flush, DEBOUNCE_MS);
}
async function flush() {
  const batch = [...pending]; pending.clear();
  let changed = 0, removed = 0;
  for (const [filePath, event] of batch) {
    const rel = path.relative(VAULT, filePath);
    if (event === 'unlink') { if (cache.delete(rel)) removed++; continue; }
    try {
      const kind = classify(rel);
      cache.set(rel, { kind, parsed: parseOne(kind, rel, path.basename(filePath), await readFile(filePath, 'utf8')) });
      changed++;
    } catch (e) { console.error(`  skip ${rel}: ${e.message}`); }
  }
  const label = batch.length === 1
    ? `${batch[0][1]}: ${path.relative(VAULT, batch[0][0])}`
    : `${changed} changed, ${removed} removed`;
  await writeCorpus(label);
}

const watcher = chokidar.watch(watchDirs, {
  ignoreInitial: true,
  ignored: (p) => path.basename(p).startsWith('.'),
  awaitWriteFinish: { stabilityThreshold: 200, pollInterval: 50 }, // don't read mid-save
});
watcher.on('all', schedule).on('error', (e) => console.error('watch error:', e.message));

process.on('SIGINT', async () => { console.log('\nStopping watcher…'); await watcher.close(); process.exit(0); });

console.log(`\nWatching ${watchDirs.length} folder(s) under ${VAULT}`);
console.log('Press Ctrl+C to stop.\n');
