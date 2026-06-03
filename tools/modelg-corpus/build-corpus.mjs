import { readFile, writeFile, readdir, mkdir } from 'node:fs/promises';
import path from 'node:path';
import { buildCorpus } from './lib/parsers.mjs';

const VAULT = process.argv[2];
const OUT = process.argv[3] ?? path.resolve('../../XJournal AI/ModelG/Corpus/ModelGCorpus.json');
if (!VAULT) { console.error('usage: node build-corpus.mjs <vaultDir> [outFile]'); process.exit(1); }

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
function classify(rel) {
  if (rel.includes('4. Bar Notes/')) return 'bar';
  if (rel.includes('5. Deep Concepts/')) return 'concept';
  if (rel.includes('1. Slang & Lexicon/')) return 'slang';
  return null;
}

const files = [];
for (const full of await walk(VAULT)) {
  const rel = path.relative(VAULT, full);
  const kind = classify(rel);
  if (!kind) continue;
  files.push({ relPath: rel, name: path.basename(full), raw: await readFile(full, 'utf8'), kind });
}
const corpus = buildCorpus(files);
await mkdir(path.dirname(OUT), { recursive: true });
await writeFile(OUT, JSON.stringify(corpus));
const withBpm = corpus.bars.filter(b => b.bpm != null).length;
console.log(`bars=${corpus.bars.length} concepts=${corpus.concepts.length} brandAttributes=${corpus.brandAttributes.length} slang=${corpus.slang.length}`);
console.log(`bpm coverage: ${withBpm}/${corpus.bars.length}`);
console.log(`-> ${OUT}`);
