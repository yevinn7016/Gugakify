from __future__ import annotations

import os
import shutil
import uuid
from pathlib import Path
from typing import Any, Dict, Optional
from zipfile import ZIP_DEFLATED, ZipFile

import httpx
from fastapi import (
    BackgroundTasks,
    Depends,
    FastAPI,
    File,
    Form,
    Header,
    HTTPException,
    UploadFile,
    status,
)
from fastapi.responses import FileResponse

from instrument_profiles import get_instrument_profile
from job_manager import read_status, write_status
from pipeline import prepare_render_job


PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = Path(os.getenv("OUTPUT_ROOT", PROJECT_ROOT / "outputs")).resolve()
INCOMING_ROOT = Path(
    os.getenv("INCOMING_ROOT", PROJECT_ROOT / "uploads" / "api")
).resolve()
BACKEND_RESULT_URL = os.getenv("BACKEND_RESULT_URL")
BACKEND_API_TOKEN = os.getenv("BACKEND_API_TOKEN")
AI_API_KEY = os.getenv("AI_API_KEY")
ALLOWED_AUDIO_EXTENSIONS = {".mp3", ".wav", ".m4a"}


app = FastAPI(
    title="Gugakify AI API",
    version="1.0.0",
    description=(
        "음원 분리와 악기별 MIDI 생성을 수행하고, 개발자의 최종 WAV를 "
        "백엔드로 전달합니다."
    ),
)


def require_api_key(x_api_key: Optional[str] = Header(default=None)) -> None:
    if AI_API_KEY and x_api_key != AI_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="유효하지 않은 API 키입니다.",
        )


def get_job_dir(job_id: str) -> Path:
    try:
        parsed_job_id = str(uuid.UUID(job_id))
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="잘못된 작업 ID입니다.") from exc

    job_dir = OUTPUT_ROOT / "jobs" / parsed_job_id
    if not job_dir.exists():
        raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다.")
    return job_dir


def _run_prepare_job(
    input_audio: Path,
    vocal_instrument: str,
    accompaniment_instrument: str,
    job_id: str,
) -> None:
    job_dir = OUTPUT_ROOT / "jobs" / job_id
    try:
        prepare_render_job(
            input_audio=input_audio,
            vocal_instrument=vocal_instrument,
            accompaniment_instrument=accompaniment_instrument,
            output_root=OUTPUT_ROOT,
            job_id=job_id,
            resume_queued_job=True,
        )
    except Exception as exc:
        write_status(
            job_dir,
            "failed",
            error_type=type(exc).__name__,
            error=str(exc),
        )


def _validate_wav(path: Path) -> None:
    if path.stat().st_size < 44:
        raise ValueError("WAV 파일이 지나치게 작습니다.")
    with path.open("rb") as wav_file:
        header = wav_file.read(12)
    if header[:4] not in {b"RIFF", b"RF64"} or header[8:12] != b"WAVE":
        raise ValueError("유효한 WAV 파일 헤더가 아닙니다.")


def deliver_result_to_backend(job_dir: Path) -> Dict[str, Any]:
    if not BACKEND_RESULT_URL:
        return write_status(
            job_dir,
            "result_uploaded",
            delivery_message="BACKEND_RESULT_URL이 없어 백엔드 전달을 대기합니다.",
        )

    job = read_status(job_dir)
    result_path = Path(job.get("result_wav", job_dir / "result.wav"))
    if not result_path.exists():
        raise FileNotFoundError(f"최종 WAV가 없습니다: {result_path}")

    write_status(job_dir, "delivering")
    headers = {}
    if BACKEND_API_TOKEN:
        headers["Authorization"] = f"Bearer {BACKEND_API_TOKEN}"

    try:
        with result_path.open("rb") as audio_file:
            response = httpx.post(
                BACKEND_RESULT_URL,
                headers=headers,
                data={
                    "job_id": job_dir.name,
                    "vocal_instrument": job.get("vocal_instrument", ""),
                    "accompaniment_instrument": job.get(
                        "accompaniment_instrument", ""
                    ),
                },
                files={
                    "audio": ("result.wav", audio_file, "audio/wav"),
                },
                timeout=120,
            )
            response.raise_for_status()
    except Exception as exc:
        write_status(
            job_dir,
            "delivery_failed",
            delivery_error_type=type(exc).__name__,
            delivery_error=str(exc),
        )
        raise

    try:
        backend_response: Any = response.json()
    except ValueError:
        backend_response = {"text": response.text}

    return write_status(
        job_dir,
        "delivered",
        backend_status_code=response.status_code,
        backend_response=backend_response,
    )


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok"}


