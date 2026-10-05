"""HTML scorecard: IN at top, Wrap / Nearby / Picture / People out, rate each lane."""

from __future__ import annotations

import html
import json
from dataclasses import asdict, is_dataclass
from pathlib import Path

from retrieve import Hit


def hit_dict(h: Hit) -> dict:
    d = asdict(h) if is_dataclass(h) else dict(h)
    return d


def paint(line: str, spans: list[dict]) -> str:
    if not spans:
        return html.escape(line)
    ordered = sorted(spans, key=lambda s: s.get("start", 0))
    out = []
    i = 0
    for sp in ordered:
        start, end = sp.get("start", 0), sp.get("end", 0)
        if start < i:
            continue
        out.append(html.escape(line[i:start]))
        kind = sp.get("kind", "")
        cls = "img"
        if kind == "rhyme.perfect":
            cls = "perf"
        elif kind == "rhyme.slant":
            cls = "slant"
        elif kind == "stress":
            cls = "stress"
        title = kind
        if sp.get("pair"):
            title += f" ↔ {sp['pair']}"
        out.append(
            f'<mark class="{cls}" title="{html.escape(title)}">{html.escape(line[start:end])}</mark>'
        )
        i = end
    out.append(html.escape(line[i:]))
    return "".join(out)


def _hit_card(h: Hit, qid: str, host: str, lane: str, prechecked: set[str]) -> str:
    payload = json.dumps(
        {
            "card": qid,
            "host": host,
            "lane": lane,
            "line": h.line,
            "end": h.end_word,
            "rhyme": h.rhyme,
            "pair": h.rhyme_pair,
            "syl": h.syllables,
            "window": h.window,
            "people": h.people,
            "metaphor": h.metaphor or "",
            "imagery": h.imagery,
            "stress": h.stress_words,
            "stress_score": h.stress_score,
            "why": h.why,
        },
        ensure_ascii=False,
    )
    liked = " is-like" if h.line.strip().lower() in prechecked else ""
    end = html.escape(h.end_word)
    rhyme = h.rhyme or ""
    return f"""
    <div class="hit{liked}" data-hit="{html.escape(payload, quote=True)}">
      <div class="votes">
        <button type="button" class="vote vote-like" aria-label="like">▲</button>
        <button type="button" class="vote vote-dislike" aria-label="dislike">▼</button>
      </div>
      <span class="hit-line">{paint(h.line, h.spans)}</span>
      <span class="hit-meta">{html.escape(h.people)} · {h.syllables} (Δ{getattr(h, 'wrap_delta', 0)}) · inner {getattr(h, 'inner_score', 0)} · {end}{(' · ' + html.escape(rhyme)) if rhyme else ''}</span>
    </div>"""


def _column(title: str, hint: str, hits: list[Hit], qid: str, host: str, lane: str, prechecked: set[str]) -> str:
    body = "".join(_hit_card(h, qid, host, lane, prechecked) for h in hits) or '<p class="empty">none</p>'
    return f"""
    <section class="col">
      <h3>{html.escape(title)} <small>{len(hits)}</small></h3>
      <p class="hint">{html.escape(hint)}</p>
      {body}
    </section>"""


def _hit_row(h: Hit, qid: str, host: str, lane: str, prechecked: set[str]) -> str:
    rhyme = h.rhyme or "—"
    if h.rhyme and h.rhyme_pair:
        rhyme = f"{h.rhyme} `{html.escape(h.end_word)}` ↔ `{html.escape(h.rhyme_pair)}`"
    imagery = ", ".join(html.escape(x) for x in h.imagery) or "—"
    payload = json.dumps(
        {
            "card": qid,
            "host": host,
            "lane": lane,
            "line": h.line,
            "end": h.end_word,
            "rhyme": h.rhyme,
            "pair": h.rhyme_pair,
            "syl": h.syllables,
            "window": h.window,
            "people": h.people,
            "metaphor": h.metaphor or "",
            "imagery": h.imagery,
            "stress": h.stress_words,
            "stress_score": h.stress_score,
            "why": h.why,
        },
        ensure_ascii=False,
    )
    checked = " checked" if h.line.strip().lower() in prechecked else ""
    return f"""
    <tr>
      <td class="pick"><input type="checkbox" class="pick-hit"{checked} data-hit="{html.escape(payload, quote=True)}"></td>
      <td class="line">{paint(h.line, h.spans)}</td>
      <td>{h.syllables}</td>
      <td><span class="win {h.window}">{h.window}</span></td>
      <td>{html.escape(h.end_word)}</td>
      <td>{rhyme}</td>
      <td>{html.escape(h.metaphor or "—")}</td>
      <td>{imagery}</td>
      <td class="stress-col" title="{html.escape(h.stress_note)}">{html.escape(", ".join(h.stress_words) or "—")} <small>{h.stress_score}</small></td>
      <td class="people">{html.escape(h.people)}</td>
      <td class="why">{html.escape(h.why)}</td>
    </tr>"""


