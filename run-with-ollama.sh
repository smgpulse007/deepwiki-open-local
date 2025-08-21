#!/bin/bash

# DeepWiki with Ollama - Easy Run Script
# This script runs DeepWiki using your local Ollama installation

echo "🚀 Starting DeepWiki with Ollama..."

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "❌ Ollama is not running on localhost:11434"
    echo "Please start Ollama first: sudo systemctl start ollama"
    exit 1
fi

echo "✅ Ollama is running"

# Check if required models are available
if ! ollama list | grep -q "nomic-embed-text"; then
    echo "📥 Downloading required embedding model..."
    ollama pull nomic-embed-text
fi

if ! ollama list | grep -q "qwen3"; then
    echo "📥 Downloading required generation model..."
    ollama pull qwen3:8b
fi

echo "✅ Required models are available"

# Build the container if it doesn't exist
if ! podman images | grep -q "deepwiki-open_deepwiki-ollama"; then
    echo "🔨 Building DeepWiki container..."
    podman-compose -f docker-compose.ollama.yml build
fi

echo "🐳 Starting DeepWiki container..."

# Run the container with the updated command
podman run --rm --name deepwiki-ollama \
    --network host \
    -v ~/.adalflow:/root/.adalflow \
    -v $(pwd)/api/logs:/app/api/logs \
    -v $(pwd)/.env:/app/.env \
    -v /nfs/workbench/home/adm_i12085/source:/app/local-repos \
    -e OLLAMA_HOST=http://localhost:11434 \
    deepwiki-open_deepwiki-ollama \
    bash -c "
        echo 'Starting Ollama inside container...'
        ollama serve > /dev/null 2>&1 &
        sleep 10
        echo 'Starting DeepWiki API...'
        python -m api.main --port 8001 &
        echo 'Starting DeepWiki Frontend...'
        PORT=3000 HOSTNAME=0.0.0.0 node server.js
    "
