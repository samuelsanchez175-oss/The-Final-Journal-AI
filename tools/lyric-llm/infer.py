#!/usr/bin/env python3
"""Generate bars in a chosen voice, steered by BPM.

  python3 infer.py --list-voices
  python3 infer.py --voice "Gunna" --bpm 140 --bars 8
  python3 infer.py --voice "Gunna" --blend "Young Thug" --mix 70 --bpm 140 --bars 16 --seed 7 \\
      --seed-line "Count the room before I say the number"
  python3 infer.py --compare --voice "Gunna" --blend "Young Thug" --mix 70 --bpm 140 \\
      --bars 16 --seed 7 --seed-line "Count the room before I say the number"
  python3 infer.py --voice custom --bpm 130 --exemplar notes.txt --bars 8

BPM sets the line budget: 8 syllables at 70 BPM and 14 at 140, linear
in between. The sampler closes each bar when that count is reached. Scale is
written in the prefix with the tempo and does not change the budget. A pair
uses the same voice, scale, and seed:

  python3 infer.py --voice "Gunna" --scale "A minor" --bars 16 --seed 7 --tempos 70,140

--mix 70 with --blend asks for 70% of the --voice distribution and 30% of the
blend voice. --compare writes the two solo voices and that mix from the same
seed, the same opening line, and the same BPM.
"""

from __future__ import annotations

import argparse
import math
import json
import random
import sqlite3
import statistics
import sys
from pathlib import Path

from lyriclib import (
    bucket_bpm,
    control_prefix,
    corpus_bpm_syllables,
    end_rime,
    estimate_syllables,
    line_reached_budget,
    load_cmudict,
    normalize,
    originality_hit,
    read_json,
    tag_safe,
    target_syllables,
    tempo_line_syllables,
    tokenize,
    voice_token,
)

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
CMU = HERE.parent.parent / "XJournal AI" / "cmudict.txt"
_RHYME_CACHE: dict = {}

ADLIB_TAILS = {
    "yeah", "yea", "yah", "uh", "oh", "ooh", "woah", "whoa", "ayy", "ay", "hey",
    "huh", "nah", "ha", "haha", "ok", "okay", "slatt", "skrrt", "woo", "ah", "ahh",
    "mmm", "hm", "hmm", "bah", "bow", "brr", "brrt", "grrt", "gang", "baby", "boy",
    "man", "bro", "dawg", "dog", "nigga", "niggas", "bitch", "bitches", "shit",
    "fuck", "damn", "god", "lord", "ya", "yo", "yuh", "what", "wait",
}


def list_voices(path: Path) -> int:
    if not path.exists():
        print("Missing %s. Run: python3 train.py --list-voices" % path, file=sys.stderr)
        return 1
    names = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    print("%d voices" % len(names))
    counts_path = path.with_name("voice_counts.json")
    if counts_path.exists():
        counts = json.loads(counts_path.read_text(encoding="utf-8"))
        thin = sum(1 for row in counts.values() if not row.get("reliable"))
        print("flagged thin: %d" % thin)
    for name in names:
        print(name)
    return 0


def load_voice_counts(path: Path) -> dict:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


class MixError(ValueError):
    """The mix string or the two voice names cannot be sampled."""


def parse_mix(text: str):
    """Return (voice share, blend share). '70' and '70/30' both mean 70/30.

    The first number is the --voice share. The two numbers must add to 100.
    """
    raw = (text or "").strip()
    if not raw:
        raise MixError("A weighted blend needs --mix, for example 70 or 70/30.")
    if "/" in raw:
        bits = raw.split("/")
        if len(bits) != 2:
            raise MixError("Write the mix as 70 or 70/30.")
        try:
            primary = int(bits[0].strip())
            secondary = int(bits[1].strip())
        except ValueError:
            raise MixError("Write the mix as 70 or 70/30.")
        if primary + secondary != 100:
            raise MixError("The two mix numbers must add to 100.")
    else:
        try:
            primary = int(raw)
        except ValueError:
            raise MixError("Write the mix as 70 or 70/30.")
        secondary = 100 - primary
    if primary <= 0 or secondary <= 0 or primary >= 100 or secondary >= 100:
        raise MixError("Each side of the mix needs a share from 1 to 99.")
    return primary, secondary


def softmax(scores):
    if not scores:
        return []
    peak = max(scores)
    # Subtract the peak so a large score cannot overflow the exponent.
    exps = [math.exp(s - peak) for s in scores]
    total = sum(exps) or 1.0
    return [value / total for value in exps]


def mix_probs(left, right, left_share):
    """70/30 means each token is drawn from 0.70 P(voice) + 0.30 P(blend)."""
    share = float(left_share)
    other = 1.0 - share
    if len(left) != len(right):
        raise MixError("The two voice scores differ in length.")
    return [(share * a) + (other * b) for a, b in zip(left, right)]


def nucleus_mask(probs, top_p):
    """Keep the smallest high-probability set whose mass reaches top-p."""
    limit = float(top_p)
    if limit >= 1:
        return list(probs)
    if limit <= 0:
        raise MixError("top-p must be above 0.")
    order = sorted(range(len(probs)), key=lambda i: probs[i], reverse=True)
    total = 0.0
    keep = []
    for index in order:
        keep.append(index)
        total += probs[index]
        if total >= limit:
            break
    chosen = set(keep)
    return [probs[i] if i in chosen else 0.0 for i in range(len(probs))]


def sample_index(probs, rng):
    total = sum(probs)
    if total <= 0:
        return 0
    roll = rng.random() * total
    cursor = 0.0
    for index, prob in enumerate(probs):
        cursor += prob
        if roll <= cursor:
            return index
    return len(probs) - 1


def draw_token(left_scores, right_scores, left_share, temperature, top_p, rng):
    """Sample one vocab id from the tempered, nucleus-trimmed mixture."""
    temp = float(temperature)
    if temp <= 0:
        raise MixError("Temperature must be above 0.")
    share = float(left_share)
    left = softmax([score / temp for score in left_scores])
    if share >= 1:
        mixed = left
    elif share <= 0:
        mixed = softmax([score / temp for score in right_scores])
    else:
        right = softmax([score / temp for score in right_scores])
        mixed = mix_probs(left, right, share)
    return sample_index(nucleus_mask(mixed, top_p), rng)


