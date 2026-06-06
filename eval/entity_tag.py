"""Entity tagging for rap lyrics — rappers, producers, labels, and drugs, with disambiguation.

Picks up the small nuances: "Slime" -> Young Thug/YSL, "Uzi" -> Lil Uzi Vert (but also gun /
jewelry — flagged POLYSEMY), regional drug aliases ("wock"/"dirty sprite" -> lean). Feeds the
LLM-judge's cultural-truth check and (later) the grader's specificity axis.

    python3 eval/entity_tag.py                 # tag the bundled example verses
    python3 eval/entity_tag.py --verse FILE    # tag one file
"""
import os, re, csv, sys, argparse

WORD = re.compile(r"[a-z0-9']+")
BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lexicons")


def _load():
    """alias(lowercased) -> {canonical, kind, polysemy, note}. Single- and multi-word."""
    table = {}
    def add(alias, canonical, kind, note):
        a = re.sub(r"\s+", " ", alias.strip().lower())
        if len(a) < 2:
            return
        table.setdefault(a, {"canonical": canonical, "kind": kind,
                             "polysemy": note.upper().startswith("POLYSEMY"), "note": note})
    rp = os.path.join(BASE, "rapper_lexicon.csv")
    if os.path.exists(rp):
        for r in csv.DictReader(open(rp, encoding="utf-8")):
            kind = r.get("type", "rapper")
            for alias in [r["term"]] + r.get("aliases", "").split(";"):
                if alias.strip():
                    add(alias, r.get("canonical", r["term"]), kind, r.get("codes_note", ""))
    dp = os.path.join(BASE, "drug_lexicon.csv")
    if os.path.exists(dp):
        for r in csv.DictReader(open(dp, encoding="utf-8")):
            for alias in [r["canonical"]] + r.get("aliases", "").split(";"):
                if alias.strip():
                    add(alias, r["canonical"], "drug:" + r.get("class", ""), r.get("note", ""))
    singles = {k: v for k, v in table.items() if " " not in k}
    multis = sorted([k for k in table if " " in k], key=len, reverse=True)
    return table, singles, multis


_TABLE, _SINGLES, _MULTIS = _load()


def tag_entities(text):
    """Return list of (surface, canonical, kind, polysemy) hits in `text`."""
    low = text.lower()
    hits, seen = [], set()
    for m in _MULTIS:                                  # multi-word aliases first
        if m in low and m not in seen:
            e = _TABLE[m]; hits.append((m, e["canonical"], e["kind"], e["polysemy"])); seen.add(m)
    for w in WORD.findall(low):                        # then single tokens
        if w in _SINGLES and w not in seen:
            e = _SINGLES[w]; hits.append((w, e["canonical"], e["kind"], e["polysemy"])); seen.add(w)
    return hits


def _report(name, lines):
    hits = tag_entities("\n".join(lines))
    print(f"\n=== {name} ===")
    if not hits:
        print("  (no entities)"); return
    for surface, canon, kind, poly in hits:
        tag = f"{surface!r} -> {canon} [{kind}]"
        if poly:
            tag += "  ⚠ POLYSEMY — disambiguate by context"
        print("  " + tag)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Tag rappers / producers / labels / drugs in lyrics")
    ap.add_argument("--verse", help="verse file to tag (default: bundled examples)")
    a = ap.parse_args()
    print(f"loaded {len(_TABLE)} aliases ({sum(1 for v in _TABLE.values() if v['polysemy'])} polysemous)")
    if a.verse:
        _report(os.path.basename(a.verse), [l.strip() for l in open(a.verse, encoding="utf-8") if l.strip()])
    else:
        ex = [("Verse2 Royce/slime", "verse2"), ("Verse3 Go Get It", "verse3"),
              ("Chorus Go Get It", "chorus"), ("Verse Lil Baby", "verse4"), ("Verse Kendrick", "verse5")]
        for nm, f in ex:
            p = f"/tmp/ablation/{f}.txt"
            if os.path.exists(p):
                _report(nm, [l.strip() for l in open(p, encoding="utf-8") if l.strip()])
