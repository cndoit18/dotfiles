#!/usr/bin/env bash
set -euo pipefail

is_obsidian_noise() {
	[[ -z "$1" || "$1" == *'Loading updated app package'* || "$1" == *'installer is out of date'* ]]
}

print_quoted_path() {
	local path=${1//\\/\\\\}
	path=${path//\"/\\\"}
	printf '"%s"' "$path"
}

build_context() {
	local intro
	intro=$(cat <<'HEADER'
# Memory Palace

The vault below is a curated LLM Wiki. When the user's question touches on any topic, system, component, or concept that matches or relates to a note listed in the vault index, delegate a query to the `memory-palace` agent before answering. The agent will search the vault and return evidence-grounded answers with provenance.

When to query:
- The user mentions any name, term, or concept that appears in a vault note title or path below
- The user asks about how something works, why a decision was made, or what the current status is
- The user asks you to create or update a note
- You are about to state a fact that the vault may already document

How to query: send the user's original question or a short description of what you need to know. Do NOT try to classify the domain or aspect yourself — the memory-palace agent will infer the right domain and search strategy from the vault structure. Example: "the user wants to know how the control plane works" or "check if we already have notes about monitoring dashboards before creating a new one"

HEADER
)
	printf '%s\n\n' "$intro"

	if vault_output="$(obsidian vaults verbose </dev/null 2>&1)"; then
		vault_entries=$'\n'
		while IFS= read -r vault_line; do
			is_obsidian_noise "$vault_line" && continue
			IFS=$'\t' read -r vault vault_path <<<"$vault_line"
			[[ -z "$vault" || "$vault_entries" == *$'\n'"$vault"$'\t'* ]] && continue
			vault_entries="$vault_entries$vault"$'\t'"$vault_path"$'\n'
		done <<<"$vault_output"

		if [[ "$vault_entries" == $'\n' ]]; then
			printf 'Memory Palace cache is unavailable: Obsidian CLI returned no vaults.\n'
		fi

		while IFS=$'\t' read -r vault vault_path; do
			[[ -z "$vault" ]] && continue
			printf '## Vault: %s (obsidian: %s' "$vault" "$vault"
			if [[ -n "$vault_path" ]]; then
				printf ', path: '
				print_quoted_path "$vault_path"
			fi
			printf ')\n'

			if files="$(obsidian files "vault=$vault" ext=md </dev/null 2>&1)"; then
				while IFS= read -r path; do
					is_obsidian_noise "$path" && continue
					printf '%s' '- '
					print_quoted_path "$path"
					if [[ -n "$vault_path" ]]; then
						printf ' (path: '
						print_quoted_path "${vault_path%/}/$path"
						printf ')'
					fi
					printf '\n'
				done <<<"$files"
			else
				printf 'Unavailable: failed to list Markdown files: %s\n' "$files"
			fi
			printf '\n'
		done <<<"$vault_entries"
	fi
}

CONTEXT="$(build_context)"

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
