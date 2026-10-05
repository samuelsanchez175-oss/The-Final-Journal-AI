#!/usr/bin/env python3
"""Build (if needed) the bench catalog, run gold queries, write HTML scorecard.

Usage:
  python3 tools/bar-hits-rag/run_scorecard.py
  python3 tools/bar-hits-rag/run_scorecard.py --rebuild
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
VAULT_CSV = Path(
    "/Users/samuel/Library/Mobile Documents/iCloud~md~obsidian/Documents/"
    "Work Studios vault/🧠 Penwork Studios - Model G/corpus/ground_truth_rap_bars_MODEL_G.csv"
)
APP_CSV = REPO / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
CMUDICT = REPO / "XJournal AI" / "cmudict.txt"
OUT = ROOT / "out"
SQLITE = OUT / "bench.sqlite"
GOLD = ROOT / "gold.json"

sys.path.insert(0, str(ROOT))

from annotate import annotate_bundle  # noqa: E402
from catalog import connect, ingest  # noqa: E402
from report import card_html, hit_dict, render, write_json  # noqa: E402
from generate import generate_pair  # noqa: E402
from retrieve import Hit, retrieve  # noqa: E402
from rhyme import load_cmudict  # noqa: E402


def hit_from_dict(d: dict) -> Hit:
    return Hit(
        id=d.get("id") or "",
        line=d.get("line") or "",
        artist=d.get("artist") or "",
        song=d.get("song") or "",
        syllables=int(d.get("syllables") or 0),
        end_word=d.get("end_word") or d.get("end") or "",
        phonetic_class=d.get("phonetic_class") or "",
        destressed_class=d.get("destressed_class") or "",
        people=d.get("people") or "",
        artist_ids=d.get("artist_ids") or [],
        person_n=int(d.get("person_n") or 0),
        lane=d.get("lane") or "",
        window=d.get("window") or "",
        rhyme=d.get("rhyme"),
        rhyme_pair=d.get("rhyme_pair") or d.get("pair") or "",
        metaphor=d.get("metaphor") or "",
        imagery=d.get("imagery") or [],
        score=float(d.get("score") or 0),
        why=d.get("why") or "",
        stress_words=d.get("stress_words") or d.get("stress") or [],
        stress_score=int(d.get("stress_score") or 0),
        stress_note=d.get("stress_note") or "",
        inner_score=int(d.get("inner_score") or 0),
        wrap_delta=int(d.get("wrap_delta") or 0),
        spans=d.get("spans") or [],
    )


def default_csv() -> Path:
    if VAULT_CSV.exists():
        return VAULT_CSV
    return APP_CSV


def lines_of(hits) -> list[str]:
    return [h.line for h in hits]


def ends_of(hits) -> list[str]:
    return [h.end_word for h in hits]


def eval_card(gold: dict, bundle: dict) -> list[str]:
    """Return fail strings (empty = pass)."""
    fails: list[str] = []
    wrap = bundle.get("wrap") or []
    replace = bundle.get("replace") or []
    nxt = bundle.get("next") or []
    nearby = bundle.get("nearby") or []
    picture = bundle.get("picture") or []
    all_hits = wrap + nearby + picture
    wrap_lines = lines_of(replace + nxt)
    wrap_ends = ends_of(replace + nxt + nearby)
    q = bundle["query"]

    for needle in gold.get("must_include_lines") or []:
        if not any(needle.lower() in (ln or "").lower() for ln in wrap_lines):
            fails.append(f"wrap missing line `{needle}`")
    for end in gold.get("must_include_ends") or []:
        if end.lower() not in {e.lower() for e in wrap_ends} | {e.lower() for e in ends_of(nearby)}:
            fails.append(f"wrap/nearby missing end `{end}`")
    blob = "\n".join(h.line for h in all_hits)
    for bad in gold.get("must_exclude_substrings") or []:
        if bad.lower() in blob.lower():
            fails.append(f"junk leaked `{bad}`")
    pic_blob = "\n".join(lines_of(picture))
    for bad in gold.get("picture_must_not_include") or []:
        if bad.lower() in pic_blob.lower():
            fails.append(f"picture trap `{bad}`")
    people = q.get("people") or ""
    for token in gold.get("expect_people_contains") or []:
        if token not in people and not any(token in (h.people or "") for h in wrap[:3]):
            # IN people should carry it when artist is set
            if token not in people:
                fails.append(f"people missing `{token}` (got `{people}`)")
    banned = gold.get("must_not_people_exact")
    if banned and people.strip() == banned:
        fails.append(f"people still merged as `{banned}`")
    expect_rhyme = gold.get("expect_rhyme") or {}
    for word, kind in expect_rhyme.items():
        found = False
        for h in wrap:
            if (h.end_word or "").lower() == word.lower() and h.rhyme == kind:
                found = True
                break
        if not found:
            fails.append(f"rhyme `{word}` not tagged {kind} in wrap")
    return fails


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", type=Path, default=default_csv())
    parser.add_argument("--sqlite", type=Path, default=SQLITE)
    parser.add_argument("--cmudict", type=Path, default=CMUDICT)
    parser.add_argument("--gold", type=Path, default=GOLD)
    parser.add_argument("--rebuild", action="store_true")
    parser.add_argument("--html-only", action="store_true", help="Rebuild HTML from out/scorecard.json")
    parser.add_argument("--limit", type=int, default=None)
    args = parser.parse_args()

    OUT.mkdir(parents=True, exist_ok=True)
    if args.html_only:
        stored = json.loads((OUT / "scorecard.json").read_text(encoding="utf-8"))
        gold_by = {q["id"]: q for q in json.loads(args.gold.read_text(encoding="utf-8"))["queries"]}
        cards_html = []
        for card in stored.get("cards") or []:
            bundle = {
                "query": card.get("query") or {},
                "replace": [hit_from_dict(h) for h in card.get("replace") or []],
                "next": [hit_from_dict(h) for h in card.get("next") or []],
                "gen_replace": [hit_from_dict(h) for h in card.get("gen_replace") or []],
                "gen_next": [hit_from_dict(h) for h in card.get("gen_next") or []],
            }
            cards_html.append(card_html(card["id"], gold_by.get(card["id"]) or {}, bundle, ""))
        html_path = OUT / "scorecard.html"
        html_path.write_text(render(cards_html, stored.get("summary") or ""), encoding="utf-8")
        print(f"wrote {html_path}")
        return 0

    if args.rebuild or not args.sqlite.exists():
        if not args.csv.exists():
            print(f"csv missing: {args.csv}", file=sys.stderr)
            return 1
        print(f"ingest {args.csv} → {args.sqlite}", file=sys.stderr)
        stats = ingest(args.csv, args.sqlite, args.cmudict, args.limit)
        print(f"kept {stats['kept']:,}  skipped {stats['skipped']:,}", file=sys.stderr)
    else:
        print(f"using {args.sqlite}", file=sys.stderr)

    gold = json.loads(args.gold.read_text(encoding="utf-8"))
    cmu = load_cmudict(args.cmudict)
    con = connect(args.sqlite)

    cards_html: list[str] = []
    payload = []
    wrap_gold = 0
    wrap_pass = 0
    rhyme_gold = 0
    rhyme_pass = 0
    collab_gold = 0
    collab_pass = 0
    junk_gold = 0
    junk_pass = 0

    for q in gold["queries"]:
        bundle = retrieve(
            con,
            q["line"],
            int(q["syllables"]),
            cmu,
            query_artist=q.get("artist") or "",
        )
        donors = list(bundle.get("replace") or []) + list(bundle.get("next") or [])
        gr, gn = generate_pair(q["line"], int(q["syllables"]), cmu, donors)
        bundle["gen_replace"] = gr
        bundle["gen_next"] = gn
        bundle = annotate_bundle(bundle)
        fails = eval_card(q, bundle)
        note = "PASS" if not fails else "FAIL: " + "; ".join(fails)
        cards_html.append(card_html(q["id"], q, bundle, note))
        payload.append(
            {
                "id": q["id"],
                "query": bundle["query"],
                "replace": [hit_dict(h) for h in bundle.get("replace") or []],
                "next": [hit_dict(h) for h in bundle.get("next") or []],
                "wrap": [hit_dict(h) for h in bundle["wrap"]],
                "nearby": [hit_dict(h) for h in bundle["nearby"]],
                "picture": [hit_dict(h) for h in bundle["picture"]],
                "roster": [hit_dict(h) for h in bundle.get("roster") or []],
                "gen_replace": [hit_dict(h) for h in bundle.get("gen_replace") or []],
                "gen_next": [hit_dict(h) for h in bundle.get("gen_next") or []],
                "fails": fails,
            }
        )
        if q.get("must_include_lines") or q.get("must_include_ends"):
            wrap_gold += 1
            if not any(f.startswith("wrap") for f in fails):
                wrap_pass += 1
        if q.get("expect_rhyme"):
            rhyme_gold += 1
            if not any(f.startswith("rhyme") for f in fails):
                rhyme_pass += 1
        if q.get("expect_people_contains") and len(q.get("expect_people_contains") or []) >= 2:
            collab_gold += 1
            if not any("people" in f or "merged" in f for f in fails):
                collab_pass += 1
        if q.get("must_exclude_substrings"):
            junk_gold += 1
            if not any(f.startswith("junk") for f in fails):
                junk_pass += 1

    con.close()

    def frac(a, b) -> str:
        if not b:
            return "n/a"
        return f"{a}/{b} ({100 * a / b:.0f}%)"

    summary = (
        f"wrap {frac(wrap_pass, wrap_gold)} · "
        f"rhyme {frac(rhyme_pass, rhyme_gold)} · "
        f"collab people {frac(collab_pass, collab_gold)} · "
        f"junk {frac(junk_pass, junk_gold)}"
    )
    html_path = OUT / "scorecard.html"
    json_path = OUT / "scorecard.json"
    html_path.write_text(render(cards_html, summary), encoding="utf-8")
    write_json(json_path, {"summary": summary, "cards": payload})
    print(summary)
    print(f"wrote {html_path}")
    print(f"wrote {json_path}")
    # Gate: wrap ≥ 70% of wrap-gold queries (plan: ≥7/10)
    wrap_ok = wrap_gold == 0 or (wrap_pass / wrap_gold) >= 0.7
    junk_ok = junk_gold == 0 or junk_pass == junk_gold
    collab_ok = collab_gold == 0 or collab_pass == collab_gold
    return 0 if wrap_ok and junk_ok and collab_ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
