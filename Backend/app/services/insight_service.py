import logging
import re

from app.core.config import settings
from app.services.llm_client import get_llm_client
from app.services.aggregation_service import EMOTIONS
from app.services.jalali_utils import jalali_weekday_name

logger = logging.getLogger(__name__)

EMOTION_LABELS = {
    "fa": {"anger": "خشم", "happiness": "شادی", "sadness": "ناراحتی", "neutral": "خنثی"},
    "en": {"anger": "anger", "happiness": "happiness", "sadness": "sadness", "neutral": "neutral"},
}

PERIOD_LABELS = {
    "fa": {"week": "هفته", "month": "ماه"},
    "en": {"week": "week", "month": "month"},
}


MAX_TOKENS_DEFAULT = 900
MAX_TOKENS_RETRY = 1500

_DIGIT_PATTERN = re.compile(r"[0-9٠-٩۰-۹%٪]")
_SENTENCE_ENDERS = (".", "!", "؟", "?")

NUMBER_REMINDER = {
    "fa": (
        "\n\nیادآوری مهم: پاسخ قبلی‌ات شامل عدد یا درصد بود. این‌بار پاسخت را "
        "کاملاً بدون هیچ رقم یا نمادی مثل ٪ بنویس؛ فقط با کلماتی مثل «کمی»، "
        "«به‌طور محسوس»، «افزایش داشته» توصیف کن."
    ),
    "en": (
        "\n\nImportant reminder: your previous reply contained a number or "
        "percentage. This time write your reply with absolutely no digits or "
        "symbols like %; only describe things qualitatively with words like "
        "\"slightly\", \"noticeably\", \"has increased\"."
    ),
}


class InsightError(Exception):
    """Error related to the weekly/monthly insight generation stage."""


def _bucket_label(value: float, language: str) -> str:
    fa_labels = ["خیلی کم", "کم", "متوسط", "نسبتاً زیاد", "زیاد", "خیلی زیاد"]
    en_labels = ["very low", "low", "moderate", "fairly high", "high", "very high"]
    labels = en_labels if language == "en" else fa_labels

    if value < 0.10:
        return labels[0]
    if value < 0.25:
        return labels[1]
    if value < 0.45:
        return labels[2]
    if value < 0.65:
        return labels[3]
    if value < 0.85:
        return labels[4]
    return labels[5]


def _trend_label(current: float, previous: float, language: str) -> str:
    diff = current - previous
    if language == "en":
        if abs(diff) < 0.05:
            return "almost unchanged"
        if diff > 0:
            return "a significant increase" if diff > 0.15 else "a slight increase"
        return "a significant decrease" if diff < -0.15 else "a slight decrease"

    if abs(diff) < 0.05:
        return "تقریباً بدون تغییر"
    if diff > 0:
        return "افزایش قابل توجه" if diff > 0.15 else "کمی افزایش"
    return "کاهش قابل توجه" if diff < -0.15 else "کمی کاهش"


def _dominant_emotion(day: dict) -> str:
    return max(EMOTIONS, key=lambda e: day[e])


def _format_emotion_line(m: dict, language: str) -> str:
    labels = EMOTION_LABELS.get(language, EMOTION_LABELS["fa"])
    separator = ", " if language == "en" else "، "
    return separator.join(f"{labels[e]}: {_bucket_label(m[e], language)}" for e in EMOTIONS)


def _format_trend_line(current: dict, previous: dict, language: str) -> str:
    labels = EMOTION_LABELS.get(language, EMOTION_LABELS["fa"])
    separator = ", " if language == "en" else "، "
    return separator.join(
        f"{labels[e]}: {_trend_label(current[e], previous[e], language)}" for e in EMOTIONS
    )


def _format_daily_breakdown(days: list[dict], language: str) -> str:

    labels = EMOTION_LABELS.get(language, EMOTION_LABELS["fa"])
    lines = []
    for day in days:
        if day["notes_count"] == 0:
            continue
        dominant = _dominant_emotion(day)
        label = jalali_weekday_name(day["date"], language)
        separator = ", " if language == "en" else "، "
        detail = separator.join(f"{labels[e]}: {_bucket_label(day[e], language)}" for e in EMOTIONS)
        if language == "en":
            lines.append(f"- {label}: dominant emotion = {labels[dominant]} ({detail})")
        else:
            lines.append(f"- {label}: احساس غالب = {labels[dominant]} ({detail})")

    if lines:
        return "\n".join(lines)
    return "No entries recorded for this period" if language == "en" else "خاطره‌ای برای این بازه ثبت نشده"


