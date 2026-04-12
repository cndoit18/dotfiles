#!/bin/bash
# lark-url-detector.sh
# 检测用户输入中的飞书/Lark URL，提醒使用 lark-cli 和 lark skills

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# 检测 larkoffice.com / larksuite.com URL
if echo "$PROMPT" | grep -qiE 'https?://[a-zA-Z0-9.-]*larkoffice\.com|https?://[a-zA-Z0-9.-]*larksuite\.com'; then
	CONTEXT=$(cat "$(dirname "$0")/lark-url-detector-prompt.md")
	jq -n --arg ctx "$CONTEXT" '{
		"hookSpecificOutput": {
			"hookEventName": "UserPromptSubmit",
			"additionalContext": $ctx
		}
	}'
fi

exit 0
