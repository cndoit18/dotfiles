#!/usr/bin/env bash
set -euo pipefail

is_obsidian_noise() {
	[[ -z "$1" || "$1" == *'Loading updated app package'* || "$1" == *'installer is out of date'* ]]
}

build_context() {
	printf '# Memory Palace\n\n'
	printf 'This is a compact index of external knowledge entry points. When a request mentions or clearly relates to a listed domain, product, note title, internal term, prior decision, or project history that could materially change the answer, delegate a quick context check to the `memory-palace` agent before answering. If a listed entry seems relevant but uncertain, prefer one short `memory-palace` lookup.\n\n'

	if vault_output="$(obsidian vaults </dev/null 2>&1)"; then
		vault_names=$'\n'
		while IFS= read -r vault; do
			is_obsidian_noise "$vault" && continue
			[[ "$vault_names" == *$'\n'"$vault"$'\n'* ]] && continue
			vault_names="$vault_names$vault"$'\n'
		done <<<"$vault_output"

		if [[ "$vault_names" == $'\n' ]]; then
			printf 'Memory Palace cache 当前不可用：Obsidian CLI 没有返回 vault。\n'
		fi

		while IFS= read -r vault; do
			[[ -z "$vault" ]] && continue
			printf '## Vault: %s (obsidian: %s)\n' "$vault" "$vault"
			if files="$(obsidian files "vault=$vault" ext=md </dev/null 2>&1)"; then
				while IFS= read -r path; do
					is_obsidian_noise "$path" && continue
					printf -- '- %s\n' "$path"
				done <<<"$files"
			else
				printf 'Unavailable: failed to list Markdown files: %s\n' "$files"
			fi
			printf '\n'
		done <<<"$vault_names"
	fi
}

CONTEXT="$(build_context)"

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
