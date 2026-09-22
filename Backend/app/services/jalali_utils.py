from datetime import date, timedelta

import jdatetime

JALALI_MONTH_NAMES = [
    "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
    "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند",
]

PERSIAN_WEEKDAY_NAMES = ["شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه"]
ENGLISH_WEEKDAY_NAMES = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]


def to_jalali(g_date: date) -> jdatetime.date:
    return jdatetime.date.fromgregorian(date=g_date)


_PERSIAN_DIGITS = str.maketrans("0123456789", "۰۱۲۳۴۵۶۷۸۹")


def joined_month_label(created_at: date) -> str:
    j = to_jalali(created_at)
    year_txt = str(j.year).translate(_PERSIAN_DIGITS)
    return f"{JALALI_MONTH_NAMES[j.month - 1]} {year_txt}"


def jalali_month_range(jalali_year: int, jalali_month: int) -> tuple[date, date]:
    start_jalali = jdatetime.date(jalali_year, jalali_month, 1)
    if jalali_month == 12:
        next_start_jalali = jdatetime.date(jalali_year + 1, 1, 1)
    else:
        next_start_jalali = jdatetime.date(jalali_year, jalali_month + 1, 1)
    end_jalali = next_start_jalali - timedelta(days=1)
    return start_jalali.togregorian(), end_jalali.togregorian()


def shift_jalali_month(jalali_year: int, jalali_month: int, delta: int) -> tuple[int, int]:
    index = (jalali_year * 12 + (jalali_month - 1)) + delta
    return index // 12, (index % 12) + 1

def jalali_weekday_name(g_date: date, language: str = "fa") -> str:
    shamsi_index = (g_date.weekday() - 5) % 7
    names = ENGLISH_WEEKDAY_NAMES if language == "en" else PERSIAN_WEEKDAY_NAMES
    return names[shamsi_index]