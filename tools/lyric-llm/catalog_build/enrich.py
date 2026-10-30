"""C3 — popularity, anthems, and topic tags. No model calls."""

from __future__ import annotations

import math

from catalog_build.annotate import AnnotatedLine
from catalog_build.anthems import is_iconic_anthem
from catalog_build.schema import EnrichedLine
from catalog_build.spotify import fetch_popularity, merged_seed_map
from catalog_build.topic import topic_for_line


def popularity_score(genius_votes: int, spotify_pop: int, iconic: bool) -> float:
    genius = math.log10(1 + max(0, int(genius_votes))) * 10.0
    spotify = max(0, int(spotify_pop)) * 0.8
    score = max(genius, spotify)
    if iconic:
        score = max(score, 45.0)
    return round(score, 2)


def enrich(
    lines: list[AnnotatedLine],
    refresh_spotify: bool = False,
    refresh_genius: bool = False,
    spotify_limit: int | None = None,
) -> list[EnrichedLine]:
    del refresh_genius  # Genius votes are read from the local jsonl dump on every enrich.
    from catalog_retriever import load_genius_popularity_map

    genius_map = load_genius_popularity_map()
    spotify_map = merged_seed_map()
    if refresh_spotify:
        songs = []
        seen = set()
        for line in lines:
            key = (line.raw.artist.strip().lower(), line.raw.song.strip().lower())
            if key in seen:
                continue
            seen.add(key)
            songs.append((line.raw.artist, line.raw.song))
            if spotify_limit is not None and len(songs) >= spotify_limit:
                break
        fresh = fetch_popularity(songs, refresh=True)
        spotify_map.update(fresh)

    enriched: list[EnrichedLine] = []
    for line in lines:
        artist_key = line.raw.artist.strip().lower()
        song_key = line.raw.song.strip().lower()
        votes = int(genius_map.get((artist_key, song_key), 0) or 0)
        spotify_pop = int(spotify_map.get((artist_key, song_key), 0) or 0)
        iconic = is_iconic_anthem(line.raw.artist, line.raw.song)
        topic = topic_for_line(line.raw.artist, line.raw.song, line.raw.line_seq, line.raw.text)
        enriched.append(EnrichedLine(
            annotated=line,
            popularity_score=popularity_score(votes, spotify_pop, iconic),
            is_iconic_anthem=iconic,
            topic=topic,
            genius_votes=votes,
            spotify_popularity=spotify_pop,
        ))
    return enriched
