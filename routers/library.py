from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import LibraryItem

router = APIRouter()

# 보관함 저장
@router.post("/library/{project_id}")
def save_to_library(project_id: int, user_id: int = 1, db: Session = Depends(get_db)):
    # 이미 저장된 항목인지 확인
    existing = db.query(LibraryItem).filter(
        LibraryItem.project_id == project_id,
        LibraryItem.user_id == user_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="이미 보관함에 저장된 항목입니다.")

    item = LibraryItem(user_id=user_id, project_id=project_id, is_favorite=False)
    db.add(item)
    db.commit()
    db.refresh(item)
    return {"message": "보관함에 저장됐습니다.", "library_id": item.id}

# 보관함 조회
@router.get("/library")
def get_library(user_id: int = 1, db: Session = Depends(get_db)):
    items = db.query(LibraryItem).filter(LibraryItem.user_id == user_id).all()
    return items

# 즐겨찾기 토글
@router.patch("/library/{project_id}/favorite")
def toggle_favorite(project_id: int, user_id: int = 1, db: Session = Depends(get_db)):
    item = db.query(LibraryItem).filter(
        LibraryItem.project_id == project_id,
        LibraryItem.user_id == user_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="보관함에 없는 항목입니다.")

    item.is_favorite = not item.is_favorite
    db.commit()
    return {"is_favorite": item.is_favorite}

# 보관함 삭제
@router.delete("/library/{project_id}")
def delete_from_library(project_id: int, user_id: int = 1, db: Session = Depends(get_db)):
    item = db.query(LibraryItem).filter(
        LibraryItem.project_id == project_id,
        LibraryItem.user_id == user_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="보관함에 없는 항목입니다.")

    db.delete(item)
    db.commit()
    return {"message": "삭제됐습니다."}