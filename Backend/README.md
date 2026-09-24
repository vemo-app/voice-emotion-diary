# VEMO Backend

This directory contains the backend implementation of **VEMO**, an AI-powered voice diary application developed as a Bachelor's thesis project.

The backend is responsible for handling the application's API, database operations, user memories, machine learning model integration, background processing, authentication, and communication with external AI services.

## Architecture

The backend is organized into several components:

```text
Backend/
├── app/
│   ├── api/
│   ├── core/
│   ├── db/
│   ├── schemas/
│   ├── services/
│   └── workers/
│
├── alembic/
│   └── versions/
│
├── media/
│   ├── voice_notes/
│   │   └── .gitkeep
│   └── images/
│       └── .gitkeep
│
├── ml_models/
│   ├── stt/
│   │   ├── whisper-large-v3/
│   │   │   └── .gitkeep
│   │   └── README.md
│   ├── voice_emotion/
│   │   ├── phase1/
│   │   │   └── README.md
│   │   └── phase2/
│   │       └── README.md
│   └── text_emotion/
│       ├── emotion_xlm_roberta_final/
│       │   └── .gitkeep
│       └── README.md
│
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

## Main Components

### `app/`

Contains the main backend application code.

* **`api/`** — API routes and endpoints used by the frontend.
* **`core/`** — Core application configuration, security, authentication, and shared settings.
* **`db/`** — Database configuration, models, and database-related functionality.
* **`schemas/`** — Data validation and serialization schemas.
* **`services/`** — Application services and the main business logic, including AI and memory-processing workflows.
* **`workers/`** — Background tasks and asynchronous processing.

### `alembic/`

Contains database migration scripts used to manage changes to the database schema.

### `media/`

Used for storing user-generated memory files during local development and deployment.

```text
media/
├── voice_notes/
└── images/
```

Actual user voice recordings and images are not included in the public repository.

### `ml_models/`

Contains the expected local directory structure for the machine learning models used by the backend.

The main model components are:

* **Speech-to-Text:** Whisper Large V3
* **Speech Emotion Recognition:** Wav2Vec2-based encoder + Logistic Regression classifier
* **Text Emotion Recognition:** XLM-RoBERTa

Due to their large size, model weights are not committed to this repository. The relevant model artifacts are hosted separately.

## AI Processing Pipeline

For each voice memory, the backend runs two independent paths in the background: one that analyzes the raw audio signal directly, and one that turns the audio into text and analyzes that text. Neither path waits for the other to finish.

```text
Voice Memory
     │
     ├──────────────────────────────┐
     ▼                              ▼
Speech Emotion                Speech-to-Text
Recognition                   (Whisper Large V3)
(runs directly on audio,            │
 independent of text)               ▼
     │                        LLM-based Text
     │                        Correction
     │                              │
     │                              ▼
     │                        Text Emotion
     │                        Recognition
     │                               │
     └───────────────┬───────────────┘
                     ▼
           Raw Emotion Scores
        (stored separately per model,
           not merged at this stage)
                     │
                     ▼
      Combined on demand — when a memory
      is viewed, when a daily/weekly/monthly
      report is requested, or when an
      empathetic response is generated
```

Generating an empathetic response for a memory is a separate, user-triggered operation: it is only executed when the user explicitly requests feedback for a specific memory, not automatically as part of the pipeline above. The same on-demand approach is used for weekly and monthly narrative trend analysis.

The backend stores the resulting memory data and raw emotion scores, and exposes the endpoints required to combine them into daily, weekly, and monthly emotional trend reports.

## Configuration

Environment-specific settings are configured through environment variables.

Create a local `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

The configuration includes settings for:

* Database connection
* Media storage
* Speech-to-Text model path
* Speech emotion model paths
* Text emotion model path
* JWT authentication
* LLM API configuration

## Machine Learning Models

The backend expects the model directories to be available locally.

For example:

```text
ml_models/
├── stt/
│   └── whisper-large-v3/
│
├── voice_emotion/
│   ├── phase1/
│   └── phase2/
│
└── text_emotion/
    └── emotion_xlm_roberta_final/
```
Both the speech emotion recognition and text emotion recognition models are available through the project's Hugging Face repository. The Whisper STT model is downloaded directly from its public Hugging Face model page. See the README.md file inside each ml_models/ subdirectory for exact download instructions and the corresponding environment variable.

## Database Migrations

Database schema changes are managed using **Alembic**.

After configuring the database, migrations can be applied with:

```bash
alembic upgrade head
```

New migrations can be generated when the database models are changed:

```bash
alembic revision --autogenerate -m "description of the change"
```
## System Requirements

In addition to Python and the packages listed in `requirements.txt`, `ffmpeg` must be installed on the system. It is required by the audio-loading fallback path used for compressed formats such as m4a and mp3:

```bash
# Ubuntu / Debian
sudo apt install ffmpeg
```

## Installation

Clone the repository and navigate to the backend directory:

```bash
cd Backend
```

Create and activate a Python virtual environment:

```bash
python -m venv .venv
```

Activate it:

```bash
# On Windows
.venv\Scripts\activate

# On macOS / Linux
source .venv/bin/activate
```

Install the required dependencies:

```bash
pip install -r requirements.txt
```

Then configure the required environment variables in `.env`, and download the machine learning models.

## Running the Backend

Running the backend requires two processes: the API server and the Celery worker that handles background processing of voice memories.

```bash
# Terminal 1 — API server
uvicorn app.main:app --reload

# Terminal 2 — Celery worker (requires Redis to be running)
celery -A app.workers.celery_app worker --loglevel=info
```

The exact commands may vary depending on the configured application entry point and Redis connection settings.

## Privacy

VEMO processes personal voice recordings and images as user-generated memories. These files are intended to be handled by the application and are **not included in the public GitHub repository**.

The real-world speech samples collected during the development of the Speech Emotion Recognition model are also not publicly released due to privacy considerations.

## Related Components

For details about the machine learning development process, see:

* `Speech_Emotion_Recognition/` — Speech emotion recognition experiments and model development
* `Text_Emotion_Recognition/` — Text emotion recognition experiments and model development

The main project documentation is available in the root `README.md`.
