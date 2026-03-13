#!/usr/bin/env python3
"""
Session mining script for Claude Code.
Parses session JSONL files and extracts usage patterns.

Usage: py ~/.claude/scripts/session_mine.py [days_back] [project_filter]
"""

import json
import os
import sys
import time
from collections import Counter, defaultdict
from datetime import datetime, timedelta
from pathlib import Path


def find_session_files(projects_dir: Path, days_back: int, project_filter: str = "") -> list[Path]:
    """Find all session JSONL files within the time window."""
    cutoff = time.time() - (days_back * 86400)
    files = []
    for project_dir in projects_dir.iterdir():
        if not project_dir.is_dir():
            continue
        if project_filter and project_filter.lower() not in project_dir.name.lower():
            continue
        for f in project_dir.glob("*.jsonl"):
            if f.stat().st_mtime >= cutoff:
                files.append(f)
    return sorted(files, key=lambda f: f.stat().st_mtime, reverse=True)


def parse_session(filepath: Path) -> dict:
    """Parse a single session JSONL file and extract stats."""
    stats = {
        "file": str(filepath),
        "tool_counts": Counter(),
        "files_read": Counter(),
        "files_edited": Counter(),
        "grep_patterns": [],
        "errors": [],
        "start_time": None,
        "end_time": None,
        "message_count": 0,
    }

    try:
        with open(filepath, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Track timestamps
                ts = entry.get("timestamp")
                if ts:
                    if isinstance(ts, (int, float)):
                        if stats["start_time"] is None or ts < stats["start_time"]:
                            stats["start_time"] = ts
                        if stats["end_time"] is None or ts > stats["end_time"]:
                            stats["end_time"] = ts

                stats["message_count"] += 1

                # Extract tool usage from assistant messages with tool_use
                msg_type = entry.get("type", "")
                if msg_type == "assistant":
                    content = entry.get("message", {}).get("content", [])
                    if isinstance(content, list):
                        for block in content:
                            if isinstance(block, dict) and block.get("type") == "tool_use":
                                tool_name = block.get("name", "unknown")
                                stats["tool_counts"][tool_name] += 1
                                tool_input = block.get("input", {})

                                # Track file reads
                                if tool_name == "Read":
                                    fp = tool_input.get("file_path", "")
                                    if fp:
                                        stats["files_read"][fp] += 1

                                # Track file edits
                                if tool_name in ("Edit", "Write"):
                                    fp = tool_input.get("file_path", "")
                                    if fp:
                                        stats["files_edited"][fp] += 1

                                # Track grep patterns
                                if tool_name == "Grep":
                                    pat = tool_input.get("pattern", "")
                                    if pat:
                                        stats["grep_patterns"].append(pat)

                                # Track Bash commands for grep usage
                                if tool_name == "Bash":
                                    cmd = tool_input.get("command", "")
                                    if "grep " in cmd or "rg " in cmd:
                                        stats["errors"].append(f"Bash grep: {cmd[:80]}")

                # Track errors from tool results
                if msg_type == "tool_result":
                    content = entry.get("content", "")
                    if isinstance(content, str) and ("error" in content.lower() or "failed" in content.lower()):
                        stats["errors"].append(content[:120])

    except Exception as e:
        stats["errors"].append(f"Parse error: {e}")

    return stats


def format_duration(seconds: float) -> str:
    """Format seconds as human-readable duration."""
    if seconds < 60:
        return f"{seconds:.0f}s"
    if seconds < 3600:
        return f"{seconds / 60:.0f}m"
    return f"{seconds / 3600:.1f}h"


def main():
    days_back = int(sys.argv[1]) if len(sys.argv) > 1 else 7
    project_filter = sys.argv[2] if len(sys.argv) > 2 else ""

    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        print(f"No projects directory found at {projects_dir}")
        sys.exit(1)

    files = find_session_files(projects_dir, days_back, project_filter)
    if not files:
        print(f"No sessions found in last {days_back} days" +
              (f" matching '{project_filter}'" if project_filter else ""))
        sys.exit(0)

    # Aggregate stats
    total_tool_counts = Counter()
    total_files_read = Counter()
    total_files_edited = Counter()
    total_grep_patterns = Counter()
    all_errors = []
    durations = []
    session_count = len(files)

    for f in files:
        stats = parse_session(f)
        total_tool_counts.update(stats["tool_counts"])
        total_files_read.update(stats["files_read"])
        total_files_edited.update(stats["files_edited"])
        total_grep_patterns.update(stats["grep_patterns"])
        all_errors.extend(stats["errors"][:5])  # Cap errors per session

        if stats["start_time"] and stats["end_time"]:
            dur = stats["end_time"] - stats["start_time"]
            if dur > 0:
                durations.append(dur)

    # Output report
    print(f"=== Session Mining Report ({days_back} days) ===")
    if project_filter:
        print(f"Filter: {project_filter}")
    print()

    # Session stats
    print(f"Sessions: {session_count}")
    if durations:
        avg_dur = sum(durations) / len(durations)
        max_dur = max(durations)
        print(f"Avg duration: {format_duration(avg_dur)}")
        print(f"Longest: {format_duration(max_dur)}")
        long_sessions = sum(1 for d in durations if d > 7200)
        if long_sessions:
            print(f"WARNING: {long_sessions} sessions over 2 hours (context degradation risk)")
    print()

    # Tool usage
    print("=== Tool Usage ===")
    for tool, count in total_tool_counts.most_common(10):
        print(f"  {tool}: {count}")
    print()

    # Bash grep detection
    bash_greps = [e for e in all_errors if e.startswith("Bash grep:")]
    if bash_greps:
        print(f"WARNING: {len(bash_greps)} Bash grep/rg calls (should use Grep tool)")
        print()

    # Hot files
    print("=== Most-Read Files (top 10) ===")
    for fp, count in total_files_read.most_common(10):
        # Shorten path for display
        short = fp.replace("\\", "/")
        if len(short) > 60:
            short = "..." + short[-57:]
        print(f"  {count:3d}x  {short}")
    print()

    print("=== Most-Edited Files (top 10) ===")
    for fp, count in total_files_edited.most_common(10):
        short = fp.replace("\\", "/")
        if len(short) > 60:
            short = "..." + short[-57:]
        print(f"  {count:3d}x  {short}")
    print()

    # Recurring grep patterns
    print("=== Recurring Search Patterns (top 10) ===")
    for pat, count in total_grep_patterns.most_common(10):
        if count >= 2:
            print(f"  {count:3d}x  {pat[:60]}")
    print()

    # Error patterns
    error_counter = Counter()
    for e in all_errors:
        if not e.startswith("Bash grep:"):
            # Normalize error messages for grouping
            key = e[:80]
            error_counter[key] += 1

    if error_counter:
        print("=== Recurring Errors (top 5) ===")
        for err, count in error_counter.most_common(5):
            if count >= 2:
                print(f"  {count:3d}x  {err}")
        print()

    print("=== Done ===")


if __name__ == "__main__":
    main()
