#!/bin/bash
# Start LLM Server on macOS
# Run this on your macOS M2 Ultra machine

set -e

echo "========================================="
echo "FTM ERP LLM Server Startup (macOS)"
echo "========================================="
echo ""

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVER_SCRIPT="$SCRIPT_DIR/llm-server.py"
VENV_DIR="$HOME/.ftm-llm-env"
FLASK_PORT="${FLASK_PORT:-5000}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Install with: brew install python3"
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Check if mlx-lm is available
if ! python3 -c "import mlx_lm" 2>/dev/null; then
    echo ""
    echo "WARNING: mlx-lm not found"
    echo "Installing mlx-lm and dependencies..."
    echo ""

    # Create virtual environment if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
        echo "Creating virtual environment..."
        python3 -m venv "$VENV_DIR"
    fi

    # Activate virtual environment
    source "$VENV_DIR/bin/activate"

    # Install dependencies
    pip install --upgrade pip
    pip install mlx-lm flask flask-cors requests

    echo "✓ Dependencies installed"
else
    echo "✓ mlx-lm already installed"

    # Activate virtual environment if it exists
    if [ -d "$VENV_DIR" ]; then
        source "$VENV_DIR/bin/activate"
    fi
fi

# Check if Ollama is running
echo ""
echo "Checking Ollama server..."
if curl -s "http://localhost:$OLLAMA_PORT/api/tags" > /dev/null 2>&1; then
    echo "✓ Ollama is running on port $OLLAMA_PORT"
else
    echo "WARNING: Ollama not responding on port $OLLAMA_PORT"
    echo "Starting Ollama..."

    if command -v ollama &> /dev/null; then
        ollama serve &
        sleep 5
        echo "✓ Ollama started"
    else
        echo "ERROR: Ollama not installed"
        echo "Install with: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi
fi

# Check if phind-codellama model is available
echo ""
echo "Checking Ollama models..."
if ollama list | grep -q "phind-codellama:34b-v2-fp16"; then
    echo "✓ phind-codellama:34b-v2-fp16 is available"
else
    echo "WARNING: phind-codellama:34b-v2-fp16 not found"
    echo "Pulling model (this may take a while)..."
    ollama pull phind-codellama:34b-v2-fp16
    echo "✓ Model downloaded"
fi

# Get local IP address for LAN access
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo ""
echo "========================================="
echo "Starting LLM Server"
echo "========================================="
echo "Local access:  http://localhost:$FLASK_PORT"
echo "LAN access:    http://$LOCAL_IP:$FLASK_PORT"
echo ""
echo "Configure rpitex to use: http://$LOCAL_IP:$FLASK_PORT"
echo "========================================="
echo ""

# Export environment variables
export FLASK_HOST="0.0.0.0"
export FLASK_PORT="$FLASK_PORT"
export OLLAMA_HOST="http://localhost:$OLLAMA_PORT"

# Start the server
python3 "$SERVER_SCRIPT"
