"""
Memory extraction script — parses Claude Code session JSONL files to extract
durable memories: decisions, corrections, preferences, connection methods, and tools.

Inspired by Claude Code's extractMemories.ts pattern but implemented as a
standalone script that can run independently of the session.

Usage:
    py memory_extract.py [days_back] [--output-dir memory/]

    days_back: Number of days of sessions to analyze (default: 7)
    --output-dir: Directory to write memory files (default: memory/)
"""

import json
import os
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

# Patterns that indicate durable memories
DECISION_PATTERNS = [
    r"(?:decided|chose|selected|picked|going with|settled on)\s+(?:to\s+)?(.{10,80})",
    r"(?:the (?:right|best|correct) (?:choice|approach|option) is)\s+(.{10,80})",
    r"(?:we'?ll use|let'?s use|using)\s+(.{10,80})\s+(?:for|because|since)",
]

CORRECTION_PATTERNS = [
    r"(?:actually|correction|wrong|no,?\s+it'?s|that'?s not right),?\s*(.{10,80})",
    r"(?:don'?t (?:use|do|say)|never (?:use|do|say))\s+(.{10,80})",
    r"(?:instead of|not|replace)\s+(.{30,80})",
]

PREFERENCE_PATTERNS = [
    r"(?:always|prefer|should|must|make sure to)\s+(.{10,80})",
    r"(?:remember (?:that|to)|keep in mind)\s+(.{10,80})",
]

CONNECTION_PATTERNS = [
    r"(?:(?:ssh|sftp|ftp|http|https|mqtt|ws|wss)://[\w\.\-:]+(?:/\S*)?)",
    r"(?:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?::\d{1,5})?)",
    r"(?:host|server|endpoint|broker|url|address)[:\s]+([\w\.\-]+(?::\d{1,5})?)",
]

TOOL_PATTERNS = [
    r"(?:found|discovered|there'?s also|check out)\s+(.{10,80})",
    r"(?:use|run|try)\s+`([^`]+)`(?:\s+(?:to|for)\s+(.{10,60}))?",
]

# Patterns to EXCLUDE (secrets, ephemeral state)
SECRET_PATTERNS = [
    r"(?:api[_\s]?key|password|secret|token|credential)[:\s=]+\S{8,}",
    r"(?:sk-|pk_|AKIA)[A-Za-z0-9]{20,}",
]


def find_session_files(projects_dir: str, days_back: int = 7) -> list[Path]:
    """Find session JSONL files from the last N days."""
    cutoff = datetime.now() - timedelta(days=days_back)
    sessions = []

    projects_path = Path(projects_dir)
    if not projects_path.exists():
        return sessions

    for jsonl_file in projects_path.rglob("*.jsonl"):
        try:
            mtime = datetime.fromtimestamp(jsonl_file.stat().st_mtime)
            if mtime >= cutoff:
                sessions.append(jsonl_file)
        except (OSError, ValueError):
            continue

    return sorted(sessions, key=lambda f: f.stat().st_mtime, reverse=True)


