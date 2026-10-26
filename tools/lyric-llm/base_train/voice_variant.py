"""Voice-conditioning text for one training example.

one_hot puts the artist name in a short system line and the
`<voice: Artist>` token on the user turn. The system brief variant
is a later phase and is not rendered here.
"""

from __future__ import annotations

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


def render_messages(example: dict, variant: str) -> dict:
    """Return one OpenAI chat JSONL object.

    `example` keys: artist, section, line_seq, total_lines, prev_text,
    topic, end_word, syllables, text, next_text, fim.
    """
    if variant != "one_hot":
        raise ValueError(
            f"variant {variant!r} is not implemented. one_hot is the V2 variant."
        )
    artist = example["artist"]
    if example.get("fim"):
        system = FIM_SYSTEM
        user = "\n".join(
            [
                f"<voice: {artist}>",
                f"ABOVE: {example['prev_text']}",
                f"BELOW: {example['next_text']}",
                f"END_WORD: {example['end_word']}",
                f"SYLLABLES: {example['syllables']}",
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
                f"END_WORD: {example['end_word']}",
                f"SYLLABLES: {example['syllables']}",
            ]
        )
    return {
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
            {"role": "assistant", "content": example["text"]},
        ]
    }
