import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseBar, parseConcept, parseSlang, buildCorpus } from './lib/parsers.mjs';

const BAR = `---
artist: "Gunna"
album: "Drip Harder"
song: "World Is Yours"
section: "Chorus"
active_artist: "Gunna"
themes: [confident]
tags:
  - master-concept/wealth-brands
bpm: 112
scale: "C# Major"
type: bar_note
---
## Contextual Lyric
53 > Tattoos on my neck and my arms (Arms)
54 > **Got garments that's never been worn (Nope)**
55 > Got a dime bitch the same color orange (Orange)

## The Breakdown
**Related Concepts:** [[Dealing with Women]] | [[Jewelry, Money, and Cars]]

- [[Ice & Diamonds]]
`;

const ATTR = `---
tags:
  - concept
aliases:
  - Exotic Leathers
---
### Parent Concept
- [[Birkin]]
`;

const SLANG = `---
term: "Buying the block back"
category: "contextual_signal"
theme_primary: "wealth_lifestyle"
type: lexicon
---
**Definition:**
> Reinvesting wealth into the old neighborhood.
`;

test('parseBar extracts bolded line, adlib, fields, concepts, context', () => {
  const b = parseBar("World Is Yours - Got garments that's never been worn (Nope)_2.md", BAR);
  assert.equal(b.text, "Got garments that's never been worn");
  assert.equal(b.adlib, "Nope");
  assert.equal(b.artist, "Gunna");
  assert.equal(b.song, "World Is Yours");
  assert.equal(b.bpm, 112);
  assert.equal(b.scale, "C# Major");
  assert.deepEqual(b.themes, ["confident"]);
  assert.ok(b.concepts.includes("Dealing with Women"));
  assert.ok(b.concepts.includes("Ice & Diamonds"));
  assert.ok(b.context.includes("Tattoos on my neck and my arms (Arms)"));
  assert.equal(b.norm, "got garments thats never been worn");
  assert.ok(b.id.length > 0);
});

test('parseConcept derives category from path + parents from Parent Concept', () => {
  const c = parseConcept("5. Deep Concepts/2. Wealth & Escapism/Brands/Attributes/Exotic Leathers.md", ATTR);
  assert.equal(c.name, "Exotic Leathers");
  assert.equal(c.category, "Attribute");
  assert.deepEqual(c.parents, ["Birkin"]);
  assert.deepEqual(c.tags, ["concept"]);
});

test('parseSlang extracts term, category, theme, definition', () => {
  const s = parseSlang("1. Slang & Lexicon/Buying the block back.md", SLANG);
  assert.equal(s.term, "Buying the block back");
  assert.equal(s.category, "contextual_signal");
  assert.equal(s.themePrimary, "wealth_lifestyle");
  assert.equal(s.definition, "Reinvesting wealth into the old neighborhood.");
});

const OLD_BAR = `---
artist: "Gunna"
song: "bread & butter"
active_artist: "Gunna"
bpm: 172
type: bar_note
---
**Song:** bread & butter
**Active Artist:** Gunna
**Section:** Verse 2

## Contextual Lyric
42 > Never gave no statement or agree to take no stand on 'em
43 > **On whatever you niggas on and trust me, I'ma stand on it**
44 > Lawyers and the DA did some sneaky shit, I fell for it

## The Breakdown
**Related Concepts:** [[General Lyricism and Flexing]]
`;

test('parseBar uses filename lyric, not the **Song:** metadata label (old format)', () => {
  const b = parseBar("bread & butter - On whatever you niggas on and trust me, I'ma stand on it.md", OLD_BAR);
  assert.equal(b.text, "On whatever you niggas on and trust me, I'ma stand on it");
  assert.notEqual(b.text, "Song:");
  assert.ok(b.context.includes("On whatever you niggas on and trust me, I'ma stand on it"));
});

test('buildCorpus routes by kind and materializes brand->attribute pairs', () => {
  const files = [
    { relPath: "4. Bar Notes/x.md", name: "World Is Yours - Got garments (Nope).md", raw: BAR, kind: "bar" },
    { relPath: "5. Deep Concepts/2. Wealth & Escapism/Brands/Attributes/Exotic Leathers.md", name: "Exotic Leathers.md", raw: ATTR, kind: "concept" },
    { relPath: "1. Slang & Lexicon/Buying the block back.md", name: "Buying the block back.md", raw: SLANG, kind: "slang" },
  ];
  const c = buildCorpus(files);
  assert.equal(c.version, 1);
  assert.equal(c.bars.length, 1);
  assert.equal(c.concepts.length, 1);
  assert.equal(c.slang.length, 1);
  assert.deepEqual(c.brandAttributes, [{ brand: "Birkin", attribute: "Exotic Leathers" }]);
});