def mix_plan(voice, blend, mix_text, bpm, scale, syl, seed_line, bars, seed):
    """Three comparable samples: voice, blend voice, and the weighted mix.

    The prefixes carry one voice each. The share is applied in the sampler,
    so a 70/30 mix is 70% of one distribution and 30% of the other at every token.
    """
    primary, secondary = parse_mix(mix_text)
    if tag_safe(voice).lower() == tag_safe(blend).lower():
        raise MixError("The blend needs two different voices.")
    if int(bars) < 1:
        raise MixError("Ask for at least one bar.")
    left = control_prefix(voice, bpm, scale, syl)
    right = control_prefix(blend, bpm, scale, syl)
    opening = seed_line.strip()
    jobs = [
        {"title": voice, "share": 1.0},
        {"title": blend, "share": 0.0},
        {
            "title": "%d%% %s / %d%% %s" % (primary, voice, secondary, blend),
            "share": primary / 100.0,
        },
    ]
    return {
        "voice": voice,
        "blend": blend,
        "primary": primary,
        "secondary": secondary,
        "left_prefix": left,
        "right_prefix": right,
        "seed_line": opening,
        "bars": int(bars),
        "seed": seed,
        "bpm": bpm,
        "scale": scale,
        "syl": syl,
        "jobs": jobs,
    }


def voice_note(artist: str, counts: dict, custom: bool) -> str:
    """Warn when a typed name was never trained or is too thin. Do not refuse."""
    if custom or not counts:
        return ""
    token = voice_token(artist)
    row = counts.get(token)
    if row is None:
        return "%s is not a trained voice token." % token
    if row.get("reliable"):
        return ""
    return (
        "%s has %s train lines and %s training windows. "
        "Flagged: too few lines to learn a reliable voice."
        % (token, row.get("train_lines"), row.get("train_windows"))
    )


def clean_bar(line: str) -> str:
    import re
    line = " ".join(line.split())
    if not line:
        return ""
    if line.startswith("<voice:") or line.startswith("<blend:") or line.startswith("<exemplar"):
        return ""
    if line.startswith("<bpm:") or line.startswith("<scale:") or line.startswith("<syl:"):
        return ""
    if line.startswith("<|") and line.endswith("|>"):
        return ""
    if line.startswith("#") or line.startswith("*") or line.startswith(">"):
        return ""
    line = re.sub(r"^(?:(?:\d+(?:st|nd|rd|th)?\s*(?:bar)?[:.]?)|(?:bar\s*\d+[:.]?))\s*", "", line, flags=re.IGNORECASE).strip()
    line = re.sub(r"\s*\([^)]*\)*$", "", line).strip()
    line = re.sub(r"[()\[\]]+", "", line).strip()
    return line


def _encode(tokenizer, text: str):
    try:
        ids = tokenizer.encode(text, add_special_tokens=False)
    except TypeError:
        ids = tokenizer.encode(text)
    if hasattr(ids, "ids"):
        ids = ids.ids
    return [int(i) for i in list(ids)]


def _decode(tokenizer, ids):
    if not ids:
        return ""
    try:
        return tokenizer.decode(ids, skip_special_tokens=True)
    except TypeError:
        return tokenizer.decode(ids)


def _eos_ids(tokenizer):
    found = set()
    for attr in ("eos_token_id", "eos_token_ids", "eot_id"):
        value = getattr(tokenizer, attr, None)
        if value is None:
            continue
        if isinstance(value, (list, tuple, set)):
            found.update(int(item) for item in value)
        else:
            found.add(int(value))
    return found


def _prompt_ids(tokenizer, user: str, seed_line: str):
    prompt = render_prompt(tokenizer, user)
    if seed_line:
        prompt += seed_line.strip() + "\n"
    return _encode(tokenizer, prompt)


def _forward_last(model, token_ids, cache):
    import mlx.core as mx

    logits = model(mx.array(token_ids)[None], cache=cache)
    mx.eval(logits)
    return logits[0, -1]


def _sample_numpy(probs, top_p, rng):
    """Same cutoff as nucleus_mask, on a full vocabulary vector."""
    import numpy as np

    total = float(probs.sum())
    if total <= 0:
        return 0
    limit = float(top_p)
    if limit >= 1:
        roll = rng.random() * total
        cursor = np.cumsum(probs)
        index = int(np.searchsorted(cursor, roll, side="left"))
        return min(index, len(probs) - 1)
    order = np.argsort(-probs)
    chosen = []
    chosen_p = []
    mass = 0.0
    for index in order:
        chosen.append(int(index))
        prob = float(probs[index])
        chosen_p.append(prob)
        mass += prob
        if mass >= limit:
            break
    return _sample_kept(chosen, chosen_p, rng)


def _sample_kept(chosen, chosen_p, rng):
    return chosen[sample_index(chosen_p, rng)] if chosen else 0


def _rhyme_index(tokenizer):
    if not hasattr(tokenizer, "get_vocab") or not CMU.exists():
        return None, {}
    key = id(tokenizer)
    if key in _RHYME_CACHE:
        return _RHYME_CACHE[key]
    try:
        cmu = load_cmudict(CMU)
        vocab = tokenizer.get_vocab()
    except Exception:
        return None, {}
    rime_to_tids: dict = {}
    word_to_tids: dict = {}
    for s, tid in vocab.items():
        if not s or s[0] not in ("Ġ", " "):
            continue
        w = s.lstrip("Ġ ").rstrip(".,!?;:\"\x27)\n\r").lower()
        if not w or not w.isalpha():
            continue
        word_to_tids.setdefault(w, []).append(int(tid))
        if w not in cmu:
            continue
        r = end_rime(w, cmu)
        if r:
            rime_to_tids.setdefault(r, []).append((int(tid), w))
    _RHYME_CACHE[f"word_tids_{key}"] = word_to_tids
    _RHYME_CACHE[key] = (cmu, rime_to_tids)
    return cmu, rime_to_tids


