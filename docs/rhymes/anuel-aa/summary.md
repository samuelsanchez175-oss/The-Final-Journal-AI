# Anuel AA rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Anuel AA
- Songs: 1
- Bars kept (Anuel AA lyric lines): 67
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Anuel AA.
- Credit strings: Anuel AA.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 831
- REPEAT pairs, recorded separately: 59
- END rhymes: 52
- INNER rhymes: 779

By match:

- PERFECT: 111 (END 5, INNER 106)
- SLANT: 213 (END 7, INNER 206)
- ASSONANCE: 473 (END 29, INNER 444)
- MULTI: 34 (END 11, INNER 23)

By confidence:

- HIGH: 71
- MED: 326
- LOW: 434

## Core

- Core Y: 518
- Core N among rhyme pairs: 313

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 161 (19.4%)
- vowel: 473 (56.9%)
- spelling: 163 (19.6%)
- multi: 34 (4.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 297 pairs (END 21, INNER 276). Words: no, nuevo, creo, los, lo, cielo, corillo, lleno.
2. `vow:EH` — 44 pairs (END 0, INNER 44). Words: est, el, en, retro, n, vest, went, desde.
3. `cmu:IY` — 39 pairs (END 0, INNER 39). Words: de, mi, e, t, te, ni, 't, li.
4. `vow:AA` — 38 pairs (END 0, INNER 38). Words: la, las, con, pa, hombre, carn, armas, marc.
5. `vow:IY` — 35 pairs (END 2, INNER 33). Words: de, dios, reaper, real, rico, negro, e, chino.
6. `slant:EH:liq-nas` — 25 pairs (END 2, INNER 23). Words: el, en, n, m, cuello, canelo, lleno, 'el.
7. `slant:EH:nas-stop` — 25 pairs (END 0, INNER 25). Words: en, n, lleg, lleno, mente, eta, gen, bebi.
8. `vow:AE` — 22 pairs (END 4, INNER 18). Words: salga, tampa, ahorcan, falso, atraso, parezco, atleta, palo.
9. `cmu:EH-N` — 19 pairs (END 0, INNER 19). Words: n, en, descansen, tienen, hacen, siguen, saben.
10. `slant:EH:nas` — 18 pairs (END 0, INNER 18). Words: m, en, n, mwen, lleno, dem, demonio, descansen.
11. `vow:EY` — 14 pairs (END 0, INNER 14). Words: se, haitian, lage, translate, k, say, take, ba.
12. `slant:EH:nas-sib` — 12 pairs (END 0, INNER 12). Words: en, n, les, menos, mayweather, tres, s, lleno.
13. `slant:EH:sib-stop` — 12 pairs (END 0, INNER 12). Words: s, mcgregor, tres, ready, mayweather, estoy, les, menos.
14. `slant:EH:stop` — 12 pairs (END 0, INNER 12). Words: estoy, desde, gente, est, vest, met, mente, eta.
15. `multi:AO-R-R-OW` — 11 pairs (END 1, INNER 10). Words: 'el forro, forro, cachorro, corro, y cotorro, cotorro, desde cachorro, hombre corro.
16. `vow:IH` — 10 pairs (END 2, INNER 8). Words: english, shit, cielo, different, dinero, diciendo, siempre, tienen.
17. `slant:EH:liq-stop` — 9 pairs (END 0, INNER 9). Words: el, cuello, mcgregor, ready, canelo, llega, crec, serie.
18. `slant:EH:liq-sib` — 8 pairs (END 0, INNER 8). Words: canelo, el, cuello, mayweather, tres, s, presi, les.
19. `slant:OW:sib-stop` — 8 pairs (END 0, INNER 8). Words: los, ndote, odia, loco, boca, rota, chota.
20. `vow:AY` — 8 pairs (END 0, INNER 8). Words: like, island, y, rifle, try, might.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- lleno — 21 pair sides, mostly vowel via spelling phonetic key, often with nuevo (2)
- creo — 20 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- cielo — 18 pair sides, mostly vowel via spelling phonetic key, often with nuevo (2)
- muero — 14 pair sides, mostly vowel via spelling phonetic key, often with hago (1)
- armao — 13 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- falso — 13 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- corillo — 13 pair sides, mostly vowel via spelling phonetic key, often with perico (1)
- corro — 12 pair sides, mostly vowel via spelling phonetic key, often with forro (2)
- perico — 12 pair sides, mostly vowel via spelling phonetic key, often with o (1)
- hijo — 12 pair sides, mostly vowel via spelling phonetic key, often with exploto (1)
- digo — 12 pair sides, mostly vowel via spelling phonetic key, often with siguen (1)
- voro — 12 pair sides, mostly vowel via spelling phonetic key, often with chota (1)
- cachorro — 11 pair sides, mostly vowel via spelling phonetic key, often with forro (2)
- tiroteo — 11 pair sides, mostly vowel via spelling phonetic key, often with nuevo (2)
- culo — 11 pair sides, mostly vowel via spelling phonetic key, often with un (3)
- exploto — 11 pair sides, mostly vowel via spelling phonetic key, often with o (1)
- kiosco — 11 pair sides, mostly vowel via spelling phonetic key, often with o (1)
- saludo — 11 pair sides, mostly vowel via spelling phonetic key, often with exploto (1)
- pendejo — 11 pair sides, mostly vowel via spelling phonetic key, often with corillo (1)
- forro — 11 pair sides, mostly multi via spelling phonetic key, often with cachorro (2)
- cotorro — 11 pair sides, mostly multi via spelling phonetic key, often with forro (2)
- hocico — 10 pair sides, mostly vowel via spelling phonetic key, often with esclavo (1)
- pedazo — 10 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- enterrao — 9 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- suelo — 9 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- tres — 9 pair sides, mostly spelling via spelling phonetic key, often with n (1)
- subiendo — 9 pair sides, mostly vowel via spelling phonetic key, often with bravo (1)
- directo — 9 pair sides, mostly vowel via spelling phonetic key, often with bravo (1)
- pongo — 9 pair sides, mostly vowel via spelling phonetic key, often with digo (1)
- hago — 9 pair sides, mostly vowel via spelling phonetic key, often with solo (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Anuel AA | Sufro | 67 | 52 | 779 | loose |
