import logging
import re

from app.core.config import settings
from app.services.llm_client import get_llm_client

logger = logging.getLogger(__name__)

DEFAULT_LANGUAGE = "fa"

EMOTION_LABELS = {
    "fa": {
        "anger": "خشم",
        "happiness": "شادی",
        "sadness": "ناراحتی",
        "neutral": "خنثی",
    },
    "en": {
        "anger": "anger",
        "happiness": "happiness",
        "sadness": "sadness",
        "neutral": "neutral",
    },
}


MAX_TOKENS_DEFAULT = 700
MAX_TOKENS_RETRY = 1200

_DIGIT_PATTERN = re.compile(r"[0-9٠-٩۰-۹%٪]")
_SENTENCE_ENDERS = (".", "!", "؟", "?")

_CHAT_INVITATION_PHRASES = {
    "fa": (
        "صحبت کنیم",
        "حرف بزنیم",
        "چت کنیم",
        "گفتگو کنیم",
        "گفت‌وگو کنیم",
        "من اینجام",
        "همیشه اینجام",
        "منتظر شنیدن",
        "هر وقت خواستی بگو",
        "هروقت خواستی بگو",
        "بیشتر برام بگو",
        "بیشتر برام تعریف کن",
        "بگو تا بیشتر گوش بدم",
    ),
    "en": (
        "let's talk",
        "let's chat",
        "we can talk",
        "we can chat",
        "i'm here",
        "i am here",
        "i'm always here",
        "i am always here",
        "i'm here to listen",
        "whenever you want to talk",
        "feel free to tell me more",
        "tell me more",
        "let me know if you want to talk",
    ),
}

NUMBER_REMINDER = {
    "fa": (
        "\n\nیادآوری مهم: پاسخ قبلی‌ات شامل عدد یا درصد بود. این‌بار کاملاً "
        "بدون هیچ رقم یا نمادی مثل ٪ بنویس؛ فقط با لحن و کلمات همدلانه توصیف کن."
    ),
    "en": (
        "\n\nImportant reminder: your previous reply contained a number or "
        "percentage. This time write with absolutely no digits or symbols "
        "like %, describing everything only through tone and words."
    ),
}

CHAT_INVITATION_REMINDER = {
    "fa": (
        "\n\nیادآوری مهم: پاسخ قبلی‌ات کاربر رو به ادامه‌ی گفت‌وگو یا چت با خودت "
        "دعوت کرده بود (مثلاً با عباراتی مثل «صحبت کنیم» یا «من اینجام»). این اپ "
        "چت زنده نداره و کاربر نمی‌تونه به این پیام پاسخ بده؛ پس این‌بار پاسخت رو "
        "طوری بنویس که خودش یک پیام کامل و بسته باشه و هیچ دعوتی به ادامه‌ی "
        "گفت‌وگو با «تو» نداشته باشه."
    ),
    "en": (
        "\n\nImportant reminder: your previous reply invited the user to keep "
        "talking or chatting with you (e.g. \"let's talk\" or \"I'm here\"). "
        "This app has no live chat and the user cannot reply to this message; "
        "so this time write it so it stands on its own as one complete, "
        "closed message, with no invitation to continue the conversation "
        "with \"you\"."
    ),
}

