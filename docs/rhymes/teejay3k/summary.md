# TeeJay3k rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: TeeJay3k
- Songs: 2
- Bars kept (TeeJay3k lyric lines): 94
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: TeeJay3k.
- Credit strings: TeeJay3k.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 773
- REPEAT pairs, recorded separately: 103
- END rhymes: 122
- INNER rhymes: 651

By match:

- PERFECT: 38 (END 10, INNER 28)
- SLANT: 361 (END 50, INNER 311)
- ASSONANCE: 362 (END 54, INNER 308)
- MULTI: 12 (END 8, INNER 4)

By confidence:

- HIGH: 45
- MED: 654
- LOW: 74

## Core

- Core Y: 765
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 328 (42.4%)
- vowel: 362 (46.8%)
- spelling: 71 (9.2%)
- multi: 12 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 111 pairs (END 5, INNER 106). Words: flippin, shit, bitch, still, think, different, six, link.
2. `vow:EY` — 64 pairs (END 9, INNER 55). Words: ain't, say, paper, haters, day, always, birthday, pay.
3. `slant:IH:stop` — 48 pairs (END 5, INNER 43). Words: nigga, shit, city, link, strip, trigger, blick, hit.
4. `vow:AH` — 48 pairs (END 12, INNER 36). Words: money, love, hungry, hustlin, stomach, comin, sluggish, struggle.
5. `slant:IH:liq-stop` — 42 pairs (END 0, INNER 42). Words: still, shit, really, hit, pillow, spit, 'til, strip.
6. `slant:IH:sib-stop` — 37 pairs (END 3, INNER 34). Words: bitch, blick, stick, rich, shit, click, busy, nigga.
7. `vow:ER` — 37 pairs (END 19, INNER 18). Words: learnin, nervous, worth, urgent, detergent, workin, person, nerds.
8. `vow:OW` — 25 pairs (END 1, INNER 24). Words: don't, no, told, know, ho, only, dope, won't.
9. `vow:EH` — 24 pairs (END 7, INNER 17). Words: sendin, hennessy, enemy, legs, neck, adrenaline, gettin, threat.
10. `slant:EY:stop` — 22 pairs (END 5, INNER 17). Words: paper, take, eight, ain't, alligator, faygo, fake, plate.
11. `vow:AA` — 20 pairs (END 0, INNER 20). Words: nothin, got, want, vomit, top, mama, starvin, argue.
12. `slant:AH:nas` — 19 pairs (END 13, INNER 6). Words: money, lustin, discussion, running, cussin, hustlin, bussin, disgustin.
13. `vow:AE` — 16 pairs (END 1, INNER 15). Words: man, can't, bands, ask, rather, ralph, nigga, had.
14. `slant:EY:sib-stop` — 11 pairs (END 5, INNER 6). Words: alligator, chase, face, haters, laced, paper, plate, cake.
15. `slant:IH:liq-sib` — 11 pairs (END 0, INNER 11). Words: bitch, pillow, 'til, busy, lil, near, rich, still.
16. `cmu:IH-T` — 9 pairs (END 0, INNER 9). Words: shit, hit, fit, spit.
17. `slant:AE:nas-stop` — 9 pairs (END 0, INNER 9). Words: man, kodak, mad, can, damn, had.
18. `slant:AH:nas-stop` — 9 pairs (END 1, INNER 8). Words: money, trust, fuckin, mud, grub, jitterbug, fuck, tuck.
19. `slant:IH:sib` — 9 pairs (END 0, INNER 9). Words: bitch, busy, bitches, pissy, niggas, six.
20. `slant:AA:nas-stop` — 8 pairs (END 0, INNER 8). Words: wanna, want, got, top, not.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 32 pair sides, mostly spelling via spelling phonetic key, often with shit (7)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with even (2)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- swervin — 6 pair sides, mostly spelling via spelling phonetic key, often with nothin (1)
- shoota — 4 pair sides, mostly spelling via spelling phonetic key, often with coupe (1)
- faygo — 4 pair sides, mostly spelling via spelling phonetic key, often with take (1)
- lyin — 4 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- teejay — 3 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- pissy — 3 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- yerky — 2 pair sides, mostly vowel via spelling phonetic key, often with pissy (1)
- thuggin — 2 pair sides, mostly spelling via spelling phonetic key, often with flippin (1)
- birkin — 2 pair sides, mostly vowel via spelling phonetic key, often with listenin (1)
- hunnids — 1 pair sides, mostly vowel via spelling phonetic key, often with comin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| TeeJay3k | Paper Soldiers | 48 | 36 | 164 | loose |
| TeeJay3k | Pissy Hallways | 46 | 86 | 487 | loose |
