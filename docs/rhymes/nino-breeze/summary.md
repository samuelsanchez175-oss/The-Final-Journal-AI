# Nino Breeze rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Nino Breeze
- Songs: 1
- Bars kept (Nino Breeze lyric lines): 35
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Nino Breeze.
- Credit strings: Nino Breeze.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 366
- REPEAT pairs, recorded separately: 40
- END rhymes: 45
- INNER rhymes: 321

By match:

- PERFECT: 56 (END 10, INNER 46)
- SLANT: 96 (END 8, INNER 88)
- ASSONANCE: 214 (END 27, INNER 187)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 49
- MED: 292
- LOW: 25

## Core

- Core Y: 354
- Core N among rhyme pairs: 12

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 132 (36.1%)
- vowel: 214 (58.5%)
- spelling: 20 (5.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 70 pairs (END 19, INNER 51). Words: ambulance, pants, cameraman, hammer, hand, man, dance, can't.
2. `vow:AY` — 40 pairs (END 0, INNER 40). Words: stripes, life, side, high, tries, try, price, guy.
3. `vow:OW` — 40 pairs (END 1, INNER 39). Words: don't, no, know, go, promo, chose, close, hoes.
4. `cmu:AY` — 22 pairs (END 6, INNER 16). Words: why, guy, high, lie, eye, pie, try.
5. `vow:EY` — 20 pairs (END 5, INNER 15). Words: shake, player, say, ain't, waste, taste, stay, waist.
6. `vow:AA` — 16 pairs (END 1, INNER 15). Words: bonkers, sponsored, monster, goddess, retarded, gotta, spot, chop.
7. `slant:AE:sib-stop` — 15 pairs (END 1, INNER 14). Words: dance, stand, chance, can't, stash, jag, cash, trap.
8. `cmu:OW` — 14 pairs (END 0, INNER 14). Words: go, know, no, metro, show, promo, ho.
9. `slant:AE:stop` — 8 pairs (END 0, INNER 8). Words: can't, stand, jag, smacked, pack.
10. `vow:IH` — 8 pairs (END 0, INNER 8). Words: bitch, think, wrist, whip, grippin, inn.
11. `vow:AH` — 7 pairs (END 1, INNER 6). Words: dumbo, gun, bump, duck, bust, hunchos.
12. `cmu:OW-S` — 6 pairs (END 0, INNER 6). Words: mofos, ochos, stolos, close.
13. `slant:AY:sib` — 6 pairs (END 0, INNER 6). Words: tries, price, advice, stripes.
14. `vow:IY` — 6 pairs (END 0, INNER 6). Words: free, sleepin, these, v, team, shawty, here.
15. `slant:AE:nas` — 5 pairs (END 0, INNER 5). Words: man, damn, goddamn, standin, cameraman, blam, hammer.
16. `slant:AE:nas-stop` — 5 pairs (END 3, INNER 2). Words: fan, hand, handstand, man, standin.
17. `slant:AE:sib` — 4 pairs (END 2, INNER 2). Words: dance, bands, pants.
18. `slant:AY:sib-stop` — 4 pairs (END 0, INNER 4). Words: side, tries, price, advice.
19. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: get, neck, deck, dead, buried.
20. `vow:EH` — 4 pairs (END 0, INNER 4). Words: presidents, buried, heads, dead.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ochos — 6 pair sides, mostly spelling via spelling phonetic key, often with promo (1)
- blam — 6 pair sides, mostly vowel via spelling phonetic key, often with pants (1)
- mofos — 5 pair sides, mostly spelling via spelling phonetic key, often with sold (1)
- stolos — 5 pair sides, mostly spelling via spelling phonetic key, often with sold (1)
- jag — 4 pair sides, mostly spelling via spelling phonetic key, often with stash (1)
- fuckboy — 2 pair sides, mostly spelling via spelling phonetic key, often with boy (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with team (1)
- shawty — 2 pair sides, mostly vowel via spelling phonetic key, often with free (1)
- hunchos — 1 pair sides, mostly vowel via spelling phonetic key, often with dumbo (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Nino Breeze | Benjamins | 35 | 45 | 321 | loose |
