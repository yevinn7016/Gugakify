# 🎬 Gugakify 국악 장단 스타일 기반 MV 연출 시스템

**음악의 장단·박자·에너지 변화에 반응하여 전통 미학 기반 MV를 생성하는 시스템**

사용자가 업로드한 음원의 **템포, 비트, onset, 에너지, 주파수 변화**를 분석하고, 분석 결과에 따라 수묵화 배경과 먹 번짐, 붓 획, 안개, 꽃잎 등의 전통 시각 효과를 자동으로 연출하여 **최대 30초 길이의 국악 스타일 MV를 생성하는 시스템**입니다.

---

## 🎼 MV 생성 로직

```text
사용자 음원 업로드
        ↓
① 음원 전처리
FFmpeg / librosa
→ 음원 길이 및 포맷 정규화
        ↓
② 음악 특징 분석
librosa
→ BPM / Beat / Onset
→ Energy / Spectral Feature 분석
        ↓
③ 국악 장단 및 분위기 분석
→ 진양조 / 중모리 / 자진모리 / 휘모리 등
→ Calm / Emotional / Energetic 등
        ↓
④ MV 연출 파라미터 생성
→ 먹 번짐 크기
→ 붓 획 속도
→ 안개 이동량
→ 꽃잎 개수 및 속도
→ 화면 전환 시점
        ↓
⑤ 전통 스타일 배경 및 에셋 구성
→ 수묵화 배경
→ 먹 번짐
→ 붓 획
→ 안개
→ 꽃잎
        ↓
⑥ 프레임 단위 애니메이션 렌더링
Pillow / OpenCV
        ↓
⑦ 영상 생성
FFmpeg
→ 렌더링 프레임 + 원본 음원 결합
        ↓
최종 국악 스타일 MV 생성
```

---

## 🔧 주요 생성 과정

### 1. 음원 전처리

사용자가 업로드한 음원을 음악 분석 및 영상 생성에 적합한 형태로 변환합니다.

MP3, WAV 등의 입력 파일을 처리하고, 영상 생성에 사용할 구간을 최대 30초 범위로 제한합니다.

주요 처리 방식:

- MP3 / WAV 등의 음원 입력
- FFmpeg 기반 오디오 포맷 변환
- Sampling Rate 통일
- Mono 또는 Stereo 형식 정리
- 최대 30초 길이로 음원 구간 설정

```text
Input Audio
     ↓
FFmpeg
     ↓
Normalized WAV
     ↓
Music Analysis
```

---

### 2. 음악 특징 분석

전처리된 음원에서 **librosa**를 이용하여 영상 연출에 필요한 음악적 특징을 추출합니다.

전체 음악을 하나의 값으로 분석하는 것이 아니라 시간에 따른 변화를 분석하여 특정 시점마다 서로 다른 영상 효과를 적용할 수 있도록 구성합니다.

주요 분석 요소:

- BPM (Tempo)
- Beat
- Onset
- RMS Energy
- Spectral Centroid
- Spectral Bandwidth
- 주파수 변화
- 구간별 에너지 변화

```text
audio.wav
    ↓
librosa
    ↓
┌─────────────────────┐
│ BPM                 │
│ Beat                │
│ Onset               │
│ RMS Energy          │
│ Spectral Centroid   │
│ Frequency Change    │
└─────────────────────┘
```

---

### 3. 장단 및 분위기 분석

음원의 BPM과 에너지 등의 특징을 기반으로 곡의 분위기와 적합한 국악 장단 스타일을 결정합니다.

장단 자체를 새롭게 생성하는 것이 아니라, 분석된 음악의 리듬적 특징을 **전통 장단의 분위기와 연결하여 MV의 연출 속도와 강도를 결정하는 기준**으로 사용합니다.

예시 매핑:

| 음악 특징 | 추천 장단 | 영상 연출 |
| --- | --- | --- |
| 느리고 잔잔함 | 진양조 | 느린 안개, 부드러운 먹 번짐 |
| 중간 템포 | 중모리 | 안정적인 붓 획과 화면 이동 |
| 빠르고 경쾌함 | 자진모리 | 빠른 붓 획, 꽃잎 움직임 증가 |
| 매우 빠르고 강함 | 휘모리 | 강한 먹 번짐, 빠른 화면 전환 |

