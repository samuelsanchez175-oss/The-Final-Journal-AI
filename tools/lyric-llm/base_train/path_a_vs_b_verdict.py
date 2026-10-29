#!/usr/bin/env python3
"""Phase B verdict: score Path A (gpt-4o-mini + catalog) vs Path B (v5 LoRA fine-tune).

Reads existing model_comparison outputs, scores each verse against the artist's
anchor profile when one exists (Gunna today; others fall back to generic
rhyme/syllable sanity), writes a JSON verdict, and patches
`tools/lyric-llm/model_registry.json` with `eval_report` and `cost_usd` for
`v5-base-50k`.

Usage:
  python3 base_train/path_a_vs_b_verdict.py \\
      --path-a ../style-profile/out/model_comparison.pathA-done-20261027-1251.json \\
      --path-b ../style-profile/out/model_comparison_pathB_lora_v3.json
"""
from __future__ import annotations

import argparse
import datetime
import json
import re
import statistics
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent.parent
LLM_ROOT = REPO_ROOT / "tools" / "lyric-llm"
STYLE_ROOT = REPO_ROOT / "tools" / "style-profile"

sys.path.insert(0, str(STYLE_ROOT))

try:
    import gunna_score  # type: ignore
    import phase1_song_metrics as p1  # type: ignore
    HAVE_GUNNA = True
except Exception as exc:  # pragma: no cover
    print(f"gunna_score unavailable: {exc}", file=sys.stderr)
    HAVE_GUNNA = False


_VOWELS = set("aeiou")


def syllables(word: str) -> int:
    w = re.sub(r"[^a-z]", "", word.lower())
    if not w:
        return 0
    count = 0
    prev_vowel = False
    for ch in w:
        is_vowel = ch in _VOWELS
        if is_vowel and not prev_vowel:
            count += 1
        prev_vowel = is_vowel
    if w.endswith("e") and count > 1:
        count -= 1
    return max(count, 1)


def line_syllables(line: str) -> int:
    return sum(syllables(w) for w in re.findall(r"[A-Za-z']+", line))


def end_word(line: str) -> str:
    words = re.findall(r"[A-Za-z']+", line)
    return words[-1].lower() if words else ""


def rhyme_hit(a: str, b: str) -> bool:
    if not a or not b:
        return False
    return a[-2:] == b[-2:] or a[-3:] == b[-3:]


def generic_score(bars: list[str]) -> dict:
    if not bars:
        return {"score": 0.0, "mean_syl": 0.0, "rhyme_density": 0.0, "bars": 0}
    syls = [line_syllables(b) for b in bars]
    ends = [end_word(b) for b in bars]
    hits = sum(1 for i in range(1, len(ends)) if rhyme_hit(ends[i - 1], ends[i]))
    rhyme = hits / max(len(ends) - 1, 1)
    mean_syl = statistics.mean(syls) if syls else 0.0
    syl_consistency = 1.0 - min(1.0, (statistics.pstdev(syls) / max(mean_syl, 1.0)))
    composite = 0.5 * rhyme + 0.5 * syl_consistency
    return {
        "score": round(composite, 4),
        "mean_syl": round(mean_syl, 2),
        "rhyme_density": round(rhyme, 4),
        "syl_consistency": round(syl_consistency, 4),
        "bars": len(bars),
    }


def gunna_score_bars(bars: list[str], profile, lex) -> dict:
    if not HAVE_GUNNA or not bars:
        return generic_score(bars)
    try:
        out = gunna_score.score_lines(bars, profile, lex)
        return {
            "score": round(float(out.get("score", 0.0)), 4),
            "components": {k: v for k, v in out.items() if k != "score"},
            "bars": len(bars),
        }
    except Exception as exc:
        print(f"gunna_score failed on bars; falling back: {exc}", file=sys.stderr)
        return generic_score(bars)


