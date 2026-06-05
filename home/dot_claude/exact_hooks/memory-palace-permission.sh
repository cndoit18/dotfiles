#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
agent_type=$(jq -r '.agent_type // empty' <<<"$input")
tool_name=$(jq -r '.tool_name // empty' <<<"$input")

allow() {
	jq -n '{
		"hookSpecificOutput": {
			"hookEventName": "PermissionRequest",
			"decision": {"behavior": "allow"}
		}
	}'
}

if [[ "$agent_type" != "memory-palace" ]]; then
	exit 0
fi

case "$tool_name" in
	Read|Grep|Glob)
		allow
		;;
	Skill)
		skill=$(jq -r '.tool_input.skill // empty' <<<"$input")
		if [[ "$skill" == "obsidian:obsidian-cli" ]]; then
			allow
		fi
		;;
	Bash)
		command=$(jq -r '.tool_input.command // empty' <<<"$input")
		case "$command" in
			obsidian\ help*|obsidian\ vaults*|obsidian\ files*|obsidian\ search*)
				allow
				;;
			*)
				if [[ "$command" =~ ^ls([[:space:]]+[-A-Za-z0-9@,%.]+|[[:space:]]+[./~A-Za-z0-9_@%+=:,.-]+)*[[:space:]]*$ ]]; then
					allow
				fi
				;;
		esac
		;;
esac
