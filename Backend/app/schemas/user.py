import uuid
from datetime import datetime
from pydantic import BaseModel, EmailStr

from typing import Literal

ThemeOption = Literal["default", "dark", "light"]
LanguageOption = Literal["default", "fa", "en"]

class UserRegister(BaseModel):
    username: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: uuid.UUID
    username: str
    email: EmailStr
    created_at: datetime
    joined_month_label: str
    theme: str
    language: str

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserRegisterResponse(BaseModel):
    user: UserResponse
    access_token: str
    token_type: str = "bearer"

class UserUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None
    theme: ThemeOption | None = None
    language: LanguageOption | None = None


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class ProfileSummaryResponse(BaseModel):
    total_notes: int
    scored_notes_count: int
    anger: float
    happiness: float
    sadness: float
    neutral: float