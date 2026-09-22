import uuid
from datetime import date, timedelta

import jdatetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.report import DailyReportResponse, WeeklyReportResponse, MonthlyReportResponse, MonthlyDaysResponse, WeeklyTrendResponse, MonthlyInsightResponse, WeeklyInsightResponse
from app.services.aggregation_service import get_week_start, get_weekly_report, get_daily_report, get_monthly_report, get_monthly_days_report, get_week_summary, get_weekly_trend, get_week_summary
from app.services.jalali_utils import to_jalali, shift_jalali_month, JALALI_MONTH_NAMES, jalali_weekday_name
from fastapi import Header
from app.core.language import resolve_response_language
from app.services.aggregation_service import EMOTIONS
from app.api.v1.deps import get_current_user
from app.db.models.user import User

from app.db.models.monthly_insight import MonthlyInsight
from app.services.insight_service import generate_monthly_insight, InsightError, generate_weekly_insight
from app.db.models.weekly_insight import WeeklyInsight

from fastapi import HTTPException
from typing import Annotated

TEHRAN_DIGITS = str.maketrans("0123456789", "۰۱۲۳۴۵۶۷۸۹")

def _snapshot_matches(cached, current: dict, tolerance: float = 1e-6) -> bool:
    if cached.snapshot_notes_count != current["notes_count"]:
        return False
    for emotion in EMOTIONS:
        if abs(getattr(cached, f"snapshot_{emotion}") - current[emotion]) > tolerance:
            return False
    return True