```text
BPM + Energy
     ↓
Rhythm Analysis
     ↓
Recommended Jangdan
     ↓
Visual Style Parameters
```

---

### 4. MV 연출 파라미터 생성

분석한 음악 특징을 실제 영상 효과가 사용할 수 있는 숫자 파라미터로 변환합니다.

예를 들어 음악의 타격 시점인 `onset`이 발생하면 먹 번짐 효과를 생성하고, RMS Energy가 높아질수록 번짐의 크기를 증가시킵니다.

```text
Music Feature
      ↓
Visual Parameter Mapping
      ↓
Animation
```

#### 음악 특징과 영상 효과 매핑

| 음악 분석 정보 | 영상 효과 |
| --- | --- |
| Onset | 먹 번짐 발생 |
| Onset Strength | 먹 번짐 크기 |
| Beat | 붓 획 / 화면 움직임 |
| BPM | 애니메이션 전체 속도 |
| RMS Energy | 효과 크기 및 움직임 강도 |
| Spectral Centroid | 화면 밝기 / 선명도 변화 |
| 구간 변화 | 배경 장면 전환 |

예시:

```text
강한 타격 발생
     ↓
Onset Strength 증가
     ↓
Ink Splash Scale 증가
     ↓
큰 먹 번짐 효과 생성
```

---

## 🖌 주요 MV 연출 효과

### 1. 먹 번짐 효과 (Ink Splash)

강한 타격이나 onset이 발생했을 때 화면에 먹이 번지는 효과를 생성합니다.

사용 에셋 예시:

```text
assets/
└── ink/
    ├── ink_splash_01.png
    ├── ink_splash_02.png
    ├── ink_splash_03.png
    └── ink_ring_01.png
```

권장 에셋 조건:

- 투명 배경 PNG
- 검은색 또는 짙은 회색 먹 표현
- 다양한 형태의 먹 번짐 이미지
- 고해상도 이미지 권장

주요 제어 파라미터:

```text
scale
opacity
position
rotation
duration
```

예시:

```text
강한 Onset
   ↓
Ink Splash 생성
   ↓
Scale 증가
   ↓
Opacity 감소
   ↓
화면에서 자연스럽게 사라짐
```

---

### 2. 붓 획 효과 (Brush Stroke)

음악의 비트와 곡의 구간 변화에 맞춰 붓 획이 화면을 지나가거나 다음 장면을 드러내는 효과입니다.

사용 에셋 예시:

```text
assets/
└── brush/
    ├── brush_horizontal.png
    ├── brush_diagonal.png
    ├── brush_curve.png
    └── brush_circle.png
```

권장 조건:

- 투명 배경 PNG
- 흰색 또는 검은색 붓 획
- 긴 가로형 이미지의 경우 약 `1920 × 300` 이상 권장

활용 방식:

- Beat 발생 → 짧은 붓 획 애니메이션
- 음악 구간 변경 → 화면 전환 Mask
- BPM 증가 → 붓 획 이동 속도 증가

```text
Current Scene
      ↓
Brush Stroke Mask
      ↓
Next Scene Reveal
```

---

### 3. 안개 효과 (Fog)

잔잔하거나 서정적인 구간에서는 화면 위에 수묵화 형태의 안개 레이어를 움직여 공간감을 표현합니다.

사용 에셋 예시:

```text
assets/
└── fog/
    ├── fog_wide_01.png
    ├── fog_wide_02.png
    └── cloud_ink_01.png
```

권장 조건:

- 투명 배경 PNG
- 가로로 긴 형태
- 약 `1920 × 600` 이상의 해상도
- 경계가 부드러운 흰색 또는 회색 안개

주요 제어 파라미터:

```text
x_position
y_position
speed
opacity
scale
```

```text
Low Energy
    ↓
Slow Fog Movement

High Energy
    ↓
Fast Fog Movement
```

