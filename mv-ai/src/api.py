from __future__ import annotations

import os
import shutil
import threading
import uuid
from pathlib import Path
from typing import Annotated, Any

from fastapi import BackgroundTasks, Depends, FastAPI, File, Form, Header, HTTPException, UploadFile, status
from fastapi.responses import FileResponse

from analyzer import analyze_audio
from director import build_direction
from job_manager import read_status, write_json, write_status
from renderer import render_video


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_ROOT = Path(os.getenv("MV_DATA_ROOT", PROJECT_ROOT / "data")).resolve()
JOBS_ROOT = DATA_ROOT / "jobs"
API_KEY = os.getenv("MV_API_KEY")
MAX_UPLOAD_BYTES = int(os.getenv("MV_MAX_UPLOAD_BYTES", str(50 * 1024 * 1024)))
ALLOWED_AUDIO = {".mp3", ".wav", ".m4a", ".aac", ".flac", ".ogg"}
ALLOWED_IMAGES = {".png", ".jpg", ".jpeg", ".webp"}
RENDER_LOCK = threading.Lock()

app = FastAPI(
    title="Gugakify Reactive MV API",
    version="1.0.0",
    description="Creates a music-reactive Korean ink-wash MV of up to 30 seconds.",
)


def require_api_key(x_api_key: Annotated[str | None, Header()] = None) -> None:
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid API key.")


def get_job_dir(job_id: str) -> Path:
    try:
        normalized = str(uuid.UUID(job_id))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="Invalid job ID.") from exc
    job_dir = JOBS_ROOT / normalized
    if not job_dir.exists():
        raise HTTPException(status_code=404, detail="MV job not found.")
    return job_dir


def _copy_upload(upload: UploadFile, destination: Path, limit: int = MAX_UPLOAD_BYTES) -> int:
    destination.parent.mkdir(parents=True, exist_ok=True)
    size = 0
    with destination.open("wb") as target:
        while chunk := upload.file.read(1024 * 1024):
            size += len(chunk)
            if size > limit:
                target.close()
                destination.unlink(missing_ok=True)
                raise HTTPException(status_code=413, detail=f"Upload exceeds {limit} bytes.")
            target.write(chunk)
    if size == 0:
        destination.unlink(missing_ok=True)
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")
    return size


def _run_mv_job(
    job_dir: Path,
    audio_path: Path,
    background_paths: list[Path],
    start_time: float | None,
    mood: str | None,
    jangdan: str | None,
) -> None:
    try:
        write_status(job_dir, "waiting_for_renderer")
        with RENDER_LOCK:
            write_status(job_dir, "analyzing")
            analysis = analyze_audio(audio_path, start_time=start_time)
            direction = build_direction(analysis, mood=mood, jangdan=jangdan)
            write_json(job_dir / "analysis.json", analysis)
            write_json(job_dir / "direction.json", direction)
            write_status(
                job_dir,
                "rendering",
                sourceStart=analysis["sourceStart"],
                duration=analysis["duration"],
                bpm=analysis["bpm"],
                mood=direction["mood"],
                jangdan=direction["jangdan"],
            )
            output = render_video(
                audio_path=audio_path,
                output_path=job_dir / "final_mv.mp4",
                analysis=analysis,
                direction=direction,
                custom_backgrounds=background_paths,
            )
            write_status(
                job_dir,
                "completed",
                videoBytes=output.stat().st_size,
                videoUrl=f"/mv/jobs/{job_dir.name}/video",
                analysisUrl=f"/mv/jobs/{job_dir.name}/analysis",
                directionUrl=f"/mv/jobs/{job_dir.name}/direction",
            )
    except Exception as exc:
        write_status(job_dir, "failed", errorType=type(exc).__name__, error=str(exc))


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "gugakify-mv"}


