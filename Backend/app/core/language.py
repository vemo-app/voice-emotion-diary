def resolve_response_language(user_language: str, accept_language_header: str | None) -> str:

    if user_language in ("fa", "en"):
        return user_language

    if accept_language_header:
        header = accept_language_header.lower()
        for lang_tag in header.split(","):
            code = lang_tag.strip().split(";")[0].split("-")[0]
            if code == "en":
                return "en"
            if code == "fa":
                return "fa"

    return "fa"