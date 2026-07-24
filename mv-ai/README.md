# Gugakify Reactive MV Service

An independent FastAPI service that turns an uploaded audio file into a music-reactive Korean ink-wash MV.

## MVP limits

- Maximum source segment: 30 seconds
- Output: 1280x720, 24 fps, H.264/AAC MP4
- Rendering concurrency: one job per service instance
- Intermediate PNG files: none; RGB frames stream directly to FFmpeg
- Backgrounds: procedural ink-wash scenes or up to three uploaded SDXL/FLUX images
- Packaged visuals: six watercolor petals, eight ink/brush masks, five fog layers, and three energy-ranked landscapes

## Pipeline

1. `librosa` selects or loads a 30-second segment and extracts BPM, beats, onsets, RMS, frequency-band energy, and sections.
2. The rule engine maps analysis and optional gugak metadata to scenes and visual events.
3. Pillow, OpenCV, and NumPy composite ink blooms, brush transitions, fog, and petals.
4. Frames stream to FFmpeg, which encodes H.264 and muxes the selected source audio.

When `start_time` is omitted for a song longer than 30 seconds, the service selects an energetic 30-second window. Send `jangdan` from the arrangement service whenever it is known; BPM-based jangdan inference is only a fallback.

## Local run

```powershell
cd mv-ai
python -m venv .venv
.venv\Scripts\pip install -r requirements.txt
.venv\Scripts\uvicorn api:app --app-dir src --reload --port 8001
```

Open `http://localhost:8001/docs` for the interactive API.

## Create an MV

```powershell
curl.exe -X POST "http://localhost:8001/mv/jobs" `
  -H "X-API-Key: YOUR_KEY" `
  -F "audio=@C:\audio\gugak.wav" `
  -F "jangdan=jajinmori" `
  -F "mood=energetic" `
  -F "background_1=@C:\images\scene-1.png" `
  -F "background_2=@C:\images\scene-2.png"
```

The background fields are optional. Without them, the service creates deterministic procedural backgrounds.

```powershell
curl.exe -H "X-API-Key: YOUR_KEY" "http://localhost:8001/mv/jobs/JOB_ID"
curl.exe -H "X-API-Key: YOUR_KEY" "http://localhost:8001/mv/jobs/JOB_ID/video" --output final_mv.mp4
```

Job states are `queued`, `waiting_for_renderer`, `analyzing`, `rendering`, `completed`, or `failed`.

## API

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/health` | Service health |
| `POST` | `/mv/jobs` | Create an asynchronous MV job |
| `GET` | `/mv/jobs/{job_id}` | Read job status |
| `GET` | `/mv/jobs/{job_id}/analysis` | Download librosa analysis JSON |
| `GET` | `/mv/jobs/{job_id}/direction` | Download direction timeline JSON |
| `GET` | `/mv/jobs/{job_id}/video` | Download the finished MP4 |

## Render

Deploy `mv-ai/render.yaml` as a Blueprint. It selects the Standard compute instance (2 GB RAM, 1 CPU). The service filesystem is ephemeral, so completed videos can disappear on a restart or deploy. For production, upload final MP4 files to S3 or Cloudflare R2 and store only their URLs in job status.

Environment variables:

| Name | Default | Purpose |
| --- | --- | --- |
| `MV_API_KEY` | generated on Render | Protects all MV endpoints except health |
| `MV_DATA_ROOT` | `mv-ai/data` | Job files and rendered videos |
| `MV_MAX_UPLOAD_BYTES` | `52428800` | Maximum audio upload size |
| `MV_FFMPEG_PRESET` | `veryfast` | FFmpeg x264 preset |
| `MV_FFMPEG_CRF` | `24` | Output quality and size |
| `FFMPEG_BINARY` | bundled executable | Optional custom FFmpeg path |

FastAPI `BackgroundTasks` is adequate for a single-instance capstone MVP, but it is not a durable queue. A production deployment should move `_run_mv_job` to Render Workflows or a queue-backed worker and upload outputs to object storage.
