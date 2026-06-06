#!/usr/bin/env python3
"""
build_rap_dataset.py
────────────────────
Turn a large pre-joined "Spotify songs + audio attributes + lyrics" dump
(default target: bwandowando's "960K Spotify Songs With Lyrics", Kaggle) into a
compact, phone-shippable CSV in The Final Journal AI's `ground_truth_rap_bars`
format — filtered to rap / your Spotify artists, annotated bar-by-bar with
CMUdict phonetics, and carrying the Spotify BPM + key the app otherwise has to
compute on-device.

WHY THIS SHAPE
──────────────
  • Lyrics are tiny as text; the giant corpora are only big because of millions
    of *non-rap* songs. Filter to rap first, then you ship a few MB.
  • The output mirrors `ground_truth_rap_bars_MODEL_G.csv` (37 columns) so it is
    drop-in for existing tooling, PLUS an appended audio block
    (spotify_bpm / spotify_key / spotify_scale / valence / energy / ...).
  • Copyright-safe posture: the value you bundle is the *derived features*
    (syllables, stress, rhyme/phonetic classes, BPM, key) — not verbatim lyrics.
    By default verbatim `text_bar_line` IS written so you can review; pass
    --strip-lyrics to blank it for a redistribution-safe artifact.

USAGE
─────
  # 1) Download the Kaggle dataset (see README), then:
  python3 build_rap_dataset.py \
      --input  /path/to/spotify_songs_with_lyrics.csv \
      --output ../../XJournal\ AI/rap_bars_from_spotify.csv \
      --cmudict "../../XJournal AI/cmudict.txt" \
      --filter  rap_filter.json

  # Quick smoke test against the bundled tiny sample:
  python3 build_rap_dataset.py --input sample_input.csv --output /tmp/out.csv \
      --cmudict "../../XJournal AI/cmudict.txt" --filter rap_filter.json

This script has NO third-party dependencies (stdlib csv/json/re/argparse only),
so it runs anywhere Python 3.8+ is installed.
"""

import argparse
import csv
import json
import re
import sys
from pathlib import Path

# ─────────────────────────────────────────────────────────────────
# Target schema — exact column order of ground_truth_rap_bars_MODEL_G.csv
# ─────────────────────────────────────────────────────────────────
BASE_COLUMNS = [
    "REAL LYRICS 2026 NEW JAN 24", "artist", "song", "album", "section_type",
    "repeat_count", "text_bar_line", "rhyme_word", "rhyme_suggestions",
    "rhyme_class", "flow_vector", "primary_tone", "secondary_tone",
    "section_weight", "avg_rhyme_density", "year", "syllable_count", "context",
    "phonetic_ending", "phonetic_rhyme_class", "phonetic_syllables",
    "phonetic_stress_pattern", "AuthorityClass", "PriorityWeight",
    "LeadAuthorityClass", "LeadPriorityWeight", "SupportingAuthorityClasses",
    "bar_index", "bar_group_2", "bar_group_4", "syllable_count_recalc",
    "stress_pattern", "stress_density", "phonetic_system", "rhyme_density",
    "average_syllables", "average_stress_density",
]
# Appended audio block — this is the bpm+key the app usually derives at runtime.
AUDIO_COLUMNS = [
    "spotify_bpm", "spotify_key", "spotify_scale", "spotify_key_raw",
    "spotify_mode_raw", "valence", "energy", "danceability", "track_id",
]
OUT_COLUMNS = BASE_COLUMNS + AUDIO_COLUMNS

SOURCE_TAG = "spotify_960k"
PROVENANCE = "imported via build_rap_dataset.py"

# ─────────────────────────────────────────────────────────────────
# CMUdict — phonetics
# ─────────────────────────────────────────────────────────────────
ARPABET_VOWELS = {
    "AA", "AE", "AH", "AO", "AW", "AY", "EH", "ER", "EY", "IH", "IY",
    "OW", "OY", "UH", "UW",
}
_VARIANT_RE = re.compile(r"\(\d+\)$")        # WORD(2) -> WORD
_WORD_RE = re.compile(r"[A-Za-z']+")
_LRC_TS_RE = re.compile(r"\[\d{1,2}:\d{2}(?:[.:]\d{1,3})?\]")  # [00:12.34]
_SECTION_RE = re.compile(r"^\s*[\[\(]\s*([A-Za-z][\w &/-]*?)\s*[\]\)]\s*$")
_PAREN_RE = re.compile(r"\([^)]*\)")          # (Skrrt) ad-libs


