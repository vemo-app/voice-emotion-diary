from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from app.core.config import settings
from app.api.v1.router import api_router
from app.db import base  # noqa: F401
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title=settings.app_name)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")


@app.get("/")
def health_check():
    return {"status": "ok", "app": settings.app_name}