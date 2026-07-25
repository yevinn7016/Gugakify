import io
import uuid
import httpx
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError


from database import get_db
from models import MusicProject
from config import cloudinary
import cloudinary.uploader

router = APIRouter()

@router.post("/projects/upload-file")
async def upload_audio_file(
    file: UploadFile = File(...),
    title: str = "",
    user_id: int = 1,
    db: Session = Depends(get_db)
):
    if not file.filename.lower().endswith(('.mp3', '.wav', '.m4a')):
        raise HTTPException(status_code=400, detail="mp3, wav, m4a 파일만 업로드 가능합니다.")

    contents = await file.read()
    music_id = str(uuid.uuid4())

    result = cloudinary.uploader.upload(
        contents,
        resource_type="video",
        public_id=f"audio/{music_id}",
        folder="gugakify"
    )

    file_url = result["secure_url"]

    project = MusicProject(
        user_id=user_id,
        title=title or file.filename,
        input_type="file",
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

@router.post("/projects/upload-url")
async def upload_audio_from_url(
    audio_url: str = Query(..., description="다운로드할 오디오 파일(.wav, .mp3)의 직링크 URL"),
    title: str = "",
    user_id: int = 1,
    db: Session = Depends(get_db)
):
    # 1. URL 빈 값 검사
    if not audio_url or not audio_url.strip():
        raise HTTPException(status_code=400, detail="audio_url 매개변수가 비어있습니다.")

    # 2. 확실한 음원 스트리밍 사이트만 차단
    blocked_domains = ["youtu.be", "youtube.com", "genie.co.kr", "melon.com"]
    if any(domain in audio_url for domain in blocked_domains):
        raise HTTPException(
            status_code=400, 
            detail="유튜브나 음원 사이트 페이지 링크는 지원하지 않습니다."
        )

    try:
        # 3. URL에서 파일 다운로드 (User-Agent 추가로 차단 방지)
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        }
        async with httpx.AsyncClient(follow_redirects=True, timeout=30.0, headers=headers) as client:
            response = await client.get(audio_url)
            
            if response.status_code != 200:
                raise HTTPException(
                    status_code=400, 
                    detail=f"URL에서 파일을 다운로드할 수 없습니다. (응답 코드: {response.status_code})"
                )

            # 4. raw bytes -> BytesIO 변환 (WAV 처리)
            audio_bytes = response.content
            if len(audio_bytes) == 0:
                raise HTTPException(status_code=400, detail="다운로드한 파일이 빈 파일(0 bytes)입니다.")

            audio_file_obj = io.BytesIO(audio_bytes)

            # 5. Cloudinary 업로드
            music_id = str(uuid.uuid4())
            upload_result = cloudinary.uploader.upload(
                audio_file_obj,
                resource_type="video",
                public_id=f"audio/{music_id}",
                folder="gugakify"
            )

            file_url = upload_result.get("secure_url")

        # 6. DB에 저장
        project = MusicProject(
            user_id=user_id,
            title=title.strip() if title else "Untitled",
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

    except HTTPException:
        raise
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400, 
            detail=f"user_id={user_id} 에 해당하는 유저가 DB에 존재하지 않습니다."
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500, 
            detail=f"서버 내부 오류: {str(e)}"
        )