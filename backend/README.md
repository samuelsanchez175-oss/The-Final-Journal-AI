# Flow Skeleton API (Generate Lyrics from Flow – Scenario B)

Backend for **Scenario B: From Mumble**. Accepts an audio file and returns a syllable-per-bar skeleton so the app can generate lyrics that match the flow.

## Endpoints

- `POST /skeleton` – upload audio, get `{ "perBar": [...], "bpm": int }`
- `GET /health` – health check

## Query parameters (POST /skeleton)

- `bpm` (optional, 60–220) – BPM hint; if omitted, estimated from audio
- `bar_offset_ms` (optional, default 0) – offset in ms to first bar

## Run locally

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## iOS config

Set the backend URL in the app (e.g. via UserDefaults key `flow_skeleton_backend_url`) or leave default `http://localhost:8000` for simulator. For a real device, use your machine’s LAN IP or a deployed URL (Railway, Render, etc.).
