#!/usr/bin/env python3
"""Audit a Claude Code install and optional project wiring."""

from __future__ import annotations

import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


CORE_SKILLS = [
    "commit",
    "sprint",
    "catchup",
    "research",
    "review",
    "session_mine",
    "memory_sync",
    "verify",
    "doctor",
    "bootstrap",
    "verifier_hooks",
]

CONDITIONAL_SKILLS = [
    "hook_authoring",
    "skill_authoring",
    "agent_authoring",
]

CORE_AGENTS = [
    "code-reviewer.md",
    "session-analyst.md",
    "research-analyst.md",
    "security-reviewer.md",
]

CORE_SCRIPTS = [
    "perplexity_search.py",
    "session_mine.py",
    "claude_doctor.py",
]

GLOBAL_HOOKS = [
    ("PreToolUse", "block-coauthored.sh"),
    ("PostToolUse", "auto-lint.sh"),
    ("Notification", "notify-permission.sh"),
    ("SessionStart", "session-context.sh"),
    ("Stop", "notify-done.sh"),
    ("SubagentStop", "log-hook-event.sh"),
    ("SessionEnd", "log-hook-event.sh"),
]

PROJECT_HOOKS = [
    ("PreToolUse", "commit-test-gate.sh"),
    ("PreToolUse", "commit-docs-gate.sh"),
    ("PostToolUse", "mark-tests-passed.sh"),
    ("PreCompact", "pre-compact-context.sh"),
]

STATUS_ORDER = {"FAIL": 0, "WARN": 1, "INFO": 2, "PASS": 3}


@dataclass
class Check:
    level: str
    name: str
    detail: str
    fix: str | None = None


def add(results: list[Check], level: str, name: str, detail: str, fix: str | None = None) -> None:
    results.append(Check(level=level, name=name, detail=detail, fix=fix))


def load_json(path: Path) -> tuple[Any | None, str | None]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), None
    except FileNotFoundError:
        return None, "missing"
    except json.JSONDecodeError as exc:
        return None, f"invalid JSON: {exc.msg} (line {exc.lineno}, col {exc.colno})"
    except OSError as exc:
        return None, str(exc)


def find_hook_command(settings: dict[str, Any], event: str, needle: str) -> bool:
    hooks = settings.get("hooks", {})
    if not isinstance(hooks, dict):
        return False
    matchers = hooks.get(event, [])
    if not isinstance(matchers, list):
        return False
    for matcher in matchers:
        if not isinstance(matcher, dict):
            continue
        inner = matcher.get("hooks", [])
        if not isinstance(inner, list):
            continue
        for hook in inner:
            if not isinstance(hook, dict):
                continue
            command = str(hook.get("command", ""))
            if needle in command:
                return True
    return False


def which(name: str) -> str | None:
    return shutil.which(name)


def find_git_bash() -> str | None:
    candidates = []
    bash_on_path = which("bash")
    if bash_on_path:
        candidates.append(Path(bash_on_path))

    local_appdata = os.environ.get("LOCALAPPDATA")
    if local_appdata:
        candidates.append(Path(local_appdata) / "Programs" / "Git" / "bin" / "bash.exe")
        candidates.append(Path(local_appdata) / "Programs" / "Git" / "usr" / "bin" / "bash.exe")

    candidates.extend(
        [
            Path(r"C:\Program Files\Git\bin\bash.exe"),
            Path(r"C:\Program Files\Git\usr\bin\bash.exe"),
            Path(r"C:\Program Files (x86)\Git\bin\bash.exe"),
            Path(r"C:\Program Files (x86)\Git\usr\bin\bash.exe"),
        ]
    )

    for candidate in candidates:
        candidate_str = str(candidate)
        if candidate.exists() and "\\git\\" in candidate_str.lower():
            return candidate_str
    return None


def run_capture(command: list[str]) -> tuple[int, str, str]:
    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError as exc:
        return 127, "", str(exc)
    return completed.returncode, completed.stdout.strip(), completed.stderr.strip()


