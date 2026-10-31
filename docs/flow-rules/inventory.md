# Vault inventory

**DB:** `tools/bar-hits-catalog/BarHitsCatalog.sqlite` (opened read-only)

## Tables

| table | rows | columns |
| --- | ---:| --- |
| `bars` | 1708472 | id:TEXT, line:TEXT, artist:TEXT, song:TEXT, syllables:INTEGER, end_word:TEXT, phonetic_class:TEXT |
| `bars_fts` | 1708472 | line: |
| `bars_fts_data` | 13272 | id:INTEGER, block:BLOB |
| `bars_fts_idx` | 5057 | segid:, term:, pgno: |
| `bars_fts_docsize` | 1708472 | id:INTEGER, sz:BLOB |
| `bars_fts_config` | 1 | k:, v: |
| `cadence_punches` | 779417 | setup:TEXT, punch:TEXT, setup_norm:TEXT, last_noun:TEXT, punch_syllables:INTEGER, setup_syllables:INTEGER, artist:TEXT, song:TEXT, punch_has_noun:INTEGER |

## Line order reconstruction

No explicit order column. We treat ascending rowid as song order; reliability depends on the vault ingestion script having inserted lines in order per song. Spot-checks on anthology tracks are consistent but not guaranteed.

## No metadata columns

Neither `bars` nor `cadence_punches` carries a BPM, tempo, key, year, or album column. Track metadata must come from external sources (GetSongBPM + AcousticBrainz) and be joined on (artist, normalized_song_title).