def _voice_dna_profile(tokenizer, voice: str) -> dict:
    """Return pre-indexed token maps for the artist's end-rhymes, signature phrases, and NoCap double-meaning words."""
    if not hasattr(tokenizer, "get_vocab"):
        return {}
    t_key = id(tokenizer)
    cache_key = f"dna_{t_key}_{voice or 'default'}"
    if cache_key in _RHYME_CACHE:
        return _RHYME_CACHE[cache_key]
    _rhyme_index(tokenizer)
    word_to_tids = _RHYME_CACHE.get(f"word_tids_{t_key}") or {}
    dna_data = _RHYME_CACHE.get("raw_dna_json")
    if dna_data is None:
        dna_path = OUT / "artist_voice_dna.json"
        if dna_path.exists():
            try:
                dna_data = json.loads(dna_path.read_text(encoding="utf-8"))
            except Exception:
                dna_data = {}
        else:
            dna_data = {}
        _RHYME_CACHE["raw_dna_json"] = dna_data

    artists_map = dna_data.get("artists") or {}
    artist_entry = artists_map.get(voice) or artists_map.get("Gunna") or {}
    double_lex = dna_data.get("double_meaning_lexicon") or {}

    artist_end_words = {e["word"] for e in (artist_entry.get("top_end_words") or []) if e.get("word")}
    artist_end_tids = {}
    for w in artist_end_words:
        for tid in word_to_tids.get(w, ()):
            artist_end_tids[tid] = w

    rhyme_pairs_raw = artist_entry.get("rhyme_pairs") or {}
    rhyme_pairs: dict[str, set[str]] = {
        k: set(v) for k, v in rhyme_pairs_raw.items() if isinstance(v, list)
    }

    phrase_next_tids: dict[str, list[tuple[int, str, str]]] = {}
    phrase_lead_tids: dict[int, str] = {}
    for p in (artist_entry.get("signature_phrases") or [])[:50]:
        lead = p.get("lead") or ""
        rest = p.get("rest") or ""
        full_phrase = p.get("phrase") or ""
        first_rest = rest.split()[0] if rest else ""
        if lead and first_rest:
            for tid in word_to_tids.get(first_rest, ()):
                phrase_next_tids.setdefault(lead, []).append((tid, first_rest, full_phrase))
            for ltid in word_to_tids.get(lead, ()):
                phrase_lead_tids[ltid] = lead

    double_words = set(artist_entry.get("double_meaning_words") or list(double_lex.keys())[:45])
    double_word_tids: dict[int, str] = {}
    for dw in double_words:
        for tid in word_to_tids.get(dw, ()):
            double_word_tids[tid] = dw

    # Map each double-meaning word -> its homophones and semantic pair triggers
    double_flips: dict[str, dict[str, list[tuple[int, str]]]] = {}
    for dw, dmeta in double_lex.items():
        homos = []
        for hw in dmeta.get("homophones") or []:
            for tid in word_to_tids.get(hw, ()):
                homos.append((tid, hw))
        trigs = []
        for tw in dmeta.get("pair_triggers") or []:
            for tid in word_to_tids.get(tw, ()):
                trigs.append((tid, tw))
        if homos or trigs:
            double_flips[dw] = {"homophones": homos, "triggers": trigs}

    banned_words = {"nigga", "niggas", "bitch", "bitches", "shit", "fuck", "fucking", "fuckin", "pussy", "hoe", "hoes", "dick", "ass", "damn", "cunt"}
    profane_banned_tids = set()
    for bw in banned_words:
        for prefix in ("", " ", "  "):
            for tid in _encode(tokenizer, prefix + bw):
                profane_banned_tids.add(int(tid))
        for tid in word_to_tids.get(bw, ()):
            profane_banned_tids.add(int(tid))

    profile = {
        "artist_end_words": artist_end_words,
        "artist_end_tids": artist_end_tids,
        "rhyme_pairs": rhyme_pairs,
        "phrase_next_tids": phrase_next_tids,
        "phrase_lead_tids": phrase_lead_tids,
        "double_words": double_words,
        "double_word_tids": double_word_tids,
        "double_flips": double_flips,
        "word_to_tids": word_to_tids,
        "profane_banned_tids": profane_banned_tids,
    }
    _RHYME_CACHE[cache_key] = profile
    return profile


def _draw_logits(left, right, share, temperature, top_p, rng, ban_ids=(), boost_map=None):
    import numpy as np

    def as_probs(logits):
        arr = np.asarray(logits).astype("float64").reshape(-1)
        if boost_map and arr.size:
            last = arr.shape[0] - 1
            for tid, delta in boost_map.items():
                tid = int(tid)
                if 0 <= tid <= last:
                    arr[tid] += float(delta)
        scaled = arr / float(temperature)
        scaled -= np.max(scaled)
        exps = np.exp(scaled)
        total = np.sum(exps) or 1.0
        return exps / total

    if share >= 1:
        mixed = as_probs(left)
    elif share <= 0:
        mixed = as_probs(right)
    else:
        mixed = np.asarray(mix_probs(as_probs(left), as_probs(right), share), dtype="float64")
    # An end-of-turn token would cut the sample off before the requested bar count.
    # Zero it before nucleus sampling so the next real token is drawn instead.
    if ban_ids and mixed.size:
        mixed = mixed.copy()
        last = mixed.shape[0] - 1
        for token_id in ban_ids:
            token_id = int(token_id)
            if 0 <= token_id <= last:
                mixed[token_id] = 0.0
    return _sample_numpy(mixed, top_p, rng)


def _artist_soft_syl(voice: str, default_syl: int) -> int:
    if not voice:
        return default_syl
    cache = _RHYME_CACHE.get("artist_syl")
    if cache is None:
        cache = {}
        for split_name in ("test.jsonl", "val.jsonl"):
            p = OUT / split_name
            if not p.exists():
                continue
            try:
                with p.open(encoding="utf-8") as handle:
                    for raw in handle:
                        if not raw.strip():
                            continue
                        rec = json.loads(raw)
                        art = rec.get("artist") or ""
                        if not art:
                            continue
                        bucket = cache.setdefault(art, [])
                        if len(bucket) >= 80:
                            continue
                        for ln in (rec.get("text") or "").split("\n"):
                            ln = ln.strip()
                            if ln and not ln.startswith("["):
                                bucket.append(estimate_syllables(ln))
                                if len(bucket) >= 80:
                                    break
            except Exception:
                pass
        _RHYME_CACHE["artist_syl"] = {
            art: int(round(statistics.fmean(vals)))
            for art, vals in cache.items()
            if len(vals) >= 8
        }
    return _RHYME_CACHE["artist_syl"].get(voice, default_syl)


