from fastapi.testclient import TestClient

import api
from api import app


client = TestClient(app)


def test_health_and_openapi() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["service"] == "gugakify-mv"

    schema = client.get("/openapi.json").json()
    assert "/mv/jobs" in schema["paths"]
    assert "/mv/jobs/{job_id}/video" in schema["paths"]


def test_audio_only_upload_accepts_blank_optional_fields(monkeypatch, tmp_path) -> None:
    monkeypatch.setattr(api, "JOBS_ROOT", tmp_path)
    monkeypatch.setattr(api, "_run_mv_job", lambda *args, **kwargs: None)

    response = client.post(
        "/mv/jobs",
        files={"audio": ("sample.wav", b"RIFF" + b"\x00" * 64, "audio/wav")},
        data={
            "start_time": "",
            "background_1": "",
            "background_2": "",
            "background_3": "",
        },
    )

    assert response.status_code == 202
    assert response.json()["status"] == "queued"