def _trim_to_last_sentence(text: str) -> str:
    last_idx = max((text.rfind(e) for e in _SENTENCE_ENDERS), default=-1)
    if last_idx == -1:
        return text
    return text[: last_idx + 1].strip()


def _contains_numbers(text: str) -> bool:
    return bool(_DIGIT_PATTERN.search(text))


INSIGHT_RULES = {
    "fa": """
قوانین حیاتی:
- فقط به روزهایی اشاره کن که در «شکست روز‌به‌روز» زیر آورده شده‌اند.
- اگر به یک روز خاص اشاره می‌کنی، احساسش را دقیقاً همان‌طور که در ستون
  «احساس غالب» آمده توصیف کن؛ هرگز روزی با احساس غالب خشم یا ناراحتی را
  شاد یا آرام توصیف نکن.
- اگر داده‌ی کافی برای نتیجه‌گیری مطمئن درباره‌ی یک روز خاص نداری، فقط بر
  اساس روند کلی بازه صحبت کن، نه یک روز مشخص.
- هرگز تشخیص روان‌شناسی نده و نتیجه‌گیری بالینی نکن.
- هیچ عدد، درصد یا رقمی (حتی تقریبی) در پاسخ نیاور؛ فقط با کلمات کیفی مثل
  «کمی»، «به‌طور محسوس»، «افزایش/کاهش داشته» توصیف کن.
- این متن قراره توی یک صفحه‌ی مجزا و کامل در اپ نمایش داده بشه، پس کوتاه
  ننویس. پاسخت را در ۳ تا ۴ پاراگراف به زبان فارسی بنویس (هر پاراگراف ۲ تا ۴ جمله،
  در مجموع حدود ۱۵۰ تا ۲۵۰ کلمه) با این ساختار:
  ۱) پاراگراف اول: نگاه کلی به روند احساسات این دوره نسبت به دوره‌ی قبل.
  ۲) پاراگراف دوم: اشاره به چند روز خاص و قابل‌توجه از شکست روز‌به‌روز
     (نه فقط یک روز) و توضیح اینکه چرا برجسته بودن.
  ۳) پاراگراف سوم: یک جمع‌بندی از الگوی کلی رفتار/حال کاربر در این بازه.
  ۴) پاراگراف چهارم (اختیاری): یک پیشنهاد یا تشویق ملایم و غیرکلیشه‌ای
     برای دوره‌ی بعد، متناسب با همین داده‌ها.
- هرگز جمله یا پاراگراف را ناقص رها نکن. اگر به انتهای حجم مجاز نزدیک
  شدی و جمله‌ی جاری کامل نشده، جمله را زودتر جمع کن.

مثال بد (این کار را نکن - خیلی کوتاه و با عدد):
«این هفته شادی‌ات ۶۰٪ بود که نسبت به هفته‌ی قبل ۱۵٪ افزایش داشته.»

مثال خوب (شبیه این ساختار و حجم بنویس):
«این هفته نسبت به هفته‌ی قبل حال‌وهوای آرام‌تر و شادتری داشتی، و انگار
فشار روزهای ابتدایی هفته کمی فروکش کرده. روز شنبه و سه‌شنبه دو تا از
روزهایی بودن که بیشترین آرامش رو تجربه کردی؛ به‌نظر می‌رسه شروع هفته
برات بهتر از وسط هفته پیش رفته. در مقابل، پنجشنبه احساس غالب کمی به
سمت ناراحتی متمایل بوده که با توجه به نزدیک شدن به آخر هفته طبیعیه.
در کل، الگوی این هفته نشون می‌ده که ثبات احساسیت نسبت به قبل بهتر شده.
اگه بتونی این ریتم آروم‌تر رو توی هفته‌ی بعد هم حفظ کنی، احتمالاً
حس بهتری از کل هفته خواهی داشت.»
""",
    "en": """
Critical rules:
- Only reference days that appear in the "daily breakdown" below.
- If you mention a specific day, describe its emotion exactly as shown in
  the "dominant emotion" data; never describe a day whose dominant emotion
  is anger or sadness as happy or calm.
- If you don't have enough data to confidently draw a conclusion about a
  specific day, speak only about the overall trend of the period, not a
  specific day.
- Never give a psychological diagnosis or clinical conclusion.
- Do not include any number, percentage, or digit (even approximate) in
  your response; only describe things qualitatively with words like
  "slightly", "noticeably", "has increased/decreased".
- This text will be displayed on its own dedicated page in the app, so
  don't write briefly. Write your response in 3 to 4 paragraphs in English
  (each paragraph 2 to 4 sentences, about 150 to 250 words total) with this
  structure:
  1) First paragraph: an overview of this period's emotional trend
     compared to the previous period.
  2) Second paragraph: mention a few specific, notable days from the daily
     breakdown (not just one) and explain why they stood out.
  3) Third paragraph: a summary of the user's overall mood pattern during
     this period.
  4) Fourth paragraph (optional): a gentle, non-cliché suggestion or
     encouragement for the next period, tailored to this data.
- Never leave a sentence or paragraph incomplete. If you're approaching
  the token limit and the current sentence isn't finished, wrap it up
  early.

Bad example (don't do this - too short and with numbers):
"Your happiness this week was 60%, up 15% from last week."

Good example (write in a similar structure and length):
"This week you had a calmer and happier mood compared to last week, and it
seems like the pressure from earlier in the week eased off a bit. Saturday
and Tuesday were two of the days when you felt the most at ease; it seems
like the start of the week went better for you than the middle of it. On
the other hand, Thursday's dominant emotion leaned slightly toward
sadness, which is understandable given the approach of the weekend.
Overall, this week's pattern shows that your emotional stability has
improved compared to before. If you can keep this calmer rhythm going
into next week, you'll likely feel even better about the week as a
whole."
""",
}