def generate_mixed(model, tokenizer, plan, job):
    """Write plan['bars'] lines. share 1 uses the voice prefix, 0 the blend prefix."""
    from mlx_lm.models.cache import make_prompt_cache

    share = float(job["share"])
    use_left = share > 0
    use_right = share < 1
    eos = _eos_ids(tokenizer)
    cache_left = make_prompt_cache(model) if use_left else None
    cache_right = make_prompt_cache(model) if use_right else None
    logits_left = None
    logits_right = None
    if use_left:
        logits_left = _forward_last(
            model, _prompt_ids(tokenizer, plan["left_prefix"], plan["seed_line"]), cache_left
        )
    if use_right:
        logits_right = _forward_last(
            model, _prompt_ids(tokenizer, plan["right_prefix"], plan["seed_line"]), cache_right
        )
    rng = random.Random(plan["seed"])
    lines = []
    empty_streak = 0
    target = int(plan["syl"]) if plan.get("fit_syllables") and plan.get("syl") else None
    base_syl = int(plan["syl"]) if plan.get("syl") else 10
    voice_name = plan.get("voice") or ""
    soft_syl = target if target is not None else _artist_soft_syl(voice_name, base_syl)
    newline_ids = _encode(tokenizer, "\n")
    newline_set = set(newline_ids)
    seed_tokens = _encode(tokenizer, plan["seed_line"]) if plan.get("seed_line") else []
    history_tokens = list(seed_tokens)
    cmu, rime_to_tids = _rhyme_index(tokenizer)
    dna = _voice_dna_profile(tokenizer, voice_name)
    artist_end_words = dna.get("artist_end_words") or set()
    artist_end_tids = dna.get("artist_end_tids") or {}
    artist_rhyme_pairs = dna.get("rhyme_pairs") or {}
    phrase_next_tids = dna.get("phrase_next_tids") or {}
    phrase_lead_tids = dna.get("phrase_lead_tids") or {}
    double_words = dna.get("double_words") or set()
    double_word_tids = dna.get("double_word_tids") or {}
    double_flips = dna.get("double_flips") or {}
    word_to_tids = dna.get("word_to_tids") or {}
    profane_banned_tids = dna.get("profane_banned_tids") or set()

    used_verse_words: set[str] = set()
    if plan.get("seed_line"):
        used_verse_words.update(tokenize(normalize(plan["seed_line"])))

    while len(lines) < plan["bars"]:
        line_ids = []
        cleaned = ""
        closed_without_nl = False
        held_back = set()
        limit = 48 if target is not None else 32
        steps = 0
        min_syl = max(4, target - 1) if target is not None else (max(5, soft_syl - 2) if cmu is not None else None)
        max_syl = (target + 1) if target is not None else (max(6, soft_syl) if cmu is not None else None)
        prev_ends = []
        if cmu is not None and lines:
            for prev_line in lines[-4:]:
                toks = tokenize(normalize(prev_line))
                while len(toks) > 1 and toks[-1] in ADLIB_TAILS:
                    toks.pop()
                if toks:
                    prev_ends.append(toks[-1])
        prev_end_set = set(prev_ends)
        active_rimes = {end_rime(w, cmu) for w in prev_ends if cmu and end_rime(w, cmu)}
        partner_words = set()
        for pw in prev_ends:
            partner_words.update(artist_rhyme_pairs.get(pw) or ())

        recent_verse_words: set[str] = set()
        if lines:
            for pl in lines[-2:]:
                for w in tokenize(normalize(pl)):
                    if len(w) >= 3 and w not in dangling:
                        recent_verse_words.add(w)

        rhyme_boost_tids = {}
        if active_rimes and rime_to_tids:
            for r in active_rimes:
                for tid, w in rime_to_tids.get(r, ()):
                    if w in prev_end_set:
                        continue
                    if w in partner_words:
                        # Tier 1: Exact rhyming partner used by this artist in their catalog
                        rhyme_boost_tids[tid] = 4.9
                    elif w in artist_end_words or w in double_words:
                        # Tier 2: Artist's own signature end-rhyme vocabulary or NoCap double-meaning word
                        rhyme_boost_tids[tid] = 4.3
                    else:
                        # Tier 3: Standard CMUdict rhyme match
                        rhyme_boost_tids[tid] = 3.2
        elif artist_end_tids:
            # Bar 1 (or fresh rhyme cycle): steer the opening bar to land on a signature artist rhyme word
            for tid, w in artist_end_tids.items():
                if w not in used_verse_words and w not in ADLIB_TAILS:
                    rhyme_boost_tids[tid] = 3.8 if w not in double_words else 4.2

        dangling = {
            "a", "an", "the", "to", "of", "in", "on", "for", "with", "and",
            "or", "but", "at", "by", "from", "as", "into", "like", "that",
            "who", "when", "where", "while", "if", "i", "i'm", "im", "we",
            "we're", "you", "you're", "don't", "dont", "can't", "cant",
            "ain't", "aint", "gonna", "wanna", "gotta", "my", "your", "our",
            "his", "her", "their", "its", "is", "are", "was", "were", "be",
        }
        while len(line_ids) < limit and steps < limit + 24:
            steps += 1
            current = _decode(tokenizer, line_ids) if line_ids else ""
            ban = set(eos)
            ban.update(profane_banned_tids)
            for rw in recent_verse_words:
                if rw not in partner_words and rw not in double_words:
                    for btid in word_to_tids.get(rw, ()):
                        ban.add(btid)
            if min_syl is not None and not line_reached_budget(current, min_syl):
                ban.update(newline_set)
                ban.update(held_back)
            # Block repeating any 4-gram already seen in history_tokens + line_ids
            full_seq = history_tokens + line_ids
            if len(full_seq) >= 3:
                prev3 = (full_seq[-3], full_seq[-2], full_seq[-1])
                for idx_ng in range(len(full_seq) - 3):
                    if (full_seq[idx_ng], full_seq[idx_ng + 1], full_seq[idx_ng + 2]) == prev3:
                        cand_tok = full_seq[idx_ng + 3]
                        if cand_tok not in newline_set:
                            ban.add(cand_tok)
            # Block repeating the exact seed line opening (first 2 tokens)
            if len(line_ids) == 1 and len(seed_tokens) >= 2 and line_ids[0] == seed_tokens[0]:
                ban.add(seed_tokens[1])

            # Repetition prevention: ban repeating content words within the same bar
            cur_toks = tokenize(normalize(current)) if current else []
            last_w = cur_toks[-1] if cur_toks else ""
            if last_w in dangling or last_w in ADLIB_TAILS:
                ban.update(newline_set)
            for cw in cur_toks:
                if len(cw) >= 3 and cw not in dangling:
                    for btid in word_to_tids.get(cw, ()):
                        ban.add(btid)

            boost = None
            if len(lines) == 0 and len(line_ids) == 0 and not plan.get("seed_line"):
                open_boost = {}
                for ltid, lw in phrase_lead_tids.items():
                    if len(lw) >= 3 and lw not in dangling and lw not in ADLIB_TAILS:
                        open_boost[ltid] = 2.8
                if open_boost:
                    boost = open_boost
            elif current:
                cur_syl = estimate_syllables(current)
                last_w = cur_toks[-1] if cur_toks else ""
                if cur_syl >= max(4, soft_syl - 4):
                    # Never repeat previous rhyme landing words
                    for pw in prev_ends:
                        for btid in word_to_tids.get(pw, ()):
                            ban.add(btid)
                    last_r = end_rime(last_w, cmu) if (last_w and cmu) else None
                    if active_rimes and last_r in active_rimes and last_w not in prev_end_set and last_w not in ADLIB_TAILS and cur_syl >= (min_syl or 5):
                        boost = {tid: 4.6 for tid in newline_ids}
                    elif not active_rimes and last_w in artist_end_words and last_w not in ADLIB_TAILS and cur_syl >= (min_syl or 5):
                        boost = {tid: 4.5 for tid in newline_ids}
                    elif cur_syl <= soft_syl + 1 and rhyme_boost_tids:
                        boost = rhyme_boost_tids
                else:
                    # Mid-bar guidance: Artist Signature Phrases + NoCap Double-Meaning Wordplay
                    mid_boost = {}
                    # 1. Signature Phrase Continuations:
                    # If the last emitted word is an artist signature phrase lead, boost the continuation!
                    if last_w and last_w in phrase_next_tids:
                        for ctid, cw, _ in phrase_next_tids[last_w]:
                            if cw not in cur_toks:
                                mid_boost[ctid] = max(mid_boost.get(ctid, 0.0), 4.8)
                    # 2. Contextual Double-Meaning Wordplay:
                    # If a double-meaning word is in play in this bar or the prior bar, boost its homophone flip & pair triggers!
                    recent_context_words = set(cur_toks)
                    if lines:
                        recent_context_words.update(tokenize(normalize(lines[-1])))
                    for rw in recent_context_words:
                        flip_info = double_flips.get(rw)
                        if not flip_info:
                            continue
                        for htid, hw in flip_info.get("homophones", ()):
                            if hw not in cur_toks:
                                mid_boost[htid] = max(mid_boost.get(htid, 0.0), 4.5)
                        for ttid, tw in flip_info.get("triggers", ()):
                            if tw not in cur_toks and tw not in used_verse_words:
                                mid_boost[ttid] = max(mid_boost.get(ttid, 0.0), 3.4)
                    if mid_boost:
                        boost = mid_boost
            token = _draw_logits(
                logits_left,
                logits_right,
                share,
                plan["temperature"],
                plan["top_p"],
                rng,
                ban_ids=ban,
                boost_map=boost,
            )
            if token in eos:
                continue
            trial = _decode(tokenizer, line_ids + [token])
            if "\n" in trial:
                head = trial.split("\n", 1)[0]
                if min_syl is not None and not line_reached_budget(head, min_syl):
                    # A newline before the minimum budget is not a bar. Hold that
                    # token back and draw again. Do not forward it.
                    held_back.add(token)
                    continue
            line_ids.append(token)
            if use_left:
                logits_left = _forward_last(model, [token], cache_left)
            if use_right:
                logits_right = _forward_last(model, [token], cache_right)
            text = _decode(tokenizer, line_ids)
            if "\n" in text:
                cleaned = clean_bar(text.split("\n", 1)[0])
                break
            if max_syl is not None and line_reached_budget(text, max_syl):
                words = text.strip().split()
                last_word = words[-1].lower().strip(",.!?;:\"'()-") if words else ""
                if last_word and last_word not in dangling and last_word not in ADLIB_TAILS and not line_reached_budget(text, max_syl + 2):
                    cleaned = clean_bar(text)
                    closed_without_nl = True
                    break
                elif line_reached_budget(text, max_syl + 2):
                    cleaned = clean_bar(text)
                    closed_without_nl = True
                    break
        else:
            cleaned = clean_bar(_decode(tokenizer, line_ids))
            closed_without_nl = True
        if cleaned:
            lines.append(cleaned)
            used_verse_words.update(tokenize(normalize(cleaned)))
            history_tokens.extend(line_ids)
            # Whenever a bar closes without emitting a newline token, feed the
            # newline so the next bar starts cleanly on a new line in the KV cache.
            if closed_without_nl:
                for token in newline_ids:
                    if use_left:
                        logits_left = _forward_last(model, [token], cache_left)
                    if use_right:
                        logits_right = _forward_last(model, [token], cache_right)
            empty_streak = 0
            mark = ""
            if target is not None:
                mark = " syl %d" % estimate_syllables(cleaned)
            print("  bar %d/%d%s" % (len(lines), plan["bars"], mark), file=sys.stderr)
        else:
            empty_streak += 1
            if empty_streak >= 3:
                break
    return lines


