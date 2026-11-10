# Pooh Shiesty rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Pooh Shiesty
- Songs: 3
- Bars kept (Pooh Shiesty lyric lines): 96
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Pooh Shiesty.
- Credit strings: Pooh Shiesty.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 980
- REPEAT pairs, recorded separately: 41
- END rhymes: 141
- INNER rhymes: 839

By match:

- PERFECT: 80 (END 15, INNER 65)
- SLANT: 397 (END 39, INNER 358)
- ASSONANCE: 496 (END 84, INNER 412)
- MULTI: 7 (END 3, INNER 4)

By confidence:

- HIGH: 71
- MED: 835
- LOW: 74

## Core

- Core Y: 946
- Core N among rhyme pairs: 34

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 426 (43.5%)
- vowel: 496 (50.6%)
- spelling: 51 (5.2%)
- multi: 7 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 208 pairs (END 64, INNER 144). Words: got, garbage, robberies, firearms, rodman's, sparkin, narcotics, regardless.
2. `vow:EY` — 57 pairs (END 8, INNER 49). Words: way, k, ain't, stay, operation, chain, angels, face.
3. `vow:IY` — 56 pairs (END 1, INNER 55). Words: shiesty, keep, probably, blicky, here, squealin, b, c.
4. `slant:AA:stop` — 54 pairs (END 6, INNER 48). Words: got, everybody, glock, block, locked, top, popped, shot.
5. `vow:IH` — 45 pairs (END 8, INNER 37). Words: since, different, shit, thinking, richard, kitchen, livin, business.
6. `vow:EH` — 44 pairs (END 0, INNER 44). Words: never, dennis, gettin, get, left, feds, head, scared.
7. `slant:IH:stop` — 34 pairs (END 4, INNER 30). Words: shit, shiesty, big, blicky, nigga, sit, switched, flip.
8. `vow:OW` — 26 pairs (END 0, INNER 26). Words: know, posted, don't, go, coat, though, closin, road.
9. `vow:AY` — 22 pairs (END 2, INNER 20). Words: buy, mind, fire, try, slimy, live, might, slime.
10. `slant:AA:nas-stop` — 21 pairs (END 2, INNER 19). Words: wanna, got, palm, rob, glock, shot, not, gonna.
11. `cmu:AO-R` — 18 pairs (END 1, INNER 17). Words: score, pour, sore, four, door, core, war, thor.
12. `slant:IH:liq-stop` — 18 pairs (END 3, INNER 15). Words: still, shit, big, quick, blicky, hit, kill, mille.
13. `slant:EH:fric-stop` — 17 pairs (END 0, INNER 17). Words: never, get, head, every, said, forever, check, bet.
14. `slant:EH:stop` — 17 pairs (END 5, INNER 12). Words: get, said, head, went, cared, check, left, scared.
15. `slant:AA:sib-stop` — 16 pairs (END 5, INNER 11). Words: notch, got, pot, knots, block, box, watch, shots.
16. `slant:IH:sib-stop` — 12 pairs (END 1, INNER 11). Words: shit, switch, bitch, rich, niggas, nigga, clip, flip.
17. `vow:AE` — 12 pairs (END 1, INNER 11). Words: bags, man, vacuum, grand, hammer, bands, banging, racks.
18. `vow:AH` — 10 pairs (END 0, INNER 10). Words: hundred, done, couple, months, double, cup, fucked, brother.
19. `cmu:AA-T` — 9 pairs (END 0, INNER 9). Words: got, not, shot, bought.
20. `cmu:EY-K` — 9 pairs (END 1, INNER 8). Words: cake, bake, snake, steak, take.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- blicky — 21 pair sides, mostly vowel via spelling phonetic key, often with sticky (3)
- shiesty — 21 pair sides, mostly vowel via spelling phonetic key, often with shit (4)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- drac — 5 pair sides, mostly spelling via spelling phonetic key, often with mismatch (1)
- wocky — 4 pair sides, mostly vowel via spelling phonetic key, often with degree (1)
- noggin — 4 pair sides, mostly spelling via spelling phonetic key, often with even (2)
- youngin — 4 pair sides, mostly spelling via spelling phonetic key, often with noggin (1)
- leventh — 3 pair sides, mostly vowel via spelling phonetic key, often with tell (1)
- kel — 3 pair sides, mostly spelling via spelling phonetic key, often with said (1)
- flodgin — 3 pair sides, mostly spelling via spelling phonetic key, often with noggin (1)
- gunplay — 2 pair sides, mostly spelling via spelling phonetic key, often with ebay (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- truey — 2 pair sides, mostly vowel via spelling phonetic key, often with way (1)
- flossin — 2 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- swanging — 2 pair sides, mostly multi via spelling phonetic key, often with banging (2)
- jdfeng — 2 pair sides, mostly vowel via spelling phonetic key, often with left (1)
- burberry — 1 pair sides, mostly vowel via spelling phonetic key, often with pussy (1)
- shawty — 1 pair sides, mostly vowel via spelling phonetic key, often with slightly (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with road (1)
- triller — 1 pair sides, mostly vowel via spelling phonetic key, often with switched (1)
- yappin — 1 pair sides, mostly spelling via spelling phonetic key, often with flodgin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Pooh Shiesty | Box of Churches | 42 | 48 | 270 | loose |
| Pooh Shiesty | Switch it Up | 40 | 80 | 456 | loose |
| Pooh Shiesty | Switch it Up (Original) | 14 | 13 | 113 | loose |
