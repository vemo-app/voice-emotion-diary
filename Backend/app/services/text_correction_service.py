import logging

from app.core.config import settings
from app.services.llm_client import get_llm_client

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """
تو یک ویراستار متن فارسی هستی که وظیفه‌ات اصلاح خروجی خام یک مدل
تبدیل گفتار به نوشتار (STT) است.

قوانین:
- فقط غلط‌های واضح ناشی از تبدیل گفتار به نوشتار رو اصلاح کن (کلمات
  به‌اشتباه به‌هم چسبیده یا از هم جدا شده، غلط‌های واجی واضح).
- لحن محاوره‌ای و سبک صحبت گوینده رو دست‌نخورده نگه دار؛ جمله رو
  رسمی یا کتابی نکن.
- هیچ کلمه یا جمله‌ی جدیدی اضافه نکن و معنای متن رو تغییر نده.
- فقط و فقط متن اصلاح‌شده رو برگردون، بدون هیچ توضیح یا مقدمه‌ای.
- اگر متن ورودی خالی یا بی‌معنی بود، همون رو بدون تغییر برگردون.
"""


class TextCorrectionError(Exception):
    """Error related to the text modification step with LLM."""


def correct_transcript(raw_transcript: str) -> str:
    if not raw_transcript or not raw_transcript.strip():
        return raw_transcript

    client = get_llm_client()

    try:
        response = client.chat.completions.create(
            model=settings.llm_chat_model,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": raw_transcript.strip()},
            ],
            temperature=0.2,
            max_tokens=500,
        )
    except Exception as e:
        logger.exception("Error calling LLM for transcript correction")
        raise TextCorrectionError(f"خطا در اصلاح متن: {e}") from e

    content = response.choices[0].message.content
    if not content or not content.strip():
        raise TextCorrectionError("پاسخ خالی از سرویس هوش مصنوعی دریافت شد")
    return content.strip()