@app.post("/mv/jobs", status_code=status.HTTP_202_ACCEPTED)
def create_mv_job(
    background_tasks: BackgroundTasks,
    audio: Annotated[UploadFile, File(description="Audio used for analysis and the final soundtrack")],
    background_1: Annotated[UploadFile | str | None, File(description="Optional first SDXL/FLUX image")] = None,
    background_2: Annotated[UploadFile | str | None, File(description="Optional second SDXL/FLUX image")] = None,
    background_3: Annotated[UploadFile | str | None, File(description="Optional third SDXL/FLUX image")] = None,
    start_time: Annotated[str, Form(description="Optional source start in seconds; leave blank for automatic selection")] = "",
    mood: Annotated[str | None, Form(max_length=32)] = None,
    jangdan: Annotated[str | None, Form(max_length=32)] = None,
    _: None = Depends(require_api_key),
) -> dict[str, Any]:
    try:
        parsed_start_time = float(start_time) if start_time.strip() else None
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="start_time must be a number or blank.") from exc
    if parsed_start_time is not None and parsed_start_time < 0:
        raise HTTPException(status_code=400, detail="start_time cannot be negative.")

    audio_name = Path(audio.filename or "input.wav").name
    audio_extension = Path(audio_name).suffix.lower()
    if audio_extension not in ALLOWED_AUDIO:
        raise HTTPException(status_code=400, detail=f"Unsupported audio format: {audio_extension}")
    uploaded_backgrounds = [
        upload
        for upload in (background_1, background_2, background_3)
        if isinstance(upload, UploadFile)
    ]

    job_id = str(uuid.uuid4())
    job_dir = JOBS_ROOT / job_id
    input_dir = job_dir / "input"
    audio_path = input_dir / f"audio{audio_extension}"
    _copy_upload(audio, audio_path)

    background_paths: list[Path] = []
    try:
        for index, upload in enumerate(uploaded_backgrounds):
            extension = Path(upload.filename or "").suffix.lower()
            if extension not in ALLOWED_IMAGES:
                raise HTTPException(status_code=400, detail=f"Unsupported image format: {extension}")
            path = input_dir / "backgrounds" / f"background_{index + 1}{extension}"
            _copy_upload(upload, path, limit=15 * 1024 * 1024)
            background_paths.append(path)
    except Exception:
        shutil.rmtree(job_dir, ignore_errors=True)
        raise

    write_status(
        job_dir,
        "queued",
        originalFilename=audio_name,
        requestedStart=parsed_start_time,
        requestedMood=mood,
        requestedJangdan=jangdan,
        customBackgrounds=len(background_paths),
    )
    background_tasks.add_task(
        _run_mv_job,
        job_dir,
        audio_path,
        background_paths,
        parsed_start_time,
        mood,
        jangdan,
    )
    return {
        "jobId": job_id,
        "status": "queued",
        "statusUrl": f"/mv/jobs/{job_id}",
        "maximumDuration": 30,
    }


@app.get("/mv/jobs/{job_id}")
def get_mv_job(job_id: str, _: None = Depends(require_api_key)) -> dict[str, Any]:
    return read_status(get_job_dir(job_id))


def _json_download(job_id: str, filename: str) -> FileResponse:
    path = get_job_dir(job_id) / filename
    if not path.exists():
        raise HTTPException(status_code=409, detail=f"{filename} is not ready.")
    return FileResponse(path, media_type="application/json", filename=filename)


@app.get("/mv/jobs/{job_id}/analysis")
def download_analysis(job_id: str, _: None = Depends(require_api_key)) -> FileResponse:
    return _json_download(job_id, "analysis.json")


@app.get("/mv/jobs/{job_id}/direction")
def download_direction(job_id: str, _: None = Depends(require_api_key)) -> FileResponse:
    return _json_download(job_id, "direction.json")


@app.get("/mv/jobs/{job_id}/video")
def download_video(job_id: str, _: None = Depends(require_api_key)) -> FileResponse:
    job_dir = get_job_dir(job_id)
    job = read_status(job_dir)
    path = job_dir / "final_mv.mp4"
    if job.get("status") != "completed" or not path.exists():
        raise HTTPException(status_code=409, detail="MV is not ready.")
    return FileResponse(path, media_type="video/mp4", filename=f"gugakify-{job_id}.mp4")
