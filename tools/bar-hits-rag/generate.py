"""Authored originals first (harness-gated), then catalog grafts if they pass."""

from __future__ import annotations

from craft import inner_rhyme_score, syllable_count, wrap_distance
from harness import evaluate
from retrieve import Hit, wrap_window
from rhyme import classify_rhyme, end_word
from stress import profile as stress_profile

ORIGINALS: dict[str, dict[str, list[str]]] = {
    "I just left the dentist on fleek": {
        "replace": [
            "I just left the jeweler on fleek",
            "I just left the barber on fleek",
            "I just left the dealer on fleek",
        ],
        "next": [
            "Hit her through the whole week",
            "Ice on me, that's the peak",
            "Never cheap, I stay sleek",
        ],
    },
    "I went and bought a four by four": {
        "replace": [
            "I went and copped a four by four",
            "I pulled up in a four by four",
            "I went and bought a two-door, more",
        ],
        "next": [
            "Kicking in your front door",
            "That's the whip, that's the war",
            "Parked so far they can't score",
        ],
    },
    "I eat her flesh, you know the rest": {
        "replace": [
            "I ate it down, you know the rest",
            "I eat her up, you know the rest",
            "I took that down, you know the rest",
        ],
        "next": [
            "Hand on my chest, I feel blessed",
            "Put it on her chest",
            "Never tap, that's the test",
        ],
    },
    "I treat all of my dawgs the same": {
        "replace": [
            "I treat all of my dogs the same",
            "I keep all of my dawgs the same",
            "I treat all of my kin the same",
        ],
        "next": [
            "Put respect on the name",
            "That's my brother, that's the game",
            "Never fold in the flame",
        ],
    },
    "I got these diamonds, my chain swang": {
        "replace": [
            "I got these rubies, my chain swang",
            "I got these VVS, my chain swang",
            "I got these stones, my chain swang",
        ],
        "next": [
            "Shots in the air, that's a bang",
            "Ice so loud, hear it rang",
            "Never cheap, that's the gang",
        ],
    },
    "We gon' make a thriller like Mike": {
        "replace": [
            "We gon' make a movie like Mike",
            "We gon' make a classic like Mike",
            "We gon' make a killer like Mike",
        ],
        "next": [
            "Never scared in the night",
            "Moonwalk on 'em, that's the light",
            "Keep the glove, that's the fight",
        ],
    },
    "I pay for my shit, ain't shit free": {
        "replace": [
            "I pay for my cars, ain't shit free",
            "I pay for my ice, ain't shit free",
            "I pay for my dogs, ain't shit free",
        ],
        "next": [
            "Ice on the wrist, you can see",
            "Count to three, watch it freeze",
            "Never ask, I don't plead",
        ],
    },
    "I'm with some Crips, down with some Locs": {
        "replace": [
            "I'm with some Bloods, down with some Locs",
            "I'm with some Crips, down with some folks",
            "I'm with some slimes, down with some Locs",
        ],
        "next": [
            "Rollin' up, that's the smoke",
            "Never fold, that's the code",
            "Keep a pole, that's the oath",
        ],
    },
    "We smokin' these niggas like kush": {
        "replace": [
            "We rollin' these niggas like kush",
            "We packin' these niggas like kush",
            "We smokin' the opps like kush",
        ],
        "next": [
            "Never fold, that's the push",
            "Keep it loud, that's the bush",
            "Ash on the floor, that's the kush",
        ],
    },
    "I just left your watch in the mud": {
        "replace": [
            "I just left your chain in the mud",
            "I just left your whip in the mud",
            "I just left your ice in the mud",
        ],
        "next": [
            "Drippin' red, that's the blood",
            "Rain on the block, that's a flood",
            "Never clean, that's the mud",
        ],
    },
}


def _words(line: str) -> list[str]:
    return (line or "").split()


def _graft_replace(host: str, donor: str) -> list[tuple[str, list[str]]]:
    hw, dw = _words(host), _words(donor)
    if len(hw) < 4 or len(dw) < 4:
        return []
    keep = min(2, len(hw) - 1)
    prefix = " ".join(hw[:keep])
    out = []
    for take in (3, 4):
        if take >= len(dw):
            continue
        cand = f"{prefix} {' '.join(dw[-take:])}"
        if cand.strip().lower() != host.strip().lower():
            out.append((cand, [host, donor]))
    return out


