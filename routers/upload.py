from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import MusicProject
import cloudinary.uploader
import httpx
import uuid
from config import cloudinary

router = APIRouter()

@router.post("/projects/upload-url")
async def upload_audio_from_url(
    audio_url: str,
    title: str = "",
    user_id: int = 1,
    db: Session = Depends(get_db)
):
    try:
        # URL에서 음원 다운로드
        async with httpx.AsyncClient() as client:
            response = await client.get(audio_url)
            if response.status_code != 200:
                raise HTTPException(status_code=400, detail="URL에서 파일을 가져올 수 없습니다.")
        
        # Cloudinary에 업로드
        music_id = str(uuid.uuid4())
        result = cloudinary.uploader.upload(
            response.content,
            resource_type="video",
            public_id=f"audio/{music_id}",
            folder="gugakify"
        )

        file_url = result["secure_url"]

        # DB에 저장
        project = MusicProject(
            user_id=user_id,
            title=title or "Untitled",
            input_type="url",
            original_file_url=file_url,
            status="uploaded"
        )
        db.add(project)
        db.commit()
        db.refresh(project)

        return {
            "project_id": project.id,
            "music_id": music_id,
            "status": "uploaded",
            "original_file_url": file_url
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))