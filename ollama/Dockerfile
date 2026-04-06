# =============================================================================
# Ollama LLM Backend - Optimized Dockerfile for Railway
# =============================================================================
FROM ollama/ollama:latest

LABEL maintainer="Railway Template - Ollama + Open WebUI"
LABEL description="Ollama LLM server with persistent model storage"

# Environment variables with sensible defaults
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_PORT=11434
ENV OLLAMA_MODELS=/root/.ollama/models
ENV OLLAMA_KEEP_ALIVE=5m

# Expose the Ollama API port
EXPOSE ${OLLAMA_PORT}

# Create the persistent volume directory
RUN mkdir -p /root/.ollama/models

# Volume for persistent model storage
VOLUME ["/root/.ollama"]

# Copy and set up the entrypoint script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Healthcheck - verify Ollama API responds
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:${OLLAMA_PORT}/api/tags || exit 1

ENTRYPOINT ["/start.sh"]
