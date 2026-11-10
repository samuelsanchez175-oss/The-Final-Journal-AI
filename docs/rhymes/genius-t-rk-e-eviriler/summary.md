# Genius Türkçe Çeviriler rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Genius Türkçe Çeviriler
- Songs: 2
- Bars kept (Genius Türkçe Çeviriler lyric lines): 75
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Genius Türkçe Çeviriler.
- Credit strings: Genius Türkçe Çeviriler.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 510
- REPEAT pairs, recorded separately: 68
- END rhymes: 23
- INNER rhymes: 487

By match:

- PERFECT: 161 (END 6, INNER 155)
- SLANT: 209 (END 7, INNER 202)
- ASSONANCE: 126 (END 4, INNER 122)
- MULTI: 14 (END 6, INNER 8)

By confidence:

- HIGH: 74
- MED: 219
- LOW: 217

## Core

- Core Y: 420
- Core N among rhyme pairs: 90

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 155 (30.4%)
- vowel: 126 (24.7%)
- spelling: 215 (42.2%)
- multi: 14 (2.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 54 pairs (END 2, INNER 52). Words: arabas, lacaks, adam, tamam, aptal, davran, rlatt, ndan.
2. `cmu:IY` — 49 pairs (END 0, INNER 49). Words: ve, z, g, b, t, ki, de, d.
3. `cmu:AA-R` — 47 pairs (END 3, INNER 44). Words: r, var, kar, par, lar, kankalar, nlar, alar.
4. `slant:EH:nas` — 34 pairs (END 1, INNER 33). Words: m, n, fena, beni, rmeme, demeyi, en, demeye.
5. `slant:EH:liq-nas` — 25 pairs (END 1, INNER 24). Words: l, m, n, kleri, eri, gel, ben, gen.
6. `vow:AA` — 24 pairs (END 0, INNER 24). Words: sa, r, la, rock, ra, lar, par, pop.
7. `vow:EH` — 21 pairs (END 1, INNER 20). Words: kleri, herifler, keserler, zenciler, geldim, eder, becerip, kendimi.
8. `cmu:EH-N` — 14 pairs (END 0, INNER 14). Words: n, ben, aslen, esinden, aynen, gen, tepesinden, en.
9. `slant:EH:nas-stop` — 13 pairs (END 0, INNER 13). Words: m, ben, dedi, n, dread, fek, tek, eder.
10. `slant:EH:nas-sib` — 12 pairs (END 0, INNER 12). Words: s, n, m, ben.
11. `spell:ar` — 12 pairs (END 2, INNER 10). Words: var, kar, yukar, soruyorlar, sorar, lar, postalar, rular.
12. `slant:AA:liq-stop` — 10 pairs (END 0, INNER 10). Words: art, r, rock, var, par, aka, kar, scott.
13. `slant:IY:liq-stop` — 10 pairs (END 3, INNER 7). Words: yor, yok, yat, st, yeter, yle, beate.
14. `vow:EY` — 8 pairs (END 0, INNER 8). Words: k, bay, ate, flame, kafay, ayr, ba, zaman.
15. `cmu:EY` — 7 pairs (END 0, INNER 7). Words: k, ba, trey, bay, ama.
16. `slant:AE:liq-stop` — 7 pairs (END 0, INNER 7). Words: yak, mal, al, hat, sal, tak, hap, lad.
17. `vow:IH` — 7 pairs (END 1, INNER 6). Words: gibi, istedi, birinin, indir, izin, tirdim, biliyorsun, hissediyorum.
18. `cmu:AE-N` — 6 pairs (END 0, INNER 6). Words: gruptan, ovumdan, masan, davran, mdan, karavan, arkadan, ndan.
19. `multi:IY-OW-R-AH-M` — 6 pairs (END 3, INNER 3). Words: yorum, hissediyorum, gidiyorum, gibi hissediyorum, henny yudumluyorum, yudumluyorum.
20. `slant:EH:fric-nas` — 6 pairs (END 0, INNER 6). Words: f, n, gen, m.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- var — 30 pair sides, mostly spelling via spelling phonetic key, often with r (7)
- yor — 16 pair sides, mostly spelling via spelling phonetic key, often with diyor (4)
- kar — 15 pair sides, mostly spelling via spelling phonetic key, often with var (3)
- kleri — 12 pair sides, mostly spelling via spelling phonetic key, often with n (3)
- arabas — 10 pair sides, mostly vowel via spelling phonetic key, often with akmak (1)
- gibi — 9 pair sides, mostly vowel via spelling phonetic key, often with birinin (2)
- diyor — 8 pair sides, mostly spelling via spelling phonetic key, often with yor (4)
- tamam — 7 pair sides, mostly vowel via spelling phonetic key, often with saklamal (1)
- fena — 7 pair sides, mostly spelling via spelling phonetic key, often with m (2)
- davran — 7 pair sides, mostly vowel via spelling phonetic key, often with rlatt (1)
- eri — 7 pair sides, mostly spelling via spelling phonetic key, often with n (3)
- mdan — 7 pair sides, mostly spelling via spelling phonetic key, often with gruptan (1)
- paralar — 7 pair sides, mostly spelling via spelling phonetic key, often with aram (1)
- ndan — 6 pair sides, mostly vowel via spelling phonetic key, often with kankalar (1)
- maviyi — 6 pair sides, mostly spelling via spelling phonetic key, often with yak (2)
- tane — 6 pair sides, mostly spelling via spelling phonetic key, often with hatun (1)
- sorar — 6 pair sides, mostly spelling via spelling phonetic key, often with soruyorlar (1)
- lacaks — 6 pair sides, mostly vowel via spelling phonetic key, often with akmak (1)
- kafay — 6 pair sides, mostly spelling via spelling phonetic key, often with k (1)
- aram — 6 pair sides, mostly vowel via spelling phonetic key, often with arabal (1)
- yorum — 5 pair sides, mostly multi via spelling phonetic key, often with gidiyorum (2)
- yukar — 5 pair sides, mostly spelling via spelling phonetic key, often with var (3)
- saklamal — 5 pair sides, mostly vowel via spelling phonetic key, often with tamam (1)
- dedi — 5 pair sides, mostly spelling via spelling phonetic key, often with m (2)
- fazladan — 5 pair sides, mostly vowel via spelling phonetic key, often with kalta (1)
- aslen — 5 pair sides, mostly spelling via spelling phonetic key, often with fazladan (1)
- rlam — 5 pair sides, mostly spelling via spelling phonetic key, often with tamam (1)
- hissediyorum — 5 pair sides, mostly multi via spelling phonetic key, often with yorum (2)
- rlatt — 5 pair sides, mostly vowel via spelling phonetic key, often with davran (1)
- soruyorlar — 5 pair sides, mostly spelling via spelling phonetic key, often with var (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Genius Türkçe Çeviriler | JACKBOYS, Pop Smoke & Travis Scott - GATTI (Türkçe Çeviri) | 42 | 7 | 204 | loose |
| Genius Türkçe Çeviriler | Post Malone - rockstar ft. 21 Savage (Türkçe Çeviri) | 33 | 16 | 283 | loose |
