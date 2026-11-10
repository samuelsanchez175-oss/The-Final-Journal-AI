# Lil Tecca rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Tecca
- Songs: 2
- Bars kept (Lil Tecca lyric lines): 108
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Lil Tecca.
- Credit strings: Lil Tecca.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 495
- REPEAT pairs, recorded separately: 169
- END rhymes: 115
- INNER rhymes: 380

By match:

- PERFECT: 37 (END 5, INNER 32)
- SLANT: 240 (END 54, INNER 186)
- ASSONANCE: 210 (END 53, INNER 157)
- MULTI: 8 (END 3, INNER 5)

By confidence:

- HIGH: 40
- MED: 408
- LOW: 47

## Core

- Core Y: 481
- Core N among rhyme pairs: 14

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 242 (48.9%)
- vowel: 210 (42.4%)
- spelling: 35 (7.1%)
- multi: 8 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 55 pairs (END 5, INNER 50). Words: steppin, there's, send, where, get, seconds, tellin, heaven.
2. `vow:AE` — 33 pairs (END 18, INNER 15). Words: flashin, bags, catch, absent, stashed, can't, happen, captain.
3. `vow:EY` — 28 pairs (END 10, INNER 18). Words: say, play, way, make, rain, take, ain't, wait.
4. `vow:OW` — 27 pairs (END 5, INNER 22). Words: don't, no, know, go, venmo, told, ammo, hold.
5. `slant:AY:stop` — 22 pairs (END 0, INNER 22). Words: type, like, inside, wide, vibe, slide, ride, sprite.
6. `slant:EH:nas-stop` — 19 pairs (END 0, INNER 19). Words: again, when, friend, said, send, spent, step, get.
7. `vow:IH` — 17 pairs (END 3, INNER 14). Words: thinkin, bitches, sixty, business, him, zero, years, still.
8. `vow:AY` — 15 pairs (END 1, INNER 14). Words: diamonds, time, mind, type, tights, inside, why, high.
9. `slant:EH:sib-stop` — 14 pairs (END 1, INNER 13). Words: get, let's, stretch, send, sense, better, step, feds.
10. `slant:EH:liq-nas` — 12 pairs (END 9, INNER 3). Words: again, well, hell, when, where, air.
11. `slant:EH:stop` — 12 pairs (END 0, INNER 12). Words: get, said, better, step, spent, meant, friend.
12. `vow:AW` — 12 pairs (END 9, INNER 3). Words: now, down, loudest, house, around, towel, sliming, drought.
13. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: nigga, hit, dick, picker, quicker, drink, wrist.
14. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: pocket, got, want, not, pop, bought, rock.
15. `vow:AA` — 8 pairs (END 0, INNER 8). Words: got, talkin, backyard, not, opposites, respond, rock.
16. `cmu:AA-T` — 7 pairs (END 0, INNER 7). Words: not, got, lot.
17. `cmu:EY` — 7 pairs (END 1, INNER 6). Words: way, play, say, lay.
18. `cmu:OW` — 7 pairs (END 0, INNER 7). Words: go, no, know, show, ho.
19. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: young, cut, fuck, drum, pump, bunny, one.
20. `slant:EY:nas-stop` — 7 pairs (END 2, INNER 5). Words: baby, macadamia, romania, sayin, rain, take, made, neighbor.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- venmo — 6 pair sides, mostly vowel via spelling phonetic key, often with lambo (1)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- camo — 5 pair sides, mostly spelling via spelling phonetic key, often with lambo (1)
- famo — 5 pair sides, mostly spelling via spelling phonetic key, often with lambo (1)
- glizzy — 5 pair sides, mostly spelling via spelling phonetic key, often with cookie (1)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with only (1)
- lambo — 4 pair sides, mostly vowel via spelling phonetic key, often with ammo (1)
- sliming — 3 pair sides, mostly cmu via vault phonetic_class, often with loudest (1)
- shawty — 3 pair sides, mostly vowel via spelling phonetic key, often with every (1)
- trackhawks — 2 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- dappin — 2 pair sides, mostly vowel via spelling phonetic key, often with flashin (1)
- foenem — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- pluckered — 2 pair sides, mostly spelling via spelling phonetic key, often with head (1)
- 3am — 1 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- dumbed — 1 pair sides, mostly vowel via spelling phonetic key, often with love (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Tecca | CHOPPA SHOOT THE LOUDEST | 52 | 52 | 183 | loose |
| Lil Tecca | HVN ON EARTH | 56 | 63 | 197 | loose |
