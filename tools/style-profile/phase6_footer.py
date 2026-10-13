#!/usr/bin/env python3
"""AI Sparkler Phase 6: render footer UI with blocks, catalog bars, and vote buttons.

Generates HTML footer for a generation showing:
- Each block used (category, definition if available)
- Catalog bars referenced
- Vote buttons (👍👎 on bar, on blocks)
- Reason tags (off_topic, bad_rhyme, off_flow, too_copied, cringe)

Usage:
  python3 tools/style-profile/phase6_footer.py <generation_id> [--db path/to/feedback.db]
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from pathlib import Path
from collections import Counter

sys.path.insert(0, str(Path(__file__).resolve().parent))
import feedback_store

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

REASONS = ["off_topic", "bad_rhyme", "off_flow", "too_copied", "cringe"]


def load_blocks_catalog(path: Path = OUT / "blocks_catalog.jsonl") -> dict[str, dict]:
    """Load blocks by norm for definitions."""
    by_norm = {}
    for line in open(path, encoding="utf-8"):
        r = json.loads(line)
        if r["norm"] not in by_norm:
            by_norm[r["norm"]] = r
    return by_norm


def get_generation_data(db: sqlite3.Connection, generation_id: str) -> dict:
    """Fetch generation, bars, sources, and votes."""
    gen = db.execute(
        "SELECT artist, created_at, model, prompt_version FROM generations WHERE id=?",
        (generation_id,)
    ).fetchone()
    if not gen:
        return None

    bars = db.execute(
        "SELECT id, bar_index, text, topic FROM generation_bars WHERE generation_id=? ORDER BY bar_index",
        (generation_id,)
    ).fetchall()

    result = {
        "generation_id": generation_id,
        "artist": gen[0],
        "created_at": gen[1],
        "model": gen[2],
        "prompt_version": gen[3],
        "bars": []
    }

    for bar_id, idx, text, topic in bars:
        sources = db.execute(
            "SELECT kind, ref, category FROM bar_sources WHERE bar_id=?",
            (bar_id,)
        ).fetchall()

        votes = db.execute(
            "SELECT vote, reason, target_kind, target_ref FROM votes WHERE bar_id=? ORDER BY ts DESC",
            (bar_id,)
        ).fetchall()

        result["bars"].append({
            "id": bar_id,
            "index": idx,
            "text": text,
            "topic": topic,
            "sources": [{"kind": s[0], "ref": s[1], "category": s[2]} for s in sources],
            "votes": [{"vote": v[0], "reason": v[1], "target_kind": v[2], "target_ref": v[3]} for v in votes]
        })

    return result


def render_footer_html(gen_data: dict, blocks_catalog: dict) -> str:
    """Render HTML footer with blocks, sources, and vote UI."""

    html = f"""
<div class="ai-sparkler-footer">
  <div class="generation-meta">
    <span class="artist">{gen_data['artist']}</span>
    <span class="model">{gen_data['model']}</span>
    <span class="gen-id" title="generation ID">{gen_data['generation_id'][:8]}</span>
  </div>

  <div class="bars-and-sources">
"""

    # Aggregate all blocks used
    all_blocks = Counter()
    all_catalog = Counter()

    for bar in gen_data["bars"]:
        for src in bar["sources"]:
            if src["kind"] == "block":
                all_blocks[src["ref"]] += 1
            else:
                all_catalog[src["ref"]] += 1

    html += """    <div class="blocks-panel">
      <h4>Blocks</h4>
      <ul class="blocks-list">
"""

    for block_norm, count in all_blocks.most_common(15):
        block_info = blocks_catalog.get(block_norm, {})
        category = block_info.get("category", "?")
        heard_as = block_info.get("heard_as", "")

        heard_title = f' title="Wordplay: {heard_as}"' if heard_as else ""

        html += f"""        <li class="block" data-norm="{block_norm}" data-category="{category}"{heard_title}>
          <span class="block-name">{block_info.get('block', block_norm)}</span>
          <span class="block-category">{category}</span>
          <span class="block-count">×{count}</span>
          <div class="block-votes">
            <button class="vote-btn vote-up" data-ref="{block_norm}" data-kind="block">👍</button>
            <button class="vote-btn vote-down" data-ref="{block_norm}" data-kind="block">👎</button>
          </div>
        </li>
"""

    html += """      </ul>
    </div>

    <div class="sources-panel">
      <h4>Catalog Bars</h4>
      <ul class="sources-list">
