# syntax=docker/dockerfile:1
FROM nvidia/cuda:13.1.1-runtime-ubuntu22.04

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FISH_SPEECH_HOST=0.0.0.0 \
    FISH_SPEECH_PORT=8080 \
    LOG_LEVEL=INFO \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg git curl python3-pip python3-dev build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python

RUN git clone --depth 1 https://github.com/fishaudio/fish-speech.git /app/engine \
    && rm -rf /app/engine/.git

WORKDIR /app/engine

RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install --upgrade pip && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip3 install -r requirements.txt huggingface_hub

RUN useradd -m -s /bin/bash fishuser && chown -R fishuser:fishuser /app
USER fishuser

VOLUME ["/app/engine/checkpoints", "/app/engine/references"]
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -sf http://localhost:8080/ || exit 1

COPY --chown=fishuser:fishuser docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["python3", "-m", "tools.api"]
