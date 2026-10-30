"""Hand-curated iconic songs. The list lives with the retriever so both sides match."""

from __future__ import annotations


def anthem_songs(artist: str) -> set[str]:
    from catalog_retriever import ICONIC_ANTHEMS

    return set(ICONIC_ANTHEMS.get((artist or "").strip().lower(), set()))


def is_iconic_anthem(artist: str, song: str) -> bool:
    return (song or "").strip().lower() in anthem_songs(artist)