WEEKLY_SYSTEM_PROMPTS = {
    "fa": f"""
تو یک تحلیل‌گر داده‌ی دوستانه در یک اپلیکیشن دفتر خاطرات صوتی هستی.
بر اساس روند احساسات هفته‌ی جاری در مقایسه با هفته‌ی قبل، و شکست
روز‌به‌روز هفته‌ی جاری، یک تحلیل روایی و مفصل، دوستانه و کاملاً مبتنی بر
داده به زبان فارسی بنویس.
{INSIGHT_RULES["fa"]}
""",
    "en": f"""
You are a friendly data analyst in a voice diary app.
Based on the current week's emotional trend compared to the previous
week, and the daily breakdown of the current week, write a detailed,
friendly, and strictly data-driven narrative analysis in English.
{INSIGHT_RULES["en"]}
""",
}

MONTHLY_SYSTEM_PROMPTS = {
    "fa": f"""
تو یک تحلیل‌گر داده‌ی دوستانه در یک اپلیکیشن دفتر خاطرات صوتی هستی.
بر اساس روند احساسات ماه جاری در مقایسه با ماه قبل، و شکست روز‌به‌روز
ماه جاری، یک تحلیل روایی و مفصل، دوستانه و کاملاً مبتنی بر داده به زبان
فارسی بنویس.
{INSIGHT_RULES["fa"]}
""",
    "en": f"""
You are a friendly data analyst in a voice diary app.
Based on the current month's emotional trend compared to the previous
month, and the daily breakdown of the current month, write a detailed,
friendly, and strictly data-driven narrative analysis in English.
{INSIGHT_RULES["en"]}
""",
}


