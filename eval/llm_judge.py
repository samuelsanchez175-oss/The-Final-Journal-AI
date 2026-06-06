"""Model G — LLM-judge (the semantic ceiling the mechanical grader can't reach).

The mechanical/typicality grader is a FLOOR: it rejects word-salad and over-polished AI by
matching the authentic distribution, but it cannot tell a GREAT line from a competent one. "Is
there a real drug pun? does it play family x luxury? does 'Uzi' land as gun/rapper/jewelry at
once? does it sound like a human rapper or a brand's caption?" — that is semantic judgment, and
only an LLM can do it. This module is that judge.

It scores a verse on six semantic axes via Claude (claude-opus-4-8) with structured JSON output,
and is seeded with the entity knowledge base (rapper/drug lexicons) so it can verify cultural
references (Slime = Young Thug/YSL, Uzi = Lil Uzi Vert / gun / jewelry, regional drug aliases).

Run where an ANTHROPIC_API_KEY exists (your machine / CI / the app) — not in the eval sandbox.
    pip install anthropic
    python3 eval/llm_judge.py --verse path/to/verse.txt [--section verse|hook]
"""
import os, sys, json, argparse

AXES = ["wordplay", "specificity", "flow", "slang_coinage", "effortlessness",
        "authenticity", "range", "human_not_caption", "punchline"]

JUDGE_SYSTEM = """You are a veteran rap A&R and ghostwriter with an ear for what's REAL, judging \
verses in the melodic-trap lineage of Gunna, Young Thug, and Lil Uzi Vert.

CRUCIAL FRAME: the artist is usually a NEW, independent rapper — NOT Gunna/Thug/Uzi. Treat that \
corpus as the CRAFT reference (how to build flow, wordplay, drip, effortlessness), NOT a life to \
borrow. Content authenticity is judged against the artist's OWN profile (city, come-up, crew, \
boundaries), provided below when available.

Score each axis 0-10 (0 = absent / AI-tell, 10 = elite):
- wordplay: real double-entendres / puns (drug-gun-money-sex multi-meaning; "Uzi" = gun/rapper/jewelry).
- specificity: concrete, lived, surprising detail — including DRIP precision (exact item, colorway, \
fabric), not generic flexing.
- flow: pocket/cadence inventiveness — rhythm switches, vowel-stretching, riding vs breaking the beat \
(the melodic-trap signature; judge the text's shadow of it).
- slang_coinage: fresh slang / lexical invention vs recycled cliche (this lineage INVENTS language).
- effortlessness: calm, unbothered "cool" — confidence without strain; trying-too-hard or \
over-explaining is the tell.
- authenticity: does it ring TRUE to THIS artist (per profile)? PENALIZE borrowed-lineage flexing — \
claiming "Slime"/YSL/insider codes, or a trap/violence/drug life, that isn't theirs. For a new artist, \
faking an OG's life is the WORST inauthenticity even when well-crafted; reward their OWN truth (their \
block, their come-up, their people, their slang).
- range: moving between family, luxury, and casual taboo in one breath without flinching — WITHIN what \
is true for this artist.
- human_not_caption: sounds like a human rapper, not an Instagram caption or motivational poster.
- punchline: at least one line you'd rewind.

PENALIZE generally: generic gratitude/"blessed"/manifestation rap, over-explanation, vague \
brand-drops with no image.

`overall` is 0-100. `best_line` = strongest bar verbatim. `weakest_tell` = the most AI-sounding OR \
most inauthentic-to-this-artist line verbatim, or "none". `verdict` = one blunt sentence: does this \
sound like a real, authentic verse for THIS artist?"""

_AXIS = {"type": "object", "additionalProperties": False,
         "properties": {"score": {"type": "integer"}, "note": {"type": "string"}},
         "required": ["score", "note"]}
SCHEMA = {"type": "object", "additionalProperties": False,
          "properties": {**{a: _AXIS for a in AXES},
                         "overall": {"type": "integer"}, "best_line": {"type": "string"},
                         "weakest_tell": {"type": "string"}, "verdict": {"type": "string"}},
          "required": AXES + ["overall", "best_line", "weakest_tell", "verdict"]}


def _glossary(limit=40):
    """Compact entity hints from the knowledge base so the judge can verify references."""
    import csv
    base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lexicons")
    out = []
    for fn, kcol, vcol in [("rapper_lexicon.csv", "term", "codes_note"),
                           ("drug_lexicon.csv", "canonical", "note")]:
        p = os.path.join(base, fn)
        if not os.path.exists(p):
            continue
        for r in list(csv.DictReader(open(p, encoding="utf-8")))[:limit]:
            who = r.get("canonical") or r.get(kcol, "")
            note = r.get(vcol, "")
            ali = r.get("aliases", "")
            out.append(f"- {r.get(kcol,'')}" + (f" = {who}" if who and who != r.get(kcol,'') else "")
                       + (f" (aka {ali})" if ali else "") + (f": {note}" if note else ""))
    return "\n".join(out)


def judge_verse(lines, section="verse", profile=None, model="claude-opus-4-8"):
    import anthropic
    client = anthropic.Anthropic()
    glossary = _glossary()
    prof = ("\nARTIST PROFILE — judge authenticity against THIS, not YSL/insider lineage:\n"
            + json.dumps(profile, indent=2) + "\n") if profile else \
           "\n(No artist profile supplied — judge authenticity by internal consistency, and still " \
           "penalize borrowed-lineage flexing the writer plainly hasn't earned.)\n"
    user = (f"Section type: {section}\n" + prof
            + (f"\nReference glossary (recognize these, but do NOT reward a new artist for borrowing "
               f"them unless the profile makes them genuinely his):\n{glossary}\n" if glossary else "")
            + "\nGrade this verse:\n\"\"\"\n" + "\n".join(lines) + "\n\"\"\"")
    resp = client.messages.create(
        model=model,
        max_tokens=2000,
        thinking={"type": "adaptive"},
        system=JUDGE_SYSTEM,
        messages=[{"role": "user", "content": user}],
        output_config={"format": {"type": "json_schema", "schema": SCHEMA}, "effort": "high"},
    )
    text = next(b.text for b in resp.content if b.type == "text")
    return json.loads(text)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Model G LLM-judge — semantic quality of a verse")
    ap.add_argument("--verse", required=True, help="verse file, one bar per line")
    ap.add_argument("--section", choices=["verse", "hook"], default="verse")
    ap.add_argument("--profile", help="path to a user-profile JSON (grounds authenticity in the artist's truth)")
    ap.add_argument("--model", default="claude-opus-4-8")
    a = ap.parse_args()
    if not os.environ.get("ANTHROPIC_API_KEY"):
        sys.exit("Set ANTHROPIC_API_KEY to run the judge (it calls Claude).")
    lines = [l.strip() for l in open(a.verse, encoding="utf-8") if l.strip()]
    profile = json.load(open(a.profile, encoding="utf-8")) if a.profile else None
    r = judge_verse(lines, section=a.section, profile=profile, model=a.model)
    print(f"\nLLM-judge ({a.model})  —  OVERALL {r['overall']}/100")
    for ax in AXES:
        print(f"  {ax:18}{r[ax]['score']:>3}/10   {r[ax]['note']}")
    print(f"\n  best line   : {r['best_line']}")
    print(f"  weakest tell: {r['weakest_tell']}")
    print(f"  verdict     : {r['verdict']}")
