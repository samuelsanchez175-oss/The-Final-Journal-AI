"""C1. Each source is a plugin. Junk is dropped. Dupes keep the first line."""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import Path

from catalog_build.ingest.plugins.ground_truth_csv import GroundTruthCsvPlugin
from catalog_build.ingest.plugins.train_jsonl import TrainJsonlPlugin
from catalog_build.paths import GROUND_TRUTH_CSV, SONG_META, TRAIN_JSONL
from catalog_build.schema import RawLine
from lyriclib import ADLIB_TRAILING_RE, is_junk_line, normalize, tokenize


def load_song_titles(path: Path = SONG_META) -> dict[str, dict]:
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return data if isinstance(data, dict) else {}


def default_plugins(
    jsonl_path: Path | None = None,
    csv_path: Path | None = None,
    titles: dict | None = None,
) -> list:
    song_titles = load_song_titles() if titles is None else titles
    return [
        TrainJsonlPlugin(jsonl_path or TRAIN_JSONL, titles=song_titles),
        GroundTruthCsvPlugin(csv_path or GROUND_TRUTH_CSV),
    ]


def _clean(line: RawLine) -> RawLine | None:
    artist = (line.artist or "").strip()
    song = (line.song or "").strip()
    text = ADLIB_TRAILING_RE.sub("", line.text or "").strip()
    if not artist or not song or not text or is_junk_line(text):
        return None
    if len(tokenize(normalize(text))) < 3:
        return None
    if artist == line.artist and song == line.song and text == line.text:
        return line
    return replace(line, artist=artist, song=song, text=text)


def _dedupe_key(line: RawLine) -> tuple[str, str, str]:
    return (line.artist.lower().strip(), line.song.lower().strip(), line.text.lower().strip())


def _apply_totals(lines: list[RawLine]) -> None:
    """relative_pos needs the song length, not the line's own index."""
    groups: dict[tuple[str, str, str], list[RawLine]] = {}
    for line in lines:
        key = (line.artist.lower(), line.song.lower(), line.source)
        groups.setdefault(key, []).append(line)
    for group in groups.values():
        span = max(max(item.line_seq for item in group), len(group), 1)
        for item in group:
            item.total_lines = span


def ingest(
    plugins: list | None = None,
    artists: list[str] | None = None,
    since: str | None = None,
) -> list[RawLine]:
    """Normalize, drop junk, and dedupe on artist + song + text. A second call returns the same lines."""
    wanted = {name.strip().lower() for name in artists} if artists else None
    chosen = plugins if plugins is not None else default_plugins()
    kept: list[RawLine] = []
    seen: set[tuple[str, str, str]] = set()
    for plugin in chosen:
        for line in plugin.iter_lines(wanted, since):
            if wanted is not None and line.artist.strip().lower() not in wanted:
                continue
            clean = _clean(line)
            if clean is None:
                continue
            key = _dedupe_key(clean)
            if key in seen:
                continue
            seen.add(key)
            kept.append(clean)
    _apply_totals(kept)
    return kept