def _build_user_prompt(
    language: str, period_key: str, current: dict, previous: dict, days: list[dict]
) -> str:
    period_label = PERIOD_LABELS.get(language, PERIOD_LABELS["fa"])[period_key]
    trend_line = _format_trend_line(current, previous, language)
    emotion_line = _format_emotion_line(current, language)
    daily_breakdown = _format_daily_breakdown(days, language)

    if language == "en":
        return f"""Emotional trend of the current {period_label} compared to the previous {period_label} (based on {current['notes_count']} entries vs {previous['notes_count']} entries):
{trend_line}

Qualitative emotional state of the current {period_label}:
{emotion_line}

Daily breakdown of the current {period_label}:
{daily_breakdown}

Write a detailed, multi-paragraph analysis based on this information, following the structure and length described in the rules. Remember: no numbers or percentages."""

    return f"""روند احساسات {period_label}ِ جاری نسبت به {period_label}ِ قبل (بر اساس {current['notes_count']} خاطره در برابر {previous['notes_count']} خاطره):
{trend_line}

وضعیت کیفی احساسات {period_label}ِ جاری:
{emotion_line}

شکست روز‌به‌روز {period_label}ِ جاری:
{daily_breakdown}

یک تحلیل مفصل و چندپاراگرافه بر اساس این اطلاعات بنویس، طبق ساختار و
حجمی که در قوانین گفته شده. یادت باشه: بدون هیچ عدد یا درصدی."""


def _generate_insight(
    system_prompts: dict,
    current: dict,
    previous: dict,
    days: list[dict],
    period_key: str,
    error_context: str,
    language: str,
) -> str:
    client = get_llm_client()
    system_prompt = system_prompts.get(language, system_prompts["fa"])
    user_prompt = _build_user_prompt(language, period_key, current, previous, days)
    reminder = NUMBER_REMINDER.get(language, NUMBER_REMINDER["fa"])

    def _call(max_tokens: int, extra: str = "") -> tuple[str, str]:
        response = client.chat.completions.create(
            model=settings.llm_chat_model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt + extra},
            ],
            temperature=0.5,
            max_tokens=max_tokens,
        )
        choice = response.choices[0]
        return (choice.message.content or "").strip(), choice.finish_reason

    try:
        content, finish_reason = _call(MAX_TOKENS_DEFAULT)

        if finish_reason == "length":
            logger.warning("پاسخ LLM (%s) ناقص برگشت (طول)؛ تلاش مجدد با سقف بالاتر", error_context)
            content, finish_reason = _call(MAX_TOKENS_RETRY)
            if finish_reason == "length":
                logger.warning("پاسخ LLM (%s) بازهم ناقص بود؛ جمله‌ی آخر حذف می‌شود", error_context)
                content = _trim_to_last_sentence(content)

        if content and _contains_numbers(content):
            logger.warning("پاسخ LLM (%s) شامل عدد بود؛ یک تلاش مجدد با یادآوری", error_context)
            content, finish_reason = _call(MAX_TOKENS_DEFAULT, extra=reminder)
            if finish_reason == "length":
                content = _trim_to_last_sentence(content)

    except InsightError:
        raise
    except Exception as e:
        logger.exception("Error calling LLM for %s (%s)", error_context, language)
        error_msg = f"Error generating {error_context}: {e}" if language == "en" else f"خطا در تولید {error_context}: {e}"
        raise InsightError(error_msg) from e

    if not content or not content.strip():
        empty_msg = f"Empty response received from the AI service ({error_context})" if language == "en" else f"پاسخ خالی از سرویس هوش مصنوعی دریافت شد ({error_context})"
        raise InsightError(empty_msg)

    return content.strip()


def generate_weekly_insight(
    current_week: dict, previous_week: dict, current_week_days: list[dict], language: str = "fa"
) -> str:
    error_context = "weekly insight" if language == "en" else "بینش هفتگی"
    return _generate_insight(
        WEEKLY_SYSTEM_PROMPTS,
        current_week,
        previous_week,
        current_week_days,
        period_key="week",
        error_context=error_context,
        language=language,
    )


def generate_monthly_insight(
    current_month: dict, previous_month: dict, current_month_days: list[dict], language: str = "fa"
) -> str:
    error_context = "monthly insight" if language == "en" else "بینش ماهانه"
    return _generate_insight(
        MONTHLY_SYSTEM_PROMPTS,
        current_month,
        previous_month,
        current_month_days,
        period_key="month",
        error_context=error_context,
        language=language,
    )