---

### 4. 꽃잎 효과 (Petal)

밝거나 서정적인 음악 구간에서는 화면에 꽃잎이 흩날리는 애니메이션을 추가합니다.

주요 제어 요소:

```text
petal_count
fall_speed
rotation
direction
opacity
```

음악 에너지가 높아질수록 꽃잎의 개수와 이동 속도를 증가시키는 방식으로 연출할 수 있습니다.

```text
Energy ↑
   ↓
Petal Count ↑
   ↓
Movement Speed ↑
```

---

### 5. 화면 전환 (Scene Transition)

음악의 구조가 변경되는 시점에 새로운 수묵화 배경으로 장면을 전환합니다.

화면 전환에는 일반적인 Fade뿐 아니라 붓 획 이미지를 Mask로 사용하는 전통적인 스타일의 장면 전환을 적용합니다.

```text
Scene A
   ↓
Brush Mask Animation
   ↓
Scene B
```

주요 전환 방식:

- Fade
- Cross Fade
- Ink Spread
- Brush Reveal

---

## 🖼 수묵화 배경 구성

MV의 기본 배경은 한국 전통 수묵화 분위기의 이미지를 사용합니다.

배경 예시:

```text
assets/
└── backgrounds/
    ├── mountain_01.png
    ├── mountain_02.png
    ├── moon_01.png
    ├── bamboo_01.png
    └── flower_01.png
```

배경 이미지에는 다음과 같은 전통적인 시각 요소를 활용할 수 있습니다.

- 산
- 달
- 구름
- 대나무
- 소나무
- 매화
- 전통 건축물
- 한지 질감

필요한 경우 **Stable Diffusion / SDXL / FLUX 등의 이미지 생성 모델을 활용하여 전통 수묵화 스타일의 배경 이미지를 생성**할 수 있습니다.

---

## 🎨 음악 반응형 연출 예시

### 예시 01 - 강한 장구 타격

```text
장구 타격
    ↓
Strong Onset
    ↓
Ink Splash Trigger
    ↓
먹 번짐 크기 증가
```

### 예시 02 - 잔잔한 대금 구간

```text
Energy 감소
    ↓
Scene Motion 감소
    ↓
안개 이동
    ↓
산수화 배경 강조
```

### 예시 03 - 빠른 장단

```text
BPM 증가
    ↓
자진모리 / 휘모리 스타일
    ↓
붓 획 속도 증가
    ↓
꽃잎 움직임 증가
    ↓
화면 전환 간격 감소
```

---

## 🎞 프레임 렌더링

음악 분석 결과와 연출 파라미터를 이용하여 영상의 각 프레임을 생성합니다.

**Pillow와 OpenCV**를 이용하여 배경 이미지 위에 여러 개의 투명 PNG 에셋을 합성합니다.

```text
Background
    +
Ink Layer
    +
Fog Layer
    +
Brush Layer
    +
Petal Layer
    ↓
Final Frame
```

각 프레임에서는 현재 음악 시간에 해당하는 분석값을 불러와 애니메이션의 위치, 크기, 투명도 등을 계산합니다.

```python
current_time = frame_index / fps

energy = get_energy(current_time)
onset = get_onset(current_time)

ink_scale = calculate_ink_scale(onset, energy)
fog_speed = calculate_fog_speed(energy)
```

---

## 🎥 최종 영상 생성

생성된 프레임들을 하나의 영상으로 조합한 뒤 원본 또는 국악 편곡 음원을 결합합니다.

```text
Rendered Frames
       ↓
FFmpeg
       ↓
Temporary MP4
       +
Audio
       ↓
FFmpeg
       ↓
Final Gugak MV
```

최종 출력 형식:

```text
MP4
1920 × 1080
30 FPS
최대 30초
```

---

## 📁 프로젝트 구조

