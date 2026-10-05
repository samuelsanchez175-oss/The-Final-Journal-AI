"""Wrap + nearby + picture retrieval against the bench catalog."""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass, field

from craft import inner_rhyme_score, wrap_distance
from metaphors import content_tokens, imagery_words, metaphor_label, picture_overlap, top_metaphor
from stress import compare as stress_compare
from stress import profile as stress_profile
from people import PEOPLE, artist_ids, people_phrase
from rhyme import (
    WORD_RE,
    classify_rhyme,
    consonant_coda,
    end_word,
    morph_end_candidates,
    morph_kind,
    phonetic_class_from_phones,
    signature_for,
    strip_adlib,
)


def wrap_window(syllables: int) -> tuple[int, int]:
    lo = max(1, syllables - 1)
    hi = syllables + 2
    return lo, hi


def _onset(tok: str) -> str:
    t = tok.lower().replace("'", "")
    if t in {"i", "im", "ima", "imma"}:
        return "i"
    return t


def opening_tokens(line: str) -> list[str]:
    """Tokens before the landing — the part the writer already started."""
    toks = WORD_RE.findall(strip_adlib(line).lower())
    return toks[:-1] if len(toks) >= 2 else toks


def prefix_overlap(host_open: list[str], cand_open: list[str]) -> int:
    n = 0
    for a, b in zip(host_open, cand_open):
        if _onset(a) == _onset(b):
            n += 1
        else:
            break
    return n


def usable_bar(line: str) -> bool:
    import re

    text = (line or "").strip()
    if len(text) < 12:
        return False
    if text[0] in ",.;:\"'":
        return False
    if text.startswith("(") and text.endswith(")"):
        return False
    if text.count("(") != text.count(")"):
        return False
    if re.match(r"^\d+\.", text):
        return False
    if " - " in text and len(text.split()) <= 8:
        return False
    words = [w for w in text.split() if w.strip(".,!?;:\"()")]
    if len(words) < 5:
        return False
    end = words[-1].lower().strip(".,!?;:\"()")
    if end in {"yeah", "yea", "uh", "woo", "ayy", "hey", "ah", "ooh", "ya"}:
        return False
    low = text.lower()
    if "boo-hoo" in low or "sheesh" in low:
        return False
    if "play my song" in low:
        return False
    return True


def window_label(hit_syl: int, lo: int, hi: int) -> str:
    if lo <= hit_syl <= hi:
        return "in"
    if lo - 2 <= hit_syl <= hi + 2:
        return "nearby"
    return "off"


@dataclass
class Hit:
    id: str
    line: str
    artist: str
    song: str
    syllables: int
    end_word: str
    phonetic_class: str
    destressed_class: str
    people: str
    artist_ids: list[str]
    person_n: int
    lane: str
    window: str
    rhyme: str | None
    rhyme_pair: str
    metaphor: str
    imagery: list[str]
    score: float
    why: str
    stress_words: list[str] = field(default_factory=list)
    stress_score: int = 0
    stress_note: str = ""
    inner_score: int = 0
    wrap_delta: int = 0
    spans: list[dict] = field(default_factory=list)


def _row_hit(
    row: sqlite3.Row,
    query_end: str,
    lo: int,
    hi: int,
    cmu: dict,
    lane: str,
    score: float,
    why: str,
    host_stress=None,
    host_syl: int = 0,
) -> Hit:
    ids = [p for p in (row["artist_ids"] or "").split(",") if p]
    rhyme = classify_rhyme(query_end, row["end_word"] or "", cmu)
    cand_stress = stress_profile(row["line"] or "", cmu, row["end_word"] or "")
    s_score, s_note = (0, "")
    if host_stress is not None:
        s_score, s_note = stress_compare(host_stress, cand_stress)
    line_txt = row["line"] or ""
    inner = inner_rhyme_score(line_txt, cmu)
    return Hit(
        id=row["id"],
        line=row["line"],
        artist=row["artist"] or "",
        song=row["song"] or "",
        syllables=int(row["syllables"]),
        end_word=row["end_word"] or "",
        phonetic_class=row["phonetic_class"] or "",
        destressed_class=row["destressed_class"] or "",
        people=row["people"] or people_phrase(row["artist"] or ""),
        artist_ids=ids or artist_ids(row["artist"] or ""),
        person_n=int(row["person_n"] or 0) if "person_n" in row.keys() else 0,
        lane=lane,
        window=window_label(int(row["syllables"]), lo, hi),
        rhyme=rhyme,
        rhyme_pair=query_end,
        metaphor=metaphor_label(row["line"]),
        imagery=imagery_words(row["line"]),
        score=score,
        why=why,
        stress_words=cand_stress.words,
        stress_score=s_score,
        stress_note=s_note,
        inner_score=inner,
        wrap_delta=wrap_distance(int(row["syllables"]), host_syl),
    )