def format_mix_report(plan, samples, adapter_note, notes):
    bpm = "n/a" if plan["bpm"] is None else ("%g" % plan["bpm"])
    lines = [
        "Voice blend",
        "At each token the model scores the next word twice, once under each voice prefix.",
        "Those scores become probabilities. The mix is %d%% of %s and %d%% of %s."
        % (plan["primary"], plan["voice"], plan["secondary"], plan["blend"]),
        "The %s sample uses only that voice. The %s sample uses only that voice."
        % (plan["voice"], plan["blend"]),
        "BPM %s. Syllable target %s. Seed %s."
        % (bpm, plan["syl"] if plan["syl"] is not None else "n/a", plan["seed"]),
        "Seed line: %s" % (plan["seed_line"] or "(none)"),
        "Temperature %s. Top-p %s." % (plan["temperature"], plan["top_p"]),
        adapter_note,
        "Prefix A: %s" % plan["left_prefix"],
        "Prefix B: %s" % plan["right_prefix"],
    ]
    for note in notes:
        if note:
            lines.append(note)
    lines.append("")
    for sample in samples:
        lines.append("## %s" % sample["title"])
        if not sample["lines"]:
            lines.append("(no bars)")
        for index, line in enumerate(sample["lines"], start=1):
            lines.append("%d. %s" % (index, line))
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def run_weighted(args, syl, counts) -> int:
    if not args.blend:
        print("A mix needs --blend and --voice.", file=sys.stderr)
        return 1
    if tag_safe(args.voice).lower() == "custom":
        print("A mix uses two artist names. A custom voice stays on --exemplar.", file=sys.stderr)
        return 1
    if args.compare and args.seed is None:
        print("Pass --seed so the three samples share a random stream.", file=sys.stderr)
        return 1
    if args.compare and not args.seed_line.strip():
        print("Pass --seed-line so the three samples continue from the same line.", file=sys.stderr)
        return 1
    try:
        plan = mix_plan(
            args.voice,
            args.blend,
            args.mix,
            args.bpm,
            args.scale or None,
            syl,
            args.seed_line,
            args.bars,
            args.seed if args.seed is not None else 0,
        )
    except MixError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    plan["temperature"] = args.temperature
    plan["top_p"] = args.top_p
    plan["fit_syllables"] = plan.get("bpm") is not None and plan.get("syl") is not None
    jobs = plan["jobs"] if args.compare else [plan["jobs"][2]]
    notes = [
        voice_note(args.voice, counts, False),
        voice_note(args.blend, counts, False),
    ]
    try:
        from mlx_lm import load
    except ImportError:
        print(
            "mlx_lm is not installed. From tools/lyric-llm:\n"
            "  uv venv --python 3.12 .venv && uv pip install -r requirements.txt",
            file=sys.stderr,
        )
        return 1
    adapter = args.adapter if (args.adapter / "adapters.safetensors").exists() else None
    if adapter is None:
        adapter_note = (
            "Adapter: none loaded. These bars are the base model. "
            "The voice prefixes take on the catalog styles after training."
        )
    else:
        adapter_note = "Adapter: %s" % adapter
    model, tokenizer = load(args.model, adapter_path=str(adapter) if adapter else None)
    from mlx_lm.utils import maybe_set_recommended_wired_limit

    maybe_set_recommended_wired_limit()
    db_path = OUT / "originality.sqlite"
    conn = sqlite3.connect(db_path) if db_path.exists() else None
    samples = []
    for job in jobs:
        print("sampling %s" % job["title"], file=sys.stderr)
        raw_lines = generate_mixed(model, tokenizer, plan, job)
        shown = []
        for line in raw_lines:
            flag = originality_hit(conn, line) if conn else None
            if flag:
                shown.append("%s  [%s train match]" % (line, flag))
            else:
                shown.append(line)
        samples.append({"title": job["title"], "lines": shown})
    if conn:
        conn.close()
    report = format_mix_report(plan, samples, adapter_note, notes)
    out_path = OUT / ("blend_compare.txt" if args.compare else "blend_sample.txt")
    out_path.write_text(report, encoding="utf-8")
    print(report, end="")
    print("saved %s" % out_path, file=sys.stderr)
    if any(len(sample["lines"]) < plan["bars"] for sample in samples):
        return 1
    return 0