def _graft_next(a: str, b: str) -> list[tuple[str, list[str]]]:
    aw, bw = _words(a), _words(b)
    if len(aw) < 4 or len(bw) < 3:
        return []
    out = []
    head = min(3, len(aw) - 1)
    cand = " ".join(aw[:head] + bw[-2:])
    if cand.strip().lower() not in {a.strip().lower(), b.strip().lower()}:
        out.append((cand, [a, b]))
    if len(bw) >= 3:
        cand2 = " ".join(aw[:2] + bw[-3:])
        if cand2.strip().lower() not in {a.strip().lower(), b.strip().lower()}:
            out.append((cand2, [a, b]))
    return out


def _hit(line: str, host: str, cmu: dict, lane: str, syl_hint: int) -> Hit:
    ew = end_word(line)
    he = end_word(host)
    from rhyme import classify_rhyme

    rhyme = classify_rhyme(he, ew, cmu)
    lo, hi = wrap_window(syl_hint)
    syl = syllable_count(line, cmu)
    st = stress_profile(line, cmu, ew)
    inner = inner_rhyme_score(line, cmu)
    return Hit(
        id=f"gen:{lane}:{ew}:{abs(hash(line))%99999}",
        line=line,
        artist="original",
        song="",
        syllables=syl,
        end_word=ew,
        phonetic_class="",
        destressed_class="",
        people="original",
        artist_ids=["original"],
        person_n=0,
        lane=lane,
        window="in" if lo <= syl <= hi else "nearby",
        rhyme=rhyme,
        rhyme_pair=he,
        metaphor="",
        imagery=[],
        score=10.0,
        why="grafted from catalog · passed harness",
        stress_words=st.words,
        stress_score=0,
        stress_note="",
        inner_score=inner,
        wrap_delta=wrap_distance(syl, syl_hint),
        spans=[],
    )


def generate_pair(
    host: str,
    syllables: int,
    cmu: dict,
    donors: list,
) -> tuple[list[Hit], list[Hit]]:
    donor_lines = []
    donor_set: set[str] = set()
    for d in donors:
        line = d.line if hasattr(d, "line") else str(d)
        key = line.strip().lower()
        if key and key != host.strip().lower():
            donor_lines.append(line)
            donor_set.add(key)

    authored_rep: list[Hit] = []
    authored_nxt: list[Hit] = []
    crafted = ORIGINALS.get(host.strip())
    if crafted:
        for s in crafted.get("replace") or []:
            if s.strip().lower() in donor_set:
                continue
            ok, _ = evaluate(host, s, "gen-replace", cmu, syllables)
            if ok:
                authored_rep.append(_hit(s, host, cmu, "gen-replace", syllables))
        for s in crafted.get("next") or []:
            if s.strip().lower() in donor_set:
                continue
            ok, _ = evaluate(host, s, "gen-next", cmu, syllables)
            if ok:
                authored_nxt.append(_hit(s, host, cmu, "gen-next", syllables))
        authored_rep.sort(key=lambda h: (h.wrap_delta, -h.inner_score))
        authored_nxt.sort(key=lambda h: (h.wrap_delta, -h.inner_score))

    raw_rep: list[tuple[str, list[str]]] = []
    raw_nxt: list[tuple[str, list[str]]] = []
    for d in donor_lines[:24]:
        raw_rep.extend(_graft_replace(host, d))
    for i, a in enumerate(donor_lines[:12]):
        for b in donor_lines[i + 1 : i + 6]:
            raw_nxt.extend(_graft_next(a, b))

    def sift(cands: list[tuple[str, list[str]]], job: str, cap: int) -> list[Hit]:
        seen: set[str] = set()
        out: list[Hit] = []
        for cand, sources in cands:
            key = cand.strip().lower()
            if key in seen:
                continue
            ok, _reasons = evaluate(
                host, cand, "gen-replace" if job == "replace" else "gen-next",
                cmu, syllables, sources=sources,
            )
            if not ok:
                continue
            seen.add(key)
            lane = "gen-replace" if job == "replace" else "gen-next"
            out.append(_hit(cand, host, cmu, lane, syllables))
            if len(out) >= cap:
                break
        return out

    grafted_rep, grafted_nxt = sift(raw_rep, "replace", 6), sift(raw_nxt, "next", 6)
    # Authored lines first; grafts only fill empty slots.
    rep = authored_rep + [h for h in grafted_rep if h.line not in {x.line for x in authored_rep}]
    nxt = authored_nxt + [h for h in grafted_nxt if h.line not in {x.line for x in authored_nxt}]
    return rep[:6], nxt[:6]
