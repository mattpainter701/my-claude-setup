"""Perplexity Sonar API wrapper for the research skill.

Usage:
    py ~/.claude/scripts/perplexity_search.py "query" [--domains d1,d2] [--recency hour|day|week|month] [--model sonar-pro] [--max-tokens 2048]
    py ~/.claude/scripts/perplexity_search.py --search-api "query" [--max-results 10]

Returns JSON to stdout with content, citations, and usage stats.
Loads PERPLEXITY_API_KEY from ~/.config/secrets.env or environment.
"""

import argparse
import json
import os
import sys
from pathlib import Path


def load_api_key():
    """Load API key from environment or secrets file."""
    key = os.environ.get("PERPLEXITY_API_KEY", "")
    if key:
        return key

    secrets_path = Path.home() / ".config" / "secrets.env"
    if secrets_path.exists():
        for line in secrets_path.read_text(encoding="utf-8").splitlines():
            line = line.strip().replace("\r", "")
            if line.startswith("PERPLEXITY_API_KEY=") and not line.startswith("#"):
                return line.split("=", 1)[1].strip()

    return ""


def chat_completions(query, domains=None, recency=None, model="sonar-pro", max_tokens=2048):
    """Call Perplexity Chat Completions API (sonar-pro default)."""
    import urllib.error
    import urllib.request

    api_key = load_api_key()
    if not api_key:
        return {"error": "No PERPLEXITY_API_KEY found in environment or ~/.config/secrets.env"}

    body = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": "Be precise, technical, and cite sources. Include specific numbers, dates, and implementation details.",
            },
            {"role": "user", "content": query},
        ],
        "temperature": 0.2,
        "max_tokens": max_tokens,
    }
    if domains:
        body["search_domain_filter"] = domains
    if recency:
        body["search_recency_filter"] = recency

    req = urllib.request.Request(
        "https://api.perplexity.ai/chat/completions",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")
        return {"error": f"HTTP {e.code}: {error_body}"}
    except Exception as e:
        return {"error": str(e)}

    # Extract structured result
    content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
    citations = data.get("citations", [])
    usage = data.get("usage", {})

    return {
        "content": content,
        "citations": citations,
        "model": data.get("model", model),
        "tokens_in": usage.get("prompt_tokens", 0),
        "tokens_out": usage.get("completion_tokens", 0),
        "query": query,
        "domains": domains,
        "recency": recency,
    }


def search_api(query, max_results=10, domains=None):
    """Call Perplexity Search API (raw results, no AI synthesis)."""
    import urllib.error
    import urllib.request

    api_key = load_api_key()
    if not api_key:
        return {"error": "No PERPLEXITY_API_KEY found in environment or ~/.config/secrets.env"}

    body = {"query": query, "max_results": max_results}
    if domains:
        body["search_domain_filter"] = domains

    req = urllib.request.Request(
        "https://api.perplexity.ai/search",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")
        return {"error": f"HTTP {e.code}: {error_body}"}
    except Exception as e:
        return {"error": str(e)}

    return {
        "results": data.get("results", []),
        "id": data.get("id", ""),
        "query": query,
    }


def main():
    parser = argparse.ArgumentParser(description="Perplexity API wrapper")
    parser.add_argument("query", help="Search query")
    parser.add_argument(
        "--search-api", action="store_true", help="Use Search API instead of Chat Completions"
    )
    parser.add_argument("--domains", help="Comma-separated domain filter (e.g., arxiv.org,ti.com)")
    parser.add_argument(
        "--recency", choices=["hour", "day", "week", "month"], help="Recency filter"
    )
    parser.add_argument("--model", default="sonar-pro", help="Model (default: sonar-pro)")
    parser.add_argument(
        "--max-tokens", type=int, default=2048, help="Max output tokens (default: 2048)"
    )
    parser.add_argument(
        "--max-results", type=int, default=10, help="Max results for Search API (default: 10)"
    )

    args = parser.parse_args()
    domains = [d.strip() for d in args.domains.split(",")] if args.domains else None

    if args.search_api:
        result = search_api(args.query, max_results=args.max_results, domains=domains)
    else:
        result = chat_completions(
            args.query,
            domains=domains,
            recency=args.recency,
            model=args.model,
            max_tokens=args.max_tokens,
        )

    json.dump(result, sys.stdout, indent=2, ensure_ascii=False)
    print()


if __name__ == "__main__":
    main()
