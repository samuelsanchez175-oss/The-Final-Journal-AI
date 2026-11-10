# Babyface Ray rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Babyface Ray
- Songs: 2
- Bars kept (Babyface Ray lyric lines): 75
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Babyface Ray.
- Credit strings: Babyface Ray.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 699
- REPEAT pairs, recorded separately: 77
- END rhymes: 116
- INNER rhymes: 583

By match:

- PERFECT: 79 (END 29, INNER 50)
- SLANT: 301 (END 53, INNER 248)
- ASSONANCE: 309 (END 33, INNER 276)
- MULTI: 10 (END 1, INNER 9)

By confidence:

- HIGH: 77
- MED: 546
- LOW: 76

## Core

- Core Y: 690
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 300 (42.9%)
- vowel: 309 (44.2%)
- spelling: 80 (11.4%)
- multi: 10 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 56 pairs (END 3, INNER 53). Words: fifty, still, trippin, six, shit, risks, switching, pistol.
2. `vow:AE` — 51 pairs (END 6, INNER 45). Words: havin, back, hand, advance, massacres, passengers, attached, racks.
3. `slant:IH:stop` — 46 pairs (END 0, INNER 46). Words: nigga, stick, shit, lit, hit, city, script, hip.
4. `slant:AE:stop` — 40 pairs (END 13, INNER 27). Words: had, back, whacked, skat, hat, snapped, act, 'llac.
5. `vow:EH` — 38 pairs (END 3, INNER 35). Words: get, invested, heaven, wealth, bench, send, letters, went.
6. `vow:AH` — 31 pairs (END 6, INNER 25). Words: love, drugs, ones, come, somethin, touchin, guns, funds.
7. `vow:EY` — 31 pairs (END 1, INNER 30). Words: ain't, grateful, crazy, k, pray, pay, came, made.
8. `vow:AY` — 27 pairs (END 10, INNER 17). Words: times, like, ridin, grind, high, blind, mine, flyin.
9. `slant:AE:sib-stop` — 26 pairs (END 20, INNER 6). Words: racks, back, plaques, max, straps, 'llac, track, whacked.
10. `vow:AA` — 24 pairs (END 3, INNER 21). Words: got, wasn't, pop, closet, boss, charge, starve, want.
11. `cmu:AE-K` — 22 pairs (END 10, INNER 12). Words: back, mac, sack, track, 'llac, crack, 'raq.
12. `vow:OW` — 16 pairs (END 0, INNER 16). Words: don't, know, no, hope, opps, ghost, most, show.
13. `slant:AA:stop` — 14 pairs (END 0, INNER 14). Words: got, stock, spot, top, want, pop, glock, locked.
14. `slant:IH:sib-stop` — 14 pairs (END 4, INNER 10). Words: niggas, nigga, rich, bitch, kit, shit, doin, quit.
15. `slant:EH:nas-stop` — 13 pairs (END 0, INNER 13). Words: ten, 'nem, get, went, again, when, met, yet.
16. `slant:AY:nas-stop` — 12 pairs (END 1, INNER 11). Words: tryin, like, defyin, nine, might, outside, cried, overnight.
17. `vow:AO` — 12 pairs (END 1, INNER 11). Words: law, flaw, endorse, course, mall, four, forward, lost.
18. `cmu:AE-P` — 11 pairs (END 11, INNER 0). Words: bap, clap, rap, cap, trap, map.
19. `slant:AY:fric-stop` — 11 pairs (END 0, INNER 11). Words: overnight, life, live, five, cried.
20. `slant:IH:liq-stop` — 11 pairs (END 0, INNER 11). Words: lil, still, clear, shit, stick, quit, doin, hit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 23 pair sides, mostly spelling via spelling phonetic key, often with niggas (5)
- llac — 11 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- doin — 10 pair sides, mostly cmu via vault phonetic_class, often with kit (1)
- ima — 10 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- bap — 9 pair sides, mostly spelling via spelling phonetic key, often with trap (1)
- skat — 8 pair sides, mostly spelling via spelling phonetic key, often with back (3)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- cuz — 4 pair sides, mostly spelling via spelling phonetic key, often with love (1)
- shiesty — 4 pair sides, mostly vowel via spelling phonetic key, often with really (2)
- nem — 3 pair sides, mostly spelling via spelling phonetic key, often with yet (1)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with yellin (1)
- raq — 2 pair sides, mostly spelling via spelling phonetic key, often with whacked (1)
- urus — 2 pair sides, mostly vowel via spelling phonetic key, often with club (1)
- durk — 2 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- fam — 1 pair sides, mostly spelling via spelling phonetic key, often with back (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Babyface Ray | 2 For 6 | 37 | 72 | 289 | loose |
| Babyface Ray | Blood Sweat & Tears | 38 | 44 | 294 | loose |