def _weekly_range_label(week_start: date, week_end: date) -> str:
    j_start = to_jalali(week_start)
    j_end = to_jalali(week_end)
    start_txt = str(j_start.day).translate(TEHRAN_DIGITS)
    end_txt = str(j_end.day).translate(TEHRAN_DIGITS)
    if j_start.month == j_end.month:
        return f"{start_txt} تا {end_txt} {JALALI_MONTH_NAMES[j_start.month - 1]}"
    return f"{start_txt} {JALALI_MONTH_NAMES[j_start.month - 1]} تا {end_txt} {JALALI_MONTH_NAMES[j_end.month - 1]}"

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/daily", response_model=DailyReportResponse)
def daily_report(
    for_date: date | None = Query(default=None, description="Gregorian date; empty = today"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    target_date = for_date or date.today()
    data = get_daily_report(db, current_user.id , target_date)
    j = to_jalali(target_date)

    return DailyReportResponse(
        date=target_date,
        jalali_date=f"{j.year}-{j.month:02d}-{j.day:02d}",
        previous_date=target_date - timedelta(days=1),
        next_date=target_date + timedelta(days=1),
        **data,
    )


@router.get("/weekly", response_model=WeeklyReportResponse)
def weekly_report(
    for_date: date | None = Query(default=None, description="Any date within the given week; blank = today"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    target_date = for_date or date.today()
    week_start = get_week_start(target_date)
    days = get_weekly_report(db, current_user.id, week_start)

    week_end = week_start + timedelta(days=6)
    return WeeklyReportResponse(
        week_start=week_start,
        week_end=week_end,
        previous_week_start=week_start - timedelta(days=7),
        next_week_start=week_start + timedelta(days=7),
        range_label=_weekly_range_label(week_start, week_end),
        days=days,
    )


@router.get("/monthly", response_model=MonthlyReportResponse)
def monthly_report(
    jalali_year: int | None = Query(default=None),
    jalali_month: int | None = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if jalali_year is None or jalali_month is None:
        today_jalali = jdatetime.date.today()
        jalali_year = jalali_year or today_jalali.year
        jalali_month = jalali_month or today_jalali.month

    data = get_monthly_report(db, current_user.id, jalali_year, jalali_month)
    prev_y, prev_m = shift_jalali_month(jalali_year, jalali_month, -1)
    next_y, next_m = shift_jalali_month(jalali_year, jalali_month, 1)

    return MonthlyReportResponse(
        jalali_year=jalali_year,
        jalali_month=jalali_month,
        month_name=JALALI_MONTH_NAMES[jalali_month - 1],
        previous_month={"jalali_year": prev_y, "jalali_month": prev_m},
        next_month={"jalali_year": next_y, "jalali_month": next_m},
        **data,
    )



@router.get("/monthly-days", response_model=MonthlyDaysResponse)
def monthly_days_report(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    jalali_year: int | None = Query(default=None),
    jalali_month: int | None = Query(default=None),
):
    if jalali_year is None or jalali_month is None:
        today_jalali = jdatetime.date.today()
        jalali_year = jalali_year or today_jalali.year
        jalali_month = jalali_month or today_jalali.month

    days = get_monthly_days_report(db, current_user.id, jalali_year, jalali_month)
    return MonthlyDaysResponse(jalali_year=jalali_year, jalali_month=jalali_month, days=days)


@router.get("/weekly-trend", response_model=WeeklyTrendResponse)
def weekly_trend_report(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    weeks: int = Query(default=4, ge=1, le=12),
    for_date: date | None = Query(default=None),
):
    anchor = for_date or date.today()
    weeks_data = get_weekly_trend(db, current_user.id, anchor, weeks)
    return WeeklyTrendResponse(weeks=weeks_data)

@router.get("/weekly-insight", response_model=WeeklyInsightResponse)
def get_cached_weekly_insight(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    for_date: date | None = Query(default=None),
    accept_language: str | None = Header(default=None, alias="Accept-Language"),
):
    target_language = resolve_response_language(current_user.language, accept_language)
    target_date = for_date or date.today()
    week_start = get_week_start(target_date)

    cached = (
        db.query(WeeklyInsight)
        .filter(
            WeeklyInsight.user_id == current_user.id,
            WeeklyInsight.week_start == week_start,
            WeeklyInsight.language == target_language,
        )
        .first()
    )
    if not cached:
        raise HTTPException(status_code=404, detail="بینشی برای این هفته هنوز تولید نشده است")

    current_week = get_week_summary(db, current_user.id, week_start)
    if not _snapshot_matches(cached, current_week):
        raise HTTPException(
            status_code=404,
            detail="خاطرات جدیدی از زمان تولید این بینش ثبت شده‌اند؛ بینش قبلی دیگر معتبر نیست",
        )

    return WeeklyInsightResponse(
        week_start=week_start, week_end=week_start + timedelta(days=6), insight=cached.insight_text
    )


@router.post("/weekly-insight/generate", response_model=WeeklyInsightResponse)
def generate_weekly_insight_endpoint(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    for_date: date | None = Query(default=None),
    accept_language: str | None = Header(default=None, alias="Accept-Language"),
):
    target_language = resolve_response_language(current_user.language, accept_language)
    target_date = for_date or date.today()
    week_start = get_week_start(target_date)

    current_week = get_week_summary(db, current_user.id, week_start)
    if current_week["notes_count"] == 0:
        raise HTTPException(status_code=409, detail="برای این هفته هنوز خاطره‌ای ثبت نشده است")

    cached = (
        db.query(WeeklyInsight)
        .filter(
            WeeklyInsight.user_id == current_user.id,
            WeeklyInsight.week_start == week_start,
            WeeklyInsight.language == target_language,
        )
        .first()
    )
    if cached and _snapshot_matches(cached, current_week):
        return WeeklyInsightResponse(
            week_start=week_start, week_end=week_start + timedelta(days=6), insight=cached.insight_text
        )

    previous_week_start = week_start - timedelta(days=7)
    previous_week = get_week_summary(db, current_user.id, previous_week_start)
    days = get_weekly_report(db, current_user.id, week_start)

    try:
        insight_text = generate_weekly_insight(current_week, previous_week, days, language=target_language)
    except InsightError as e:
        raise HTTPException(status_code=502, detail=str(e))

    if cached:
        cached.insight_text = insight_text
        cached.snapshot_notes_count = current_week["notes_count"]
        cached.snapshot_anger = current_week["anger"]
        cached.snapshot_happiness = current_week["happiness"]
        cached.snapshot_sadness = current_week["sadness"]
        cached.snapshot_neutral = current_week["neutral"]
    else:
        db.add(WeeklyInsight(
            user_id=current_user.id,
            week_start=week_start,
            language=target_language,
            insight_text=insight_text,
            snapshot_notes_count=current_week["notes_count"],
            snapshot_anger=current_week["anger"],
            snapshot_happiness=current_week["happiness"],
            snapshot_sadness=current_week["sadness"],
            snapshot_neutral=current_week["neutral"],
        ))
    db.commit()

    return WeeklyInsightResponse(
        week_start=week_start, week_end=week_start + timedelta(days=6), insight=insight_text
    )

@router.get("/monthly-insight", response_model=MonthlyInsightResponse)
def get_cached_monthly_insight(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    jalali_year: int | None = Query(default=None),
    jalali_month: int | None = Query(default=None),
    accept_language: str | None = Header(default=None, alias="Accept-Language"),
):
    target_language = resolve_response_language(current_user.language, accept_language)
    if jalali_year is None or jalali_month is None:
        today_jalali = jdatetime.date.today()
        jalali_year = jalali_year or today_jalali.year
        jalali_month = jalali_month or today_jalali.month

    cached = (
        db.query(MonthlyInsight)
        .filter(
            MonthlyInsight.user_id == current_user.id,
            MonthlyInsight.jalali_year == jalali_year,
            MonthlyInsight.jalali_month == jalali_month,
            MonthlyInsight.language == target_language,
        )
        .first()
    )
    if not cached:
        raise HTTPException(status_code=404, detail="بینشی برای این ماه هنوز تولید نشده است")

    current_month = get_monthly_report(db, current_user.id, jalali_year, jalali_month)
    if not _snapshot_matches(cached, current_month):
        raise HTTPException(
            status_code=404,
            detail="خاطرات جدیدی از زمان تولید این بینش ثبت شده‌اند؛ بینش قبلی دیگر معتبر نیست",
        )

    return MonthlyInsightResponse(jalali_year=jalali_year, jalali_month=jalali_month, insight=cached.insight_text)


@router.post("/monthly-insight", response_model=MonthlyInsightResponse)
def generate_monthly_insight_endpoint(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    jalali_year: int | None = Query(default=None),
    jalali_month: int | None = Query(default=None),
    accept_language: str | None = Header(default=None, alias="Accept-Language"),
):
    target_language = resolve_response_language(current_user.language, accept_language)
    if jalali_year is None or jalali_month is None:
        today_jalali = jdatetime.date.today()
        jalali_year = jalali_year or today_jalali.year
        jalali_month = jalali_month or today_jalali.month

    current_month = get_monthly_report(db, current_user.id, jalali_year, jalali_month)
    if current_month["notes_count"] == 0:
        raise HTTPException(status_code=409, detail="برای این ماه هنوز خاطره‌ای ثبت نشده است")

    cached = (
        db.query(MonthlyInsight)
        .filter(
            MonthlyInsight.user_id == current_user.id,
            MonthlyInsight.jalali_year == jalali_year,
            MonthlyInsight.jalali_month == jalali_month,
            MonthlyInsight.language == target_language,
        )
        .first()
    )
    if cached and _snapshot_matches(cached, current_month):
        return MonthlyInsightResponse(jalali_year=jalali_year, jalali_month=jalali_month, insight=cached.insight_text)

    prev_y, prev_m = shift_jalali_month(jalali_year, jalali_month, -1)
    previous_month = get_monthly_report(db, current_user.id, prev_y, prev_m)
    days = get_monthly_days_report(db, current_user.id, jalali_year, jalali_month)

    try:
        insight_text = generate_monthly_insight(current_month, previous_month, days, language=target_language)
    except InsightError as e:
        raise HTTPException(status_code=502, detail=str(e))

    if cached:
        cached.insight_text = insight_text
        cached.snapshot_notes_count = current_month["notes_count"]
        cached.snapshot_anger = current_month["anger"]
        cached.snapshot_happiness = current_month["happiness"]
        cached.snapshot_sadness = current_month["sadness"]
        cached.snapshot_neutral = current_month["neutral"]
    else:
        db.add(MonthlyInsight(
            user_id=current_user.id,
            jalali_year=jalali_year,
            jalali_month=jalali_month,
            language=target_language,
            insight_text=insight_text,
            snapshot_notes_count=current_month["notes_count"],
            snapshot_anger=current_month["anger"],
            snapshot_happiness=current_month["happiness"],
            snapshot_sadness=current_month["sadness"],
            snapshot_neutral=current_month["neutral"],
        ))
    db.commit()

    return MonthlyInsightResponse(jalali_year=jalali_year, jalali_month=jalali_month, insight=insight_text)