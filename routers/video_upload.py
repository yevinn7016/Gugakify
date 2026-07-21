from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import MusicProject
import cloudinary.uploader
import ffmpeg
import tempfile
import os
import uuid

router = APIRouter()

@router.post("/projects/upload-video")
async def upload_video(
    file: UploadFile = File(...),
    user_id: int = 1,
    db: Session = Depends(get_db)
):
    # 파일 형식 확인
    if not file.filename.lower().endswith(('.mp4', '.mov', '.m4v', '.webm')):
        raise HTTPException(status_code=400, detail="mp4, mov, m4v, webm 파일만 업로드 가능합니다.")

    contents = await file.read()
    video_id = str(uuid.uuid4())

    # 임시 파일로 저장
    with tempfile.NamedTemporaryFile(suffix='.mp4', delete=False) as tmp_video:
        tmp_video.write(contents)
        tmp_video_path = tmp_video.name

    try:
        # 음원 분리 (FFmpeg)
        tmp_audio_path = tmp_video_path.replace('.mp4', '_audio.wav')
        ffmpeg.input(tmp_video_path).audio.output(tmp_audio_path).run(overwrite_output=True)

        # Cloudinary에 영상 업로드
        video_result = cloudinary.uploader.upload(
            contents,
            resource_type="video",
            public_id=f"videos/{video_id}",
            folder="gugakify"
        )
        video_url = video_result["secure_url"]

        # DB에 저장
        project = MusicProject(
            user_id=user_id,
            title=file.filename,
            input_type="video",
            original_file_url=video_url,
            status="uploaded"
        )
        db.add(project)
        db.commit()
        db.refresh(project)

        return {
            "project_id": project.id,
            "video_id": video_id,
            "status": "uploaded",
            "video_url": video_url
        }
    finally:
        os.unlink(tmp_video_path)
        if os.path.exists(tmp_audio_path):
            os.unlink(tmp_audio_path)