def render_prompt(tokenizer, user: str) -> str:
    if getattr(tokenizer, "chat_template", None):
        try:
            rendered = tokenizer.apply_chat_template(
                [{"role": "user", "content": user}],
                add_generation_prompt=True,
                tokenize=False,
            )
        except TypeError:
            rendered = tokenizer.apply_chat_template(
                [{"role": "user", "content": user}],
                add_generation_prompt=True,
            )
        if isinstance(rendered, str):
            return rendered
    return user + "\n"


def generate_lines(model, tokenizer, user: str, bars: int, temperature: float, top_p: float) -> list[str]:
    from mlx_lm import generate

    text = generate(
        model,
        tokenizer,
        prompt=render_prompt(tokenizer, user),
        max_tokens=max(32, bars * 24),
        temp=temperature,
        top_p=top_p,
        verbose=False,
    )
    lines = []
    for line in str(text).splitlines():
        line = " ".join(line.split())
        if not line or line.startswith("<voice:") or line.startswith("<blend:") or line.startswith("<exemplar"):
            continue
        if line.startswith("<bpm:") or line.startswith("<scale:") or line.startswith("<syl:"):
            continue
        lines.append(line)
        if len(lines) >= bars:
            break
    return lines


def parse_tempos(text: str) -> list:
    parts = [part.strip() for part in text.split(",") if part.strip()]
    if len(parts) < 2:
        raise MixError("Pass two tempos, for example 70,140.")
    tempos = []
    for part in parts:
        try:
            tempos.append(float(part))
        except ValueError as exc:
            raise MixError("A tempo must be a number, for example 70,140.") from exc
    return tempos