def check_binary(results: list[Check], name: str, required: bool = True, label: str | None = None) -> None:
    found = which(name)
    display = label or name
    if found:
        add(results, "PASS", f"Binary: {display}", found)
        return
    level = "FAIL" if required else "WARN"
    add(results, level, f"Binary: {display}", "not found on PATH", f"Install or expose `{name}` on PATH.")


def check_settings_flags(results: list[Check], settings: dict[str, Any], settings_path: Path) -> None:
    recommended_truthy = [
        "autoMemoryEnabled",
        "fileCheckpointingEnabled",
        "showTurnDuration",
        "terminalProgressBarEnabled",
        "todoFeatureEnabled",
    ]
    enabled = [key for key in recommended_truthy if settings.get(key) is True]
    missing = [key for key in recommended_truthy if settings.get(key) is not True]

    if missing:
        add(
            results,
            "WARN",
            "Global settings",
            f"{settings_path} is missing or disabling: {', '.join(missing)}",
            "Enable the recommended Claude Code quality-of-life settings in ~/.claude/settings.json.",
        )
    else:
        add(results, "PASS", "Global settings", "Recommended Claude Code settings are enabled.")

    permissions = settings.get("permissions", {})
    if isinstance(permissions, dict) and permissions.get("defaultMode"):
        add(
            results,
            "PASS",
            "Permission mode",
            f"defaultMode={permissions.get('defaultMode')}",
        )
    else:
        add(
            results,
            "WARN",
            "Permission mode",
            "permissions.defaultMode is not set.",
            "Set permissions.defaultMode deliberately in ~/.claude/settings.json.",
        )


def check_burnttoast(results: list[Check]) -> None:
    powershell = which("pwsh") or which("powershell")
    if not powershell:
        add(results, "WARN", "BurntToast", "PowerShell not found; toast notifications cannot be checked.")
        return
    code, stdout, _ = run_capture(
        [
            powershell,
            "-NoProfile",
            "-NonInteractive",
            "-Command",
            "Get-Module -ListAvailable BurntToast | Select-Object -First 1 -ExpandProperty Version",
        ]
    )
    if code == 0 and stdout:
        add(results, "PASS", "BurntToast", f"Installed ({stdout})")
    else:
        add(
            results,
            "WARN",
            "BurntToast",
            "Module not installed; notify-permission hook will fall back to beep-only behavior.",
            "Run `Install-Module BurntToast -Scope CurrentUser` if you want Windows toast notifications.",
        )


def detect_mcp(project_root: Path | None, settings: dict[str, Any] | None) -> tuple[bool, str]:
    if isinstance(settings, dict):
        if settings.get("mcpServers"):
            return True, "Detected mcpServers in ~/.claude/settings.json"
        if settings.get("plugins"):
            return True, "Detected plugin configuration in ~/.claude/settings.json"

    if project_root is not None:
        project_mcp = project_root / ".mcp.json"
        if project_mcp.exists():
            return True, f"Detected {project_mcp}"

    return False, "No MCP or plugin configuration detected"


