from enum import StrEnum
from typing import Optional

from pydantic import BaseModel, Field, HttpUrl, field_validator


class StyleType(StrEnum):
    SUMUKHWA = "sumukhwa"
    MINHWA = "minhwa"


class JobStatus(StrEnum):
    QUEUED = "queued"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class CurrentStep(StrEnum):
    UPLOAD = "upload"
    FRAME_EXTRACT = "frame_extract"
    STYLE_TRANSFER = "style_transfer"
    VIDEO_MERGE = "video_merge"
    DONE = "done"


class ConversionRequest(BaseModel):
    userId: str = Field(..., min_length=1)
    projectId: str = Field(..., min_length=1)
    inputVideoUrl: HttpUrl
    originalFileName: str = Field(..., min_length=1)
    styleType: StyleType
    preserveAudio: bool
    callbackUrl: Optional[HttpUrl] = None

    @field_validator("callbackUrl", mode="before")
    @classmethod
    def empty_callback_url_to_none(cls, value: object) -> object:
        if isinstance(value, str) and not value.strip():
            return None
        return value


class JobCreateResponse(BaseModel):
    jobId: str
    status: JobStatus
    message: str


class JobStatusResponse(BaseModel):
    jobId: str
    status: JobStatus
    progress: int = Field(..., ge=0, le=100)
    currentStep: CurrentStep
    processingTimeSeconds: Optional[float] = None
    styleTransferTimeSeconds: Optional[float] = None
    errorMessage: Optional[str] = None


class JobResultResponse(BaseModel):
    jobId: str
    status: JobStatus
    outputVideoUrl: str
    thumbnailUrl: str
    duration: float
    outputFileSize: int
    processingTimeSeconds: Optional[float] = None
    styleTransferTimeSeconds: Optional[float] = None
