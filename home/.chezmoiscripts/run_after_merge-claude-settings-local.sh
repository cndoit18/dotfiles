#!/bin/bash
set -euo pipefail

settings="$HOME/.claude/settings.json"
local_settings="$HOME/.claude/settings.local.json"

if [ ! -f "$local_settings" ]; then
    exit 0
fi

if [ ! -f "$settings" ]; then
    cp "$local_settings" "$settings"
    exit 0
fi

tmp=$(mktemp)
jq -n --argjson a "$(cat "$settings")" --argjson b "$(cat "$local_settings")" '
def deepmerge(a; b):
  if (a | type) == "object" and (b | type) == "object" then
    ((a | keys) + (b | keys) | unique) as $keys
    | reduce $keys[] as $k ({};
        if (a | has($k)) and (b | has($k)) then .[$k] = deepmerge(a[$k]; b[$k])
        elif (a | has($k)) then .[$k] = a[$k]
        else .[$k] = b[$k]
        end)
  elif (a | type) == "array" and (b | type) == "array" then a + b | unique
  else b
  end;

deepmerge($a; $b)
' > "$tmp" && mv "$tmp" "$settings"
