# Drake Cleanup Baseline Measurement

**Timestamp:** 2026-10-08 21:15:29 

## 1. Click Log (`docs/play-on-words/genius-clicks/drake.jsonl`)
- **Total JSONL Rows:** 12,096
- **Song Rows (`type == "song"`):** 1,204
  - `status == "done"`: 993
  - `status == "missing"`: 211
- **Song Row Sources:**
  - Chrome clicked (`source` not set / done): 704
  - API fetched (`source == "api"`): 289
  - Missing: 211
- **Line Rows (`type == "line"`):** 10,892
- **Malformed Song Rows (`song` starts with `<` or contains `<img`/`alt=`):** 20 (15 done, 5 missing)
- **Malformed Line Rows:** 464
- **Empty or Missing `genius_url` in Song Rows:** 211 (matches 211 missing rows)

## 2. Rendered View Header (`docs/play-on-words/genius-clicks/drake.md`)
- **Header Line:** `Songs finished: 993 of 1211.`
- Catalog size used by `render("Drake")` in `click_song.py`: 1211 (distinct Drake songs in vault).

## 3. Lyric Vault (`BarHitsCatalog.sqlite` - Read Only)
- **Distinct Drake Songs in `bars` table:** 1,211
- **Distinct Drake Songs without HTML/`alt=` in title:** 1,191
- **Distinct Drake Songs with HTML/`alt=` in title:** 20
- **Battle Transcripts excluded from `drake.jsonl`:** 7 (1,211 vault songs - 7 = 1,204 song rows in `drake.jsonl`)

## 4. Live Board (`http://127.0.0.1:47321/?v=active-glow-2`)
- **`GET /api/health`:** `{"ok": true}`
- **`GET /api/state` Drake Card Metrics:**
  - `song_total`: 1204
  - `opened_songs` (Done): 993
  - `unopened_songs` (Missing): 211
  - `pct`: 82% (993/1204)
  - `saved_notes`: 10864
  - `second_sense`: 10764
  - `status`: `open`

### Note on Discrepancy Explanation
- **~60% figure (58.5%):** 704 Chrome-clicked songs out of 1,204 total song rows in `drake.jsonl`.
- **82% figure (82.5%):** 993 done songs (704 Chrome + 288 API + 1 GODSPLAN) out of 1,204 total song rows in `drake.jsonl` (or 993 of 1,211 in `drake.md` header).


---

# Drake Cleanup After Measurement

**Timestamp:** 2026-10-08 21:39:15 

## 1. Click Log (`docs/play-on-words/genius-clicks/drake.jsonl`)
- **Total JSONL Rows:** 12,408
- **Song Rows (`type == "song"`):** 1,204
  - `status == "done"`: 1,031 (+38 recovered)
  - `status == "missing"`: 173 (-38)
- **Song Row Sources:**
  - Chrome clicked: 704
  - API fetched (`source == "api"`): 327 (+38 newly added)
- **Line Rows (`type == "line"`):** 11,204
- **Unresolved Songs in `drake-unresolved.jsonl`:** 173
- **Reconciliation:** Done (1031) + Unresolved (173) = 1204 / Total 1204 (100% matched)

## 2. Rendered View Header (`docs/play-on-words/genius-clicks/drake.md`)
- **Header Line:** `Songs finished: 1031 of 1211.`
- Verified: matches new done count (1031 of 1211).

## 3. Live Board (`http://127.0.0.1:47321/?v=active-glow-2`)
- **`GET /api/health`:** `{"ok": true}`
- **`GET /api/state` Drake Card Metrics:**
  - `song_total`: 1204
  - `opened_songs` (Done): 1031
  - `unopened_songs` (Missing): 173
  - `pct`: 86% (1031/1204)
  - `saved_notes`: 11175
  - `second_sense`: 11073
  - `status`: `open`