def check_global_install(results: list[Check], home: Path) -> dict[str, Any] | None:
    if home.exists():
        add(results, "PASS", "Claude home", str(home))
    else:
        add(
            results,
            "FAIL",
            "Claude home",
            f"{home} does not exist.",
            "Create ~/.claude and copy the repo's global configuration into it.",
        )
        return None

    claude_md = home / "CLAUDE.md"
    if claude_md.exists():
        add(results, "PASS", "Global rules", str(claude_md))
    else:
        add(
            results,
            "FAIL",
            "Global rules",
            f"{claude_md} is missing.",
            "Copy claude-config/CLAUDE.global.md to ~/.claude/CLAUDE.md.",
        )

    for dirname in ("skills", "agents", "hooks", "scripts"):
        path = home / dirname
        if path.is_dir():
            add(results, "PASS", f"Directory: {dirname}", str(path))
        else:
            add(
                results,
                "FAIL",
                f"Directory: {dirname}",
                f"{path} is missing.",
                f"Create {path} and copy the repo's {dirname} content into it.",
            )

    skills_dir = home / "skills"
    if skills_dir.is_dir():
        for skill in CORE_SKILLS:
            path = skills_dir / skill / "SKILL.md"
            if path.exists():
                add(results, "PASS", f"Skill: {skill}", str(path))
            else:
                add(
                    results,
                    "WARN",
                    f"Skill: {skill}",
                    "missing",
                    f"Copy ~/.claude/skills/{skill} from the repo.",
                )
        for skill in CONDITIONAL_SKILLS:
            path = skills_dir / skill / "SKILL.md"
            if path.exists():
                add(results, "PASS", f"Conditional skill: {skill}", str(path))
            else:
                add(
                    results,
                    "WARN",
                    f"Conditional skill: {skill}",
                    "missing",
                    f"Copy ~/.claude/skills/{skill} from the repo so path-scoped guidance can auto-activate.",
                )

    agents_dir = home / "agents"
    if agents_dir.is_dir():
        for agent in CORE_AGENTS:
            path = agents_dir / agent
            if path.exists():
                add(results, "PASS", f"Agent: {agent}", str(path))
            else:
                add(
                    results,
                    "WARN",
                    f"Agent: {agent}",
                    "missing",
                    f"Copy ~/.claude/agents/{agent} from the repo.",
                )

    scripts_dir = home / "scripts"
    if scripts_dir.is_dir():
        for script in CORE_SCRIPTS:
            path = scripts_dir / script
            if path.exists():
                add(results, "PASS", f"Helper script: {script}", str(path))
            else:
                add(
                    results,
                    "FAIL",
                    f"Helper script: {script}",
                    "missing",
                    f"Copy ~/.claude/scripts/{script} from the repo.",
                )

    settings_path = home / "settings.json"
    settings, error = load_json(settings_path)
    if settings is None:
        level = "FAIL" if error == "missing" else "WARN"
        add(
            results,
            level,
            "Global settings file",
            f"{settings_path}: {error}",
            "Create or fix ~/.claude/settings.json so hooks and settings can load.",
        )
        return None

    add(results, "PASS", "Global settings file", str(settings_path))
    assert isinstance(settings, dict)
    check_settings_flags(results, settings, settings_path)

    for event, script in GLOBAL_HOOKS:
        if find_hook_command(settings, event, script):
            add(results, "PASS", f"Global hook: {script}", f"Registered under {event}")
        else:
            add(
                results,
                "WARN",
                f"Global hook: {script}",
                f"Not registered under {event} in {settings_path}",
                f"Add {script} to the {event} hooks block in ~/.claude/settings.json.",
            )

    return settings


def check_project(results: list[Check], project_root: Path) -> None:
    if not project_root.exists():
        add(results, "FAIL", "Project root", f"{project_root} does not exist.")
        return

    add(results, "PASS", "Project root", str(project_root))

    claude_dir = project_root / ".claude"
    if claude_dir.is_dir():
        add(results, "PASS", "Project .claude", str(claude_dir))
    else:
        add(
            results,
            "WARN",
            "Project .claude",
            f"{claude_dir} is missing.",
            "Run /bootstrap project or copy the project stencil into .claude/.",
        )
        return

    project_rules = claude_dir / "CLAUDE.md"
    if project_rules.exists():
        add(results, "PASS", "Project rules", str(project_rules))
    else:
        add(
            results,
            "WARN",
            "Project rules",
            f"{project_rules} is missing.",
            "Copy claude-config/project-stencil/CLAUDE.project.md into .claude/CLAUDE.md.",
        )

    local_settings_path = claude_dir / "settings.local.json"
    local_settings, error = load_json(local_settings_path)
    if local_settings is None:
        add(
            results,
            "WARN",
            "Project settings",
            f"{local_settings_path}: {error}",
            "Add .claude/settings.local.json if you want project-specific hooks or MCP wiring.",
        )
    else:
        add(results, "PASS", "Project settings", str(local_settings_path))
        assert isinstance(local_settings, dict)
        for event, script in PROJECT_HOOKS:
            if find_hook_command(local_settings, event, script):
                add(results, "PASS", f"Project hook: {script}", f"Registered under {event}")
            else:
                add(
                    results,
                    "INFO",
                    f"Project hook: {script}",
                    f"Not registered under {event}",
                )

    rules_dir = claude_dir / "rules"
    if rules_dir.is_dir():
        add(results, "PASS", "Project rules dir", str(rules_dir))
    else:
        add(results, "INFO", "Project rules dir", "No .claude/rules/ directory yet.")

    local_md = project_root / "CLAUDE.local.md"
    if local_md.exists():
        add(results, "PASS", "Local rules", str(local_md))
    else:
        add(results, "INFO", "Local rules", "CLAUDE.local.md not present.")

    task_file = project_root / "TASKS.md"
    changelog_file = project_root / "CHANGELOG.md"
    if task_file.exists() and changelog_file.exists():
        add(results, "PASS", "Workflow files", "TASKS.md and CHANGELOG.md are present.")
    elif task_file.exists() or changelog_file.exists():
        add(
            results,
            "WARN",
            "Workflow files",
            "Only one of TASKS.md / CHANGELOG.md is present.",
            "Keep TASKS.md and CHANGELOG.md together if you use the sprint workflow.",
        )
    else:
        add(results, "INFO", "Workflow files", "TASKS.md / CHANGELOG.md not detected.")


