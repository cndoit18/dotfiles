#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  cat <<'USAGE'
Usage: bash scripts/references.sh [keyword ...]

Print a compact reference catalog without loading article bodies.
Keywords are case-insensitive and combined with AND.
Paths are resolved relative to the Skill root, not the caller's cwd.

Examples:
  bash scripts/references.sh
  bash scripts/references.sh 故障 复盘
  bash scripts/references.sh ADR
  bash scripts/references.sh 机制 zh
USAGE
  exit 0
fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SKILL_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
REF_DIR="$SKILL_ROOT/references"
[[ -d "$REF_DIR" ]] || { printf 'Missing references directory: %s\n' "$REF_DIR" >&2; exit 1; }

export KEYS="$(printf '%s\n' "$@")"
printf 'file\tkind\tlanguage\ttitle\tuse_for\tread_next\n'
found=0
for file in "$REF_DIR"/*.md; do
  [[ -f "$file" ]] || continue
  if awk -v filename="${file##*/}" '
    BEGIN { in_meta=0; n=split(ENVIRON["KEYS"], keys, "\n") }
    FNR == 1 && $0 == "---" { in_meta=1; next }
    in_meta && $0 == "---" {
      haystack=tolower(filename " " values["kind"] " " values["language"] " " values["title"] " " values["use_for"] " " values["read_next"])
      matched=1
      for (i=1; i<=n; i++) { if (keys[i] != "" && index(haystack, tolower(keys[i])) == 0) matched=0 }
      if (matched) { printf "%s\t%s\t%s\t%s\t%s\t%s\n", filename, values["kind"], values["language"], values["title"], values["use_for"], values["read_next"]; found=1 }
      in_meta=0; next
    }
    in_meta && /^[a-z_]+:/ {
      key=$0; sub(/:.*/, "", key)
      value=substr($0, index($0, ":") + 2)
      sub(/^"/, "", value); sub(/"$/, "", value)
      values[key]=value
    }
    END { if (found) exit 0; exit 1 }
  ' "$file"; then found=1; fi
done
if [[ $found -eq 0 ]]; then printf 'No references matched.\n' >&2; fi