def extract_bars(entry: dict, model_key: str) -> list[str]:
    bars = entry.get("models", {}).get(model_key, {}).get("bars", [])
    out = []
    for b in bars:
        text = (b.get("text") or "").strip()
        if text:
            out.append(text)
    return out


def score_file(path: Path, model_key: str, profile=None, lex=None, artist_filter: str | None = None,
               profile_artist: str | None = None, profiles_by_artist: dict | None = None) -> dict:
    """Score each entry.

    Two modes:
      - single-profile (legacy): `profile` + `profile_artist`. Applies voice score only to
        entries whose artist matches `profile_artist`; everything else falls back to generic.
      - multi-profile: pass `profiles_by_artist` as {artist_lower: profile_dict}. Applies the
        matching profile per row, falls back to generic for artists with no profile. Overrides
        the single-profile path when provided.
    """
    data = json.loads(path.read_text(encoding="utf-8"))
    if artist_filter:
        data = [e for e in data if e.get("artist", "").lower() == artist_filter.lower()]
    profile_artist_norm = (profile_artist or (profile or {}).get("artist") or "Gunna").lower()
    per_entry: list[dict] = []
    for entry in data:
        bars = extract_bars(entry, model_key)
        artist_key = (entry.get("artist") or "").lower()
        row_profile = None
        if profiles_by_artist:
            row_profile = profiles_by_artist.get(artist_key)
        elif profile is not None and artist_key == profile_artist_norm:
            row_profile = profile
        if row_profile is not None and lex is not None and bars:
            s = gunna_score_bars(bars, row_profile, lex)
            scored_as = "voice_profile"
        else:
            s = generic_score(bars)
            scored_as = "generic"
        per_entry.append({
            "artist": entry.get("artist"),
            "topic": entry.get("topic"),
            "model": model_key,
            "scored_as": scored_as,
            **s,
        })
    voice_scores = [e["score"] for e in per_entry if e.get("scored_as") == "voice_profile" and e.get("score") is not None]
    generic_scores = [e["score"] for e in per_entry if e.get("scored_as") == "generic" and e.get("score") is not None]
    voice_mean = round(statistics.mean(voice_scores), 4) if voice_scores else None
    generic_mean = round(statistics.mean(generic_scores), 4) if generic_scores else None
    # Headline aggregate uses whichever scale is present. When both are present (mixed
    # artist comparison without --artist-filter), the voice-profile mean is the honest
    # headline — mixing 0-100 with 0-1 in one mean would dilute voice-score deltas by
    # ~100x. Both means are also reported so downstream consumers see both scales.
    if voice_mean is not None:
        aggregate = voice_mean
        aggregate_scale = "voice_profile"
    elif generic_mean is not None:
        aggregate = generic_mean
        aggregate_scale = "generic"
    else:
        aggregate = 0.0
        aggregate_scale = "none"
    return {
        "file": str(path),
        "model_key": model_key,
        "n_entries": len(per_entry),
        "aggregate_score": aggregate,
        "aggregate_scale": aggregate_scale,
        "voice_only_mean": voice_mean,
        "generic_only_mean": generic_mean,
        "voice_n": sum(1 for e in per_entry if e.get("scored_as") == "voice_profile"),
        "generic_n": sum(1 for e in per_entry if e.get("scored_as") == "generic"),
        "per_entry": per_entry,
    }


