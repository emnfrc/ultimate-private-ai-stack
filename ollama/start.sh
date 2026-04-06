#!/bin/bash
# =============================================================================
# Ollama Start Script for Railway
# Handles startup, optional model preloading, and graceful shutdown
# =============================================================================

set -e

echo "============================================="
echo "  Ollama LLM Server - Railway Deployment"
echo "============================================="
echo "Host: ${OLLAMA_HOST:-0.0.0.0}"
echo "Port: ${OLLAMA_PORT:-11434}"
echo "Models directory: ${OLLAMA_MODELS:-/root/.ollama/models}"
echo "============================================="

# Start Ollama server in the background
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "[INFO] Waiting for Ollama server to start..."
MAX_RETRIES=30
RETRY_COUNT=0
until curl -sf http://localhost:${OLLAMA_PORT:-11434}/api/tags > /dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "[ERROR] Ollama failed to start after ${MAX_RETRIES} retries."
        exit 1
    fi
    echo "[INFO] Ollama not ready yet... retry ${RETRY_COUNT}/${MAX_RETRIES}"
    sleep 2
done
echo "[INFO] Ollama server is running and healthy."

# Auto-pull a model if OLLAMA_PRELOAD_MODEL is set
if [ -n "${OLLAMA_PRELOAD_MODEL}" ]; then
    echo "[INFO] Preloading model: ${OLLAMA_PRELOAD_MODEL}"
    ollama pull "${OLLAMA_PRELOAD_MODEL}" || echo "[WARN] Failed to preload model ${OLLAMA_PRELOAD_MODEL}"
    echo "[INFO] Model preload complete."
fi

# Graceful shutdown handler
shutdown_handler() {
    echo "[INFO] Shutting down Ollama gracefully..."
    kill -SIGTERM $OLLAMA_PID 2>/dev/null
    wait $OLLAMA_PID
    echo "[INFO] Ollama stopped."
    exit 0
}
trap shutdown_handler SIGTERM SIGINT

# Keep the script running, wait for the Ollama process
wait $OLLAMA_PID
