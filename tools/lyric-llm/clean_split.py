#!/usr/bin/env python3
"""Clean the Penwork bar CSV into song-level train/val/test JSONL.

One JSONL record is one song. Lyric lines are copied unchanged and joined
with newlines, so line breaks stay. Verse and chorus labels from section_type
are written once at the start of that span. A later chorus span whose lines
match an earlier chorus in the same song is dropped. Exact duplicate lines
inside a song are dropped outside the kept chorus. Two different songs are
never combined. An exact copy of a whole song (same lines, any artist) is
removed; shared lines in songs that otherwise differ stay in both songs.
BPM and scale come from the tempo cache. Missing values are JSON null.

  python3 clean_split.py
"""

from __future__ import annotations

import csv
import hashlib
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

from lyriclib import split_song_ids
from prep import load_tempo, lookup_tempo

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DEFAULT_CSV = ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
DEFAULT_TEMPO = ROOT / "tools" / "style-profile" / "out" / "tempo_cache.jsonl"
OUT = HERE / "out"
SEED = 7

csv.field_size_limit(min(sys.maxsize, 2**31 - 1))

SECTION_MARKERS = {
    "verse": "[Verse]",
    "chorus": "[Chorus]",
    "intro": "[Intro]",
    "outro": "[Outro]",
    "bridge": "[Bridge]",
    "hook": "[Hook]",
    "refrain": "[Chorus]",
}
CHORUS_SECTIONS = frozenset({"chorus", "hook", "refrain"})


def song_id_for(artist: str, title: str) -> str:
    """Stable id. The raw artist and title are not merged with any other pair."""
    payload = artist + "\0" + title
    return hashlib.sha1(payload.encode("utf-8", errors="surrogateescape")).hexdigest()


def body_hash(rows: list[tuple[str, str]]) -> str:
    digest = hashlib.sha1()
    for text, _section in rows:
        digest.update(text.encode("utf-8", errors="surrogateescape"))
        digest.update(b"\n")
    return digest.hexdigest()


def is_chorus_row(text: str, section: str) -> bool:
    if section in CHORUS_SECTIONS:
        return True
    stripped = text.strip()
    lower = stripped.lower()
    return lower.startswith("[chorus") or lower.startswith("[hook") or lower.startswith("[refrain")


def prepare_rows(rows: list[tuple[str, str]]) -> tuple[list[tuple[str, str]], Counter]:
    """Drop a repeated chorus span and later exact copies of non-chorus lines.

    The first chorus span is kept whole, even when one of its lines also
    appeared in the verse. A later span is removed only when its lyric lines
    match an earlier chorus span exactly.
    """
    stats: Counter = Counter()
    spans: list[tuple[int, int]] = []
    index = 0
    total = len(rows)
    while index < total:
        if is_chorus_row(rows[index][0], rows[index][1]):
            end = index + 1
            while end < total and is_chorus_row(rows[end][0], rows[end][1]):
                end += 1
            spans.append((index, end))
            index = end
        else:
            index += 1

    drop: set[int] = set()
    seen_spans: set[tuple[str, ...]] = set()
    for start, end in spans:
        body = tuple(rows[pos][0] for pos in range(start, end))
        if body in seen_spans:
            drop.update(range(start, end))
            stats["chorus_spans_removed"] += 1
            stats["chorus_lines_removed"] += end - start
        else:
            seen_spans.add(body)

    kept: list[tuple[str, str]] = []
    seen_lines: set[str] = set()
    for pos, row in enumerate(rows):
        if pos in drop:
            continue
        text, section = row
        in_chorus = is_chorus_row(text, section)
        if not in_chorus and text in seen_lines:
            stats["exact_lines_removed"] += 1
            continue
        seen_lines.add(text)
        kept.append(row)
    stats["lyric_lines"] = len(kept)
    return kept, stats


