# Guackify MV AI Server

FastAPI based AI server for converting an existing MV into a Korean ink-and-color painting style video.

This project is currently structured around two layers:

- Video pipeline: video metadata, frame extraction, shot/keyframe detection, frame reconstruction, and optional audio merge.
- Model adapter: a replaceable interface for AI Hub CycleGAN/DCGAN checkpoints and future fine-tuned models.

## Model Direction

AI Hub model usage is split by role:

- CycleGAN Style Transfer: main frame-to-frame converter for MV frames.
- DCGAN Image Generator: style reference or texture generation support, not the main MV frame converter.

The MV conversion pipeline should avoid converting every frame independently with unrelated generations. The intended direction is:

1. Extract original FPS, resolution, duration, and audio.
2. Split the MV into shots using scene-change detection.
3. Select keyframes per shot.
4. Convert keyframes and frames through a shared model adapter.
5. Preserve temporal consistency with deterministic settings, keyframe context, optical flow, or interpolation.
6. Rebuild the video at the original FPS.
7. Merge the original audio back into the final MV.

## Project Layout

```text
app/
  main.py                 FastAPI entrypoint
  schemas.py              API request/response models
  store.py                In-memory job store for the current prototype
  models/
    base.py               Shared model adapter protocol
    cyclegan.py           AI Hub CycleGAN style-transfer adapter
    dcgan.py              AI Hub DCGAN generator adapter
    registry.py           Adapter selection from environment variables
  video/
    metadata.py           Video probing
    io.py                 Frame/audio extraction and video writing
    shots.py              Shot and keyframe detection
    pipeline.py           End-to-end video conversion pipeline
```

## Run Locally

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API Checks

```bash
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/model-adapters
```

## Create Conversion Job

```bash
curl -X POST http://localhost:8000/api/v1/mv-conversions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_001",
    "projectId": "project_001",
    "inputVideoUrl": "https://storage/video.mp4",
    "originalFileName": "music_video.mp4",
    "styleType": "sumukh_damchae",
    "preserveAudio": true
  }'
```

## Environment Variables

```bash
MODEL_ADAPTER=cyclegan
CYCLEGAN_CHECKPOINT_PATH=D:\Guackify\models\cyclegan\checkpoint.pt
DCGAN_CHECKPOINT_PATH=D:\Guackify\models\dcgan\checkpoint.pt
PUBLIC_BASE_URL=https://storage.example.com
ENABLE_REAL_PIPELINE=false
MAX_INPUT_VIDEO_MB=200
```

By default, the API job runner uses a lightweight placeholder pipeline so backend integration can be tested without loading heavy AI models.

To test with a real direct video URL, enable the real pipeline:

```bash
set ENABLE_REAL_PIPELINE=true
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then call `POST /api/v1/mv-conversions` with an `inputVideoUrl` that points directly to a downloadable video file such as `.mp4`.

YouTube URLs are also supported through `yt-dlp` in development mode:

```json
{
  "inputVideoUrl": "https://youtu.be/ekr2nIex040?si=...&t=150",
  "originalFileName": "youtube_mv.mp4"
}
```

The YouTube downloader is intended for videos you own or are allowed to process. Availability can depend on YouTube policy, region, age restrictions, cookies, and network access.

In real pipeline mode, the server downloads the video, extracts frames, detects shots/keyframes, applies the active model adapter, rebuilds the video, and returns `/outputs/...` URLs for the result and thumbnail.
