#!/bin/bash
set -e

echo "==========================================="
echo "  Fish Speech Server"
echo "==========================================="
echo "  Host:    ${FISH_SPEECH_HOST}"
echo "  Port:    ${FISH_SPEECH_PORT}"
echo "  Python:  $(python3 --version)"
echo "  PyTorch: $(python3 -c 'import torch; print(torch.__version__)' 2>/dev/null || echo 'loading...')"
echo "  CUDA:    $(python3 -c 'import torch; print(torch.version.cuda)' 2>/dev/null || echo 'N/A')"
echo "  GPU:     $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'not detected')"
echo "==========================================="

CHECKPOINT_DIR=/app/engine/checkpoints

if [ -d "$CHECKPOINT_DIR" ] && [ "$(ls -A $CHECKPOINT_DIR 2>/dev/null)" ]; then
    echo "✓ Models found"
    ls "$CHECKPOINT_DIR"
elif [ -n "$HF_TOKEN" ]; then
    echo "→ Downloading fish-speech-1.5..."
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download('fishaudio/fish-speech-1.5', local_dir='$CHECKPOINT_DIR/fish-speech-1.5', token='$HF_TOKEN')
"
else
    echo "⚠ No models. Mount with -v or set HF_TOKEN"
fi

echo "==========================================="
exec python3 -m tools.api --host "${FISH_SPEECH_HOST}" --port "${FISH_SPEECH_PORT}" "$@"
