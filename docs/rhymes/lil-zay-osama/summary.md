# Lil Zay Osama rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Zay Osama
- Songs: 3
- Bars kept (Lil Zay Osama lyric lines): 114
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Zay Osama.
- Credit strings: Lil Zay Osama.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 930
- REPEAT pairs, recorded separately: 96
- END rhymes: 130
- INNER rhymes: 800

By match:

- PERFECT: 92 (END 16, INNER 76)
- SLANT: 393 (END 54, INNER 339)
- ASSONANCE: 432 (END 58, INNER 374)
- MULTI: 13 (END 2, INNER 11)

By confidence:

- HIGH: 100
- MED: 782
- LOW: 48

## Core

- Core Y: 915
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 447 (48.1%)
- vowel: 432 (46.5%)
- spelling: 38 (4.1%)
- multi: 13 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 112 pairs (END 18, INNER 94). Words: bitches, lil, killed, still, blitz, risks, blick, sickest.
2. `vow:EY` — 90 pairs (END 24, INNER 66). Words: ain't, day, saved, pray, say, made, grades, anyway.
3. `vow:OW` — 76 pairs (END 0, INNER 76). Words: know, smoke, don't, told, go, no, opps, won't.
4. `vow:AE` — 36 pairs (END 4, INNER 32). Words: ass, stand, cameras, back, can't, catch, facts, mans.
5. `slant:IH:stop` — 34 pairs (END 4, INNER 30). Words: hit, nigga, big, blick, slid, stick, pig, pick.
6. `vow:AY` — 29 pairs (END 7, INNER 22). Words: like, why, lightning, die, writing, strikers, line, baptized.
7. `vow:EH` — 28 pairs (END 1, INNER 27). Words: left, sparin, get, many, kept, never, friends, dead.
8. `slant:IH:sib-stop` — 25 pairs (END 5, INNER 20). Words: bitch, switch, blick, shit, niggas, nigga, rich, lit.
9. `slant:AY:nas-stop` — 22 pairs (END 5, INNER 17). Words: like, mine, anytime, died, slide, fine, iron, line.
10. `vow:AA` — 22 pairs (END 1, INNER 21). Words: mama, got, want, product, bodies, nothin, bodyguard, poppin.
11. `slant:IH:nas-stop` — 18 pairs (END 0, INNER 18). Words: him, spin, hit, dig, pick, blick, big, i'ma.
12. `slant:AA:stop` — 17 pairs (END 0, INNER 17). Words: got, gotta, dropped, shot, block, glock, opp, want.
13. `cmu:AH-M` — 16 pairs (END 7, INNER 9). Words: 'em, mhm, come, some, drum.
14. `slant:AY:stop` — 16 pairs (END 2, INNER 14). Words: like, ride, right, slide, indicted, lied, behind, fight.
15. `slant:EY:stop` — 16 pairs (END 4, INNER 12). Words: made, saved, make, amazed, wait, hate, ain't, hesitate.
16. `slant:AY:sib-stop` — 15 pairs (END 5, INNER 10). Words: size, like, strikers, outside, guys, ride, strike, baptized.
17. `slant:AA:nas-stop` — 14 pairs (END 0, INNER 14). Words: mama, got, body, shot, lot, obama, block, not.
18. `slant:IH:liq-sib` — 14 pairs (END 0, INNER 14). Words: bitch, lil, switch, drill, still, nickel, six, rich.
19. `slant:IH:sib` — 13 pairs (END 4, INNER 9). Words: niggas, pictures, sticthes, bitches, blitz, viscous, missions, finish.
20. `slant:EH:nas-stop` — 12 pairs (END 3, INNER 9). Words: again, pretend, get, gen, pen, n, any, head.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- niggas — 11 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- sticthes — 7 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- opps — 6 pair sides, mostly vowel via spelling phonetic key, often with know (4)
- glocks — 6 pair sides, mostly spelling via spelling phonetic key, often with throw (1)
- homie — 4 pair sides, mostly spelling via spelling phonetic key, often with homies (2)
- killas — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- glah — 3 pair sides, mostly spelling via spelling phonetic key, often with gang (2)
- rson — 3 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- homies — 2 pair sides, mostly spelling via spelling phonetic key, often with homie (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- foenem — 1 pair sides, mostly spelling via spelling phonetic key, often with em (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- lyin — 1 pair sides, mostly multi via spelling phonetic key, often with dyin (1)
- dyin — 1 pair sides, mostly multi via spelling phonetic key, often with lyin (1)
- tup — 1 pair sides, mostly spelling via spelling phonetic key, often with come (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Zay Osama | Chase Em Down | 51 | 62 | 266 | loose |
| Lil Zay Osama | We’ll Be Straight | 26 | 46 | 257 | loose |
| Lil Zay Osama | Why They Be Lyin | 37 | 22 | 277 | loose |
