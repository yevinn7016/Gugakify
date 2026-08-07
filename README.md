# 🎵 Gugakify 국악 스타일 음원 편곡 AI

**AI로 익숙한 음악을 국악기 중심의 새로운 음원으로 재해석하는 서비스**

K-POP·POP 등 사용자가 업로드한 음원을 분석하고, 보컬과 반주를 분리한 뒤 자동 채보와 국악기별 MIDI 보정을 거쳐 **해금·대금·피리·가야금·거문고 등의 국악기 음색으로 재편곡하는 AI 기반 음원 변환 시스템**입니다.

---

## 🎼 음원 편곡 로직

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
→ 선택한 국악기의 연주 가능 음역에 맞게 조정
→ 해금 / 대금 / 피리 / 가야금 / 거문고 등
        ↓
④ 국악 가상악기 렌더링
Kontakt Player + 국악 가상악기
→ 보정된 MIDI를 실제 국악기 음색으로 연주
→ 파트별 WAV 생성
        ↓
⑤ 음원 믹싱
→ 생성된 국악기 WAV 결합
        ↓
최종 국악 편곡 음원 생성
```

---

## 🔧 주요 변환 과정

### 1. 음원 분리 (Source Separation)

사용자가 업로드한 음원을 **Demucs**를 이용하여 보컬과 반주로 분리합니다.

보컬과 반주를 독립적으로 처리함으로써 각 파트의 멜로디와 리듬을 추출하고, 서로 다른 국악기를 적용할 수 있도록 구성했습니다.

주요 처리 방식:

- 사용자가 MP3/WAV 등의 원본 음원 업로드
- Demucs 기반 음원 분리
- 보컬 파트 `vocals.wav` 추출
- 반주 파트 `other.wav` 추출
- 분리된 각 파트를 자동 채보 단계의 입력으로 사용

```text
original.wav
    │
    └── Demucs
          ├── vocals.wav
          └── other.wav
```

---

### 2. 자동 채보 (Automatic Music Transcription)

분리된 음원에서 **BasicPitch**를 이용해 음정과 리듬 정보를 추출하고 MIDI 악보를 생성합니다.

오디오를 MIDI라는 중간 표현으로 변환하여 **원곡의 멜로디 구조를 최대한 유지하면서 원하는 국악기로 재연주할 수 있도록** 구성했습니다.

주요 처리 방식:

- `vocals.wav` / `other.wav` 입력
- BasicPitch를 이용한 음정(Pitch) 추출
- 음표 시작 및 종료 시점 분석
- 음표 길이 및 리듬 정보 추출
- 분석 결과를 MIDI Note Event로 변환
- 파트별 MIDI 파일 생성

```text
vocals.wav
    ↓
BasicPitch
    ↓
vocal.mid

other.wav
    ↓
BasicPitch
    ↓
other.mid
```

---

### 3. 국악기 맞춤 MIDI 보정

자동 채보로 생성된 MIDI를 사용자가 선택한 **국악기의 연주 가능 음역에 맞게 자동 보정**합니다.

원곡의 음이 선택한 국악기의 음역을 벗어나는 경우 옥타브 단위로 이동시켜 원래 멜로디의 진행을 최대한 유지하면서 해당 악기로 연주할 수 있도록 처리합니다.

#### 악기별 적용 음역

| 국악기 | 적용 음역 |
| :---: | :---: |
| 🎻 해금 | A4 ~ E7 |
| 🪈 대금 | B4 ~ G7 |
| 🪈 피리 | B4 ~ F6 |
| 🪕 가야금 | D3 ~ G5 |
| 🪕 거문고 | E3 ~ F6 |

주요 처리 방식:

- 사용자가 변환할 국악기 선택
- 선택된 악기의 최소·최대 음역 확인
- MIDI Note의 Pitch 검사
- 연주 가능 음역을 벗어난 음표 탐지
- 옥타브 단위(`+12 / -12 semitone`)로 자동 이동
- 보정된 MIDI 파일 생성

#### MIDI 보정 예시

```text
Original MIDI
C4 - D4 - E4 - G4
        ↓
Octave Shift (+12)
        ↓
Adjusted MIDI
C5 - D5 - E5 - G5
```

---

### 4. 국악 가상악기 렌더링

보정된 MIDI는 **REAPER와 Kontakt Player 기반 국악 가상악기**를 이용하여 실제 오디오 파일로 렌더링합니다.

MIDI에는 음높이와 음표 길이 등의 연주 정보만 존재하기 때문에 국악 가상악기를 연결하여 해금·가야금·대금 등의 실제 악기 음색을 적용합니다.

주요 처리 방식:

- 보정된 MIDI를 REAPER로 불러오기
- Kontakt Player를 VST3 가상악기로 연결
- 선택된 국악기 음색 로드
- MIDI Note를 국악 가상악기로 연주
- 파트별 WAV 파일 렌더링

```text
Adjusted MIDI
      ↓
REAPER
      ↓
Kontakt Player
      ↓
Gugak Virtual Instrument
      ↓