def _table(title: str, hits: list[Hit], qid: str, host: str, lane: str, prechecked: set[str]) -> str:
    if not hits:
        return f'<section class="lane"><h3>{html.escape(title)}</h3><p class="empty">none</p></section>'
    rows = "".join(_hit_row(h, qid, host, lane, prechecked) for h in hits)
    return f"""
    <section class="lane">
      <h3>{html.escape(title)} <small>{len(hits)}</small></h3>
      <table>
        <thead>
          <tr>
            <th>Keep</th><th>Hit</th><th>Syl</th><th>Window</th><th>End</th>
            <th>Rhyme</th><th>Metaphor</th><th>Imagery</th><th>Stress</th><th>People</th><th>Why</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    </section>"""


def _rate(qid: str, lane: str) -> str:
    return f"""
    <div class="rate" data-q="{html.escape(qid)}" data-lane="{html.escape(lane)}">
      <span>{html.escape(lane)}</span>
      <label><input type="radio" name="{html.escape(qid+lane)}" value="right"> right</label>
      <label><input type="radio" name="{html.escape(qid+lane)}" value="weak"> weak</label>
      <label><input type="radio" name="{html.escape(qid+lane)}" value="wrong"> wrong</label>
    </div>"""


def card_html(qid: str, gold: dict, bundle: dict, notes: str = "") -> str:
    q = bundle["query"]
    rates = "".join(_rate(qid, lane) for lane in ("replace", "next"))
    host = q.get("line") or ""
    pre = {ln.strip().lower() for ln in (gold.get("helpful_lines") or [])}
    end = q.get("end_word") or ""
    return f"""
    <article class="card" id="{html.escape(qid)}" data-host="{html.escape(host, quote=True)}">
      <header>
        <h2>{html.escape(qid)}</h2>
        {rates}
      </header>
      <p class="held">{paint(q['line'], q.get('spans') or [])}</p>
      <p class="host-meta">{q.get('syllables')} count · window {html.escape(q.get('window') or '')} · punches {html.escape(', '.join(q.get('stress_words') or []))} · {html.escape(q.get('people') or '')}</p>
      <div class="pair">
        {_column("Replace · catalog", "Same start, then a finish in the pocket.", bundle.get("replace") or [], qid, host, "replace", pre)}
        {_column("Follow-up · catalog", "Next line — more play. Rhyme with " + end + ".", bundle.get("next") or [], qid, host, "next", pre)}
      </div>
      <div class="pair gen-pair">
        {_column("Replace · original", "Only grafts that pass the harness. Empty = nothing earned a slot.", bundle.get("gen_replace") or [], qid, host, "gen-replace", set())}
        {_column("Follow-up · original", "Only grafts that pass the harness. Empty = nothing earned a slot.", bundle.get("gen_next") or [], qid, host, "gen-next", set())}
      </div>
    </article>
    """


def _primary_chip(h: Hit) -> str:
    if h.artist_ids:
        return h.artist_ids[0]
    return h.people.split(" and ")[0] if h.people else "?"


