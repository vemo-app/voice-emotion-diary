import uuid
from sqlalchemy import Column, Date, Text, DateTime, ForeignKey, UniqueConstraint, String, Float, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.session import Base

class WeeklyInsight(Base):
    __tablename__ = "weekly_insights"
    __table_args__ = (
        UniqueConstraint("user_id", "week_start", "language", name="uq_weekly_insight_user_week_lang"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    week_start = Column(Date, nullable=False)
    language = Column(String, nullable=False, server_default="fa")
    insight_text = Column(Text, nullable=False)

    snapshot_notes_count = Column(Integer, nullable=False, server_default="0")
    snapshot_anger = Column(Float, nullable=False, server_default="0")
    snapshot_happiness = Column(Float, nullable=False, server_default="0")
    snapshot_sadness = Column(Float, nullable=False, server_default="0")
    snapshot_neutral = Column(Float, nullable=False, server_default="0")
    created_at = Column(DateTime(timezone=True), server_default=func.now())