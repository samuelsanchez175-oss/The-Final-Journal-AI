# captures/ — v2 vs v3 head-to-head

Put generated verses here (one bar per line; the hook can be the first line), then grade them.

## The controlled test
Use the **same** entry for both runs so only the pipeline differs:
`eval/golden_entry.txt` (paste it into the app's journal entry / generate field).

## Steps
1. App → **Settings → Model G v3 tab** → turn **v3 OFF** (so v2 runs; make sure Model G Core + v2 are on).
2. Paste the golden entry → generate → copy the verse → save here as `v2.txt`.
3. Turn **v3 ON** → paste the **same** golden entry → generate → copy → save here as `v3.txt`.
4. Grade:
   ```bash
   python3 eval/grade_modelg.py --compare eval/captures/v2.txt eval/captures/v3.txt
   ```
   Higher **Authenticity Score** wins. Trust A1/A2/A6/A7 (A3 rhyme is indicative only — see ../README.md).

## Tip
Generate 2–3 verses per version and grade them all — `--compare` takes any number of files —
so you're comparing averages, not a single lucky/unlucky verse.