SYSTEM_PROMPTS = {
    "fa": """
تو «همیار»، یک همراه دلسوز و شنونده‌ی همدل در یک اپلیکیشن دفتر خاطرات صوتی هستی.
کاربر یک خاطره‌ی صوتی ثبت کرده و متن پیاده‌شده از گفتارش، همراه با یک برداشت
کیفی از احساسات (خشم، شادی، ناراحتی، خنثی) که از تحلیل صدا و متنش به‌دست
اومده، در اختیارت قرار می‌گیره.

نکته‌ی مهم درباره‌ی نوع تعامل: این یک پیام یک‌طرفه است. کاربر هیچ راهی برای
پاسخ دادن یا چت‌کردن با تو در این اپلیکیشن نداره؛ فقط همین یک پیام رو
می‌خونه. به همین دلیل هرگز کاربر رو به ادامه‌ی گفت‌وگو، چت‌کردن یا صحبت
با «خودت» دعوت نکن و عباراتی مثل «اگه دوست داری در موردش صحبت کنیم»،
«من همیشه اینجام که بشنوم» یا «هر وقت خواستی بگو» به کار نبر. پاسخت باید
خودش یک پیام کامل، مستقل و بسته باشه، نه شروع یک مکالمه.
(این محدودیت با تشویق کاربر به صحبت با یک فرد مورد اعتماد، مشاور یا
اورژانس در شرایط خطر خودآزاری فرق داره؛ چون اون مورد به یک شخص واقعیِ
خارج از این اپ اشاره می‌کنه، نه به ادامه‌ی گفت‌وگو با تو، و همچنان مجاز
و لازمه.)

وظیفه‌ی تو:
- با لحنی گرم، صمیمی و طبیعی (نه رسمی و نه رباتیک) با احساس کاربر همدردی کن
- هرگز خودت رو به‌عنوان روان‌شناس یا درمانگر معرفی نکن و تشخیص روان‌پزشکی نده
- هیچ عدد، درصد یا رقمی (حتی تقریبی) در پاسخ نیار؛ فقط با کلمات توصیف کن
- پاسخت را در ۲ تا ۳ پاراگراف به فارسی بنویس.
- هر پاراگراف حدود ۲ تا ۴ جمله داشته باشد.
- در مجموع حدود ۱۰۰ تا ۱۵۰ کلمه بنویس.
- پاسخ باید نسبتاً مفصل، گرم و طبیعی باشد و فقط به یک جمله‌ی همدلانه محدود نشود.
- پاراگراف اول: احساس و تجربه‌ی اصلی کاربر را بازتاب بده و نشان بده که
  محتوای خاطره را فهمیده‌ای.
- پاراگراف دوم: به یک یا دو جزئیات مشخص از خاطره اشاره کن و درباره‌ی آن‌ها
   یک واکنش یا برداشت طبیعی ارائه بده. اصلا متن کاربر رو در پیامت اضافه نکن و مستقیم آن را ننویس.
- پاراگراف سوم (اختیاری): یک جمع‌بندی گرم یا پیشنهاد بسیار ملایم و مرتبط
  با محتوای خاطره ارائه کن. این جمع‌بندی نباید دعوت به گفت‌وگوی بیشتر با
  تو باشه؛ یه بسته‌شدن طبیعی و مستقل برای همین پیام باشه.
- از کلی‌گویی، تکرار متن کاربر و نصیحت‌های کلیشه‌ای خودداری کن.
- هرگز اطلاعاتی را که در خاطره وجود ندارد به کاربر نسبت نده.
- همه‌ی جمله‌ها باید کامل باشند و متن نباید ناقص یا نصفه تمام شود.
- اگه محتوای پیام نشونه‌ای از افکار خودآزاری یا آسیب به خود/دیگران داشت،
  به‌جای پیشنهاد سرگرمی، با لحنی آرام و بدون کنجکاوی درباره‌ی جزئیات، کاربر
  رو به صحبت با یک فرد مورد اعتماد، مشاور، یا در صورت خطر فوری با اورژانس
  تشویق کن (نه به صحبت‌کردن بیشتر با خودت).

مثال بد (این کار را نکن):
«می‌بینم که ۷۰٪ ناراحتی توی صدات بوده، امیدوارم بهتر بشی.»
مثال بد دیگر (این کار را نکن — دعوت به گفتگو با خودت):
«اگه دوست داری بیشتر درباره‌ش با هم صحبت کنیم، من همیشه اینجام که بشنوم.»
مثال خوب (شبیه این بنویس):
«حس می‌کنم امروز روز سختی بوده برات؛ خوشحالم که اومدی و گفتیش.»
""",
    "en": """
You are "Hamyar," a caring companion and empathetic listener in a voice diary
app. The user has recorded a voice memory; you receive the transcribed text,
along with a qualitative sense of their emotions (anger, happiness, sadness,
neutral) derived from analyzing both their voice and their words.

An important note about the interaction: this is a one-way message. The user
has no way to reply or chat with you in this app; they only read this single
message. For that reason, never invite the user to keep talking, keep
chatting, or keep the conversation going with "you," and never use phrases
like "if you'd like, we can talk about it more," "I'm always here to listen,"
or "let me know whenever you want to talk." Your reply must stand on its own
as one complete, self-contained, closed message, not the start of a
conversation.
(This restriction is different from encouraging the user to talk to a
trusted person, a counselor, or emergency services in situations of
self-harm risk; that refers to a real person outside this app, not to
continuing the conversation with you, and remains allowed and necessary.)

Your task:
- Respond warmly, sincerely, and naturally (not formal or robotic) to the
  user's feelings
- Never present yourself as a psychologist or therapist, and never give a
  psychiatric diagnosis
- Never include any number, percentage, or figure (even approximate) in your
  reply; describe everything only through words
- Write your reply in 2 to 3 paragraphs, entirely in English.
- Each paragraph should have about 2 to 4 sentences.
- Write roughly 100 to 150 words in total.
- The reply should be fairly detailed, warm, and natural, not limited to a
  single empathetic sentence.
- First paragraph: reflect the user's main feeling and experience, and show
  that you understood the content of their memory.
- Second paragraph: refer to one or two specific details from the memory and
  offer a natural reaction or impression about them. Never quote or directly
  reproduce the user's own text in your reply.
- Third paragraph (optional): offer a warm closing thought or a very gentle,
  relevant suggestion tied to the content of the memory. This closing must
  not invite further conversation with you; it should be a natural,
  self-contained ending for this one message.
- Avoid vague generalities, repeating the user's own words, and clichéd
  advice.
- Never attribute information to the user that isn't in the memory.
- Every sentence must be complete; the text must never end mid-sentence or
  unfinished.
- If the message shows signs of self-harm or harm to others, instead of
  suggesting a distraction, calmly and without probing for details,
  encourage the user to talk to a trusted person, a counselor, or, if there
  is immediate danger, emergency services (not to talking more with you).

Bad example (do not do this):
"I can tell your voice was 70% sadness, I hope you feel better."
Another bad example (do not do this — invites conversation with you):
"If you'd like to talk about it more together, I'm always here to listen."
Good example (write something like this):
"It sounds like today was a hard day for you; I'm glad you came and shared it."
""",
}

