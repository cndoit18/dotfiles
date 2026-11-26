#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bash scripts/render_d2.sh [--layout elk|tala|dagre] <input.d2> [output-prefix]

Validate a D2 source file, then render SVG and PNG with the selected layout.
The default layout is tala; use --layout elk for a layered-graph alternative.
The default output prefix is the input path without its final .d2 suffix.
Set D2_BIN when the d2 executable is not on PATH. No dependencies are installed.

Examples:
  bash scripts/render_d2.sh architecture.d2
  bash scripts/render_d2.sh --layout tala architecture.d2 dist/architecture
  D2_BIN=/opt/d2/bin/d2 bash scripts/render_d2.sh --layout elk architecture.d2
USAGE
}

layout=tala
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -l|--layout)
      [[ $# -ge 2 ]] || { printf 'Missing value for %s\n' "$1" >&2; exit 2; }
      layout="$2"
      shift 2
      ;;
    --layout=*)
      layout="${1#*=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

[[ "$layout" == "elk" || "$layout" == "tala" || "$layout" == "dagre" ]] || {
  printf 'Unsupported layout: %s (expected elk, tala, or dagre)\n' "$layout" >&2
  exit 2
}
[[ $# -ge 1 && $# -le 2 ]] || {
  usage >&2
  exit 2
}

input="$1"
[[ -f "$input" ]] || { printf 'D2 input does not exist: %s\n' "$input" >&2; exit 1; }
if [[ $# -eq 2 ]]; then
  prefix="$2"
else
  prefix="${input%.d2}"
fi
[[ "$prefix" != "$input" || "$input" != *.d2 ]] || {
  printf 'Could not derive output prefix; provide it explicitly.\n' >&2
  exit 2
}

d2_bin="${D2_BIN:-d2}"
command -v "$d2_bin" >/dev/null 2>&1 || {
  printf 'D2 executable not found: %s. Install D2 or set D2_BIN; no install was attempted.\n' "$d2_bin" >&2
  exit 1
}

version="$("$d2_bin" version)"
svg="${prefix}.svg"
png="${prefix}.png"

"$d2_bin" validate "$input"
"$d2_bin" --layout="$layout" --pad 60 --center "$input" "$svg"
"$d2_bin" --layout="$layout" --pad 60 --center "$input" "$png"
[[ -s "$svg" && -s "$png" ]] || {
  printf 'Renderer returned success but output is missing or empty.\n' >&2
  exit 1
}

python3 -c 'import json, sys
print(json.dumps({
  "status": "rendered",
  "layout": sys.argv[1],
  "d2_version": sys.argv[2],
  "input": sys.argv[3],
  "svg": sys.argv[4],
  "png": sys.argv[5],
}, ensure_ascii=False))' "$layout" "$version" "$input" "$svg" "$png"
