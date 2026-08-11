# 🎵 Gugakify

> **AI로 익숙한 음악을 국악 스타일 음원과 전통 미학의 MV로 재해석하는 서비스**

Gugakify는 K-POP·POP 등 익숙한 음악을  
**국악의 악기·장단·선율·음색**과 **한국 전통 시각 미학**을 활용하여 새롭게 재해석하는 AI 기반 서비스입니다.

사용자가 음원 또는 영상을 업로드하면 AI가 음악과 영상의 특징을 분석하여  
**국악 스타일 음원**, **전통 미학 스타일 MV**, **국악 장단 기반 반응형 MV**를 생성합니다.

---

# 📌 주요 기능

Gugakify는 크게 세 가지 AI 기능으로 구성됩니다.

### 1. 🎼 국악 스타일 음원 변환 AI

사용자가 업로드한 음원을 분석하고 자동 채보하여  
원곡의 멜로디를 유지하면서 **가야금·해금·대금·피리·거문고 등 국악기 중심의 음원**으로 재구성합니다.

### 2. 🎨 국악 스타일 MV 변환 AI

기존 뮤직비디오의 프레임을 분석하고 스타일 변환을 적용하여  
**수묵화·민화 등 한국 전통 회화 스타일의 MV**로 재해석합니다.

### 3. 🥁 국악 장단 스타일 기반 MV 연출 AI

음원의 박자·비트·에너지·주파수 변화를 분석하고  
먹 번짐, 붓 획, 안개 등 전통 시각 효과를 음악에 맞춰 자동으로 연출하여  
**음악에 반응하는 국악 스타일 MV**를 생성합니다.

---

# 🎼 1. 국악 스타일 음원 변환 AI

## 📌 개요

사용자가 음원을 업로드하고 원하는 국악기를 선택하면  
AI가 음원을 **보컬과 반주로 분리하고 자동 채보**합니다.

생성된 MIDI는 선택한 국악기의 실제 연주 가능 음역에 맞게 보정한 뒤  
국악 가상악기를 통해 WAV 음원으로 렌더링합니다.

이를 통해 원곡의 주요 멜로디를 유지하면서  
국악기의 음색을 활용한 새로운 음원으로 재구성합니다.

---

## 🔄 음원 변환 로직

```text
사용자 음원 업로드
        ↓
① 음원 분리
Demucs
→ vocals.wav / other.wav
        ↓
② 자동 채보
BasicPitch
→ 각 파트의 음정·리듬 분석
→ MIDI 악보 생성
        ↓
③ 국악기 맞춤 MIDI 보정
→ 선택한 국악기의 연주 가능 음역 분석
→ 옥타브 이동 및 음역 보정
        ↓
④ 국악 가상악기 적용
Kontakt Player / VST
→ 보정된 MIDI를 국악 가상악기로 연주
→ 파트별 WAV 생성
        ↓
⑤ 음원 믹싱
→ 생성된 국악기 WAV 결합
        ↓
최종 국악 편곡 음원 생성
```

---

## 🤖 핵심 기술

### 1. 음원 분리 — Demucs

**Demucs**를 활용하여 사용자가 업로드한 음원을 파트별로 분리합니다.

```text
Original Audio
      ↓
   Demucs
      ↓
┌────────────┬────────────┐
│ vocals.wav │ other.wav  │
└────────────┴────────────┘
```

보컬과 반주를 분리함으로써 각각의 파트에 서로 다른 국악기를 적용할 수 있습니다.

---

### 2. 자동 채보 — BasicPitch

**BasicPitch**를 이용하여 분리된 음원의 음정과 리듬을 분석하고 MIDI 악보를 생성합니다.

```text
vocals.wav
     ↓
 BasicPitch
     ↓
Pitch / Rhythm Analysis
     ↓
 vocal.mid
```

자동 채보를 통해 오디오 신호를 국악 가상악기로 연주할 수 있는 MIDI 데이터로 변환합니다.

---

### 3. 국악기 맞춤 MIDI 보정

자동 채보된 MIDI가 선택한 국악기의 실제 연주 가능 음역을 벗어날 경우  
악기별 음역을 기준으로 MIDI 음높이를 자동 보정합니다.

| 국악기 | 적용 음역 |
|---|---|
| 거문고 | E3 ~ F6 |
| 해금 | A4 ~ E7 |
| 대금 | B4 ~ G7 |
| 가야금 | D3 ~ G5 |
| 피리 | B4 ~ F6 |

필요한 경우 한 옥타브 단위로 음정을 이동하여  
원래의 멜로디 구조를 최대한 유지하면서 선택한 악기로 연주할 수 있도록 변환합니다.

```text
Original MIDI
      ↓
Instrument Range Check
      ↓
Out of Range?
   ↓       ↓
  YES      NO
   ↓       ↓
Octave     유지
Shift
   ↓
Corrected MIDI
```

---

### 4. 국악 가상악기 렌더링

보정된 MIDI를 실제 오디오로 변환하기 위해  
**REAPER와 Kontakt Player 기반 국악 가상악기 환경**을 활용합니다.