@app.post("/jobs", status_code=status.HTTP_202_ACCEPTED)
def create_job(
    background_tasks: BackgroundTasks,
    audio: UploadFile = File(...),
    vocal_instrument: str = Form(...),
    accompaniment_instrument: str = Form(...),
    _: None = Depends(require_api_key),
) -> Dict[str, Any]:
    try:
        get_instrument_profile(vocal_instrument)
        get_instrument_profile(accompaniment_instrument)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    original_name = Path(audio.filename or "input.wav").name
    extension = Path(original_name).suffix.lower()
    if extension not in ALLOWED_AUDIO_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="MP3, WAV, M4A 파일만 업로드할 수 있습니다.",
        )

    job_id = str(uuid.uuid4())
    incoming_dir = INCOMING_ROOT / job_id
    incoming_dir.mkdir(parents=True, exist_ok=False)
    input_path = incoming_dir / f"input{extension}"
    with input_path.open("wb") as output_file:
        shutil.copyfileobj(audio.file, output_file)

    if input_path.stat().st_size == 0:
        input_path.unlink(missing_ok=True)
        raise HTTPException(status_code=400, detail="업로드 파일이 비어 있습니다.")

    job_dir = OUTPUT_ROOT / "jobs" / job_id
    job_dir.mkdir(parents=True, exist_ok=False)
    write_status(
        job_dir,
        "queued",
        original_filename=original_name,
        vocal_instrument=vocal_instrument,
        accompaniment_instrument=accompaniment_instrument,
    )

    background_tasks.add_task(
        _run_prepare_job,
        input_path,
        vocal_instrument,
        accompaniment_instrument,
        job_id,
    )
    return {
        "job_id": job_id,
        "status": "queued",
        "status_url": f"/jobs/{job_id}",
        "midi_download_url": f"/jobs/{job_id}/midi",
        "result_upload_url": f"/jobs/{job_id}/result",
    }


@app.get("/jobs/{job_id}")
def get_job_status(
    job_id: str,
    _: None = Depends(require_api_key),
) -> Dict[str, Any]:
    return read_status(get_job_dir(job_id))


@app.get("/jobs/{job_id}/midi")
def download_job_midi(
    job_id: str,
    _: None = Depends(require_api_key),
) -> FileResponse:
    job_dir = get_job_dir(job_id)
    job = read_status(job_dir)
    midi_files = [Path(path) for path in job.get("midi_files", {}).values()]
    if len(midi_files) != 2 or not all(path.exists() for path in midi_files):
        raise HTTPException(
            status_code=409,
            detail="MIDI 생성이 아직 완료되지 않았습니다.",
        )

    zip_path = job_dir / f"{job_id}-midi.zip"
    temporary_zip = zip_path.with_suffix(".zip.tmp")
    with ZipFile(temporary_zip, "w", ZIP_DEFLATED) as archive:
        for midi_path in midi_files:
            archive.write(midi_path, arcname=midi_path.name)
    temporary_zip.replace(zip_path)

    return FileResponse(
        path=zip_path,
        media_type="application/zip",
        filename=zip_path.name,
    )


