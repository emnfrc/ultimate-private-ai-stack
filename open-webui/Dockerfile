# =============================================================================
# Open WebUI Frontend - Optimized Dockerfile for Railway
# =============================================================================
FROM ghcr.io/open-webui/open-webui:main

LABEL maintainer="Railway Template - Ollama + Open WebUI"
LABEL description="Open WebUI - ChatGPT-style interface for Ollama"

# Environment variables
ENV OLLAMA_BASE_URL=http://ollama.railway.internal:11434
ENV WEBUI_AUTH=true
ENV WEBUI_SECRET_KEY=change-me-to-a-random-secret
ENV PORT=8080
ENV ENABLE_SIGNUP=true
ENV DEFAULT_MODELS=""
ENV WEBUI_NAME="AI Private Hub"

# Data persistence for user configs, chat history, etc.
VOLUME ["/app/backend/data"]

# Expose the web UI port
EXPOSE ${PORT}

# Healthcheck - verify the web UI is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -f http://localhost:${PORT}/health || curl -f http://localhost:${PORT}/ || exit 1
