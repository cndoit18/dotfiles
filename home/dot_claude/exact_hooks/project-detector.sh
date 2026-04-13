#!/bin/bash
# project-detector.sh
# 通用项目检测脚本，支持多种语言，从markdown文件读取提示词

set -euo pipefail

# 读取hook输入
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANGUAGES_DIR="$SCRIPT_DIR/languages"

LANGUAGES=()

[[ -f "$CWD/package.json" ]] && LANGUAGES+=("nodejs")
[[ -f "$CWD/go.mod" ]] && LANGUAGES+=("go")
[[ -f "$CWD/Cargo.toml" ]] && LANGUAGES+=("rust")
[[ -f "$CWD/pyproject.toml" || -f "$CWD/setup.py" ]] && LANGUAGES+=("python")
[[ -f "$CWD/pom.xml" || -f "$CWD/build.gradle" || -f "$CWD/build.gradle.kts" ]] && LANGUAGES+=("java")

if [[ ${#LANGUAGES[@]} -eq 0 ]]; then
	exit 0
fi

ADDITIONAL_CONTEXT=""
for LANGUAGE in "${LANGUAGES[@]}"; do
	LANGUAGE_FILE="$LANGUAGES_DIR/${LANGUAGE}.md"
	if [ -f "$LANGUAGE_FILE" ]; then
		ADDITIONAL_CONTEXT+="\n\n# **$LANGUAGE**\n"
		ADDITIONAL_CONTEXT+="$(cat "$LANGUAGE_FILE")"
	fi
done

# 返回JSON格式的额外上下文
jq -n --arg ctx "$ADDITIONAL_CONTEXT" '{
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": $ctx
    }
}'

exit 0
