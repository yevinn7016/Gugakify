import os
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from database import get_db
from models import MvGeneration
from dotenv import load_dotenv
import httpx

load_dotenv()

router = APIRouter()

AI_MV_SERVER = os.getenv("AI_MV_SERVER")
MV_API_KEY = os.getenv("MV_API_KEY")

@router.post("/api/mvs")
async def request_mv_conversion(
    audio: UploadFile = File(...),
    mood: str = Form("balanced"),
    jangdan: str = Form("jajinmori"),
    project_id: int = Form(1),
    db: Session = Depends(get_db)
):
    # AI 서버에 MV 변환 요청
    audio_bytes = await audio.read()

    async with httpx.AsyncClient(timeout=300.0) as client:
        response = await client.post(
            f"{AI_MV_SERVER}/mv/jobs",
            headers={"X-API-Key": MV_API_KEY},
            files={"audio": (audio.filename, audio_bytes, audio.content_type)},
            data={
                "start_time": "",
                "mood": mood,
                "jangdan": jangdan,
            }
        )

    if response.status_code != 202:
        raise HTTPException(status_code=500, detail=f"MV 변환 요청 실패: {response.text}")

    data = response.json()
    job_id = data["jobId"]

    # DB에 저장
    mv = MvGeneration(
    project_id=project_id,
    conversion_id=1,
    mv_url=None,
    visual_style=mood,
    job_id=job_id,
    )

    db.add(mv)
    db.commit()
    db.refresh(mv)

    return {
        "mv_id": mv.id,
        "job_id": job_id,
        "status": data["status"]
    }

@router.get("/api/mvs/{mv_id}")
async def get_mv_status(mv_id: int, db: Session = Depends(get_db)):
    mv = db.query(MvGeneration).filter(MvGeneration.id == mv_id).first()
    if not mv:
        raise HTTPException(status_code=404, detail="MV 작업을 찾을 수 없습니다.")

    if mv.mv_url:
        return {
            "mv_id": mv_id,
            "status": "completed",
            "videoUrl": mv.mv_url,
        }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{AI_MV_SERVER}/mv/jobs/{mv.job_id}",
            headers={"X-API-Key": MV_API_KEY}
        )

    if response.status_code != 200:
        raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다.")

    data = response.json()
    status = data.get("status")

    if status == "completed":
        video_url = AI_MV_SERVER + data.get("videoUrl", "")
        async with httpx.AsyncClient(timeout=120.0) as client:
            video_response = await client.get(video_url, headers={"X-API-Key": MV_API_KEY})

        import cloudinary.uploader
        import uuid
        video_id = str(uuid.uuid4())
        result = cloudinary.uploader.upload(
            video_response.content,
            resource_type="video",
            public_id=f"mvs/{video_id}",
            folder="gugakify"
        )
        final_url = result["secure_url"]
        mv.mv_url = final_url
        db.commit()

        return {
            "mv_id": mv_id,
            "status": "completed",
            "videoUrl": final_url,
            "bpm": data.get("bpm"),
            "mood": data.get("mood"),
            "jangdan": data.get("jangdan"),
        }

    return {
        "mv_id": mv_id,
        "status": status,
        "videoUrl": None,
        "error": data.get("error"),
    }