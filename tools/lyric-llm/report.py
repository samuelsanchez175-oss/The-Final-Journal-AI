"""Write the local eval report. Counts and scores only, never source bars."""

from __future__ import annotations

from pathlib import Path


def _pct(part: float) -> str:
    return f"{100.0 * part:.1f}%"


def _num(value, digits=3):
    if value is None:
        return "n/a"
    if isinstance(value, float):
        return f"{value:.{digits}f}"
    return str(value)


def _add_model_scores(add, model: dict) -> None:
    adapter = model.get("adapter") or ""
    if adapter in ("", "none"):
        add(
            "No LoRA adapter has been trained. Every score below is the base "
            f"checkpoint `{model.get('model_id', 'mlx-community/Qwen2.5-3B-Instruct-4bit')}`."
        )
    else:
        add(f"Adapter: `{adapter}`.")
    add(
        "Perplexity is the prompt-masked next-token loss on eight-line windows "
        "from the held-out song file. Generation does not force a syllable budget, "
        "so the rhyme and flow numbers are the model's, measured after sampling."
    )
    add("")
    if model.get("error"):
        add(f"Model section error: {model['error']}")
        add("")
        return
    add("## 1. Perplexity")
    add("")
    add("- Source: `out/test.jsonl`, the leak-checked held-out songs.")
    add(f"- Test songs: {model.get('test_songs', 0):,}")
    add(f"- Windows scored: {model.get('test_windows', 0):,}")
    add(f"- Windows skipped (shorter than the prompt mask): {model.get('skipped_windows', 0):,}")
    add(f"- Scored lyric tokens: {model.get('scored_tokens', 0):,}")
    add(f"- Test loss: {_num(model.get('test_loss'), 4)}")
    add(f"- Perplexity: {_num(model.get('perplexity'), 2)}")
    add("")
    add("## 2. Rhyme density")
    add("")
    add(
        "Rhyme rate is the share of lines whose end word rhymes with one of the "
        "previous four, using CMUdict. The corpus figure is the mean over train "
        "songs that have BPM. The generated figure is the mean over the example generations."
    )
    add("")
    add(f"- Corpus mean end-rhyme rate: {_num(model.get('corpus_rhyme'))}")
    add(f"- Generated mean end-rhyme rate: {_num(model.get('generated_rhyme'))}")
    add("")
    add("| Voice | Seed | BPM bucket | Generated rhyme | Corpus rhyme at that BPM |")
    add("| --- | ---: | ---: | ---: | ---: |")
    for row in model.get("examples") or model.get("trials") or []:
        add(
            f"| {row.get('voice', '')} | {row.get('seed', '')} | "
            f"{row.get('bpm_bucket', '')} | {_num(row.get('rhyme'))} | "
            f"{_num(row.get('corpus_rhyme'))} |"
        )
    add("")
    add("## 3. Syllable consistency at a matched BPM")
    add("")
    add(
        "Flow consistency is 1 when every line in the sample has the same syllable "
        "count. The target is the train-set median for that BPM bucket. The BPM on "
        "each row is the median of that artist's held-out songs, except where the note says otherwise."
    )
    add("")
    add(f"- Corpus mean flow consistency: {_num(model.get('corpus_flow'))}")
    add(f"- Generated mean flow consistency on the five fidelity samples: {_num(model.get('generated_flow'))}")
    add("")
    add("| Voice | BPM | BPM source | Mean syllables | Bucket median | Flow | Bucket flow |")
    add("| --- | ---: | --- | ---: | ---: | ---: | ---: |")
    for row in model.get("trials") or []:
        add(
            f"| {row.get('voice', '')} | {row.get('bpm', '')} | {row.get('bpm_source', '')} | "
            f"{_num(row.get('mean_syl'), 2)} | {row.get('corpus_median_syl', '')} | "
            f"{_num(row.get('flow'))} | {_num(row.get('corpus_flow'))} |"
        )
    add("")
    add("## 4. Voice fidelity")
    add("")
    add(
        "Each fidelity sample is 8 bars at seed 7. Distance is the L2 gap between "
        "syllable count, line length, type-token ratio, and end-rhyme rate. "
        "Closer means that distance to the named artist's held-out lines is smaller "
        "than the distance to a random artist's held-out lines."
    )
    add("")
    add(
        f"- Closer to the named artist: {model.get('voice_passes', 0)} / {model.get('voice_trials', 0)}"
    )
    add("")
    add("| Voice | Other artist | Distance to voice | Distance to other | Closer |")
    add("| --- | --- | ---: | ---: | --- |")
    for row in model.get("trials") or []:
        add(
            f"| {row.get('voice', '')} | {row.get('other_voice', '')} | "
            f"{_num(row.get('distance_voice'))} | {_num(row.get('distance_other'))} | "
            f"{'yes' if row.get('closer') else 'no'} |"
        )
    add("")
    add("## 5. Originality")
    add("")
    add(
        "Every generated line was checked against the training simhash index. "
        "An exact hash scores similarity 1. A near hit is the closest indexed "
        "neighbor within Hamming distance 3. Similarity is `(64 - Hamming) / 64`. "
        "Kind near with Hamming 0 is a simhash collision: the stored sha did not "
        "match, so the line is not an exact copy of a training string. "
        "The training line is not stored in the index and is not printed."
    )
    add("")
    add(
        f"- Flagged lines: {model.get('flagged_lines', 0)} / {model.get('generated_lines', 0)}"
    )
    hits = model.get("hits") or []
    if not hits:
        add("- No exact or near matches.")
    else:
        add("")
        add("| Voice | Seed | Line | Kind | Hamming | Similarity | Generated line |")
        add("| --- | ---: | ---: | --- | ---: | ---: | --- |")
        for hit in hits:
            text = " ".join(str(hit.get("text") or "").split()).replace("|", "/")
            add(
                f"| {hit.get('voice', '')} | {hit.get('seed', '')} | {hit.get('line', '')} | "
                f"{hit.get('kind', '')} | {hit.get('hamming', '')} | "
                f"{_num(hit.get('similarity'), 4)} | {text} |"
            )
    add("")
    add("## Example generations")
    add("")
    add(
        "Two samples per voice. The first seed is the fidelity sample. "
        "The next seed is a second draw from the same prefix. These lines are model output."
    )
    add("")
    for index, sample in enumerate(model.get("examples") or [], start=1):
        add(f"### {index}. {sample.get('voice', '')}  seed {sample.get('seed', '')}")
        add("")
        add(f"Prefix: `{sample.get('prefix', '')}`")
        add("")
        lines = sample.get("lines") or []
        if not lines:
            add("(no bars)")
        for line_no, line in enumerate(lines, start=1):
            add(f"{line_no}. {' '.join(str(line).split())}")
        add("")


