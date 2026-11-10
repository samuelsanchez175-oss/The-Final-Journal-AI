# Big Opp rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Big Opp
- Songs: 3
- Bars kept (Big Opp lyric lines): 146
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Big Opp.
- Credit strings: Big Opp.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1499
- REPEAT pairs, recorded separately: 198
- END rhymes: 236
- INNER rhymes: 1263

By match:

- PERFECT: 200 (END 73, INNER 127)
- SLANT: 657 (END 94, INNER 563)
- ASSONANCE: 637 (END 68, INNER 569)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 193
- MED: 1227
- LOW: 79

## Core

- Core Y: 1487
- Core N among rhyme pairs: 12

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 776 (51.8%)
- vowel: 637 (42.5%)
- spelling: 81 (5.4%)
- multi: 5 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 152 pairs (END 31, INNER 121). Words: shit, switches, blitz, hit, sticks, givin, him, lyrics.
2. `vow:EY` — 99 pairs (END 1, INNER 98). Words: ain't, say, day, same, way, name, aim, favorite.
3. `vow:EH` — 96 pairs (END 8, INNER 88). Words: when, gettin, drench, get, heads, already, head, neck.
4. `vow:AE` — 88 pairs (END 9, INNER 79). Words: back, hats, adapted, alaskan, ass, acts, fashion, mans.
5. `slant:IH:sib-stop` — 63 pairs (END 30, INNER 33). Words: hit, shit, switch, bitch, diss, blitz, hits, quick.
6. `slant:IH:stop` — 63 pairs (END 17, INNER 46). Words: shit, hit, quick, nigga, big, trip, lit, pick.
7. `vow:IY` — 54 pairs (END 17, INNER 37). Words: backseat, three, see, keep, weeks, b, tv, streets.
8. `vow:OW` — 46 pairs (END 0, INNER 46). Words: don't, know, go, no, throw, smoke, opps, smoked.
9. `vow:AH` — 43 pairs (END 0, INNER 43). Words: hundred, jump, jumped, fuck, duckin, one, what's, front.
10. `vow:AY` — 39 pairs (END 2, INNER 37). Words: like, ridin, fly, high, lie, time, by, died.
11. `slant:AE:sib-stop` — 35 pairs (END 3, INNER 32). Words: ass, back, 'raq, math, racks, saks, lax, hats.
12. `slant:AE:stop` — 31 pairs (END 11, INNER 20). Words: back, rat, scat, tap, strap, chat, raq, slap.
13. `slant:IH:nas-stop` — 28 pairs (END 2, INNER 26). Words: him, hit, shit, trip, askin, pick, big, i'ma.
14. `slant:IH:liq-stop` — 27 pairs (END 0, INNER 27). Words: lil, shit, really, hit, kill, quick, big, crib.
15. `cmu:IH-T` — 25 pairs (END 8, INNER 17). Words: hit, shit, lit, 'fit, commit, kit, pitt.
16. `slant:EH:stop` — 25 pairs (END 5, INNER 20). Words: get, vest, chest, stretched, vec, already, send, head.
17. `slant:AA:stop` — 22 pairs (END 0, INNER 22). Words: got, want, gotta, glock, hop, not, pop, starter.
18. `slant:IH:liq-sib` — 21 pairs (END 0, INNER 21). Words: lil, bitch, switch, still, itch, kill, mitch, rich.
19. `cmu:EH-L` — 19 pairs (END 9, INNER 10). Words: hell, duracell, zelle, sell, tell, l.
20. `cmu:IH-CH` — 18 pairs (END 11, INNER 7). Words: bitch, switch, itch, rich, mitch, ditch, glitch.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 17 pair sides, mostly spelling via spelling phonetic key, often with trip (4)
- raq — 16 pair sides, mostly spelling via spelling phonetic key, often with back (3)
- hella — 6 pair sides, mostly spelling via spelling phonetic key, often with hell (2)
- dyin — 6 pair sides, mostly cmu via vault phonetic_class, often with keep (2)
- vec — 5 pair sides, mostly spelling via spelling phonetic key, often with smell (1)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with foenem (2)
- gangway — 5 pair sides, mostly spelling via spelling phonetic key, often with day (2)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- gravediggers — 4 pair sides, mostly spelling via spelling phonetic key, often with figures (2)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with rico (1)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with throw (2)
- jumpout — 3 pair sides, mostly spelling via spelling phonetic key, often with about (1)
- foenem — 3 pair sides, mostly spelling via spelling phonetic key, often with gon (2)
- backshot — 3 pair sides, mostly spelling via spelling phonetic key, often with headshot (1)
- cuz — 3 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- twino — 3 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- spinned — 2 pair sides, mostly vowel via spelling phonetic key, often with give (2)
- finna — 1 pair sides, mostly spelling via spelling phonetic key, often with swing (1)
- rinsed — 1 pair sides, mostly vowel via spelling phonetic key, often with switches (1)
- herbo — 1 pair sides, mostly spelling via spelling phonetic key, often with swerv (1)
- swerv — 1 pair sides, mostly spelling via spelling phonetic key, often with herbo (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Big Opp | BACKSEAT | 61 | 94 | 495 | loose |
| Big Opp | Close Up | 44 | 68 | 363 | loose |
| Big Opp | Shouldn’t Play With Us | 41 | 74 | 405 | loose |
