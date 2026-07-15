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
    hf_sumukhwa.py        Hugging Face Stable Diffusion img2img adapter
    opencv_ink.py         Deterministic OpenCV ink-wash adapter
    openai_image.py       OpenAI Image API style-transfer adapter
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

On Windows, create or edit `.env`, then run:

```powershell
.\run_server.ps1
```

The server automatically loads `.env` through `python-dotenv`.

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
    "styleType": "sumukhwa",
    "preserveAudio": true
  }'
```

## Environment Variables

```bash
MODEL_ADAPTER=auto
CYCLEGAN_CHECKPOINT_PATH=D:\Guackify\models\cyclegan\checkpoint.pt
DCGAN_CHECKPOINT_PATH=D:\Guackify\models\dcgan\checkpoint.pt
PUBLIC_BASE_URL=https://storage.example.com
ENABLE_REAL_PIPELINE=false
MAX_INPUT_VIDEO_MB=200
```

## OpenAI Image Adapter

Use this adapter when you want to transform extracted frames with the OpenAI Image API instead of the local preview/CycleGAN adapter.

```bash
set ENABLE_REAL_PIPELINE=true
set MODEL_ADAPTER=openai_image
set OPENAI_API_KEY=your_api_key_here
set OPENAI_IMAGE_MODEL=gpt-image-2
```

The default prompt is:

```text
Traditional Korean Sumukhwa style, inspired by Joseon dynasty painters, hanji paper texture, ink wash technique, natural ink diffusion, thin dark ink outlines, elegant brush strokes, Korean cultural aesthetic, landscape painting influence, traditional Korean fine art, masterpiece, highly detailed, cinematic scene preservation, harmonious composition
```

You can override it with:

```bash
set OPENAI_IMAGE_PROMPT=your custom prompt
```

Never commit a real API key. Use local environment variables, a local `.env`, or hosting provider secrets.

## OpenCV Ink-Wash Adapter

Use this adapter for fast deterministic frame-by-frame ink-wash conversion without AI model inference.

```bash
set MODEL_ADAPTER=opencv_ink
set OPENCV_INK_STRENGTH=0.92
set OPENCV_WASH_STRENGTH=0.86
set OPENCV_PAPER_STRENGTH=0.18
set OPENCV_WHITE_SPACE=0.26
set OPENCV_DETAIL_LEVELS=8
set OPENCV_TEXTURE_STRENGTH=0.36
set OPENCV_DETAIL_PRESERVE=0.24
set OPENCV_FINE_LINE_STRENGTH=0.48
set OPENCV_OUTLINE_STRENGTH=0.55
```

Unlike generative models, this adapter is deterministic and fast enough to apply to every extracted frame. This usually gives smoother video continuity than keyframe-only diffusion on CPU.

## OpenCV Minhwa Adapter

Use this adapter for a Korean Minhwa look: thin dark outlines around people and objects, toned-down hanji background, and emphasized red, green, blue, black, and yellow folk-painting colors.

```bash
set MODEL_ADAPTER=opencv_minhwa
set OPENCV_MINHWA_PALETTE_STRENGTH=0.84
set OPENCV_MINHWA_OUTLINE_STRENGTH=0.92
set OPENCV_MINHWA_LINE_THICKNESS=1
set OPENCV_MINHWA_FLATTEN_STRENGTH=0.66
set OPENCV_MINHWA_SMOOTHING_STRENGTH=0.30
set OPENCV_MINHWA_PAPER_STRENGTH=0.28
set OPENCV_MINHWA_PIGMENT_BLEED=0.00
set OPENCV_MINHWA_HAND_DRAWN_STRENGTH=0.06
set OPENCV_MINHWA_PAINT_VARIATION=0.04
set OPENCV_MINHWA_AGE_STRENGTH=0.58
set OPENCV_MINHWA_PRESERVE_BRIGHTNESS=0.22
set OPENCV_MINHWA_COLOR_FADE=0.16
set OPENCV_MINHWA_COLOR_BOOST=0.62
set OPENCV_MINHWA_INK_TONE_STRENGTH=0.84
set OPENCV_MINHWA_SHARPNESS=0.70
set OPENCV_MINHWA_TEMPORAL_BLEND=0.00
```

For an older folk-painting look, raise `OPENCV_MINHWA_PAPER_STRENGTH`, `OPENCV_MINHWA_AGE_STRENGTH`, and `OPENCV_MINHWA_COLOR_FADE`. For a cleaner MV look, lower those values and raise `OPENCV_MINHWA_SHARPNESS`.

## Hugging Face Sumukhwa Adapter

Use this adapter to run the Hugging Face model `gagong/korean-sumukhwa-model-ver-1` through a Stable Diffusion image-to-image pipeline.

Install the common dependencies:

```bash
pip install -r requirements.txt
```

Install PyTorch for your machine separately. For CUDA builds, follow the command from the official PyTorch install selector because the correct wheel depends on your CUDA version.

Run with the Hugging Face adapter:

```bash
set ENABLE_REAL_PIPELINE=true
set MODEL_ADAPTER=hf_sumukhwa
set HF_SUMUKHWA_MODEL_ID=gagong/korean-sumukhwa-model-ver-1
set HF_SUMUKHWA_PROMPT=Korean sumukhwa style, traditional artistic drawing, ink painting, subtle details
set HF_SUMUKHWA_NEGATIVE_PROMPT=blurry, low quality, bad anatomy, vibrant colors, photorealistic, cartoon
set HF_SUMUKHWA_STRENGTH=0.45
set HF_SUMUKHWA_GUIDANCE_SCALE=7.5
set HF_SUMUKHWA_STEPS=6
set HF_SUMUKHWA_DEVICE=cpu
set HF_SUMUKHWA_DTYPE=float32
set HF_SUMUKHWA_MAX_SIZE=512
set HF_SUMUKHWA_KEYFRAME_ONLY=false
set HF_SUMUKHWA_NON_KEYFRAME_BLEND=0.55

uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The adapter defaults to CPU mode, 512px image-to-image input, and full-frame model inference when `HF_SUMUKHWA_KEYFRAME_ONLY=false`. CPU inference is much slower than GPU inference, but applying the model to every frame avoids visible style breaks between keyframes.

Completed job responses include `processingTimeSeconds` for the whole job time and `styleTransferTimeSeconds` for the frame style-transfer section.

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
