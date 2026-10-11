#!/usr/bin/env python3
"""
Review helper for Chat 7 manual review of notes-queue.jsonl.
Strictly fetches rows for model inspection and commits model-decided verdicts.
Does NOT perform any automatic or keyword-based classification.
"""

import sys
import json
import os
from datetime import datetime, timezone
from zoneinfo import ZoneInfo

ROOT = "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
QUEUE_PATH = os.path.join(ROOT, "docs/play-on-words/wordplay-index/notes-queue.jsonl")
INDEX_V2_PATH = os.path.join(ROOT, "docs/play-on-words/wordplay-index/index-v2.jsonl")
RECHECK_PATH = os.path.join(ROOT, "docs/play-on-words/confirmed-recheck/recheck.jsonl")
STATUS_PATH = os.path.join(ROOT, "docs/play-on-words/chat-status/chat-7.md")

TOTAL_UNREVIEWED_TARGET = 15614

def get_already_indexed():
    indexed = set()
    if os.path.exists(INDEX_V2_PATH):
        with open(INDEX_V2_PATH, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip():
                    try:
                        d = json.loads(line)
                        indexed.add((d["artist"], d["song"], d["bar"]))
                    except Exception:
                        pass
    return indexed

def fetch(limit=25):
    indexed = get_already_indexed()
    results = []
    with open(QUEUE_PATH, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f):
            if not line.strip():
                continue
            row = json.loads(line)
            if row.get("already_reviewed"):
                continue
            key = (row["artist"], row["song"], row["bar"])
            if key in indexed:
                continue
            
            results.append({
                "queue_index": idx,
                "artist": row["artist"],
                "song": row["song"],
                "bar": row["bar"],
                "note": row.get("note", ""),
                "guess_tab": row.get("guess_tab"),
                "guess_subtype": row.get("guess_subtype"),
                "matched_signals": row.get("matched_signals", []),
                "source_url": row.get("source_url"),
                "wired_chip": row.get("wired_chip"),
                "genius_fragment": row.get("genius_fragment"),
                "vault_lines": row.get("vault_lines", [])
            })
            if len(results) >= limit:
                break
    return results

def commit(decisions):
    now_iso = datetime.now(timezone.utc).isoformat()
    with open(INDEX_V2_PATH, "a", encoding="utf-8") as f_index, \
         open(RECHECK_PATH, "a", encoding="utf-8") as f_recheck:
        for d in decisions:
            # index-v2 row
            index_row = {
                "artist": d["artist"],
                "song": d["song"],
                "bar": d["bar"],
                "verdict": d["verdict"],
                "tab": d["tab"],
                "subtype": d["subtype"],
                "punchline_setup": d.get("punchline_setup", False),
                "setup_spans": d.get("setup_spans", []),
                "play_spans": d.get("play_spans", []),
                "heard_as": d.get("heard_as", ""),
                "partner_bars": d.get("partner_bars", []),
                "noun_chip": d.get("noun_chip"),
                "scope": "D",
                "reason": d["reason"],
                "source_url": d.get("source_url"),
                "by": "antigravity-reindex",
                "method": "manual",
                "ts": now_iso
            }
            f_index.write(json.dumps(index_row, ensure_ascii=False) + "\n")

            # recheck row
            recheck_row = {
                "key_artist": d["artist"],
                "key_song": d["song"],
                "key_bar": d["bar"],
                "verdict": d["verdict"],
                "tab": d["tab"],
                "wordplay_type": d["subtype"],
                "punchline_setup": d.get("punchline_setup", False),
                "setup_spans": d.get("setup_spans", []),
                "play_spans": d.get("play_spans", []),
                "heard_as": d.get("heard_as", ""),
                "reason": d["reason"],
                "source_url": d.get("source_url"),
                "by": "antigravity-recheck-v3",
                "ts": now_iso
            }
            f_recheck.write(json.dumps(recheck_row, ensure_ascii=False) + "\n")

    update_status()

def update_status():
    total_done = 0
    verdict_counts = {"KEEP": 0, "FIX": 0, "REJECT": 0}
    tab_counts = {"sound_flips": 0, "double_meanings": 0, "split_names": 0, "hidden_references": 0, "none": 0}
    punchline_count = 0
    example_keeps = []

    if os.path.exists(INDEX_V2_PATH):
        with open(INDEX_V2_PATH, "r", encoding="utf-8") as f:
            for line in f:
                if not line.strip():
                    continue
                d = json.loads(line)
                total_done += 1
                v = d.get("verdict", "REJECT")
                verdict_counts[v] = verdict_counts.get(v, 0) + 1
                tab = d.get("tab", "none")
                tab_counts[tab] = tab_counts.get(tab, 0) + 1
                if d.get("punchline_setup"):
                    punchline_count += 1
                if v in ("KEEP", "FIX"):
                    example_keeps.append(d)

    # 3 example keeps (most recent)
    recent_keeps = example_keeps[-3:] if len(example_keeps) >= 3 else example_keeps

    et_now = datetime.now(ZoneInfo("America/New_York")).strftime("%Y-%m-%d %H:%M ET")

    examples_str = ""
    if recent_keeps:
        for idx, ek in enumerate(reversed(recent_keeps), 1):
            examples_str += f"{idx}. **{ek['artist']}** – *{ek['song']}*: \"{ek['bar']}\" ({ek['tab']} / {ek['subtype']}) -> {ek.get('heard_as')}\n"
    else:
        examples_str = "None yet.\n"

    status_content = f"""# Chat 7 · Wordplay Index v2 (Manual Review)
updated: {et_now}
state: running
doing: manual review of notes-queue.jsonl (reading each line & Genius note)
progress: {total_done} / {TOTAL_UNREVIEWED_TARGET} done ({verdict_counts.get('KEEP',0)} KEEP, {verdict_counts.get('FIX',0)} FIX, {verdict_counts.get('REJECT',0)} REJECT)
tabs: sound_flips={tab_counts.get('sound_flips',0)}, double_meanings={tab_counts.get('double_meanings',0)}, split_names={tab_counts.get('split_names',0)}, hidden_references={tab_counts.get('hidden_references',0)}, none={tab_counts.get('none',0)}
punchline_setups: {punchline_count}
example_keeps:
{examples_str}problems: none
needs Samuel: no
"""

    tmp_path = STATUS_PATH + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        f.write(status_content)
    os.replace(tmp_path, STATUS_PATH)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "fetch":
        limit = int(sys.argv[2]) if len(sys.argv) > 2 else 25
        rows = fetch(limit)
        print(json.dumps(rows, ensure_ascii=False, indent=2))
    elif len(sys.argv) > 1 and sys.argv[1] == "commit":
        decisions_file = sys.argv[2]
        with open(decisions_file, "r", encoding="utf-8") as f:
            decisions = json.load(f)
        commit(decisions)
        print(f"Committed {len(decisions)} decisions and updated status.")
    elif len(sys.argv) > 1 and sys.argv[1] == "status":
        update_status()
        print("Updated status.")