```text
Corrected MIDI
       ↓
     REAPER
       ↓
Kontakt Player / VST
       ↓
Gugak Virtual Instrument
       ↓
      WAV
```

MIDI에 포함된 음정과 연주 정보를 국악 가상악기에 전달하여  
해금·가야금·대금·피리·거문고 등의 음색을 가진 WAV 음원을 생성합니다.

---

### 5. 최종 음원 믹싱

각 파트에서 생성된 국악기 WAV를 하나의 음원으로 결합합니다.

```text
Vocal Instrument WAV
          +
Accompaniment Instrument WAV
          ↓
       Mixing
          ↓
Final Gugak Audio
```

---

# 🎨 2. 국악 스타일 MV 변환 AI

## 📌 개요

사용자가 업로드한 기존 영상을 프레임 단위로 분석하고  
각 프레임에 한국 전통 회화 스타일을 적용하여 새로운 MV를 생성합니다.

주요 스타일은 **수묵화(Sumukhwa)**와 **민화(Minhwa)**입니다.

---

## 🔄 영상 변환 로직

```text
사용자 영상 업로드
        ↓
① 영상 프레임 추출
        ↓
② 프레임 RGB/BGR 로드
        ↓
③ 프레임별 스타일 변환
        ↓
④ 변환 프레임 영상 재조합
        ↓
⑤ 원본 오디오 결합
        ↓
최종 국악 스타일 MV 생성
```

---

## 🖌️ 지원 스타일

### 1. 수묵화 스타일 — Sumukhwa

먹의 번짐과 농담을 중심으로 한 한국 전통 수묵화의 특징을 영상에 적용합니다.

주요 처리 요소:

- Grayscale 기반 색상 단순화
- 먹의 농담 표현
- Edge 강조
- Blur를 활용한 먹 번짐 표현
- 종이 질감 적용

이를 통해 기존 영상의 형태와 움직임을 유지하면서  
먹으로 그린 듯한 전통적인 영상 스타일을 생성합니다.

---

### 2. 민화 스타일 — Minhwa

한국 전통 민화의 특징인 선명한 윤곽선과 강한 색감을 영상에 적용합니다.

주요 처리 요소:

- 색상 단순화
- 높은 채도
- 윤곽선 강조
- 전통 회화 색감 적용
- 회화적 질감 표현

기존 영상의 주요 객체와 구도를 유지하면서  
전통 민화 특유의 화려한 색채와 평면적인 표현을 구현합니다.

---

# 🥁 3. 국악 장단 스타일 기반 MV 연출 AI

## 📌 개요

사용자가 업로드한 음원의 **박자·비트·에너지·주파수 변화**를 분석하고  
분석 결과에 따라 전통 시각 효과가 음악에 반응하도록 구성하여  
최대 30초 길이의 MV를 자동 생성합니다.

단순히 영상 전체에 하나의 필터를 적용하는 방식이 아니라  
**음악의 변화에 따라 영상 효과의 종류와 강도가 달라지는 반응형 MV**를 생성하는 것이 핵심입니다.

---

## 🔄 MV 생성 로직

```text
사용자 음원 업로드
        ↓
① 음원 분석
librosa
        ↓
Tempo / Beat / Onset
Energy / Frequency 분석
        ↓
② 음악 특징 추출
        ↓
③ 장단·분위기 분석
        ↓
④ 장면 및 효과 결정
        ↓
⑤ 음악 특징과 효과 Parameter 연결
        ↓
⑥ 프레임 단위 영상 합성
OpenCV / Pillow
        ↓
⑦ 영상 인코딩
FFmpeg
        ↓
⑧ 원본 음원 결합
        ↓
최종 국악 장단 기반 MV 생성
```

---

## 🎵 음악 분석

**librosa**를 활용하여 입력 음원에서 영상 연출에 필요한 음악 특징을 추출합니다.

주요 분석 요소:

| 분석 요소 | 활용 |
|---|---|
| Tempo | 전체 영상의 움직임 속도 |
| Beat | 반복적인 영상 움직임 |
| Onset | 먹 번짐 등 순간 효과 |
| RMS Energy | 효과의 크기 및 강도 |
| Frequency | 시각 효과 및 장면 변화 |

---

## 🎨 전통 시각 효과

음악 분석 결과를 다양한 전통 시각 효과와 연결합니다.

### 먹 번짐

강한 타격음 또는 Onset이 발생할 때 화면에 먹이 퍼지는 효과를 생성합니다.

```text
Strong Onset
     ↓
Ink Splash Trigger
     ↓
Scale / Opacity 증가
```

---

### 붓 획

음악의 구간이 변경될 때 붓이 화면을 지나가며 다음 장면을 드러내는 전환 효과로 사용합니다.

```text
Section Change
      ↓
Brush Stroke
      ↓
Scene Transition
```

---

### 안개

음악의 에너지 변화에 따라 화면에 흐르는 수묵 안개의 속도와 투명도를 조절합니다.

