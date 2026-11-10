# ZillaKami rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: ZillaKami
- Songs: 1
- Bars kept (ZillaKami lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: ZillaKami.
- Credit strings: ZillaKami.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 218
- REPEAT pairs, recorded separately: 25
- END rhymes: 44
- INNER rhymes: 174

By match:

- PERFECT: 20 (END 5, INNER 15)
- SLANT: 93 (END 25, INNER 68)
- ASSONANCE: 105 (END 14, INNER 91)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 18
- MED: 191
- LOW: 9

## Core

- Core Y: 214
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 104 (47.7%)
- vowel: 105 (48.2%)
- spelling: 9 (4.1%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 36 pairs (END 6, INNER 30). Words: manson, can't, cannot, flats, scratch, batch, match, relax.
2. `vow:AY` — 14 pairs (END 3, INNER 11). Words: why, fire, like, reminder, bite, eyes, outside, try.
3. `slant:AE:sib-stop` — 13 pairs (END 9, INNER 4). Words: back, badass, ass, fat, bag, scratch, lap, packs.
4. `slant:IH:sib-stop` — 13 pairs (END 4, INNER 9). Words: bitch, stick, smith, miss, shit, lip, big, whip.
5. `slant:IH:stop` — 9 pairs (END 1, INNER 8). Words: stick, kick, big, drink, slip, whip, shit, lip.
6. `vow:AH` — 9 pairs (END 1, INNER 8). Words: fuckin, bust, dust, tooted, blood, fuck.
7. `vow:EY` — 9 pairs (END 3, INNER 6). Words: way, hatin, paid, grenade, raise.
8. `slant:AE:stop` — 8 pairs (END 5, INNER 3). Words: back, bag, lap, fat, can't, cannot.
9. `vow:EH` — 7 pairs (END 0, INNER 7). Words: yellin, let, gettin, freddy, marilyn, getting, never, get.
10. `vow:IH` — 7 pairs (END 0, INNER 7). Words: witness, drink, smith, stick, whip, biggy, really, bitch.
11. `vow:OW` — 7 pairs (END 1, INNER 6). Words: smokin, won’t, poles, ghost, throwing, focus, don’t, whole.
12. `vow:UW` — 7 pairs (END 0, INNER 7). Words: cruisin, booted, through, who.
13. `slant:AA:stop` — 6 pairs (END 0, INNER 6). Words: got, locked, pop, block.
14. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: fuckin, fuck.
15. `slant:AO:liq-stop` — 5 pairs (END 0, INNER 5). Words: thought, y’all, y'all, talk.
16. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: lil, really, big, shit, stick, kick.
17. `cmu:AO-L` — 4 pairs (END 0, INNER 4). Words: all, y'all, y’all.
18. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: bitch, really, lil, miss.
19. `vow:IY` — 4 pairs (END 0, INNER 4). Words: leave, see, biggy, probably, geeked, pussy, xanny.
20. `cmu:AE-CH` — 3 pairs (END 1, INNER 2). Words: scratch, match, batch.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- xanny — 3 pair sides, mostly spelling via spelling phonetic key, often with pussy (1)
- tooted — 2 pair sides, mostly vowel via vault phonetic_class, often with dust (1)
- nickelback — 2 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with witness (1)
- biggy — 2 pair sides, mostly vowel via spelling phonetic key, often with see (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with whole (1)
- geeked — 1 pair sides, mostly vowel via spelling phonetic key, often with leave (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with manson (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with hip (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| ZillaKami | BADASS | 34 | 44 | 174 | loose |
