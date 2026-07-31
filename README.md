<div align="center">

# Gugakify Frontend

**AI로 익숙한 음악을 국악 스타일 음원과 전통 미학 MV로 재해석하는 서비스**

K-POP·POP 음원을 국악기 중심의 음악으로 변환하고,  
수묵화와 민화 스타일의 전통 MV를 생성하는 Flutter 애플리케이션

</div>

---

## 주요 기능

- Google 로그인 및 비회원 이용
- URL 입력 또는 음원 파일 업로드
- 보컬 멜로디·반주 악기 선택
- 국악 스타일 음원 생성 및 재생
- 수묵화·민화 스타일 MV 생성
- 결과 음원·영상 확인 및 다운로드
- 프로젝트 보관함과 즐겨찾기 관리

---

## 이용 흐름

```text
로그인
  ↓
홈
  ↓
음원 입력
  ↓
국악 변환 설정
  ↓
국악 음원 결과
  ↓
전통 MV 설정
  ↓
최종 결과
```

---

## 화면 구성

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/01_login.jpeg">
        <img src="docs/screenshots/01_login.jpeg" width="300" alt="로그인 화면">
      </a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/02_home.jpeg">
        <img src="docs/screenshots/02_home.jpeg" width="300" alt="홈 화면">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <b>01. 로그인</b><br>
      Google 계정으로 로그인하거나 비회원으로 서비스를 이용합니다.
    </td>
    <td align="center" valign="top">
      <b>02. 홈</b><br>
      새 변환을 시작하고 최근 프로젝트의 상태와 결과를 확인합니다.
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/03_service_intro.jpeg">
        <img src="docs/screenshots/03_service_intro.jpeg" width="300" alt="서비스 소개 화면">
      </a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/04_audio_url_input.jpeg">
        <img src="docs/screenshots/04_audio_url_input.jpeg" width="300" alt="URL 입력 화면">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <b>03. 서비스 소개</b><br>
      서비스의 핵심 기능과 이용 순서, 저작권 안내를 제공합니다.
    </td>
    <td align="center" valign="top">
      <b>04. 음원 URL 입력</b><br>
      프로젝트 이름과 음원 또는 영상 URL을 입력합니다.
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/05_audio_file_upload.jpeg">
        <img src="docs/screenshots/05_audio_file_upload.jpeg" width="300" alt="파일 업로드 화면">
      </a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/06_audio_settings.jpeg">
        <img src="docs/screenshots/06_audio_settings.jpeg" width="300" alt="국악 변환 설정 화면">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <b>05. 음원 파일 업로드</b><br>
      MP3·WAV·M4A 파일을 선택하고 이용 권한을 확인합니다.
    </td>
    <td align="center" valign="top">
      <b>06. 국악 변환 설정</b><br>
      보컬 멜로디와 반주를 연주할 국악기를 각각 선택합니다.
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/07_audio_result_top.jpeg">
        <img src="docs/screenshots/07_audio_result_top.jpeg" width="300" alt="국악 음원 결과 화면">
      </a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/08_audio_result_detail.jpeg">
        <img src="docs/screenshots/08_audio_result_detail.jpeg" width="300" alt="국악 음원 상세 화면">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <b>07. 국악 음원 완성</b><br>
      생성된 WAV 음원을 재생하거나 내려받을 수 있습니다.
    </td>
    <td align="center" valign="top">
      <b>08. 음원 결과 상세</b><br>
      사용 악기와 처리 방식, 파일명과 음원 길이를 확인합니다.
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/09_mv_settings_top.jpeg">
        <img src="docs/screenshots/09_mv_settings_top.jpeg" width="300" alt="전통 MV 설정 화면">
      </a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/10_mv_settings_detail.jpeg">
        <img src="docs/screenshots/10_mv_settings_detail.jpeg" width="300" alt="MV 설정 요약 화면">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <b>09. 전통 MV 설정</b><br>
      전통 화풍과 결과 영상의 화면 비율을 선택합니다.
    </td>
    <td align="center" valign="top">
      <b>10. MV 설정 요약</b><br>
      선택한 스타일과 영상 비율, 처리 방식을 확인합니다.
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/11_final_result.jpeg">
        <img src="docs/screenshots/11_final_result.jpeg" width="300" alt="최종 결과 화면">
      </a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/12_mypage.jpeg">
        <img src="docs/screenshots/12_mypage.jpeg" width="300" alt="마이페이지 화면">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <b>11. 최종 결과</b><br>
      완성된 전통 MV와 국악 음원을 재생하고 다운로드합니다.
    </td>
    <td align="center" valign="top">
      <b>12. 마이페이지</b><br>
      사용자 정보와 프로젝트, 즐겨찾기 및 결과물을 관리합니다.
    </td>
  </tr>
</table>

---

## 기술 스택

| 구분 | 기술 |
| --- | --- |
| Framework | Flutter |
| Language | Dart |
| Design | Figma |
| Target | Android |
| Version Control | Git, GitHub |

> 패키지와 정확한 버전 정보는 `pubspec.yaml` 및 `pubspec.lock`을 기준으로 확인합니다.

---

## 시작하기

### 1. 저장소 복제

```bash
git clone <FRONTEND_REPOSITORY_URL>
cd <FRONTEND_DIRECTORY>
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. 개발 환경 확인

```bash
flutter doctor -v
flutter devices
```

### 4. 애플리케이션 실행

```bash
flutter run
```

Web에서 실행하려면 다음 명령을 사용합니다.

```bash
flutter run -d chrome
```

연결된 Android 기기 또는 에뮬레이터에서 실행하려면 다음 명령을 사용합니다.

```bash
flutter run -d <DEVICE_ID>
```

---

## 프로젝트 구조

```text
frontend/
├── android/
├── assets/
├── docs/
│   └── screenshots/
├── lib/
│   ├── core/
│   ├── features/
│   ├── shared/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

> 실제 폴더 구조가 다른 경우 현재 프로젝트 구조에 맞게 이 부분을 수정합니다.

---

## 저작권 안내

- 본인이 소유하거나 이용 권한이 있는 음원만 변환할 수 있습니다.
- 타인의 저작물을 무단으로 업로드하거나 결과물을 배포해서는 안 됩니다.
- 현재 결과물은 대회 시연 및 개인 학습 목적의 결과로 사용됩니다.

---

## License

본 프로젝트는 **2026 IT 경진대회 출품을 위해 개발된 프로젝트**입니다.