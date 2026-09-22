from dotenv import load_dotenv
load_dotenv()

from celery import Celery
from app.db import base  # noqa: F401

celery_app = Celery(
    "voice_diary",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1",
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
)

celery_app.autodiscover_tasks(["app.workers"])