@app.post("/jobs/{job_id}/result")
def upload_final_result(
    job_id: str,
    audio: UploadFile = File(...),
    _: None = Depends(require_api_key),
) -> Dict[str, Any]:
    job_dir = get_job_dir(job_id)
    job = read_status(job_dir)
    if job.get("status") not in {
        "waiting_for_manual_render",
        "result_uploaded",
        "delivery_failed",
        "delivered",
    }:
        raise HTTPException(
            status_code=409,
            detail=f"최종 WAV를 받을 수 없는 작업 상태입니다: {job.get('status')}",
        )

    if Path(audio.filename or "").suffix.lower() != ".wav":
        raise HTTPException(status_code=400, detail="WAV 파일만 업로드할 수 있습니다.")

    result_path = job_dir / "result.wav"
    temporary_path = job_dir / ".result.uploading.wav"
    with temporary_path.open("wb") as output_file:
        shutil.copyfileobj(audio.file, output_file)

    try:
        _validate_wav(temporary_path)
    except ValueError as exc:
        temporary_path.unlink(missing_ok=True)
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    temporary_path.replace(result_path)
    write_status(
        job_dir,
        "result_uploaded",
        result_wav=str(result_path),
        uploaded_filename=Path(audio.filename or "result.wav").name,
    )

    try:
        return deliver_result_to_backend(job_dir)
    except Exception as exc:
        raise HTTPException(
            status_code=502,
            detail=(
                "최종 WAV는 저장했지만 백엔드 전달에 실패했습니다: "
                f"{exc}"
            ),
        ) from exc


@app.post("/results")
def upload_standalone_result(
    audio: UploadFile = File(...),
    vocal_instrument: str = Form(default=""),
    accompaniment_instrument: str = Form(default=""),
    _: None = Depends(require_api_key),
) -> Dict[str, Any]:
    """AI 작업과 연결하지 않고 완성된 WAV를 백엔드로 전달한다."""
    if Path(audio.filename or "").suffix.lower() != ".wav":
        raise HTTPException(status_code=400, detail="WAV 파일만 업로드할 수 있습니다.")

    for instrument in (vocal_instrument, accompaniment_instrument):
        if instrument:
            try:
                get_instrument_profile(instrument)
            except ValueError as exc:
                raise HTTPException(status_code=400, detail=str(exc)) from exc

    delivery_id = str(uuid.uuid4())
    job_dir = OUTPUT_ROOT / "jobs" / delivery_id
    job_dir.mkdir(parents=True, exist_ok=False)
    result_path = job_dir / "result.wav"
    temporary_path = job_dir / ".result.uploading.wav"

    with temporary_path.open("wb") as output_file:
        shutil.copyfileobj(audio.file, output_file)

    try:
        _validate_wav(temporary_path)
    except ValueError as exc:
        temporary_path.unlink(missing_ok=True)
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    temporary_path.replace(result_path)
    write_status(
        job_dir,
        "result_uploaded",
        delivery_id=delivery_id,
        job_type="standalone_result",
        vocal_instrument=vocal_instrument,
        accompaniment_instrument=accompaniment_instrument,
        result_wav=str(result_path),
        uploaded_filename=Path(audio.filename or "result.wav").name,
    )

    try:
        return deliver_result_to_backend(job_dir)
    except Exception as exc:
        raise HTTPException(
            status_code=502,
            detail=(
                "최종 WAV는 저장했지만 백엔드 전달에 실패했습니다: "
                f"{exc}"
            ),
        ) from exc


@app.post("/jobs/{job_id}/deliver")
def retry_backend_delivery(
    job_id: str,
    _: None = Depends(require_api_key),
) -> Dict[str, Any]:
    job_dir = get_job_dir(job_id)
    try:
        return deliver_result_to_backend(job_dir)
    except Exception as exc:
        raise HTTPException(
            status_code=502,
            detail=f"백엔드 전달에 실패했습니다: {exc}",
        ) from exc
