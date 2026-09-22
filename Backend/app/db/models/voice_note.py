import uuid
from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.session import Base
from sqlalchemy import Float


class VoiceNote(Base):
    __tablename__ = "voice_notes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    file_path = Column(String, nullable=False)
    title = Column(String, nullable=False)
    note = Column(Text, nullable=True)
    image_path = Column(String, nullable=True)
    transcript = Column(Text, nullable=True)
    transcript_raw = Column(Text, nullable=True)
    feedback_language = Column(String, nullable=True)
    feedback = Column(Text, nullable=True)
    duration_seconds = Column(Float, nullable=True)
    status = Column(String, default="processing")
    recorded_at = Column(DateTime(timezone=True), server_default=func.now())