def write_eval_report(path: Path, baseline: dict, model: dict | None = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines: list[str] = []
    add = lines.append
    add("# Lyric model eval")
    add("")
    add("Private report for the Penwork catalog. It records counts and scores.")
    add("It does not quote corpus lines.")
    add("")
    add("## Legal")
    add("")
    add(
        "Training on these lyrics is legally gray. Fair use for model training "
        "is still being fought over in court. Keep the corpus and any adapters "
        "private. Do not redistribute the weights commercially without counsel. "
        "The base checkpoint is also under the Qwen research license."
    )
    add("")
    add("## Corpus")
    add("")
    raw = baseline.get("raw_rows", 0)
    kept = baseline.get("kept_lines", 0)
    add(f"- Source rows read: {raw:,}")
    add(f"- Rows with text: {baseline.get('rows_with_text', 0):,}")
    add(f"- Junk or empty rows dropped: {baseline.get('junk', 0):,}")
    add(f"- Cross-song exact copies dropped: {baseline.get('dropped_exact', 0):,}")
    add(f"- Cross-song near copies dropped: {baseline.get('dropped_near', 0):,}")
    add(f"- Kept lines: {kept:,}")
    add(f"- Songs before the length cut: {baseline.get('songs_read', 0):,}")
    add(f"- Songs kept (at least 4 lines): {baseline.get('songs_kept', 0):,}")
    add(f"- Artist names on kept lines: {baseline.get('artists', 0):,}")
    add(
        "- Lines with BPM: "
        f"{baseline.get('lines_with_bpm', 0):,} ({_pct(baseline.get('bpm_line_share', 0))})"
    )
    add(
        "- Lines with scale: "
        f"{baseline.get('lines_with_scale', 0):,} ({_pct(baseline.get('scale_line_share', 0))})"
    )
    add(
        "- Section labels are almost all missing in the source CSV "
        f"({baseline.get('section_unknown_share', 0):.1%} unknown). "
        "Verse, chorus, and bridge are learned from line order inside each song, "
        "not from section tags."
    )
    add("")
    add("## Song split")
    add("")
    add("Split is 95/3/2 by song. Every kept line from a song stays in that song's split.")
    add("")
    add("| Split | Songs | Lines |")
    add("| --- | ---: | ---: |")
    for name in ("train", "valid", "test"):
        block = (baseline.get("splits") or {}).get(name) or {}
        add(f"| {name} | {block.get('songs', 0):,} | {block.get('lines', 0):,} |")
    add("")
    add(
        f"Train windows in the MLX train file before blend rows: {baseline.get('train_windows', 0):,}. "
        f"Custom-voice windows inside that count: {baseline.get('custom_windows', 0):,}. "
        f"Extra blend windows appended after: {baseline.get('blend_windows', 0):,}."
    )
    add("")
    add("## Artist distribution")
    add("")
    add(
        "A heavy artist is anyone with 4% or more of kept lines, or a single "
        "artist with more lines than the next two combined. A heavy name still "
        "gets a voice token. It will dominate the loss if you train for a full epoch."
    )
    add("")
    flags = baseline.get("heavy") or []
    if not flags:
        add("No artist is at or above 4% of kept lines.")
    else:
        add("| Artist | Kept lines | Share | Why it is flagged |")
        add("| --- | ---: | ---: | --- |")
        for row in flags:
            add(
                f"| {row['artist']} | {row['lines']:,} | {_pct(row['share'])} | {row['reason']} |"
            )
    add("")
    add("Top 15 by kept lines:")
    add("")
    add("| Artist | Kept lines | Share |")
    add("| --- | ---: | ---: |")
    for row in baseline.get("top_artists") or []:
        add(f"| {row['artist']} | {row['lines']:,} | {_pct(row['share'])} |")
    add("")
    add("Line-count histogram:")
    add("")
    add("| Bucket | Artists |")
    add("| --- | ---: |")
    for bucket, count in (baseline.get("artist_histogram") or {}).items():
        add(f"| {bucket} | {count:,} |")
    thin = baseline.get("thin_voice_artists", 0)
    add("")
    add(
        f"Artists with fewer than 200 kept lines: {thin:,}. "
        "A voice token for a thin artist has little to learn. Prefer a blend "
        "or a custom exemplar prompt for those names."
    )
    variants = baseline.get("case_variant_groups", 0)
    if variants:
        add("")
        add(
            f"Artist names that differ only by case: {variants} groups. "
            "They are separate voice tokens until someone merges them."
        )
    add("")
    add("## Craft baselines")
    add("")
    add(
        "Rhyme rate is the share of lines whose end word rhymes with one of the "
        "previous four, using CMUdict. Flow consistency is 1 when every line in "
        "a song has the same syllable count. Both are measured on train songs "
        "that have BPM. `<syl:N>` at training time is the median syllable count "
        "of that window. At inference, N comes from the tempo bucket below."
    )
    add("")
    g = baseline.get("global_craft") or {}
    if g:
        add(
            f"- Global median syllables per line: {g.get('median_syl', 'n/a')}"
        )
        rhyme = g.get("mean_rhyme_rate")
        flow = g.get("mean_flow")
        add(
            "- Mean end-rhyme rate: "
            + (f"{rhyme:.3f}" if isinstance(rhyme, float) else "n/a")
        )
        add(
            "- Mean flow consistency: "
            + (f"{flow:.3f}" if isinstance(flow, float) else "n/a")
        )
    add("")
    add("| BPM bucket | Lines | Median syllables | Mean rhyme rate | Mean flow |")
    add("| ---: | ---: | ---: | ---: | ---: |")
    buckets = baseline.get("curve", {}).get("buckets") or {}
    for key in sorted(buckets, key=lambda item: int(item)):
        row = buckets[key]
        rhyme = row.get("mean_rhyme_rate")
        flow = row.get("mean_flow")
        add(
            f"| {key} | {row.get('n', 0):,} | {row.get('median_syl', '')} | "
            f"{'' if rhyme is None else f'{rhyme:.3f}'} | "
            f"{'' if flow is None else f'{flow:.3f}'} |"
        )
    add("")
    add("## Model scores")
    add("")
    if not model:
        add("Not run. There is no adapter yet.")
        add("")
        add("After a pilot or a full train:")
        add("")
        add("```")
        add("python3 evaluate.py")
        add("```")
        add("")
        add(
            "That command fills perplexity on the held-out songs, rhyme and flow "
            "against the BPM bucket, a stylometric voice check, and the "
            "originality flags."
        )
    else:
        _add_model_scores(add, model)
    add("")
    add("## How to read a fail")
    add("")
    add(
        "A voice fail means the generated block's syllable count, line length, "
        "type-token ratio, and end-rhyme rate were closer to a random artist's "
        "held-out songs than to the named artist's. That is an automatic stand-in "
        "for a blind listen, not the listen itself."
    )
    add("")
    add(
        "An originality flag means the generated line matches a training line "
        "exactly, or its simhash is within Hamming distance 3. The report does "
        "not print the training line."
    )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
