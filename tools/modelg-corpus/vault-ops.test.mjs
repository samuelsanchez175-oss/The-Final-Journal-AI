import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  deriveLyric, normalizeText, TONES, cleanCorruption, dedupe, inferTone, inferTags,
  songBpmScale, applyBpmScale, signatureScore, brandAttributeCard,
} from './lib/vault-ops.mjs';

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

test('cleanCorruption strips URL/markdown bleed and proposes a rename', () => {
  const note = { fileName: "Song - She talkin bout licks](https---genius.com-123-x.md", lyric: "She talkin bout licks](https---genius.com-123-x" };
  const p = cleanCorruption(note);
  assert.equal(p.cleanLyric, "She talkin bout licks");
  assert.match(p.rename, /^Song - She talkin bout licks\.md$/);
});
test('cleanCorruption returns null for clean notes', () => {
  assert.equal(cleanCorruption({ fileName: "Song - Clean line.md", lyric: "Clean line" }), null);
});

test('dedupe (conservative) collapses same-song variants, keeps the clean name', () => {
  const notes = [
    { fileName: "S - Line 3.md", norm: "line", data: { song: "S" } },
    { fileName: "S - Line.md",   norm: "line", data: { song: "S" } },
    { fileName: "S - Other.md",  norm: "other", data: { song: "S" } },
  ];
  const { keep, archive } = dedupe(notes);
  assert.deepEqual(keep.map(n => n.fileName).sort(), ["S - Line.md", "S - Other.md"]);
  assert.deepEqual(archive.map(n => n.fileName), ["S - Line 3.md"]);
});
test('dedupe (conservative) KEEPS the same line in different songs', () => {
  const notes = [
    { fileName: "A - Line.md", norm: "line", data: { song: "A" } },
    { fileName: "B - Line.md", norm: "line", data: { song: "B" } },
  ];
  const { keep, archive } = dedupe(notes);
  assert.equal(keep.length, 2);
  assert.equal(archive.length, 0);
});
test('dedupe (crossSong) collapses across songs when asked', () => {
  const notes = [
    { fileName: "A - Line.md", norm: "line", data: { song: "A" } },
    { fileName: "B - Line.md", norm: "line", data: { song: "B" } },
  ];
  assert.equal(dedupe(notes, { crossSong: true }).archive.length, 1);
});

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

test('inferTags keeps existing tags untouched', () => {
  assert.equal(inferTags({ data: { tags: ["gun"] }, concepts: [], lyric: "" }, []), null);
});
test('inferTags derives from concepts and song siblings, deduped + lowercased', () => {
  const p = inferTags({ data: { tags: [] }, concepts: ["Glock 19","Money"], lyric: "" }, ["weapon","weapon"]);
  assert.deepEqual(p.data.tags.sort(), ["glock 19","money","weapon"]);
  assert.equal(p.inferred, true);
});

test('songBpmScale picks the most common bpm/scale present', () => {
  const bars = [{ data: { bpm: 120, scale: "E Minor" } }, { data: { bpm: 120 } }, { data: {} }];
  assert.deepEqual(songBpmScale(bars), { bpm: 120, scale: "E Minor" });
});
test('applyBpmScale fills only missing fields; null when nothing to add or nothing known', () => {
  assert.deepEqual(applyBpmScale({ data: {} }, { bpm: 120, scale: "E Minor" }).data, { bpm: 120, scale: "E Minor" });
  assert.equal(applyBpmScale({ data: { bpm: 120, scale: "E Minor" } }, { bpm: 120, scale: "E Minor" }), null);
  assert.equal(applyBpmScale({ data: {} }, { bpm: null, scale: null }), null);
});

test('signatureScore rewards concept-dense, well-sized bars and punishes interjections', () => {
  const dense = { lyric: "Cross on the Chrome Heart, three K for the jeans", concepts: ["Chrome Hearts","Designer Jeans"], data: { tags: ["jewelry"] } };
  const adlib = { lyric: "Ah", concepts: [], data: { tags: [] } };
  assert.ok(signatureScore(dense) > signatureScore(adlib));
  assert.ok(signatureScore(adlib) <= 0);
});

test('brandAttributeCard renders an Obsidian Attribute note with a parent wikilink', () => {
  const { fileName, content } = brandAttributeCard({ brand: "Jewelry and Timepieces", attribute: "Bustdown", aliases: ["bustdown"] });
  assert.equal(fileName, "Bustdown.md");
  assert.match(content, /aliases:/);
  assert.match(content, /## Parent Concept\n\n\[\[Jewelry and Timepieces\]\]/);
});
