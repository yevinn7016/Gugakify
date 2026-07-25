from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from database import get_db
from models import MvGeneration
import httpx

router = APIRouter()

AI_MV_SERVER = "https://gugakify-mv-ai.onrender.com"
MV_API_KEY = "329bc0832be1e351c1e4f047c37a0ae951f5c816dee7bada61300b5b6d22f87c"

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

    async with httpx.AsyncClient(timeout=60.0) as client:
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
        visual_style=mood
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
async def get_mv_status(mv_id: int, job_id: str, db: Session = Depends(get_db)):
    # AI 서버에 상태 조회
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{AI_MV_SERVER}/mv/jobs/{job_id}",
            headers={"X-API-Key": MV_API_KEY}
        )

    if response.status_code != 200:
        raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다.")

    data = response.json()
    status = data.get("status")

    # 완료되면 Cloudinary에 영상 저장
    if status == "completed":
        video_url = AI_MV_SERVER + data.get("videoUrl", "")

        async with httpx.AsyncClient(timeout=120.0) as client:
            video_response = await client.get(
                video_url,
                headers={"X-API-Key": MV_API_KEY}
            )

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

        # DB 업데이트
        mv = db.query(MvGeneration).filter(MvGeneration.id == mv_id).first()
        if mv:
            mv.mv_url = final_url
            db.commit()

        return {
            "mv_id": mv_id,
            "status": "completed",
            "video_url": final_url,
            "bpm": data.get("bpm"),
            "mood": data.get("mood"),
            "jangdan": data.get("jangdan"),
            "duration": data.get("duration")
        }

    return {
        "mv_id": mv_id,
        "status": status,
        "video_url": None,
        "error": data.get("error")
    }