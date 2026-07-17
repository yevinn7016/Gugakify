import asyncio
import os
from datetime import datetime, timezone
from pathlib import Path
from time import perf_counter
from uuid import uuid4

import httpx
from dotenv import load_dotenv
from fastapi import BackgroundTasks, FastAPI, File, Form, HTTPException, UploadFile, status
from fastapi.staticfiles import StaticFiles

load_dotenv()

from app.models.registry import create_model_adapter, preload_model_adapter
from app.schemas import (
    ConversionRequest,
    CurrentStep,
    JobCreateResponse,
    JobResultResponse,
    JobStatus,
    JobStatusResponse,
    StyleType,
)
from app.services.download import download_video
from app.store import ConversionJob, job_store
from app.video.pipeline import VideoConversionPipeline

app = FastAPI(
    title="Guackify MV AI Server",
    description="Korean ink-and-color painting style MV conversion AI server.",
    version="0.2.0",
)
Path("outputs").mkdir(parents=True, exist_ok=True)
app.mount("/outputs", StaticFiles(directory="outputs"), name="outputs")


@app.get("/")
def root() -> dict[str, str]:
    return {"service": "guackify-mv-ai-server", "status": "ok"}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/v1/model-adapters")
def get_model_adapter_info() -> dict[str, str | None]:
    selected = (os.getenv("MODEL_ADAPTER") or "").strip().lower()
    if selected == "auto":
        return {
            "activeAdapter": "auto",
            "checkpointPath": None,
            "role": "sumukhwa -> opencv_ink, minhwa -> opencv_minhwa",
            "loaded": None,
        }

    adapter = create_model_adapter()
    checkpoint_path = getattr(adapter, "checkpoint_path", None)
    loaded = getattr(adapter, "is_loaded", None)
    return {
        "activeAdapter": adapter.name,
        "checkpointPath": str(checkpoint_path) if checkpoint_path else None,
        "role": "OpenCV adapters convert MV frames to sumukhwa or minhwa styles.",
        "loaded": str(loaded) if loaded is not None else None,
    }


@app.post("/api/v1/model-adapters/preload")
def preload_active_model_adapter() -> dict[str, str]:
    selected = (os.getenv("MODEL_ADAPTER") or "").strip().lower()
    if selected == "auto":
        return {
            "activeAdapter": "auto",
            "status": "style-based adapters are selected at job runtime",
        }

    adapter = preload_model_adapter()
    return {
        "activeAdapter": adapter.name,
        "status": "loaded",
    }


@app.post(
    "/api/v1/mv-conversions",
    response_model=JobCreateResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
def create_conversion_job(
    payload: ConversionRequest,
    background_tasks: BackgroundTasks,
) -> JobCreateResponse:
    job_id = f"job_{uuid4().hex[:12]}"
    job = ConversionJob(
        job_id=job_id,
        user_id=payload.userId,
        project_id=payload.projectId,
        input_video_url=str(payload.inputVideoUrl),
        original_file_name=payload.originalFileName,
        style_type=payload.styleType,
        preserve_audio=payload.preserveAudio,
        callback_url=str(payload.callbackUrl) if payload.callbackUrl else None,
    )
    job_store.create(job)
    if _real_pipeline_enabled():
        background_tasks.add_task(run_real_conversion_pipeline, job_id)
    else:
        background_tasks.add_task(run_conversion_pipeline_placeholder, job_id)

    return JobCreateResponse(
        jobId=job_id,
        status=JobStatus.QUEUED,
        message="Video conversion job has been created.",
    )


@app.post(
    "/api/v1/mv-conversions/upload",
    response_model=JobCreateResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def create_conversion_upload_job(
    background_tasks: BackgroundTasks,
    userId: str = Form(...),
    projectId: str = Form(...),
    styleType: str = Form(...),
    preserveAudio: bool = Form(True),
    callbackUrl: str | None = Form(None),
    originalFileName: str | None = Form(None),
    file: UploadFile = File(...),
) -> JobCreateResponse:
    if not userId.strip():
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="userId is required.")
    if not projectId.strip():
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="projectId is required.")

    normalized_style = styleType.strip().lower()
    if normalized_style not in {"sumukhwa", "minhwa"}:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="styleType must be either 'sumukhwa' or 'minhwa'.",
        )

    job_id = f"job_{uuid4().hex[:12]}"
    upload_dir = _work_dir() / job_id / "upload"
    input_path = await _save_upload_file(file, upload_dir, _max_input_video_bytes())
    callback_url = callbackUrl.strip() if callbackUrl and callbackUrl.strip() else None
    source_name = originalFileName.strip() if originalFileName and originalFileName.strip() else input_path.name

    job = ConversionJob(
        job_id=job_id,
        user_id=userId,
        project_id=projectId,
        input_video_url="",
        original_file_name=source_name,
        style_type=StyleType(normalized_style),
        preserve_audio=preserveAudio,
        callback_url=callback_url,
        input_file_path=str(input_path),
        input_source_type="file",
    )
    job_store.create(job)
    if _real_pipeline_enabled():
        background_tasks.add_task(run_real_conversion_pipeline, job_id)
    else:
        background_tasks.add_task(run_conversion_pipeline_placeholder, job_id)

    return JobCreateResponse(
        jobId=job_id,
        status=JobStatus.QUEUED,
        message="Uploaded video conversion job has been created.",
    )


