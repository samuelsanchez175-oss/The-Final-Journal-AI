"""Topic tags from the Phase 4 topic chain. This stage does not call a model."""

from __future__ import annotations


def topic_for_line(artist: str, song: str, line_seq: int, text: str = "") -> str:
    from catalog_retriever import get_topic_for_bar

    try:
        label = get_topic_for_bar(artist, song, line_seq, text)
    except Exception:
        return ""
    return str(label or "")