def format_tempo_report(voice, scale, seed, temperature, top_p, samples, corpus, adapter_note):
    lines = [
        "Tempo control",
        "Voice %s. Scale %s. Seed %s." % (voice, scale, seed),
        "Temperature %s. Top-p %s." % (temperature, top_p),
        adapter_note,
        "Each bar closes when its syllable count reaches the tempo budget.",
        "70 BPM asks for a roomier line. 140 BPM asks for a denser line.",
        "The budget is 8 syllables at 70 BPM and 14 at 140, with a straight line between them.",
        "Scale is in the prefix with the tempo. It does not change the syllable budget.",
        "Corpus rows are lyric lines in that BPM bucket. Section markers are left out.",
        "Catalog lines stay near the same length at both tempos. The sampler budget is the control.",
        "",
    ]
    for bucket, row in corpus.items():
        lines.append(
            "Corpus %g BPM: %s songs, %s lines, mean %s, median %s."
            % (
                bucket,
                row["songs"],
                row["lines"],
                row["mean"] if row["mean"] is not None else "n/a",
                row["median"] if row["median"] is not None else "n/a",
            )
        )
    lines.append("")
    for sample in samples:
        raw_lines = sample["lines"]
        mean = mean_syl(raw_lines)
        shown = "n/a" if mean is None else ("%.2f" % mean)
        lines.append(
            "## %g BPM  budget %s  mean %s" % (sample["bpm"], sample["syl"], shown)
        )
        lines.append(sample["prefix"])
        if not raw_lines:
            lines.append("(no bars)")
        flags = sample.get("flags") or []
        for index, line in enumerate(raw_lines, start=1):
            flag = flags[index - 1] if index - 1 < len(flags) else None
            suffix = "  [%s train match]" % flag if flag else ""
            lines.append(
                "%d. %s  (%d syl)%s" % (index, line, estimate_syllables(line), suffix)
            )
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def run_tempo_pair(args, tempos) -> int:
    if tag_safe(args.voice).lower() == "custom":
        print("A tempo pair uses an artist voice.", file=sys.stderr)
        return 1
    counts = load_voice_counts(OUT / "voice_counts.json")
    note = voice_note(args.voice, counts, False)
    if note:
        print(note, file=sys.stderr)
    corpus = corpus_bpm_syllables(
        [OUT / "train.jsonl", OUT / "val.jsonl", OUT / "test.jsonl"],
        tempos,
    )
    try:
        from mlx_lm import load
    except ImportError:
        print(
            "mlx_lm is not installed. From tools/lyric-llm:\n"
            "  uv venv --python 3.12 .venv && uv pip install -r requirements.txt",
            file=sys.stderr,
        )
        return 1
    adapter = args.adapter if (args.adapter / "adapters.safetensors").exists() else None
    if adapter is None:
        adapter_note = (
            "Adapter: none loaded. These bars are the base model. "
            "The syllable budget is applied by the sampler."
        )
    else:
        adapter_note = "Adapter: %s" % adapter
    model, tokenizer = load(args.model, adapter_path=str(adapter) if adapter else None)
    from mlx_lm.utils import maybe_set_recommended_wired_limit

    maybe_set_recommended_wired_limit()
    db_path = OUT / "originality.sqlite"
    conn = sqlite3.connect(db_path) if db_path.exists() else None
    samples = []
    for bpm in tempos:
        syl = tempo_line_syllables(bpm)
        prefix = control_prefix(args.voice, bpm, args.scale or None, syl)
        plan = {
            "left_prefix": prefix,
            "right_prefix": prefix,
            "seed_line": "",
            "bars": args.bars,
            "seed": args.seed if args.seed is not None else 0,
            "bpm": bpm,
            "syl": syl,
            "temperature": args.temperature,
            "top_p": args.top_p,
            "fit_syllables": True,
        }
        print("sampling %g BPM budget %d" % (bpm, syl), file=sys.stderr)
        print(prefix, file=sys.stderr)
        raw_lines = generate_mixed(model, tokenizer, plan, {"title": "%g BPM" % bpm, "share": 1.0})
        flags = []
        for line in raw_lines:
            flags.append(originality_hit(conn, line) if conn else None)
        samples.append(
            {"bpm": bpm, "syl": syl, "prefix": prefix, "lines": raw_lines, "flags": flags}
        )
    if conn:
        conn.close()
    report = format_tempo_report(
        args.voice,
        args.scale,
        args.seed if args.seed is not None else 0,
        args.temperature,
        args.top_p,
        samples,
        corpus,
        adapter_note,
    )
    out_path = OUT / ("bpm_compare.txt" if len(tempos) > 1 else "bpm_sample.txt")
    out_path.write_text(report, encoding="utf-8")
    print(report, end="")
    print("saved %s" % out_path, file=sys.stderr)
    if any(len(sample["lines"]) < args.bars for sample in samples):
        return 1
    return 0


def mean_syl(lines: list[str]) -> float | None:
    if not lines:
        return None
    return statistics.fmean(estimate_syllables(line) for line in lines)