def render_song(rows: list[tuple[str, str]]) -> tuple[str, int, int, Counter]:
    """Join kept lines with newlines. Insert a section marker when the label changes."""
    kept, stats = prepare_rows(rows)
    pieces: list[str] = []
    previous = ""
    markers = 0
    for text, section in kept:
        label = SECTION_MARKERS.get(section)
        if label:
            if section != previous:
                pieces.append(label)
                markers += 1
            previous = section
        else:
            previous = ""
        pieces.append(text)
    stats["markers"] = markers
    return "\n".join(pieces), len(kept), markers, stats


def choose_duplicate_winners(songs: dict[str, dict]) -> set[str]:
    """Return song ids to drop. The kept song is unchanged and not merged."""
    groups: dict[str, list[str]] = defaultdict(list)
    for sid, song in songs.items():
        groups[body_hash(song["rows"])].append(sid)
    drop: set[str] = set()
    for sids in groups.values():
        if len(sids) < 2:
            continue

        def rank(sid: str) -> tuple[int, int, int]:
            song = songs[sid]
            return (
                1 if song["bpm"] is not None else 0,
                1 if song["scale"] else 0,
                -song["order"],
            )

        winner = max(sids, key=rank)
        for sid in sids:
            if sid != winner:
                drop.add(sid)
    return drop


