from datetime import date
from pydantic import BaseModel


class DailyEmotionPoint(BaseModel):
    date: date
    jalali_date: str
    notes_count: int
    anger: float
    happiness: float
    sadness: float
    neutral: float


class WeeklyReportResponse(BaseModel):
    week_start: date
    week_end: date
    previous_week_start: date
    next_week_start: date
    range_label: str
    days: list[DailyEmotionPoint]


class DailyReportResponse(BaseModel):
    date: date
    jalali_date: str
    notes_count: int
    anger: float
    happiness: float
    sadness: float
    neutral: float
    previous_date: date
    next_date: date


class JalaliMonthRef(BaseModel):
    jalali_year: int
    jalali_month: int


class MonthlyReportResponse(BaseModel):
    jalali_year: int
    jalali_month: int
    month_name: str
    notes_count: int
    anger: float
    happiness: float
    sadness: float
    neutral: float
    previous_month: JalaliMonthRef
    next_month: JalaliMonthRef

class DayEmotionPoint(BaseModel):
    date: date
    notes_count: int
    anger: float
    happiness: float
    sadness: float
    neutral: float


class MonthlyDaysResponse(BaseModel):
    jalali_year: int
    jalali_month: int
    days: list[DayEmotionPoint]


class WeekSummaryPoint(BaseModel):
    week_start: date
    week_end: date
    notes_count: int
    anger: float
    happiness: float
    sadness: float
    neutral: float


class WeeklyTrendResponse(BaseModel):
    weeks: list[WeekSummaryPoint]

class MonthlyInsightResponse(BaseModel):
    jalali_year: int
    jalali_month: int
    insight: str

class WeeklyInsightResponse(BaseModel):
    week_start: date
    week_end: date
    insight: str