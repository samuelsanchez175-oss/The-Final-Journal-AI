# FaZe Kaysan rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: FaZe Kaysan
- Songs: 1
- Bars kept (FaZe Kaysan lyric lines): 67
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: FaZe Kaysan.
- Credit strings: FaZe Kaysan.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 565
- REPEAT pairs, recorded separately: 92
- END rhymes: 68
- INNER rhymes: 497

By match:

- PERFECT: 56 (END 9, INNER 47)
- SLANT: 242 (END 28, INNER 214)
- ASSONANCE: 266 (END 31, INNER 235)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 56
- MED: 471
- LOW: 38

## Core

- Core Y: 558
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 265 (46.9%)
- vowel: 266 (47.1%)
- spelling: 33 (5.8%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 75 pairs (END 1, INNER 74). Words: bitch, lil, finish, pistols, killers, millions, blitz, think.
2. `vow:EY` — 66 pairs (END 9, INNER 57). Words: ain't, take, play, range, way, brakes, make, say.
3. `vow:AE` — 25 pairs (END 7, INNER 18). Words: can't, action, blastin, passed, racks, gangster, laughin, act.
4. `vow:IY` — 25 pairs (END 3, INNER 22). Words: t, here, g, thirty, people, even, real, eat.
5. `vow:OW` — 21 pairs (END 0, INNER 21). Words: don't, no, bro, both, scope, boat, glocks, known.
6. `slant:EY:sib-stop` — 19 pairs (END 7, INNER 12). Words: take, chase, face, state, straight, brakes, trace, race.
7. `vow:UW` — 16 pairs (END 11, INNER 5). Words: two, through, shootin, juice, houston, booth, roof, shoot.
8. `vow:EH` — 15 pairs (END 0, INNER 15). Words: plenty, relentless, dependin, never, swear, direct, fence, depend.
9. `slant:IH:sib` — 14 pairs (END 1, INNER 13). Words: clips, niggas, since, pitts, drizzy, years, blitz, six.
10. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: no, show, o, throw, go, bro, ho, ago.
11. `slant:AA:stop` — 13 pairs (END 0, INNER 13). Words: got, shot, stop, block, knock, knob, pop, glock.
12. `slant:IH:sib-stop` — 13 pairs (END 2, INNER 11). Words: bitch, nigga, niggas, shit, dick, sip, switch, split.
13. `slant:IH:nas-stop` — 12 pairs (END 0, INNER 12). Words: thing, shit, spin, i'ma, big, lit, sip, dick.
14. `slant:IH:stop` — 11 pairs (END 0, INNER 11). Words: nigga, whipped, shit, big, lit, sip, wicked, list.
15. `vow:AY` — 11 pairs (END 0, INNER 11). Words: diamonds, find, license, like, slidin, sniper, drive, while.
16. `slant:IH:liq-sib` — 9 pairs (END 0, INNER 9). Words: lil, bitch, killers, switch, gear.
17. `slant:IH:nas-sib` — 9 pairs (END 0, INNER 9). Words: bitch, thing, him, spin, switch, spinnin, finish, i'ma.
18. `cmu:AA-T` — 8 pairs (END 0, INNER 8). Words: shot, got, headshot.
19. `slant:AY:stop` — 8 pairs (END 0, INNER 8). Words: like, tired, inside, died, tried.
20. `slant:EY:stop` — 8 pairs (END 3, INNER 5). Words: hate, take, ain't, shake, gate, baby, straight, make.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 12 pair sides, mostly spelling via spelling phonetic key, often with clips (6)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- bruh — 4 pair sides, mostly spelling via spelling phonetic key, often with come (1)
- drizzy — 3 pair sides, mostly vowel via spelling phonetic key, often with thirty (1)
- drac — 3 pair sides, mostly spelling via spelling phonetic key, often with carry (1)
- twerk — 2 pair sides, mostly spelling via spelling phonetic key, often with alert (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- glocks — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- trackhawk — 1 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- gangbang — 1 pair sides, mostly vowel via spelling phonetic key, often with pass (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| FaZe Kaysan | Plenty | 67 | 68 | 497 | loose |
