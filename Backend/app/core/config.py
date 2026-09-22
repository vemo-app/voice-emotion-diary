from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Voice Diary API"
    database_url: str = "postgresql://user:password@localhost:5432/voice_diary"
    audio_storage_path: str = "./media/voice_notes"
    jwt_secret_key: str = "change-this-to-a-random-secret"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60 * 24 * 30
    llm_api_key: str = ""
    llm_base_url: str = "https://api.gapgpt.app/v1"
    llm_chat_model: str = "gpt-4o-mini"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()