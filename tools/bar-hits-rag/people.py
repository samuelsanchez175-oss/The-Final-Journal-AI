"""Numbered Work Studios people. Collabs are two (or more) individuals, not a third artist."""

from __future__ import annotations

import re

# Roster order from Work Studios vault 🎤 Artists/People
PEOPLE: list[tuple[int, str]] = [
    (1, "Gunna"),
    (2, "Young Thug"),
    (3, "Lil Baby"),
    (4, "Young Stoner Life"),
    (5, "Future"),
    (6, "Lil Duke"),
    (7, "Yak Gotti"),
    (8, "Kodak Black"),
    (9, "NAV"),
    (10, "YTB Trench"),
    (11, "Don Toliver"),
    (12, "Drake"),
    (13, "Sheck Wes"),
    (14, "Travis Scott"),
    (15, "Lil Keed"),
    (16, "YNW Melly"),
    (17, "Lil Uzi Vert"),
    (18, "T-Shyne"),
    (19, "Karlae"),
    (20, "Offset"),
    (21, "FN DaDealer"),
    (22, "Meek Mill"),
    (23, "Wizkid"),
    (24, "BSlime"),
    (25, "Quavo"),
    (26, "Yung Kayo"),
    (27, "Doe Boy"),
    (28, "Lil Juice"),
    (29, "21 Savage"),
    (30, "Yung Bleu"),
    (31, "Lil Durk"),
    (32, "Rowdy Rebel"),
    (33, "Strick"),
    (34, "Unfoonk"),
    (35, "Chlöe"),
    (36, "Skepta"),
    (37, "Dolly White"),
    (38, "Playboi Carti"),
    (39, "24Heavy"),
    (40, "Internet Money"),
    (41, "Leon Bridges"),
]

_BY_LOWER = {name.lower(): (num, name) for num, name in PEOPLE}
_SPLIT = re.compile(r"\s*(?:,|&| with | and )\s*", re.I)


def pad(n: int) -> str:
    return f"{n:02d}"


def label(num: int, name: str) -> str:
    return f"{pad(num)} {name}"


def split_names(credit: str) -> list[str]:
    parts = _SPLIT.split(credit or "")
    out: list[str] = []
    seen: set[str] = set()
    for raw in parts:
        p = re.sub(r"\s+", " ", raw).strip(" .")
        p = p.strip("*() ")
        if not p or p.lower() in {"both", "and", "the"}:
            continue
        key = p.lower()
        if key not in seen:
            seen.add(key)
            out.append(p)
    return out


def resolve_people(credit: str) -> list[dict]:
    """Map a CSV artist credit onto numbered people. Unknown names keep number 0."""
    found: list[dict] = []
    seen: set[str] = set()
    for name in split_names(credit):
        hit = _BY_LOWER.get(name.lower())
        if hit:
            num, canon = hit
            key = canon.lower()
            if key in seen:
                continue
            seen.add(key)
            found.append({"number": num, "name": canon, "id": label(num, canon)})
        else:
            key = name.lower()
            if key in seen:
                continue
            seen.add(key)
            found.append({"number": 0, "name": name, "id": name})
    found.sort(key=lambda p: (p["number"] == 0, p["number"], p["name"]))
    return found


def people_phrase(credit: str) -> str:
    people = resolve_people(credit)
    if not people:
        return (credit or "").strip()
    return " and ".join(p["id"] for p in people)


def artist_ids(credit: str) -> list[str]:
    return [p["id"] for p in resolve_people(credit)]