"""

    for cat_bar_ref, count in all_catalog.most_common(10):
        html += f"""        <li class="catalog-bar" data-ref="{cat_bar_ref}">
          <span class="ref">{cat_bar_ref}</span>
          <span class="count">×{count}</span>
          <div class="catalog-votes">
            <button class="vote-btn vote-up" data-ref="{cat_bar_ref}" data-kind="catalog_bar">👍</button>
            <button class="vote-btn vote-down" data-ref="{cat_bar_ref}" data-kind="catalog_bar">👎</button>
          </div>
        </li>
"""

    html += """      </ul>
    </div>
  </div>

  <div class="bar-votes">
    <h4>Bar Votes</h4>
"""

    for bar in gen_data["bars"]:
        vote_counts = Counter((v["vote"] for v in bar["votes"]), start=[0, 0])
        html += f"""    <div class="bar-vote" data-bar-id="{bar['id']}">
      <span class="bar-text">{bar['text'][:60]}...</span>
      <span class="topic">[{bar['topic']}]</span>
      <div class="vote-buttons">
        <button class="vote-btn vote-up" data-target-kind="bar">👍</button>
        <button class="vote-btn vote-down" data-target-kind="bar">👎</button>
      </div>
      <div class="reason-tags">
"""

        for reason in REASONS:
            html += f'        <button class="reason-tag" data-reason="{reason}">{reason}</button>\n'

        html += """      </div>
    </div>
"""

    html += """  </div>

  <style>
    .ai-sparkler-footer {
      background: #1a1a1a; color: #eee; padding: 1rem; font-family: monospace; font-size: 0.9rem;
    }
    .generation-meta { margin-bottom: 0.5rem; }
    .artist { font-weight: bold; margin-right: 1rem; }
    .blocks-panel, .sources-panel { display: inline-block; margin-right: 1.5rem; vertical-align: top; }
    .blocks-list, .sources-list { list-style: none; padding: 0; margin: 0.5rem 0; }
    .block, .catalog-bar { display: flex; align-items: center; gap: 0.5rem; padding: 0.25rem 0; }
    .block-name { flex: 1; color: #4f9; }
    .block-category { color: #88f; font-size: 0.85rem; }
    .block-count { color: #fa8; margin-left: 0.25rem; }
    .vote-btn { background: none; border: 1px solid #666; color: #aaa; padding: 0.1rem 0.3rem; cursor: pointer; margin-left: 0.25rem; }
    .vote-btn:hover { background: #333; color: #fff; }
    .vote-up:hover { color: #4f9; }
    .vote-down:hover { color: #f44; }
    .bar-vote { margin: 0.5rem 0; padding: 0.5rem; border-left: 2px solid #666; }
    .bar-text { color: #4f9; margin-right: 0.5rem; }
    .topic { color: #88f; font-size: 0.85rem; }
    .reason-tags { margin-top: 0.25rem; }
    .reason-tag { background: #333; border: 1px solid #666; color: #aaa; padding: 0.15rem 0.3rem; margin-right: 0.25rem; font-size: 0.8rem; cursor: pointer; }
    .reason-tag:hover { background: #555; color: #fff; }
  </style>

  <script>
    document.querySelectorAll('.vote-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const isUp = btn.classList.contains('vote-up');
        const voteVal = isUp ? 1 : -1;
        const kind = btn.dataset.kind || btn.dataset.targetKind;
        const ref = btn.dataset.ref;
        const barId = btn.closest('.bar-vote')?.dataset.barId;
        const reason = btn.closest('.bar-vote')?.querySelector('.reason-tag.selected')?.dataset.reason;

        console.log(`vote: ${voteVal} on ${kind}:${ref || barId} reason=${reason}`);
        // TODO: POST to feedback API
      });
    });

    document.querySelectorAll('.reason-tag').forEach(tag => {
      tag.addEventListener('click', () => {
        tag.parentElement.querySelectorAll('.reason-tag').forEach(t => t.classList.remove('selected'));
        tag.classList.add('selected');
      });
    });
  </script>
</div>
"""

    return html


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("generation_id", help="generation ID to render")
    ap.add_argument("--db", type=Path, default=OUT / "feedback.db", help="feedback store DB")
    ap.add_argument("--html", type=Path, help="output HTML file (default: print to stdout)")
    args = ap.parse_args()

    db = sqlite3.connect(args.db)
    gen_data = get_generation_data(db, args.generation_id)

    if not gen_data:
        print(f"generation {args.generation_id} not found", file=sys.stderr)
        return 1

    blocks_catalog = load_blocks_catalog()
    html = render_footer_html(gen_data, blocks_catalog)

    if args.html:
        args.html.write_text(html, encoding="utf-8")
        print(f"wrote {args.html}")
    else:
        print(html)

    return 0


if __name__ == "__main__":
    sys.exit(main())
