# Guackify MV AI Server

Guackify MV AI Server is a FastAPI server that converts an input music video into a Korean traditional visual style video.

Current supported styles:

- `sumukhwa`: Korean ink wash style with thin, dark outlines and monochrome ink texture
- `minhwa`: Korean folk painting style with thin, dark outlines, toned-down hanji background, and emphasized red, green, blue, black, and yellow colors

The user sends an MV URL and a style type. The server downloads the video, extracts frames, applies the selected style, rebuilds the video, merges the original audio, and returns the output video URL.

## Current Flow

1. Receive a video URL and style type.
2. Download the input MV.
3. Extract video metadata, frames, and optional audio.
4. Select the style adapter.
   - `styleType=sumukhwa` -> `opencv_ink`
   - `styleType=minhwa` -> `opencv_minhwa`
5. Apply style conversion frame by frame.
6. Rebuild the video at the original FPS and resolution.
7. Merge the original audio.
8. Return output video and thumbnail URLs.

## Project Layout

```text
app/
  main.py                 FastAPI entrypoint
  schemas.py              API request/response models
  store.py                In-memory job store for the current prototype
  models/
    base.py               Shared model adapter protocol
    cyclegan.py           AI Hub CycleGAN placeholder adapter
    dcgan.py              AI Hub DCGAN placeholder adapter
    hf_sumukhwa.py        Hugging Face Stable Diffusion img2img adapter
    opencv_ink.py         OpenCV Sumukhwa adapter
    opencv_minhwa.py      OpenCV Minhwa adapter
    openai_image.py       Optional OpenAI image adapter
    registry.py           Adapter selection
  services/
    download.py           Direct video / YouTube download
  video/
    metadata.py           Video metadata probing
    io.py                 Frame/audio extraction and video writing
    shots.py              Shot/keyframe detection utilities
    pipeline.py           End-to-end video conversion pipeline
scripts/
  generate_style_previews.py
```

## Requirements

- Python 3.11+
- FFmpeg available on the system path
- Render or local machine with enough temporary disk space for frames and output videos

Install dependencies:

```bash
pip install -r requirements.txt
```

## Local Run

Create a local `.env` from `.env.example`, then run:

```powershell
.\run_server.ps1
```

Or run directly:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Health checks:

```bash
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/model-adapters
```

## API

### Create Conversion Job

`POST /api/v1/mv-conversions`

```json
{
  "userId": "user_001",
  "projectId": "project_001",
  "inputVideoUrl": "https://example.com/input.mp4",
  "originalFileName": "input.mp4",
  "styleType": "sumukhwa",
  "preserveAudio": true,
  "callbackUrl": null
}
```

Use `styleType=minhwa` for the folk painting style.

Response:

```json
{
  "jobId": "job_xxxxxxxxxxxx",
  "status": "queued",
  "message": "Video conversion job has been created."
}
```

### Check Job Status

`GET /api/v1/mv-conversions/{jobId}`

```json
{
  "jobId": "job_xxxxxxxxxxxx",
  "status": "processing",
  "progress": 35,
  "currentStep": "style_transfer",
  "processingTimeSeconds": 120.5,
  "styleTransferTimeSeconds": null,
  "errorMessage": null
}
```

### Get Result

`GET /api/v1/mv-conversions/{jobId}/result`

```json
{
  "jobId": "job_xxxxxxxxxxxx",
  "status": "completed",
  "outputVideoUrl": "/outputs/job_xxxxxxxxxxxx_output.mp4",
  "thumbnailUrl": "/outputs/job_xxxxxxxxxxxx_thumbnail.png",
  "duration": 4.0,
  "outputFileSize": 1234567,
  "processingTimeSeconds": 180.2,
  "styleTransferTimeSeconds": 150.8
}
```

`processingTimeSeconds` is the whole job time. `styleTransferTimeSeconds` is the frame style-transfer section only.

## Environment Variables

Recommended default for the current API:

```env
ENABLE_REAL_PIPELINE=true
MODEL_ADAPTER=auto
PUBLIC_BASE_URL=
MAX_INPUT_VIDEO_MB=200
```

`MODEL_ADAPTER=auto` maps styles automatically:

```text
sumukhwa -> opencv_ink
minhwa   -> opencv_minhwa
```

Use a fixed adapter only when testing:

```env
MODEL_ADAPTER=opencv_ink
MODEL_ADAPTER=opencv_minhwa
MODEL_ADAPTER=hf_sumukhwa
```

## Sumukhwa Settings

The OpenCV Sumukhwa adapter is the fast default for `styleType=sumukhwa`.

