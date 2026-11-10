# Trench Baby rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Trench Baby
- Songs: 1
- Bars kept (Trench Baby lyric lines): 62
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Trench Baby.
- Credit strings: Trench Baby.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 345
- REPEAT pairs, recorded separately: 20
- END rhymes: 47
- INNER rhymes: 298

By match:

- PERFECT: 41 (END 18, INNER 23)
- SLANT: 120 (END 11, INNER 109)
- ASSONANCE: 180 (END 16, INNER 164)
- MULTI: 4 (END 2, INNER 2)

By confidence:

- HIGH: 44
- MED: 280
- LOW: 21

## Core

- Core Y: 342
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 141 (40.9%)
- vowel: 180 (52.2%)
- spelling: 20 (5.8%)
- multi: 4 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 42 pairs (END 8, INNER 34). Words: stamped, mask, after, catch, bands, cap, wrappin, mad.
2. `vow:AH` — 38 pairs (END 1, INNER 37). Words: gun, drummond, dumpin, bustin, drums, duckin, fuck, runnin.
3. `vow:EY` — 19 pairs (END 0, INNER 19). Words: ain't, play, andre, laser, sprayin, race, wake, neighbors.
4. `vow:IH` — 18 pairs (END 4, INNER 14). Words: bitch, him, richest, blitz, nicks, picture, million, think.
5. `vow:IY` — 17 pairs (END 3, INNER 14). Words: probably, even, see, dreams, deal, wheel, sneak, these.
6. `vow:EH` — 13 pairs (END 0, INNER 13). Words: ever, end, trenches, backends, let, every, gettin, smell.
7. `cmu:UW` — 12 pairs (END 7, INNER 5). Words: two, who, mildew, crew, new, through.
8. `vow:AY` — 10 pairs (END 0, INNER 10). Words: like, pipes, sizin, height, lie, ride, why.
9. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: got, glock, hop, want, hot, stop, start, caught.
10. `slant:AE:nas-stop` — 8 pairs (END 0, INNER 8). Words: wrappin, clap, ran, lap, plannin, band, cap, rappin.
11. `slant:AH:nas` — 8 pairs (END 3, INNER 5). Words: runnin, thumbin, gun, huntin, duckin, dumpin, one, somethin.
12. `slant:AY:stop` — 8 pairs (END 0, INNER 8). Words: like, might, died, tried, side, height, ride.
13. `slant:IH:nas-stop` — 8 pairs (END 2, INNER 6). Words: shit, him, i'ma, hit, stick.
14. `cmu:AY-D` — 6 pairs (END 3, INNER 3). Words: tried, died, side, ride, slide.
15. `vow:AA` — 6 pairs (END 0, INNER 6). Words: compound, glock, got, start, hop, bodies.
16. `vow:AO` — 6 pairs (END 0, INNER 6). Words: scorin, bosses, coffin, perform, walk.
17. `slant:AE:nas` — 5 pairs (END 1, INNER 4). Words: lackin, addin, rappin, cappin, wrappin.
18. `slant:AY:fric-stop` — 5 pairs (END 0, INNER 5). Words: five, might, like, died, tried.
19. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: lil, still, hit, fit, shit, stick, clip.
20. `vow:OW` — 5 pairs (END 0, INNER 5). Words: don't, know, no, boulders, sober, blow.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- backbends — 3 pair sides, mostly vowel via spelling phonetic key, often with after (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with blickas (1)
- blickas — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- dracos — 1 pair sides, mostly spelling via spelling phonetic key, often with macs (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- calis — 1 pair sides, mostly vowel via spelling phonetic key, often with traffic (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with pick (1)
- ebk — 1 pair sides, mostly spelling via spelling phonetic key, often with let (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Trench Baby | Invite Only | 62 | 47 | 298 | loose |
