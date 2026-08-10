# Gugakify
AI 기반 K-POP/POP 국악 편곡 및 전통 MV 재창작 앱 서비스

FastAPI 기반 백엔드 서버로, 사용자 인증, 음원/영상 업로드, AI 서버 연동, 보관함 관리 등의 기능을 담당합니다.

---

## 🛠 기술 스택

| 분류 | 기술 |
|---|---|
| 언어 | Python |
| 프레임워크 | FastAPI |
| 데이터베이스 | MySQL |
| ORM | SQLAlchemy |
| DB 드라이버 | PyMySQL |
| 파일 저장 | Cloudinary |
| 인증 | Firebase Authentication (Google OAuth) |
| 영상 처리 | FFmpeg, ffmpeg-python |
| HTTP 통신 | httpx |
| 서버 실행 | uvicorn |
| 로컬 터널링 | ngrok |
| 협업 도구 | GitHub, Notion |

---

## 📂 프로젝트 구조

```
gugakify-backend/
├── main.py                  # FastAPI 앱 진입점
├── database.py              # DB 연결 설정
├── models.py                # SQLAlchemy 테이블 모델
├── auth.py                  # 구글 로그인 API
├── config.py                # Cloudinary 설정
├── firebase_key.json        # Firebase 서비스 계정 키 (비공개)
├── routers/
│   ├── upload.py            # 음원 업로드 API
│   ├── arrangements.py      # 음원 변환 결과 수신 API
│   ├── mv_conversion.py     # MV 변환 요청/조회 API
│   ├── mv_process.py        # FFmpeg 음원 분리 및 합성 API
│   ├── library.py           # 보관함 API
│   ├── status.py            # 프로젝트 상태 조회 API
│   └── video_upload.py      # 영상 업로드 API
└── venv/                    # 가상환경
```

---

## 🗄️ DB 설계

총 7개 테이블로 구성됩니다.

| 테이블 | 설명 |
|---|---|
| `users` | 구글 로그인 사용자 정보 |
| `music_projects` | 음원 변환 프로젝트 |
| `music_analysis` | AI 음원 분석 결과 |
| `gugak_conversions` | 국악 변환 결과 |
| `mv_generations` | MV 생성 결과 |
| `realtime_effects` | 실시간 연출 효과 파라미터 |
| `library_items` | 보관함 |

---

## 📡 API 목록

### 🔐 인증
| Method | Endpoint | 설명 |
|---|---|---|
| POST | `/auth/google` | 구글 OAuth 로그인 |

### 🎵 음원 업로드
| Method | Endpoint | 설명 |
|---|---|---|
| POST | `/projects/upload-url` | URL 입력 → Cloudinary 저장 |
| POST | `/projects/upload-file` | 파일 업로드 → Cloudinary 저장 |
| GET | `/projects/{id}/status` | 변환 진행 상태 조회 |

### 🎶 음원 변환 AI 연동
| Method | Endpoint | 설명 |
|---|---|---|
| POST | `/api/arrangements/result` | AI 서버에서 변환된 국악 음원 수신 |

### 🎬 MV 변환 AI 연동
| Method | Endpoint | 설명 |
|---|---|---|
| POST | `/api/mvs` | MV 변환 AI 서버에 음원 전달 |
| GET | `/api/mvs/{mv_id}` | MV 변환 상태 조회 |
| POST | `/projects/{id}/process-mv` | FFmpeg 음원 분리 → 합성 → 스타일 변환 요청 |

### 🗂️ 보관함
| Method | Endpoint | 설명 |
|---|---|---|
| POST | `/library/{project_id}` | 보관함 저장 |
| GET | `/library` | 보관함 조회 |
| PATCH | `/library/{project_id}/favorite` | 즐겨찾기 토글 |
| DELETE | `/library/{project_id}` | 보관함 삭제 |

---

## 🤖 AI 서버 연동

| AI 기능 | 서버 주소 | 연동 방식 |
|---|---|---|
| 국악 음원 변환 | `gugakify.onrender.com` | AI가 변환 완료 후 백엔드로 WAV 전달 |
| MV 스타일 변환 | `gugakify-mv-ai.onrender.com` | 백엔드가 요청 → jobId로 상태 폴링 |

---

## ⚙️ 실행 방법

### 1. 가상환경 설정
```bash
python -m venv venv
venv\Scripts\activate  # Windows
```

### 2. 라이브러리 설치
```bash
pip install fastapi uvicorn sqlalchemy pymysql firebase-admin cloudinary httpx ffmpeg-python python-multipart
```

### 3. 환경 설정
- `firebase_key.json` — Firebase 서비스 계정 키 파일 추가
- `config.py` — Cloudinary API 키 설정
- `database.py` — MySQL 연결 정보 설정

### 4. 서버 실행
```bash
uvicorn main:app --reload
```

### 5. API 문서 확인
```
http://127.0.0.1:8000/docs
```
