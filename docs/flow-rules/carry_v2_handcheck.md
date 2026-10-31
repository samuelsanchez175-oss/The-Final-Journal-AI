# Carry v2 — hand-checked precision on 30 pairs

**Pool:** all 18 pairs the v2 detector flagged carry in the 200-pair sample +
12 random non-flagged pairs (seeded).
**Judgment criterion:** a carry means the sentence genuinely continues across
the two bars — the next line is grammatically needed to parse the current
line, not just thematically related.

## YES-tier (18 pairs the detector called carry)

| # | detector | hand | note |
| ---:| :-:| :-:| --- |
| 12 | YES | **no** | 'G5 and not the propellers' + 'Told my niggas…' — two independent statements |
| 14 | YES | no | 'All this hi-tec and wockhardt on my back' + 'Shoppin' out of town' — new scene |
| 16 | YES | no | 'Half of niggas really phony' + 'Finna wake these niggas' — adjective + new action |
| 23 | YES | no | 'Drinkin' promethazine, me and my slime' + 'Add a few shrooms…' — "drinkin'" IS a verb; spaCy missed `-in'` form |
| 30 | YES | no | 'Rondo number nine' + 'Hope you buster niggas never cross the line' — title + new wish |
| 36 | YES | no | 'Monday through Sunday, ooh' + 'Yung Carti be on it' — time phrase + new line |
| 49 | YES | no | 'Woah, two hundred for brunch' + 'I eat two hundred for lunch' — parallel bars |
| 56 | YES | **YES** | "there's so many guns in" + "Shoot (?), then we robbin'" — "in" dangles into next |
| 82 | YES | no | 'Turn my savage on' + 'your girl work out to my songs' — "turn on" phrasal complete |
| 95 | YES | no | French bars; English POS doesn't apply |
| 97 | YES | no | 'Pullin' up, my bumper hard body' + 'Dark tint…' — "Pullin'" is a verb spaCy missed |
| 98 | YES | no | 'Eliantte your finger ring' + 'Baby swallow my dingaling' — two independent |
| 108 | YES | no | 'Heatin' up like last day in June' + 'Niggas stealin'…' — "Heatin'" verb missed |
| 157 | YES | no | 'Audemars Piguet' + 'I put that water on my wrist' — brand + new line |
| 166 | YES | no | 'New Ghost, Patrick Swayze…' + 'Southside, but not JD…' — list + list |
| 169 | YES | no | 'From the jungle like the lions…' + 'And I told you, I'm fly…' — simile + new simile |
| 184 | YES | no | 'Hedi Slimane with the walk' + 'I got on Celine, Balenciaga' — reference + wear |
| 196 | YES | no | "she bendin' it over" + "Spend a thousand on kicks" — "bend it over" complete |

**YES tier:** 1 TP, 17 FP. **Precision at this tier = 1/18 = 5.6%**.

## no-tier (12 pairs the detector called no-carry)

All 12 were correctly non-carries (independent bars). **FN = 0**, recall on
these 12 ≈ 100% (trivially, since there are no positives to miss).

## Overall on 30 hand-checked pairs

- TP = 1
- FP = 17
- TN = 12
- FN = 0 (on this sample)
- **Precision = 1 / 18 ≈ 0.056**
- Recall ≈ 1.0 (every true carry in the sample was caught, but n_positive = 1 so this estimate is thin)
- **Corrected carry rate: NOT 10.44%.** If precision is ~6% at this threshold, the real carry rate on the clean subset is closer to 10.44% × 0.056 ≈ **0.6%**, far below the v1 (5.68%) and v2 raw (10.44%) numbers. The honest headline is **"grammar-only carry detection on rap bars is not usable at this precision; real carry rate is likely very low — single-digit percent at most."**

## Why it fails

1. **spaCy misses `-in'` slang verbs** (`Pullin'`, `Heatin'`, `Drinkin'`,
   `shoppin'`). Normalizing `-in'` → `-ing` before parsing would recover
   those (~4-5 of 18 FPs).
2. **Even with correct verb detection, verb-less rap bars are usually
   complete images, not dangling clauses.** Lines like "Audemars Piguet"
   or "Rondo number nine" are self-contained noun phrases; the next bar
   isn't completing them. The dangling-clause heuristic doesn't match
   rap style.
3. **"Phrasal verb complete" vs "preposition dangling"** can't be told
   apart from the word alone. "Turn it on" vs "many guns in [sentence
   continues]" — same preposition, different grammar role. Needs a
   dependency parse of the full couplet or a learned model.

## Updated rule for the rulebook

- Reclassify "carry rate" under "needs audio / hand-marked / better model
  to measure" alongside triplet flow.
- The 27.4% v1 number was wrong (false positives from capitalization);
  the 10.44% v2 number is wrong (grammar heuristic overshoots on
  noun-phrase bars); neither should be used downstream.
- A real carry-rate number requires either a dependency parse that
  distinguishes phrasal particles from hanging prepositions, or a
  per-song hand-mark on ~5-10 verses so a learned classifier can
  calibrate. Not blocking for v7 generation targets — the v7_spec marks
  rule 6 "finalize once v2 reports."