@app.get("/api/v1/mv-conversions/{job_id}", response_model=JobStatusResponse)
def get_conversion_job_status(job_id: str) -> JobStatusResponse:
    job = get_job_or_404(job_id)
    return JobStatusResponse(
        jobId=job.job_id,
        status=job.status,
        progress=job.progress,
        currentStep=job.current_step,
        processingTimeSeconds=_job_processing_time_seconds(job),
        styleTransferTimeSeconds=job.style_transfer_time_seconds,
        errorMessage=job.error_message,
    )


@app.get("/api/v1/mv-conversions/{job_id}/result", response_model=JobResultResponse)
def get_conversion_job_result(job_id: str) -> JobResultResponse:
    job = get_job_or_404(job_id)
    if job.status != JobStatus.COMPLETED:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="The conversion job has not completed yet.",
        )

    return JobResultResponse(
        jobId=job.job_id,
        status=job.status,
        outputVideoUrl=job.output_video_url or "",
        thumbnailUrl=job.thumbnail_url or "",
        duration=job.duration or 0.0,
        outputFileSize=job.output_file_size or 0,
        processingTimeSeconds=_job_processing_time_seconds(job),
        styleTransferTimeSeconds=job.style_transfer_time_seconds,
    )


def get_job_or_404(job_id: str) -> ConversionJob:
    job = job_store.get(job_id)
    if job is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="The requested job was not found.",
        )
    return job


async def run_conversion_pipeline_placeholder(job_id: str) -> None:
    started_at = perf_counter()
    try:
        steps = [
            (CurrentStep.UPLOAD, 10),
            (CurrentStep.FRAME_EXTRACT, 35),
            (CurrentStep.STYLE_TRANSFER, 70),
            (CurrentStep.VIDEO_MERGE, 95),
        ]

        job_store.update(job_id, status=JobStatus.PROCESSING)
        for step, progress in steps:
            job_store.update(job_id, current_step=step, progress=progress)
            await asyncio.sleep(0.5)

        public_base_url = os.getenv("PUBLIC_BASE_URL", "https://storage.example.com")
        job = job_store.update(
            job_id,
            status=JobStatus.COMPLETED,
            progress=100,
            current_step=CurrentStep.DONE,
            output_video_url=f"{public_base_url}/guackify/{job_id}/output_video.mp4",
            thumbnail_url=f"{public_base_url}/guackify/{job_id}/thumbnail.jpg",
            duration=30.0,
            output_file_size=12_345_678,
            processing_time_seconds=perf_counter() - started_at,
            style_transfer_time_seconds=0.5,
        )
        if job and job.callback_url:
            try:
                await send_completion_callback(job)
            except httpx.HTTPError:
                pass
    except Exception as exc:
        job_store.update(
            job_id,
            status=JobStatus.FAILED,
            error_message=str(exc),
            processing_time_seconds=perf_counter() - started_at,
        )


