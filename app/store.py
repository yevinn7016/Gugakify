from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional

from app.schemas import CurrentStep, JobStatus, StyleType


@dataclass
class ConversionJob:
    job_id: str
    user_id: str
    project_id: str
    input_video_url: str
    original_file_name: str
    style_type: StyleType
    preserve_audio: bool
    callback_url: Optional[str]
    status: JobStatus = JobStatus.QUEUED
    progress: int = 0
    current_step: CurrentStep = CurrentStep.UPLOAD
    error_message: Optional[str] = None
    output_video_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    duration: Optional[float] = None
    output_file_size: Optional[int] = None
    processing_time_seconds: Optional[float] = None
    style_transfer_time_seconds: Optional[float] = None
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))


class InMemoryJobStore:
    def __init__(self) -> None:
        self._jobs: dict[str, ConversionJob] = {}

    def create(self, job: ConversionJob) -> ConversionJob:
        self._jobs[job.job_id] = job
        return job

    def get(self, job_id: str) -> Optional[ConversionJob]:
        return self._jobs.get(job_id)

    def update(self, job_id: str, **changes: object) -> Optional[ConversionJob]:
        job = self.get(job_id)
        if job is None:
            return None

        for key, value in changes.items():
            setattr(job, key, value)
        job.updated_at = datetime.now(timezone.utc)
        return job


job_store = InMemoryJobStore()
