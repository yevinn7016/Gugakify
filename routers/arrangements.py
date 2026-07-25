from fastapi import APIRouter, File, Form, Header, HTTPException, UploadFile
from sqlalchemy.orm import Session
from fastapi import Depends
from database import get_db
from models import GugakConversion, MusicProject
import cloudinary.uploader
import uuid

router = APIRouter()

BACKEND_TOKEN = "gugakify-backend-2026"  # AI 담당자에게 전달한 토큰과 반드시 일치해야 함

@router.post("/api/arrangements/result")
async def receive_ai_result(
    job_id: str = Form(...),
    vocal_instrument: str = Form(""),
    accompaniment_instrument: str = Form(""),
    audio: UploadFile = File(...),
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db)
):
    # 인증 확인
    expected = f"Bearer {BACKEND_TOKEN}"
    if authorization != expected:
        raise HTTPException(status_code=401, detail="인증 토큰이 올바르지 않습니다.")

    # WAV 파일 확인
    if not audio.filename.lower().endswith(".wav"):
        raise HTTPException(status_code=400, detail="WAV 파일만 업로드할 수 있습니다.")

    # 중복 job_id 확인 (멱등 처리)
    existing = db.query(GugakConversion).filter(GugakConversion.job_id == job_id).first()
    if existing:
        return {
            "job_id": job_id,
            "status": "saved",
            "audio_url": existing.converted_audio_url
        }

    # 이 결과를 연결할 프로젝트 찾기: 아직 완료되지 않은 것 중 가장 최근에 업로드된 프로젝트
    # TODO: 나중에 job_id <-> project_id를 정식으로 매칭하는 방식으로 교체 필요
    target_project = (
        db.query(MusicProject)
        .filter(MusicProject.status != "completed")
        .order_by(MusicProject.id.desc())
        .first()
    )

    if not target_project:
        raise HTTPException(status_code=404, detail="연결할 작업을 찾을 수 없습니다.")

    # Cloudinary에 업로드
    contents = await audio.read()
    result = cloudinary.uploader.upload(
        contents,
        resource_type="video",
        public_id=f"results/{job_id}",
        folder="gugakify"
    )

    audio_url = result["secure_url"]

    # DB에 저장
    conversion = GugakConversion(
        project_id=target_project.id,
        job_id=job_id,
        converted_audio_url=audio_url,
        rhythm_type=accompaniment_instrument,
        main_instruments=f"{vocal_instrument},{accompaniment_instrument}",
    )
    db.add(conversion)

    # 프로젝트 상태를 완료로 업데이트
    target_project.status = "completed"

    db.commit()

    return {
        "job_id": job_id,
        "status": "saved",
        "audio_url": audio_url
    }