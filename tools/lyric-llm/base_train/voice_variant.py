"""Voice-conditioning text for one training example.

one_hot puts the artist name in a short system line and the
`<voice: Artist>` token on the user turn. systembrief puts
voice_briefs.json[artist].brief in the system turn, verbatim, and
leaves the voice token off the user turn.
"""

from __future__ import annotations

import json
from pathlib import Path

FIM_SYSTEM = (
    "Write the missing bar. Context above and below is from the same song."
)

ONE_HOT_SYSTEM = (
    "Write bars like {artist}. Keep the artist's slang, syllable count, "
    "and rhyme pattern."
)

SECTION_FOR_ARC = {
    "intro": "intro",
    "verse_build": "verse",
    "verse_turn": "verse",
    "climax_punch": "verse",
}


def section_name(chronological_arc: str | None) -> str:
    arc = (chronological_arc or "").strip()
    return SECTION_FOR_ARC.get(arc, "verse")


def topic_name(topic: str | None) -> str:
    cleaned = (topic or "").strip()
    return cleaned or "untagged"


def one_hot_system(artist: str) -> str:
    return ONE_HOT_SYSTEM.format(artist=artist)


def load_briefs(path: Path | None = None) -> dict:
    brief_path = path or Path(__file__).resolve().parent / "voice_briefs.json"
    data = json.loads(brief_path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{brief_path} must be a JSON object of artists")
    return data


def brief_text(briefs: dict, artist: str) -> str:
    entry = briefs.get(artist)
    if not isinstance(entry, dict) or not isinstance(entry.get("brief"), str):
        raise ValueError(f"no voice brief for {artist}")
    return entry["brief"]


def _fields(example: dict) -> list[str]:
    return [
        f"END_WORD: {example['end_word']}",
        f"SYLLABLES: {example['syllables']}",
    ]


def render_messages(example: dict, variant: str, briefs: dict | None = None) -> dict:
    """Return one OpenAI chat JSONL object.

    `example` keys: artist, section, line_seq, total_lines, prev_text,
    topic, end_word, syllables, text, next_text, fim.
    """
    artist = example["artist"]
    if variant == "one_hot":
        if example.get("fim"):
            system = FIM_SYSTEM
            user = "\n".join(
                [
                    f"<voice: {artist}>",
                    f"ABOVE: {example['prev_text']}",
                    f"BELOW: {example['next_text']}",
                    *_fields(example),
                ]
            )
        else:
            system = one_hot_system(artist)
            user = "\n".join(
                [
                    (
                        f"<voice: {artist}> <section: {example['section']}> "
                        f"<bar {example['line_seq']} of {example['total_lines']}>"
                    ),
                    f"PREV_BAR: {example['prev_text']}",
                    f"TOPIC: {example['topic']}",
                    *_fields(example),
                ]
            )
    elif variant == "systembrief":
        # The brief is the voice signal, so FIM rows keep it verbatim.
        # ABOVE/BELOW stay on the user turn, with no <voice:> token.
        system = brief_text(briefs or {}, artist)
        if example.get("fim"):
            user = "\n".join(
                [
                    f"ABOVE: {example['prev_text']}",
                    f"BELOW: {example['next_text']}",
                    *_fields(example),
                ]
            )
        else:
            user = "\n".join(
                [
                    (
                        f"<section: {example['section']}> "
                        f"<bar {example['line_seq']} of {example['total_lines']}>"
                    ),
                    f"PREV_BAR: {example['prev_text']}",
                    f"TOPIC: {example['topic']}",
                    *_fields(example),
                ]
            )
    else:
        raise ValueError(f"variant {variant!r} is not implemented")
    return {
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
            {"role": "assistant", "content": example["text"]},
        ]
    }