def run_fitted_voice(args, user: str, syl: int) -> int:
    """One voice, one BPM. Each bar closes at the tempo syllable budget."""
    try:
        from mlx_lm import load
    except ImportError:
        print(
            "mlx_lm is not installed. From tools/lyric-llm:\n"
            "  uv venv --python 3.12 .venv && uv pip install -r requirements.txt",
            file=sys.stderr,
        )
        return 1
    adapter = args.adapter if (args.adapter / "adapters.safetensors").exists() else None
    model, tokenizer = load(args.model, adapter_path=str(adapter) if adapter else None)
    from mlx_lm.utils import maybe_set_recommended_wired_limit

    maybe_set_recommended_wired_limit()
    plan = {
        "left_prefix": user,
        "right_prefix": user,
        "seed_line": (args.seed_line or "").strip(),
        "bars": args.bars,
        "seed": args.seed if args.seed is not None else 0,
        "bpm": args.bpm,
        "syl": syl,
        "temperature": args.temperature,
        "top_p": args.top_p,
        "fit_syllables": True,
    }
    print(user.split("\n", 1)[0])
    print("sampling %g BPM budget %d" % (args.bpm, syl), file=sys.stderr)
    lines = generate_mixed(model, tokenizer, plan, {"title": args.voice, "share": 1.0})
    db_path = OUT / "originality.sqlite"
    conn = sqlite3.connect(db_path) if db_path.exists() else None
    print("")
    for index, line in enumerate(lines, start=1):
        flag = originality_hit(conn, line) if conn else None
        suffix = "  [%s train match]" % flag if flag else ""
        print("%d. %s  (%d syl)%s" % (index, line, estimate_syllables(line), suffix))
    if conn:
        conn.close()
    got = mean_syl(lines)
    if got is not None:
        print("\nsyllable mean %.2f  budget %s" % (got, syl))
    if len(lines) < args.bars:
        print("The sample is short of the requested bar count.", file=sys.stderr)
        return 1
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Write bars with a voice token and a BPM.")
    parser.add_argument("--voice", default="", help="Artist name, or 'custom' with --exemplar.")
    parser.add_argument("--blend", default="", help="Second artist. With --mix, this voice gets the remaining share.")
    parser.add_argument(
        "--mix",
        default="",
        help="Share for --voice, as 70 or 70/30. 70 means 70 percent this voice and 30 percent --blend.",
    )
    parser.add_argument(
        "--seed-line",
        default="",
        help="Opening line the sample continues from. Shared by every sample in --compare.",
    )
    parser.add_argument(
        "--compare",
        action="store_true",
        help="Write --voice, --blend, and the mix. Same seed, seed line, and BPM.",
    )
    parser.add_argument("--bpm", type=float, default=None)
    parser.add_argument(
        "--tempos",
        default="",
        help="Two or more BPMs, for example 70,140. Same voice, scale, and seed.",
    )
    parser.add_argument("--scale", default="", help="Musical scale, for example 'A minor'.")
    parser.add_argument("--bars", type=int, default=8)
    parser.add_argument("--temperature", type=float, default=0.9)
    parser.add_argument("--top-p", type=float, default=0.9)
    parser.add_argument("--exemplar", type=Path, default=None, help="Text file of example bars for a custom voice.")
    parser.add_argument("--list-voices", action="store_true")
    parser.add_argument("--model", default="mlx-community/Qwen2.5-3B-Instruct-4bit")
    parser.add_argument("--adapter", type=Path, default=HERE / "adapters")
    parser.add_argument("--seed", type=int, default=None)
    args = parser.parse_args()
    if args.list_voices:
        return list_voices(OUT / "voices.txt")
    if args.tempos:
        if not args.voice:
            print("Pass --voice with --tempos.", file=sys.stderr)
            return 1
        if args.bpm is not None:
            print("Pass --tempos or --bpm, not both.", file=sys.stderr)
            return 1
        if args.mix or args.compare or args.blend:
            print(
                "A tempo pair uses one voice. Leave off --mix, --blend, and --compare.",
                file=sys.stderr,
            )
            return 1
        if not str(args.scale).strip():
            print("Pass --scale so both tempos share one scale, for example 'A minor'.", file=sys.stderr)
            return 1
        if args.seed is None:
            print("Pass --seed so both tempos share a random stream.", file=sys.stderr)
            return 1
        try:
            tempos = parse_tempos(args.tempos)
        except MixError as exc:
            print(str(exc), file=sys.stderr)
            return 1
        return run_tempo_pair(args, tempos)
    if not args.voice:
        print("Pass --voice, or --list-voices.", file=sys.stderr)
        return 1
    if args.bpm is not None:
        syl = tempo_line_syllables(args.bpm)
    else:
        curve_path = OUT / "syllable_curve.json"
        curve = read_json(curve_path) if curve_path.exists() else {"buckets": {}}
        syl = target_syllables(curve, args.bpm)
    custom = tag_safe(args.voice).lower() == "custom"
    exemplar_lines: list[str] = []
    if args.exemplar:
        exemplar_lines = [
            " ".join(line.split())
            for line in args.exemplar.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ][:6]
    if custom and not exemplar_lines:
        print("A custom voice needs --exemplar with a few bars of the voice you want.", file=sys.stderr)
        return 1
    user = control_prefix(
        args.voice,
        args.bpm,
        args.scale or None,
        syl,
        blend=args.blend or None,
        custom=custom,
    )
    if exemplar_lines:
        user = user + "\n<exemplar>\n" + "\n".join(exemplar_lines) + "\n</exemplar>"
    counts = load_voice_counts(OUT / "voice_counts.json")
    if args.compare or args.mix:
        if args.blend and not args.mix:
            print("Pass --mix, for example 70, to set the blend ratio.", file=sys.stderr)
            return 1
        return run_weighted(args, syl, counts)
    note = voice_note(args.voice, counts, custom)
    if note:
        print(note)
    if args.bpm is not None:
        return run_fitted_voice(args, user, syl)
    print(user.split("\n", 1)[0])
    try:
        from mlx_lm import load
    except ImportError:
        print(
            "mlx_lm is not installed. From tools/lyric-llm:\n"
            "  uv venv --python 3.12 .venv && uv pip install -r requirements.txt",
            file=sys.stderr,
        )
        return 1
    adapter = args.adapter if (args.adapter / "adapters.safetensors").exists() else None
    model, tokenizer = load(args.model, adapter_path=str(adapter) if adapter else None)
    if args.seed is not None:
        import mlx.core as mx

        mx.random.seed(args.seed)
    lines = generate_lines(model, tokenizer, user, args.bars, args.temperature, args.top_p)
    got = mean_syl(lines)
    if syl and got is not None and abs(got - syl) / syl > 0.35:
        print(f"syllable mean {got:.1f} is outside 35% of target {syl}; sampling once more")
        lines = generate_lines(model, tokenizer, user, args.bars, args.temperature, args.top_p)
        got = mean_syl(lines)
    db_path = OUT / "originality.sqlite"
    conn = sqlite3.connect(db_path) if db_path.exists() else None
    print("")
    for index, line in enumerate(lines, start=1):
        flag = originality_hit(conn, line) if conn else None
        suffix = f"  [{flag} train match]" if flag else ""
        print(f"{index}. {line}{suffix}")
    if conn:
        conn.close()
    if got is not None:
        print(f"\nsyllable mean {got:.1f}  target {syl if syl is not None else 'n/a'}")
    if not lines:
        print("The model returned no bars.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
