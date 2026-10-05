#!/usr/bin/env python3
"""Model You-fit grader. Identity target is the artist fixture, not the Gunna CSV."""
import argparse
import csv
import datetime
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_FIXTURE = os.path.join(HERE, "you_golden", "artist_fixture.json")
LOG_PATH = os.path.join(HERE, "you_grading_log.csv")
HOUSE = ["gunna", "wunna", "young thug", "thugger", "lil baby", "roley", "atlanta"]
FRAGMENTS = {
    "the", "a", "an", "and", "or", "to", "of", "in", "on", "my", "i", "you", "it",
    "we", "they", "that", "this", "with", "from", "for",
}


def tokens(text):
    return {
        t for t in re.findall(r"[a-z0-9]+", text.lower())
        if len(t) >= 3 and t not in FRAGMENTS
    }


def end_word(line):
    parts = re.findall(r"[a-z0-9]+", line.lower())
    return parts[-1] if parts else ""


def load_fixture(path):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    data.setdefault("neverUse", [])
    data.setdefault("bars", [])
    data.setdefault("punch", [])
    data.setdefault("houseNouns", HOUSE)
    return data


def load_verse(path):
    with open(path, encoding="utf-8") as f:
        return [ln.strip() for ln in f if ln.strip()]


def score_verse(lines, fixture):
    verse = "\n".join(lines)
    verse_tok = tokens(verse)
    catalog_tok = tokens(" ".join(fixture["bars"]))
    never = [t.lower() for t in fixture["neverUse"] if t.strip()]
    never_hits = sum(1 for t in never if t in verse.lower())
    grief = 0
    house = [t.lower() for t in fixture["houseNouns"]]
    house_hits = sum(1 for t in house if t in verse.lower() and t not in catalog_tok)
    punch = [t.lower() for t in fixture["punch"]]
    used_punch = [t for t in punch if t in verse_tok]
    ends = {end_word(ln) for ln in lines}
    punch_demoted = bool(used_punch) and not any(t in ends for t in used_punch)

    wrap = 70.0
    if fixture["bars"] and lines:
        cat_len = {len(tokens(b)) for b in fixture["bars"]}
        hits = sum(1 for ln in lines if any(abs(len(tokens(ln)) - c) <= 2 for c in cat_len))
        wrap = 100.0 * hits / max(1, len(lines))
    endings = 70.0
    cat_ends = {end_word(b) for b in fixture["bars"] if end_word(b)}
    if cat_ends and lines:
        hits = sum(1 for ln in lines if end_word(ln) in cat_ends)
        endings = 100.0 * hits / max(1, len(lines))
    lexicon = 70.0
    if catalog_tok and verse_tok:
        lexicon = 100.0 * len(verse_tok & catalog_tok) / len(verse_tok | catalog_tok)
    punch_score = 70.0
    if punch:
        if punch_demoted:
            punch_score = 0.0
        elif used_punch:
            punch_score = 100.0
    house_pen = min(100.0, house_hits * 25.0)
    total = 0.25 * wrap + 0.20 * endings + 0.25 * lexicon + 0.15 * punch_score + 0.15 * (100 - house_pen)
    if never_hits or grief or punch_demoted:
        total = 0.0
    band = "ship" if total >= 80 else "passable" if total >= 70 else "needs work"
    return {
        "total": round(total, 1),
        "wrap": round(wrap, 1),
        "endings": round(endings, 1),
        "lexicon": round(lexicon, 1),
        "punch": round(punch_score, 1),
        "housePenalty": round(house_pen, 1),
        "neverUseHits": never_hits,
        "punchDemoted": punch_demoted,
        "band": band,
    }


def print_score(name, scored):
    print(f"{name}: You-fit {scored['total']} ({scored['band']})")
    print(
        f"  wrap {scored['wrap']}  endings {scored['endings']}  "
        f"lexicon {scored['lexicon']}  punch {scored['punch']}  "
        f"house -{scored['housePenalty']}  neverUse {scored['neverUseHits']}"
    )


def append_log(label, scored):
    new = not os.path.exists(LOG_PATH)
    with open(LOG_PATH, "a", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        if new:
            w.writerow(["timestamp", "label", "total", "band", "neverUseHits", "punchDemoted"])
        w.writerow([
            datetime.datetime.now().isoformat(timespec="seconds"),
            label,
            scored["total"],
            scored["band"],
            scored["neverUseHits"],
            int(scored["punchDemoted"]),
        ])


def demo(fixture):
    teacher = [
        "Wunna Wunna, they workin my nerves",
        "I hop out a 911 in Atlanta",
        "Roley on the wrist, that's a flex",
    ]
    matched = [
        "The city hums in flesh and bone",
        "I pour a cup of henny",
    ]
    print_score("teacher-G", score_verse(teacher, fixture))
    print_score("fixture-matched", score_verse(matched, fixture))


def main():
    p = argparse.ArgumentParser(description="Grade Model You-fit against an artist fixture")
    p.add_argument("--demo", action="store_true")
    p.add_argument("--verse")
    p.add_argument("--fixture", default=DEFAULT_FIXTURE)
    p.add_argument("--compare", nargs=2, metavar=("G_TXT", "YOU_TXT"))
    p.add_argument("--log", action="store_true")
    args = p.parse_args()
    fixture = load_fixture(args.fixture)
    if args.demo:
        demo(fixture)
        return
    if args.compare:
        g = score_verse(load_verse(args.compare[0]), fixture)
        y = score_verse(load_verse(args.compare[1]), fixture)
        print_score(os.path.basename(args.compare[0]), g)
        print_score(os.path.basename(args.compare[1]), y)
        if args.log:
            append_log(os.path.basename(args.compare[0]), g)
            append_log(os.path.basename(args.compare[1]), y)
        return
    if args.verse:
        scored = score_verse(load_verse(args.verse), fixture)
        print_score(os.path.basename(args.verse), scored)
        if args.log:
            append_log(os.path.basename(args.verse), scored)
        return
    p.print_help()
    sys.exit(1)


if __name__ == "__main__":
    main()
