# DeepWiki with Ollama - Local Setup Guide

This guide explains how to run DeepWiki using your local Ollama installation with Podman.

## Prerequisites

- ✅ Ollama running as systemd service
- ✅ Podman installed
- ✅ Required Ollama models downloaded

## Quick Start

### Option 1: Using the Easy Run Script (Recommended)

```bash
./run-with-ollama.sh
```

This script will:
- Check if Ollama is running
- Download required models if missing
- Build the container if needed
- Start DeepWiki with proper configuration

### Option 2: Manual Steps

1. **Ensure Ollama is running:**
   ```bash
   systemctl status ollama
   curl http://localhost:11434/api/tags
   ```

2. **Download required models:**
   ```bash
   ollama pull nomic-embed-text
   ollama pull qwen3:8b
   ```

3. **Build the container:**
   ```bash
   podman-compose -f docker-compose.ollama.yml build
   ```

4. **Run the container:**
   ```bash
   podman run --rm --name deepwiki-ollama \
       --network host \
       -v ~/.adalflow:/root/.adalflow \
       -v $(pwd)/api/logs:/app/api/logs \
       -v $(pwd)/.env:/app/.env \
       -e OLLAMA_HOST=http://localhost:11434 \
       deepwiki-open_deepwiki-ollama \
       bash -c "
           ollama serve > /dev/null 2>&1 &
           sleep 10
           python -m api.main --port 8001 &
           PORT=3000 HOSTNAME=0.0.0.0 node server.js
       "
   ```

## Configuration

### Environment Variables (.env)
```
PORT=8001
OLLAMA_HOST=http://localhost:11434
```

### Embedder Configuration (api/config/embedder.json)
```json
{
  "embedder": {
    "client_class": "OllamaClient",
    "model_kwargs": {
      "model": "nomic-embed-text"
    }
  },
  "retriever": {
    "top_k": 20
  },
  "text_splitter": {
    "split_by": "word",
    "chunk_size": 350,
    "chunk_overlap": 100
  }
}
```

## Usage

1. **Access the web interface:** http://localhost:3000
2. **Enter a GitHub repository URL** (e.g., https://github.com/microsoft/autogen)
3. **Select "Use Local Ollama Model"** in the interface
4. **Choose your preferred model** (qwen3:8b is recommended)
5. **Click "Generate Wiki"**

## Available Models

The system supports any Ollama model you have installed:
- **qwen3:8b** - Good balance of speed and quality (recommended)
- **llama3:8b** - Alternative option
- **gemma3:4b** - Faster but smaller model

## Troubleshooting

### Container Issues
- **Container exits immediately:** Check that Ollama is running on the host
- **Permission errors:** Ensure ~/.adalflow directory exists and is writable
- **Port conflicts:** Make sure ports 3000 and 8001 are available

### Ollama Issues
- **Model not found:** Run `ollama pull <model-name>` to download
- **Connection refused:** Verify Ollama service is running: `systemctl status ollama`
- **Slow performance:** Consider using a smaller model or adding more RAM

### Performance Tips
- **Use SSD storage** for better model loading times
- **Allocate sufficient RAM** (8GB+ recommended)
- **Use smaller models** for faster processing if quality is acceptable

## File Structure

```
deepwiki-open/
├── .env                           # Environment configuration
├── docker-compose.ollama.yml      # Podman compose for Ollama setup
├── run-with-ollama.sh            # Easy run script
├── api/config/embedder.json      # Ollama embedder configuration
└── README-OLLAMA-SETUP.md        # This file
```

## Success Indicators

When running correctly, you should see:
- ✅ "Ollama model 'nomic-embed-text' is available"
- ✅ "Starting Streaming API on port 8001"
- ✅ "Next.js ready on http://localhost:3000"
- ✅ No API key warnings (since we're using Ollama only)

## Stopping the Application

Press `Ctrl+C` in the terminal or run:
```bash
podman stop deepwiki-ollama
```

## Data Persistence

Your data is stored in:
- **Repositories:** ~/.adalflow/repos/
- **Embeddings:** ~/.adalflow/databases/
- **Generated wikis:** ~/.adalflow/wikicache/
- **Logs:** ./api/logs/

This ensures your work persists between container restarts.