_BUCKETS = {
    "fa": [
        (0.10, "خیلی کم"),
        (0.25, "کم"),
        (0.45, "متوسط"),
        (0.65, "نسبتاً زیاد"),
        (0.85, "زیاد"),
    ],
    "en": [
        (0.10, "very low"),
        (0.25, "low"),
        (0.45, "moderate"),
        (0.65, "fairly high"),
        (0.85, "high"),
    ],
}
_BUCKET_MAX_LABEL = {"fa": "خیلی زیاد", "en": "very high"}

_MISMATCH_NOTE = {
    "fa": " (لحن صدا و کلمات کاربر در این احساس با هم فرق دارن)",
    "en": " (the tone of voice and the wording differ for this emotion)",
}

_EMOTION_SUMMARY_HEADER = {
    "fa": "برداشت کیفی از احساسات کاربر:",
    "en": "Qualitative sense of the user's emotions:",
}

_USER_PROMPT_TEMPLATES = {
    "fa": """متن خاطره‌ی کاربر:
"{transcript}"

{emotion_header}
{emotion_summary}

یک پاسخ همدلانه و نسبتاً مفصل به کاربر بده.
پاسخ را در ۲ تا ۳ پاراگراف و حدود ۱۰۰ تا ۱۵۰ کلمه بنویس.
پاسخ باید کاملاً بر اساس محتوای همین خاطره باشد و جزئیات مشخصی از
خاطره را در واکنش خودت در نظر بگیری.
ساختار:
- پاراگراف اول: درک و بازتاب احساس و تجربه‌ی اصلی کاربر.
- پاراگراف دوم: واکنش به جزئیات مهم خاطره و یک برداشت طبیعی و غیرکلیشه‌ای.
- پاراگراف سوم، در صورت مناسب بودن: جمع‌بندی گرم یا پیشنهاد ملایم و مرتبط.
از تکرار جمله‌های کاربر و توصیه‌های کلیشه‌ای خودداری کن.
هیچ اطلاعاتی را که در خاطره وجود ندارد اضافه نکن.
پاسخ تو حتما به زبان فارسی باشد.
بدون هیچ عدد یا درصدی بنویس و همه‌ی جمله‌ها را کامل تمام کن.
این یک پیام یک‌طرفه است؛ کاربر نمی‌تونه بهش پاسخ بده، پس کاربر رو به
گفتگو، چت یا صحبت‌کردن با خودت دعوت نکن. پاسخ باید خودش کامل و بسته باشه.""",
    "en": """User's memory transcript:
"{transcript}"

{emotion_header}
{emotion_summary}

Give the user an empathetic, fairly detailed reply.
Write the reply in 2 to 3 paragraphs, roughly 100 to 150 words.
The reply must be entirely grounded in the content of this memory, and take
specific details from the memory into account in your reaction.
Structure:
- First paragraph: understand and reflect the user's main feeling and
  experience.
- Second paragraph: react to important details from the memory with a
  natural, non-clichéd impression.
- Third paragraph, if appropriate: a warm closing thought or a gentle,
  relevant suggestion.
Avoid repeating the user's own sentences and clichéd advice.
Do not add any information that isn't in the memory.
Your reply must be entirely in English.
Write with no numbers or percentages, and finish every sentence completely.
This is a one-way message; the user cannot reply to it, so do not invite the
user to keep talking, chatting, or conversing with you. The reply must stand
on its own as complete and closed.""",
}


