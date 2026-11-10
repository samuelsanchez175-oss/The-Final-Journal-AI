# Turk rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Turk
- Songs: 1
- Bars kept (Turk lyric lines): 64
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Turk.
- Credit strings: Turk.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 315
- REPEAT pairs, recorded separately: 61
- END rhymes: 69
- INNER rhymes: 246

By match:

- PERFECT: 19 (END 3, INNER 16)
- SLANT: 140 (END 25, INNER 115)
- ASSONANCE: 154 (END 39, INNER 115)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 20
- MED: 276
- LOW: 19

## Core

- Core Y: 315
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 139 (44.1%)
- vowel: 154 (48.9%)
- spelling: 20 (6.3%)
- multi: 2 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 32 pairs (END 19, INNER 13). Words: over, shoulders, focus, golden, chosen, lower, notice, don't.
2. `vow:IY` — 24 pairs (END 3, INNER 21). Words: g, beefing, deep, even, eagle, adidas, these, sleep.
3. `vow:AH` — 21 pairs (END 1, INNER 20). Words: fuck, hundred, fucking, coming, drunk, enough, guns, under.
4. `vow:AA` — 20 pairs (END 11, INNER 9). Words: robbers, condom, block, yacht, cop, started, god, got.
5. `slant:OW:sib` — 14 pairs (END 8, INNER 6). Words: totals, brodies, sodas, notice, lotus, focus, hoes, sofas.
6. `slant:AA:stop` — 13 pairs (END 5, INNER 8). Words: block, got, cop, drop, not, yacht, god, hard.
7. `vow:AE` — 13 pairs (END 4, INNER 9). Words: gangster, back, attached, attack, cannot, album, can't, rat.
8. `slant:AE:stop` — 10 pairs (END 3, INNER 7). Words: back, tat, rat, can't, rap, attack, cannot, attached.
9. `slant:IH:sib-stop` — 9 pairs (END 0, INNER 9). Words: nigga, niggas, bitch, shit.
10. `slant:UH:nas-stop` — 9 pairs (END 0, INNER 9). Words: looking, look.
11. `vow:AW` — 8 pairs (END 0, INNER 8). Words: how, about, now, south, house, without, mouth.
12. `slant:AE:sib-stop` — 7 pairs (END 0, INNER 7). Words: catch, rap, path, mac, bag, smash, ass, attack.
13. `vow:AO` — 7 pairs (END 1, INNER 6). Words: all, immortals, walked, tortoise, orphan, office, law, before.
14. `vow:EH` — 7 pairs (END 0, INNER 7). Words: desert, red, shell, send, tell.
15. `vow:EY` — 7 pairs (END 0, INNER 7). Words: ain't, baby, say, heartbreak.
16. `vow:IH` — 7 pairs (END 0, INNER 7). Words: listen, hit, lil, killers, children, swimming, crawfish, bitches.
17. `cmu:AA-T` — 6 pairs (END 1, INNER 5). Words: got, not, yacht, caught.
18. `slant:AH:stop` — 6 pairs (END 0, INNER 6). Words: fuck, hol, thug, blood.
19. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: shell, red, tell, said, wear, bet.
20. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: nigga, shit, kid, hit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 13 pair sides, mostly spelling via spelling phonetic key, often with niggas (8)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- hol — 5 pair sides, mostly cmu via vault phonetic_class, often with fuck (4)
- brodies — 4 pair sides, mostly spelling via spelling phonetic key, often with notice (1)
- tweeting — 1 pair sides, mostly spelling via spelling phonetic key, often with beefing (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Turk | Fuk How It Turn Out (G-Mix) | 64 | 69 | 246 | loose |
