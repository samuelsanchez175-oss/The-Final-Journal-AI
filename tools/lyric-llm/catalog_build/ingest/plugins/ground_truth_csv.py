"""Ingest bars from the ground-truth lyric CSV."""

from __future__ import annotations

import csv
from pathlib import Path
from typing import Iterator

from catalog_build.schema import RawLine
from lyriclib import ADLIB_TRAILING_RE, is_junk_line, normalize, tokenize


class GroundTruthCsvPlugin:
    name = "ground_truth_csv"

    def __init__(self, path: Path) -> None:
        self.path = Path(path)

    def iter_lines(self, artists: set[str] | None, since: str | None) -> Iterator[RawLine]:
        if not self.path.exists():
            return
        since_year = _since_year(since)
        with self.path.open("r", encoding="utf-8", errors="ignore", newline="") as handle:
            reader = csv.DictReader(handle)
            for row in reader:
                artist = str(row.get("artist") or "").strip()
                if not artist or artist.lower() == "artist":
                    continue
                if artists is not None and artist.lower() not in artists:
                    continue
                if since_year is not None:
                    year = _year(row.get("year"))
                    if year is not None and year < since_year:
                        continue
                text = ADLIB_TRAILING_RE.sub("", str(row.get("text_bar_line") or "")).strip()
                if not text or is_junk_line(text):
                    continue
                if len(tokenize(normalize(text))) < 3:
                    continue
                song = str(row.get("song") or "").strip() or "untitled"
                album = str(row.get("album") or "").strip() or None
                if album and album.lower() == "unknown":
                    album = None
                try:
                    line_seq = int(row.get("bar_index") or 1)
                except (TypeError, ValueError):
                    line_seq = 1
                yield RawLine(
                    artist=artist,
                    song=song,
                    album=album,
                    song_id=None,
                    line_seq=line_seq,
                    total_lines=max(line_seq, 1),
                    text=text,
                    source=self.name,
                )


def _year(value: object) -> int | None:
    text = str(value or "").strip()
    if len(text) < 4 or not text[:4].isdigit():
        return None
    return int(text[:4])


def _since_year(since: str | None) -> int | None:
    if not since:
        return None
    head = since.strip()[:4]
    if len(head) == 4 and head.isdigit():
        return int(head)
    return None
