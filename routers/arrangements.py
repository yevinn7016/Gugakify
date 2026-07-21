from fastapi import APIRouter, File, Form, Header, HTTPException, UploadFile
from sqlalchemy.orm import Session
from fastapi import Depends
from database import get_db
from models import GugakConversion
import cloudinary.uploader
import uuid

router = APIRouter()

BACKEND_TOKEN = "gugakify-backend-2026"  # 나중에 AI 담당자한테 이 토큰 알려줘야 해요

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

    # 중복 job_id 확인
    existing = db.query(GugakConversion).filter(GugakConversion.job_id == job_id).first()
    if existing:
        return {
            "job_id": job_id,
            "status": "saved",
            "audio_url": existing.converted_audio_url
        }

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
        project_id=1,  # 나중에 실제 project_id로 연결
        converted_audio_url=audio_url,
        rhythm_type=accompaniment_instrument,
        main_instruments=f"{vocal_instrument},{accompaniment_instrument}",
    )
    db.add(conversion)
    db.commit()

    return {
        "job_id": job_id,
        "status": "saved",
        "audio_url": audio_url
    }