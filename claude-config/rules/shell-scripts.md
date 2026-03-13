# Glob: **/*.sh

## Shell Script Rules
- `set -euo pipefail` at top of every script.
- Single-quote SSH commands containing `$` variables to prevent local expansion.
- Use `$HOME` not `~` in scripts (tilde doesn't expand in all contexts).
- Windows Git Bash: no `sudo`, use forward slashes, `jq` is available.
- Hook scripts: exit 0 = pass, exit 1 = warn (soft block), exit 2 = hard block.
- Scripts SCP'd from Windows need `sed -i 's/\r//' script.sh` (CRLF fix).