def load_cmudict(path: Path) -> dict:
    """Parse CMUdict ('WORD  PH PH PH'). Keeps the first pronunciation only."""
    d = {}
    with open(path, encoding="latin-1") as fh:
        for line in fh:
            if not line or line.startswith(";;;"):
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            word = _VARIANT_RE.sub("", parts[0]).upper()
            if word not in d:                 # first variant wins
                d[word] = parts[1:]
    return d


def _is_vowel(ph: str) -> bool:
    return ph[:2].rstrip("012") in ARPABET_VOWELS or ph[:2] in ARPABET_VOWELS


def _stress_digits(phones) -> str:
    """ARPAbet stress (0/1/2 on vowels) -> '1' stressed / '0' unstressed."""
    out = []
    for ph in phones:
        if _is_vowel(ph):
            out.append("1" if ph[-1] in ("1", "2") else "0")
    return "".join(out)


def _heuristic_syllables(word: str) -> int:
    w = word.lower()
    groups = re.findall(r"[aeiouy]+", w)
    n = len(groups)
    if w.endswith("e") and n > 1 and not w.endswith(("le", "ye")):
        n -= 1
    return max(1, n)


def word_phonetics(word: str, cmu: dict):
    """Return (phones|None, syllable_count, stress_string)."""
    key = re.sub(r"[^A-Za-z']", "", word).upper().strip("'")
    if not key:
        return None, 0, ""
    phones = cmu.get(key)
    if phones is None and "'" in key:          # GOIN' -> GOING fallback
        phones = cmu.get(key.replace("'", "")) or cmu.get(key + "G")
    if phones:
        stress = _stress_digits(phones)
        return phones, max(1, len(stress)), stress
    n = _heuristic_syllables(key)
    return None, n, "1" + "0" * (n - 1)


# ─────────────────────────────────────────────────────────────────
# Per-line annotation
# ─────────────────────────────────────────────────────────────────
def annotate_line(text: str, cmu: dict) -> dict:
    analysis_text = _PAREN_RE.sub(" ", text)          # drop ad-libs for analysis
    words = _WORD_RE.findall(analysis_text)
    if not words:
        words = _WORD_RE.findall(text)

    syllables = 0
    stress = []
    for w in words:
        _, syl, st = word_phonetics(w, cmu)
        syllables += syl
        stress.append(st)
    stress_pattern = "".join(stress)
    stress_density = (stress_pattern.count("1") / len(stress_pattern)
                      if stress_pattern else 0.0)

    rhyme_word = words[-1].strip("'").lower() if words else ""
    phones, p_syl, p_stress = word_phonetics(rhyme_word, cmu) if rhyme_word else (None, 0, "")
    phonetic_ending = " ".join(phones) if phones else ""
    phonetic_rhyme_class = _phonetic_rhyme_class(phones) if phones else ""
    rhyme_class = _ortho_rhyme_tail(rhyme_word)

    return {
        "text_bar_line": text.strip(),
        "rhyme_word": rhyme_word,
        "rhyme_class": rhyme_class,
        "syllable_count": syllables,
        "phonetic_ending": phonetic_ending,
        "phonetic_rhyme_class": phonetic_rhyme_class,
        "phonetic_syllables": p_syl,
        "phonetic_stress_pattern": p_stress,
        "stress_pattern": stress_pattern,
        "stress_density": stress_density,
    }


def _phonetic_rhyme_class(phones) -> str:
    """Phones from the last stressed vowel onward (rhyme nucleus + coda)."""
    last_stressed = -1
    for i, ph in enumerate(phones):
        if _is_vowel(ph) and ph[-1] in ("1", "2"):
            last_stressed = i
    if last_stressed == -1:                    # no stressed vowel -> last vowel
        for i, ph in enumerate(phones):
            if _is_vowel(ph):
                last_stressed = i
    return " ".join(phones[last_stressed:]) if last_stressed >= 0 else " ".join(phones)


