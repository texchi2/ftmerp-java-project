#!/usr/bin/env python3
"""
FTM ERP LLM Client - rpitex
Command-line client to interact with macOS LLM server
"""

import requests
import json
import sys
import os
from typing import Optional, Dict, Any
import argparse


class LLMClient:
    """Client for FTM ERP LLM Server"""

    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')

    def _post(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Make POST request to server"""
        try:
            response = requests.post(
                f"{self.base_url}{endpoint}",
                json=data,
                timeout=120
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            return {"error": str(e)}

    def _get(self, endpoint: str) -> Dict[str, Any]:
        """Make GET request to server"""
        try:
            response = requests.get(f"{self.base_url}{endpoint}", timeout=10)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            return {"error": str(e)}

    def health_check(self) -> Dict[str, Any]:
        """Check server health"""
        return self._get("/health")

    def list_models(self) -> Dict[str, Any]:
        """List available models"""
        return self._get("/models")

    def complete(self, prefix: str, suffix: str = "", language: str = "java",
                 model: str = "phind-codellama", max_tokens: int = 200) -> str:
        """
        Code completion with FIM support

        Args:
            prefix: Code before cursor
            suffix: Code after cursor (for FIM)
            language: Programming language
            model: Model to use
            max_tokens: Maximum tokens to generate

        Returns:
            Completed code
        """
        data = {
            "prefix": prefix,
            "suffix": suffix,
            "language": language,
            "model": model,
            "max_tokens": max_tokens
        }
        result = self._post("/complete", data)
        return result.get("completion", result.get("error", ""))

    def explain(self, code: str, language: str = "java") -> str:
        """Explain code snippet"""
        data = {
            "code": code,
            "language": language
        }
        result = self._post("/explain", data)
        return result.get("explanation", result.get("error", ""))

    def refactor(self, code: str, language: str = "java",
                 instructions: str = "") -> str:
        """Refactor code"""
        data = {
            "code": code,
            "language": language,
            "instructions": instructions or "Improve code quality, readability, and performance"
        }
        result = self._post("/refactor", data)
        return result.get("refactored", result.get("error", ""))

    def reason(self, question: str, context: str = "") -> str:
        """Advanced reasoning"""
        data = {
            "question": question,
            "context": context
        }
        result = self._post("/reason", data)
        return result.get("response", result.get("error", ""))

    def generate(self, description: str, language: str = "java",
                 framework: str = "OFBiz") -> str:
        """Generate new code"""
        data = {
            "description": description,
            "language": language,
            "framework": framework
        }
        result = self._post("/generate", data)
        return result.get("code", result.get("error", ""))

    def chat(self, message: str, model: str = "llama-scout",
             history: list = None) -> str:
        """Interactive chat"""
        messages = history or []
        messages.append({"role": "user", "content": message})

        data = {
            "messages": messages,
            "model": model
        }
        result = self._post("/chat", data)
        return result.get("response", result.get("error", ""))


def main():
    parser = argparse.ArgumentParser(description="FTM ERP LLM Client")
    parser.add_argument(
        '--server',
        default=os.getenv('LLM_SERVER_URL', 'http://192.168.1.100:5000'),
        help='LLM server URL'
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # Health check
    subparsers.add_parser('health', help='Check server health')

    # List models
    subparsers.add_parser('models', help='List available models')

    # Complete
    complete_parser = subparsers.add_parser('complete', help='Code completion')
    complete_parser.add_argument('--file', help='File containing code prefix')
    complete_parser.add_argument('--stdin', action='store_true', help='Read from stdin')
    complete_parser.add_argument('--language', default='java', help='Programming language')
    complete_parser.add_argument('--model', default='phind-codellama', help='Model to use')

    # Explain
    explain_parser = subparsers.add_parser('explain', help='Explain code')
    explain_parser.add_argument('--file', help='File containing code')
    explain_parser.add_argument('--stdin', action='store_true', help='Read from stdin')
    explain_parser.add_argument('--language', default='java', help='Programming language')

    # Refactor
    refactor_parser = subparsers.add_parser('refactor', help='Refactor code')
    refactor_parser.add_argument('--file', help='File containing code')
    refactor_parser.add_argument('--stdin', action='store_true', help='Read from stdin')
    refactor_parser.add_argument('--language', default='java', help='Programming language')
    refactor_parser.add_argument('--instructions', help='Refactoring instructions')

    # Reason
    reason_parser = subparsers.add_parser('reason', help='Advanced reasoning')
    reason_parser.add_argument('question', help='Question to answer')
    reason_parser.add_argument('--context', help='Additional context')

    # Generate
    generate_parser = subparsers.add_parser('generate', help='Generate code')
    generate_parser.add_argument('description', help='Code description')
    generate_parser.add_argument('--language', default='java', help='Programming language')
    generate_parser.add_argument('--framework', default='OFBiz', help='Framework')

    # Chat
    chat_parser = subparsers.add_parser('chat', help='Interactive chat')
    chat_parser.add_argument('message', help='Message to send')
    chat_parser.add_argument('--model', default='llama-scout', help='Model to use')

    args = parser.parse_args()

    # Create client
    client = LLMClient(args.server)

    # Execute command
    if args.command == 'health':
        result = client.health_check()
        print(json.dumps(result, indent=2))

    elif args.command == 'models':
        result = client.list_models()
        print(json.dumps(result, indent=2))

    elif args.command == 'complete':
        # Read code
        if args.file:
            with open(args.file, 'r') as f:
                code = f.read()
        elif args.stdin:
            code = sys.stdin.read()
        else:
            print("Error: Provide --file or --stdin")
            sys.exit(1)

        result = client.complete(code, language=args.language, model=args.model)
        print(result)

    elif args.command == 'explain':
        # Read code
        if args.file:
            with open(args.file, 'r') as f:
                code = f.read()
        elif args.stdin:
            code = sys.stdin.read()
        else:
            print("Error: Provide --file or --stdin")
            sys.exit(1)

        result = client.explain(code, language=args.language)
        print(result)

    elif args.command == 'refactor':
        # Read code
        if args.file:
            with open(args.file, 'r') as f:
                code = f.read()
        elif args.stdin:
            code = sys.stdin.read()
        else:
            print("Error: Provide --file or --stdin")
            sys.exit(1)

        result = client.refactor(
            code,
            language=args.language,
            instructions=args.instructions or ""
        )
        print(result)

    elif args.command == 'reason':
        result = client.reason(args.question, context=args.context or "")
        print(result)

    elif args.command == 'generate':
        result = client.generate(
            args.description,
            language=args.language,
            framework=args.framework
        )
        print(result)

    elif args.command == 'chat':
        result = client.chat(args.message, model=args.model)
        print(result)

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