def print_report(mode: str, results: list[Check]) -> None:
    counts = {level: 0 for level in ("PASS", "WARN", "FAIL", "INFO")}
    for result in results:
        counts[result.level] += 1

    print(f"Claude doctor ({mode})")
    print("")
    for result in sorted(results, key=lambda item: (STATUS_ORDER[item.level], item.name.lower())):
        print(f"[{result.level}] {result.name}: {result.detail}")

    fixes = []
    seen = set()
    for result in results:
        if result.level not in {"FAIL", "WARN"} or not result.fix:
            continue
        if result.fix in seen:
            continue
        fixes.append(result.fix)
        seen.add(result.fix)

    print("")
    print(
        "Summary: "
        f"{counts['PASS']} pass, {counts['WARN']} warn, {counts['FAIL']} fail, {counts['INFO']} info"
    )
    if fixes:
        print("Next fixes:")
        for index, fix in enumerate(fixes[:5], start=1):
            print(f"{index}. {fix}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=["quick", "full"], default="quick")
    parser.add_argument("--home", default=str(Path.home() / ".claude"))
    parser.add_argument("--project-root", default=os.getcwd())
    args = parser.parse_args()

    results: list[Check] = []
    home = Path(args.home).expanduser().resolve()
    project_root = Path(args.project_root).expanduser().resolve()

    add(results, "INFO", "Platform", f"{platform.system()} {platform.release()}")
    check_binary(results, "py", required=True, label="Python launcher")
    check_binary(results, "jq", required=True)

    if os.name == "nt":
        bash_path = find_git_bash()
        if bash_path:
            add(results, "PASS", "Git Bash", bash_path)
        else:
            add(
                results,
                "FAIL",
                "Git Bash",
                "Git Bash not found.",
                "Install Git for Windows so Claude hooks can run bash scripts.",
            )
        check_burnttoast(results)
    else:
        check_binary(results, "bash", required=True)

    secrets_env = Path.home() / ".config" / "secrets.env"
    if secrets_env.exists():
        content = secrets_env.read_text(encoding="utf-8", errors="ignore")
        if "PERPLEXITY_API_KEY=" in content:
            add(results, "PASS", "Research credentials", str(secrets_env))
        else:
            add(
                results,
                "INFO",
                "Research credentials",
                f"{secrets_env} exists but PERPLEXITY_API_KEY was not detected.",
            )
    else:
        add(
            results,
            "INFO",
            "Research credentials",
            f"{secrets_env} not found; research falls back to WebSearch/WebFetch.",
        )

    settings = check_global_install(results, home)

    mcp_found, mcp_detail = detect_mcp(project_root if args.mode == "full" else None, settings)
    add(results, "PASS" if mcp_found else "INFO", "MCP / plugins", mcp_detail)

    if args.mode == "full":
        check_project(results, project_root)

    print_report(args.mode, results)
    return 0


if __name__ == "__main__":
    sys.exit(main())