async def run_real_conversion_pipeline(job_id: str) -> None:
    job = job_store.get(job_id)
    if job is None:
        return

    started_at = perf_counter()
    try:
        job_store.update(
            job_id,
            status=JobStatus.PROCESSING,
            current_step=CurrentStep.UPLOAD,
            progress=5,
        )
        job_dir = _work_dir() / job_id
        if job.input_file_path:
            input_path = Path(job.input_file_path)
            if not input_path.exists():
                raise FileNotFoundError(f"Uploaded input video was not found: {input_path}")
        else:
            input_path = await download_video(
                url=job.input_video_url,
                original_file_name=job.original_file_name,
                output_dir=job_dir,
                max_bytes=_max_input_video_bytes(),
            )

        job_store.update(job_id, current_step=CurrentStep.STYLE_TRANSFER, progress=35)
        pipeline = VideoConversionPipeline(create_model_adapter(_adapter_name_for_style(job.style_type)))
        result = await asyncio.to_thread(
            pipeline.run,
            job_id,
            input_path,
            _work_dir(),
            _output_dir(),
            str(job.style_type),
            job.preserve_audio,
        )

        job_store.update(job_id, current_step=CurrentStep.VIDEO_MERGE, progress=95)
        public_base_url = os.getenv("PUBLIC_BASE_URL", "").rstrip("/")
        output_url = _public_output_url(result.output_video_path, public_base_url)
        thumbnail_url = _public_output_url(result.thumbnail_path, public_base_url) if result.thumbnail_path else ""
        updated_job = job_store.update(
            job_id,
            status=JobStatus.COMPLETED,
            progress=100,
            current_step=CurrentStep.DONE,
            output_video_url=output_url,
            thumbnail_url=thumbnail_url,
            duration=result.metadata.duration,
            output_file_size=result.output_file_size,
            processing_time_seconds=perf_counter() - started_at,
            style_transfer_time_seconds=result.style_transfer_time_seconds,
        )
        if updated_job and updated_job.callback_url:
            try:
                await send_completion_callback(updated_job)
            except httpx.HTTPError:
                pass
    except Exception as exc:
        job_store.update(
            job_id,
            status=JobStatus.FAILED,
            error_message=str(exc),
            processing_time_seconds=perf_counter() - started_at,
        )


async def send_completion_callback(job: ConversionJob) -> None:
    callback_payload = JobResultResponse(
        jobId=job.job_id,
        status=job.status,
        outputVideoUrl=job.output_video_url or "",
        thumbnailUrl=job.thumbnail_url or "",
        duration=job.duration or 0.0,
        outputFileSize=job.output_file_size or 0,
        processingTimeSeconds=job.processing_time_seconds,
        styleTransferTimeSeconds=job.style_transfer_time_seconds,
    ).model_dump()

    async with httpx.AsyncClient(timeout=5.0) as client:
        await client.post(job.callback_url, json=callback_payload)


def _real_pipeline_enabled() -> bool:
    return os.getenv("ENABLE_REAL_PIPELINE", "false").lower() in {"1", "true", "yes", "on"}


def _adapter_name_for_style(style_type: object) -> str | None:
    selected = (os.getenv("MODEL_ADAPTER") or "").strip().lower()
    if selected and selected != "auto":
        return selected

    style_value = str(style_type).lower()
    if style_value.endswith(".sumukhwa") or style_value == "sumukhwa":
        return "opencv_ink"
    if style_value.endswith(".minhwa") or style_value == "minhwa":
        return "opencv_minhwa"
    return None


def _work_dir() -> Path:
    return Path(os.getenv("GUACKIFY_WORK_DIR", "work/jobs"))


def _output_dir() -> Path:
    output_dir = Path(os.getenv("GUACKIFY_OUTPUT_DIR", "outputs"))
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir


def _max_input_video_bytes() -> int:
    megabytes = int(os.getenv("MAX_INPUT_VIDEO_MB", "200"))
    return megabytes * 1024 * 1024


async def _save_upload_file(upload_file: UploadFile, output_dir: Path, max_bytes: int) -> Path:
    file_name = Path(upload_file.filename or "input.mp4").name
    suffix = Path(file_name).suffix.lower() or ".mp4"
    if suffix not in {".mp4", ".mov", ".m4v", ".webm"}:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Only mp4, mov, m4v, and webm video files are supported.",
        )

    output_dir.mkdir(parents=True, exist_ok=True)
    target_path = output_dir / f"input{suffix}"
    total_bytes = 0
    try:
        with target_path.open("wb") as buffer:
            while chunk := await upload_file.read(1024 * 1024):
                total_bytes += len(chunk)
                if total_bytes > max_bytes:
                    target_path.unlink(missing_ok=True)
                    raise HTTPException(
                        status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                        detail="Uploaded video exceeds MAX_INPUT_VIDEO_MB.",
                    )
                buffer.write(chunk)
    finally:
        await upload_file.close()

    if total_bytes == 0:
        target_path.unlink(missing_ok=True)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Uploaded video file is empty.")
    return target_path


def _public_output_url(path: Path, public_base_url: str) -> str:
    try:
        relative = path.resolve().relative_to(Path("outputs").resolve()).as_posix()
        local_path = f"/outputs/{relative}"
    except ValueError:
        local_path = str(path)

    if public_base_url:
        return f"{public_base_url}{local_path}"
    return local_path


def _job_processing_time_seconds(job: ConversionJob) -> float | None:
    if job.processing_time_seconds is not None:
        return job.processing_time_seconds
    if job.status in {JobStatus.PROCESSING, JobStatus.QUEUED}:
        return (datetime.now(timezone.utc) - job.created_at).total_seconds()
    return None
