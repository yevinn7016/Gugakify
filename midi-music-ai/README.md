# 국악 음원 편곡 파이프라인

원본 음원을 보컬과 반주로 분리하고, 각 파트를 사용자가 선택한 국악기용
MIDI로 변환합니다. Kontakt 라이선스 제약으로 기본 운영 흐름은 MIDI까지
자동 처리한 뒤 개발자가 렌더링과 믹싱을 완료한 최종 `result.wav` 하나를
API에 업로드하는 방식입니다.

## 지원 악기와 음역

| key | 악기 | 음역 | 최대 동시음 |
| --- | --- | --- | ---: |
| `geomungo` | 거문고 | E3-F6 | 3 |
| `haegeum` | 해금 | A4-E7 | 1 |
| `daegeum` | 대금 | B4-G7 | 1 |
| `gayageum` | 가야금 | D3-G5 | 4 |
| `piri` | 피리 | B4-F6 | 1 |
| `danso` | 단소 | G4-G6 | 1 |

## 1. MIDI 생성

`src` 폴더가 아니라 프로젝트 루트에서 실행합니다.

```powershell
python src/pipeline.py prepare uploads/sample.mp3 `
  --vocal-instrument haegeum `
  --accompaniment-instrument gayageum
```

처리가 끝나면 `outputs/jobs/{job_id}/status.json` 상태가
`waiting_for_manual_render`로 변경됩니다. 렌더링할 MIDI는 같은 작업 폴더의
`processed_midi`에 생성됩니다.

## 2. 수동 렌더링과 믹싱

MIDI 두 개를 가상악기로 렌더링하고 REAPER에서 직접 믹싱해 최종
`result.wav`를 만듭니다. 배포된 API 사용법은 아래 API 절을 참고합니다.

기존 자동 합성 실험 코드는 다음 명령으로 계속 사용할 수 있습니다.

```powershell
python src/pipeline.py complete JOB_ID `
  --vocal-wav C:\path\to\vocal_haegeum.wav `
  --accompaniment-wav C:\path\to\other_gayageum.wav
```

이 명령은 개별 WAV 두 개를 Python에서 합성하는 이전 실험 흐름입니다.

## 선택 사항: REAPER 자동 렌더링 시도

`render_config.example.json`을 복사해 악기별 REAPER 프로젝트와 런타임 MIDI
경로를 입력한 다음 실행합니다.

```powershell
python src/pipeline.py auto-render JOB_ID render_config.json
```

렌더링이 성공하면 WAV 합성까지 진행합니다. REAPER 또는 Kontakt 문제로
실패하면 MIDI를 삭제하지 않고 상태를 `waiting_for_manual_render`로 유지하며
`status.json`에 오류를 기록합니다.

각 REAPER 템플릿의 `RENDER_FILE`은 해당 작업에서 요구하는 출력 WAV 경로와
일치해야 합니다. 현재 저장된 `danso_template.rpp`에는 절대 경로가 있으므로
다른 PC에서는 템플릿 경로를 먼저 수정해야 합니다.

## API 로컬 실행

```powershell
uvicorn api:app --app-dir src --host 0.0.0.0 --port 8000
```

Swagger 문서는 `http://localhost:8000/docs`에서 확인합니다. `AI_API_KEY`를
설정했다면 `/health`를 제외한 요청에 `X-API-Key` 헤더가 필요합니다.

### 1. 작업 생성

```powershell
curl.exe -X POST "http://localhost:8000/jobs" `
  -H "X-API-Key: YOUR_KEY" `
  -F "audio=@uploads/sample.mp3" `
  -F "vocal_instrument=haegeum" `
  -F "accompaniment_instrument=gayageum"
```

### 2. 상태 확인과 MIDI 다운로드

```powershell
curl.exe "http://localhost:8000/jobs/JOB_ID" `
  -H "X-API-Key: YOUR_KEY"

curl.exe "http://localhost:8000/jobs/JOB_ID/midi" `
  -H "X-API-Key: YOUR_KEY" `
  --output JOB_ID-midi.zip
```

### 3. 개발자의 최종 WAV 업로드

```powershell
curl.exe -X POST "http://localhost:8000/jobs/JOB_ID/result" `
  -H "X-API-Key: YOUR_KEY" `
  -F "audio=@C:\rendered\result.wav;type=audio/wav"
```

AI 작업과 연결하지 않고 완성된 WAV만 바로 전달하려면 `POST /results`를
사용합니다. 악기 정보는 선택 사항입니다.

```powershell
curl.exe -X POST "http://localhost:8000/results" `
  -H "X-API-Key: YOUR_KEY" `
  -F "audio=@C:\rendered\result.wav;type=audio/wav" `
  -F "vocal_instrument=haegeum" `
  -F "accompaniment_instrument=gayageum"
```

이 요청은 새로운 `delivery_id`를 자동 발급하므로 기존 `job_id`가 필요하지
않습니다.

`BACKEND_RESULT_URL`이 설정되어 있으면 API가 최종 WAV를 해당 백엔드 주소로
즉시 전달합니다. 전달 실패 시 파일을 보존하고 상태를 `delivery_failed`로
기록합니다. 다음 요청으로 전송만 재시도할 수 있습니다.

```powershell
curl.exe -X POST "http://localhost:8000/jobs/JOB_ID/deliver" `
  -H "X-API-Key: YOUR_KEY"
```

## Render 환경변수

- `AI_API_KEY`: API 호출 인증 키
- `BACKEND_RESULT_URL`: 백엔드의 최종 WAV 수신 주소
- `BACKEND_API_TOKEN`: 백엔드 Bearer 인증 토큰
- `OUTPUT_ROOT`: 작업 결과 저장 경로(선택)
- `INCOMING_ROOT`: 업로드 원본 임시 저장 경로(선택)

Render의 기본 파일시스템은 재시작 시 유실될 수 있습니다. Persistent Disk를
사용한다면 예를 들어 `/var/data`에 마운트하고 `OUTPUT_ROOT=/var/data/outputs`,
`INCOMING_ROOT=/var/data/incoming`으로 설정합니다.
