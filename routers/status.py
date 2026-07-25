from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import MusicProject

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

    return {
        "project_id": project.id,
        "status": project.status,
        "step": step,
        "total_steps": 4
    }