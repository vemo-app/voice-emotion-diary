import uuid
from datetime import datetime
from pydantic import BaseModel


class VoiceNoteResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    note: str | None = None
    has_image: bool = False
    status: str
    recorded_at: datetime
    transcript: str | None = None
    transcript_raw: str | None = None
    emotion: dict[str, float] | None = None
    feedback: str | None = None
    duration_seconds: float | None = None

    class Config:
        from_attributes = True