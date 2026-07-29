from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import MusicProject, GugakConversion

router = APIRouter()

@router.get("/projects/{project_id}/status")
def get_project_status(project_id: int, db: Session = Depends(get_db)):
    project = db.query(MusicProject).filter(MusicProject.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="프로젝트를 찾을 수 없습니다.")

    status_to_step = {
        "uploaded": 0,
        "analyzing": 1,
        "converting": 2,
        "generating_mv": 3,
        "completed": 4,
    }
    step = status_to_step.get(project.status, 0)

    audio_url = None
    if project.status == "completed":
        conversion = (
            db.query(GugakConversion)
            .filter(GugakConversion.project_id == project.id)
            .order_by(GugakConversion.id.desc())
            .first()
        )
        if conversion:
            audio_url = conversion.converted_audio_url

    return {
        "project_id": project.id,
        "status": project.status,
        "step": step,
        "total_steps": 4,
        "audio_url": audio_url
    }