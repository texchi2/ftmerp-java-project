#!/usr/bin/env python3
"""
FTM ERP LLM Server - macOS
Flask API server for MLX-LM and Ollama models
Provides unified interface for code completion, FIM, reasoning, and refactoring
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import json
import os
from typing import Dict, List, Optional
import logging

# MLX-LM integration
try:
    from mlx_lm import load, generate
    MLX_AVAILABLE = True
except ImportError:
    MLX_AVAILABLE = False
    print("Warning: mlx_lm not available. Install with: pip install mlx-lm")

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Model configurations
MODELS = {
    "llama-scout": {
        "type": "mlx",
        "path": "mlx-community/Llama-4-Scout-17B-16E-Instruct-8bit",
        "use_case": "reasoning",
        "loaded": False,
        "model": None,
        "tokenizer": None
    },
    "codellama-70b": {
        "type": "mlx",
        "path": "mlx-community/CodeLlama-70b-Instruct-hf-4bit-MLX",
        "use_case": "code_generation",
        "loaded": False,
        "model": None,
        "tokenizer": None
    },
    "phind-codellama": {
        "type": "ollama",
        "name": "phind-codellama:34b-v2-fp16",
        "use_case": "code_completion",
        "ollama_host": "http://localhost:11434"
    }
}

# Ollama configuration
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")


def load_mlx_model(model_key: str) -> bool:
    """Load MLX model into memory"""
    if not MLX_AVAILABLE:
        logger.error("MLX-LM not available")
        return False

    if MODELS[model_key]["loaded"]:
        return True

    try:
        model_path = MODELS[model_key]["path"]
        logger.info(f"Loading MLX model: {model_path}")
        model, tokenizer = load(model_path)
        MODELS[model_key]["model"] = model
        MODELS[model_key]["tokenizer"] = tokenizer
        MODELS[model_key]["loaded"] = True
        logger.info(f"Successfully loaded: {model_key}")
        return True
    except Exception as e:
        logger.error(f"Error loading {model_key}: {str(e)}")
        return False


def generate_mlx(model_key: str, prompt: str, max_tokens: int = 500,
                 temperature: float = 0.7) -> str:
    """Generate text using MLX model"""
    if not MODELS[model_key]["loaded"]:
        if not load_mlx_model(model_key):
            return f"Error: Failed to load {model_key}"

    try:
        model = MODELS[model_key]["model"]
        tokenizer = MODELS[model_key]["tokenizer"]

        response = generate(
            model,
            tokenizer,
            prompt=prompt,
            max_tokens=max_tokens,
            temp=temperature,
            verbose=False
        )
        return response
    except Exception as e:
        logger.error(f"Error generating with {model_key}: {str(e)}")
        return f"Error: {str(e)}"


def generate_ollama(model_name: str, prompt: str, max_tokens: int = 500,
                    temperature: float = 0.7) -> str:
    """Generate text using Ollama"""
    try:
        response = requests.post(
            f"{OLLAMA_HOST}/api/generate",
            json={
                "model": model_name,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens
                }
            },
            timeout=120
        )
        response.raise_for_status()
        return response.json().get("response", "")
    except Exception as e:
        logger.error(f"Error with Ollama: {str(e)}")
        return f"Error: {str(e)}"


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    status = {
        "status": "healthy",
        "models": {}
    }

    for key, config in MODELS.items():
        if config["type"] == "mlx":
            status["models"][key] = {
                "type": "mlx",
                "loaded": config["loaded"],
                "use_case": config["use_case"]
            }
        else:
            # Check Ollama availability
            try:
                r = requests.get(f"{OLLAMA_HOST}/api/tags", timeout=5)
                ollama_available = r.status_code == 200
            except:
                ollama_available = False

            status["models"][key] = {
                "type": "ollama",
                "available": ollama_available,
                "use_case": config["use_case"]
            }

    return jsonify(status)


@app.route('/complete', methods=['POST'])
def code_completion():
    """
    Code completion endpoint
    Supports both standard completion and Fill-in-the-Middle (FIM)
    """
    data = request.json
    code_before = data.get('prefix', '')
    code_after = data.get('suffix', '')
    language = data.get('language', 'java')
    model = data.get('model', 'phind-codellama')  # Default to fast model
    max_tokens = data.get('max_tokens', 200)

    # Determine if this is FIM or standard completion
    is_fim = bool(code_after)

    if is_fim:
        # Fill-in-the-Middle prompt format
        prompt = f"""<PRE> {code_before} <SUF> {code_after} <MID>"""
    else:
        # Standard completion
        prompt = f"""Complete the following {language} code:

{code_before}

Continue the code implementation:"""

    # Route to appropriate model
    if model == "phind-codellama":
        result = generate_ollama(
            MODELS["phind-codellama"]["name"],
            prompt,
            max_tokens=max_tokens,
            temperature=0.2  # Lower temp for code
        )
    elif model == "codellama-70b":
        result = generate_mlx("codellama-70b", prompt, max_tokens=max_tokens, temperature=0.2)
    else:
        return jsonify({"error": f"Unknown model: {model}"}), 400

    return jsonify({
        "completion": result,
        "model": model,
        "type": "fim" if is_fim else "completion"
    })


@app.route('/explain', methods=['POST'])
def explain_code():
    """Explain code snippet"""
    data = request.json
    code = data.get('code', '')
    language = data.get('language', 'java')

    prompt = f"""Explain the following {language} code in detail.
