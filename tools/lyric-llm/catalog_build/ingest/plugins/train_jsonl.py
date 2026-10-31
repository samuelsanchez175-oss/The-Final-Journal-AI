"""Ingest song records from out/train.jsonl."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Iterator

from catalog_build.schema import RawLine
from lyriclib import ADLIB_TRAILING_RE, is_junk_line, normalize, tokenize


class TrainJsonlPlugin:
    name = "train_jsonl"

    def __init__(self, path: Path, titles: dict[str, dict] | None = None) -> None:
        self.path = Path(path)
        self.titles = titles if titles is not None else {}

    def iter_lines(self, artists: set[str] | None, since: str | None) -> Iterator[RawLine]:
        # train.jsonl songs have no release date. --since does not drop them.
        del since
        if not self.path.exists():
            return
        with self.path.open("r", encoding="utf-8") as handle:
            for raw in handle:
                raw = raw.strip()
                if not raw:
                    continue
                try:
                    obj = json.loads(raw)
                except json.JSONDecodeError:
                    continue
                artist = str(obj.get("artist") or "").strip()
                if not artist:
                    continue
                if artists is not None and artist.lower() not in artists:
                    continue
                song_id = str(obj.get("song_id") or "").strip() or None
                meta = self.titles.get(song_id or "", {}) if song_id else {}
                song = str(meta.get("song") or obj.get("song") or song_id or "").strip()
                if not song or song.lower() == "song":
                    song = song_id or "untitled"
                album = str(meta.get("album") or obj.get("album") or "").strip() or None
                if album and album.lower() == "album":
                    album = None
                body = str(obj.get("text") or "")
                kept: list[str] = []
                for piece in body.splitlines():
                    text = ADLIB_TRAILING_RE.sub("", piece).strip()
                    if not text or is_junk_line(text):
                        continue
                    if len(tokenize(normalize(text))) < 3:
                        continue
                    kept.append(text)
                total = len(kept)
                for index, text in enumerate(kept, start=1):
                    yield RawLine(
                        artist=artist,
                        song=song,
                        album=album,
                        song_id=song_id,
                        line_seq=index,
                        total_lines=total,
                        text=text,
                        source=self.name,
                    )