Instrument WAV
```

#### REAPER

MIDI 편집, VST 연결, 오디오 믹싱 및 렌더링을 수행하는 **DAW(Digital Audio Workstation)**입니다.

#### Kontakt Player

Native Instruments의 샘플 기반 가상악기 플레이어로, MIDI 입력을 불러온 악기 라이브러리의 실제 음색으로 재생하는 역할을 합니다.

---

### 5. 음원 믹싱

각 MIDI 파트에서 생성된 국악기 WAV 파일을 하나의 음원으로 결합하여 최종 국악 편곡 결과를 생성합니다.

보컬과 반주에 서로 다른 국악기를 적용할 수 있기 때문에 사용자가 원하는 악기 조합으로 국악 편곡을 구성할 수 있습니다.

```text
보컬 멜로디
vocals.wav
    ↓
BasicPitch
    ↓
vocal.mid
    ↓
해금
    ↓
haegeum.wav


반주
other.wav
    ↓
BasicPitch
    ↓
other.mid
    ↓
가야금
    ↓
gayageum.wav


haegeum.wav + gayageum.wav
              ↓
            Mixing
              ↓
      gugak_result.wav
```

---

## 🎻 지원 국악기

사용자는 보컬과 반주 파트에 적용할 국악기를 각각 선택할 수 있습니다.

### 보컬 파트

```text
보컬
 ├── 해금
 ├── 대금
 └── 피리
```

### 반주 파트

```text
반주
 ├── 가야금
 ├── 거문고
 ├── 해금
 └── 대금
```

사용자가 선택한 악기 정보는 **MIDI 보정 단계와 가상악기 렌더링 단계**에 전달되어 해당 악기의 음역과 음색이 적용됩니다.

---

## 📁 프로젝트 구조

```text
app/
├── main.py                     # FastAPI 엔트리포인트
│
├── audio/
│   ├── preprocess.py           # 음원 전처리
│   ├── separation.py           # Demucs 음원 분리
│   ├── transcription.py        # BasicPitch 자동 채보
│   ├── midi_adjust.py          # 국악기별 MIDI 음역 보정
│   └── mixing.py               # 생성 음원 믹싱
│
├── instruments/
│   ├── ranges.py               # 국악기별 연주 가능 음역
│   └── registry.py             # 국악기 설정 및 매핑
│
├── renderer/
│   ├── reaper.py               # REAPER 렌더링 처리
│   └── kontakt.py              # Kontakt 가상악기 연동
│
└── services/
    └── file_manager.py         # 입력/출력 음원 관리

outputs/
├── stems/                      # Demucs 분리 음원
├── midi/                       # 생성 및 보정 MIDI
├── rendered/                   # 국악기별 렌더링 WAV
└── final/                      # 최종 국악 편곡 음원
```

---

## 🧪 테스트 결과

현재 시스템은 다음과 같은 방식으로 테스트되었습니다.

- 입력 음원을 Demucs를 이용해 보컬과 반주로 분리 가능
- BasicPitch를 이용해 분리된 WAV에서 MIDI 자동 채보 가능
- 생성된 MIDI의 음정 및 리듬 정보 확인 가능
- 선택한 국악기의 연주 가능 음역에 맞춰 MIDI 자동 보정 가능
- 음역을 벗어난 MIDI Note에 대한 옥타브 단위 보정 가능
- REAPER와 Kontakt Player를 이용한 국악 가상악기 렌더링 테스트 진행
- 렌더링된 국악기 WAV를 이용해 최종 편곡 음원 구성 가능

### 예시 01 - 보컬 → 해금

| 원본 보컬 | 해금 변환 |
| :---: | :---: |
| `vocals.wav` | `haegeum.wav` |
|  |  |

### 예시 02 - 반주 → 가야금

| 원본 반주 | 가야금 변환 |
| :---: | :---: |
| `other.wav` | `gayageum.wav` |
|  |  |

### 예시 03 - 최종 국악 편곡

| 원본 음원 | 국악 편곡 음원 |
| :---: | :---: |
| Original | Gugakify |
|  |  |

---

## 🛠 기술 스택

| 구분 | 기술 |
| --- | --- |
| Language | Python |
| API Server | FastAPI, Uvicorn |
| Source Separation | Demucs |
| Automatic Transcription | BasicPitch |
| MIDI Processing | PrettyMIDI |
| Audio Processing | FFmpeg |
| DAW | REAPER |
| Virtual Instrument | Kontakt Player |
| Plugin | VST3 / 국악 가상악기 |

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

### 3. 음원 변환

사용자가 음원을 업로드하고 보컬 및 반주에 적용할 국악기를 선택하면 다음 과정이 순차적으로 수행됩니다.

```text
Upload
  ↓
Demucs
  ↓
BasicPitch
  ↓
MIDI Adjustment
  ↓
Gugak Virtual Instrument Rendering
  ↓
Mixing
  ↓
Final WAV
```

최종 생성된 국악 편곡 음원은 출력 디렉터리에 저장되며, 백엔드에서 결과 파일을 전달받아 애플리케이션에서 재생할 수 있도록 구성합니다.

---

## 💡 핵심 기술

> **Source Separation + Automatic Music Transcription + MIDI Processing + Virtual Instrument Rendering**

Gugakify의 음원 편곡 AI는 새로운 음악을 처음부터 생성하는 방식이 아니라, **원곡에서 음악 정보를 추출하고 MIDI로 변환한 뒤 국악기의 연주 특성에 맞게 보정하여 다시 연주하는 방식**을 사용합니다.

이를 통해 **원곡의 멜로디를 최대한 유지하면서 사용자가 선택한 국악기 조합을 적용한 새로운 국악 스타일 음원**을 생성하는 것을 목표로 합니다.
