#!/usr/bin/env python3
"""Wire a batch of wordplay chips into the Noun Bank.

usage: wire_batch.py spec.json [--remove chip,chip]
spec.json: list of {chip, asset, partners:[a,b], what, artist, song, bar, setup_spans, play_spans,
                    heardAs, url, sourceLine, decision}
Caller must back up first. Appends to Store, Sections, Catalog (partner table + wordplayPictureIcons
only), Brief, Tests, WordplayFlips.json, log, ledger, queue.
"""
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
S = ROOT / "XJournal AI"
STORE, SECT, CAT, BRIEF = (S / n for n in ("NounBankStore.swift", "NounBankSections.swift", "NounBankCatalog.swift", "NounMentionBrief.swift"))
TEST = ROOT / "The Final Journal AITests/NounBankSheetTests.swift"
FLIPS = S / "WordplayFlips.json"
DOCS = ROOT / "docs/play-on-words"


def q(s):  # swift string literal
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def norm(w):  # mirror NounBankMark.normalize
    w = w.lower().replace("\u2019", "").replace("'", "").replace(".", "").replace("-", " ").replace("/", " ")
    return " ".join(w.split())


def insert_before(text, closer, lines, indent):
    i = text.index(closer)
    head = text[:i].rstrip("\n")
    if not head.rstrip().endswith(",") and not head.rstrip().endswith("["):
        head += ","
    body = ",\n".join(indent + l for l in lines)
    return head + "\n" + body + text[i:]


def drop_in_range(text, start_marker, end_marker, needle):
    a = text.index(start_marker)
    b = text.index(end_marker, a)
    seg = text[a:b]
    lines = seg.split("\n")
    out = [l for l in lines if needle not in l]
    assert len(out) == len(lines) - 1, (needle, len(lines) - len(out))
    return text[:a] + "\n".join(out) + text[b:]


