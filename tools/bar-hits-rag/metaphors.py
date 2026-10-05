"""Metaphor prototypes ported from MetaphorPrototypeCatalog.swift + SimilarMeaning rubric."""

from __future__ import annotations

import re
from dataclasses import dataclass

WORD_RE = re.compile(r"[A-Za-z0-9']+")
STOP = {
    "a", "an", "the", "of", "to", "in", "on", "and", "or", "but", "for", "with", "at", "by",
    "as", "is", "it", "be", "we", "my", "me", "you", "i", "im", "i'm", "so", "if", "do", "no",
    "that", "this", "they", "he", "she", "was", "got", "get", "gon", "gonna", "uh", "yeah",
    "ya", "yo", "oh", "ay", "ayy", "just", "from", "out", "up", "down", "not", "dont", "don't",
}


@dataclass(frozen=True)
class Prototype:
    id: str
    label: str
    terms: frozenset[str]


PROTOTYPES: list[Prototype] = [
    Prototype("scarcity", "scarcity", frozenset(
        "broke empty bowl mill mills hungry starving fuel tank glass half low pockets owe debt ramen evict rent sputter dry last fumes nothing zero crumbs nickel".split()
    )),
    Prototype("luxury", "luxury", frozenset(
        "ice chain diamonds foreign penthouse jet champagne vvs patek rolls yacht marble mink cuban flooded bezel drip".split()
    )),
    Prototype("persistence", "persistence", frozenset(
        "climb grind engine round again survive hustle never quit push uphill marathon last stand fight".split()
    )),
    Prototype("aviation", "aviation", frozenset(
        "jet fuel plane runway altitude turbulence pilot wing fumes takeoff landing cabin cockpit airport flight clouds".split()
    )),
    Prototype("machinery", "machinery", frozenset(
        "machine engine gear sputter knock factory motor piston wrench bolt rust oil spark wire circuit".split()
    )),
    Prototype("weather", "weather", frozenset(
        "storm rain flood drought thunder cloud sun snow wind lightning hurricane fog cold heat".split()
    )),
    Prototype("vehicles", "vehicles", frozenset(
        "gas highway wheels whip coupe truck benz rari hellcat engine brake crash lane dash".split()
    )),
    Prototype("jewelry", "jewelry", frozenset(
        "ice stones bezel vvs diamond chain pendant tennis flooded sparkle blink shine grill".split()
    )),
    Prototype("appetite", "appetite", frozenset(
        "plate fridge hungry starving sip glass bowl crumb dinner food stomach appetite thirst".split()
    )),
    Prototype("time", "time", frozenset(
        "clock hourglass seconds time late early yesterday tomorrow aging young old minute hour".split()
    )),
    Prototype("family", "family", frozenset(
        "mama mom dad brother sister family son daughter blood kin home porch".split()
    )),
    Prototype("war", "war", frozenset(
        "war trench armor bullet soldier battle enemy opp slide gun drill vest ammo".split()
    )),
    Prototype("love", "love", frozenset(
        "love heart baby girl miss kiss faithful her passenger lonely together".split()
    )),
    Prototype("distance", "distance", frozenset(
        "leave gone left ghost ignore door silent away move distance fade".split()
    )),
    Prototype("loyalty", "loyalty", frozenset(
        "bro homie dawg gang family circle loyal ride block".split()
    )),
    Prototype("religion", "religion", frozenset(
        "pray heaven hell god devil angel church sin bless faith soul".split()
    )),
    Prototype("sports", "sports", frozenset(
        "quarter clock ring championship court field game score coach team win loss".split()
    )),
    Prototype("flex", "flex", frozenset(
        "money cash bands racks paid rich check bag count safe million stage drip".split()
    )),
]


def tokens(text: str) -> list[str]:
    return [t.lower() for t in WORD_RE.findall(text or "")]


def content_tokens(text: str) -> list[str]:
    return [t for t in tokens(text) if t not in STOP and len(t) >= 3]


def lexical_matches(text: str) -> list[tuple[Prototype, int]]:
    bag = set(tokens(text))
    scored: list[tuple[Prototype, int]] = []
    for proto in PROTOTYPES:
        n = len(bag & proto.terms)
        if n:
            scored.append((proto, n))
    scored.sort(key=lambda x: -x[1])
    return scored


def top_metaphor(text: str) -> Prototype | None:
    hits = lexical_matches(text)
    return hits[0][0] if hits else None


def metaphor_label(text: str) -> str:
    proto = top_metaphor(text)
    return proto.label if proto else ""


def imagery_words(text: str, limit: int = 4) -> list[str]:
    """Concrete steal-words: prototype terms in the line, then leftover content tokens."""
    seen: set[str] = set()
    out: list[str] = []
    bag = content_tokens(text)
    proto_terms = set()
    for proto, _ in lexical_matches(text):
        proto_terms |= proto.terms
    for tok in bag:
        if tok in proto_terms and tok not in seen:
            seen.add(tok)
            out.append(tok)
        if len(out) >= limit:
            return out
    for tok in bag:
        if tok not in seen:
            seen.add(tok)
            out.append(tok)
        if len(out) >= limit:
            break
    return out


def picture_overlap(query: str, line: str) -> tuple[str, int]:
    """Shared prototype + shared content tokens. 0 overlap means picture lane should skip."""
    q_hits = lexical_matches(query)
    if not q_hits:
        return "", 0
    q_proto = q_hits[0][0]
    l_bag = set(tokens(line))
    shared_terms = l_bag & q_proto.terms
    q_content = set(content_tokens(query))
    shared_content = q_content & set(content_tokens(line))
    # Same picture needs the prototype terms, not just any overlapping word.
    score = len(shared_terms) * 2 + len(shared_content)
    if not shared_terms:
        return "", 0
    return q_proto.label, score