def _ortho_rhyme_tail(word: str) -> str:
    """Cheap orthographic rhyme key: from the last vowel letter to the end."""
    if not word:
        return ""
    idx = max((word.rfind(v) for v in "aeiouy"), default=-1)
    tail = word[idx:] if idx >= 0 else word
    return tail if len(tail) >= 2 else word[-3:]


# valence/energy -> tone, using the app's own tone vocabulary
def tone_from_mood(valence, energy):
    v = _to_float(valence)
    e = _to_float(energy)
    if v is None or e is None:
        return "confident", "luxurious"
    if v >= 0.6 and e >= 0.6:
        return "celebratory", "confident"
    if v >= 0.6 and e < 0.6:
        return "confident", "luxurious"
    if v < 0.4 and e >= 0.6:
        return "aggressive", "gritty"
    if v < 0.4 and e < 0.4:
        return "detached", "paranoid"
    return "confident", "luxurious"


KEY_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


def key_to_name(key_raw):
    k = _to_int(key_raw)
    if k is None or k < 0 or k > 11:
        return "Unknown"
    return KEY_NAMES[k]


def mode_to_scale(mode_raw):
    m = _to_int(mode_raw)
    if m is None:
        return "Unknown"
    return "Major" if m == 1 else "Minor"


# ─────────────────────────────────────────────────────────────────
# Lyrics -> bars
# ─────────────────────────────────────────────────────────────────
def split_into_bars(lyrics: str, opts: dict):
    """Yield (section_type, line) tuples from a lyrics blob."""
    section = "unknown"
    out = []
    for raw in str(lyrics).splitlines():
        line = _LRC_TS_RE.sub("", raw).strip()
        if not line:
            continue
        m = _SECTION_RE.match(line)
        if m:
            section = m.group(1).split()[0].lower()  # 'Verse 2' -> 'verse'
            continue
        stripped = _PAREN_RE.sub("", line).strip()
        if opts.get("drop_pure_adlib_lines", True) and not stripped:
            continue                            # line was only an ad-lib
        n = len(line)
        if n < opts.get("min_line_chars", 6) or n > opts.get("max_line_chars", 140):
            continue
        out.append((section, line))
    return out


# ─────────────────────────────────────────────────────────────────
# Column auto-detection (schemas vary between Spotify dumps)
# ─────────────────────────────────────────────────────────────────
def pick(colmap, *candidates):
    for c in candidates:
        if c in colmap:
            return colmap[c]
    return None


def detect_columns(header):
    cm = {h.lower().strip(): h for h in header}
    cols = {
        "artist": pick(cm, "artists", "artist", "artist_name", "track_artist", "artist(s)_name"),
        "song":   pick(cm, "name", "track_name", "song", "title", "track"),
        "album":  pick(cm, "album_name", "album", "album_title"),
        "lyrics": pick(cm, "lyrics", "text", "lyric"),
        "tempo":  pick(cm, "tempo", "bpm"),
        "key":    pick(cm, "key"),
        "mode":   pick(cm, "mode"),
        "valence": pick(cm, "valence"),
        "energy":  pick(cm, "energy"),
        "dance":   pick(cm, "danceability"),
        "genre":   pick(cm, "playlist_genre", "track_genre", "genre", "genres", "playlist_subgenre"),
        "year":    pick(cm, "year", "release_year", "track_album_release_date", "album_release_date"),
        "track_id": pick(cm, "track_id", "id", "uri", "spotify_id"),
    }
    return cols


def normalize_artist(value, opts):
    """`artists` may be a stringified list like "['Gunna', 'Lil Baby']"."""
    s = str(value).strip()
    if opts.get("treat_artists_field_as_list", True) and s[:1] in "[(":
        names = re.findall(r"['\"]([^'\"]+)['\"]", s)
        if names:
            return names[0] if opts.get("primary_artist_only", False) else ", ".join(names), names
    return s, [s]


def year_of(value):
    m = re.search(r"(19|20)\d{2}", str(value))
    return m.group(0) if m else ""