def extract_text_from_messages(session_path: Path) -> list[str]:
    """Extract text content from user and assistant messages."""
    texts = []

    try:
        with open(session_path, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    msg = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Extract text from message content
                content = msg.get("content", "")
                if isinstance(content, str):
                    texts.append(content)
                elif isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get("type") == "text":
                            texts.append(block.get("text", ""))
                        elif isinstance(block, dict) and block.get("type") == "tool_use":
                            # Extract tool inputs that might contain info
                            inp = block.get("input", {})
                            if isinstance(inp, dict):
                                for v in inp.values():
                                    if isinstance(v, str) and len(v) > 10:
                                        texts.append(v)

                # Also check the message field
                msg_content = msg.get("message", {})
                if isinstance(msg_content, dict):
                    inner = msg_content.get("content", "")
                    if isinstance(inner, str):
                        texts.append(inner)
                    elif isinstance(inner, list):
                        for block in inner:
                            if isinstance(block, dict) and block.get("type") == "text":
                                texts.append(block.get("text", ""))
    except (OSError, UnicodeDecodeError):
        pass

    return texts


def is_secret(text: str) -> bool:
    """Check if text contains a secret."""
    for pattern in SECRET_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False


def extract_memories(texts: list[str]) -> dict[str, list[str]]:
    """Extract memories from text content using pattern matching."""
    memories = {
        "decisions": [],
        "lessons": [],
        "preferences": [],
        "connections": [],
        "tools": [],
    }
    seen = set()

    for text in texts:
        if is_secret(text):
            continue

        # Decision extraction
        for pattern in DECISION_PATTERNS:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                memory = match.group(1).strip()
                if len(memory) > 10 and memory.lower() not in seen:
                    seen.add(memory.lower())
                    memories["decisions"].append(memory)

        # Correction/lesson extraction
        for pattern in CORRECTION_PATTERNS:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                memory = match.group(1).strip()
                if len(memory) > 10 and memory.lower() not in seen:
                    seen.add(memory.lower())
                    memories["lessons"].append(memory)

        # Preference extraction
        for pattern in PREFERENCE_PATTERNS:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                memory = match.group(1).strip()
                if len(memory) > 10 and memory.lower() not in seen:
                    seen.add(memory.lower())
                    memories["preferences"].append(memory)

        # Connection extraction
        for pattern in CONNECTION_PATTERNS:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                memory = match.group(0).strip()
                if memory.lower() not in seen:
                    seen.add(memory.lower())
                    memories["connections"].append(memory)

        # Tool discovery extraction
        for pattern in TOOL_PATTERNS:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                memory = match.group(0).strip()
                if len(memory) > 10 and memory.lower() not in seen:
                    seen.add(memory.lower())
                    memories["tools"].append(memory)

    return memories


def read_existing_memories(output_dir: Path) -> dict[str, set[str]]:
    """Read existing memory entries to avoid duplicates."""
    existing = {}
    file_map = {
        "decisions": "decisions.md",
        "lessons": "lessons.md",
        "preferences": "preferences.md",
        "connections": "connections.md",
        "tools": "tools.md",
    }

    for topic, filename in file_map.items():
        filepath = output_dir / filename
        if filepath.exists():
            try:
                content = filepath.read_text(encoding="utf-8")
                # Extract existing entries (lines starting with -)
                entries = set()
                for line in content.splitlines():
                    line = line.strip()
                    if line.startswith("- ") and not line.startswith("<!--"):
                        entries.add(line[2:].strip().lower())
                existing[topic] = entries
            except OSError:
                existing[topic] = set()
        else:
            existing[topic] = set()

    return existing


def write_memories(memories: dict[str, list[str]], output_dir: Path) -> list[str]:
    """Write extracted memories to topic files. Returns list of files updated."""
    output_dir.mkdir(parents=True, exist_ok=True)
    existing = read_existing_memories(output_dir)
    updated_files = []

    file_map = {
        "decisions": ("decisions.md", "Decisions"),
        "lessons": ("lessons.md", "Lessons"),
        "preferences": ("preferences.md", "Preferences"),
        "connections": ("connections.md", "Connections"),
        "tools": ("tools.md", "Tools"),
    }

    timestamp = datetime.now().strftime("%Y-%m-%d")

    for topic, (filename, title) in file_map.items():
        new_entries = []
        for memory in memories[topic]:
            if memory.lower() not in existing.get(topic, set()):
                new_entries.append(f"- {timestamp}: {memory}")

        if new_entries:
            filepath = output_dir / filename
            if filepath.exists():
                content = filepath.read_text(encoding="utf-8")
                # Append before the first HTML comment or at end
                insert_point = content.find("<!--")
                if insert_point > 0:
                    # Find the start of that line
                    line_start = content.rfind("\n", 0, insert_point)
                    if line_start < 0:
                        line_start = insert_point
                    content = (
                        content[:line_start]
                        + "\n"
                        + "\n".join(new_entries)
                        + content[line_start:]
                    )
                else:
                    content = content.rstrip() + "\n" + "\n".join(new_entries) + "\n"
            else:
                content = f"# {title}\n\n" + "\n".join(new_entries) + "\n"

            filepath.write_text(content, encoding="utf-8")
            updated_files.append(filename)

    return updated_files


def update_index(output_dir: Path, updated_files: list[str]):
    """Update MEMORY.md index with last-extracted timestamp."""
    index_path = output_dir / "MEMORY.md"
    if not index_path.exists():
        return

    content = index_path.read_text(encoding="utf-8")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")

    # Update or add the "last extracted" line
    if "Last extracted:" in content:
        content = re.sub(
            r"- Last extracted:.*",
            f"- Last extracted: {timestamp} ({', '.join(updated_files)})",
            content,
        )
    else:
        # Add after "## Current State" section
        if "## Current State" in content:
            content = content.replace(
                "## Current State",
                f"## Current State\n\n- Last extracted: {timestamp} ({', '.join(updated_files)})",
                1,
            )

    index_path.write_text(content, encoding="utf-8")


def main():
    days_back = 7
    output_dir = Path("memory/")

    args = sys.argv[1:]
    for i, arg in enumerate(args):
        if arg == "--output-dir" and i + 1 < len(args):
            output_dir = Path(args[i + 1])
        elif arg.isdigit():
            days_back = int(arg)

    # Find Claude Code session files
    # Try common locations
    home = Path.home()
    possible_dirs = [
        home / ".claude" / "projects",
        home / ".config" / "claude" / "projects",
    ]

    session_files = []
    for projects_dir in possible_dirs:
        if projects_dir.exists():
            session_files = find_session_files(str(projects_dir), days_back)
            if session_files:
                break

    if not session_files:
        print("No session files found in the last", days_back, "days")
        return

    print(f"Found {len(session_files)} session file(s) from the last {days_back} days")

    # Extract text from all sessions
    all_texts = []
    for session_path in session_files:
        texts = extract_text_from_messages(session_path)
        all_texts.extend(texts)

    print(f"Extracted {len(all_texts)} text blocks from sessions")

    # Extract memories using pattern matching
    memories = extract_memories(all_texts)

    total = sum(len(v) for v in memories.values())
    print(f"Found {total} potential memories:")
    for topic, entries in memories.items():
        if entries:
            print(f"  {topic}: {len(entries)}")

    if total == 0:
        print("No new memories to write")
        return

    # Write to files
    updated = write_memories(memories, output_dir)

    if updated:
        print(f"Updated: {', '.join(updated)}")
        update_index(output_dir, updated)
        print("Index updated")
    else:
        print("No new memories (all were duplicates)")


if __name__ == "__main__":
    main()