```env
OPENCV_INK_STRENGTH=0.92
OPENCV_WASH_STRENGTH=0.86
OPENCV_PAPER_STRENGTH=0.18
OPENCV_WHITE_SPACE=0.26
OPENCV_DETAIL_LEVELS=8
OPENCV_TEXTURE_STRENGTH=0.22
OPENCV_DETAIL_PRESERVE=0.20
OPENCV_FINE_LINE_STRENGTH=0.34
OPENCV_OUTLINE_STRENGTH=0.48
```

This style emphasizes monochrome ink wash, hanji paper tone, thin dark outlines, and reduced speckle noise.

## Minhwa Settings

The OpenCV Minhwa adapter is the fast default for `styleType=minhwa`.

```env
OPENCV_MINHWA_PALETTE_STRENGTH=0.84
OPENCV_MINHWA_OUTLINE_STRENGTH=0.88
OPENCV_MINHWA_LINE_THICKNESS=1
OPENCV_MINHWA_FLATTEN_STRENGTH=0.66
OPENCV_MINHWA_SMOOTHING_STRENGTH=0.30
OPENCV_MINHWA_PAPER_STRENGTH=0.28
OPENCV_MINHWA_PIGMENT_BLEED=0.00
OPENCV_MINHWA_HAND_DRAWN_STRENGTH=0.03
OPENCV_MINHWA_PAINT_VARIATION=0.015
OPENCV_MINHWA_AGE_STRENGTH=0.58
OPENCV_MINHWA_PRESERVE_BRIGHTNESS=0.22
OPENCV_MINHWA_COLOR_FADE=0.16
OPENCV_MINHWA_COLOR_BOOST=0.62
OPENCV_MINHWA_INK_TONE_STRENGTH=0.84
OPENCV_MINHWA_SHARPNESS=0.52
OPENCV_MINHWA_TEMPORAL_BLEND=0.00
```

This style tones down the background toward hanji and emphasizes folk-painting colors on people and objects.

## Hugging Face Adapter

The Hugging Face adapter is optional and much slower on CPU. It can be used for experimental full-frame image-to-image conversion.

```env
MODEL_ADAPTER=hf_sumukhwa
HF_SUMUKHWA_MODEL_ID=gagong/korean-sumukhwa-model-ver-1
HF_SUMUKHWA_PROMPT=Korean sumukhwa style, traditional artistic drawing, ink painting, subtle details
HF_SUMUKHWA_NEGATIVE_PROMPT=blurry, low quality, bad anatomy, vibrant colors, photorealistic, cartoon
HF_SUMUKHWA_STRENGTH=0.65
HF_SUMUKHWA_GUIDANCE_SCALE=8.5
HF_SUMUKHWA_STEPS=4
HF_SUMUKHWA_DEVICE=cpu
HF_SUMUKHWA_DTYPE=float32
HF_SUMUKHWA_MAX_SIZE=512
HF_SUMUKHWA_KEYFRAME_ONLY=false
HF_SUMUKHWA_NON_KEYFRAME_BLEND=0.8
```

When `HF_SUMUKHWA_KEYFRAME_ONLY=false`, every extracted frame runs through the model. This avoids style breaks between keyframes, but CPU processing can take a long time.

## Preview Images

Generate still-image previews with the current server adapters:

```powershell
python scripts\generate_style_previews.py D:\Guackify\test.png --output-dir outputs
```

Outputs:

```text
outputs/test01.png  # sumukhwa
outputs/test02.png  # minhwa
```

## YouTube Inputs

Direct downloadable video URLs are preferred. YouTube URLs are supported through `yt-dlp` in development mode:

```json
{
  "inputVideoUrl": "https://youtu.be/example",
  "originalFileName": "youtube_mv.mp4"
}
```

Only process videos you own or are allowed to process. YouTube availability can depend on policy, region, age restrictions, cookies, and network access.

## Render Deployment

This repository includes `render.yaml`.

Render settings:

```text
Build Command: pip install -r requirements.txt
Start Command: uvicorn app.main:app --host 0.0.0.0 --port $PORT
Health Check Path: /health
Python Version: 3.12.8
```

Set environment variables in the Render dashboard. Do not upload a real `.env`.

For Render, make sure these are set:

```env
ENABLE_REAL_PIPELINE=true
MODEL_ADAPTER=auto
MAX_INPUT_VIDEO_MB=200
PYTHON_VERSION=3.12.8
```

If output files must be publicly persistent, connect external storage. Render local disk is not intended as permanent storage.

## Git Ignore

Do not commit:

- `.env`
- `.venv/`
- `work/`
- `outputs/`
- downloaded model weights
- test videos/images
- `.safetensors`, `.pt`, `.ckpt`, `.onnx`, `.bin`

Commit:

- `app/`
- `scripts/`
- `requirements.txt`
- `render.yaml`
- `README.md`
- `.env.example`
- `.gitignore`
