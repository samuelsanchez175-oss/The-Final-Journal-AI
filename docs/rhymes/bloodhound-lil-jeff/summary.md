# Bloodhound Lil Jeff rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bloodhound Lil Jeff
- Songs: 1
- Bars kept (Bloodhound Lil Jeff lyric lines): 74
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bloodhound Lil Jeff.
- Credit strings: Bloodhound Lil Jeff.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 640
- REPEAT pairs, recorded separately: 54
- END rhymes: 153
- INNER rhymes: 487

By match:

- PERFECT: 84 (END 20, INNER 64)
- SLANT: 348 (END 81, INNER 267)
- ASSONANCE: 207 (END 51, INNER 156)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 81
- MED: 516
- LOW: 43

## Core

- Core Y: 626
- Core N among rhyme pairs: 14

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 397 (62.0%)
- vowel: 207 (32.3%)
- spelling: 35 (5.5%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 71 pairs (END 27, INNER 44). Words: ricks, bricks, fifty, bitch, him, hit, bitches, shit.
2. `slant:IH:sib-stop` — 43 pairs (END 17, INNER 26). Words: bitch, shit, switch, snitch, hit, dick, stick, kiss.
3. `slant:AA:stop` — 39 pairs (END 13, INNER 26). Words: got, stop, block, dropped, spot, lock, drop, not.
4. `slant:IH:stop` — 38 pairs (END 7, INNER 31). Words: hit, nigga, shit, big, dick, stick, kick, tripped.
5. `vow:AA` — 37 pairs (END 16, INNER 21). Words: box, rockin, got, cops, socks, watch, fox, top.
6. `cmu:OW` — 30 pairs (END 1, INNER 29). Words: know, no, blow, bro, show, go.
7. `vow:OW` — 29 pairs (END 0, INNER 29). Words: know, opps, told, don't, no, close, throwin, herbo.
8. `slant:IH:nas-stop` — 19 pairs (END 2, INNER 17). Words: him, shit, dick, slim, spit, diddy, whip, everything.
9. `slant:IH:nas-sib` — 18 pairs (END 4, INNER 14). Words: him, switch, snitch, wish, kiss, slim, bitch.
10. `vow:IY` — 16 pairs (END 6, INNER 10). Words: free, g, real, screamin, keep, henny, shitty, speak.
11. `slant:AA:sib-stop` — 15 pairs (END 8, INNER 7). Words: watch, cops, lock, top, hop, got, shots, stop.
12. `vow:AE` — 15 pairs (END 0, INNER 15). Words: can't, rap, traffic, drac, pass, ass, map, had.
13. `slant:IH:sib` — 13 pairs (END 3, INNER 10). Words: niggas, lids, sticks, bitches, switch, snitch, wish, kiss.
14. `vow:EH` — 13 pairs (END 0, INNER 13). Words: steppin, there, best, friend, every, get, semis, when.
15. `cmu:IY-L` — 11 pairs (END 4, INNER 7). Words: real, feel, peel, deal.
16. `slant:IH:liq-stop` — 11 pairs (END 1, INNER 10). Words: still, hit, shit, really, milli, kick, big, dick.
17. `slant:IH:liq-sib` — 10 pairs (END 4, INNER 6). Words: bitch, millis, really, still, milli, wish, 'til, clear.
18. `slant:IY:liq-stop` — 10 pairs (END 2, INNER 8). Words: street, real, feel, peel, speak, hear, keep, deal.
19. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: ten, when, get, greg, head, 'net, wet.
20. `vow:EY` — 8 pairs (END 0, INNER 8). Words: take, j, played, chases, ain't, say, favorite, cray.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with hit (3)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with lids (2)
- opps — 7 pair sides, mostly vowel via spelling phonetic key, often with know (4)
- henny — 3 pair sides, mostly vowel via spelling phonetic key, often with pity (1)
- drac — 3 pair sides, mostly vowel via spelling phonetic key, often with cant (2)
- herbo — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- raq — 3 pair sides, mostly spelling via spelling phonetic key, often with saks (1)
- titties — 2 pair sides, mostly spelling via spelling phonetic key, often with kidneys (1)
- dyin — 2 pair sides, mostly spelling via spelling phonetic key, often with hear (1)
- hemis — 1 pair sides, mostly spelling via spelling phonetic key, often with semis (1)
- bap — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- doin — 1 pair sides, mostly spelling via spelling phonetic key, often with goin (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with will (1)
- bappin — 1 pair sides, mostly spelling via spelling phonetic key, often with rappin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bloodhound Lil Jeff | Ahhh (Remix) | 74 | 153 | 487 | loose |
