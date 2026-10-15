#!/usr/bin/env python3
"""Render two mimic batches side by side (e.g. rhyme-first v2 vs v1) into one HTML page.

Usage:
  python3 tools/style-profile/ab_side_by_side.py out/rater-batch-rhymefirst/v1 out/rater-batch-rhymefirst/v2 \
      --labels "Old (no rhyme plan)" "Rhyme-first" --html tools/style-profile/ab_rhymefirst.html
"""

from __future__ import annotations

import argparse
import html
import json
from pathlib import Path


def verses(folder: Path) -> list[dict]:
    out = []
    for path in sorted(folder.glob("mimic_*.json")):
        if path.name == "mimic_manifest.json":
            continue
        doc = json.loads(path.read_text(encoding="utf-8"))
        for key, model in sorted(doc.get("models", {}).items()):
            if model.get("bars"):
                out.append({"seed": doc.get("seed"), "slot": key, "model": model.get("model", key),
                            "bars": model["bars"], "plan": model.get("rhyme_plan"),
                            "problems": model.get("problems", []), "notes": model.get("notes", [])})
    return out


def render_verse(v: dict) -> str:
    plan_slots = (v.get("plan") or {}).get("slots") or []
    rows = []
    for i, bar in enumerate(v["bars"]):
        text = html.escape(bar["text"])
        end = bar.get("end_word") or ""
        if end:
            low = text.lower()
            pos = low.rfind(html.escape(end).lower())
            if pos >= 0:
                text = f'{text[:pos]}<b class="end">{text[pos:pos + len(end)]}</b>{text[pos + len(end):]}'
        slot = plan_slots[i] if i < len(plan_slots) else None
        planned = f'<span class="plan">planned “{html.escape(slot["word"])}”</span>' if slot else ""
        rows.append(f'<li><span class="txt">{text}</span><span class="meta"><span class="letter L{html.escape(bar.get("rhyme_letter") or "")}">'
                    f'{html.escape(bar.get("rhyme_letter") or "")}</span>{planned}</span></li>')
    letters = "".join(b.get("rhyme_letter") or "?" for b in v["bars"])
    issues = v["problems"] + v["notes"]
    foot = f'<div class="foot">scheme {html.escape(letters)}' + (
        f' · {len(issues)} note(s)' if issues else '') + '</div>'
    return f'<ol>{"".join(rows)}</ol>{foot}'


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("left", type=Path)
    ap.add_argument("right", type=Path)
    ap.add_argument("--labels", nargs=2, default=["Left", "Right"])
    ap.add_argument("--html", type=Path, required=True)
    args = ap.parse_args()
    left, right = verses(args.left), verses(args.right)
    pairs = []
    for i in range(max(len(left), len(right))):
        a = render_verse(left[i]) if i < len(left) else '<p class="none">no verse</p>'
        b = render_verse(right[i]) if i < len(right) else '<p class="none">no verse</p>'
        model = (right[i] if i < len(right) else left[i])["model"]
        seed = (right[i] if i < len(right) else left[i])["seed"]
        pairs.append(f'<section><h2>Verse {i + 1} <small>seed {seed} · {html.escape(str(model))}</small></h2>'
                     f'<div class="cols"><div class="col"><h3>{html.escape(args.labels[0])}</h3>{a}</div>'
                     f'<div class="col"><h3>{html.escape(args.labels[1])}</h3>{b}</div></div></section>')
    page = f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Rhyme-First A/B</title>
<style>
:root {{ --bg:#f6f5f2; --panel:#fff; --ink:#1b1b1f; --muted:#6b6b74; --line:#e3e1dc; --accent:#3d5afe;
  --a:#e3ecff; --b:#ffe9d6; --c:#e8f6ea; --d:#f6e6f7; --e:#fff6c8; }}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{ --bg:#111114; --panel:#1a1a1f; --ink:#ececf1;
  --muted:#9a9aa6; --line:#2c2c34; --accent:#8c9eff; --a:#26304d; --b:#4a3320; --c:#1f3b28; --d:#3d2440; --e:#4a4220; }} }}
:root[data-theme="dark"] {{ --bg:#111114; --panel:#1a1a1f; --ink:#ececf1; --muted:#9a9aa6; --line:#2c2c34; --accent:#8c9eff;
  --a:#26304d; --b:#4a3320; --c:#1f3b28; --d:#3d2440; --e:#4a4220; }}
* {{ box-sizing:border-box; }}
body {{ margin:0; background:var(--bg); color:var(--ink); font:15px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }}
.wrap {{ max-width:1100px; margin:0 auto; padding:24px 16px 48px; }}
h1 {{ font-size:22px; margin:0 0 4px; }} .sub {{ color:var(--muted); font-size:13px; margin-bottom:20px; }}
section {{ background:var(--panel); border:1px solid var(--line); border-radius:12px; padding:16px; margin-bottom:16px; }}
h2 {{ font-size:15px; margin:0 0 10px; }} h2 small {{ color:var(--muted); font-weight:400; }}
h3 {{ font-size:12px; text-transform:uppercase; letter-spacing:.06em; color:var(--muted); margin:0 0 6px; }}
.cols {{ display:grid; grid-template-columns:1fr 1fr; gap:20px; }}
.col:last-child h3 {{ color:var(--accent); }}
ol {{ margin:0; padding-left:22px; }} li {{ padding:3px 0; }}
li {{ display:list-item; }} .txt {{ font-size:16px; }}
.meta {{ margin-left:8px; white-space:nowrap; }}
.letter {{ font-size:11px; font-weight:700; padding:1px 6px; border-radius:5px; background:var(--line); }}
.LA {{ background:var(--a); }} .LB {{ background:var(--b); }} .LC {{ background:var(--c); }} .LD {{ background:var(--d); }} .LE {{ background:var(--e); }}
.plan {{ font-size:11px; color:var(--muted); margin-left:6px; font-style:italic; }}
.end {{ text-decoration:underline; text-underline-offset:3px; }}
.foot {{ font-size:12px; color:var(--muted); margin-top:6px; }} .none {{ color:var(--muted); }}
@media (max-width:700px) {{ .cols {{ grid-template-columns:1fr; }} .meta {{ display:inline-block; margin-left:0; }} }}
</style></head><body><div class="wrap">
<h1>Rhyme-first A/B</h1>
<div class="sub">Same model, same seeds, same Gunna songs as examples. Left: {html.escape(args.labels[0])}. Right: {html.escape(args.labels[1])}.
Letters show which lines end-rhyme with each other (same letter = rhyme). Underlined = end word. “planned” = the end word the rhyme plan asked for.</div>
{''.join(pairs)}
</div></body></html>"""
    args.html.write_text(page, encoding="utf-8")
    print(f"wrote {args.html} ({len(pairs)} pairs)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
