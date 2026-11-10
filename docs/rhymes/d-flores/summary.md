# D.Flores rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: D.Flores
- Songs: 1
- Bars kept (D.Flores lyric lines): 30
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: D.Flores.
- Credit strings: D.Flores.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 230
- REPEAT pairs, recorded separately: 64
- END rhymes: 65
- INNER rhymes: 165

By match:

- PERFECT: 24 (END 15, INNER 9)
- SLANT: 100 (END 26, INNER 74)
- ASSONANCE: 106 (END 24, INNER 82)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 23
- MED: 177
- LOW: 30

## Core

- Core Y: 216
- Core N among rhyme pairs: 14

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 103 (44.8%)
- vowel: 106 (46.1%)
- spelling: 21 (9.1%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 45 pairs (END 10, INNER 35). Words: say, ain't, hate, face, snakes, birthday, everyday, cake.
2. `vow:IH` — 33 pairs (END 5, INNER 28). Words: i'mma, nigga, bitch, hills, bitches, shit, killed, lil.
3. `slant:IH:sib-stop` — 28 pairs (END 12, INNER 16). Words: bitch, shit, nigga, niggas, twitter, bit, dig, hills.
4. `vow:OW` — 16 pairs (END 9, INNER 7). Words: most, go, close, blow, no, know, won't, smoke.
5. `slant:IH:liq-sib` — 8 pairs (END 0, INNER 8). Words: bitch, kill, lil, hills.
6. `slant:IH:stop` — 8 pairs (END 2, INNER 6). Words: nigga, shit, ticket, bit, dig, twitter.
7. `cmu:OW` — 7 pairs (END 7, INNER 0). Words: blow, go.
8. `slant:EY:sib-stop` — 7 pairs (END 5, INNER 2). Words: face, hate, snakes, cake, fake, lake.
9. `slant:IH:liq-stop` — 7 pairs (END 0, INNER 7). Words: lil, bit, kill, shit, dig, twitter.
10. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: let, disrespect, get, spent.
11. `cmu:EY` — 4 pairs (END 0, INNER 4). Words: say, birthday, everyday, play.
12. `spell:itch` — 4 pairs (END 3, INNER 1). Words: killswitch, bitch.
13. `vow:IY` — 4 pairs (END 0, INNER 4). Words: even, see, meal, these, screamin.
14. `cmu:EY-K` — 3 pairs (END 3, INNER 0). Words: cake, fake, lake.
15. `cmu:IH-T` — 3 pairs (END 2, INNER 1). Words: shit, bit.
16. `slant:EY:stop` — 3 pairs (END 0, INNER 3). Words: hate, ain't, cake.
17. `slant:IH:nas` — 3 pairs (END 0, INNER 3). Words: i'mma, i'ma.
18. `vow:EH` — 3 pairs (END 0, INNER 3). Words: beverly, when, get, spent, whenever.
19. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: got, opp, gotta.
20. `slant:AE:nas-sib` — 2 pairs (END 0, INNER 2). Words: cash, man.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 19 pair sides, mostly spelling via spelling phonetic key, often with imma (8)
- imma — 14 pair sides, mostly vowel via spelling phonetic key, often with nigga (8)
- niggas — 10 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- killswitch — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with imma (3)
- shondale — 1 pair sides, mostly vowel via spelling phonetic key, often with smoked (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| D.Flores | Let It Blow | 30 | 65 | 165 | loose |