def main():
    spec = json.load(open(sys.argv[1]))
    remove = []
    if "--remove" in sys.argv:
        remove = sys.argv[sys.argv.index("--remove") + 1].split(",")
    store = STORE.read_text(); sect = SECT.read_text(); cat = CAT.read_text()
    brief = BRIEF.read_text(); test = TEST.read_text()
    store_l = store.lower()

    for r in remove:  # unwire chips by exact chip name
        store = drop_in_range(store, "case .wordplay:", "case .phrases:", q(r))
        sect = drop_in_range(sect, "case .wordplay:", "case .phrases:", q(r))
        k = norm(r)
        cat = drop_in_range(cat, "mentionPartnerTable: [String: [String]] = [", "mentionExclusionTable", f'"{k}": [')
        cat = drop_in_range(cat, "wordplayPictureIcons", "static func iconName", f'"{k}": ')
        brief = drop_in_range(brief, "private static let wordplay:", "private static func threshold", f'"{k}": ')
        test = drop_in_range(test, "func testPlayOnWordsStayOneSenseAndOffTheOtherTabs", "func test", q(r))
        t = test
        for old in [f'            ("{r}", ']:
            pass
        # plays dict + reusedChips lines
        test = "\n".join(l for l in test.split("\n") if not (l.strip().startswith(q(r) + ":") and "said beside" in l)
                         and not l.strip().startswith("(" + q(r) + ", "))
        flips = [f for f in json.load(open(FLIPS)) if f["chip"] != r]
        json.dump(flips, open(FLIPS, "w"), indent=2, ensure_ascii=False)

    shared = []
    for e in spec:
        c = e["chip"]
        if f'"{c.lower()}"' in store_l:
            shared.append(norm(c) if False else c.lower())
    store = insert_before(store, "\n            ])\n        case .phrases:", [q(e["chip"]) for e in spec], " " * 16)
    sect = insert_before(sect, "\n                ]),\n            ]\n        case .phrases:", [q(e["chip"]) for e in spec], " " * 20)
    cat = insert_before(cat, "\n    ]\n\n    private static let mentionExclusionTable",
                        [f'{q(norm(e["chip"]))}: [{q(e["partners"][0])}, {q(e["partners"][1])}]' for e in spec], " " * 8)
    cat = insert_before(cat, "\n    ]\n\n    static func iconName",
                        [f'{q(norm(e["chip"]))}: {q(e["asset"])}' for e in spec], " " * 8)
    for e in spec:
        e["line"] = f'{e["chip"]} is {e["what"]}, said beside {e["partners"][0]} and {e["partners"][1]}.'
    brief = insert_before(brief, "\n    ]\n\n    private static func threshold",
                          [f'{q(norm(e["chip"]))}: {q(e["line"])}' for e in spec], " " * 8)
    test = insert_before(test, "\n        ])\n        let others = NounBankCategory.allCases", [q(e["chip"]) for e in spec], " " * 12)
    test = insert_before(test, "\n        ]\n        XCTAssertEqual(Set(plays.keys), Set(words))",
                         [f'{q(e["chip"])}: {q(e["line"])}' for e in spec], " " * 12)
    test = insert_before(test, "\n        ]\n        for item in reusedChips",
                         [f'({q(e["chip"])}, {q(e["asset"])})' for e in spec], " " * 12)
    if shared:
        test = insert_before(test, "\n        ]\n        for word in words where !sharedHeardAs",
                             [", ".join(q(s) for s in shared)], " " * 12)
    STORE.write_text(store); SECT.write_text(sect); CAT.write_text(cat); BRIEF.write_text(brief); TEST.write_text(test)

    flips = json.load(open(FLIPS))
    for e in spec:
        flips.append({"chip": e["chip"], "artist": e["artist"], "song": e["song"], "bar": e["bar"],
                      "setupSpans": e.get("setup_spans", []), "playSpans": e.get("play_spans", []),
                      "heardAs": e["heardAs"], "geniusURL": e.get("url", ""), "image": e["asset"],
                      "imageDecision": e.get("decision", "created"), "sourceLine": e.get("sourceLine", 0)})
    json.dump(flips, open(FLIPS, "w"), indent=2, ensure_ascii=False)

    batch = spec[0].get("batch", 0)
    with open(DOCS / "wordplay-wiring-log.jsonl", "a") as f:
        for r in remove:
            f.write(json.dumps({"ts": spec[0].get("ts", ""), "batch": batch, "noun": r, "decision": "unwired_rejected"}) + "\n")
        for e in spec:
            f.write(json.dumps({"ts": e.get("ts", ""), "batch": batch, "noun": e["chip"], "sections": ["Play on Words"] + (["(also) shared"] if e["chip"].lower() in shared else []),
                                "image": e["asset"], "decision": e.get("decision", "created"), "artist": e["artist"], "song": e["song"],
                                "bar": e["bar"], "url": e.get("url", ""), "note": e.get("note", "")}) + "\n")
    with open(DOCS / "picture-ledger.tsv", "a") as f:
        for e in spec:
            f.write(f'{e["chip"]}\t\tPhonetic\t{e["chip"]}\t{e["chip"]}\t{e["asset"]}\tyes\tyes\t{e["asset"]}\t{e.get("decision","created")}\tno\tno\t\t\t\t\twired: {e["chip"]} {e.get("decision","created")} {e["asset"]}\twired\n')
    with open(DOCS / "picture-ledger.md", "a") as f:
        f.write(f"\n## Wordplay wiring Batch {batch}\n\n| Heard word | Asset | Decision |\n|---|---|---|\n")
        for e in spec:
            f.write(f'| {e["chip"]} | {e["asset"]} | {e.get("decision","created")} |\n')
    qp = DOCS / "wordplay-image-queue.md"
    done = {e["chip"].lower() for e in spec}
    lines = qp.read_text().split("\n")
    kept, finished = [], []
    for l in lines:
        m = re.match(r"\| ([^|]+?) \|", l)
        if m and m.group(1).lower() in done and "Completed" not in l:
            finished.append(l)
        else:
            kept.append(l)
    txt = "\n".join(kept).rstrip("\n") + "\n"
    if finished:
        assets = {e["chip"].lower(): e["asset"] for e in spec}
        if "## Completed Chips" not in txt:
            txt += "\n## Completed Chips\n\n| Noun | Artist - Song | Bar | Suggested Subject | Asset Created |\n|---|---|---|---|---|\n"
        for l in finished:
            p = [x.strip() for x in l.split("|")[1:-1]]
            txt += f"| {p[0]} | {p[1]} | {p[2]} | {p[3]} | {assets[p[0].lower()]} (Batch {batch}) |\n"
    qp.write_text(txt)
    print("wired", len(spec), "removed", remove, "shared", shared)


main()