def patch_registry(cost_usd: float, verdict_path: Path, verdict: dict) -> None:
    reg_path = LLM_ROOT / "model_registry.json"
    if not reg_path.exists():
        # On a fresh checkout the registry may not exist yet; skip the patch instead of
        # crashing after we already wrote the verdict file. --no-patch-registry gives
        # the explicit opt-out; this handles the implicit "nothing to patch" case.
        print(f"skip registry patch (no {reg_path.name} on disk)", file=sys.stderr)
        return
    reg = json.loads(reg_path.read_text(encoding="utf-8"))
    v5 = reg.get("models", {}).get("v5-base-50k", {})
    v5["cost_usd"] = round(cost_usd, 4)
    abs_path = verdict_path.resolve()
    try:
        v5["eval_report"] = str(abs_path.relative_to(REPO_ROOT))
    except ValueError:
        v5["eval_report"] = str(abs_path)
    v5["eval_summary"] = {
        "path_a_aggregate": verdict["path_a"]["aggregate_score"],
        "path_b_aggregate": verdict["path_b"]["aggregate_score"],
        "delta": round(verdict["path_b"]["aggregate_score"] - verdict["path_a"]["aggregate_score"], 4),
        "verdict": verdict["verdict"],
    }
    reg["models"]["v5-base-50k"] = v5
    reg_path.write_text(json.dumps(reg, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path-a", type=Path, required=True)
    ap.add_argument("--path-b", type=Path, required=True)
    ap.add_argument("--path-a-key", default="v5_pathA")
    ap.add_argument("--path-b-key", default="v5_pathB_lora")
    ap.add_argument("--profile", type=Path, default=STYLE_ROOT / "out" / "anchor_profile_gunna.json",
                    help="Single-profile mode. Ignored when --profile-dir is passed.")
    ap.add_argument("--profile-dir", type=Path, default=STYLE_ROOT / "out",
                    help="Multi-profile mode: directory containing anchor_profile_*.json. "
                         "Each row scores against its matching artist profile; artists with no "
                         "profile fall back to generic. Pass '' to disable and use --profile.")
    ap.add_argument("--cmudict", type=Path, default=REPO_ROOT / "XJournal AI" / "cmudict.txt")
    ap.add_argument("--out", type=Path, default=LLM_ROOT / "out" / "path_a_vs_b_verdict.json")
    ap.add_argument("--cost-usd", type=float, default=8.1213,
                    help="Together.ai spend for job ft-a2211706-c2ae (nano-dollars 8_121_312_000 / 1e9)")
    ap.add_argument("--no-patch-registry", action="store_true")
    ap.add_argument("--artist-filter", help="Score only entries whose artist matches (case-insensitive)")
    args = ap.parse_args()

    profile = None
    lex = None
    profiles_by_artist: dict = {}
    if HAVE_GUNNA and args.cmudict.exists():
        try:
            lex = p1.Lexicon(p1.load_cmudict(args.cmudict))
        except Exception as exc:
            print(f"lexicon load failed: {exc}", file=sys.stderr)
    use_multi = bool(args.profile_dir) and args.profile_dir.exists()
    if HAVE_GUNNA and use_multi and lex is not None:
        for pf in sorted(args.profile_dir.glob("anchor_profile_*.json")):
            try:
                prof = gunna_score.load_profile(pf)
            except Exception as exc:
                print(f"skip {pf.name}: {exc}", file=sys.stderr)
                continue
            artist_key = (prof.get("artist") or pf.stem.replace("anchor_profile_", "")).lower()
            profiles_by_artist[artist_key] = prof
        print(f"loaded {len(profiles_by_artist)} voice profile(s): "
              f"{sorted(profiles_by_artist.keys())}", file=sys.stderr)
    elif HAVE_GUNNA and args.profile.exists() and lex is not None:
        try:
            profile = gunna_score.load_profile(args.profile)
        except Exception as exc:
            print(f"profile load failed, generic scoring only: {exc}", file=sys.stderr)

    profile_artist = (profile or {}).get("artist") if profile else None
    a = score_file(args.path_a, args.path_a_key, profile, lex, args.artist_filter,
                   profile_artist, profiles_by_artist or None)
    b = score_file(args.path_b, args.path_b_key, profile, lex, args.artist_filter,
                   profile_artist, profiles_by_artist or None)

    delta = round(b["aggregate_score"] - a["aggregate_score"], 4)
    # Verdict scale follows aggregate scale: voice-profile is 0-100 (2.0 threshold ~=
    # 5% movement); generic is 0-1 (0.02 threshold ~= same relative movement). The
    # scale is explicit from aggregate_scale so this is no longer a magnitude guess.
    scale = a.get("aggregate_scale") or b.get("aggregate_scale") or "none"
    threshold = 2.0 if scale == "voice_profile" else 0.02
    if delta > threshold:
        verdict = "path_b_wins"
    elif delta < -threshold:
        verdict = "path_a_wins"
    else:
        verdict = "tie_within_threshold"

    scored_as_summary = (
        f"multi-profile ({len(profiles_by_artist)} artists)"
        if profiles_by_artist else
        f"single-profile ({profile_artist or 'none'})"
    )
    out = {
        "generated_at": datetime.date.today().isoformat(),
        "job_id": "ft-a2211706-c2ae",
        "cost_usd": args.cost_usd,
        "scoring": scored_as_summary,
        "path_a": {k: v for k, v in a.items() if k != "per_entry"},
        "path_b": {k: v for k, v in b.items() if k != "per_entry"},
        "delta": delta,
        "verdict": verdict,
        "notes": "Per-row voice score when the artist has a profile, else generic. "
                 "Aggregate uses whichever scale dominates (voice_profile 0-100 or generic 0-1); "
                 "see aggregate_scale. paired_prompts is the (artist, topic) intersection.",
    }
    # Per-artist breakdown: whole-set means and the subset of same-prompt pairs.
    def _by_artist(rows: list[dict]) -> dict:
        out: dict = {}
        for r in rows:
            out.setdefault((r.get("artist") or "").lower(), []).append(r)
        return out
    a_by, b_by = _by_artist(a["per_entry"]), _by_artist(b["per_entry"])
    per_artist: list[dict] = []
    for art in sorted(set(a_by) | set(b_by)):
        ar, br = a_by.get(art, []), b_by.get(art, [])
        a_mean = round(statistics.mean(r["score"] for r in ar), 3) if ar else None
        b_mean = round(statistics.mean(r["score"] for r in br), 3) if br else None
        per_artist.append({
            "artist": art,
            "a_n": len(ar), "b_n": len(br),
            "a_mean": a_mean, "b_mean": b_mean,
            "delta_b_minus_a": (round(b_mean - a_mean, 3)
                                 if (a_mean is not None and b_mean is not None) else None),
            "scale": (ar[0]["scored_as"] if ar else br[0]["scored_as"]) if (ar or br) else "none",
        })
    out["per_artist"] = per_artist

    pb_lookup = {(r.get("artist"), r.get("topic")): r for r in b["per_entry"]}
    paired: list[dict] = []
    for ra in a["per_entry"]:
        rb = pb_lookup.get((ra.get("artist"), ra.get("topic")))
        if rb is None or ra["scored_as"] != rb["scored_as"]:
            continue
        paired.append({
            "artist": ra.get("artist"), "topic": ra.get("topic"),
            "scored_as": ra["scored_as"],
            "a_score": ra["score"], "b_score": rb["score"],
            "delta_b_minus_a": round(rb["score"] - ra["score"], 3),
        })
    out["paired_prompts"] = paired
    out["paired_n"] = len(paired)
    out["detail"] = {"path_a_per_entry": a["per_entry"], "path_b_per_entry": b["per_entry"]}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote {args.out}")
    print(f"Path A aggregate: {a['aggregate_score']}  "
          f"(voice n={a['voice_n']}, generic n={a['generic_n']})")
    print(f"Path B aggregate: {b['aggregate_score']}  "
          f"(voice n={b['voice_n']}, generic n={b['generic_n']})")
    print(f"Delta: {delta}  Verdict: {verdict}")

    if not args.no_patch_registry:
        patch_registry(args.cost_usd, args.out, out)
        print("Patched model_registry.json: cost_usd + eval_report + eval_summary on v5-base-50k")
    return 0


if __name__ == "__main__":
    sys.exit(main())
