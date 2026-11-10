# Bobby Raps rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bobby Raps
- Songs: 1
- Bars kept (Bobby Raps lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bobby Raps.
- Credit strings: Bobby Raps.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 242
- REPEAT pairs, recorded separately: 23
- END rhymes: 38
- INNER rhymes: 204

By match:

- PERFECT: 20 (END 7, INNER 13)
- SLANT: 108 (END 12, INNER 96)
- ASSONANCE: 114 (END 19, INNER 95)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 20
- MED: 211
- LOW: 11

## Core

- Core Y: 239
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 120 (49.6%)
- vowel: 114 (47.1%)
- spelling: 8 (3.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 23 pairs (END 7, INNER 16). Words: stop, arch, want, momma, croissants, heart, nothin, mom.
2. `vow:OW` — 21 pairs (END 0, INNER 21). Words: don't, no, snowin, blow, hold, smoking, dopey, know.
3. `vow:AE` — 20 pairs (END 5, INNER 15). Words: gas, pants, bands, fanned, cash, faster, hands, camp.
4. `vow:EH` — 20 pairs (END 3, INNER 17). Words: get, step, lesson, nemesis, lettuce, fed, jetsons, l.
5. `vow:AY` — 11 pairs (END 2, INNER 9). Words: fire, like, sides, rise, grind, likewise, time, vibe.
6. `slant:AA:sib-stop` — 10 pairs (END 2, INNER 8). Words: watch, croissants, gotta, want, chop, wash, got, grandpa's.
7. `vow:EY` — 8 pairs (END 0, INNER 8). Words: ain't, day, gave, brains, space, came, gravy, take.
8. `slant:AA:nas-stop` — 7 pairs (END 4, INNER 3). Words: megatron, stop, want, wanna, gotta, savant, momma, mom.
9. `vow:IH` — 7 pairs (END 2, INNER 5). Words: shit's, rinse, persevere, fishin, switch, chandelier, commandeer, still.
10. `cmu:IH-R` — 6 pairs (END 1, INNER 5). Words: fear, chandelier, persevere, commandeer.
11. `slant:AA:stop` — 6 pairs (END 0, INNER 6). Words: not, drop, top, heart.
12. `slant:AY:stop` — 6 pairs (END 1, INNER 5). Words: like, right, vibe, striped, tried.
13. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: lit, clip, lil, chandelier, fear, commandeer, persevere, still.
14. `slant:IH:liq` — 4 pairs (END 0, INNER 4). Words: still, chandelier, fear, commandeer, persevere.
15. `slant:IY:liq-stop` — 4 pairs (END 0, INNER 4). Words: keep, steel, veal, need.
16. `slant:AE:sib` — 3 pairs (END 3, INNER 0). Words: pants, bands, cash, catch.
17. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: nigga, clip, hit, spaceship.
18. `slant:OW:liq-stop` — 3 pairs (END 0, INNER 3). Words: whole, hold, dope, old.
19. `cmu:AA-N-T` — 2 pairs (END 1, INNER 1). Words: want, savant.
20. `cmu:ER-N` — 2 pairs (END 0, INNER 2). Words: learn, turn.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with clip (2)
- tooka — 2 pair sides, mostly spelling via spelling phonetic key, often with hookah (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dopey (1)
- cashapp — 1 pair sides, mostly vowel via spelling phonetic key, often with cash (1)
- hookah — 1 pair sides, mostly spelling via spelling phonetic key, often with tooka (1)
- olantern — 1 pair sides, mostly vowel via spelling phonetic key, often with whole (1)
- mids — 1 pair sides, mostly vowel via spelling phonetic key, often with spaceship (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bobby Raps | Wash My Hands | 47 | 38 | 204 | loose |
