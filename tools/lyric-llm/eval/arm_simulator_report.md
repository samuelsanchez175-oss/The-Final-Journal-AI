# 3-arm offline simulator — report

**Date:** 2026-10-30
**What this is:** post-hoc evaluation of existing V4/V5/V6 outputs on disk
under each arm's hard-check configuration. No API calls, no new
generation. Measures the gate behavior and raw copying stats; it does
NOT measure what the generators WOULD produce with the new wiring
(that needs the paid taste30 run).

Arms (all run against the same bars from each output file):
- **a_current** — couplet rhyme only (pre-fix gate behavior)
- **b_novelty** — rhyme + novelty check (chip_words=[])
- **c_novelty+chips** — same with topic-mapped chip_words excluded from
  shared-run count so a bar sharing only a chip noun doesn't trip novelty

Topic → chip-category map comes from `eval/chips_topic_map.json`.
ChipIndex loaded 5560 chips across 55 categories.

## Near-duplicate rate (fraction of bars tripping novelty)

| file | model | n verses | n bars | b_novelty | c_novelty+chips | mean 5-gram overlap | mean longest shared run |
| --- | --- | ---:| ---:| ---:| ---:| ---:| ---:|
| v4_phase6_final | frontier_v4 | 50 | 364 | **100.00%** | 99.45% | 0.929 ± 0.213 | 10.0 ± 2.7 |
| v4_50verses | frontier_v4 | 50 | 360 | 43.89% | 43.61% | 0.936 ± 0.172 | 9.4 ± 2.5 |
| pathA_matched | v5_pathA (gpt-4o-mini+catalog) | 20 | 160 | **83.13%** | 81.87% | 0.555 ± 0.222 | 8.0 ± 1.8 |
| pathB_lora_v3 | Together LoRA 50k | 20 | 160 | 19.38% | 17.50% | 0.332 ± 0.146 | 6.0 ± 0.3 |
| v4_blocks50 | catalog_block | 50 | 200 | 3.00% | 2.00% | 0.271 ± 0.035 | 6.0 ± 0.0 |
| v4_20verses | frontier_v4 | 20 | 144 | 3.47% | 2.78% | 0.161 ± 0.063 | 6.6 ± 0.8 |
| grok_expert | v5_grok_expert | 6 | 48 | 2.08% | 2.08% | 0.286 ± 0.000 | 6.0 ± 0.0 |
| grok_hand | v5_grok_hand | 1 | 8 | 0.00% | 0.00% | 0.000 ± 0.000 | 0.0 ± 0.0 |

**Reading this.** `b_novelty − c_novelty+chips` is the fraction of bars
that only tripped the shared-run detector because of a chip noun; those
are legitimate shared chips, not copies. Across the board the chip-aware
arm removes 0–2% of false flags. Not a lot, but it validates that the
chip-exclusion logic is working — chips alone can't ban a bar.

## Chip usage rate (bars containing any topic-mapped chip)

| model | mean | sd (across verses) |
| --- | ---:| ---:|
| v5_grok_hand (hand-written) | **12.50%** | — |
| v5_grok_expert | 6.25% | 0.08 |
| v5_pathB_lora | 1.25% | 0.03 |
| v5_pathA | 0.63% | 0.03 |
| catalog_block | 2.00% | 0.09 |
| frontier_v4 (20 verses) | 0.00% | 0.00 |
| frontier_v4 (50 verses) | 0.25% | 0.02 |
| frontier_v4 (phase 6) | 0.00% | 0.00 |

Hand-written grok reaches 12.5%, the gold ceiling for this sample. The
automated engines sit at 0–1.3%. **The chip bank is effectively unused
right now** — this is the gap the chip wiring in plan_v5 is meant to
close once run_taste30 executes.

## Arm-a (couplet rhyme) pass rate

0% across almost every file (v4_blocks50 hits 2%). This is because the
pre-fix outputs weren't constrained to strict phonetic AABB couplet
rhyme. The couplet-rhyme hard gate alone would reject every existing
V4/V5 verse. The rhyme-constraint fix (couplet rhyme validation inside
`_plan_from_json`) is what the taste30 run will exercise end-to-end.

## What this tells us

1. **The copy problem is confirmed and quantified.** The old
   frontier_v4 "phase 6" output is 100% near-duplicate — effectively a
   retrieval system. gpt-4o-mini + catalog scaffold (`pathA_matched`)
   paraphrases 83% of bars. LoRA sits at 19%. The novelty hard gate
   rejects exactly the pattern we wanted to catch.
2. **Chip-aware exclusion is sound and small-impact today**, because
   current engines don't use chips. Impact rises once the planner uses
   the CHIP_BANK block to prefer chip words as end words.
3. **No automated engine passes arm-a** against the current rhyme/comma
   hard gate. The matched taste30 run will be the first measurement of
   what the fixed pipeline actually produces.

## What's missing until the paid run executes

- Actual pass-rate numbers for arms b, c (we only have gate behaviour
  on OLD outputs; the generator with chips + novelty + the new editor
  prompt is only exercised when `run_taste30.py` runs).
- Chip usage rate CHANGE from arm b to arm c (right now the bars are
  identical across arms since no regeneration happened).
- 3 before/after pairs with Samuel ratings — needs the blind run.

Reproduce: `tools/lyric-llm/.venv/bin/python3 tools/lyric-llm/eval/arm_simulator.py`.
Raw data: `eval/arm_simulator_report.json`.