def _primary(hit: Hit) -> str:
    return hit.artist_ids[0] if hit.artist_ids else (hit.artist or "?")


def diversify(hits: list[Hit], k: int, max_per: int = 2) -> list[Hit]:
    """Keep rhyme order, but don't let Gunna/Baby/Future fill the whole list."""
    out: list[Hit] = []
    n: dict[str, int] = {}
    for h in hits:
        key = _primary(h)
        if n.get(key, 0) >= max_per:
            continue
        n[key] = n.get(key, 0) + 1
        out.append(h)
        if len(out) >= k:
            break
    if len(out) < k:
        have = {id(h) for h in out}
        for h in hits:
            if id(h) in have:
                continue
            out.append(h)
            if len(out) >= k:
                break
    return out


def retrieve(
    con: sqlite3.Connection,
    line: str,
    syllables: int,
    cmu: dict,
    wrap_k: int = 22,
    nearby_k: int = 8,
    picture_k: int = 10,
    query_artist: str = "",
) -> dict:
    query_end = end_word(line)
    lo, hi = wrap_window(syllables)
    sig = signature_for(query_end, cmu)
    klass = phonetic_class_from_phones(cmu[query_end]) if query_end in cmu else ""
    destressed = sig.destressed_class if sig else ""
    q_people = people_phrase(query_artist) if query_artist else ""
    q_ids = artist_ids(query_artist) if query_artist else []
    q_metaphor = metaphor_label(line)
    q_imagery = imagery_words(line)
    q_stress = stress_profile(line, cmu, query_end)

    query = {
        "line": line,
        "end_word": query_end,
        "syllables": syllables,
        "window": f"{lo}…{hi}",
        "phonetic": klass or destressed,
        "people": q_people or (q_ids[0] if q_ids else ""),
        "stress_words": q_stress.words,
        "stress_count": q_stress.count,
        "stress_last": q_stress.last,
        "artist_ids": q_ids,
        "metaphor": q_metaphor,
        "imagery": q_imagery,
    }

    seen: set[str] = set()
    wrap_pool: list[Hit] = []
    nearby_pool: list[Hit] = []
    vowel = sig.vowel_base if sig else (destressed.split()[0] if destressed else "")

    def take_person(sql: str, params: tuple, lane: str, score: float, why: str, bucket: list[Hit], limit: int) -> None:
        got = 0
        for row in con.execute(sql, params):
            key = (row["line"] or "").strip().lower()
            if key in seen:
                continue
            hit = _row_hit(row, query_end, lo, hi, cmu, lane, score, why, host_stress=q_stress, host_syl=syllables)
            if not usable_bar(hit.line):
                continue
            if len(hit.end_word) < 2 and hit.end_word != query_end:
                continue
            if lane == "wrap" and hit.window != "in":
                continue
            if lane == "nearby" and hit.window == "in":
                continue
            if lane in {"wrap", "nearby"} and hit.end_word != query_end and hit.rhyme is None:
                continue
            seen.add(key)
            bucket.append(hit)
            got += 1
            if got >= limit:
                break

    def coda_closeness(h: Hit) -> int:
        q_ds = destressed
        h_ds = h.destressed_class
        if not q_ds or not h_ds:
            return 3
        if h_ds == q_ds:
            return 0
        if q_ds.startswith(h_ds) or h_ds.startswith(q_ds):
            return 1
        return 2

    # Sweep every numbered roster person so Gunna/Baby/Future cannot monopolize SQL order.
    for num, _name in PEOPLE:
        if query_end:
            take_person(
                """SELECT * FROM bars
                   WHERE end_word = ? AND person_n = ? AND syllables BETWEEN ? AND ?
                   LIMIT 3""",
                (query_end, num, lo, hi),
                "wrap",
                3.0,
                f"exact `{query_end}` · person {num:02d}",
                wrap_pool,
                3,
            )
            for stem in morph_end_candidates(query_end)[1:]:
                take_person(
                    """SELECT * FROM bars
                       WHERE end_word = ? AND person_n = ? AND syllables BETWEEN ? AND ?
                       LIMIT 8""",
                    (stem, num, lo, hi),
                    "wrap",
                    2.8,
                    f"morph `{stem}` of `{query_end}` · person {num:02d}",
                    wrap_pool,
                    8,
                )
                take_person(
                    """SELECT * FROM bars
                       WHERE end_word LIKE ? AND end_word != ? AND person_n = ?
                         AND syllables BETWEEN ? AND ?
                       LIMIT 3""",
                    (f"%{stem}", query_end, num, lo, hi),
                    "wrap",
                    2.4,
                    f"morph-contains `{stem}` · person {num:02d}",
                    wrap_pool,
                    3,
                )
        if klass:
            take_person(
                """SELECT * FROM bars
                   WHERE phonetic_class = ? AND person_n = ? AND syllables BETWEEN ? AND ?
                     AND end_word != ?
                   LIMIT 3""",
                (klass, num, lo, hi, query_end),
                "wrap",
                2.0,
                f"same class `{klass}` · person {num:02d}",
                wrap_pool,
                3,
            )
        if vowel:
            take_person(
                """SELECT * FROM bars
                   WHERE destressed_class = ? AND person_n = ? AND syllables BETWEEN ? AND ?
                   LIMIT 4""",
                (vowel, num, lo, hi),
                "wrap",
                1.7,
                f"empty-coda slant `{vowel}` · person {num:02d}",
                wrap_pool,
                4,
            )
            take_person(
                """SELECT * FROM bars
                   WHERE vowel_base = ? AND person_n = ? AND syllables BETWEEN ? AND ?
                   LIMIT 12""",
                (vowel, num, lo, hi),
                "wrap",
                1.5,
                f"tight slant `{vowel}` · person {num:02d}",
                wrap_pool,
                12,
            )
            take_person(
                """SELECT * FROM bars
                   WHERE vowel_base = ? AND person_n = ?
                     AND (syllables < ? OR syllables > ?)
                   LIMIT 3""",
                (vowel, num, lo, hi),
                "nearby",
                1.0,
                f"same vowel, outside window · person {num:02d}",
                nearby_pool,
                3,
            )

    def wrap_key(h: Hit) -> tuple:
        if h.end_word == query_end:
            family = 0
        elif morph_kind(h.end_word, query_end) == "perfect":
            family = 1
        elif morph_kind(h.end_word, query_end) == "slant":
            family = 2
        else:
            family = 3
        kind = {"perfect": 0, "slant": 1, None: 2}.get(h.rhyme, 2)
        return (
            abs(h.syllables - syllables),
            -h.inner_score,
            -len(h.imagery),
            family,
            kind,
            coda_closeness(h),
            -h.stress_score,
            -h.score,
        )

    wrap_pool.sort(key=wrap_key)
    nearby_pool.sort(key=wrap_key)
    exact = [h for h in wrap_pool if h.end_word == query_end]
    morph_p = [
        h for h in wrap_pool
        if h.end_word != query_end and morph_kind(h.end_word, query_end) == "perfect"
    ]
    morph_s = [
        h for h in wrap_pool
        if h.end_word != query_end and morph_kind(h.end_word, query_end) == "slant"
    ]
    same_rime = [
        h for h in wrap_pool
        if h.end_word != query_end
        and h.rhyme == "perfect"
        and not morph_kind(h.end_word, query_end)
    ]
    slant = [
        h for h in wrap_pool
        if h.rhyme == "slant" and not morph_kind(h.end_word, query_end)
    ]
    qid_set = set(q_ids)

    def with_host(hits: list[Hit], rest_k: int, host_k: int = 2) -> list[Hit]:
        if not qid_set:
            return diversify(hits, rest_k + host_k, max_per=1)
        host = [h for h in hits if qid_set & set(h.artist_ids)]
        rest = [h for h in hits if not (qid_set & set(h.artist_ids))]
        return diversify(host, host_k, max_per=2) + diversify(rest, rest_k, max_per=1)

    def stamp(hits: list[Hit], lane: str) -> list[Hit]:
        for h in hits:
            h.lane = lane
        return hits

    next_bar = stamp(
        with_host(morph_p, 5, 2)
        + with_host(morph_s, 3, 1)
        + with_host(same_rime, 4, 1)
        + with_host(slant, 6, 1),
        "next",
    )
    host_norm = line.strip().lower()
    host_open = opening_tokens(line)
    replace_pool: list[Hit] = []
    seen_replace: set[str] = set()

    def replace_ok(hit: Hit, n: int) -> bool:
        if n < 1:
            return False
        if hit.end_word == query_end or hit.rhyme == "perfect":
            return True
        if hit.rhyme != "slant":
            return False
        sa, sb = signature_for(query_end, cmu), signature_for(hit.end_word, cmu)
        if not sa or not sb:
            return False
        ca, cb = consonant_coda(sa), consonant_coda(sb)
        return len(ca) == 1 and len(cb) == 1

    def consider_replace(hit: Hit) -> None:
        if not usable_bar(hit.line) or hit.window != "in":
            return
        key = hit.line.strip().lower()
        if key in seen_replace or key == host_norm:
            return
        n = prefix_overlap(host_open, opening_tokens(hit.line))
        if n < 1 or not replace_ok(hit, n):
            return
        start = " ".join(host_open[:n]) or hit.line.split()[0]
        hit.score = float(n) * 10 + hit.stress_score
        hit.why = f'same start "{start}" · finish `{hit.end_word}`'
        hit.lane = "replace"
        seen_replace.add(key)
        replace_pool.append(hit)

    for h in wrap_pool:
        consider_replace(h)

    # Completions of the started line: "I drip on my …"
    likes: list[str] = []
    for n in range(min(4, len(host_open)), 1, -1):
        likes.append(" ".join(host_open[:n]) + "%")
    if likes:
        like_sql = " OR ".join(["line LIKE ?"] * len(likes))
        for num, _name in PEOPLE:
            sql = (
                f"SELECT * FROM bars WHERE person_n = ? AND syllables BETWEEN ? AND ? "
                f"AND ({like_sql}) LIMIT 8"
            )
            for row in con.execute(sql, (num, lo, hi, *likes)):
                hit = _row_hit(
                    row, query_end, lo, hi, cmu, "replace", 0,
                    "prefix", host_stress=q_stress, host_syl=syllables,
                )
                consider_replace(hit)

    replace_pool.sort(
        key=lambda h: (
            abs(h.syllables - syllables),
            -h.inner_score,
            -len(h.imagery),
            0 if h.end_word == query_end else 1,
            -int(h.score),
        )
    )
    replace = stamp(with_host(replace_pool, 8, 2), "replace")
    def dedupe(hits: list[Hit], k: int) -> list[Hit]:
        seen: set[str] = set()
        out: list[Hit] = []
        for h in hits:
            key = h.line.strip().lower()
            if key in seen:
                continue
            seen.add(key)
            out.append(h)
            if len(out) >= k:
                break
        return out

    replace = dedupe(replace, 12)
    next_bar = dedupe(next_bar, 16)
    from craft import imagery_score as _img
    craft_rank = lambda h: (h.wrap_delta, -h.inner_score, -_img(h.line), -len(h.imagery))
    replace.sort(key=craft_rank)
    next_bar.sort(key=craft_rank)
    wrap = replace + next_bar
    nearby = stamp(diversify(nearby_pool, nearby_k, max_per=1), "next")

    # One *next-bar* hit per roster person (not the same end-word — that's Replace).
    best_by_person: dict[int, Hit] = {}
    for h in wrap_pool:
        n = h.person_n
        if n <= 0 or h.end_word == query_end:
            continue
        prev = best_by_person.get(n)
        if prev is None or wrap_key(h) < wrap_key(prev):
            best_by_person[n] = h
    roster = [best_by_person[n] for n, _ in PEOPLE if n in best_by_person]

    picture: list[Hit] = []
    q_proto = top_metaphor(line)
    if q_proto is not None:
        seeds = [t for t in q_proto.terms if t in {w.lower() for w in line.split()}]
        if not seeds:
            seeds = list(q_imagery)[:3]
        seeds = seeds or ["___none___"]
        like_clauses = " OR ".join(["line LIKE ?"] * len(seeds))
        like_params = tuple(f"%{s}%" for s in seeds)
        scored: list[Hit] = []
        for num, _name in PEOPLE:
            sql = f"SELECT * FROM bars WHERE person_n = ? AND ({like_clauses}) LIMIT 4"
            for row in con.execute(sql, (num, *like_params)):
                key = (row["line"] or "").strip().lower()
                label, overlap = picture_overlap(line, row["line"])
                if overlap <= 0 or not label:
                    continue
                hit = _row_hit(
                    row, query_end, lo, hi, cmu, "picture", float(overlap),
                    f"same picture `{label}` · person {num:02d}",
                    host_stress=q_stress, host_syl=syllables,
                )
                hit.metaphor = label
                scored.append(hit)
        scored.sort(key=lambda h: (abs(h.syllables - syllables), -h.inner_score, -h.score))
        picture = diversify(scored, picture_k, max_per=1)

    query["roster_hit_count"] = len(roster)
    query["roster_people"] = [h.people for h in roster]
    stamp(roster, "next")
    stamp(picture, "picture")

    return {
        "query": query,
        "replace": replace,
        "next": next_bar,
        "wrap": wrap,
        "nearby": nearby,
        "picture": picture,
        "roster": roster,
    }
