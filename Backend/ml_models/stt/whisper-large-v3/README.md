# Speech-to-Text Model

This directory contains the Speech-to-Text (STT) model used by the VEMO backend to transcribe users' voice memories into text.

## Model

VEMO uses **Whisper Large V3** for speech recognition.

The model files are not included in this repository because of their large size. They should be downloaded separately and placed in this directory.

Expected model path:

```text
ml_models/stt/whisper-large-v3/
```

The model location is configured through the `STT_MODEL_NAME` environment variable.

## Downloading the Model

The model is publicly available on the Hugging Face Hub. To download it into the expected path, run:

\`\`\`bash
python -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='openai/whisper-large-v3',
    local_dir='./ml_models/stt/whisper-large-v3',
)
"
\`\`\`

The download is approximately 3GB and requires the `huggingface_hub` package (already included in `requirements.txt`).

## Role in VEMO

The STT component converts a user's recorded voice memory into text. The resulting transcription is then passed to an **LLM-based text correction component** to improve the quality and readability of the transcribed text before it is used by other VEMO components.