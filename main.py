from fastapi import FastAPI
from database import engine, Base
from auth import router as auth_router
from routers.upload import router as upload_router
from routers.library import router as library_router
from routers.arrangements import router as arrangements_router
from routers.mv_conversion import router as mv_router
from routers.video_upload import router as video_router
from routers.mv_process import router as mv_process_router
from routers.status import router as status_router

app = FastAPI()

# DB 테이블 자동 생성
Base.metadata.create_all(bind=engine)

# 라우터 등록
app.include_router(auth_router)
app.include_router(upload_router)
app.include_router(library_router)
app.include_router(arrangements_router)
app.include_router(mv_router)
app.include_router(video_router)
app.include_router(mv_process_router)
app.include_router(status_router)

@app.get("/")
def root():
    return {"message": "Gugakify API 서버 작동 중!"}