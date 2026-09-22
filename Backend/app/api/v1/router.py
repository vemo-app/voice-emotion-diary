from fastapi import APIRouter
from app.api.v1.endpoints import voice_notes, reports, auth, users

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(voice_notes.router)
api_router.include_router(reports.router)