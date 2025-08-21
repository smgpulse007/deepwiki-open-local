#!/bin/bash

# Start ollama serve in background
ollama serve > /dev/null 2>&1 &

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
sleep 10

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  export $(grep -v "^#" .env | xargs -r)
fi

echo "Starting DeepWiki with Ollama support..."
echo "Ollama Host: ${OLLAMA_HOST:-http://localhost:11434}"

# Start the API server in the background with the configured port
python -m api.main --port ${PORT:-8001} &

# Start the frontend
PORT=3000 HOSTNAME=0.0.0.0 node server.js &

# Wait for any process to exit
wait -n
exit $?
