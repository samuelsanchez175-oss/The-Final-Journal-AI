# Away-mode status files (Samuel is away; Grok reads these and reports to him)

Every Anti-Gravity chat writes `chat-status/chat-<N>.md` and overwrites it at least every 30 minutes. Write it to a temp file, then mv it into place. Format:

```
# Chat <N> · <name>
updated: <time ET>
state: running | idle | waiting on Samuel | stopped | done
doing: <one line>
progress: <numbers, e.g. 812/1886 songs, 42 verdicts this hour>
since last update: <one or two lines>
problems: <none | 429s, crash + restart, test failure, etc.>
needs Samuel: <no | the exact question>
```

Rules while Samuel is away:
- Never stop to ask a question in the chat window. Write it under "needs Samuel" in your status file, then skip that item and keep working on the next one.
- If a runner crashes, restart it once (it resumes). If it crashes again, set state: stopped and explain.
- Never commit or push, never edit BarHitsCatalog.sqlite, unwired-chips.md, NoCap source files, ~/.grok or the live-board files, and kill no process you didn't start.