CSS = """
:root { color-scheme: dark; --bg:#111; --card:#1b1b1b; --ink:#eee; --mut:#9a9a9a; --line:#333; }
body { margin:0; font: 15px/1.45 ui-sans-serif, system-ui; background:var(--bg); color:var(--ink); }
header.top { padding:24px 28px 8px; }
header.top h1 { margin:0 0 8px; font-size:22px; }
header.top p { color:var(--mut); max-width:72ch; }
.jobs { color:var(--ink); font-size:14px; background:#161616; border:1px solid var(--line); padding:10px 12px; border-radius:8px; }
.coverage { color:var(--mut); font-size:13px; margin:8px 0 4px; }
.chips { display:flex; flex-wrap:wrap; gap:6px; margin:0 0 16px; }
.chip { background:#2a2a2a; border:1px solid var(--line); border-radius:999px; padding:2px 8px; font-size:12px; }
.card { background:var(--card); margin:20px; padding:20px 22px 28px; border-radius:12px; border:1px solid var(--line); }
.card h2 { margin:0; font-size:16px; letter-spacing:.04em; text-transform:uppercase; }
.card header { display:flex; flex-wrap:wrap; gap:12px; justify-content:space-between; align-items:center; margin-bottom:12px; }
.rate { display:flex; gap:8px; align-items:center; font-size:13px; color:var(--mut); }
.rate span { color:var(--ink); font-weight:600; margin-right:4px; }
pre.in { background:#111; padding:12px 14px; border-radius:8px; overflow:auto; }
.held { font-size:20px; margin:4px 0 6px; }
.host-meta { color:var(--mut); font-size:13px; margin:0 0 16px; }
.pair { display:grid; grid-template-columns:1fr 1fr; gap:18px; }
.gen-pair { margin-top:16px; padding-top:16px; border-top:1px dashed var(--line); }
.gen-pair .col h3 { color:#c9b36a; }
@media (max-width: 900px) { .pair { grid-template-columns:1fr; } }
.col h3 { margin:0 0 4px; font-size:15px; }
.col .hint { color:var(--mut); font-size:12px; margin:0 0 10px; }
.hit { display:grid; grid-template-columns:36px 1fr; grid-template-rows:auto auto; gap:2px 10px; padding:8px 10px; border:1px solid var(--line); border-radius:8px; margin-bottom:8px; }
.hit.is-like { background:#1a2a1a; border-color:#2f6f3e; }
.hit.is-dislike { background:#2a1a1a; border-color:#8a3a3a; }
.votes { grid-row:1 / span 2; display:flex; flex-direction:column; gap:4px; }
.vote { width:28px; height:26px; border:1px solid var(--line); background:#222; color:var(--mut); border-radius:6px; cursor:pointer; font-size:12px; line-height:1; }
.vote-like:hover, .hit.is-like .vote-like { background:#2f6f3e; color:#fff; border-color:#2f6f3e; }
.vote-dislike:hover, .hit.is-dislike .vote-dislike { background:#8a3a3a; color:#fff; border-color:#8a3a3a; }
.hit-line { font-size:15px; }
.hit-meta { grid-column:2; color:var(--mut); font-size:12px; }
mark.perf { background:#2f6f3e; color:#fff; padding:0 .15em; border-radius:3px; }
mark.slant { background:#6a5420; color:#fff; padding:0 .15em; border-radius:3px; }
mark.img { background:#1e3a5f; color:#fff; padding:0 .15em; border-radius:3px; text-decoration:underline; }
mark.stress { background:#4a2d6a; color:#fff; padding:0 .15em; border-radius:3px; }
table { width:100%; border-collapse:collapse; font-size:13px; }
th, td { border-bottom:1px solid var(--line); padding:7px 8px; vertical-align:top; text-align:left; }
th { color:var(--mut); font-weight:600; }
.line { min-width:28ch; }
.people { white-space:nowrap; }
.why { color:var(--mut); }
.win.in { color:#8fd19e; }
.win.nearby { color:#e6c07b; }
.win.off { color:#e07a7a; }
.notes, .expect, .gate { color:var(--mut); font-size:13px; }
.gate.pass { color:#8fd19e; }
.gate.fail { color:#e07a7a; }
.empty { color:var(--mut); }
.legend span { display:inline-block; margin-right:12px; }
.pick { width:2.2em; }
.pick-hit { width:16px; height:16px; accent-color:#8fd19e; }
tr:has(.pick-hit:checked) { background:#1a2a1a; }
#export {
  position: sticky; bottom: 0; background:#0d0d0d; border-top:1px solid var(--line);
  padding: 14px 22px 18px; z-index: 5;
}
#export h2 { margin:0 0 6px; font-size:15px; }
#export .row { display:flex; gap:10px; align-items:center; margin-bottom:8px; }
#export button {
  background:#2f6f3e; color:#fff; border:0; border-radius:8px; padding:8px 12px; font-weight:600; cursor:pointer;
}
#export textarea {
  width:100%; min-height:140px; background:#111; color:var(--ink); border:1px solid var(--line);
  border-radius:8px; padding:10px; font:12px/1.4 ui-monospace, monospace;
}
#copied { color:#8fd19e; font-size:13px; display:none; }
"""

