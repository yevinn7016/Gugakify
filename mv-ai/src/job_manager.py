from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def write_status(job_dir: Path, status: str, **fields: Any) -> dict[str, Any]:
    job_dir.mkdir(parents=True, exist_ok=True)
    path = job_dir / "status.json"
    previous: dict[str, Any] = {}
    if path.exists():
        previous = json.loads(path.read_text(encoding="utf-8"))
    document = {
        **previous,
        **fields,
        "jobId": job_dir.name,
        "status": status,
        "updatedAt": datetime.now(timezone.utc).isoformat(),
    }
    temporary = path.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(document, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(path)
    return document


def read_status(job_dir: Path) -> dict[str, Any]:
    path = job_dir / "status.json"
    if not path.exists():
        raise FileNotFoundError(path)
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, document: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(document, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(path)
