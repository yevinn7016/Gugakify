from fastapi import FastAPI
from database import engine, Base
from auth import router as auth_router
from routers.upload import router as upload_router
from routers.library import router as library_router

app = FastAPI()

# DB 테이블 자동 생성
Base.metadata.create_all(bind=engine)

# 라우터 등록
app.include_router(auth_router)
app.include_router(upload_router)
app.include_router(library_router)

@app.get("/")
def root():
    return {"message": "Gugakify API 서버 작동 중!"}
    