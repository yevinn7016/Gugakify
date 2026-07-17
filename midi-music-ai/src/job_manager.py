from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict


def write_status(job_dir: Path, status: str, **fields: Any) -> Dict[str, Any]:
    status_path = job_dir / "status.json"
    previous: Dict[str, Any] = {}
    if status_path.exists():
        previous = json.loads(status_path.read_text(encoding="utf-8"))

    document = {
        **previous,
        **fields,
        "job_id": job_dir.name,
        "status": status,
        "updated_at": datetime.now(timezone.utc).isoformat(),
    }
    status_path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = status_path.with_suffix(".json.tmp")
    temporary_path.write_text(
        json.dumps(document, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    temporary_path.replace(status_path)
    return document


def read_status(job_dir: Path) -> Dict[str, Any]:
    status_path = job_dir / "status.json"
    if not status_path.exists():
        raise FileNotFoundError(f"작업 상태 파일이 없습니다: {status_path}")
    return json.loads(status_path.read_text(encoding="utf-8"))