```text
Energy
   ↓
Fog Opacity
Fog Movement Speed
```

---

## 🔗 음악 특징과 영상 효과 연결

```text
Music Analysis
      ↓
┌───────────────────────┐
│ Tempo                 │ → Animation Speed
│ Beat                  │ → Object Movement
│ Onset                 │ → Ink Splash
│ RMS Energy            │ → Effect Intensity
│ Frequency             │ → Visual Variation
└───────────────────────┘
      ↓
Frame Rendering
      ↓
Final MV
```

이를 통해 영상이 단순히 재생되는 것이 아니라  
음악의 흐름에 따라 시각적 요소가 함께 변화하도록 구성합니다.

---

# 🏗️ Gugakify 전체 서비스 구조

```text
                    User
                      │
              Audio / Video Upload
                      │
                      ▼
                Flutter App
                      │
                      ▼
                  Backend
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
   국악 음원      MV 스타일      장단 기반
    변환 AI        변환 AI        MV 연출 AI
        │             │             │
        ▼             ▼             ▼
  Gugak Audio    Styled MV    Reactive Gugak MV
        │             │             │
        └─────────────┼─────────────┘
                      ▼
                  Backend
                      │
                      ▼
                Flutter App
                      │
                      ▼
                    User
```

---

# 🛠️ 기술 스택

## AI / Audio

- Python
- Demucs
- BasicPitch
- librosa
- NumPy
- MIDI Processing
- Kontakt Player
- VST / VST3
- REAPER

## Image / Video

- OpenCV
- Pillow
- FFmpeg

## AI Server

- FastAPI
- Python

## Frontend

- Flutter
- Dart

## Backend

- REST API

---

# 📂 AI 시스템 구성

```text
Gugakify
│
├── 🎼 국악 스타일 음원 변환 AI
│   ├── Audio Separation
│   │   └── Demucs
│   ├── Automatic Transcription
│   │   └── BasicPitch
│   ├── MIDI Processing
│   │   └── Instrument Range Correction
│   ├── Virtual Instrument Rendering
│   │   ├── REAPER
│   │   └── Kontakt Player / VST
│   └── Audio Mixing
│
├── 🎨 국악 스타일 MV 변환 AI
│   ├── Frame Extraction
│   ├── Sumukhwa Style
│   ├── Minhwa Style
│   ├── Frame Reconstruction
│   └── Audio Merge
│
└── 🥁 국악 장단 스타일 기반 MV 연출 AI
    ├── Audio Analysis
    │   └── librosa
    ├── Rhythm Analysis
    ├── Visual Effect Mapping
    │   ├── Ink Splash
    │   ├── Brush Stroke
    │   └── Fog
    ├── Frame Rendering
    │   ├── OpenCV
    │   └── Pillow
    └── Video Encoding
        └── FFmpeg
```

---

# ✨ Gugakify의 특징

### 🎼 원곡의 음악적 특징 유지

완전히 새로운 음악을 생성하는 방식이 아니라  
자동 채보를 기반으로 원곡의 주요 멜로디를 유지하면서 국악기 음색으로 재구성합니다.

### 🎨 한국 전통 시각 미학 활용

수묵화와 민화 등 한국 전통 회화의 시각적 특징을  
현대적인 영상 콘텐츠에 적용합니다.

### 🥁 음악과 영상의 동기화

Tempo, Beat, Onset, Energy 등의 음악 특징을 분석하여  
영상 효과가 음악에 맞춰 반응하도록 구성합니다.

### 🎻 사용자 선택 기반 국악기 구성

사용자가 원하는 국악기를 선택하여  
같은 음악도 서로 다른 국악기 조합으로 재해석할 수 있습니다.

### 🎬 음원부터 MV까지 통합

음악 변환과 영상 변환을 하나의 서비스에서 제공하여  
사용자가 직접 국악 스타일의 음악 콘텐츠를 제작할 수 있습니다.

---

# 🌱 기대 효과

Gugakify는 전통 국악을 단순히 감상하는 방식에서 벗어나  
사용자가 익숙한 음악을 통해 국악을 직접 경험할 수 있도록 합니다.

이를 통해

- 국악 콘텐츠에 대한 접근성 향상
- 젊은 세대의 전통문화 관심 확대
- K-POP과 국악의 새로운 융합 콘텐츠 제작
- 전통문화 기반 디지털 콘텐츠 확장
- 한국 전통 미학의 글로벌 확산

등의 효과를 기대할 수 있습니다.

---

# 🎯 Project Goal

> **익숙한 음악에서 시작해, 새로운 방식으로 국악을 경험하다.**

Gugakify는 AI 기술을 활용하여  
K-POP·POP과 같은 현대 음악을 **국악의 악기·장단·선율·음색**과  
**한국 전통 시각 미학**으로 재해석합니다.

이를 통해 전통문화가 어렵고 낯선 콘텐츠가 아니라  
누구나 직접 만들고 즐길 수 있는 새로운 디지털 문화 콘텐츠가 되는 것을 목표로 합니다.
