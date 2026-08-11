<div align="center">

# Gugakify

### AI로 익숙한 음악을 국악 스타일 음원과 전통 미학 MV로 재해석하는 서비스

K-POP·POP 음원을 국악기 중심의 음악으로 변환하고,  
수묵화·민화 스타일의 전통 MV를 생성하는 AI 기반 애플리케이션

</div>

---

## 🎵 Project Overview

Gugakify는 사용자가 업로드한 음악과 영상을 분석하여  
현대 대중음악을 **국악 스타일의 음원과 한국 전통 미학 기반의 MV**로 재창작하는 서비스입니다.

익숙한 음악을 통해 국악과 전통문화를 보다 쉽게 경험할 수 있도록 하는 것을 목표로 합니다. :contentReference[oaicite:0]{index=0}

---

## ✨ Main Features

### 🎼 국악 음원 편곡 AI

음원을 보컬과 반주로 분리하고 자동 채보한 뒤,  
선택한 국악기의 음역에 맞게 MIDI를 보정하여 국악기 음색의 WAV 음원을 생성합니다.

`Demucs` `BasicPitch` `MIDI` `REAPER` `Kontakt Player`

### 🎨 MV 스타일 변환 AI

기존 MV의 프레임을 분석하여  
수묵화 또는 민화 스타일의 전통 영상으로 변환합니다.

`OpenCV` `Pillow` `FFmpeg`

### 🥁 국악 장단 기반 MV 연출 AI

음원의 BPM, Beat, Onset, Energy 등을 분석하고  
먹 번짐, 붓 획, 안개 등 전통 시각 효과를 음악에 맞춰 자동으로 연출합니다.

`librosa` `NumPy` `OpenCV` `FFmpeg`

---

## 🛠 Tech Stack

### Frontend
`Flutter` `Dart` `Firebase`

### Backend
`Python` `FastAPI` `MySQL` `SQLAlchemy`

### AI
`Demucs` `BasicPitch` `librosa` `OpenCV` `Pillow` `FFmpeg`

### Cloud
`Cloudinary` `Render` `Firebase`

---

## 🔄 Service Flow

```text
음원 / 영상 입력
      ↓
국악 음원 변환
      ↓
전통 MV 생성 및 변환
      ↓
최종 WAV / MP4 결과 제공
