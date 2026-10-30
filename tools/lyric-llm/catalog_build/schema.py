"""Line objects shared by the catalog build stages."""

from __future__ import annotations

from dataclasses import dataclass, field

SCHEMA_VERSION = "v5.1"


@dataclass
class RawLine:
    artist: str
    song: str
    album: str | None
    song_id: str | None
    line_seq: int
    total_lines: int
    text: str
    source: str


@dataclass
class AnnotatedLine:
    raw: RawLine
    tokens: list[str]
    end_word: str
    end_rime: str
    vowel_class: str
    syllables: int
    inner_rhymes: list[dict]
    inner_rhyme_count: int
    inner_vowel_class: str
    is_generic: bool
    is_proper_noun: bool
    chronological_arc: str
    relative_pos: float
    next_bar_text: str = ""
    next_bar_end_word: str = ""


@dataclass
class EnrichedLine:
    annotated: AnnotatedLine
    popularity_score: float
    is_iconic_anthem: bool
    topic: str
    genius_votes: int = 0
    spotify_popularity: int = 0
    extra: dict = field(default_factory=dict)