```text
app/
├── main.py                       # FastAPI 엔트리포인트
│
├── audio/
│   ├── preprocess.py             # 음원 전처리
│   ├── analyzer.py               # librosa 기반 음악 분석
│   ├── rhythm.py                 # BPM / Beat / 장단 분석
│   └── features.py               # Energy / Spectral Feature 추출
│
├── visual/
│   ├── mapper.py                 # 음악 → 영상 파라미터 매핑
│   │
│   ├── effects/
│   │   ├── ink.py                # 먹 번짐
│   │   ├── brush.py              # 붓 획
│   │   ├── fog.py                # 안개
│   │   ├── petal.py              # 꽃잎
│   │   └── transition.py         # 화면 전환
│   │
│   └── background.py             # 수묵화 배경 처리
│
├── video/
│   ├── renderer.py               # 프레임 렌더링
│   ├── compositor.py             # 레이어 합성
│   └── encoder.py                # FFmpeg 영상 생성
│
└── services/
    └── file_manager.py           # 입력 / 출력 파일 관리

assets/
├── backgrounds/
├── ink/
├── brush/
├── fog/
└── petals/

outputs/
├── analysis/
├── frames/
└── videos/
```

---

## 🧪 테스트 결과

현재 시스템은 다음과 같은 방식으로 테스트할 수 있습니다.

- 사용자 음원의 BPM 분석 가능
- Beat 및 Onset 시점 추출 가능
- 구간별 RMS Energy 분석 가능
- 음악 특징을 영상 효과 파라미터로 변환 가능
- 강한 Onset에 맞춰 먹 번짐 효과 생성 가능
- Beat에 맞춰 붓 획 애니메이션 적용 가능
- 음악 에너지에 따라 안개 이동 속도 조절 가능
- 꽃잎 등의 Particle 효과 적용 가능
- 음악 구간 변화에 따라 배경 장면 전환 가능
- Pillow / OpenCV 기반 프레임 합성 가능
- FFmpeg를 이용한 MP4 영상 생성 가능
- 생성 영상과 음원을 결합하여 최종 MV 출력 가능

---

## 🛠 기술 스택

| 구분 | 기술 |
| --- | --- |
| Language | Python |
| API Server | FastAPI, Uvicorn |
| Music Analysis | librosa |
| Numerical Processing | NumPy |
| Image Processing | Pillow, OpenCV |
| Video Processing | FFmpeg |
| Background Generation | Stable Diffusion / SDXL / FLUX (Optional) |
| Output | MP4 |

---

## 🚀 시작하기

### 1. 의존성 설치

```bash
pip install -r requirements.txt
```

### 2. 서버 실행

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. MV 생성

사용자가 음원을 업로드하면 다음 과정이 순차적으로 수행됩니다.

```text
Audio Upload
      ↓
Music Analysis
      ↓
Rhythm / Energy Analysis
      ↓
Visual Parameter Mapping
      ↓
Ink / Brush / Fog / Petal Animation
      ↓
Frame Rendering
      ↓
FFmpeg Encoding
      ↓
Final MP4
```

생성된 영상은 출력 디렉터리에 저장되며, 백엔드에서 결과 파일을 전달받아 애플리케이션에서 재생할 수 있도록 구성합니다.

---

## 💡 핵심 기술

> **Music Information Retrieval + Rule-based Visual Mapping + Procedural Animation + Video Rendering**

Gugakify의 국악 장단 스타일 기반 MV 연출 AI는 전체 영상을 생성형 AI로 직접 생성하는 방식이 아니라, **음악에서 리듬과 에너지 정보를 분석하고 그 결과를 영상 효과의 파라미터와 연결하여 프레임을 직접 생성하는 방식**을 사용합니다.

이를 통해 같은 효과를 반복적으로 재생하는 것이 아니라 음악의 흐름에 따라:

- 강한 타격에서는 먹 번짐이 커지고
- 빠른 장단에서는 붓 획과 꽃잎의 움직임이 빨라지고
- 잔잔한 구간에서는 안개와 산수화 배경이 강조되며
- 음악의 구간 변화에서는 새로운 수묵화 장면으로 전환되는

**음악 반응형 전통 미학 MV**를 자동으로 생성하는 것을 목표로 합니다.