def read_songs(csv_path: Path, tempo: dict) -> tuple[dict[str, dict], Counter]:
    songs: dict[str, dict] = {}
    order: list[str] = []
    stats: Counter = Counter()
    current_sid = ""
    with csv_path.open(newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.DictReader(handle)
        for row_number, row in enumerate(reader, start=1):
            stats["rows"] += 1
            if stats["rows"] % 200000 == 0:
                print(f"  read {stats['rows']:,}", flush=True)
            artist = row.get("artist") or ""
            title = row.get("song") or ""
            text = row.get("text_bar_line")
            if text is None:
                text = ""
            if artist.strip().lower() == "artist" and title.strip().lower() == "song":
                stats["header_echo"] += 1
                continue
            if not artist.strip() or not title.strip():
                stats["skipped_blank_song"] += 1
                continue
            section = (row.get("section_type") or "").strip().lower()
            sid = song_id_for(artist, title)
            song = songs.get(sid)
            started_new = song is None
            if started_new:
                bpm, scale = lookup_tempo(tempo, artist, title)
                song = {
                    "artist": artist,
                    "title": title,
                    "song_id": sid,
                    "bpm": bpm,
                    "scale": scale,
                    "rows": [],
                    "order": row_number,
                }
                songs[sid] = song
                order.append(sid)
            elif song["artist"] != artist or song["title"] != title:
                stats["song_id_collision"] += 1
                continue
            if sid != current_sid:
                if not started_new:
                    stats["reopened_segments"] += 1
                current_sid = sid
            song["rows"].append((text, section))
    stats["songs_read"] = len(songs)
    stats["order"] = order
    return songs, stats


def record_for(song: dict, text: str) -> dict:
    return {
        "text": text,
        "artist": song["artist"],
        "bpm": song["bpm"],
        "scale": song["scale"],
        "song_id": song["song_id"],
    }


def write_split(path: Path, songs: list[dict]) -> dict:
    path.parent.mkdir(parents=True, exist_ok=True)
    artists: Counter = Counter()
    artist_songs: Counter = Counter()
    row_stats: Counter = Counter()
    lyric_lines = 0
    markers = 0
    missing_bpm = 0
    missing_scale = 0
    with path.open("w", encoding="utf-8") as handle:
        for song in songs:
            text, n_lines, n_markers, one_stats = render_song(song["rows"])
            row_stats.update(one_stats)
            if n_lines == 0 and not text:
                continue
            if n_lines + n_markers > 1 and "\n" not in text:
                raise RuntimeError(f"line breaks missing for {song['song_id']}")
            payload = record_for(song, text)
            handle.write(json.dumps(payload, ensure_ascii=False) + "\n")
            artists[song["artist"]] += n_lines
            artist_songs[song["artist"]] += 1
            lyric_lines += n_lines
            markers += n_markers
            if song["bpm"] is None:
                missing_bpm += 1
            if not song["scale"]:
                missing_scale += 1
    return {
        "songs": sum(artist_songs.values()),
        "lyric_lines": lyric_lines,
        "markers": markers,
        "artists": len(artist_songs),
        "missing_bpm": missing_bpm,
        "missing_scale": missing_scale,
        "lines_by_artist": artists,
        "songs_by_artist": artist_songs,
        "row_stats": row_stats,
    }


def write_report(
    path: Path,
    split_stats: dict[str, dict],
    clean_stats: Counter,
    songs_read: int,
) -> None:
    names = sorted(
        {
            artist
            for stats in split_stats.values()
            for artist in stats["songs_by_artist"]
        }
    )
    names.sort(
        key=lambda artist: (
            -sum(split_stats[split]["lines_by_artist"][artist] for split in split_stats),
            artist.lower(),
        )
    )
    lines = [
        "# Clean split counts",
        "",
        "Read-only source. The CSV was not modified.",
        "",
        "Rules applied:",
        "",
        "- One JSONL record is one song. `text` is the song's lines joined with newlines.",
        "- Lyric lines are copied as stored. `[Verse]`, `[Chorus]`, `[Intro]`, and `[Outro]` are inserted from `section_type` when that column is set. Unknown sections get no invented marker.",
        "- A repeated chorus span in the same song is kept once. `repeat_count` is not expanded.",
        "- An exact duplicate line later in the same song is removed, except lines inside the kept chorus.",
        "- An exact copy of a whole song is removed. The copy that already has BPM, then scale, is kept. Earlier in the file wins a tie. The kept song is not merged with the dropped one.",
        "- A line that also appears in a different song stays in both songs.",
        "- BPM and scale are joined from the tempo cache. Missing values are null.",
        f"- Song split is 95 / 3 / 2, seed {SEED}. A song is in one file.",
        f"- `song_id` is the SHA1 of the stored artist, a NUL byte, and the stored title.",
        "",
        "## Cleaning",
        "",
        f"- Songs read: {songs_read:,}",
        f"- Header-echo rows skipped: {clean_stats['header_echo']:,}",
        f"- Rows skipped with a blank artist or title: {clean_stats['skipped_blank_song']:,}",
        f"- Non-contiguous segments appended to the same song: {clean_stats['reopened_segments']:,}",
        f"- Exact duplicate songs removed: {clean_stats['duplicate_songs_removed']:,}",
        f"- Lyric lines removed with those songs: {clean_stats['duplicate_song_lines_removed']:,}",
        f"- Repeated chorus spans removed: {clean_stats['chorus_spans_removed']:,}",
        f"- Repeated chorus lines removed: {clean_stats['chorus_lines_removed']:,}",
        f"- Exact duplicate lines removed inside a song: {clean_stats['exact_lines_removed']:,}",
        f"- Song-id collisions: {clean_stats['song_id_collision']:,}",
        "",
        "Cross-song copies of a single line were left in place when the rest of the song differed.",
        "",
        "## Splits",
        "",
        "| Split | Songs | Lyric lines | Section markers | Artists | Songs missing BPM | Songs missing scale |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    for split in ("train", "val", "test"):
        stats = split_stats[split]
        lines.append(
            f"| {split} | {stats['songs']:,} | {stats['lyric_lines']:,} | {stats['markers']:,} | "
            f"{stats['artists']:,} | {stats['missing_bpm']:,} | {stats['missing_scale']:,} |"
        )
    total_songs = sum(split_stats[s]["songs"] for s in split_stats)
    total_lines = sum(split_stats[s]["lyric_lines"] for s in split_stats)
    lines.append(
        f"| total | {total_songs:,} | {total_lines:,} | "
        f"{sum(split_stats[s]['markers'] for s in split_stats):,} | {len(names):,} | "
        f"{sum(split_stats[s]['missing_bpm'] for s in split_stats):,} | "
        f"{sum(split_stats[s]['missing_scale'] for s in split_stats):,} |"
    )
    lines.extend(
        [
            "",
            "## Lines and songs per artist",
            "",
            "Lyric lines exclude the inserted section markers.",
            "",
            "| Artist | Train songs | Train lines | Val songs | Val lines | Test songs | Test lines | Total songs | Total lines |",
            "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
        ]
    )
    for artist in names:
        cells = [artist.replace("|", "\\|")]
        total_s = 0
        total_l = 0
        for split in ("train", "val", "test"):
            songs_n = split_stats[split]["songs_by_artist"][artist]
            lines_n = split_stats[split]["lines_by_artist"][artist]
            total_s += songs_n
            total_l += lines_n
            cells.append(f"{songs_n:,}")
            cells.append(f"{lines_n:,}")
        cells.append(f"{total_s:,}")
        cells.append(f"{total_l:,}")
        lines.append("| " + " | ".join(cells) + " |")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    print("tempo", flush=True)
    tempo = load_tempo(DEFAULT_TEMPO)
    print("read", flush=True)
    songs, stats = read_songs(DEFAULT_CSV, tempo)
    order = list(stats.pop("order"))
    drop = choose_duplicate_winners(songs)
    stats["duplicate_songs_removed"] = len(drop)
    stats["duplicate_song_lines_removed"] = sum(len(songs[sid]["rows"]) for sid in drop)
    kept_ids = [sid for sid in order if sid not in drop]
    print(
        f"songs {stats['songs_read']:,} drop {len(drop):,} keep {len(kept_ids):,}",
        flush=True,
    )
    splits = split_song_ids(kept_ids, seed=SEED)
    by_id = {sid: songs[sid] for sid in kept_ids}
    split_stats = {}
    membership = {
        "train": set(splits["train"]),
        "val": set(splits["valid"]),
        "test": set(splits["test"]),
    }
    for split in ("train", "val", "test"):
        chosen = [by_id[sid] for sid in order if sid in membership[split]]
        print(f"write {split} {len(chosen):,}", flush=True)
        split_stats[split] = write_split(OUT / f"{split}.jsonl", chosen)
        stats.update(split_stats[split]["row_stats"])
    report = OUT / "split_counts.md"
    write_report(report, split_stats, stats, stats["songs_read"])
    print("WROTE", OUT / "train.jsonl")
    print("WROTE", OUT / "val.jsonl")
    print("WROTE", OUT / "test.jsonl")
    print("WROTE", report)
    for split in ("train", "val", "test"):
        item = split_stats[split]
        print(
            split,
            "songs",
            item["songs"],
            "lines",
            item["lyric_lines"],
            "artists",
            item["artists"],
            "missing_bpm",
            item["missing_bpm"],
            "missing_scale",
            item["missing_scale"],
        )
    print(
        "removed_songs",
        stats["duplicate_songs_removed"],
        "removed_song_lines",
        stats["duplicate_song_lines_removed"],
        "chorus_spans",
        stats["chorus_spans_removed"],
        "exact_lines",
        stats["exact_lines_removed"],
        "reopened",
        stats["reopened_segments"],
    )
    verify_outputs()
    return 0


def verify_outputs() -> None:
    """Check the written files. Prints counts only, never lyric text."""
    seen: dict[str, str] = {}
    problems = 0
    for split in ("train", "val", "test"):
        path = OUT / f"{split}.jsonl"
        with path.open(encoding="utf-8") as handle:
            for line_number, line in enumerate(handle, start=1):
                record = json.loads(line)
                if list(record) != ["text", "artist", "bpm", "scale", "song_id"]:
                    problems += 1
                if not isinstance(record["text"], str) or not isinstance(record["artist"], str):
                    problems += 1
                if record["bpm"] is not None and not isinstance(record["bpm"], int):
                    problems += 1
                if record["scale"] is not None and not isinstance(record["scale"], str):
                    problems += 1
                if record["scale"] == "" or record["bpm"] == "":
                    problems += 1
                song_id = record["song_id"]
                if song_id in seen:
                    problems += 1
                else:
                    seen[song_id] = split
                if "\\n" in line and "\n" not in record["text"] and record["text"].count("\n") == 0:
                    pass
        print(f"checked {split} lines_in_file", line_number)
    print("unique_song_ids", len(seen), "schema_problems", problems)
    if problems:
        raise SystemExit("output failed verification")


if __name__ == "__main__":
    raise SystemExit(main())
