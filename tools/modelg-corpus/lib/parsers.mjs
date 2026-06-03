import matter from 'gray-matter';
import path from 'node:path';

export function slugify(s) {
  return s.toLowerCase().replace(/\.md$/, '')
    .replace(/[''`]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '').slice(0, 90);
}

export function normalizeText(s) {
  return s.toLowerCase()
    .replace(/\([^)]*\)/g, '')
    .replace(/[^a-z0-9 ]+/g, '')
    .replace(/\s+/g, ' ').trim();
}

export function extractWikilinks(s) {
  const out = []; const re = /\[\[([^\]|]+?)(?:\|[^\]]+)?\]\]/g; let m;
  while ((m = re.exec(s)) !== null) out.push(m[1].trim());
  return out;
}

function asArray(v) { return Array.isArray(v) ? v : (v == null || v === '' ? [] : [v]); }

export function parseBar(fileName, raw) {
  const { content, data } = matter(raw);
  const bold = content.match(/\*\*(.+?)\*\*/);
  let full = bold
    ? bold[1].trim()
    : path.basename(fileName).replace(/\.md$/, '').replace(/^.*? - /, '').replace(/[_ ]\d+$/, '').trim();
  let text = full, adlib = null;
  const am = full.match(/^(.*?)\s*\(([^)]+)\)\s*$/);
  if (am) { text = am[1].trim(); adlib = am[2].trim(); }
  const context = [];
  for (const line of content.split('\n')) {
    const cm = line.match(/^\s*\d+\s*>\s*(.+?)\s*$/);
    if (cm) context.push(cm[1].replace(/\*\*/g, '').trim());
  }
  const concepts = [...new Set(extractWikilinks(content))];
  return {
    id: slugify(fileName),
    text, adlib, norm: normalizeText(text),
    artist: data.artist ?? null,
    activeArtist: data.active_artist ?? null,
    song: data.song ?? null,
    album: data.album ?? null,
    section: data.section ?? null,
    themes: asArray(data.themes),
    tags: asArray(data.tags),
    bpm: typeof data.bpm === 'number' ? data.bpm : null,
    scale: data.scale ?? null,
    concepts, context,
  };
}

export function parseConcept(filePath, raw) {
  const { content, data } = matter(raw);
  const name = path.basename(filePath).replace(/\.md$/, '');
  const lower = filePath.toLowerCase();
  let category = 'Concept';
  if (lower.includes('/attributes/')) category = 'Attribute';
  else if (lower.includes('/brands/')) category = 'Brand';
  else if (lower.includes('/jewelry/')) category = 'Jewelry';
  else if (lower.includes('/vehicles/')) category = 'Vehicle';
  else if (lower.includes('/1. core themes/')) category = 'CoreTheme';
  else if (lower.includes('/3. actions')) category = 'Action';
  else if (lower.includes('/4. audience/')) category = 'Audience';
  let parents = [];
  const section = content.split(/^#{2,3}\s+/m).find(s => /^parent concept/i.test(s));
  if (section) parents = extractWikilinks(section);
  return {
    name, category, parents,
    aliases: [...new Set(asArray(data.aliases))],
    tags: asArray(data.tags),
  };
}

export function parseSlang(filePath, raw) {
  const { content, data } = matter(raw);
  const name = path.basename(filePath).replace(/\.md$/, '');
  let definition = null;
  const dm = content.match(/\*\*Definition:\*\*\s*\n?\s*>?\s*(.+)/);
  if (dm) definition = dm[1].trim() || null;
  return {
    term: data.term ?? name,
    category: data.category ?? null,
    themePrimary: data.theme_primary ?? null,
    definition,
  };
}

export function buildCorpus(files) {
  const bars = [], concepts = [], slang = [];
  for (const f of files) {
    if (f.kind === 'bar') bars.push(parseBar(f.name, f.raw));
    else if (f.kind === 'concept') concepts.push(parseConcept(f.relPath, f.raw));
    else if (f.kind === 'slang') slang.push(parseSlang(f.relPath, f.raw));
  }
  const brandAttributes = [];
  for (const c of concepts) {
    if (c.category === 'Attribute') {
      for (const p of c.parents) brandAttributes.push({ brand: p, attribute: c.name });
    }
  }
  return { version: 1, bars, concepts, brandAttributes, slang };
}
