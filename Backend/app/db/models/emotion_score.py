from sqlalchemy import Column, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.db.session import Base


class VoiceEmotionScore(Base):
    __tablename__ = "voice_emotion_scores"

    voice_note_id = Column(UUID(as_uuid=True), ForeignKey("voice_notes.id"), primary_key=True)
    anger = Column(Float, nullable=False)
    sadness = Column(Float, nullable=False)
    happiness = Column(Float, nullable=False)
    neutral = Column(Float, nullable=False)


class TextEmotionScore(Base):
    __tablename__ = "text_emotion_scores"

    voice_note_id = Column(UUID(as_uuid=True), ForeignKey("voice_notes.id"), primary_key=True)
    anger = Column(Float, nullable=False)
    sadness = Column(Float, nullable=False)
    happiness = Column(Float, nullable=False)
    neutral = Column(Float, nullable=False)