# ─────────────────────────────────────────────────────────────────
# Filter
# ─────────────────────────────────────────────────────────────────
def flatten_allow(node, acc):
    if isinstance(node, dict):
        for k, v in node.items():
            if not k.startswith("_comment"):
                flatten_allow(v, acc)
    elif isinstance(node, list):
        for v in node:
            flatten_allow(v, acc)
    elif isinstance(node, str):
        acc.add(node.lower().strip())


def load_filter(path: Path):
    cfg = json.loads(Path(path).read_text(encoding="utf-8"))
    allow = set()
    flatten_allow(cfg.get("artists_allow", {}), allow)
    block = {a.lower().strip() for a in cfg.get("artists_block", [])}
    genres = [g.lower().strip() for g in cfg.get("genres_any", [])]
    opts = cfg.get("options", {})
    return allow, block, genres, opts


def keep_row(artist_names, genre_value, allow, block, genres):
    names = [n.lower().strip() for n in artist_names]
    if any(n in block for n in names):
        return False
    if any(n in allow for n in names):
        return True
    if genres and genre_value:
        g = str(genre_value).lower()
        if any(tok in g for tok in genres):
            return True
    return False


# ─────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────
def _to_float(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def _to_int(x):
    f = _to_float(x)
    return int(f) if f is not None else None


# ─────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────
def main():
    ap = argparse.ArgumentParser(description="Build rap_bars CSV from a Spotify+lyrics dump.")
    ap.add_argument("--input", required=True, help="Source CSV (Spotify songs + lyrics).")
    ap.add_argument("--output", required=True, help="Destination CSV (ground_truth_rap_bars format).")
    ap.add_argument("--cmudict", required=True, help="Path to cmudict.txt.")
    ap.add_argument("--filter", required=True, help="rap_filter.json.")
    ap.add_argument("--limit", type=int, default=0, help="Max KEPT songs (0 = no limit).")
    ap.add_argument("--strip-lyrics", action="store_true",
                    help="Blank text_bar_line in output (ship features, not verbatim lyrics).")
    args = ap.parse_args()

    cmu = load_cmudict(Path(args.cmudict))
    print(f"✓ CMUdict loaded: {len(cmu):,} entries")
    allow, block, genres, opts = load_filter(Path(args.filter))
    print(f"✓ Filter: {len(allow)} allow-artists, {len(block)} block, {len(genres)} genres")

    csv.field_size_limit(min(sys.maxsize, 2**31 - 1))
    n_rows = n_songs = n_bars = 0
    with open(args.input, newline="", encoding="utf-8", errors="replace") as fin:
        reader = csv.reader(fin)
        try:
            header = next(reader)
        except StopIteration:
            print("✗ Empty input."); return
        cols = detect_columns(header)
        if cols["lyrics"] is None or cols["artist"] is None:
            print(f"✗ Could not find lyrics/artist columns in header: {header}")
            sys.exit(2)
        idx = {k: header.index(v) for k, v in cols.items() if v is not None}
        print("✓ Column mapping:", {k: header[i] for k, i in idx.items()})

        def cell(row, key):
            i = idx.get(key)
            return row[i] if i is not None and i < len(row) else ""

        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        with open(args.output, "w", newline="", encoding="utf-8") as fout:
            writer = csv.DictWriter(fout, fieldnames=OUT_COLUMNS, extrasaction="ignore")
            writer.writeheader()

            for row in reader:
                n_rows += 1
                artist_disp, artist_names = normalize_artist(cell(row, "artist"), opts)
                if not keep_row(artist_names, cell(row, "genre"), allow, block, genres):
                    continue
                lyrics = cell(row, "lyrics")
                if not lyrics or not str(lyrics).strip():
                    continue
                bars = split_into_bars(lyrics, opts)
                if not bars:
                    continue

                tempo = cell(row, "tempo")
                bpm = _to_int(tempo) or 0
                key_raw, mode_raw = cell(row, "key"), cell(row, "mode")
                valence, energy, dance = cell(row, "valence"), cell(row, "energy"), cell(row, "dance")
                prim_tone, sec_tone = tone_from_mood(valence, energy)
                song = str(cell(row, "song")).strip()
                album = str(cell(row, "album")).strip()
                year = year_of(cell(row, "year"))
                track_id = str(cell(row, "track_id")).strip()
                audio = {
                    "spotify_bpm": bpm or "",
                    "spotify_key": key_to_name(key_raw),
                    "spotify_scale": mode_to_scale(mode_raw),
                    "spotify_key_raw": _to_int(key_raw) if _to_int(key_raw) is not None else "",
                    "spotify_mode_raw": _to_int(mode_raw) if _to_int(mode_raw) is not None else "",
                    "valence": _to_float(valence) if _to_float(valence) is not None else "",
                    "energy": _to_float(energy) if _to_float(energy) is not None else "",
                    "danceability": _to_float(dance) if _to_float(dance) is not None else "",
                    "track_id": track_id,
                }

                # annotate bars + collect per-song aggregates
                ann_rows = []
                rhyme_keys = []
                for bar_i, (section, line) in enumerate(bars, start=1):
                    a = annotate_line(line, cmu)
                    a.update({"section_type": section, "bar_index": bar_i})
                    ann_rows.append(a)
                    rhyme_keys.append(a["phonetic_rhyme_class"])

                n_lines = len(ann_rows)
                avg_syl = sum(a["syllable_count"] for a in ann_rows) / n_lines
                avg_sd = sum(a["stress_density"] for a in ann_rows) / n_lines
                key_counts = {}
                for k in rhyme_keys:
                    if k:
                        key_counts[k] = key_counts.get(k, 0) + 1
                matched = sum(c for c in key_counts.values() if c > 1)
                rhyme_density = round(matched / n_lines, 4) if n_lines else 0.0

                for a in ann_rows:
                    bi = a["bar_index"]
                    sd = a["stress_density"]
                    out = {c: "" for c in OUT_COLUMNS}
                    out.update({
                        "REAL LYRICS 2026 NEW JAN 24": SOURCE_TAG,
                        "artist": artist_disp,
                        "song": song,
                        "album": album,
                        "section_type": a["section_type"],
                        "repeat_count": "",
                        "text_bar_line": "" if args.strip_lyrics else a["text_bar_line"],
                        "rhyme_word": a["rhyme_word"],
                        "rhyme_suggestions": "",
                        "rhyme_class": a["rhyme_class"],
                        "flow_vector": f"{bpm}|{sd:.2f}|{bi}",
                        "primary_tone": prim_tone,
                        "secondary_tone": sec_tone,
                        "section_weight": "",
                        "avg_rhyme_density": rhyme_density,
                        "year": year,
                        "syllable_count": a["syllable_count"],
                        "context": "line_level",
                        "phonetic_ending": a["phonetic_ending"],
                        "phonetic_rhyme_class": a["phonetic_rhyme_class"],
                        "phonetic_syllables": a["phonetic_syllables"],
                        "phonetic_stress_pattern": a["phonetic_stress_pattern"],
                        "AuthorityClass": "",
                        "PriorityWeight": 0.3,
                        "LeadAuthorityClass": "",
                        "LeadPriorityWeight": "",
                        "SupportingAuthorityClasses": "",
                        "bar_index": bi,
                        "bar_group_2": (bi - 1) // 2,
                        "bar_group_4": (bi - 1) // 4,
                        "syllable_count_recalc": a["syllable_count"],
                        "stress_pattern": a["stress_pattern"],
                        "stress_density": round(sd, 6),
                        "phonetic_system": "CMUdict",
                        "rhyme_density": rhyme_density,
                        "average_syllables": round(avg_syl, 2),
                        "average_stress_density": round(avg_sd, 4),
                    })
                    out.update(audio)
                    writer.writerow(out)
                    n_bars += 1

                n_songs += 1
                if args.limit and n_songs >= args.limit:
                    break

    print(f"\n✅ Done. Scanned {n_rows:,} rows → kept {n_songs:,} songs → {n_bars:,} bars")
    print(f"   Output: {args.output}")
    if n_songs == 0:
        print("   ⚠ 0 songs kept — check the genre/artist filter or column mapping above.")


if __name__ == "__main__":
    main()
