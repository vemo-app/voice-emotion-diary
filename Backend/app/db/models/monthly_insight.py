import uuid
from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, UniqueConstraint, String, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.session import Base


class MonthlyInsight(Base):
    __tablename__ = "monthly_insights"
    __table_args__ = (
        UniqueConstraint("user_id", "jalali_year", "jalali_month", "language", name="uq_monthly_insight_user_month_lang"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    jalali_year = Column(Integer, nullable=False)
    jalali_month = Column(Integer, nullable=False)
    language = Column(String, nullable=False, server_default="fa")
    insight_text = Column(Text, nullable=False)

    snapshot_notes_count = Column(Integer, nullable=False, server_default="0")
    snapshot_anger = Column(Float, nullable=False, server_default="0")
    snapshot_happiness = Column(Float, nullable=False, server_default="0")
    snapshot_sadness = Column(Float, nullable=False, server_default="0")
    snapshot_neutral = Column(Float, nullable=False, server_default="0")
    created_at = Column(DateTime(timezone=True), server_default=func.now())