from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import get_db
from models import User
import firebase_admin
from firebase_admin import credentials, auth

# Firebase 초기화
cred = credentials.Certificate("firebase_key.json")
firebase_admin.initialize_app(cred)

router = APIRouter()

class GoogleLoginRequest(BaseModel):
    idToken: str

@router.post("/auth/google")
def google_login(request: GoogleLoginRequest, db: Session = Depends(get_db)):
    try:
        decoded_token = auth.verify_id_token(request.idToken)
    except Exception:
        raise HTTPException(status_code=401, detail="유효하지 않은 토큰")

    email = decoded_token.get("email")
    nickname = decoded_token.get("name")

    # users 테이블에 없으면 저장, 있으면 그냥 반환
    user = db.query(User).filter(User.email == email).first()
    if not user:
        user = User(email=email, nickname=nickname, provider="google")
        db.add(user)
        db.commit()
        db.refresh(user)

    return {
        "user_id": user.id,
        "email": user.email,
        "nickname": user.nickname
    }