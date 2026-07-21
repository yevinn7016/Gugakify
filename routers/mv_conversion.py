from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import MvGeneration
import httpx

router = APIRouter()

AI_MV_SERVER = "https://guackify-ai-mv.onrender.com"

@router.post("/api/mv-conversions")
async def request_mv_conversion(
    project_id: int,
    video_url: str,
    style_type: str = "sumukhwa",
    preserve_audio: bool = True,
    db: Session = Depends(get_db)
):
    # AI 서버에 MV 변환 요청
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{AI_MV_SERVER}/api/v1/mv-conversions",
            json={
                "userId": str(project_id),
                "projectId": str(project_id),
                "inputVideoUrl": video_url,
                "originalFileName": "input.mp4",
                "styleType": style_type,
                "preserveAudio": preserve_audio,
                "callbackUrl": None
            },
            timeout=30.0
        )

    if response.status_code != 202:
        raise HTTPException(status_code=500, detail="MV 변환 요청 실패")

    data = response.json()
    job_id = data["jobId"]

    # DB에 저장
    mv = MvGeneration(
        project_id=project_id,
        conversion_id=1,  # 나중에 실제 conversion_id로 연결
        mv_url=None,
        visual_style=style_type
    )
    db.add(mv)
    db.commit()
    db.refresh(mv)

    return {
        "job_id": job_id,
        "status": data["status"],
        "mv_id": mv.id
    }

@router.get("/api/mv-conversions/{job_id}/status")
async def get_mv_status(job_id: str):
    # AI 서버에 상태 조회
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{AI_MV_SERVER}/api/v1/mv-conversions/{job_id}",
            timeout=30.0
        )

    if response.status_code != 200:
        raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다.")

    return response.json()

@router.get("/api/mv-conversions/{job_id}/result")
async def get_mv_result(job_id: str, db: Session = Depends(get_db)):
    # AI 서버에 결과 조회
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{AI_MV_SERVER}/api/v1/mv-conversions/{job_id}/result",
            timeout=30.0
        )

    if response.status_code == 409:
        raise HTTPException(status_code=409, detail="아직 변환이 완료되지 않았습니다.")

    if response.status_code != 200:
        raise HTTPException(status_code=500, detail="결과 조회 실패")

    data = response.json()

    # outputVideoUrl 앞에 AI 서버 주소 붙이기
    output_url = data.get("outputVideoUrl", "")
    if output_url.startswith("/"):
        output_url = AI_MV_SERVER + output_url

    # DB에 결과 URL 저장
    mv = db.query(MvGeneration).filter(
        MvGeneration.mv_url == None
    ).first()
    if mv:
        mv.mv_url = output_url
        db.commit()

    return {
        "job_id": job_id,
        "status": data["status"],
        "output_video_url": output_url,
        "thumbnail_url": AI_MV_SERVER + data.get("thumbnailUrl", ""),
        "duration": data.get("duration"),
        "output_file_size": data.get("outputFileSize")
    }