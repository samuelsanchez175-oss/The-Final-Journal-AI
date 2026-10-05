# Model You gold set

Offline You-fit grade. Does not call the app or OpenAI.

```bash
python3 eval/grade_modelyou.py --demo
python3 eval/grade_modelyou.py --verse path/to/you.txt --fixture eval/you_golden/artist_fixture.json
python3 eval/grade_modelyou.py --compare eval/you_golden/g.txt eval/you_golden/you.txt
```

`g.txt` / `you.txt` in this folder are **fixture stand-ins** of the `--demo` verses so `--compare` is runnable without a device. They are not a live same-note capture.

Live capture protocol (same as Model G `eval/captures/`):
1. Same journal note.
2. Generate Model G → overwrite `g.txt` (one bar per line).
3. Generate Model You → overwrite `you.txt`.
4. Grade You-fit against the artist fixture, not the Gunna CSV.

Bands: 80+ ship · 70–79 passable · <70 needs work.