Focus on:
1. What the code does
2. Key design patterns used
3. Potential issues or improvements
4. How it fits in an ERP system context

Code:
```{language}
{code}
```

Explanation:"""

    # Use reasoning model
    result = generate_mlx("llama-scout", prompt, max_tokens=800, temperature=0.3)

    return jsonify({
        "explanation": result,
        "model": "llama-scout"
    })


@app.route('/refactor', methods=['POST'])
def refactor_code():
    """Refactor code with improvements"""
    data = request.json
    code = data.get('code', '')
    language = data.get('language', 'java')
    instructions = data.get('instructions', 'Improve code quality, readability, and performance')

    prompt = f"""Refactor the following {language} code.

Instructions: {instructions}

Original code:
```{language}
{code}
```

Provide:
1. Refactored code
2. Explanation of changes
3. Benefits of the refactoring

Refactored code:"""

    # Use code generation model
    result = generate_mlx("codellama-70b", prompt, max_tokens=1000, temperature=0.3)

    return jsonify({
        "refactored": result,
        "model": "codellama-70b"
    })


@app.route('/reason', methods=['POST'])
def reasoning():
    """
    Advanced reasoning for architectural decisions, debugging, etc.
    """
    data = request.json
    question = data.get('question', '')
    context = data.get('context', '')

    prompt = f"""You are an expert in Apache OFBiz ERP systems and enterprise Java development.

Context: {context}

Question: {question}

Provide a detailed, reasoned response with:
1. Analysis of the situation
2. Recommended approach
3. Step-by-step implementation plan
4. Potential pitfalls to avoid

Response:"""

    # Use reasoning model
    result = generate_mlx("llama-scout", prompt, max_tokens=1500, temperature=0.5)

    return jsonify({
        "response": result,
        "model": "llama-scout"
    })


@app.route('/generate', methods=['POST'])
def generate_code():
    """
    Generate new code from description
    """
    data = request.json
    description = data.get('description', '')
    language = data.get('language', 'java')
    framework = data.get('framework', 'OFBiz')

    prompt = f"""Generate {language} code for {framework}.

Requirements:
{description}

Generate well-structured, documented code following {framework} best practices.

Code:"""

    # Use code generation model
    result = generate_mlx("codellama-70b", prompt, max_tokens=1500, temperature=0.4)

    return jsonify({
        "code": result,
        "model": "codellama-70b",
        "language": language
    })


@app.route('/chat', methods=['POST'])
def chat():
    """
    General chat endpoint for interactive assistance
    """
    data = request.json
    messages = data.get('messages', [])
    model = data.get('model', 'llama-scout')

    # Convert messages to prompt
    prompt = ""
    for msg in messages:
        role = msg.get('role', 'user')
        content = msg.get('content', '')
        prompt += f"{role.capitalize()}: {content}\n"

    prompt += "Assistant: "

    # Route to appropriate model
    if model in ["llama-scout", "codellama-70b"]:
        result = generate_mlx(model, prompt, max_tokens=1000, temperature=0.6)
    elif model == "phind-codellama":
        result = generate_ollama(
            MODELS["phind-codellama"]["name"],
            prompt,
            max_tokens=1000,
            temperature=0.6
        )
    else:
        return jsonify({"error": f"Unknown model: {model}"}), 400

    return jsonify({
        "response": result,
        "model": model
    })


@app.route('/models', methods=['GET'])
def list_models():
    """List available models and their status"""
    models_status = {}

    for key, config in MODELS.items():
        models_status[key] = {
            "type": config["type"],
            "use_case": config["use_case"],
            "loaded": config.get("loaded", False) if config["type"] == "mlx" else None,
            "name": config.get("name") if config["type"] == "ollama" else config.get("path")
        }

    return jsonify({"models": models_status})


@app.route('/preload', methods=['POST'])
def preload_models():
    """Preload MLX models into memory"""
    data = request.json
    models_to_load = data.get('models', ['llama-scout', 'codellama-70b'])

    results = {}
    for model_key in models_to_load:
        if model_key in MODELS and MODELS[model_key]["type"] == "mlx":
            success = load_mlx_model(model_key)
            results[model_key] = "loaded" if success else "failed"
        else:
            results[model_key] = "not found or not mlx model"

    return jsonify({"results": results})


if __name__ == '__main__':
    # Get configuration from environment
    host = os.getenv('FLASK_HOST', '0.0.0.0')
    port = int(os.getenv('FLASK_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'false').lower() == 'true'

    logger.info("=" * 60)
    logger.info("FTM ERP LLM Server Starting")
    logger.info("=" * 60)
    logger.info(f"Host: {host}")
    logger.info(f"Port: {port}")
    logger.info(f"Ollama Host: {OLLAMA_HOST}")
    logger.info("=" * 60)
    logger.info("Available endpoints:")
    logger.info("  GET  /health       - Health check")
    logger.info("  GET  /models       - List models")
    logger.info("  POST /preload      - Preload MLX models")
    logger.info("  POST /complete     - Code completion (FIM supported)")
    logger.info("  POST /explain      - Explain code")
    logger.info("  POST /refactor     - Refactor code")
    logger.info("  POST /reason       - Advanced reasoning")
    logger.info("  POST /generate     - Generate new code")
    logger.info("  POST /chat         - Interactive chat")
    logger.info("=" * 60)

    app.run(host=host, port=port, debug=debug)