JS = r"""
const rateKey = "bar-hits-rag-ratings-v7";
const pickKey = "bar-hits-rag-picks-v7";
function load(k){ try { return JSON.parse(localStorage.getItem(k)||"{}"); } catch { return {}; } }
function save(k, m){ localStorage.setItem(k, JSON.stringify(m)); }

const ratings = load(rateKey);
document.querySelectorAll(".rate").forEach(el => {
  const q = el.dataset.q, lane = el.dataset.lane;
  const cur = (ratings[q]||{})[lane];
  el.querySelectorAll("input").forEach(inp => {
    if (cur && inp.value === cur) inp.checked = true;
    inp.addEventListener("change", () => {
      ratings[q] = ratings[q] || {};
      ratings[q][lane] = inp.value;
      save(rateKey, ratings);
      buildPrompt();
    });
  });
});

const picks = load(pickKey);
function hitId(el){
  const h = JSON.parse(el.dataset.hit);
  return h.card + "||" + h.lane + "||" + h.line + "||" + h.people;
}
function applyVote(el, vote){
  el.classList.toggle("is-like", vote === "like");
  el.classList.toggle("is-dislike", vote === "dislike");
}
document.querySelectorAll(".hit[data-hit]").forEach(el => {
  const id = hitId(el);
  const saved = picks[id];
  if (saved && saved.vote) applyVote(el, saved.vote);
  else if (el.classList.contains("is-like")) {
    picks[id] = Object.assign(JSON.parse(el.dataset.hit), {vote:"like"});
  }
  el.querySelector(".vote-like").addEventListener("click", (ev) => {
    ev.preventDefault();
    const cur = (picks[id]||{}).vote;
    const vote = cur === "like" ? "" : "like";
    if (vote) picks[id] = Object.assign(JSON.parse(el.dataset.hit), {vote});
    else delete picks[id];
    applyVote(el, vote);
    save(pickKey, picks);
    buildPrompt();
  });
  el.querySelector(".vote-dislike").addEventListener("click", (ev) => {
    ev.preventDefault();
    const cur = (picks[id]||{}).vote;
    const vote = cur === "dislike" ? "" : "dislike";
    if (vote) picks[id] = Object.assign(JSON.parse(el.dataset.hit), {vote});
    else delete picks[id];
    applyVote(el, vote);
    save(pickKey, picks);
    buildPrompt();
  });
});
save(pickKey, picks);

function buildPrompt(){
  const live = {};
  document.querySelectorAll(".hit[data-hit]").forEach(el => {
    const id = hitId(el);
    if (picks[id] && picks[id].vote) live[id] = picks[id];
  });
  const byHost = {};
  Object.values(live).forEach(h => {
    const host = h.host || "";
    byHost[host] = byHost[host] || [];
    byHost[host].push(h);
  });
  const parts = [];
  parts.push("Bar Hits RAG feedback — paste this back so Grok can retune retrieval.");
  parts.push("");
  parts.push("I used like/dislike on each hit. LIKE = surface more like this. DISLIKE = stop surfacing this kind of miss. REPLACE = swap the current line (same pocket/picture; end-word does NOT have to match). NEXT = follow-up bar that rhymes with the landing. Infer how to rank each job. Rebuild and loop.");
  parts.push("");
  parts.push("Originals are harness-gated (not catalog). Grade those too.");
  parts.push("");
  if (!Object.keys(byHost).length) {
    parts.push("(No likes or dislikes yet.)");
  }
  Object.keys(byHost).forEach(host => {
    const likes = byHost[host].filter(h => h.vote === "like");
    const dislikes = byHost[host].filter(h => h.vote === "dislike");
    parts.push("## Host: " + host);
    likes.forEach(h => {
      const rhyme = (h.rhyme || "—") + (h.pair ? (" `" + h.end + "` ↔ `" + h.pair + "`") : "");
      parts.push("- LIKE [" + h.lane + "] \"" + h.line + "\" | end=" + h.end + " | " + rhyme + " | syl=" + h.syl + " " + h.window + " | " + h.people);
    });
    dislikes.forEach(h => {
      const rhyme = (h.rhyme || "—") + (h.pair ? (" `" + h.end + "` ↔ `" + h.pair + "`") : "");
      parts.push("- DISLIKE [" + h.lane + "] \"" + h.line + "\" | end=" + h.end + " | " + rhyme + " | syl=" + h.syl + " " + h.window + " | " + h.people);
    });
    parts.push("");
  });
  const liveCards = new Set([...document.querySelectorAll(".card")].map(el => el.id));
  const rated = Object.keys(ratings).filter(q => liveCards.has(q));
  if (rated.length) {
    parts.push("## Lane ratings");
    rated.forEach(q => {
      const lanes = ratings[q];
      parts.push("- " + q + ": " + Object.keys(lanes).map(k => k + "=" + lanes[k]).join(", "));
    });
    parts.push("");
  }
  const ta = document.getElementById("prompt");
  ta.value = parts.join("\n");
  const nLike = Object.values(live).filter(h => h.vote === "like").length;
  const nDis = Object.values(live).filter(h => h.vote === "dislike").length;
  document.getElementById("count").textContent = nLike + " liked · " + nDis + " disliked";
}
buildPrompt();
document.getElementById("clear-votes").addEventListener("click", () => {
  Object.keys(picks).forEach(k => delete picks[k]);
  Object.keys(ratings).forEach(k => delete ratings[k]);
  save(pickKey, picks);
  save(rateKey, ratings);
  document.querySelectorAll(".hit").forEach(el => {
    el.classList.remove("is-like", "is-dislike");
  });
  document.querySelectorAll(".rate input").forEach(inp => { inp.checked = false; });
  buildPrompt();
});
document.getElementById("copy").addEventListener("click", async () => {
  const ta = document.getElementById("prompt");
  ta.select();
  try { await navigator.clipboard.writeText(ta.value); } catch { document.execCommand("copy"); }
  const ok = document.getElementById("copied");
  ok.style.display = "inline";
  setTimeout(() => { ok.style.display = "none"; }, 1600);
});
"""


def render(cards: list[str], summary: str) -> str:
    return f"""<!doctype html>
<meta charset="utf-8">
<title>Bar Hits RAG scorecard</title>
<style>{CSS}</style>
<header class="top">
  <h1>Bar Hits RAG scorecard</h1>
  <p>Top row = catalog. Bottom row (gold) = <strong>original</strong> lines, not in the dump. ▲ like / ▼ dislike, then copy the prompt.</p>
  <p class="legend">
    <span><mark class="perf">perfect rhyme</mark></span>
    <span><mark class="slant">slant</mark></span>
    <span><mark class="img">imagery</mark></span>
    <span><mark class="stress">stress word</mark></span>
  </p>
  <p class="gate">{html.escape(summary)}</p>
</header>
{''.join(cards)}
<aside id="export">
  <h2>Feedback prompt</h2>
  <div class="row">
    <button type="button" id="copy">Copy prompt</button>
    <button type="button" id="clear-votes" style="background:#444">Clear votes</button>
    <span id="count">0 liked · 0 disliked</span>
    <span id="copied">copied</span>
  </div>
  <textarea id="prompt" readonly></textarea>
</aside>
<script>{JS}</script>
"""


def write_json(path: Path, payload: dict) -> None:
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
