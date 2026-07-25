from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import MusicProject, GugakConversion
from dotenv import load_dotenv
import cloudinary.uploader
import httpx
import ffmpeg
import tempfile
import os
import uuid

load_dotenv()

router = APIRouter()

AI_MV_SERVER = os.getenv("AI_MV_SERVER")

@router.post("/projects/{project_id}/process-mv")
async def process_mv(
    project_id: int,
    conversion_id: int,
    style_type: str = "sumukhwa",
    db: Session = Depends(get_db)
):
    # 1. 프로젝트에서 영상 URL 가져오기
    project = db.query(MusicProject).filter(MusicProject.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="프로젝트를 찾을 수 없습니다.")

    # 2. 국악풍 음원 URL 가져오기
    conversion = db.query(GugakConversion).filter(GugakConversion.id == conversion_id).first()
    if not conversion or not conversion.converted_audio_url:
        raise HTTPException(status_code=404, detail="국악풍 음원을 찾을 수 없습니다.")

    video_url = project.original_file_url
    audio_url = conversion.converted_audio_url

    async with httpx.AsyncClient() as client:
        # 3. 영상 다운로드
        video_response = await client.get(video_url, timeout=60.0)
        # 4. 국악풍 음원 다운로드
        audio_response = await client.get(audio_url, timeout=60.0)

    # 5. 임시 파일로 저장
    tmp_video_path = tempfile.mktemp(suffix='.mp4')
    tmp_audio_path = tempfile.mktemp(suffix='.wav')
    tmp_output_path = tempfile.mktemp(suffix='.mp4')

    try:
        with open(tmp_video_path, 'wb') as f:
            f.write(video_response.content)
        with open(tmp_audio_path, 'wb') as f:
            f.write(audio_response.content)

        # 6. FFmpeg으로 영상에서 음원 제거 후 국악풍 음원 합치기
        video_stream = ffmpeg.input(tmp_video_path).video
        audio_stream = ffmpeg.input(tmp_audio_path).audio
        ffmpeg.output(
            video_stream,
            audio_stream,
            tmp_output_path,
            vcodec='copy',
            acodec='aac',
            shortest=None
        ).run(overwrite_output=True)

        # 7. Cloudinary에 합친 MV 업로드
        with open(tmp_output_path, 'rb') as f:
            merged_video = f.read()

        merged_id = str(uuid.uuid4())
        result = cloudinary.uploader.upload(
            merged_video,
            resource_type="video",
            public_id=f"merged/{merged_id}",
            folder="gugakify"
        )
        merged_video_url = result["secure_url"]

        # 8. AI 서버에 스타일 변환 요청
        async with httpx.AsyncClient(timeout=60.0) as client:
            ai_response = await client.post(
                f"{AI_MV_SERVER}/api/v1/mv-conversions",
                json={
                    "userId": str(project_id),
                    "projectId": str(project_id),
                    "inputVideoUrl": merged_video_url,
                    "originalFileName": "merged.mp4",
                    "styleType": style_type,
                    "preserveAudio": True,
                    "callbackUrl": None
                }
            )

        if ai_response.status_code != 202:
            raise HTTPException(status_code=500, detail="MV 스타일 변환 요청 실패")

        ai_data = ai_response.json()

        return {
            "project_id": project_id,
            "merged_video_url": merged_video_url,
            "job_id": ai_data["jobId"],
            "status": ai_data["status"],
            "message": "국악풍 음원 합치기 및 스타일 변환 요청 완료"
        }

    finally:
        for path in [tmp_video_path, tmp_audio_path, tmp_output_path]:
            if os.path.exists(path):
                os.unlink(path)