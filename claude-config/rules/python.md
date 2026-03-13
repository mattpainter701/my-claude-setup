# Glob: **/*.py

## Python Rules
- Use `py` not `python` on Windows (py launcher).
- Type hints on public functions. No type hints on obvious local variables.
- f-strings over `.format()` or `%`. Exception: logging (`log.info("msg %s", val)`).
- `pathlib.Path` over `os.path` for new code. Don't refactor existing `os.path` unless touching that line.
- `ensure_ascii=False` + `encoding="utf-8"` on all `json.dump`/`json.dumps` calls that may contain non-ASCII (manifests, metadata, user-facing data).
- Never `from module import *`. Explicit imports only.
- Guard `if __name__ == "__main__":` on scripts.
