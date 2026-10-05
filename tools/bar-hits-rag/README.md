# Bar Hits RAG bench

Offline prove-it layer for Bar Hits craft readout (wrap, syllables, rhyme/slant, metaphor, imagery, people). **Not wired into the app yet.**

## Run

```bash
cd "pennworkstudios.nosync"
python3 tools/bar-hits-rag/test_bench.py
python3 tools/bar-hits-rag/run_scorecard.py
```

First run ingests the Work Studios CSV into `tools/bar-hits-rag/out/bench.sqlite` (a few minutes). Later runs reuse it. `--rebuild` forces a new ingest.

Open:

`tools/bar-hits-rag/out/scorecard.html`

Check **Keep** on accurate hits. Copy the sticky **Feedback prompt** and paste it back in chat. Lane ratings (right / weak / wrong) ride along. Selections stay in the browser. JSON dump: `out/scorecard.json`.

## What a card is

**IN** = held line + end-word + syllable window (n−1…n+2) + people.  
**OUT** = Wrap (tight rhyme, max 2 per artist) / Across roster (one hit per person searched) / Nearby / Picture.

This bench retrieves **real** catalog bars. It does not generate new lines.

Do not plug into Swift until this scorecard looks right.
