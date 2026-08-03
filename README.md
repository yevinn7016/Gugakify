<div align="center">
  
# Guackify MV 스타일 변환 AI

**AI로 익숙한 음악을 국악 스타일 음원과 전통 미학 MV로 재해석하는 서비스**

K-POP·POP 음원을 국악기 중심의 음악으로 변환하고,
수묵화와 민화 스타일의 전통 MV를 생성하는 Flutter 애플리케이션

</div>

---

## 영상 변환 로직
```bash
1. 입력 영상에서 프레임 추출
2. 각 프레임을 RGB/BGR로 로드
3. 프레임에 대한 스타일 변환 처리 수행
4. 변환된 프레임들을 다시 영상으로 조합
5. 원본 오디오와 합쳐 최종 결과 영상 생성
```

---

## 지원 스타일

### 1. 수묵화 스타일 (Sumukhwa)
수묵화 스타일은 잉크의 흐름과 한지 질감을 강조하는 방식으로 구현되었습니다. 프레임 단위로 처리하면서도, 잉크 선과 번짐, 어두운 윤곽선, 종이 질감을 함께 결합해 전통 수묵화의 분위기를 재현합니다.

주요 변환 방식:
- 그레이스케일 변환으로 수묵의 흑백 기반 구조를 형성
- CLAHE와 bilateral filtering으로 대비와 선명도를 조정
- adaptive threshold와 Canny edge detection으로 잉크 선을 생성
- Gaussian blur와 blend를 통해 먹의 흐름과 번짐 효과를 구현
- paper texture와 결합해 한지 같은 배경감을 부여

|  |  |
|:---:|:---:|
| <img src="https://tse1.mm.bing.net/th/id/OIP._-wY5OR5DiPL8yKdKiWEWAHaEH?r=0&rs=1&pid=ImgDetMain&o=7&rm=3" width="500"> | <img src="https://tse4.mm.bing.net/th/id/OIP.6twyXVzBAMtwD3PpD5ku3gHaEJ?r=0&rs=1&pid=ImgDetMain&o=7&rm=3" width="500"> |

### 2. 민화 스타일 (Minhwa)
민화 스타일은 전통 민화에서 느껴지는 색채감, 단순화된 형태, 붓질 느낌을 살리도록 설계되었습니다. 색을 단순화하고 윤곽선을 강조한 뒤, 오래된 종이와 유사한 질감을 더해 전통적인 분위기를 표현합니다.

주요 변환 방식:
- 색상 영역을 단순화하여 민화풍의 팔레트 기반 표현을 구현
- adaptive threshold로 형태 윤곽선을 강조하고, Canny edge를 사용해 세밀한 윤곽 추가
- 색상 부스트와 채도 조정을 통해 전통적인 색감 강화
- hand-drawn variation을 넣어 손그림 같은 선의 불규칙성과 pigment bleed 효과를 적용해 색이 자연스럽게 확산되는 느낌 구현
- aged paper texture를 합성해 오래된 그림 같은 배경을 생성

|  |  |
|:---:|:---:|
| <img src="https://th.bing.com/th/id/R.90a9fca0fd78a4933a2741fc57f3fa2e?rik=xiNzg8PE75vc1g&riu=http%3a%2f%2ffolkpainting.net%2ffiles%2fattach%2fimages%2f711%2f740%2f046%2f7f0a536c1ce2199849fd9a1820e08d21.jpg&ehk=BWS9CoGxAlDu586Zj0KRFn5Lccpnn9giXMRUxi2ouVw%3d&risl=&pid=ImgRaw&r=0" width="350"> | <img src="https://i.pinimg.com/originals/da/9d/db/da9ddb2dca2dc079c2d40a1d7ad5a723.jpg" width="590"> |

---

## 프로젝트 구조

```text
app/
  main.py                 FastAPI 엔트리포인트
  schemas.py              요청/응답 모델
  store.py                작업 상태 저장
  models/
    opencv_ink.py         수묵화 스타일 변환 로직
    opencv_minhwa.py      민화 스타일 변환 로직
    registry.py           스타일 어댑터 선택
  services/
    download.py           영상 다운로드
  video/
    pipeline.py           영상 변환 파이프라인
    io.py                 프레임/오디오 처리
```

---

## 테스트 결과

현재 시스템은 다음과 같은 방식으로 테스트되었습니다.

- 입력 MV를 프레임 단위로 분해한 뒤 스타일 변환 처리 가능
- 수묵화 스타일과 민화 스타일이 각각 독립적으로 적용 가능
- 변환된 프레임을 다시 영상으로 재조합해 결과물을 생성 가능
- 원본 오디오를 유지한 채 최종 결과 영상 생성 가능

### 예시 01 - 수묵화 ver

| 원본 영상 | 변환 영상 |
|:---:|:---:|
| [![원본 영상](https://img.youtube.com/vi/zMGDeFEI0wc/hqdefault.jpg)](https://youtu.be/zMGDeFEI0wc) | [![변환 영상](https://img.youtube.com/vi/yCKenFdf6Us/hqdefault.jpg)](https://youtu.be/yCKenFdf6Us) |

### 예시 02 - 민화 ver

| 원본 영상 | 변환 영상 |
|:---:|:---:|
| [![원본 영상](https://img.youtube.com/vi/TPVUm7HLNkU/hqdefault.jpg)](https://youtu.be/TPVUm7HLNkU) | [![변환 영상](https://img.youtube.com/vi/5EvbZOgHwvk/hqdefault.jpg)](https://youtu.be/5EvbZOgHwvk) |

---

## 기술 스택

- Python
- FastAPI
- OpenCV
- NumPy
- FFmpeg
- Uvicorn

---

## 시작하기

### 1) 의존성 설치

```bash
pip install -r requirements.txt
```

### 2) 서버 실행

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3) 결과 확인

- 업로드된 영상에 대한 변환 요청을 보내 결과 영상을 확인합니다.
- 변환된 결과는 작업 디렉터리와 출력 디렉터리에 저장됩니다.