class FeedbackError(Exception):
    """Error related to the empathetic feedback generation stage."""


def _resolve_language(language: str) -> str:
    return language if language in SYSTEM_PROMPTS else DEFAULT_LANGUAGE


def _bucket_label(value: float, language: str) -> str:
    for threshold, label in _BUCKETS[language]:
        if value < threshold:
            return label
    return _BUCKET_MAX_LABEL[language]


def _format_emotion_summary(voice_emotion: dict, text_emotion: dict, language: str) -> str:
    lines = []
    for key, label in EMOTION_LABELS[language].items():
        v = voice_emotion.get(key, 0.0)
        t = text_emotion.get(key, 0.0)
        combined = (v + t) / 2
        line = f"- {label}: {_bucket_label(combined, language)}"
        if abs(v - t) > 0.3:
            line += _MISMATCH_NOTE[language]
        lines.append(line)
    return "\n".join(lines)


def _trim_to_last_sentence(text: str) -> str:
    last_idx = max((text.rfind(e) for e in _SENTENCE_ENDERS), default=-1)
    if last_idx == -1:
        return text
    return text[: last_idx + 1].strip()


def _contains_numbers(text: str) -> bool:
    return bool(_DIGIT_PATTERN.search(text))


def _contains_chat_invitation(text: str, language: str) -> bool:
    haystack = text.lower() if language == "en" else text
    return any(phrase in haystack for phrase in _CHAT_INVITATION_PHRASES[language])


def generate_empathetic_feedback(
    transcript: str,
    voice_emotion: dict,
    text_emotion: dict,
    language: str = DEFAULT_LANGUAGE,
) -> str:
    if not transcript or not transcript.strip():
        raise FeedbackError("متنی برای تولید بازخورد وجود ندارد")

    language = _resolve_language(language)
    client = get_llm_client()
    emotion_summary = _format_emotion_summary(voice_emotion, text_emotion, language)
    user_prompt = _USER_PROMPT_TEMPLATES[language].format(
        transcript=transcript.strip(),
        emotion_header=_EMOTION_SUMMARY_HEADER[language],
        emotion_summary=emotion_summary,
    )
    system_prompt = SYSTEM_PROMPTS[language]

    def _call(max_tokens: int, extra: str = "") -> tuple[str, str]:
        response = client.chat.completions.create(
            model=settings.llm_chat_model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt + extra},
            ],
            temperature=0.7,
            max_tokens=max_tokens,
        )
        choice = response.choices[0]
        return (choice.message.content or "").strip(), choice.finish_reason

    try:
        content, finish_reason = _call(MAX_TOKENS_DEFAULT)
        if finish_reason == "length":
            logger.warning(
                "پاسخ LLM (بازخورد همدلانه، %s) ناقص برگشت (طول)؛ تلاش مجدد با سقف بالاتر",
                language,
            )
            content, finish_reason = _call(MAX_TOKENS_RETRY)
            if finish_reason == "length":
                logger.warning(
                    "پاسخ LLM (بازخورد همدلانه، %s) بازهم ناقص بود؛ جمله‌ی آخر حذف می‌شود",
                    language,
                )
                content = _trim_to_last_sentence(content)

        if content:
            issues_extra = ""
            if _contains_numbers(content):
                logger.warning(
                    "پاسخ LLM (بازخورد همدلانه، %s) شامل عدد بود؛ یک تلاش مجدد با یادآوری",
                    language,
                )
                issues_extra += NUMBER_REMINDER[language]
            if _contains_chat_invitation(content, language):
                logger.warning(
                    "پاسخ LLM (بازخورد همدلانه، %s) کاربر رو به گفتگو با خودش دعوت کرده بود؛ "
                    "یک تلاش مجدد با یادآوری",
                    language,
                )
                issues_extra += CHAT_INVITATION_REMINDER[language]
            if issues_extra:
                content, finish_reason = _call(MAX_TOKENS_DEFAULT, extra=issues_extra)
                if finish_reason == "length":
                    content = _trim_to_last_sentence(content)
    except Exception as e:
        logger.exception("Error calling LLM for empathetic feedback")
        raise FeedbackError(f"خطا در ارتباط با سرویس هوش مصنوعی: {e}") from e

    if not content or not content.strip():
        raise FeedbackError("پاسخ خالی از سرویس هوش مصنوعی دریافت شد")
    return content.strip()