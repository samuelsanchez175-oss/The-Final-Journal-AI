# Rap dataset builder (Spotify + lyrics → `rap_bars` format)

Turns a large **pre-joined "Spotify songs + audio attributes + lyrics"** dump into
a compact, phone-shippable CSV in the app's `ground_truth_rap_bars` format —
filtered to rap / your Spotify artists, annotated bar-by-bar with CMUdict
phonetics, and carrying the **Spotify BPM + key** the app otherwise computes
on-device.

No third-party dependencies — stdlib only, Python 3.8+.

## 1. Get the source dataset

Recommended (already has tempo + key + lyrics in one table, so **no merge needed**):

- **960K Spotify Songs With Lyrics** — https://www.kaggle.com/datasets/bwandowando/spotify-songs-with-attributes-and-lyrics
- Smaller alt (~18K): https://www.kaggle.com/datasets/imuhammad/audio-features-and-lyrics-of-spotify-songs

Download via the Kaggle CLI:

```bash
pip install kaggle            # then put kaggle.json in ~/.config/kaggle/
kaggle datasets download -d bwandowando/spotify-songs-with-attributes-and-lyrics
unzip spotify-songs-with-attributes-and-lyrics.zip -d spotify_data
```

The script **auto-detects columns**, so exact header names don't matter — it
looks for artist/`artists`, `name`/track, `lyrics`, `tempo`, `key`, `mode`,
`valence`, `energy`, `danceability`, a genre column (if any), year, and id.

## 2. Run

```bash
python3 build_rap_dataset.py \
  --input  spotify_data/<the_big_file>.csv \
  --output "../../XJournal AI/rap_bars_from_spotify.csv" \
  --cmudict "../../XJournal AI/cmudict.txt" \
  --filter  rap_filter.json \
  --limit  2000          # optional cap on KEPT songs (keeps the file phone-sized)
```

Smoke test (bundled fake sample, no download needed):

```bash
python3 build_rap_dataset.py --input sample_input.csv --output /tmp/out.csv \
  --cmudict "../../XJournal AI/cmudict.txt" --filter rap_filter.json
```

## 3. The filter — `rap_filter.json`

A song is **kept** if its genre matches `genres_any` (substring, case-insensitive)
**OR** its artist is in `artists_allow`. `artists_block` is always dropped.

- `artists_allow` was **seeded from your Spotify** (melodic-trap neighborhood:
  Gunna, Young Thug, Lil Baby, Future) plus a curated default roster.
- **Why both genre + artists?** The 960K set may have **no genre column** (Spotify
  track objects carry genre at the *artist* level, not the track). When genre is
  absent, the artist allowlist is the primary filter — so keep it reasonably full.
- Just edit the JSON to add/remove artists or genres. No code changes.

### Refreshing the allowlist from your Spotify taste
The live Spotify connection in this session could not read your **top / followed
artists** ("token expired — requires re-authorization"), and its search returns
playlists (~5 at a time), not a bulk artist export. To enrich the list from your
actual taste: reconnect Spotify, then either
1. ask Claude to re-pull "my top artists / my followed artists" and merge them in, or
2. paste your followed-artist list and drop the names into `artists_allow`.

## 4. Output

37 base columns identical to `ground_truth_rap_bars_MODEL_G.csv` (drop-in for
existing tooling) **plus** an appended audio block:

`spotify_bpm, spotify_key, spotify_scale, spotify_key_raw, spotify_mode_raw,
valence, energy, danceability, track_id`

Filled from raw lyrics + audio features:

| Field | Source |
|---|---|
| `syllable_count`, `stress_pattern`, `stress_density` | CMUdict (heuristic fallback for OOV words) |
| `phonetic_ending`, `phonetic_rhyme_class`, `phonetic_syllables` | CMUdict |
| `rhyme_word`, `rhyme_class` | last word of the bar |
| `flow_vector` | `bpm|stress_density|bar_index` |
| `primary_tone` / `secondary_tone` | heuristic from Spotify `valence`/`energy`, using the app's tone vocabulary |
| `spotify_bpm` | Spotify `tempo` |
| `spotify_key` / `spotify_scale` | Spotify `key` (0–11→C..B) + `mode` (1→Major/0→Minor), matching `BeatFingerprint` |
| `section_type` | parsed from `[Verse]`/`[Chorus]` markers if present, else `unknown` |

**Left blank on purpose** — the proprietary lexicon columns (`AuthorityClass`,
`LeadAuthorityClass`, `SupportingAuthorityClasses`, `rhyme_suggestions`,
`section_weight`). These come from your jargon/authority lexicons and Model-G
passes, not from raw lyrics. Run them through your existing pipeline to fill.

## 5. Size & licensing

- **Size:** filter to rap + `--limit`, and it's a few MB (your current
  `ground_truth_rap_bars_MODEL_G.csv` is 3.1 MB for ~9.4K bars). Add
  `--strip-lyrics` to drop verbatim `text_bar_line` and keep only derived
  features — smaller, and safer to bundle.
- **Licensing:** these Kaggle dumps contain verbatim copyrighted lyrics. Use them
  to **derive features**; do not redistribute verbatim lyrics inside a paid app.
  `--strip-lyrics` produces the redistribution-safe artifact.
